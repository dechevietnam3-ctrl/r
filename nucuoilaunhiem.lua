--[[
    ═══════════════════════════════════════════════════════════════
    🔥 M.E.G.A HUB v2.0
    ═══════════════════════════════════════════════════════════════
    ✅ ESP phân biệt team đúng (auto re-detect khi đổi đội)
    ✅ Auto-avoid Infected
    ✅ Waypoints save/load per map
    ✅ Event log (Infect / Death / Kill)
    ✅ Discord webhook
    Toggle: Right Control
    ═══════════════════════════════════════════════════════════════
--]]

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local LocalPlayer       = Players.LocalPlayer

local RS = ReplicatedStorage:FindFirstChild("Ugc")
if not RS then warn("[M.E.G.A] Không tìm thấy ReplicatedStorage.Ugc — sai game?") end

-- ═══════════════ CONFIG ═══════════════
local CONFIG = {
    DISCORD_WEBHOOK = "", -- Điền URL webhook vào đây nếu muốn log ra Discord
    LOG_FILE = "mega_hub_log.txt",
    WAYPOINTS_FILE = "mega_hub_waypoints.json",
}

-- ═══════════════ CLIPBOARD ═══════════════
local function setClip(text)
    if type(setclipboard) == "function" then return pcall(setclipboard, text) end
    if type(toclipboard) == "function" then return pcall(toclipboard, text) end
    return false
end

-- ═══════════════ FILE I/O ═══════════════
local function writeFile(name, content)
    if type(writefile) == "function" then return pcall(writefile, name, content) end
    return false
end

local function readFile(name)
    if type(isfile) == "function" and type(readfile) == "function" then
        if isfile(name) then
            local ok, c = pcall(readfile, name)
            if ok then return c end
        end
    end
    return nil
end

local function appendFile(name, line)
    local existing = readFile(name) or ""
    return writeFile(name, existing .. line .. "\n")
end

-- ═══════════════ REFS ═══════════════
local function getMyFolder() return Workspace:FindFirstChild(LocalPlayer.Name) end
local function getMyStats() local f = getMyFolder(); return f and f:FindFirstChild("Stats") end

local function findRemote(path)
    if not RS then return nil end
    local p = path:gsub("^Ugc%.", "")
    local parts = {}
    for seg in p:gmatch("[^%.]+") do table.insert(parts, seg) end
    local cur = game
    for _, name in ipairs(parts) do
        if cur then cur = cur:FindFirstChild(name) else return nil end
    end
    return cur
end

-- ═══════════════ TEAM DETECTION (FIXED) ═══════════════
-- Cache để giảm lag khi check nhiều lần
local teamCache = {}
local teamCacheTime = 0
local TEAM_CACHE_TTL = 0.3

local function getPlayerInfected(plr)
    if plr == LocalPlayer then
        -- Với local, đọc từ stats của mình
        local stats = getMyStats()
        if stats then
            local inf = stats:FindFirstChild("Infected")
            if inf then return inf.Value == true end
        end
        return false
    end

    -- Cache check
    local now = tick()
    if now - teamCacheTime > TEAM_CACHE_TTL then
        teamCache = {}
        teamCacheTime = now
    end

    if teamCache[plr.UserId] ~= nil then
        return teamCache[plr.UserId]
    end

    -- Đọc trực tiếp từ Workspace.<username>.Stats.Infected
    local folder = Workspace:FindFirstChild(plr.Name)
    local stats = folder and folder:FindFirstChild("Stats")
    local inf = stats and stats:FindFirstChild("Infected")
    local isInfected = inf and inf.Value == true or false
    teamCache[plr.UserId] = isInfected
    return isInfected
end

-- ═══════════════ UI ═══════════════
local gui = Instance.new("ScreenGui")
gui.Name = "MegaHubV2"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if type(gethui) == "function" then
    local ok, h = pcall(gethui)
    if ok and h then gui.Parent = h else gui.Parent = CoreGui end
else
    gui.Parent = CoreGui
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 780, 0, 560)
main.Position = UDim2.new(0.5, -390, 0.5, -280)
main.BackgroundColor3 = Color3.fromRGB(10, 8, 14)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local ms = Instance.new("UIStroke", main)
ms.Color = Color3.fromRGB(255, 60, 100); ms.Thickness = 1.5

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = Color3.fromRGB(24, 14, 20)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Text = "🔥 M.E.G.A HUB v2.0"
title.TextColor3 = Color3.fromRGB(255, 90, 130)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 26, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 24, 30)
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 13
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- HUD
local hud = Instance.new("Frame", main)
hud.Size = UDim2.new(1, -20, 0, 78)
hud.Position = UDim2.new(0, 10, 0, 42)
hud.BackgroundColor3 = Color3.fromRGB(18, 12, 18)
hud.BorderSizePixel = 0
Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 8)

