--=========================================================
-- ULTIMATE 7-TAB CUSTOM TOOLKIT v7.0 (ADVANCED INSPECTOR)
-- Toggle UI: Phím Right Control
--=========================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function getScriptCode(scr)
    if decompile then
        local success, code = pcall(function() return decompile(scr) end)
        if success and code and #code > 0 then return code end
    end
    if scr:IsA("LocalScript") and scr.Source and #scr.Source > 0 then 
        return scr.Source 
    end
    return "-- [Không thể decompile script này]"
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomInspectorUI_v7"
ScreenGui.ResetOnSpawn = false

if gethui then
    ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 580, 0, 400)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Header
local TitleLabel = Instance.new("TextLabel", MainFrame)
TitleLabel.Size = UDim2.new(1, -60, 0, 30)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "⚡ TOOLKIT INSPECTOR v7.0 (7 TABS EXTENDED)"
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 3)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Navigation Bar
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -16, 0, 28)
TabBar.Position = UDim2.new(0, 8, 0, 32)
TabBar.BackgroundTransparency = 1

local TabListUI = Instance.new("UIListLayout", TabBar)
TabListUI.FillDirection = Enum.FillDirection.Horizontal
TabListUI.Padding = UDim.new(0, 3)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -16, 1, -70)
ContentContainer.Position = UDim2.new(0, 8, 0, 64)
ContentContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 6)

local pages = {}
local tabButtons = {}

local function createTab(name, id)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0.138, 0, 1, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    btn.TextColor3 = Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 9
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local page = Instance.new("Frame", ContentContainer)
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.Visible = false

    pages[id] = page
    tabButtons[id] = btn

    btn.MouseButton1Click:Connect(function()
        for pageId, p in pairs(pages) do
            p.Visible = (pageId == id)
            tabButtons[pageId].BackgroundColor3 = (pageId == id) and Color3.fromRGB(0, 160, 110) or Color3.fromRGB(28, 28, 28)
            tabButtons[pageId].TextColor3 = (pageId == id) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
        end
    end)
    return page
end

local Page1 = createTab("1. Tọa Độ", 1)
local Page2 = createTab("2. NPC Radar", 2)
local Page3 = createTab("3. Block Scan", 3)
local Page4 = createTab("4. Backpack", 4)
local Page5 = createTab("5. Stats", 5)
local Page6 = createTab("6. Remote Spy", 6)
local Page7 = createTab("7. Console Log", 7)

--=========================================================
-- TAB 1: TỌA ĐỘ ADVANCED (WAYPOINT SYSTEM + MONITOR)
--=========================================================
local PosLabel = Instance.new("TextLabel", Page1)
PosLabel.Size = UDim2.new(1, 0, 0, 30)
PosLabel.Text = "X: 0 | Y: 0 | Z: 0"
PosLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
PosLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
PosLabel.Font = Enum.Font.SourceSansBold
PosLabel.TextSize = 12
Instance.new("UICorner", PosLabel).CornerRadius = UDim.new(0, 4)

local StatusLabel = Instance.new("TextLabel", Page1)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 32)
StatusLabel.Text = "Trạng Thái: An Toàn"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 10

local CopyVecBtn = Instance.new("TextButton", Page1)
CopyVecBtn.Size = UDim2.new(0.48, 0, 0, 24)
CopyVecBtn.Position = UDim2.new(0, 0, 0, 54)
CopyVecBtn.Text = "📋 Copy Vector3"
CopyVecBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
CopyVecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyVecBtn.Font = Enum.Font.SourceSansBold
CopyVecBtn.TextSize = 9
Instance.new("UICorner", CopyVecBtn).CornerRadius = UDim.new(0, 4)

local CopyCFBtn = Instance.new("TextButton", Page1)
CopyCFBtn.Size = UDim2.new(0.48, 0, 0, 24)
CopyCFBtn.Position = UDim2.new(0.52, 0, 0, 54)
CopyCFBtn.Text = "📋 Copy CFrame"
CopyCFBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 160)
CopyCFBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyCFBtn.Font = Enum.Font.SourceSansBold
CopyCFBtn.TextSize = 9
Instance.new("UICorner", CopyCFBtn).CornerRadius = UDim.new(0, 4)

local WpScroll = Instance.new("ScrollingFrame", Page1)
WpScroll.Size = UDim2.new(1, 0, 1, -115)
WpScroll.Position = UDim2.new(0, 0, 0, 82)
WpScroll.BackgroundTransparency = 1
WpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
WpScroll.ScrollBarThickness = 3

