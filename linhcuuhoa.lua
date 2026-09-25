--[[
    ═══════════════════════════════════════════════════════════════
    🔥 FIREFIGHTER HUB v2.0 — EXTENDED
    Thêm: Aim Assist, Pathfinding, Auto Donate, Script Reader
    ═══════════════════════════════════════════════════════════════
    ⚠️ CẢNH BÁO:
    - Aim assist + auto-fire = hành vi đáng ngờ với anti-cheat
    - Donation spam = có thể bị kick khỏi server
    - Pathfinding là client-side visual, không tự di chuyển nhân vật
    - CHỈ DÙNG Ở MỨC VỪA PHẢI
    Toggle: Right Control
    ═══════════════════════════════════════════════════════════════
--]]

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local PathfindingService= game:GetService("PathfindingService")
local HttpService       = game:GetService("HttpService")
local LocalPlayer       = Players.LocalPlayer

local RS = ReplicatedStorage:FindFirstChild("Ugc")
local GameValues   = RS and RS:FindFirstChild("GameValues")
local ServerEvents = RS and RS:FindFirstChild("ServerEvents")
local ClientEvents = RS and RS:FindFirstChild("ClientEvents")
local MapsInfo     = RS and RS:FindFirstChild("MapsInfo")

local function getPlayerDataFolder()
    return Workspace:FindFirstChild(LocalPlayer.Name)
end

local function setClip(text)
    if type(setclipboard) == "function" then return pcall(setclipboard, text) end
    if type(toclipboard) == "function" then return pcall(toclipboard, text) end
    return false
end

-- ═══════════════ UI ═══════════════
local gui = Instance.new("ScreenGui")
gui.Name = "FirefighterHubV2"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if type(gethui) == "function" then
    local ok, h = pcall(gethui)
    if ok and h then gui.Parent = h else gui.Parent = CoreGui end
else
    gui.Parent = CoreGui
end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 720, 0, 540)
main.Position = UDim2.new(0.5, -360, 0.5, -270)
main.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local mstroke = Instance.new("UIStroke", main)
mstroke.Color = Color3.fromRGB(255, 90, 50)
mstroke.Thickness = 1.5

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = Color3.fromRGB(24, 20, 24)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Text = "🔥 FIREFIGHTER HUB v2.0 — EXTENDED"
title.TextColor3 = Color3.fromRGB(255, 130, 80)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 26, 0, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 5)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
closeBtn.TextColor3 = Color3.fromRGB(255, 90, 90)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 13
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- HUD
local hud = Instance.new("Frame", main)
hud.Size = UDim2.new(1, -20, 0, 64)
hud.Position = UDim2.new(0, 10, 0, 42)
hud.BackgroundColor3 = Color3.fromRGB(20, 18, 22)
hud.BorderSizePixel = 0
Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 8)

local hudText = Instance.new("TextLabel", hud)
hudText.Size = UDim2.new(1, -16, 1, -8)
hudText.Position = UDim2.new(0, 8, 0, 4)
hudText.BackgroundTransparency = 1
hudText.TextColor3 = Color3.fromRGB(220, 220, 230)
hudText.Font = Enum.Font.Code
hudText.TextSize = 11
hudText.TextXAlignment = Enum.TextXAlignment.Left
hudText.TextYAlignment = Enum.TextYAlignment.Top
hudText.Text = "Đang tải..."

-- Tabs
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1, -20, 0, 28)
tabBar.Position = UDim2.new(0, 10, 0, 112)
tabBar.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -20, 1, -152)
content.Position = UDim2.new(0, 10, 0, 146)
content.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
content.BorderSizePixel = 0
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 8)

local pages, tabBtns = {}, {}

local function createTab(name, id, width)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0, width or 100, 1, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(28, 26, 32)
    btn.TextColor3 = Color3.fromRGB(150, 150, 160)
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
            tabBtns[i].BackgroundColor3 = (i == id) and Color3.fromRGB(255, 100, 50) or Color3.fromRGB(28, 26, 32)
            tabBtns[i].TextColor3 = (i == id) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
        end
    end)
    return page
end