local hudText = Instance.new("TextLabel", hud)
hudText.Size = UDim2.new(1, -16, 1, -8)
hudText.Position = UDim2.new(0, 8, 0, 4)
hudText.BackgroundTransparency = 1
hudText.TextColor3 = Color3.fromRGB(230, 220, 230)
hudText.Font = Enum.Font.Code
hudText.TextSize = 11
hudText.TextXAlignment = Enum.TextXAlignment.Left
hudText.TextYAlignment = Enum.TextYAlignment.Top
hudText.Text = "Đang tải..."

-- Tabs
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, -20, 0, 28)
tabBar.Position = UDim2.new(0, 10, 0, 126)
tabBar.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -20, 1, -164)
content.Position = UDim2.new(0, 10, 0, 160)
content.BackgroundColor3 = Color3.fromRGB(8, 6, 10)
content.BorderSizePixel = 0
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

local pages, tabBtns = {}, {}

local function createTab(name, id, w)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0, w or 90, 1, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(26, 18, 24)
    btn.TextColor3 = Color3.fromRGB(160, 150, 160)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 10
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, -12, 1, -12)
    page.Position = UDim2.new(0, 6, 0, 6)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 4
    page.Visible = false
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 5)

    pages[id] = page
    tabBtns[id] = btn
    btn.MouseButton1Click:Connect(function()
        for i, p in pairs(pages) do
            p.Visible = (i == id)
            tabBtns[i].BackgroundColor3 = (i == id) and Color3.fromRGB(255, 80, 120) or Color3.fromRGB(26, 18, 24)
            tabBtns[i].TextColor3 = (i == id) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 150, 160)
        end
    end)
    return page
end

local PageInfo    = createTab("📊 Info", 1, 60)
local PageESP     = createTab("👁️ ESP", 2, 55)
local PageCombat  = createTab("⚔️ Combat", 3, 70)
local PageTP      = createTab("⚡ TP", 4, 50)
local PageAvoid   = createTab("🚫 Avoid", 5, 65)
local PageLog     = createTab("📜 Log", 6, 55)
local PageWp      = createTab("📍 WP", 7, 50)
local PageMisc    = createTab("🔧 Misc", 8, 55)

tabBtns[1].BackgroundColor3 = Color3.fromRGB(255, 80, 120)
tabBtns[1].TextColor3 = Color3.fromRGB(255, 255, 255)
pages[1].Visible = true

-- ═══════════════ UI HELPERS ═══════════════
local function mkBtn(parent, text, cb, color, width)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, width or 200, 0, 28)
    b.Text = text
    b.BackgroundColor3 = color or Color3.fromRGB(40, 26, 34)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function mkToggle(parent, text, state, cb, color)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 200, 0, 28)
    b.Text = text .. (state and ": ON" or ": OFF")
    b.BackgroundColor3 = state and (color or Color3.fromRGB(0, 140, 70)) or Color3.fromRGB(40, 40, 50)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text .. (state and ": ON" or ": OFF")
        b.BackgroundColor3 = state and (color or Color3.fromRGB(0, 140, 70)) or Color3.fromRGB(40, 40, 50)
        cb(state)
    end)
    return b
end

local function mkHeader(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -8, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255, 120, 160)
    l.Font = Enum.Font.SourceSansBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function mkLabel(parent, text, color)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -8, 0, 18)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(200, 200, 210)
    l.Font = Enum.Font.Code
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

-- ═══════════════ TAB 1: INFO ═══════════════
mkHeader(PageInfo, "📊 Player Stats")
local statsLabel = mkLabel(PageInfo, "...", Color3.fromRGB(220, 220, 230))
statsLabel.Size = UDim2.new(1, -8, 0, 130)
statsLabel.TextYAlignment = Enum.TextYAlignment.Top
statsLabel.TextWrapped = true

mkHeader(PageInfo, "🎭 Role của bạn")
local roleLabel = mkLabel(PageInfo, "...", Color3.fromRGB(255, 200, 100))
roleLabel.Size = UDim2.new(1, -8, 0, 80)
roleLabel.TextYAlignment = Enum.TextYAlignment.Top
roleLabel.TextWrapped = true

mkHeader(PageInfo, "👥 Trong server")
local serverLabel = mkLabel(PageInfo, "...", Color3.fromRGB(180, 220, 255))
serverLabel.Size = UDim2.new(1, -8, 0, 90)
serverLabel.TextYAlignment = Enum.TextYAlignment.Top
serverLabel.TextWrapped = true

-- ═══════════════ TAB 2: ESP (FIXED) ═══════════════
local espState = {
    infected = false,
    human = false,
    names = false,
    localOnly = false,
}

local espObjects = {}
local espConnections = {}

local function clearESP()
    for _, v in pairs(espObjects) do pcall(function() v:Destroy() end) end
    espObjects = {}
end

