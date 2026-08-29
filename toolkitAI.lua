-- ============================================================================
-- DataScout AI v5.3 – Smart Data Analyst (tookit)
-- Responsive cho PC và mobile. Giao diện nhỏ gọn, dễ thao tác.
-- Chức năng giữ nguyên. Phím tắt: Right Control (hoặc nút toggle trên UI)
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
-- STATE (giữ nguyên)
-- ============================================================================
Tookit.State = {
    history = {},
    current = {},
    previous = {},
    cacheValid = false,
    autoRefresh = true,
    interval = 2,
    filterText = "",
    aiReport = "",
    lastAnalysis = "",
    maxHistory = 30,
    isAnalyzing = false,
    cleanup = {},
}

-- ============================================================================
-- UTILITY (giữ nguyên)
-- ============================================================================
local function safeCopy(text)
    local ok, _ = pcall(function()
        if setclipboard then setclipboard(text) return true end
        return false
    end)
    return ok
end

local function safeCall(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then warn("[DataScoutAI] " .. tostring(result)) end
    return ok and result
end

local function tableCount(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

-- ============================================================================
-- DATA COLLECTOR (giữ nguyên)
-- ============================================================================
local function getContainers()
    return {
        Workspace, Players, RS, SS, Lighting, CoreGui,
        game:GetService("StarterGui"), game:GetService("StarterPack"),
        game:GetService("StarterPlayer"), game:GetService("ScriptContext"),
    }
end

local function collectAllValues()
    local result = {}
    local seen = {}
    for _, container in pairs(getContainers()) do
        if container then
            for _, obj in pairs(container:GetDescendants()) do
                if obj:IsA("ValueBase") then
                    local path = obj:GetFullName()
                    if not seen[path] then
                        seen[path] = true
                        local val = obj.Value
                        if type(val) ~= "table" and type(val) ~= "userdata" then
                            result[path] = {
                                instance = obj,
                                value = val,
                                className = obj.ClassName,
                                name = obj.Name,
                            }
                        end
                    end
                end
            end
        end
    end
    return result
end

local function updateData()
    local newRaw = collectAllValues()
    local newCurrent = {}
    for path, data in pairs(newRaw) do
        newCurrent[path] = data.value
    end

    local S = Tookit.State
    local oldCurrent = S.current

    for path, val in pairs(newCurrent) do
        if not S.history[path] then
            S.history[path] = { values = {}, times = {} }
        end
        local hist = S.history[path]
        if #hist.values == 0 or hist.values[#hist.values] ~= val then
            table.insert(hist.values, val)
            table.insert(hist.times, os.time())
            if #hist.values > S.maxHistory then
                table.remove(hist.values, 1)
                table.remove(hist.times, 1)
            end
        end
    end

    S.previous = oldCurrent
    S.current = newCurrent
    S.cacheValid = true
end

-- ============================================================================
-- AI ENGINE (giữ nguyên)
-- ============================================================================
local function calculateMean(t)
    local sum = 0
    for _, v in pairs(t) do sum = sum + v end
    return #t > 0 and sum / #t or 0
end

local function calculateStdDev(t, mean)
    if #t < 2 then return 0 end
    local sqSum = 0
    for _, v in pairs(t) do sqSum = sqSum + (v - mean)^2 end
    return math.sqrt(sqSum / (#t - 1))
end

local function linearPredict(hist, steps)
    local n = #hist
    if n < 2 then return nil end
    local xSum, ySum, xySum, x2Sum = 0, 0, 0, 0
    for i = 1, n do
        local x = i
        local y = hist[i]
        xSum = xSum + x
        ySum = ySum + y
        xySum = xySum + x * y
        x2Sum = x2Sum + x * x
    end
    local denominator = n * x2Sum - xSum * xSum
    if denominator == 0 then return nil end
    local slope = (n * xySum - xSum * ySum) / denominator
    local intercept = (ySum - slope * xSum) / n
    return slope * (n + steps) + intercept
end

local function runAIAnalysis()
    local S = Tookit.State
    local report = {}
    local insights = {}
    local warnings = {}
    local predictions = {}
    local suggestions = {}

    local current = S.current
    local history = S.history

    local numValues = tableCount(current)
    local changedCount = 0
    local increased = {}
    local decreased = {}

    for path, val in pairs(current) do
        local old = S.previous[path]
        if old ~= nil and old ~= val then
            changedCount = changedCount + 1
            if val > old then
                table.insert(increased, {path = path, diff = val - old, pct = (val - old) / math.abs(old) * 100})
            else
                table.insert(decreased, {path = path, diff = old - val, pct = (old - val) / math.abs(old) * 100})
            end
        end
    end

    table.insert(report, string.format("📊 Tổng số giá trị: %d", numValues))
    table.insert(report, string.format("🔄 Thay đổi gần nhất: %d giá trị", changedCount))

    -- Anomaly detection
    for path, hist in pairs(history) do
        local vals = hist.values
        if #vals >= 5 then
            local mean = calculateMean(vals)
            local std = calculateStdDev(vals, mean)
            local latest = vals[#vals]
            if std > 0 and math.abs(latest - mean) > 2.5 * std then
                local direction = latest > mean and "tăng" or "giảm"
                table.insert(warnings, string.format(
                    "⚠️ Bất thường tại `%s`: %s đột biến (%.1f → %.1f, độ lệch %.2fσ)",
                    path, direction, mean, latest, math.abs(latest - mean) / std
                ))
            end
        end
    end

    -- Trend
    for path, hist in pairs(history) do
        local vals = hist.values
        if #vals >= 5 then
            local recent = {}
            for i = #vals - 4, #vals do table.insert(recent, vals[i]) end
            local isIncreasing = true
            local isDecreasing = true
            for i = 2, #recent do
                if recent[i] <= recent[i-1] then isIncreasing = false end
                if recent[i] >= recent[i-1] then isDecreasing = false end
            end
            if isIncreasing then
                local pct = (recent[#recent] - recent[1]) / math.abs(recent[1]) * 100
                if pct > 10 then
                    table.insert(insights, string.format(
                        "📈 `%s` tăng liên tục (%.1f%%), hiện tại: %.2f",
                        path, pct, recent[#recent]
                    ))
                    local pred = linearPredict(vals, 3)
                    if pred then
                        table.insert(predictions, string.format(
                            "🔮 `%s` dự kiến sau 3 lần cập nhật: %.2f (từ %.2f)",
                            path, pred, recent[#recent]
                        ))
                    end
                end
            elseif isDecreasing then
                local pct = (recent[1] - recent[#recent]) / math.abs(recent[1]) * 100
                if pct > 10 then
                    table.insert(warnings, string.format(
                        "📉 `%s` giảm liên tục (%.1f%%), hiện tại: %.2f",
                        path, pct, recent[#recent]
                    ))
                end
            end
        end
    end

    -- Suggestions
    if #increased > 0 then
        table.sort(increased, function(a, b) return a.pct > b.pct end)
        local top = increased[1]
        if top then
            table.insert(suggestions, string.format(
                "💡 Giá trị `%s` đang tăng mạnh nhất (%.1f%%). Hãy kiểm tra nguyên nhân!",
                top.path, top.pct
            ))
        end
    end
    if #decreased > 0 then
        table.sort(decreased, function(a, b) return a.pct > b.pct end)
        local top = decreased[1]
        if top then
            table.insert(suggestions, string.format(
                "💡 Giá trị `%s` đang giảm mạnh nhất (%.1f%%). Có thể cần can thiệp!",
                top.path, top.pct
            ))
        end
    end

    local finalReport = {}
    table.insert(finalReport, "🤖 BÁO CÁO PHÂN TÍCH DỮ LIỆU (AI)")
    table.insert(finalReport, "==========================================")
    for _, line in ipairs(report) do table.insert(finalReport, line) end
    table.insert(finalReport, "")
    if #insights > 0 then
        table.insert(finalReport, "🔍 INSIGHTS:")
        for _, line in ipairs(insights) do table.insert(finalReport, line) end
    end
    if #warnings > 0 then
        table.insert(finalReport, "")
        table.insert(finalReport, "⚠️ CẢNH BÁO:")
        for _, line in ipairs(warnings) do table.insert(finalReport, line) end
    end
    if #predictions > 0 then
        table.insert(finalReport, "")
        table.insert(finalReport, "🔮 DỰ ĐOÁN:")
        for _, line in ipairs(predictions) do table.insert(finalReport, line) end
    end
    if #suggestions > 0 then
        table.insert(finalReport, "")
        table.insert(finalReport, "💡 ĐỀ XUẤT:")
        for _, line in ipairs(suggestions) do table.insert(finalReport, line) end
    end
    if #warnings == 0 and #insights == 0 and #suggestions == 0 then
        table.insert(finalReport, "✅ Hệ thống ổn định. Không phát hiện bất thường đáng kể.")
    end

    S.aiReport = table.concat(finalReport, "\n")
    S.lastAnalysis = os.date("%H:%M:%S")
    S.isAnalyzing = false
end

-- ============================================================================
-- UI BUILDER – RESPONSIVE (nâng cấp)
-- ============================================================================
local function buildUI()
    local S = Tookit.State
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "DataScoutAI"
    Gui.ResetOnSpawn = false

    local ok, _ = pcall(function()
        if gethui then
            Gui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(Gui)
            Gui.Parent = CoreGui
        else
            Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    if not ok then Gui.Parent = CoreGui end

    -- Main Frame – kích thước theo tỉ lệ màn hình
    local Main = Instance.new("Frame", Gui)
    Main.Size = UDim2.new(0.85, 0, 0.8, 0)  -- 85% ngang, 80% dọc
    Main.Position = UDim2.new(0.075, 0, 0.1, 0)  -- căn giữa
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    Main.Active = true
    Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.Thickness = 1.5

    -- Title + nút thu nhỏ
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundTransparency = 1

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Size = UDim2.new(0.8, 0, 1, 0)
    Title.Position = UDim2.new(0.02, 0, 0, 0)
    Title.Text = "🧠 DataScout AI v5.3 (tookit)"
    Title.TextColor3 = Color3.fromRGB(0, 255, 200)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.SourceSansBold
    Title.TextScaled = true
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Nút thu nhỏ (mini)
    local MiniBtn = Instance.new("TextButton", TitleBar)
    MiniBtn.Size = UDim2.new(0, 28, 0, 24)
    MiniBtn.Position = UDim2.new(1, -70, 0, 4)
    MiniBtn.Text = "—"
    MiniBtn.TextColor3 = Color3.fromRGB(255, 200, 50)
    MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    MiniBtn.Font = Enum.Font.SourceSansBold
    MiniBtn.TextSize = 14
    Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 4)

    -- Nút đóng
    local CloseBtn = Instance.new("TextButton", TitleBar)
    CloseBtn.Size = UDim2.new(0, 28, 0, 24)
    CloseBtn.Position = UDim2.new(1, -36, 0, 4)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    CloseBtn.Font = Enum.Font.SourceSansBold
    CloseBtn.TextSize = 14
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    -- Tab Bar
    local TabBar = Instance.new("Frame", Main)
    TabBar.Size = UDim2.new(1, -8, 0, 30)
    TabBar.Position = UDim2.new(0, 4, 0, 34)
    TabBar.BackgroundTransparency = 1

    local tabs = {}
    local tabNames = {"📊 Dữ liệu", "🤖 Báo cáo AI", "📜 Lịch sử"}
    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0.32, -2, 1, 0)  -- chia đều 3 tab
        btn.Position = UDim2.new(0.33*(i-1)+0.005, 0, 0, 0)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        btn.TextColor3 = Color3.fromRGB(150, 150, 160)
        btn.Font = Enum.Font.SourceSansBold
        btn.TextScaled = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local page = Instance.new("ScrollingFrame", Main)
        page.Size = UDim2.new(1, -12, 1, -72)
        page.Position = UDim2.new(0, 6, 0, 68)
        page.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollBarThickness = 4
        page.Visible = false
        Instance.new("UICorner", page).CornerRadius = UDim.new(0, 6)

        tabs[name] = { btn = btn, page = page }
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
                t.btn.TextColor3 = Color3.fromRGB(150, 150, 160)
            end
            page.Visible = true
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
    tabs["📊 Dữ liệu"].btn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    tabs["📊 Dữ liệu"].btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabs["📊 Dữ liệu"].page.Visible = true

    -- Control Bar (các nút bên trái, thu nhỏ)
    local CBar = Instance.new("Frame", Main)
    CBar.Size = UDim2.new(1, -8, 0, 32)
    CBar.Position = UDim2.new(0, 4, 0, 34)
    CBar.BackgroundTransparency = 1

    -- Nhóm nút bên trái
    local LeftGroup = Instance.new("Frame", CBar)
    LeftGroup.Size = UDim2.new(0.75, 0, 1, 0)
    LeftGroup.BackgroundTransparency = 1

    local LeftLayout = Instance.new("UIListLayout", LeftGroup)
    LeftLayout.FillDirection = Enum.FillDirection.Horizontal
    LeftLayout.Padding = UDim.new(0, 4)
    LeftLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- Ô tìm kiếm
    local SearchBox = Instance.new("TextBox", LeftGroup)
    SearchBox.Size = UDim2.new(0, 80, 0, 24)
    SearchBox.PlaceholderText = "🔍 Lọc..."
    SearchBox.Text = ""
    SearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.TextScaled = true
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

    -- Nút Refresh
    local RefreshBtn = Instance.new("TextButton", LeftGroup)
    RefreshBtn.Size = UDim2.new(0, 28, 0, 24)
    RefreshBtn.Text = "🔄"
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.Font = Enum.Font.SourceSansBold
    RefreshBtn.TextSize = 12
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

    -- Nút Auto
    local AutoBtn = Instance.new("TextButton", LeftGroup)
    AutoBtn.Size = UDim2.new(0, 60, 0, 24)
    AutoBtn.Text = "⏱ Auto: ON"
    AutoBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
    AutoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoBtn.Font = Enum.Font.SourceSansBold
    AutoBtn.TextScaled = true
    Instance.new("UICorner", AutoBtn).CornerRadius = UDim.new(0, 4)

    -- Nút AI Phân tích
    local AIScanBtn = Instance.new("TextButton", LeftGroup)
    AIScanBtn.Size = UDim2.new(0, 90, 0, 24)
    AIScanBtn.Text = "🧠 AI Phân tích"
    AIScanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    AIScanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AIScanBtn.Font = Enum.Font.SourceSansBold
    AIScanBtn.TextScaled = true
    Instance.new("UICorner", AIScanBtn).CornerRadius = UDim.new(0, 4)

    -- Nút Copy Report
    local CopyReportBtn = Instance.new("TextButton", LeftGroup)
    CopyReportBtn.Size = UDim2.new(0, 80, 0, 24)
    CopyReportBtn.Text = "📋 Copy Report"
    CopyReportBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    CopyReportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyReportBtn.Font = Enum.Font.SourceSansBold
    CopyReportBtn.TextScaled = true
    Instance.new("UICorner", CopyReportBtn).CornerRadius = UDim.new(0, 4)

    -- Status Label (bên phải)
    local StatusLabel = Instance.new("TextLabel", CBar)
    StatusLabel.Size = UDim2.new(0.24, 0, 1, 0)
    StatusLabel.Position = UDim2.new(0.76, 0, 0, 0)
    StatusLabel.Text = "🟢 Sẵn sàng"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.SourceSans
    StatusLabel.TextScaled = true
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Center

    -- ============================================================
    -- CONTENT FUNCTIONS (giữ nguyên logic)
    -- ============================================================
    local function renderDataTab()
        local page = tabs["📊 Dữ liệu"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local filter = string.lower(SearchBox.Text)
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 3)

        for path, val in pairs(S.current) do
            if filter == "" or string.find(string.lower(path), filter) then
                local hist = S.history[path]
                local avg = hist and calculateMean(hist.values) or val
                local fr = Instance.new("Frame", page)
                fr.Size = UDim2.new(1, -4, 0, 30)
                fr.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
                Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 3)

                local lbl = Instance.new("TextLabel", fr)
                lbl.Size = UDim2.new(0.5, 0, 0.6, 0)
                lbl.Position = UDim2.new(0.02, 0, 0.05, 0)
                lbl.Text = string.format("%s = %.2f", path, val)
                lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.SourceSans
                lbl.TextScaled = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left

                local stat = Instance.new("TextLabel", fr)
                stat.Size = UDim2.new(0.3, 0, 0.4, 0)
                stat.Position = UDim2.new(0.02, 0, 0.55, 0)
                stat.Text = string.format("TB: %.2f | Mẫu: %d", avg, hist and #hist.values or 0)
                stat.TextColor3 = Color3.fromRGB(150, 150, 180)
                stat.BackgroundTransparency = 1
                stat.Font = Enum.Font.SourceSans
                stat.TextScaled = true
                stat.TextXAlignment = Enum.TextXAlignment.Left

                local copyBtn = Instance.new("TextButton", fr)
                copyBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
                copyBtn.Position = UDim2.new(0.84, 0, 0.15, 0)
                copyBtn.Text = "📋"
                copyBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
                copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                copyBtn.Font = Enum.Font.SourceSansBold
                copyBtn.TextScaled = true
                Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 3)
                copyBtn.MouseButton1Click:Connect(function() safeCopy(tostring(val)) end)
            end
        end
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    local function renderAIReport()
        local page = tabs["🤖 Báo cáo AI"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end

        local header = Instance.new("TextLabel", page)
        header.Size = UDim2.new(1, 0, 0, 24)
        header.Text = "🧠 PHÂN TÍCH TRÍ TUỆ NHÂN TẠO (AI)"
        header.TextColor3 = Color3.fromRGB(0, 255, 200)
        header.BackgroundTransparency = 1
        header.Font = Enum.Font.SourceSansBold
        header.TextScaled = true

        local timeLabel = Instance.new("TextLabel", page)
        timeLabel.Size = UDim2.new(1, 0, 0, 18)
        timeLabel.Position = UDim2.new(0, 0, 0, 26)
        timeLabel.Text = "Cập nhật lần cuối: " .. S.lastAnalysis
        timeLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
        timeLabel.BackgroundTransparency = 1
        timeLabel.Font = Enum.Font.SourceSans
        timeLabel.TextScaled = true

        local reportBox = Instance.new("TextLabel", page)
        reportBox.Size = UDim2.new(1, -8, 1, -50)
        reportBox.Position = UDim2.new(0, 4, 0, 46)
        reportBox.Text = S.aiReport or "Chưa có dữ liệu. Nhấn '🧠 AI Phân tích' để bắt đầu."
        reportBox.TextColor3 = Color3.fromRGB(220, 220, 235)
        reportBox.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        reportBox.BackgroundTransparency = 0
        reportBox.Font = Enum.Font.SourceSans
        reportBox.TextScaled = true
        reportBox.TextXAlignment = Enum.TextXAlignment.Left
        reportBox.TextYAlignment = Enum.TextYAlignment.Top
        reportBox.TextWrapped = true
        reportBox.AutomaticSize = Enum.AutomaticSize.Y
        Instance.new("UICorner", reportBox).CornerRadius = UDim.new(0, 6)

        page.CanvasSize = UDim2.new(0, 0, 0, reportBox.AbsoluteSize.Y + 60)
    end

    local function renderLogs()
        local page = tabs["📜 Lịch sử"].page
        for _, c in pairs(page:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 3)

        local logs = {}
        for path, hist in pairs(S.history) do
            local vals = hist.values
            if #vals >= 2 then
                local last = vals[#vals]
                local prev = vals[#vals-1]
                if last ~= prev then
                    table.insert(logs, {path = path, old = prev, new = last, time = hist.times[#vals]})
                end
            end
        end
        table.sort(logs, function(a, b) return (a.time or 0) > (b.time or 0) end)

        if #logs == 0 then
            local empty = Instance.new("TextLabel", page)
            empty.Size = UDim2.new(1, 0, 0, 24)
            empty.Text = "Chưa có thay đổi nào được ghi nhận."
            empty.TextColor3 = Color3.fromRGB(150, 150, 150)
            empty.BackgroundTransparency = 1
            empty.Font = Enum.Font.SourceSansItalic
            empty.TextScaled = true
        else
            for i = 1, math.min(200, #logs) do
                local entry = logs[i]
                local fr = Instance.new("Frame", page)
                fr.Size = UDim2.new(1, -4, 0, 24)
                fr.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
                Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 3)
                local lbl = Instance.new("TextLabel", fr)
                lbl.Size = UDim2.new(0.85, 0, 1, 0)
                lbl.Position = UDim2.new(0.02, 0, 0, 0)
                lbl.Text = string.format("%.1f → %.1f : %s", entry.old, entry.new, entry.path)
                lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.SourceSans
                lbl.TextScaled = true
                lbl.TextXAlignment = Enum.TextXAlignment.Left
            end
        end
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    end

    local function refreshAll()
        if not Main.Visible then return end
        updateData()
        renderDataTab()
        renderLogs()
        if S.aiReport ~= "" then renderAIReport() end
        StatusLabel.Text = "✅ Cập nhật lúc " .. os.date("%H:%M:%S")
    end

    -- ============================================================
    -- EVENTS
    -- ============================================================
    local cleanup = {}
    table.insert(cleanup, CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end))
    table.insert(cleanup, MiniBtn.MouseButton1Click:Connect(function()
        Main.Visible = not Main.Visible
    end))

    table.insert(cleanup, RefreshBtn.MouseButton1Click:Connect(refreshAll))

    table.insert(cleanup, AutoBtn.MouseButton1Click:Connect(function()
        S.autoRefresh = not S.autoRefresh
        AutoBtn.Text = S.autoRefresh and "⏱ Auto: ON" or "⏱ Auto: OFF"
        AutoBtn.BackgroundColor3 = S.autoRefresh and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(60, 60, 60)
    end))

    table.insert(cleanup, AIScanBtn.MouseButton1Click:Connect(function()
        if S.isAnalyzing then return end
        S.isAnalyzing = true
        AIScanBtn.Text = "⏳ Đang phân tích..."
        AIScanBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        StatusLabel.Text = "🧠 AI đang suy nghĩ..."
        task.spawn(function()
            updateData()
            runAIAnalysis()
            renderAIReport()
            AIScanBtn.Text = "🧠 AI Phân tích"
            AIScanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
            StatusLabel.Text = "✅ Phân tích hoàn tất!"
            S.isAnalyzing = false
        end)
    end))

    table.insert(cleanup, CopyReportBtn.MouseButton1Click:Connect(function()
        if S.aiReport and S.aiReport ~= "" then
            safeCopy(S.aiReport)
            StatusLabel.Text = "📋 Đã copy báo cáo!"
        else
            StatusLabel.Text = "⚠️ Chưa có báo cáo để copy"
        end
    end))

    SearchBox.Changed:Connect(function()
        S.filterText = SearchBox.Text
        if Main.Visible then renderDataTab() end
    end)

    -- Auto refresh loop
    task.spawn(function()
        while task.wait(S.interval) do
            if S.autoRefresh and Main.Visible then
                refreshAll()
            end
        end
    end)

    -- Hotkey
    local hotkey = UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
            Main.Visible = not Main.Visible
            if Main.Visible then refreshAll() end
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

    return {
        Gui = Gui,
        Main = Main,
        Refresh = refreshAll,
        RenderAI = renderAIReport,
        RenderData = renderDataTab,
    }
end

-- ============================================================================
-- INIT
-- ============================================================================
local function init()
    updateData()
    task.spawn(runAIAnalysis)
    local ui = buildUI()
    task.wait(0.5)
    ui.RenderAI()
    ui.RenderData()
    print("🧠 DataScout AI v5.3 loaded. Press Right Control or tap '—' to toggle.")
end

safeCall(init)
return Tookit
-- ============================================================================
