-- ============================================================================
-- DataScout Monitor v6.0 – Smart Monitor (tookit)
-- Giám sát toàn diện: Values, NPC, Blocks, Models, Player Scripts, Map changes
-- Toggle: Right Control hoặc nút thu nhỏ
-- ============================================================================

local Tookit = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- STATE
-- ============================================================================
Tookit.State = {
    values = {},         -- {path = value}
    prevValues = {},
    history = {},        -- {path = {values, times}}
    npcs = {},           -- {model = {name, health, pos, ...}}
    blocks = {},
    models = {},
    newObjects = {},
    mapChangeLog = {},
    playerScripts = {},
    autoRefresh = true,
    interval = 2,
    filterText = "",
    aiReport = "",
    lastAnalysis = "",
    isAnalyzing = false,
    minified = false,
    cleanup = {},
}

-- ============================================================================
-- UTILITY (có xử lý lỗi)
-- ============================================================================
local function safeCall(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then warn("[DataScout] " .. tostring(result)) end
    return ok and result
end

local function safeCopy(text)
    return safeCall(function()
        if setclipboard then setclipboard(text) return true end
        return false
    end) or false
end

local function tableCount(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

local function getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ============================================================================
-- DATA COLLECTORS (nhanh hơn)
-- ============================================================================
local function collectAllValues()
    local result = {}
    local containers = {Workspace, Players, RS, SS, Lighting, CoreGui,
        game:GetService("StarterGui"), game:GetService("StarterPack")}
    for _, c in pairs(containers) do
        if c then
            for _, obj in pairs(c:GetDescendants()) do
                if obj:IsA("ValueBase") then
                    local path = obj:GetFullName()
                    if not result[path] then
                        local val = obj.Value
                        if type(val) ~= "table" and type(val) ~= "userdata" then
                            result[path] = val
                        end
                    end
                end
            end
        end
    end
    return result
end

local function collectNPCs()
    local list = {}
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
            if not Players:GetPlayerFromCharacter(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                list[model] = {
                    name = model.Name,
                    health = hum and math.floor(hum.Health) or 0,
                    maxHealth = hum and math.floor(hum.MaxHealth) or 0,
                    pos = hrp and hrp.Position or Vector3.new(0,0,0),
                    model = model,
                }
            end
        end
    end
    return list
end

local function collectBlocks()
    local list = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            list[obj] = {
                name = obj.Name,
                pos = obj.Position,
                size = obj.Size,
                transparency = obj.Transparency,
                isInvisible = obj.Transparency > 0.8,
                parent = obj.Parent,
            }
        elseif obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") then
            local primary = obj.PrimaryPart
            list[obj] = {
                name = obj.Name,
                pos = primary and primary.Position or Vector3.new(0,0,0),
                isModel = true,
            }
        end
    end
    return list
end

local function collectPlayerScripts()
    local scripts = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char then
                for _, obj in pairs(char:GetDescendants()) do
                    if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                        table.insert(scripts, {player = plr, script = obj, name = obj.Name})
                    end
                end
            end
        end
    end
    return scripts
end

-- ============================================================================
-- UPDATE DATA
-- ============================================================================
local function updateData()
    local S = Tookit.State

    -- Values
    local newValues = collectAllValues()
    local oldValues = S.values
    S.prevValues = oldValues
    S.values = newValues

    -- History for values
    for path, val in pairs(newValues) do
        if not S.history[path] then
            S.history[path] = { values = {}, times = {} }
        end
        local hist = S.history[path]
        if #hist.values == 0 or hist.values[#hist.values] ~= val then
            table.insert(hist.values, val)
            table.insert(hist.times, os.time())
            if #hist.values > 30 then
                table.remove(hist.values, 1)
                table.remove(hist.times, 1)
            end
        end
    end

    -- NPCs
    S.npcs = collectNPCs()

    -- Blocks & Models
    S.blocks = collectBlocks()

    -- Player scripts
    S.playerScripts = collectPlayerScripts()

    -- Detect new objects (so với lần trước)
    local prevBlocks = S.prevBlocks or {}
    for obj, _ in pairs(S.blocks) do
        if not prevBlocks[obj] then
            table.insert(S.mapChangeLog, {time = os.date("%H:%M:%S"), desc = "🆕 New object: " .. obj.Name})
        end
    end
    S.prevBlocks = S.blocks
end

-- ============================================================================
-- AI ENGINE (cải tiến tốc độ)
-- ============================================================================
local function calculateMean(t)
    local sum = 0
    for _, v in pairs(t) do sum = sum + v end
    return #t > 0 and sum / #t or 0
end

local function calculateStdDev(t, mean)
    if #t < 2 then return 0 end
    local sq = 0
    for _, v in pairs(t) do sq = sq + (v - mean)^2 end
    return math.sqrt(sq / (#t - 1))
end

local function runAIAnalysis()
    local S = Tookit.State
    if S.isAnalyzing then return end
    S.isAnalyzing = true

    local report = {}
    local insights = {}
    local warnings = {}
    local suggestions = {}

    -- 1. Phân tích giá trị số
    local numValues = tableCount(S.values)
    local changed = 0
    local inc, dec = {}, {}
    for path, val in pairs(S.values) do
        local old = S.prevValues[path]
        if old ~= nil and old ~= val then
            changed = changed + 1
            if val > old then
                table.insert(inc, {path = path, diff = val - old, pct = (val - old) / math.abs(old) * 100})
            else
                table.insert(dec, {path = path, diff = old - val, pct = (old - val) / math.abs(old) * 100})
            end
        end
    end
    table.insert(report, "📊 Tổng giá trị: " .. numValues)
    table.insert(report, "🔄 Thay đổi: " .. changed)

    -- Bất thường
    for path, hist in pairs(S.history) do
        local vals = hist.values
        if #vals >= 5 then
            local mean = calculateMean(vals)
            local std = calculateStdDev(vals, mean)
            local latest = vals[#vals]
            if std > 0 and math.abs(latest - mean) > 2.5 * std then
                local dir = latest > mean and "tăng" or "giảm"
                table.insert(warnings, string.format("⚠️ Bất thường `%s`: %s đột biến (%.1f→%.1f)", path, dir, mean, latest))
            end
        end
    end

    -- Xu hướng
    for path, hist in pairs(S.history) do
        local vals = hist.values
        if #vals >= 5 then
            local recent = {}
            for i = #vals-4, #vals do table.insert(recent, vals[i]) end
            local up = true
            local down = true
            for i = 2, #recent do
                if recent[i] <= recent[i-1] then up = false end
                if recent[i] >= recent[i-1] then down = false end
            end
            if up then
                local pct = (recent[#recent] - recent[1]) / math.abs(recent[1]) * 100
                if pct > 10 then
                    table.insert(insights, string.format("📈 `%s` tăng liên tục (%.1f%%)", path, pct))
                end
            elseif down then
                local pct = (recent[1] - recent[#recent]) / math.abs(recent[1]) * 100
                if pct > 10 then
                    table.insert(warnings, string.format("📉 `%s` giảm liên tục (%.1f%%)", path, pct))
                end
            end
        end
    end

    -- 2. Phân tích NPC
    local npcCount = tableCount(S.npcs)
    table.insert(report, "👾 NPC: " .. npcCount)
    if npcCount > 0 then
        local lowHP = 0
        for _, info in pairs(S.npcs) do
            if info.health < info.maxHealth * 0.2 then lowHP = lowHP + 1 end
        end
        if lowHP > 0 then
            table.insert(warnings, string.format("⚠️ %d NPC có HP thấp (<20%)", lowHP))
        end
    end

    -- 3. Block & Model
    local blockCount = 0
    local invisibleCount = 0
    for obj, info in pairs(S.blocks) do
        if info.isInvisible then invisibleCount = invisibleCount + 1
        else blockCount = blockCount + 1 end
    end
    table.insert(report, "🧱 Blocks: " .. blockCount .. " (Ẩn: " .. invisibleCount .. ")")
    if invisibleCount > 10 then
        table.insert(warnings, "⚠️ Có nhiều khối tàng hình (" .. invisibleCount .. ")")
    end

    -- 4. Đề xuất
    if #inc > 0 then
        table.sort(inc, function(a,b) return a.pct > b.pct end)
        table.insert(suggestions, "💡 Giá trị tăng mạnh nhất: " .. inc[1].path .. " (+" .. string.format("%.1f%%", inc[1].pct) .. ")")
    end
    if #dec > 0 then
        table.sort(dec, function(a,b) return a.pct > b.pct end)
        table.insert(suggestions, "💡 Giá trị giảm mạnh nhất: " .. dec[1].path .. " (-" .. string.format("%.1f%%", dec[1].pct) .. ")")
    end

    -- Tổng hợp
    local final = {}
    table.insert(final, "🤖 BÁO CÁO GIÁM SÁT TOÀN DIỆN")
    table.insert(final, "==================================")
    for _, line in ipairs(report) do table.insert(final, line) end
    if #insights > 0 then
        table.insert(final, "")
        table.insert(final, "🔍 INSIGHTS:")
        for _, line in ipairs(insights) do table.insert(final, line) end
    end
    if #warnings > 0 then
        table.insert(final, "")
        table.insert(final, "⚠️ CẢNH BÁO:")
        for _, line in ipairs(warnings) do table.insert(final, line) end
    end
    if #suggestions > 0 then
        table.insert(final, "")
        table.insert(final, "💡 ĐỀ XUẤT:")
        for _, line in ipairs(suggestions) do table.insert(final, line) end
    end
    if #warnings == 0 and #insights == 0 then
        table.insert(final, "✅ Hệ thống ổn định.")
    end

    S.aiReport = table.concat(final, "\n")
    S.lastAnalysis = os.date("%H:%M:%S")
    S.isAnalyzing = false
end

-- ============================================================================
-- UI BUILDER – với Mini bar và nhóm nút
-- ============================================================================
local function buildUI()
    local S = Tookit.State

    -- ScreenGui
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "DataScoutMonitor"
    Gui.ResetOnSpawn = false
    safeCall(function()
        if gethui then Gui.Parent = gethui()
        elseif syn and syn.protect_gui then syn.protect_gui(Gui); Gui.Parent = CoreGui
        else Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    end)

    -- ================================
    -- MAIN FRAME
    -- ================================
    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0.85, 0, 0.8, 0)
    Main.Position = UDim2.new(0.075, 0, 0.1, 0)
    Main.BackgroundColor3 = Color3.fromRGB(12,12,18)
    Main.Active = true
    Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0,255,200)

    -- Title Bar
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0.02, 0, 0, 0)
    Title.Text = "📊 DataScout Monitor v6.0 (tookit)"
    Title.TextColor3 = Color3.fromRGB(0,255,200)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextScaled = true
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Mini toggle
    local MiniBtn = Instance.new("TextButton", TitleBar)
    MiniBtn.Size = UDim2.new(0, 28, 0, 24)
    MiniBtn.Position = UDim2.new(1, -70, 0, 4)
    MiniBtn.Text = "—"
    MiniBtn.TextColor3 = Color3.fromRGB(255,200,50)
    MiniBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
    MiniBtn.Font = Enum.Font.SourceSansBold
    MiniBtn.TextSize = 14
    Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 4)

    -- Close
    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.Size = UDim2.new(0, 28, 0, 24)
    CloseBtn.Position = UDim2.new(1, -36, 0, 4)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 14
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    -- ================================
    -- TAB BAR
    -- ================================
    local TabBar = Instance.new("Frame", Main)
    TabBar.Size = UDim2.new(1, -8, 0, 28)
    TabBar.Position = UDim2.new(0, 4, 0, 34)
    TabBar.BackgroundTransparency = 1

    local tabNames = {"📊 Values", "👾 NPC", "🧱 Blocks", "📜 Scripts", "📋 Log"}
    local tabs = {}
    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0.2, -2, 1, 0)
        btn.Position = UDim2.new(0.2*(i-1)+0.005, 0, 0, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(22,22,28)
        btn.TextColor3 = Color3.fromRGB(150,150,160)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextScaled = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local page = Instance.new("ScrollingFrame", Main)
        page.Size = UDim2.new(1, -12, 1, -72)
        page.Position = UDim2.new(0, 6, 0, 66)
        page.BackgroundColor3 = Color3.fromRGB(8,8,12)
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.ScrollBarThickness = 4
        page.Visible = false
        Instance.new("UICorner", page).CornerRadius = UDim.new(0, 6)

        tabs[name] = {btn = btn, page = page}
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = Color3.fromRGB(22,22,28)
                t.btn.TextColor3 = Color3.fromRGB(150,150,160)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(0,180,120)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        end)
    end
    tabs["📊 Values"].btn.BackgroundColor3 = Color3.fromRGB(0,180,120)
    tabs["📊 Values"].btn.TextColor3 = Color3.fromRGB(255,255,255)
    tabs["📊 Values"].page.Visible = true

    -- ================================
    -- CONTROL BAR – NHÓM NÚT THEO KHU
    -- ================================
    local CBar = Instance.new("Frame", Main)
    CBar.Size = UDim2.new(1, -8, 0, 32)
    CBar.Position = UDim2.new(0, 4, 0, 34)
    CBar.BackgroundTransparency = 1

    -- Khu 1: Điều khiển (Refresh, Auto)
    local Group1 = Instance.new("Frame", CBar)
    Group1.Size = UDim2.new(0.25, 0, 1, 0)
    Group1.BackgroundTransparency = 1

    local G1Layout = Instance.new("UIListLayout", Group1)
    G1Layout.FillDirection = Enum.FillDirection.Horizontal
    G1Layout.Padding = UDim.new(0, 4)
    G1Layout.VerticalAlignment = Enum.VerticalAlignment.Center

    local RefreshBtn = Instance.new("TextButton", Group1)
    RefreshBtn.Size = UDim2.new(0, 28, 0, 24)
    RefreshBtn.Text = "🔄"
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
    RefreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
    RefreshBtn.Font = Enum.Font.SourceSansBold
    RefreshBtn.TextSize = 12
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

    local AutoBtn = Instance.new("TextButton", Group1)
    AutoBtn.Size = UDim2.new(0, 60, 0, 24)
    AutoBtn.Text = "⏱ Auto"
    AutoBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
    AutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
    AutoBtn.Font = Enum.Font.SourceSansBold
    AutoBtn.TextScaled = true
    Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 4)

    -- Khu 2: AI & Báo cáo
    local Group2 = Instance.new("Frame", CBar)
    Group2.Size = UDim2.new(0.35, 0, 1, 0)
    Group2.Position = UDim2.new(0.27, 0, 0, 0)
    Group2.BackgroundTransparency = 1

    local G2Layout = Instance.new("UIListLayout", Group2)
    G2Layout.FillDirection = Enum.FillDirection.Horizontal
    G2Layout.Padding = UDim.new(0, 4)
    G2Layout.VerticalAlignment = Enum.VerticalAlignment.Center

    local AIScanBtn = Instance.new("TextButton", Group2)
    AIScanBtn.Size = UDim2.new(0, 90, 0, 24)
    AIScanBtn.Text = "🧠 AI Phân tích"
    AIScanBtn.BackgroundColor3 = Color3.fromRGB(0,140,200)
    AIScanBtn.TextColor3 = Color3.fromRGB(255,255,255)
    AIScanBtn.Font = Enum.Font.SourceSansBold
    AIScanBtn.TextScaled = true
    Instance.new("UICorner", AIScanBtn).CornerRadius = UDim.new(0, 4)

    local CopyReportBtn = Instance.new("TextButton", Group2)
    CopyReportBtn.Size = UDim2.new(0, 80, 0, 24)
    CopyReportBtn.Text = "📋 Copy Report"
    CopyReportBtn.BackgroundColor3 = Color3.fromRGB(0,120,180)
    CopyReportBtn.TextColor3 = Color3.fromRGB(255,255,255)
    CopyReportBtn.Font = Enum.Font.SourceSansBold
    CopyReportBtn.TextScaled = true
    Instance.new("UICorner", CopyReportBtn).CornerRadius = UDim.new(0, 4)

    -- Khu 3: Tìm kiếm + trạng thái
    local Group3 = Instance.new("Frame", CBar)
    Group3.Size = UDim2.new(0.38, 0, 1, 0)
    Group3.Position = UDim2.new(0.63, 0, 0, 0)
    Group3.BackgroundTransparency = 1

    local G3Layout = Instance.new("UIListLayout", Group3)
    G3Layout.FillDirection = Enum.FillDirection.Horizontal
    G3Layout.Padding = UDim.new(0, 4)
    G3Layout.VerticalAlignment = Enum.VerticalAlignment.Center

    local SearchBox = Instance.new("TextBox", Group3)
    SearchBox.Size = UDim2.new(0.5, 0, 0, 24)
    SearchBox.PlaceholderText = "🔍 Lọc..."
    SearchBox.Text = ""
    SearchBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
    SearchBox.TextColor3 = Color3.fromRGB(255,255,255)
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.TextScaled = true
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

    local StatusLabel = Instance.new("TextLabel", Group3)
    StatusLabel.Size = UDim2.new(0.45, 0, 1, 0)
    StatusLabel.Text = "🟢 Sẵn sàng"
    StatusLabel.TextColor3 = Color3.fromRGB(150,255,150)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.TextScaled = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- ================================
    -- MINI FRAME (khi thu nhỏ)
    -- ================================
    local Mini = Instance.new("Frame", Gui)
    Mini.Size = UDim2.new(0, 200, 0, 32)
    Mini.Position = UDim2.new(0.5, -100, 0.05, 0)
    Mini.BackgroundColor3 = Color3.fromRGB(12,12,18)
    Mini.Active = true
    Mini.Draggable = true
    Mini.Visible = false
    Instance.new("UICorner", Mini).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", Mini).Color = Color3.fromRGB(0,255,200)

    local MiniTitle = Instance.new("TextLabel", Mini)
    MiniTitle.Size = UDim2.new(1, -40, 1, 0)
    MiniTitle.Position = UDim2.new(0, 4, 0, 0)
    MiniTitle.Text = "📊 DataScout Monitor"
    MiniTitle.TextColor3 = Color3.fromRGB(0,255,200)
    MiniTitle.BackgroundTransparency = 1
    MiniTitle.Font = Enum.Font.SourceSansBold
    MiniTitle.TextScaled = true
    MiniTitle.TextXAlignment = Enum.TextXAlignment.Left

    local ExpandBtn = Instance.new("TextButton", Mini)
    ExpandBtn.Size = UDim2.new(0, 24, 0, 22)
    ExpandBtn.Position = UDim2.new(1, -28, 0, 5)
    ExpandBtn.Text = "🗖"
    ExpandBtn.TextColor3 = Color3.fromRGB(0,255,200)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
    ExpandBtn.Font = Enum.Font.SourceSansBold
    ExpandBtn.TextSize = 12
    Instance.new("UICorner", ExpandBtn).CornerRadius = UDim.new(0, 4)

    -- ================================
    -- RENDER FUNCTIONS (cho từng tab)
    -- ================================
    local function renderValuesTab()
        local page = tabs["📊 Values"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local filter = string.lower(SearchBox.Text)
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 3)

        for path, val in pairs(S.values) do
            if filter == "" or string.find(string.lower(path), filter) then
                local fr = Instance.new("Frame", page)
                fr.Size = UDim2.new(1, -4, 0, 28)
                fr.BackgroundColor3 = Color3.fromRGB(18,18,24)
                Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 3)

                local lbl = Instance.new("TextLabel", fr)
                lbl.Size = UDim2.new(0.7, 0, 1, 0)
                lbl.Position = UDim2.new(0.02, 0, 0, 0)
                lbl.Text = string.format("%s = %.2f", path, val)
                lbl.TextColor3 = Color3.fromRGB(200,200,220)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.SourceSans
                lbl.TextScaled = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local copyBtn = Instance.new("TextButton", fr)
                copyBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
                copyBtn.Position = UDim2.new(0.84, 0, 0.15, 0)
                copyBtn.Text = "📋"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0,110,170)
                copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
                copyBtn.Font = Enum.Font.SourceSansBold
                copyBtn.TextScaled = true
                Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 3)
                copyBtn.MouseButton1Click:Connect(function() safeCopy(tostring(val)) end)
            end
        end
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    local function renderNPCTab()
        local page = tabs["👾 NPC"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 3)

        for model, info in pairs(S.npcs) do
            local fr = Instance.new("Frame", page)
            fr.Size = UDim2.new(1, -4, 0, 28)
            fr.BackgroundColor3 = Color3.fromRGB(18,18,24)
            Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 3)

            local lbl = Instance.new("TextLabel", fr)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0.02, 0, 0, 0)
            lbl.Text = string.format("👾 %s | HP: %d/%d | (%.1f,%.1f,%.1f)", info.name, info.health, info.maxHealth, info.pos.X, info.pos.Y, info.pos.Z)
            lbl.TextColor3 = Color3.fromRGB(255,200,100)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.SourceSans
            lbl.TextScaled = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    local function renderBlockTab()
        local page = tabs["🧱 Blocks"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 3)

        for obj, info in pairs(S.blocks) do
            local fr = Instance.new("Frame", page)
            fr.Size = UDim2.new(1, -4, 0, 28)
            fr.BackgroundColor3 = Color3.fromRGB(18,18,24)
            Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 3)

            local lbl = Instance.new("TextLabel", fr)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0.02, 0, 0, 0)
            local infoStr = info.isInvisible and " (Ẩn)" or ""
            lbl.Text = string.format("📦 %s%s | (%.1f,%.1f,%.1f)", obj.Name, infoStr, info.pos.X, info.pos.Y, info.pos.Z)
            lbl.TextColor3 = info.isInvisible and Color3.fromRGB(200,200,50) or Color3.fromRGB(200,220,200)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.SourceSans
            lbl.TextScaled = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    local function renderScriptsTab()
        local page = tabs["📜 Scripts"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 3)

        for _, entry in pairs(S.playerScripts) do
            local fr = Instance.new("Frame", page)
            fr.Size = UDim2.new(1, -4, 0, 24)
            fr.BackgroundColor3 = Color3.fromRGB(18,18,24)
            Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 3)

            local lbl = Instance.new("TextLabel", fr)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0.02, 0, 0, 0)
            lbl.Text = string.format("📜 %s (Player: %s)", entry.name, entry.player.DisplayName)
            lbl.TextColor3 = Color3.fromRGB(200,200,255)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.SourceSans
            lbl.TextScaled = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    local function renderLogTab()
        local page = tabs["📋 Log"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 3)

        for _, entry in ipairs(S.mapChangeLog) do
            local fr = Instance.new("Frame", page)
            fr.Size = UDim2.new(1, -4, 0, 22)
            fr.BackgroundColor3 = Color3.fromRGB(18,18,24)
            Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 3)

            local lbl = Instance.new("TextLabel", fr)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.Position = UDim2.new(0.02, 0, 0, 0)
            lbl.Text = string.format("[%s] %s", entry.time, entry.desc)
            lbl.TextColor3 = Color3.fromRGB(200,200,200)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.SourceSans
            lbl.TextScaled = true
            lbl.TextXAlignment = Enum.TextXAlignment.Left
        end
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    -- ================================
    -- REFRESH ALL
    -- ================================
    local function refreshAll()
        if not Main.Visible and not Mini.Visible then return end
        updateData()
        renderValuesTab()
        renderNPCTab()
        renderBlockTab()
        renderScriptsTab()
        renderLogTab()
        StatusLabel.Text = "✅ Cập nhật lúc " .. os.date("%H:%M:%S")
    end

    -- ================================
    -- EVENTS
    -- ================================
    local cleanup = {}
    table.insert(cleanup, CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end))

    -- Thu nhỏ / Mở rộng
    local function toggleMinify()
        S.minified = not S.minified
        Main.Visible = not S.minified
        Mini.Visible = S.minified
        if not S.minified then refreshAll() end
    end
    MiniBtn.MouseButton1Click:Connect(toggleMinify)
    ExpandBtn.MouseButton1Click:Connect(toggleMinify)

    table.insert(cleanup, RefreshBtn.MouseButton1Click:Connect(refreshAll))

    table.insert(cleanup, AutoBtn.MouseButton1Click:Connect(function()
        S.autoRefresh = not S.autoRefresh
        AutoBtn.Text = S.autoRefresh and "⏱ Auto" or "⏱ Off"
        AutoBtn.BackgroundColor3 = S.autoRefresh and Color3.fromRGB(0,140,70) or Color3.fromRGB(60,60,60)
    end))

    table.insert(cleanup, AIScanBtn.MouseButton1Click:Connect(function()
        if S.isAnalyzing then return end
        S.isAnalyzing = true
        AIScanBtn.Text = "⏳ Đang phân tích..."
        AIScanBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
        StatusLabel.Text = "🧠 AI đang suy nghĩ..."
        task.spawn(function()
            updateData()
            runAIAnalysis()
            renderValuesTab()
            renderNPCTab()
            renderBlockTab()
            renderScriptsTab()
            renderLogTab()
            AIScanBtn.Text = "🧠 AI Phân tích"
            AIScanBtn.BackgroundColor3 = Color3.fromRGB(0,140,200)
            StatusLabel.Text = "✅ Phân tích hoàn tất!"
            S.isAnalyzing = false
        end)
    end))

    table.insert(cleanup, CopyReportBtn.MouseButton1Click:Connect(function()
        if S.aiReport and S.aiReport ~= "" then
            safeCopy(S.aiReport)
            StatusLabel.Text = "📋 Đã copy báo cáo!"
        else
            StatusLabel.Text = "⚠️ Chưa có báo cáo"
        end
    end))

    SearchBox.Changed:Connect(function()
        S.filterText = SearchBox.Text
        if Main.Visible then renderValuesTab() end
    end)

    -- Auto refresh loop
    task.spawn(function()
        while task.wait(S.interval) do
            if S.autoRefresh and (Main.Visible or Mini.Visible) then
                refreshAll()
            end
        end
    end)

    -- Hotkey
    local hotkey = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            if S.minified then
                toggleMinify()
            else
                Main.Visible = not Main.Visible
                if Main.Visible then refreshAll() end
            end
        end
    end)
    table.insert(cleanup, hotkey)

    -- Cleanup
    local function cleanAll()
        for _, conn in pairs(cleanup) do safeCall(conn.Disconnect, conn) end
    end
    local this = coroutine.running()
    if this and this:IsA("BaseScript") then
        this.AncestryChanged:Connect(function()
            if not this.Parent then cleanAll() end
        end)
    else
        Gui.AncestryChanged:Connect(function()
            if not Gui.Parent then cleanAll() end
        end)
    end

    S.cleanup = cleanup

    -- Initial render
    refreshAll()
    return {Gui = Gui, Main = Main, Mini = Mini}
end

-- ============================================================================
-- INIT
-- ============================================================================
local function init()
    updateData()
    task.spawn(runAIAnalysis)
    buildUI()
    print("📊 DataScout Monitor v6.0 loaded. Right Control or '—' to toggle.")
end

safeCall(init)
return Tookit
-- ============================================================================