local function clearEspConnections()
    for _, c in ipairs(espConnections) do
        pcall(function() c:Disconnect() end)
    end
    espConnections = {}
end

local function addESPToCharacter(plr, isInfected)
    if not plr.Character then return end

    -- Skip self
    if plr == LocalPlayer and espState.localOnly then return end
    if plr == LocalPlayer and not espState.localOnly then
        -- Vẫn hiện self nếu muốn
    end

    -- Determine if we should show
    local shouldShow = false
    if isInfected and espState.infected then shouldShow = true end
    if not isInfected and espState.human then shouldShow = true end
    if not shouldShow then return end

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.Name = "MEGA_ESP"
    hl.FillColor = isInfected and Color3.fromRGB(255, 40, 60) or Color3.fromRGB(60, 200, 100)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0.2
    hl.Parent = plr.Character
    table.insert(espObjects, hl)

    -- Name tag
    if espState.names then
        local head = plr.Character:FindFirstChild("Head")
        if head then
            local bb = Instance.new("BillboardGui")
            bb.Name = "MEGA_Nametag"
            bb.Size = UDim2.new(0, 160, 0, 24)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.Adornee = head
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = (isInfected and "🧟 " or "🧑 ") .. plr.DisplayName
            lbl.TextColor3 = isInfected and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 150)
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextSize = 13
            lbl.TextStrokeTransparency = 0.3
            bb.Parent = plr.Character
            table.insert(espObjects, bb)
        end
    end
end

local function applyESP()
    clearESP()
    clearEspConnections()

    -- 1. ESP cho players hiện tại
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer or espState.localOnly ~= true then
            addESPToCharacter(plr, getPlayerInfected(plr))
        end
    end

    -- 2. Watch khi player đổi team (Stats.Infected thay đổi)
    for _, plr in ipairs(Players:GetPlayers()) do
        local folder = Workspace:FindFirstChild(plr.Name)
        if folder then
            local stats = folder:FindFirstChild("Stats")
            if stats then
                local inf = stats:FindFirstChild("Infected")
                if inf then
                    local conn = inf:GetPropertyChangedSignal("Value"):Connect(function()
                        -- Team changed → re-apply ESP toàn bộ (nhẹ nhưng chắc)
                        task.defer(function()
                            if espState.infected or espState.human then
                                applyESP()
                            end
                        end)
                    end)
                    table.insert(espConnections, conn)
                end
            end
        end
    end
end

mkHeader(PageESP, "👁️ ESP Teams (đã fix đổi đội)")

local infectedBtn, _ = mkToggle(PageESP, "🧟 ESP Infected", espState.infected,
    function(s) espState.infected = s; applyESP() end, Color3.fromRGB(200, 40, 60))

local humanBtn, _ = mkToggle(PageESP, "🧑 ESP Human", espState.human,
    function(s) espState.human = s; applyESP() end, Color3.fromRGB(40, 180, 80))

mkToggle(PageESP, "🏷️ Hiện tên", espState.names,
    function(s) espState.names = s; applyESP() end, Color3.fromRGB(100, 100, 180))

mkToggle(PageESP, "👤 Chỉ ESP mình", espState.localOnly,
    function(s) espState.localOnly = s; applyESP() end, Color3.fromRGB(150, 100, 60))

mkBtn(PageESP, "🔄 Re-scan Teams", function()
    teamCache = {}
    teamCacheTime = 0
    applyESP()
    print("[M.E.G.A] Đã re-scan teams")
end, Color3.fromRGB(80, 100, 160), 240)

mkBtn(PageESP, "❌ Tắt hết ESP", function()
    espState.infected = false
    espState.human = false
    espState.names = false
    -- Reset button visuals
    if infectedBtn then
        infectedBtn.Text = "🧟 ESP Infected: OFF"
        infectedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end
    if humanBtn then
        humanBtn.Text = "🧑 ESP Human: OFF"
        humanBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end
    clearESP()
    clearEspConnections()
end, Color3.fromRGB(100, 40, 40), 240)

mkHeader(PageESP, "🔍 Debug team")
local teamDebugLabel = mkLabel(PageESP, "Đang check...", Color3.fromRGB(180, 200, 220))
teamDebugLabel.Size = UDim2.new(1, -8, 0, 200)
teamDebugLabel.TextYAlignment = Enum.TextYAlignment.Top
teamDebugLabel.TextWrapped = true

task.spawn(function()
    while gui.Parent do
        local lines = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            local inf = getPlayerInfected(plr)
            local prefix = plr == LocalPlayer and "👈 " or "   "
            table.insert(lines, prefix .. plr.DisplayName .. " → " .. (inf and "🧟 INFECTED" or "🧑 HUMAN"))
        end
        teamDebugLabel.Text = table.concat(lines, "\n")
        task.wait(1)
    end
end)

-- ═══════════════ TAB 3: COMBAT ═══════════════
local aimState = { enabled = false, smoothness = 0.2, maxDist = 200 }