local PageInfo    = createTab("📊 Info", 1, 80)
local PageTP      = createTab("⚡ TP", 2, 60)
local PageESP     = createTab("👁️ ESP", 3, 60)
local PageCombat  = createTab("🎯 Combat", 4, 80)
local PageNav     = createTab("🧭 Navigate", 5, 90)
local PageAuto    = createTab("🤖 Auto", 6, 70)
local PageRead    = createTab("📜 Reader", 7, 80)
local PageUtil    = createTab("🔧 Util", 8, 60)

tabBtns[1].BackgroundColor3 = Color3.fromRGB(255, 100, 50)
tabBtns[1].TextColor3 = Color3.fromRGB(255, 255, 255)
pages[1].Visible = true

-- ═══════════════ HELPERS ═══════════════
local function mkBtn(parent, text, cb, color, width)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, width or 200, 0, 30)
    b.Text = text
    b.BackgroundColor3 = color or Color3.fromRGB(40, 40, 55)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(cb)
    return b
end

local function mkToggle(parent, text, state, cb, color)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0, 200, 0, 30)
    b.Text = text .. (state and ": ON" or ": OFF")
    b.BackgroundColor3 = state and (color or Color3.fromRGB(0, 140, 70)) or Color3.fromRGB(50, 50, 50)
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text .. (state and ": ON" or ": OFF")
        b.BackgroundColor3 = state and (color or Color3.fromRGB(0, 140, 70)) or Color3.fromRGB(50, 50, 50)
        cb(state)
    end)
    return b, function() return state end
end

local function mkLabel(parent, text, color)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -8, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(200, 200, 210)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function mkHeader(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, -8, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255, 130, 80)
    l.Font = Enum.Font.SourceSansBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

-- ═══════════════ TAB INFO ═══════════════
mkHeader(PageInfo, "📊 Trạng thái Game")
local gameInfoLabel = mkLabel(PageInfo, "...", Color3.fromRGB(220, 220, 230))
gameInfoLabel.Size = UDim2.new(1, -8, 0, 90)
gameInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
gameInfoLabel.TextWrapped = true

mkHeader(PageInfo, "👤 Dữ liệu bản thân")
local playerInfoLabel = mkLabel(PageInfo, "...", Color3.fromRGB(220, 220, 230))
playerInfoLabel.Size = UDim2.new(1, -8, 0, 100)
playerInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
playerInfoLabel.TextWrapped = true