local WpListUI = Instance.new("UIListLayout", WpScroll)
WpListUI.Padding = UDim.new(0, 4)

local SaveWpBtn = Instance.new("TextButton", Page1)
SaveWpBtn.Size = UDim2.new(1, 0, 0, 24)
SaveWpBtn.Position = UDim2.new(0, 0, 1, -26)
SaveWpBtn.Text = "📌 Lưu Vị Trí Hiện Tại Vào Danh Sách Waypoints"
SaveWpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
SaveWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveWpBtn.Font = Enum.Font.SourceSansBold
SaveWpBtn.TextSize = 10
Instance.new("UICorner", SaveWpBtn).CornerRadius = UDim.new(0, 4)

local waypoints = {}
local lastPos = nil

local function refreshWaypoints()
    for _, child in pairs(WpScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for idx, cf in ipairs(waypoints) do
        local Frame = Instance.new("Frame", WpScroll)
        Frame.Size = UDim2.new(1, -5, 0, 24)
        Frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.Position = UDim2.new(0.02, 0, 0, 0)
        Label.Text = string.format("📍 WP #%d: %.1f, %.1f, %.1f", idx, cf.X, cf.Y, cf.Z)
        Label.TextColor3 = Color3.fromRGB(200, 200, 200)
        Label.BackgroundTransparency = 1
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 9
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local TpBtn = Instance.new("TextButton", Frame)
        TpBtn.Size = UDim2.new(0.3, 0, 0.75, 0)
        TpBtn.Position = UDim2.new(0.68, 0, 0.12, 0)
        TpBtn.Text = "⚡ Teleport"
        TpBtn.BackgroundColor3 = Color3.fromRGB(180, 90, 0)
        TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TpBtn.Font = Enum.Font.SourceSansBold
        TpBtn.TextSize = 8
        Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)

        TpBtn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = cf
            end
        end)
    end
    WpScroll.CanvasSize = UDim2.new(0, 0, 0, WpListUI.AbsoluteContentSize.Y)
end

SaveWpBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
        table.insert(waypoints, cf)
        refreshWaypoints()
    end)
end)

CopyVecBtn.MouseButton1Click:Connect(function() setclipboard(PosLabel.Text) end)
CopyCFBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local cf = LocalPlayer.Character.HumanoidRootPart.CFrame
        setclipboard(string.format("CFrame.new(%.2f, %.2f, %.2f)", cf.X, cf.Y, cf.Z))
    end)
end)

task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local currentPos = char.HumanoidRootPart.Position
                PosLabel.Text = string.format("X: %.2f | Y: %.2f | Z: %.2f", currentPos.X, currentPos.Y, currentPos.Z)
                if lastPos then
                    local speed = (currentPos - lastPos).Magnitude
                    if speed > 80 or currentPos.Y < -150 or currentPos.Y > 2500 then
                        StatusLabel.Text = "⚠️ CẢNH BÁO: Tọa độ biến động bất thường!"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
                    else
                        StatusLabel.Text = "Trạng Thái: An Toàn"
                        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    end
                end
                lastPos = currentPos
            end
        end)
    end
end)

--=========================================================
-- TAB 2: NPC & RADAR (FULL ESP + NOCLIP TELEPORT)
--=========================================================
local NpcSearchBox = Instance.new("TextBox", Page2)
NpcSearchBox.Size = UDim2.new(0.65, 0, 0, 24)
NpcSearchBox.PlaceholderText = "🔍 Nhập tên NPC..."
NpcSearchBox.Text = ""
NpcSearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
NpcSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NpcSearchBox.Font = Enum.Font.SourceSans
NpcSearchBox.TextSize = 10
Instance.new("UICorner", NpcSearchBox).CornerRadius = UDim.new(0, 4)

local EspToggleBtn = Instance.new("TextButton", Page2)
EspToggleBtn.Size = UDim2.new(0.32, 0, 0, 24)
EspToggleBtn.Position = UDim2.new(0.68, 0, 0, 0)
EspToggleBtn.Text = "👁️ ESP: OFF"
EspToggleBtn.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
EspToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspToggleBtn.Font = Enum.Font.SourceSansBold
EspToggleBtn.TextSize = 10
Instance.new("UICorner", EspToggleBtn).CornerRadius = UDim.new(0, 4)