mkHeader(PageCombat, "🎯 Aim Assist")
mkLabel(PageCombat, "Chỉ quay camera — không tự bắn", Color3.fromRGB(255, 180, 80))
mkToggle(PageCombat, "🎯 Aim Infected", aimState.enabled, function(s) aimState.enabled = s end, Color3.fromRGB(220, 60, 60))

local distBox = Instance.new("TextBox", PageCombat)
distBox.Size = UDim2.new(0, 200, 0, 26)
distBox.Text = tostring(aimState.maxDist)
distBox.BackgroundColor3 = Color3.fromRGB(30, 20, 26)
distBox.TextColor3 = Color3.fromRGB(255, 255, 255)
distBox.Font = Enum.Font.SourceSans
distBox.TextSize = 12
distBox.PlaceholderText = "Khoảng cách tối đa"
Instance.new("UICorner", distBox).CornerRadius = UDim.new(0, 5)
distBox.FocusLost:Connect(function()
    local v = tonumber(distBox.Text)
    if v and v > 0 then aimState.maxDist = v end
end)

task.spawn(function()
    while gui.Parent do
        RunService.RenderStepped:Wait()
        if aimState.enabled then
            local cam = Workspace.CurrentCamera
            if cam then
                local best, bd
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and getPlayerInfected(plr) then
                        local head = plr.Character:FindFirstChild("Head")
                        if head then
                            local d = (head.Position - cam.CFrame.Position).Magnitude
                            if d <= aimState.maxDist and (not bd or d < bd) then
                                bd = d; best = head
                            end
                        end
                    end
                end
                if best then
                    local dir = (best.Position - cam.CFrame.Position).Unit
                    local targetCF = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + dir)
                    cam.CFrame = cam.CFrame:Lerp(targetCF, aimState.smoothness)
                end
            end
        end
    end
end)

-- ═══════════════ TAB 4: TP ═══════════════
mkHeader(PageTP, "⚡ Teleport")

mkBtn(PageTP, "📍 Về Spawn", function()
    local sp = Workspace:FindFirstChild("SpawnLocation")
    if not sp then
        local map = Workspace:FindFirstChild("Map")
        sp = map and (map:FindFirstChild("MapSpawn") or map:FindFirstChild("Spawn"))
    end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if sp and hrp then hrp.CFrame = CFrame.new(sp.Position + Vector3.new(0, 5, 0)) end
end, Color3.fromRGB(80, 120, 200), 240)

mkBtn(PageTP, "🧟 Đến Infected gần nhất", function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local best, bd
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and getPlayerInfected(plr) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if not bd or d < bd then bd = d; best = hrp end
            end
        end
    end
    if best then myHRP.CFrame = best.CFrame * CFrame.new(0, 3, 3) end
end, Color3.fromRGB(200, 60, 60), 240)

mkBtn(PageTP, "🧑 Đến Human gần nhất", function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local best, bd
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not getPlayerInfected(plr) then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if not bd or d < bd then bd = d; best = hrp end
            end
        end
    end
    if best then myHRP.CFrame = best.CFrame * CFrame.new(0, 3, 3) end
end, Color3.fromRGB(60, 180, 100), 240)

-- ═══════════════ TAB 5: AUTO-AVOID ═══════════════
local avoidState = {
    enabled = false,
    distance = 40,
    warnOnly = true, -- true = chỉ cảnh báo, false = đẩy nhân vật
    minDist = 15,
}

mkHeader(PageAvoid, "🚫 Auto-Avoid Infected")
mkLabel(PageAvoid, "Cảnh báo / đẩy nhân vật khi Infected lại gần", Color3.fromRGB(255, 180, 80))

mkToggle(PageAvoid, "🚫 Auto-Avoid", avoidState.enabled,
    function(s) avoidState.enabled = s end, Color3.fromRGB(200, 60, 60))

local avoidDistBox = Instance.new("TextBox", PageAvoid)
avoidDistBox.Size = UDim2.new(0, 200, 0, 26)
avoidDistBox.Text = tostring(avoidState.distance)
avoidDistBox.BackgroundColor3 = Color3.fromRGB(30, 20, 26)
avoidDistBox.TextColor3 = Color3.fromRGB(255, 255, 255)
avoidDistBox.PlaceholderText = "Khoảng cách cảnh báo"
avoidDistBox.Font = Enum.Font.SourceSans
avoidDistBox.TextSize = 12
Instance.new("UICorner", avoidDistBox).CornerRadius = UDim.new(0, 5)
avoidDistBox.FocusLost:Connect(function()
    local v = tonumber(avoidDistBox.Text)
    if v then avoidState.distance = v end
end)

mkToggle(PageAvoid, "👁️ Chỉ cảnh báo (không đẩy)", avoidState.warnOnly,
    function(s) avoidState.warnOnly = s end, Color3.fromRGB(100, 100, 180))