-- ═══════════════ TAB TP ═══════════════
mkHeader(PageTP, "📍 Teleport nhanh")
mkBtn(PageTP, "🏠 Về Fire Station", function()
    local fs = Workspace:FindFirstChild("Fire Station")
    local sp = fs and fs:FindFirstChild("Spawn")
    if sp and sp:IsA("BasePart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = sp.CFrame * CFrame.new(0, 3, 0) end
    end
end, Color3.fromRGB(200, 100, 40))

mkBtn(PageTP, "🔥 Đến Fire hiện tại", function()
    local pdata = getPlayerDataFolder()
    local cf = pdata and pdata:FindFirstChild("CurrentFire")
    if cf and cf.Value and cf.Value:IsA("BasePart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = cf.Value.CFrame * CFrame.new(0, 5, 0) end
    end
end, Color3.fromRGB(220, 60, 40))

mkBtn(PageTP, "🧑 Đến Citizen gần nhất", function()
    local map = Workspace:FindFirstChild("Map")
    local citizens = map and map:FindFirstChild("Citizens")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (citizens and myHRP) then return end
    local nearest, nd
    for _, c in ipairs(citizens:GetChildren()) do
        if c:IsA("Model") then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if not nd or d < nd then nd = d; nearest = hrp end
            end
        end
    end
    if nearest then myHRP.CFrame = nearest.CFrame * CFrame.new(0, 3, 3) end
end, Color3.fromRGB(60, 180, 100))

mkBtn(PageTP, "🚁 Đến Helicopter", function()
    local heli = Workspace:FindFirstChild("Helicopter")
    if heli then
        local hrp = heli:FindFirstChild("HumanoidRootPart") or heli.PrimaryPart
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and myHRP then myHRP.CFrame = hrp.CFrame * CFrame.new(0, 5, 0) end
    end
end, Color3.fromRGB(80, 120, 200))

mkBtn(PageTP, "🚒 Đến Firetruck gần nhất", function()
    local rt = Workspace:FindFirstChild("RoundTemp")
    local ft = rt and rt:FindFirstChild("Firetruck")
    if ft then
        local hrp = ft:FindFirstChild("HumanoidRootPart") or ft.PrimaryPart
        if not hrp then
            for _, p in ipairs(ft:GetDescendants()) do
                if p:IsA("BasePart") and p.Name:lower():find("chassis") then hrp = p break end
            end
        end
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and myHRP then myHRP.CFrame = hrp.CFrame * CFrame.new(0, 5, 0) end
    end
end, Color3.fromRGB(200, 60, 60))

-- ═══════════════ TAB ESP ═══════════════
local espState = { fires = false, citizens = false, players = false, names = false }
local espObjects = {}

local function clearESP()
    for _, v in pairs(espObjects) do pcall(function() v:Destroy() end) end
    espObjects = {}
end

local function applyESP()
    clearESP()
    if espState.fires then
        local map = Workspace:FindFirstChild("Map")
        local fires = map and map:FindFirstChild("Fires")
        if fires then
            for _, f in ipairs(fires:GetChildren()) do
                if f:IsA("Model") or f:IsA("BasePart") then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 60, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 200, 100)
                    hl.FillTransparency = 0.5
                    hl.Parent = f
                    table.insert(espObjects, hl)
                    if espState.names then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 100, 0, 20)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = f:IsA("BasePart") and f or (f.PrimaryPart or f:FindFirstChildWhichIsA("BasePart"))
                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = "🔥 " .. f.Name
                        lbl.TextColor3 = Color3.fromRGB(255, 150, 50)
                        lbl.Font = Enum.Font.SourceSansBold
                        lbl.TextSize = 12
                        lbl.TextStrokeTransparency = 0.3
                        bb.Parent = f
                        table.insert(espObjects, bb)
                    end
                end
            end
        end
    end
    if espState.citizens then
        local map = Workspace:FindFirstChild("Map")
        local citizens = map and map:FindFirstChild("Citizens")
        if citizens then
            for _, c in ipairs(citizens:GetChildren()) do
                if c:IsA("Model") and c:FindFirstChildOfClass("Humanoid") then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(0, 255, 100)
                    hl.OutlineColor = Color3.fromRGB(200, 255, 200)
                    hl.FillTransparency = 0.5
                    hl.Parent = c
                    table.insert(espObjects, hl)
                    if espState.names then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.new(0, 120, 0, 20)
                        bb.StudsOffset = Vector3.new(0, 3, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee = c:FindFirstChild("Head") or c.PrimaryPart
                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = "🧑 " .. c.Name
                        lbl.TextColor3 = Color3.fromRGB(100, 255, 150)
                        lbl.Font = Enum.Font.SourceSansBold
                        lbl.TextSize = 12
                        lbl.TextStrokeTransparency = 0.3
                        bb.Parent = c
                        table.insert(espObjects, bb)
                    end
                end
            end
        end
    end
    if espState.players then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(100, 150, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.55
                hl.Parent = plr.Character
                table.insert(espObjects, hl)
            end
        end
    end
end

mkHeader(PageESP, "👁️ ESP đối tượng")
mkToggle(PageESP, "🔥 ESP Fires", espState.fires, function(s) espState.fires = s; applyESP() end, Color3.fromRGB(200, 60, 40))
mkToggle(PageESP, "🧑 ESP Citizens", espState.citizens, function(s) espState.citizens = s; applyESP() end, Color3.fromRGB(40, 180, 80))
mkToggle(PageESP, "👥 ESP Players", espState.players, function(s) espState.players = s; applyESP() end, Color3.fromRGB(60, 120, 220))
mkToggle(PageESP, "🏷️ Hiện tên", espState.names, function(s) espState.names = s; applyESP() end, Color3.fromRGB(100, 100, 160))
mkBtn(PageESP, "🔄 Refresh ESP", applyESP, Color3.fromRGB(80, 80, 100))
mkBtn(PageESP, "❌ Tắt hết ESP", function()
    espState = { fires = false, citizens = false, players = false, names = false }
    clearESP()
    -- Reset buttons nếu cần
end, Color3.fromRGB(100, 40, 40))

-- ═══════════════ TAB COMBAT (AIM ASSIST) ═══════════════
local aimState = { enabled = false, smoothness = 0.15, maxDist = 150 }
local aimTarget = nil

mkHeader(PageCombat, "🎯 Aim Assist — hướng camera về fire gần nhất")
mkLabel(PageCombat, "⚠️ Chỉ quay camera, KHÔNG tự bấm chuột.", Color3.fromRGB(255, 180, 80))

mkToggle(PageCombat, "🎯 Aim Assist", aimState.enabled, function(s)
    aimState.enabled = s
end, Color3.fromRGB(220, 60, 40))

mkHeader(PageCombat, "📏 Khoảng cách tối đa")
local distBox = Instance.new("TextBox", PageCombat)
distBox.Size = UDim2.new(0, 200, 0, 28)
distBox.Text = tostring(aimState.maxDist)
distBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
distBox.TextColor3 = Color3.fromRGB(255, 255, 255)
distBox.Font = Enum.Font.SourceSans
distBox.TextSize = 12
Instance.new("UICorner", distBox).CornerRadius = UDim.new(0, 5)
distBox.FocusLost:Connect(function()
    local v = tonumber(distBox.Text)
    if v and v > 0 then aimState.maxDist = v end
end)

mkBtn(PageCombat, "🔫 Scan fire gần nhất", function()
    local map = Workspace:FindFirstChild("Map")
    local fires = map and map:FindFirstChild("Fires")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (fires and myHRP) then return end
    local nearest, nd
    for _, f in ipairs(fires:GetChildren()) do
        local fp = f:IsA("BasePart") and f.Position or (f.PrimaryPart and f.PrimaryPart.Position)
        if fp then
            local d = (fp - myHRP.Position).Magnitude
            if d <= aimState.maxDist and (not nd or d < nd) then nd = d; nearest = f end
        end
    end
    if nearest then
        print("[FF Hub] Fire gần nhất:", nearest.Name, "| Dist:", math.floor(nd or 0))
        aimTarget = nearest
    else
        print("[FF Hub] Không tìm thấy fire trong tầm.")
    end
end, Color3.fromRGB(180, 100, 40))

mkBtn(PageCombat, "🧑 Scan citizen gần nhất", function()
    local map = Workspace:FindFirstChild("Map")
    local citizens = map and map:FindFirstChild("Citizens")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (citizens and myHRP) then return end
    local nearest, nd
    for _, c in ipairs(citizens:GetChildren()) do
        if c:IsA("Model") then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if d <= aimState.maxDist and (not nd or d < nd) then nd = d; nearest = c end
            end
        end
    end
    if nearest then
        print("[FF Hub] Citizen gần nhất:", nearest.Name, "| Dist:", math.floor(nd or 0))
        aimTarget = nearest
    else
        print("[FF Hub] Không tìm thấy citizen trong tầm.")
    end
end, Color3.fromRGB(60, 180, 100))

-- Aim loop
task.spawn(function()
    while gui.Parent do
        if aimState.enabled then
            local cam = Workspace.CurrentCamera
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if cam and myHRP then
                -- Tìm target mỗi frame nếu chưa có
                local map = Workspace:FindFirstChild("Map")
                local fires = map and map:FindFirstChild("Fires")
                if fires then
                    local nearest, nd
                    for _, f in ipairs(fires:GetChildren()) do
                        local fp = f:IsA("BasePart") and f.Position or (f.PrimaryPart and f.PrimaryPart.Position)
                        if fp then
                            local d = (fp - myHRP.Position).Magnitude
                            if d <= aimState.maxDist and (not nd or d < nd) then nd = d; nearest = fp end
                        end
                    end
                    if nearest then
                        local dir = (nearest - cam.CFrame.Position).Unit
                        local targetCF = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + dir)
                        cam.CFrame = cam.CFrame:Lerp(targetCF, aimState.smoothness)
                    end
                end
            end
        end
        RunService.RenderStepped:Wait()
    end
end)

-- ═══════════════ TAB NAVIGATE (PATHFINDING) ═══════════════
local navState = { active = false, target = nil, path = nil, waypoints = {}, currentIdx = 1 }

mkHeader(PageNav, "🧭 Pathfinding tới Citizen")
mkLabel(PageNav, "Hiển thị đường đi trực quan. Không tự di chuyển.", Color3.fromRGB(255, 180, 80))

mkBtn(PageNav, "🧭 Tìm đường tới Citizen gần nhất", function()
    local map = Workspace:FindFirstChild("Map")
    local citizens = map and map:FindFirstChild("Citizens")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (citizens and myHRP) then return end

    local nearest, nd
    for _, c in ipairs(citizens:GetChildren()) do
        if c:IsA("Model") then
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - myHRP.Position).Magnitude
                if not nd or d < nd then nd = d; nearest = hrp end
            end
        end
    end
    if not nearest then return end

    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
    })
    local ok = pcall(function()
        path:ComputeAsync(myHRP.Position, nearest.Position)
    end)
    if not ok or path.Status ~= Enum.PathStatus.Success then
        warn("[FF Hub] Không tìm được đường đi.")
        return
    end

    -- Xóa path cũ
    for _, wp in ipairs(navState.waypoints) do
        if wp.obj then pcall(function() wp.obj:Destroy() end) end
    end
    navState.waypoints = {}
    navState.target = nearest

    local waypoints = path:GetWaypoints()
    for i, wp in ipairs(waypoints) do
        local p = Instance.new("Part")
        p.Shape = Enum.PartType.Ball
        p.Size = Vector3.new(1.2, 1.2, 1.2)
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(100, 200, 255)
        p.Anchored = true
        p.CanCollide = false
        p.Position = wp.Position + Vector3.new(0, 1, 0)
        p.Parent = Workspace
        table.insert(navState.waypoints, {position = wp.Position, obj = p, action = wp.Action})
    end
    print("[FF Hub] Path có", #waypoints, "waypoints. Dist:", math.floor(nd))
end, Color3.fromRGB(60, 120, 200))