local NpcScroll = Instance.new("ScrollingFrame", Page2)
NpcScroll.Size = UDim2.new(1, 0, 1, -30)
NpcScroll.Position = UDim2.new(0, 0, 0, 30)
NpcScroll.BackgroundTransparency = 1
NpcScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
NpcScroll.ScrollBarThickness = 3

local NpcListUI = Instance.new("UIListLayout", NpcScroll)
NpcListUI.Padding = UDim.new(0, 4)

local espActive = false
local espHighlights = {}

EspToggleBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    EspToggleBtn.Text = espActive and "👁️ ESP: ON" or "👁️ ESP: OFF"
    EspToggleBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(140, 35, 35)
    if not espActive then
        for _, hl in pairs(espHighlights) do if hl then hl:Destroy() end end
        espHighlights = {}
    end
end)

local function updateNpcList()
    for _, child in pairs(NpcScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local filterText = string.lower(NpcSearchBox.Text)

    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
            if filterText == "" or string.find(string.lower(model.Name), filterText) then
                local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                local dist = (myHrp and hrp) and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0

                if espActive and not model:FindFirstChild("NPCHighlight") then
                    pcall(function()
                        local hl = Instance.new("Highlight", model)
                        hl.Name = "NPCHighlight"
                        hl.FillColor = Color3.fromRGB(255, 200, 0)
                        hl.OutlineColor = Color3.fromRGB(255, 0, 0)
                        table.insert(espHighlights, hl)
                    end)
                end

                local ItemFrame = Instance.new("Frame", NpcScroll)
                ItemFrame.Size = UDim2.new(1, -5, 0, 26)
                ItemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

                local InfoText = Instance.new("TextLabel", ItemFrame)
                InfoText.Size = UDim2.new(0.7, 0, 1, 0)
                InfoText.Position = UDim2.new(0.02, 0, 0, 0)
                InfoText.Text = string.format("👾 %s (%dm)", model.Name, dist)
                InfoText.TextColor3 = Color3.fromRGB(220, 220, 220)
                InfoText.BackgroundTransparency = 1
                InfoText.Font = Enum.Font.SourceSans
                InfoText.TextSize = 10
                InfoText.TextXAlignment = Enum.TextXAlignment.Left

                local TpBtn = Instance.new("TextButton", ItemFrame)
                TpBtn.Size = UDim2.new(0.26, 0, 0.7, 0)
                TpBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
                TpBtn.Text = "Teleport"
                TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
                TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                TpBtn.Font = Enum.Font.SourceSansBold
                TpBtn.TextSize = 9
                Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)

                TpBtn.MouseButton1Click:Connect(function()
                    if myHrp and hrp then myHrp.CFrame = hrp.CFrame * CFrame.new(0, 2, 3) end
                end)
            end
        end
    end
    NpcScroll.CanvasSize = UDim2.new(0, 0, 0, NpcListUI.AbsoluteContentSize.Y)
end

--=========================================================
-- TAB 3: BLOCK SCANNER & AUTO INTERACTOR
--=========================================================
local InstantHoldBtn = Instance.new("TextButton", Page3)
InstantHoldBtn.Size = UDim2.new(0.32, 0, 0, 24)
InstantHoldBtn.Text = "⚡ Hold=0"
InstantHoldBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 0)
InstantHoldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantHoldBtn.Font = Enum.Font.SourceSansBold
InstantHoldBtn.TextSize = 9
Instance.new("UICorner", InstantHoldBtn).CornerRadius = UDim.new(0, 4)

local FirePromptsBtn = Instance.new("TextButton", Page3)
FirePromptsBtn.Size = UDim2.new(0.32, 0, 0, 24)
FirePromptsBtn.Position = UDim2.new(0.34, 0, 0, 0)
FirePromptsBtn.Text = "🔥 Fire All"
FirePromptsBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
FirePromptsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FirePromptsBtn.Font = Enum.Font.SourceSansBold
FirePromptsBtn.TextSize = 9
Instance.new("UICorner", FirePromptsBtn).CornerRadius = UDim.new(0, 4)

local AutoLoopBtn = Instance.new("TextButton", Page3)
AutoLoopBtn.Size = UDim2.new(0.32, 0, 0, 24)
AutoLoopBtn.Position = UDim2.new(0.68, 0, 0, 0)
AutoLoopBtn.Text = "🔄 Auto Loop: OFF"
AutoLoopBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoLoopBtn.Font = Enum.Font.SourceSansBold
AutoLoopBtn.TextSize = 8
Instance.new("UICorner", AutoLoopBtn).CornerRadius = UDim.new(0, 4)