local avoidStatus = mkLabel(PageAvoid, "Chưa hoạt động", Color3.fromRGB(200, 220, 200))
avoidStatus.Size = UDim2.new(1, -8, 0, 30)

-- Avoid loop
local avoidWarningGui = Instance.new("ScreenGui")
avoidWarningGui.Name = "MegaAvoidWarning"
avoidWarningGui.ResetOnSpawn = false
avoidWarningGui.Enabled = false
if type(gethui) == "function" then
    local ok, h = pcall(gethui)
    if ok and h then avoidWarningGui.Parent = h else avoidWarningGui.Parent = CoreGui end
else
    avoidWarningGui.Parent = CoreGui
end

local warnFrame = Instance.new("TextLabel", avoidWarningGui)
warnFrame.Size = UDim2.new(1, 0, 0, 60)
warnFrame.Position = UDim2.new(0, 0, 0.4, 0)
warnFrame.BackgroundColor3 = Color3.fromRGB(255, 40, 60)
warnFrame.BackgroundTransparency = 0.4
warnFrame.Text = "⚠️ INFECTED ĐANG LẠI GẦN ⚠️"
warnFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
warnFrame.Font = Enum.Font.SourceSansBold
warnFrame.TextSize = 28
warnFrame.Visible = false

task.spawn(function()
    while gui.Parent do
        task.wait(0.2)
        if avoidState.enabled then
            local myChar = LocalPlayer.Character
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myHRP then
                local closest, closestDist
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and getPlayerInfected(plr) then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d = (hrp.Position - myHRP.Position).Magnitude
                            if not closestDist or d < closestDist then
                                closestDist = d
                                closest = hrp
                            end
                        end
                    end
                end

                if closest and closestDist and closestDist < avoidState.distance then
                    avoidWarningGui.Enabled = true
                    warnFrame.Visible = true
                    warnFrame.Text = string.format("⚠️ INFECTED GẦN: %dm ⚠️", math.floor(closestDist))
                    avoidStatus.Text = string.format("⚠️ Nguy hiểm: %d m", math.floor(closestDist))
                    avoidStatus.TextColor3 = Color3.fromRGB(255, 100, 100)

                    -- Push away if not warnOnly
                    if not avoidState.warnOnly and closestDist < avoidState.minDist then
                        local dir = (myHRP.Position - closest.Position).Unit
                        local bv = myChar:FindFirstChild("MEGA_AvoidPush")
                        if not bv then
                            bv = Instance.new("BodyVelocity")
                            bv.Name = "MEGA_AvoidPush"
                            bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                            bv.Velocity = Vector3.new(0, 0, 0)
                            bv.Parent = myHRP
                        end
                        bv.Velocity = dir * 40
                        task.delay(0.2, function()
                            if bv and bv.Parent then bv:Destroy() end
                        end)
                    end
                else
                    warnFrame.Visible = false
                    avoidWarningGui.Enabled = false
                    avoidStatus.Text = "✅ An toàn"
                    avoidStatus.TextColor3 = Color3.fromRGB(100, 255, 150)
                end
            end
        else
            warnFrame.Visible = false
            avoidWarningGui.Enabled = false
            avoidStatus.Text = "Chưa hoạt động"
        end
    end
end)

-- ═══════════════ TAB 6: EVENT LOG ═══════════════
local logState = { enabled = false, maxLines = 200 }
local eventLog = {}

mkHeader(PageLog, "📜 Event Log (Infect / Death / Kill)")

local logScroll = Instance.new("ScrollingFrame", PageLog)
logScroll.Size = UDim2.new(1, -8, 0, 200)
logScroll.BackgroundColor3 = Color3.fromRGB(6, 4, 8)
logScroll.BorderSizePixel = 0
logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logScroll.ScrollBarThickness = 4
Instance.new("UICorner", logScroll).CornerRadius = UDim.new(0, 5)
local logLayout = Instance.new("UIListLayout", logScroll)
logLayout.Padding = UDim.new(0, 2)

local function addLogLine(text, color)
    local l = Instance.new("TextLabel", logScroll)
    l.Size = UDim2.new(1, -6, 0, 16)
    l.BackgroundTransparency = 1
    l.Text = string.format("[%s] %s", os.date("%H:%M:%S"), text)
    l.TextColor3 = color or Color3.fromRGB(220, 220, 230)
    l.Font = Enum.Font.Code
    l.TextSize = 10
    l.TextXAlignment = Enum.TextXAlignment.Left
    table.insert(eventLog, l)
    if #eventLog > logState.maxLines then
        local old = table.remove(eventLog, 1)
        if old then old:Destroy() end
    end
    task.defer(function()
        logScroll.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 10)
    end)
end