mkBtn(PageNav, "❌ Xóa path", function()
    for _, wp in ipairs(navState.waypoints) do
        if wp.obj then pcall(function() wp.obj:Destroy() end) end
    end
    navState.waypoints = {}
    navState.target = nil
end, Color3.fromRGB(100, 40, 40))

mkToggle(PageNav, "🎯 Hiện target indicator", false, function(s)
    -- Bật/tắt highlight target
end, Color3.fromRGB(100, 60, 180))

-- ═══════════════ TAB AUTO (DONATION + PROMPTS) ═══════════════
local autoState = {
    donateActive = false,
    promptActive = false,
    donateAmounts = {25, 100, 500, 1000, 5000, 10000},
    donateDelay = 1.0,
    promptDelay = 0.5,
}

mkHeader(PageAuto, "🤖 Auto Donation Board")
mkLabel(PageAuto, "⚠️ Spam donate có thể bị flag. Chỉ dùng khi đứng gần board.", Color3.fromRGB(255, 180, 80))

mkToggle(PageAuto, "💰 Auto Donate", autoState.donateActive, function(s)
    autoState.donateActive = s
end, Color3.fromRGB(180, 140, 40))

local donateAmtBox = Instance.new("TextBox", PageAuto)
donateAmtBox.Size = UDim2.new(0, 200, 0, 28)
donateAmtBox.Text = "100"
donateAmtBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
donateAmtBox.TextColor3 = Color3.fromRGB(255, 255, 255)
donateAmtBox.Font = Enum.Font.SourceSans
donateAmtBox.TextSize = 12
donateAmtBox.PlaceholderText = "Số tiền donate"
Instance.new("UICorner", donateAmtBox).CornerRadius = UDim.new(0, 5)