local autoLoopActive = false
AutoLoopBtn.MouseButton1Click:Connect(function()
    autoLoopActive = not autoLoopActive
    AutoLoopBtn.Text = autoLoopActive and "🔄 Auto Loop: ON" or "🔄 Auto Loop: OFF"
    AutoLoopBtn.BackgroundColor3 = autoLoopActive and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)
end)

task.spawn(function()
    while task.wait(0.5) do
        if autoLoopActive then
            pcall(function()
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then fireproximityprompt(prompt) end
                end
            end)
        end
    end
end)

local ScanScroll = Instance.new("ScrollingFrame", Page3)
ScanScroll.Size = UDim2.new(1, 0, 1, -30)
ScanScroll.Position = UDim2.new(0, 0, 0, 30)
ScanScroll.BackgroundTransparency = 1
ScanScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ScanScroll.ScrollBarThickness = 3

local ScanListUI = Instance.new("UIListLayout", ScanScroll)
ScanListUI.Padding = UDim.new(0, 4)

InstantHoldBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, prompt in pairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
        end
    end)
end)

FirePromptsBtn.MouseButton1Click:Connect(function()
    pcall(function()
        for _, prompt in pairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then fireproximityprompt(prompt) end
        end
    end)
end)

local function updateBlockScanner()
    for _, child in pairs(ScanScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local ItemFrame = Instance.new("Frame", ScanScroll)
            ItemFrame.Size = UDim2.new(1, -5, 0, 26)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

            local InfoText = Instance.new("TextLabel", ItemFrame)
            InfoText.Size = UDim2.new(0.7, 0, 1, 0)
            InfoText.Position = UDim2.new(0.02, 0, 0, 0)
            InfoText.Text = string.format("📦 %s [%s]", obj.Name, obj.ClassName)
            InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
            InfoText.BackgroundTransparency = 1
            InfoText.Font = Enum.Font.SourceSans
            InfoText.TextSize = 10
            InfoText.TextXAlignment = Enum.TextXAlignment.Left

            local CopyPathBtn = Instance.new("TextButton", ItemFrame)
            CopyPathBtn.Size = UDim2.new(0.26, 0, 0.7, 0)
            CopyPathBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
            CopyPathBtn.Text = "Copy Path"
            CopyPathBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            CopyPathBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            CopyPathBtn.Font = Enum.Font.SourceSans
            CopyPathBtn.TextSize = 9
            Instance.new("UICorner", CopyPathBtn).CornerRadius = UDim.new(0, 3)

            CopyPathBtn.MouseButton1Click:Connect(function()
                setclipboard(obj:GetFullName())
            end)
        end
    end
    ScanScroll.CanvasSize = UDim2.new(0, 0, 0, ScanListUI.AbsoluteContentSize.Y)
end

--=========================================================
-- TAB 4: BACKPACK INSPECTOR & SCRIPT EXTENSION
--=========================================================
local InvScroll = Instance.new("ScrollingFrame", Page4)
InvScroll.Size = UDim2.new(1, 0, 1, 0)
InvScroll.BackgroundTransparency = 1
InvScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
InvScroll.ScrollBarThickness = 3

local InvListUI = Instance.new("UIListLayout", InvScroll)
InvListUI.Padding = UDim.new(0, 6)

local function buildItemScriptsUI(item, parentFrame)
    local scriptsFound = {}
    for _, desc in pairs(item:GetDescendants()) do
        if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
            table.insert(scriptsFound, desc)
        end
    end

    if #scriptsFound == 0 then
        local EmptyText = Instance.new("TextLabel", parentFrame)
        EmptyText.Size = UDim2.new(1, 0, 0, 14)
        EmptyText.Text = "  └─ [Không có Script bên trong]"
        EmptyText.TextColor3 = Color3.fromRGB(110, 110, 110)
        EmptyText.BackgroundTransparency = 1
        EmptyText.Font = Enum.Font.SourceSansItalic
        EmptyText.TextSize = 9
        EmptyText.TextXAlignment = Enum.TextXAlignment.Left
    else
        for _, scr in pairs(scriptsFound) do
            local ScrFrame = Instance.new("Frame", parentFrame)
            ScrFrame.Size = UDim2.new(1, -4, 0, 20)
            ScrFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            Instance.new("UICorner", ScrFrame).CornerRadius = UDim.new(0, 3)

            local ScrLabel = Instance.new("TextLabel", ScrFrame)
            ScrLabel.Size = UDim2.new(0.65, 0, 1, 0)
            ScrLabel.Position = UDim2.new(0.02, 0, 0, 0)
            ScrLabel.Text = string.format("📜 %s (%s)", scr.Name, scr.ClassName)
            ScrLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
            ScrLabel.BackgroundTransparency = 1
            ScrLabel.Font = Enum.Font.SourceSans
            ScrLabel.TextSize = 9
            ScrLabel.TextXAlignment = Enum.TextXAlignment.Left

            local CopyCodeBtn = Instance.new("TextButton", ScrFrame)
            CopyCodeBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
            CopyCodeBtn.Position = UDim2.new(0.68, 0, 0.1, 0)
            CopyCodeBtn.Text = "📜 Copy Code"
            CopyCodeBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
            CopyCodeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            CopyCodeBtn.Font = Enum.Font.SourceSansBold
            CopyCodeBtn.TextSize = 8
            Instance.new("UICorner", CopyCodeBtn).CornerRadius = UDim.new(0, 3)

            CopyCodeBtn.MouseButton1Click:Connect(function()
                setclipboard(getScriptCode(scr))
            end)
        end
    end
end

local function updateBackpackInspector()
    for _, child in pairs(InvScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end

    for _, plr in pairs(Players:GetPlayers()) do
        local allItems = {}
        local bp = plr:FindFirstChild("Backpack")
        if bp then
            for _, item in pairs(bp:GetChildren()) do if item:IsA("Tool") then table.insert(allItems, {Obj = item, Status = "Túi đồ"}) end end
        end
        if plr.Character then
            for _, item in pairs(plr.Character:GetChildren()) do if item:IsA("Tool") then table.insert(allItems, {Obj = item, Status = "Đang cầm"}) end end
        end

        local PlayerCard = Instance.new("Frame", InvScroll)
        PlayerCard.Size = UDim2.new(1, -5, 0, 130)
        PlayerCard.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Instance.new("UICorner", PlayerCard).CornerRadius = UDim.new(0, 5)

        local PlayerTitle = Instance.new("TextLabel", PlayerCard)
        PlayerTitle.Size = UDim2.new(0.96, 0, 0, 18)
        PlayerTitle.Position = UDim2.new(0.02, 0, 0.02, 0)
        PlayerTitle.Text = string.format("👤 %s (%d items)", plr.DisplayName, #allItems)
        PlayerTitle.TextColor3 = Color3.fromRGB(255, 210, 80)
        PlayerTitle.BackgroundTransparency = 1
        PlayerTitle.Font = Enum.Font.SourceSansBold
        PlayerTitle.TextSize = 10
        PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left

        local ItemsContainer = Instance.new("ScrollingFrame", PlayerCard)
        ItemsContainer.Size = UDim2.new(0.96, 0, 0, 102)
        ItemsContainer.Position = UDim2.new(0.02, 0, 0.18, 0)
        ItemsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        ItemsContainer.ScrollBarThickness = 3

        local ItemsListUI = Instance.new("UIListLayout", ItemsContainer)
        ItemsListUI.Padding = UDim.new(0, 4)

        if #allItems == 0 then
            local EmptyText = Instance.new("TextLabel", ItemsContainer)
            EmptyText.Size = UDim2.new(1, 0, 0, 20)
            EmptyText.Text = "Túi đồ trống"
            EmptyText.TextColor3 = Color3.fromRGB(120, 120, 120)
            EmptyText.BackgroundTransparency = 1
            EmptyText.Font = Enum.Font.SourceSansItalic
            EmptyText.TextSize = 10
        else
            for _, itemData in pairs(allItems) do
                local toolFrame = Instance.new("Frame", ItemsContainer)
                toolFrame.Size = UDim2.new(1, -4, 0, 42)
                toolFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                Instance.new("UICorner", toolFrame).CornerRadius = UDim.new(0, 4)

                local ToolTitle = Instance.new("TextLabel", toolFrame)
                ToolTitle.Size = UDim2.new(1, 0, 0, 15)
                ToolTitle.Position = UDim2.new(0.02, 0, 0, 0)
                ToolTitle.Text = string.format("🗡️ %s [%s]", itemData.Obj.Name, itemData.Status)
                ToolTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
                ToolTitle.BackgroundTransparency = 1
                ToolTitle.Font = Enum.Font.SourceSansBold
                ToolTitle.TextSize = 9
                ToolTitle.TextXAlignment = Enum.TextXAlignment.Left

                local ScriptsSubContainer = Instance.new("Frame", toolFrame)
                ScriptsSubContainer.Size = UDim2.new(0.96, 0, 0, 22)
                ScriptsSubContainer.Position = UDim2.new(0.02, 0, 0.42, 0)
                ScriptsSubContainer.BackgroundTransparency = 1

                local SubListUI = Instance.new("UIListLayout", ScriptsSubContainer)
                SubListUI.Padding = UDim.new(0, 2)

                buildItemScriptsUI(itemData.Obj, ScriptsSubContainer)
            end
        end
        ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, ItemsListUI.AbsoluteContentSize.Y)
    end
    InvScroll.CanvasSize = UDim2.new(0, 0, 0, InvListUI.AbsoluteContentSize.Y)
end

--=========================================================
-- TAB 5: STATS INSPECTOR
--=========================================================
local StatsScroll = Instance.new("ScrollingFrame", Page5)
StatsScroll.Size = UDim2.new(1, 0, 1, 0)
StatsScroll.BackgroundTransparency = 1
StatsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
StatsScroll.ScrollBarThickness = 3

local StatsListUI = Instance.new("UIListLayout", StatsScroll)
StatsListUI.Padding = UDim.new(0, 6)

local function buildStatDetails(plr, parentFrame)
    local leaderstats = plr:FindFirstChild("leaderstats")
    if not leaderstats or #leaderstats:GetChildren() == 0 then
        local EmptyText = Instance.new("TextLabel", parentFrame)
        EmptyText.Size = UDim2.new(1, 0, 0, 18)
        EmptyText.Text = "• Không có dữ liệu leaderstats"
        EmptyText.TextColor3 = Color3.fromRGB(140, 140, 140)
        EmptyText.BackgroundTransparency = 1
        EmptyText.Font = Enum.Font.SourceSansItalic
        EmptyText.TextSize = 9
        EmptyText.TextXAlignment = Enum.TextXAlignment.Left
        return
    end

    for _, stat in pairs(leaderstats:GetChildren()) do
        local StatFrame = Instance.new("Frame", parentFrame)
        StatFrame.Size = UDim2.new(1, -4, 0, 22)
        StatFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        Instance.new("UICorner", StatFrame).CornerRadius = UDim.new(0, 4)

        local valStr = stat:IsA("ValueBase") and tostring(stat.Value) or "N/A"
        local StatLabel = Instance.new("TextLabel", StatFrame)
        StatLabel.Size = UDim2.new(0.58, 0, 1, 0)
        StatLabel.Position = UDim2.new(0.02, 0, 0, 0)
        StatLabel.Text = string.format("💎 %s: %s", stat.Name, valStr)
        StatLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
        StatLabel.BackgroundTransparency = 1
        StatLabel.Font = Enum.Font.SourceSansBold
        StatLabel.TextSize = 9
        StatLabel.TextXAlignment = Enum.TextXAlignment.Left

        local CopyValBtn = Instance.new("TextButton", StatFrame)
        CopyValBtn.Size = UDim2.new(0.36, 0, 0.7, 0)
        CopyValBtn.Position = UDim2.new(0.61, 0, 0.15, 0)
        CopyValBtn.Text = "📋 Copy Value"
        CopyValBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        CopyValBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyValBtn.Font = Enum.Font.SourceSansBold
        CopyValBtn.TextSize = 8
        Instance.new("UICorner", CopyValBtn).CornerRadius = UDim.new(0, 3)

        CopyValBtn.MouseButton1Click:Connect(function()
            setclipboard(valStr)
        end)
    end
end

local function updateStatsInspector()
    for _, child in pairs(StatsScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local distStr = (myHrp and hrp) and string.format("%dm", math.floor((hrp.Position - myHrp.Position).Magnitude)) or "N/A"

        local CardFrame = Instance.new("Frame", StatsScroll)
        CardFrame.Size = UDim2.new(1, -5, 0, 125)
        CardFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        Instance.new("UICorner", CardFrame).CornerRadius = UDim.new(0, 5)

        local HeaderLabel = Instance.new("TextLabel", CardFrame)
        HeaderLabel.Size = UDim2.new(0.96, 0, 0, 18)
        HeaderLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
        HeaderLabel.Text = string.format("👤 %s (@%s) | HP: %d/%d | Cách: %s", 
            plr.DisplayName, plr.Name, 
            hum and math.floor(hum.Health) or 0, hum and math.floor(hum.MaxHealth) or 0, 
            distStr)
        HeaderLabel.TextColor3 = (plr == LocalPlayer) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 200, 50)
        HeaderLabel.BackgroundTransparency = 1
        HeaderLabel.Font = Enum.Font.SourceSansBold
        HeaderLabel.TextSize = 10
        HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left

        local StatsContainer = Instance.new("ScrollingFrame", CardFrame)
        StatsContainer.Size = UDim2.new(0.96, 0, 0, 98)
        StatsContainer.Position = UDim2.new(0.02, 0, 0.18, 0)
        StatsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        StatsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        StatsContainer.ScrollBarThickness = 3

        local ContainerListUI = Instance.new("UIListLayout", StatsContainer)
        ContainerListUI.Padding = UDim.new(0, 4)

        buildStatDetails(plr, StatsContainer)
        StatsContainer.CanvasSize = UDim2.new(0, 0, 0, ContainerListUI.AbsoluteContentSize.Y)
    end
    StatsScroll.CanvasSize = UDim2.new(0, 0, 0, StatsListUI.AbsoluteContentSize.Y)
end

--=========================================================
-- TAB 6: REMOTE SPY & EVENT SNIFFER
--=========================================================
local RemoteSpyToggle = Instance.new("TextButton", Page6)
RemoteSpyToggle.Size = UDim2.new(0.48, 0, 0, 24)
RemoteSpyToggle.Text = "📡 Spy Status: OFF"
RemoteSpyToggle.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
RemoteSpyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RemoteSpyToggle.Font = Enum.Font.SourceSansBold
RemoteSpyToggle.TextSize = 9
Instance.new("UICorner", RemoteSpyToggle).CornerRadius = UDim.new(0, 4)

local ClearSpyBtn = Instance.new("TextButton", Page6)
ClearSpyBtn.Size = UDim2.new(0.48, 0, 0, 24)
ClearSpyBtn.Position = UDim2.new(0.52, 0, 0, 0)
ClearSpyBtn.Text = "🗑️ Clear Logs"
ClearSpyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearSpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearSpyBtn.Font = Enum.Font.SourceSansBold
ClearSpyBtn.TextSize = 9
Instance.new("UICorner", ClearSpyBtn).CornerRadius = UDim.new(0, 4)

local SpyScroll = Instance.new("ScrollingFrame", Page6)
SpyScroll.Size = UDim2.new(1, 0, 1, -30)
SpyScroll.Position = UDim2.new(0, 0, 0, 30)
SpyScroll.BackgroundTransparency = 1
SpyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SpyScroll.ScrollBarThickness = 3

local SpyListUI = Instance.new("UIListLayout", SpyScroll)
SpyListUI.Padding = UDim.new(0, 4)

local spyActive = false
local hookedRemotes = {}

RemoteSpyToggle.MouseButton1Click:Connect(function()
    spyActive = not spyActive
    RemoteSpyToggle.Text = spyActive and "📡 Spy Status: ON" or "📡 Spy Status: OFF"
    RemoteSpyToggle.BackgroundColor3 = spyActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(140, 35, 35)
end)

ClearSpyBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(SpyScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    SpyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

local function logRemoteEvent(remote, args)
    if not spyActive then return end
    
    local ItemFrame = Instance.new("Frame", SpyScroll)
    ItemFrame.Size = UDim2.new(1, -5, 0, 26)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

    local InfoText = Instance.new("TextLabel", ItemFrame)
    InfoText.Size = UDim2.new(0.68, 0, 1, 0)
    InfoText.Position = UDim2.new(0.02, 0, 0, 0)
    InfoText.Text = string.format("⚡ [%s] %s", remote.ClassName, remote.Name)
    InfoText.TextColor3 = Color3.fromRGB(255, 180, 50)
    InfoText.BackgroundTransparency = 1
    InfoText.Font = Enum.Font.SourceSansBold
    InfoText.TextSize = 9
    InfoText.TextXAlignment = Enum.TextXAlignment.Left

    local CopyCallBtn = Instance.new("TextButton", ItemFrame)
    CopyCallBtn.Size = UDim2.new(0.28, 0, 0.7, 0)
    CopyCallBtn.Position = UDim2.new(0.7, 0, 0.15, 0)
    CopyCallBtn.Text = "📋 Copy Code"
    CopyCallBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
    CopyCallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyCallBtn.Font = Enum.Font.SourceSansBold
    CopyCallBtn.TextSize = 8
    Instance.new("UICorner", CopyCallBtn).CornerRadius = UDim.new(0, 3)

    CopyCallBtn.MouseButton1Click:Connect(function()
        local path = remote:GetFullName()
        local code = string.format("game:GetService(\"%s\")", path)
        setclipboard(string.format("-- Path: %s\n-- Call: %s:FireServer()", path, remote.Name))
    end)

    SpyScroll.CanvasSize = UDim2.new(0, 0, 0, SpyListUI.AbsoluteContentSize.Y)
end

-- Scan Remotes
task.spawn(function()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if not hookedRemotes[obj] then
                hookedRemotes[obj] = true
                if obj:IsA("RemoteEvent") then
                    obj.OnClientEvent:Connect(function(...)
                        logRemoteEvent(obj, {...})
                    end)
                end
            end
        end
    end
end)

--=========================================================
-- TAB 7: CONSOLE & EXECUTION LOG
--=========================================================
local ConsoleScroll = Instance.new("ScrollingFrame", Page7)
ConsoleScroll.Size = UDim2.new(1, 0, 1, -28)
ConsoleScroll.Position = UDim2.new(0, 0, 0, 0)
ConsoleScroll.BackgroundTransparency = 1
ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ConsoleScroll.ScrollBarThickness = 3

local ConsoleListUI = Instance.new("UIListLayout", ConsoleScroll)
ConsoleListUI.Padding = UDim.new(0, 3)

local ClearConsoleBtn = Instance.new("TextButton", Page7)
ClearConsoleBtn.Size = UDim2.new(1, 0, 0, 24)
ClearConsoleBtn.Position = UDim2.new(0, 0, 1, -24)
ClearConsoleBtn.Text = "🗑️ Clear Console Log"
ClearConsoleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ClearConsoleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearConsoleBtn.Font = Enum.Font.SourceSansBold
ClearConsoleBtn.TextSize = 9
Instance.new("UICorner", ClearConsoleBtn).CornerRadius = UDim.new(0, 4)

ClearConsoleBtn.MouseButton1Click:Connect(function()
    for _, child in pairs(ConsoleScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

local function appendLog(message, messageType)
    local Frame = Instance.new("Frame", ConsoleScroll)
    Frame.Size = UDim2.new(1, -5, 0, 20)
    Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)

    local LogText = Instance.new("TextLabel", Frame)
    LogText.Size = UDim2.new(0.98, 0, 1, 0)
    LogText.Position = UDim2.new(0.01, 0, 0, 0)
    LogText.Text = string.format("[%s] %s", os.date("%H:%M:%S"), message)
    LogText.BackgroundTransparency = 1
    LogText.Font = Enum.Font.SourceSans
    LogText.TextSize = 9
    LogText.TextXAlignment = Enum.TextXAlignment.Left

    if messageType == Enum.MessageType.MessageOutput then
        LogText.TextColor3 = Color3.fromRGB(220, 220, 220)
    elseif messageType == Enum.MessageType.MessageWarning then
        LogText.TextColor3 = Color3.fromRGB(255, 200, 50)
    elseif messageType == Enum.MessageType.MessageError then
        LogText.TextColor3 = Color3.fromRGB(255, 70, 70)
    else
        LogText.TextColor3 = Color3.fromRGB(100, 200, 255)
    end

    ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, ConsoleListUI.AbsoluteContentSize.Y)
end

LogService.MessageOut:Connect(appendLog)

-- VÒNG LẶP TỰ ĐỘNG CẬP NHẬT
task.spawn(function()
    while task.wait(1.5) do
        if Page2.Visible then updateNpcList() end
        if Page3.Visible then updateBlockScanner() end
        if Page4.Visible then updateBackpackInspector() end
        if Page5.Visible then updateStatsInspector() end
    end
end)

tabButtons[1].BackgroundColor3 = Color3.fromRGB(0, 160, 110)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
Page1.Visible = true