local function sendWebhook(content)
    if CONFIG.DISCORD_WEBHOOK == "" then return end
    local ok, err = pcall(function()
        HttpService:PostAsync(CONFIG.DISCORD_WEBHOOK, HttpService:JSONEncode({
            content = content,
            username = "M.E.G.A HUB",
        }), Enum.HttpContentType.ApplicationJson)
    end)
    if not ok then warn("[M.E.G.A] Webhook fail: " .. tostring(err)) end
end

local function logEvent(text, color)
    addLogLine(text, color)
    if CONFIG.LOG_FILE then
        appendFile(CONFIG.LOG_FILE, string.format("[%s] %s", os.date("%Y-%m-%d %H:%M:%S"), text))
    end
    sendWebhook(text)
end

-- Watch Infected changes cho event log
local function watchPlayerEvents(plr)
    local folder = Workspace:FindFirstChild(plr.Name)
    if not folder then return end
    local stats = folder:FindFirstChild("Stats")
    if not stats then return end

    local inf = stats:FindFirstChild("Infected")
    if inf then
        inf:GetPropertyChangedSignal("Value"):Connect(function()
            if logState.enabled then
                if inf.Value then
                    logEvent("🧟 " .. plr.DisplayName .. " đã bị INFECT", Color3.fromRGB(255, 100, 100))
                else
                    logEvent("🧑 " .. plr.DisplayName .. " đã trở thành HUMAN", Color3.fromRGB(100, 255, 150))
                end
            end
        end)
    end

    local downed = stats:FindFirstChild("Downed")
    if downed then
        downed:GetPropertyChangedSignal("Value"):Connect(function()
            if logState.enabled and downed.Value then
                logEvent("💀 " .. plr.DisplayName .. " đã bị DOWNED", Color3.fromRGB(255, 180, 80))
            end
        end)
    end
end

mkToggle(PageLog, "📜 Bật Event Log", logState.enabled, function(s)
    logState.enabled = s
    if s then
        logEvent("📜 Log đã bật", Color3.fromRGB(100, 200, 255))
    end
end, Color3.fromRGB(60, 100, 160))

mkBtn(PageLog, "🧹 Xoá log", function()
    for _, l in ipairs(eventLog) do pcall(function() l:Destroy() end) end
    eventLog = {}
    logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end, Color3.fromRGB(80, 40, 40), 200)

mkBtn(PageLog, "📋 Copy log", function()
    local lines = {}
    for _, l in ipairs(eventLog) do
        table.insert(lines, l.Text)
    end
    setClip(table.concat(lines, "\n"))
end, Color3.fromRGB(60, 100, 160), 200)

mkHeader(PageLog, "🔔 Discord Webhook")
local webhookBox = Instance.new("TextBox", PageLog)
webhookBox.Size = UDim2.new(1, -8, 0, 26)
webhookBox.Text = CONFIG.DISCORD_WEBHOOK
webhookBox.PlaceholderText = "https://discord.com/api/webhooks/..."
webhookBox.BackgroundColor3 = Color3.fromRGB(30, 20, 26)
webhookBox.TextColor3 = Color3.fromRGB(255, 255, 255)
webhookBox.Font = Enum.Font.SourceSans
webhookBox.TextSize = 11
Instance.new("UICorner", webhookBox).CornerRadius = UDim.new(0, 5)
webhookBox.FocusLost:Connect(function()
    CONFIG.DISCORD_WEBHOOK = webhookBox.Text
end)

mkBtn(PageLog, "🧪 Test webhook", function()
    if CONFIG.DISCORD_WEBHOOK == "" then
        logEvent("❌ Chưa cấu hình webhook", Color3.fromRGB(255, 100, 100))
        return
    end
    sendWebhook("🧪 Test từ M.E.G.A HUB của " .. LocalPlayer.DisplayName)
    logEvent("✅ Đã gửi test webhook", Color3.fromRGB(100, 255, 150))
end, Color3.fromRGB(100, 60, 140), 200)

-- Hook existing + new players
for _, plr in ipairs(Players:GetPlayers()) do watchPlayerEvents(plr) end
Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    watchPlayerEvents(plr)
    if logState.enabled then
        logEvent("👋 " .. plr.DisplayName .. " đã vào server", Color3.fromRGB(100, 200, 255))
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    if logState.enabled then
        logEvent("👋 " .. plr.DisplayName .. " đã rời server", Color3.fromRGB(180, 180, 200))
    end
end)

-- ═══════════════ TAB 7: WAYPOINTS ═══════════════
local waypointState = { list = {}, currentMap = "" }

local function getCurrentMapName()
    local map = Workspace:FindFirstChild("Map")
    if map then
        -- Có thể có name hoặc 1 biến nào đó
        return map.Name
    end
    return "unknown"
end