mkHeader(PageAuto, "🎯 Auto ProximityPrompt")
mkLabel(PageAuto, "Tự động kích hoạt prompt gần đó (vd: Save Citizen)")

mkToggle(PageAuto, "🎯 Auto Prompt", autoState.promptActive, function(s)
    autoState.promptActive = s
end, Color3.fromRGB(120, 60, 180))

mkHeader(PageAuto, "🔥 Auto Extinguish (thử remote)")
mkLabel(PageAuto, "⚠️ Remote này cần server validate. Có thể không hiệu quả.", Color3.fromRGB(255, 120, 120))

mkBtn(PageAuto, "🧪 Test — Kích hoạt prompt gần nhất 1 lần", function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local nearest, nd
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            local parent = p.Parent
            if parent and parent:IsA("BasePart") then
                local d = (parent.Position - myHRP.Position).Magnitude
                if d <= 15 and (not nd or d < nd) then nd = d; nearest = p end
            end
        end
    end
    if nearest then
        if type(fireproximityprompt) == "function" then
            pcall(fireproximityprompt, nearest)
            print("[FF Hub] Fired prompt:", nearest.Parent.Name)
        else
            print("[FF Hub] Executor không có fireproximityprompt.")
        end
    else
        print("[FF Hub] Không tìm thấy prompt gần đó.")
    end
end, Color3.fromRGB(100, 180, 80))