local function saveWaypoints()
    local data = {
        map = getCurrentMapName(),
        list = waypointState.list,
    }
    local ok, json = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then
        -- Load existing
        local existing = readFile(CONFIG.WAYPOINTS_FILE) or "{}"
        local ok2, all = pcall(function() return HttpService:JSONDecode(existing) end)
        if not ok2 or type(all) ~= "table" then all = {} end
        all[getCurrentMapName()] = data
        writeFile(CONFIG.WAYPOINTS_FILE, HttpService:JSONEncode(all))
        return true
    end
    return false
end

local function loadWaypoints()
    local existing = readFile(CONFIG.WAYPOINTS_FILE)
    if not existing then return false end
    local ok, all = pcall(function() return HttpService:JSONDecode(existing) end)
    if not ok or type(all) ~= "table" then return false end
    local curMap = getCurrentMapName()
    local data = all[curMap]
    if data and data.list then
        waypointState.list = data.list
        return true
    end
    return false
end

mkHeader(PageWp, "📍 Waypoints (save/load per map)")

local wpLabel = mkLabel(PageWp, "Chưa có waypoint nào", Color3.fromRGB(200, 220, 240))
wpLabel.Size = UDim2.new(1, -8, 0, 200)
wpLabel.TextYAlignment = Enum.TextYAlignment.Top
wpLabel.TextWrapped = true

local function refreshWpLabel()
    if #waypointState.list == 0 then
        wpLabel.Text = "Chưa có waypoint nào.\nĐứng ở vị trí muốn lưu rồi bấm '💾 Lưu vị trí'."
    else
        local lines = {}
        for i, wp in ipairs(waypointState.list) do
            table.insert(lines, string.format("[%d] %s (%.1f, %.1f, %.1f)", i, wp.name, wp.x, wp.y, wp.z))
        end
        wpLabel.Text = table.concat(lines, "\n")
    end
end
refreshWpLabel()

mkBtn(PageWp, "💾 Lưu vị trí hiện tại", function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local name = "WP" .. (#waypointState.list + 1)
    table.insert(waypointState.list, {
        name = name,
        x = hrp.Position.X,
        y = hrp.Position.Y,
        z = hrp.Position.Z,
    })
    saveWaypoints()
    refreshWpLabel()
end, Color3.fromRGB(60, 140, 80), 240)

mkBtn(PageWp, "📂 Load waypoints của map này", function()
    local ok = loadWaypoints()
    refreshWpLabel()
    print(ok and "[M.E.G.A] Đã load WP" or "[M.E.G.A] Không có WP để load")
end, Color3.fromRGB(60, 100, 160), 240)

mkBtn(PageWp, "📋 Copy waypoints", function()
    local lines = {}
    for i, wp in ipairs(waypointState.list) do
        table.insert(lines, string.format("%d. %s = %.2f, %.2f, %.2f", i, wp.name, wp.x, wp.y, wp.z))
    end
    setClip(table.concat(lines, "\n"))
end, Color3.fromRGB(100, 80, 160), 240)

mkBtn(PageWp, "🧹 Xoá tất cả WP", function()
    waypointState.list = {}
    saveWaypoints()
    refreshWpLabel()
end, Color3.fromRGB(120, 40, 40), 240)

-- Quick TP buttons cho từng WP
task.spawn(function()
    while gui.Parent do
        task.wait(2)
        -- Cleanup old WP buttons, add new ones
        for _, c in ipairs(PageWp:GetChildren()) do
            if c:IsA("TextButton") and c.Name == "WP_TP_BTN" then c:Destroy() end
        end
        for i, wp in ipairs(waypointState.list) do
            local b = Instance.new("TextButton", PageWp)
            b.Name = "WP_TP_BTN"
            b.Size = UDim2.new(0, 100, 0, 24)
            b.Text = "📍 TP " .. wp.name
            b.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.SourceSansBold
            b.TextSize = 10
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = CFrame.new(wp.x, wp.y + 3, wp.z)
                end
            end)
        end
    end
end)

-- ═══════════════ TAB 8: MISC ═══════════════
local miscState = { speedEnabled = false, jumpEnabled = false, speedVal = 30, jumpVal = 80 }

mkHeader(PageMisc, "🏃 Movement (nhẹ để không flag)")
mkToggle(PageMisc, "⚡ Speed Boost", miscState.speedEnabled, function(s) miscState.speedEnabled = s end, Color3.fromRGB(200, 100, 40))

local speedBox = Instance.new("TextBox", PageMisc)
speedBox.Size = UDim2.new(0, 200, 0, 26)
speedBox.Text = "30"
speedBox.BackgroundColor3 = Color3.fromRGB(30, 20, 26)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderText = "WalkSpeed (16 default — đừng quá 50)"
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 12
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 5)
speedBox.FocusLost:Connect(function()
    local v = tonumber(speedBox.Text)
    if v then miscState.speedVal = v end
end)

mkToggle(PageMisc, "🦘 Jump Boost", miscState.jumpEnabled, function(s) miscState.jumpEnabled = s end, Color3.fromRGB(80, 120, 200))

task.spawn(function()
    while gui.Parent do
        task.wait(0.3)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            if miscState.speedEnabled and hum.WalkSpeed ~= miscState.speedVal then
                hum.WalkSpeed = miscState.speedVal
            end
            if miscState.jumpEnabled then
                pcall(function() hum.UseJumpPower = true end)
                if hum.JumpPower ~= miscState.jumpVal then
                    hum.JumpPower = miscState.jumpVal
                end
            end
        end
    end
end)

mkHeader(PageMisc, "🛠️ Util")
mkBtn(PageMisc, "📋 Copy toàn bộ Settings", function()
    local f = getMyFolder()
    local settings = f and f:FindFirstChild("Settings")
    if not settings then return end
    local out = {}
    for _, v in ipairs(settings:GetChildren()) do
        if v:IsA("ValueBase") then out[v.Name] = tostring(v.Value) end
    end
    local ok, json = pcall(function() return HttpService:JSONEncode(out) end)
    if ok then setClip(json) end
end, Color3.fromRGB(100, 80, 160), 240)

mkBtn(PageMisc, "📋 Copy Marketplace inventory", function()
    local mk = LocalPlayer:FindFirstChild("Marketplace")
    if not mk then return end
    local out = {}
    for _, cat in ipairs(mk:GetChildren()) do
        out[cat.Name] = {}
        for _, item in ipairs(cat:GetChildren()) do
            if item:IsA("StringValue") and item.Name == "Equipped" and item.Value ~= "" then
                out[cat.Name].Equipped = item.Value
            end
        end
    end
    local ok, json = pcall(function() return HttpService:JSONEncode(out) end)
    if ok then setClip(json) end
end, Color3.fromRGB(80, 100, 160), 240)

mkBtn(PageMisc, "📋 Copy remote paths", function()
    if not RS then return end
    local list = {}
    for _, d in ipairs(RS:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") then
            table.insert(list, d:GetFullName() .. "  (" .. d.ClassName .. ")")
        end
    end
    setClip(table.concat(list, "\n"))
    print("[M.E.G.A] Copied " .. #list .. " remotes")
end, Color3.fromRGB(80, 120, 160), 240)

mkBtn(PageMisc, "🔄 Server Hop", function()
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end)
end, Color3.fromRGB(150, 60, 60), 240)

-- ═══════════════ HUD LOOP ═══════════════
task.spawn(function()
    while gui.Parent do
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local stats = getMyStats()
        local lines = {}

        if stats then
            local function v(n) local o = stats:FindFirstChild(n) return o and tostring(o.Value) or "?" end
            lines[#lines+1] = string.format("👤 %s | Lv %s | Exp %s | SmileCoins %s",
                LocalPlayer.DisplayName, v("Level"), v("Exp"), v("SmileCoins"))
            lines[#lines+1] = string.format("🎯 K:%s I:%s | 🎭 %s",
                v("TotalKills"), v("TotalInfects"),
                (stats:FindFirstChild("Infected") and stats.Infected.Value) and "🧟 INFECTED" or "🧑 HUMAN")
        end
        if hum then
            lines[#lines+1] = string.format("⚡ HP:%d/%d Spd:%d",
                math.floor(hum.Health), math.floor(hum.MaxHealth), math.floor(hum.WalkSpeed))
        end
        hudText.Text = table.concat(lines, "\n")

        -- Stats tab
        if stats then
            local function v(n) local o = stats:FindFirstChild(n) return o and tostring(o.Value) or "?" end
            statsLabel.Text = string.format(
                "Level: %s | Exp: %s | SmileCoins: %s\nKills: %s | Infects: %s | ElimWins: %s\nPlaytime: %ss | NormalSpeed: %s",
                v("Level"), v("Exp"), v("SmileCoins"), v("TotalKills"), v("TotalInfects"),
                v("TotalEliminationWins"), v("Playtime"), v("NormalSpeed"))

            local inf = stats:FindFirstChild("Infected")
            local dn = stats:FindFirstChild("Downed")
            local rg = stats:FindFirstChild("Ragdoll")
            roleLabel.Text = string.format(
                "Infected: %s\nDowned: %s\nRagdoll: %s",
                inf and tostring(inf.Value) or "?",
                dn and tostring(dn.Value) or "?",
                rg and tostring(rg.Value) or "?")
        end

        -- Server info
        local ic, hc = 0, 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if getPlayerInfected(plr) then ic = ic + 1 else hc = hc + 1 end
            end
        end
        serverLabel.Text = string.format(
            "Players: %d | 🧟 %d | 🧑 %d\nPlace: %d",
            #Players:GetPlayers(), ic, hc, game.PlaceId)

        task.wait(0.8)
    end
end)

-- ═══════════════ HOTKEY ═══════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

print("[M.E.G.A HUB v2.0] Loaded — Right Control để toggle.")