-- Auto loops
task.spawn(function()
    while gui.Parent do
        task.wait(0.5)
        -- Auto donate
        if autoState.donateActive then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local fs = Workspace:FindFirstChild("Fire Station")
            local board = fs and fs:FindFirstChild("DonationBoard")
            if board and myHRP then
                local amount = tonumber(donateAmtBox.Text) or 100
                local btn = board:FindFirstChild("DonateButton" .. amount)
                if btn then
                    -- ProximityPrompt bên trong
                    local prompt = btn:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt and type(fireproximityprompt) == "function" then
                        pcall(fireproximityprompt, prompt)
                    end
                end
            end
        end

        -- Auto prompt
        if autoState.promptActive then
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHRP then
                for _, p in ipairs(Workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and p.Enabled then
                        local parent = p.Parent
                        if parent and parent:IsA("BasePart") then
                            local d = (parent.Position - myHRP.Position).Magnitude
                            if d <= 10 and type(fireproximityprompt) == "function" then
                                pcall(fireproximityprompt, p)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ═══════════════ TAB READER (SCRIPT READER) ═══════════════
local readerState = { selected = nil }

local function getSourceSafely(scr)
    if not scr or not scr:IsA("LuaSourceContainer") then return nil, "unavailable" end
    if type(decompile) == "function" then
        local ok, code = pcall(decompile, scr)
        if ok and type(code) == "string" and #code > 0 then return code, "decompile" end
    end
    local ok2, src = pcall(function() return scr.Source end)
    if ok2 and type(src) == "string" and #src > 0 then return src, "source" end
    return nil, "unavailable"
end

mkHeader(PageReader, "📜 Đọc source các script client-side")
mkLabel(PageReader, "Chỉ đọc được LocalScript/ModuleScript client. Script server-side không đọc được.", Color3.fromRGB(255, 180, 80))

local readerOutput = Instance.new("TextLabel", PageReader)
readerOutput.Size = UDim2.new(1, -8, 0, 120)
readerOutput.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
readerOutput.TextColor3 = Color3.fromRGB(200, 255, 200)
readerOutput.Font = Enum.Font.Code
readerOutput.TextSize = 10
readerOutput.TextXAlignment = Enum.TextXAlignment.Left
readerOutput.TextYAlignment = Enum.TextYAlignment.Top
readerOutput.TextWrapped = true
readerOutput.Text = "Chưa có script nào được chọn."
Instance.new("UICorner", readerOutput).CornerRadius = UDim.new(0, 5)

-- Danh sách script quan trọng từ báo cáo
local importantScripts = {
    { path = "Ugc.Workspace.Map.MapScripts.FiresScript.FireSpreadScript", desc = "Cơ chế lan lửa" },
    { path = "Ugc.Workspace.Map.MapScripts.FiresScript.FireSpreadScript.DamageScript", desc = "Damage khi đứng gần lửa" },
    { path = "Ugc.Workspace.Map.MapScripts.FiresScript.BurningScript", desc = "Cơ chế cháy" },
    { path = "Ugc.Workspace.Map.MapScripts.CleanTrucks", desc = "Logic dọn xe" },
    { path = "Ugc.Workspace.Helicopter.FireScript", desc = "Script bắn nước từ trực thăng" },
    { path = "Ugc.Workspace.RoundTemp.Firetruck.Scripts.Vehicle", desc = "Logic xe cứu hỏa" },
    { path = "Ugc.Workspace.RoundTemp.Firetruck.Scripts.Chassis", desc = "Chassis xe" },
    { path = "Ugc.Players.<you>.PlayerGui.FirefightersGui.Extinguisher.LocalScript", desc = "Logic bình chữa cháy" },
    { path = "Ugc.Players.<you>.PlayerGui.FirefightersGui.Sprint.LocalScript", desc = "Logic sprint" },
    { path = "Ugc.Players.<you>.PlayerGui.FirefightersGui.HealButton.LocalScript", desc = "Logic hồi máu" },
    { path = "Ugc.Players.<you>.PlayerGui.Main.Frame.MapChoose.LocalScript", desc = "Logic chọn map" },
    { path = "Ugc.Players.<you>.PlayerGui.FireHealth", desc = "Hiển thị máu lửa" },
    { path = "Ugc.Players.<you>.PlayerGui.FriendsCharacters", desc = "Hiển thị bạn bè" },
}

-- Hàm resolve path (thay <you> bằng LocalPlayer.Name)
local function resolvePath(pathStr)
    pathStr = pathStr:gsub("<you>", LocalPlayer.Name)
    local parts = {}
    for p in pathStr:gmatch("[^%.]+") do table.insert(parts, p) end
    local current = game
    for _, name in ipairs(parts) do
        if current then
            current = current:FindFirstChild(name)
        else return nil end
    end
    return current
end

mkHeader(PageReader, "📋 Danh sách script quan trọng")
for _, entry in ipairs(importantScripts) do
    local btn = mkBtn(PageReader, "📜 " .. entry.desc, function()
        local obj = resolvePath(entry.path)
        if not obj then
            readerOutput.Text = "❌ Không tìm thấy: " .. entry.path
            return
        end
        local code, kind = getSourceSafely(obj)
        if code then
            readerOutput.Text = "✅ " .. entry.desc .. " (" .. kind .. ")\n" ..
                "Path: " .. entry.path .. "\n\n" ..
                code:sub(1, 400) .. (#code > 400 and "\n...(còn nữa)" or "")
            readerState.selected = code
        else
            readerOutput.Text = "⚠️ Không đọc được source (script server-side hoặc obfuscated):\n" .. entry.path
        end
    end, Color3.fromRGB(80, 100, 140), 300)
end

mkBtn(PageReader, "📋 Copy nội dung đang xem", function()
    if readerState.selected then
        setClip(readerState.selected)
    end
end, Color3.fromRGB(60, 120, 180), 300)

mkBtn(PageReader, "🔍 Liệt kê tất cả LocalScript trong PlayerGui", function()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end
    local list = {}
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("LocalScript") or d:IsA("ModuleScript") then
            table.insert(list, d:GetFullName())
        end
    end
    setClip(table.concat(list, "\n"))
    readerOutput.Text = "Đã copy " .. #list .. " script vào clipboard."
end, Color3.fromRGB(100, 80, 140), 300)

-- ═══════════════ TAB UTIL ═══════════════
mkHeader(PageUtil, "🔧 Tiện ích")
mkBtn(PageUtil, "📋 Copy Remote list", function()
    local list = {}
    if ServerEvents then
        for _, r in ipairs(ServerEvents:GetChildren()) do
            table.insert(list, r.Name .. " (" .. r.ClassName .. ")")
        end
    end
    setClip(table.concat(list, "\n"))
end, Color3.fromRGB(60, 120, 180))

mkBtn(PageUtil, "📋 Copy Maps Info", function()
    local list = {}
    if MapsInfo then
        for _, m in ipairs(MapsInfo:GetChildren()) do
            table.insert(list, m.Name)
        end
    end
    setClip(table.concat(list, "\n"))
end, Color3.fromRGB(80, 140, 100))

mkBtn(PageUtil, "📋 Copy data bản thân (JSON)", function()
    local pdata = getPlayerDataFolder()
    if not pdata then return end
    local out = {}
    for _, v in ipairs(pdata:GetChildren()) do
        if v:IsA("ValueBase") then out[v.Name] = tostring(v.Value) end
    end
    local ok, json = pcall(function() return HttpService:JSONEncode(out) end)
    if ok then setClip(json) end
end, Color3.fromRGB(100, 80, 160))

mkBtn(PageUtil, "📋 Copy Tools trong Backpack", function()
    local bp = LocalPlayer:FindFirstChild("Backpack")
    local list = {}
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(list, t.Name) end
        end
    end
    setClip(table.concat(list, "\n"))
end, Color3.fromRGB(120, 100, 60))

mkBtn(PageUtil, "🔧 Bật tất cả ProximityPrompt gần đó", function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local count = 0
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            local parent = p.Parent
            if parent and parent:IsA("BasePart") then
                local d = (parent.Position - myHRP.Position).Magnitude
                if d <= 30 then
                    p.Enabled = true
                    p.HoldDuration = 0
                    count = count + 1
                end
            end
        end
    end
    print("[FF Hub] Đã set", count, "prompt gần đó.")
end, Color3.fromRGB(140, 100, 40))

mkBtn(PageUtil, "🚀 Boost WalkSpeed (local)", function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 60 end
end, Color3.fromRGB(80, 140, 200))

mkBtn(PageUtil, "🦘 Boost JumpPower (local)", function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = 100 end
end, Color3.fromRGB(80, 140, 200))

mkBtn(PageUtil, "↩️ Reset WalkSpeed/Jump", function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = 16; hum.JumpPower = 50 end
end, Color3.fromRGB(80, 80, 100))

-- ═══════════════ HUD UPDATE LOOP ═══════════════
task.spawn(function()
    while gui.Parent do
        local lines = {}
        if GameValues then
            local playing = GameValues:FindFirstChild("Playing")
            local currentMap = GameValues:FindFirstChild("CurrentMap")
            local timeLeft = GameValues:FindFirstChild("TimeLeft")
            local fires = GameValues:FindFirstChild("FireToExtinguish")
            local alive = GameValues:FindFirstChild("PlayersAlive")
            local rescue = GameValues:FindFirstChild("CitizensToRescue")
            lines[#lines+1] = string.format("🎮 %s  |  Map: %s",
                playing and tostring(playing.Value) or "?",
                currentMap and tostring(currentMap.Value) or "?")
            lines[#lines+1] = string.format("⏱️ Time: %ss  |  🔥 Fires: %s  |  👥 Alive: %s  |  🧑 Rescue: %s",
                timeLeft and tostring(timeLeft.Value) or "?",
                fires and tostring(fires.Value) or "?",
                alive and tostring(alive.Value) or "?",
                rescue and tostring(rescue.Value) or "?")
        else
            lines[#lines+1] = "Không tìm thấy GameValues — sai game?"
        end
        hudText.Text = table.concat(lines, "\n")

        -- Update info tab
        local pdata = getPlayerDataFolder()
        if pdata then
            local exp = pdata:FindFirstChild("Exp")
            local fe = pdata:FindFirstChild("FireExtinguished")
            local citizens = pdata:FindFirstChild("Citizens")
            local saved = citizens and citizens:FindFirstChild("Saved")
            local cf = pdata:FindFirstChild("CurrentFire")
            playerInfoLabel.Text = string.format(
                "Exp: %s  |  FireExtinguished: %s\nSaved Citizens: %s  |  CurrentFire: %s",
                exp and tostring(exp.Value) or "?",
                fe and tostring(fe.Value) or "?",
                saved and tostring(saved.Value) or "?",
                cf and cf.Value and cf.Value.Name or "nil"
            )
        end

        task.wait(1)
    end
end)

-- ESP auto-refresh
task.spawn(function()
    while gui.Parent do
        if espState.fires or espState.citizens then applyESP() end
        task.wait(5)
    end
end)

-- Hotkey
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

print("[FF Hub] v2.0 loaded — Right Control để toggle.")
