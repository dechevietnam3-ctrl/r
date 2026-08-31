-- ================================================================
--  🎯 AIMBOT PRO v1.2  —  tookit  (FIX UI LAYOUT)
--  Tự động nhắm & bắn mục tiêu (Players)
--  Toggle: Right Control
-- ================================================================

local Tookit = {} -- "tookit" marker

-- ================================================================
-- SERVICES
-- ================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

repeat task.wait() until LocalPlayer and LocalPlayer.Character

-- ================================================================
-- UTILITY
-- ================================================================
local function getTargetPart(plr, partName)
    local char = plr.Character
    if not char then return nil end
    if partName == "Head" then
        return char:FindFirstChild("Head")
    elseif partName == "Torso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

-- ================================================================
-- SETTINGS
-- ================================================================
local settings = {
    enabled = false,
    autoFire = false,
    fov = 45,
    smoothing = 5,
    targetPart = "Head",
}

-- ================================================================
-- UI CREATION (FIX PARENT)
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotPro"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function safeParent()
    local success, err = pcall(function()
        if gethui then
            ScreenGui.Parent = gethui()
            return
        end
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = CoreGui
            return
        end
        local pg = LocalPlayer:WaitForChild("PlayerGui")
        ScreenGui.Parent = pg
    end)
    if not success then
        ScreenGui.Parent = CoreGui
    end
end
safeParent()
if not ScreenGui.Parent then
    task.delay(0.1, function() ScreenGui.Parent = CoreGui end)
end

-- ================================================================
-- MAIN FRAME
-- ================================================================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 380)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255, 50, 50)
Stroke.Thickness = 2

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -20, 0, 32)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.Text = "🎯 AIMBOT PRO  —  tookit"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 4)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ================================================================
-- CONTROLS WITH UIListLayout (FIX OVERLAP)
-- ================================================================
local ControlsContainer = Instance.new("Frame", MainFrame)
ControlsContainer.Size = UDim2.new(1, -16, 1, -38)
ControlsContainer.Position = UDim2.new(0, 8, 0, 38)
ControlsContainer.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", ControlsContainer)
Layout.FillDirection = Enum.FillDirection.Vertical
Layout.Padding = UDim.new(0, 6)  -- Khoảng cách giữa các hàng
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Hàm tạo một hàng điều khiển
local function createControlRow()
    local row = Instance.new("Frame", ControlsContainer)
    row.Size = UDim2.new(1, 0, 0, 28)  -- Chiều cao cố định
    row.BackgroundTransparency = 1
    row.LayoutOrder = 0  -- Sẽ được cập nhật
    return row
end

-- Hàm tạo toggle
local function createToggle(label, callback)
    local row = createControlRow()
    row.LayoutOrder = #ControlsContainer:GetChildren() - 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0.2, 0, 0.8, 0)
    btn.Position = UDim2.new(0.7, 0, 0.1, 0)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        local newState = btn.Text == "OFF"
        btn.Text = newState and "ON" or "OFF"
        btn.BackgroundColor3 = newState and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 80)
        callback(newState)
    end)
    return btn
end

-- Hàm tạo slider
local function createSlider(label, minVal, maxVal, defaultValue, callback)
    local row = createControlRow()
    row.LayoutOrder = #ControlsContainer:GetChildren() - 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size = UDim2.new(0.08, 0, 1, 0)
    valLbl.Position = UDim2.new(0.42, 0, 0, 0)
    valLbl.Text = tostring(defaultValue)
    valLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.SourceSansBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Center

    local sliderBg = Instance.new("Frame", row)
    sliderBg.Size = UDim2.new(0.45, 0, 0.5, 0)
    sliderBg.Position = UDim2.new(0.52, 0, 0.25, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame", sliderBg)
    local initScale = (defaultValue - minVal) / (maxVal - minVal)
    sliderFill.Size = UDim2.new(initScale, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local dragBtn = Instance.new("TextButton", sliderBg)
    dragBtn.Size = UDim2.new(0, 10, 1, 0)
    dragBtn.Position = UDim2.new(initScale - 0.015, 0, 0, 0)
    dragBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dragBtn.Text = ""
    Instance.new("UICorner", dragBtn).CornerRadius = UDim.new(1, 0)
    dragBtn.AutoButtonColor = false

    local dragging = false
    local function updateSlider(mouseX)
        local relX = math.clamp((mouseX - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + (maxVal - minVal) * relX + 0.5)
        sliderFill.Size = UDim2.new(relX, 0, 1, 0)
        dragBtn.Position = UDim2.new(relX - 0.015, 0, 0, 0)
        valLbl.Text = tostring(val)
        callback(val)
    end

    dragBtn.MouseButton1Down:Connect(function() dragging = true end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)
    sliderBg.MouseButton1Click:Connect(function(x) updateSlider(x.X) end)
    return valLbl
end

-- Hàm tạo dropdown
local function createDropdown(label, options, defaultIndex, callback)
    local row = createControlRow()
    row.LayoutOrder = #ControlsContainer:GetChildren() - 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0.4, 0, 0.8, 0)
    btn.Position = UDim2.new(0.55, 0, 0.1, 0)
    btn.Text = options[defaultIndex] or options[1]
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local idx = defaultIndex or 1
    btn.MouseButton1Click:Connect(function()
        idx = idx % #options + 1
        btn.Text = options[idx]
        callback(options[idx])
    end)
    return btn
end

-- Status label (không nằm trong layout, đặt phía dưới)
local statusLabel = Instance.new("TextLabel", ControlsContainer)
statusLabel.Size = UDim2.new(1, 0, 0, 22)
statusLabel.Position = UDim2.new(0, 0, 0, 0)  -- sẽ được đặt dưới layout
statusLabel.Text = "🔴 No target"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Key hint
local keyHint = Instance.new("TextLabel", ControlsContainer)
keyHint.Size = UDim2.new(1, 0, 0, 18)
keyHint.Position = UDim2.new(0, 0, 0, 0)
keyHint.Text = "⌨️ Right Control toggle"
keyHint.TextColor3 = Color3.fromRGB(150, 150, 160)
keyHint.BackgroundTransparency = 1
keyHint.Font = Enum.Font.SourceSans
keyHint.TextSize = 11
keyHint.TextXAlignment = Enum.TextXAlignment.Left

-- Thêm các control với LayoutOrder phù hợp
local toggleBtn = createToggle("🎯 Aimbot", function(state) settings.enabled = state end)
local autoFireBtn = createToggle("🔥 Auto Fire", function(state) settings.autoFire = state end)
createSlider("FOV (độ)", 5, 180, settings.fov, function(val) settings.fov = val end)
createSlider("Smoothing", 1, 20, settings.smoothing, function(val) settings.smoothing = val end)
createDropdown("Target Part", {"Head", "Torso", "HumanoidRootPart"}, 1, function(opt) settings.targetPart = opt end)

-- Đặt status và key hint xuống cuối cùng bằng LayoutOrder cao
statusLabel.LayoutOrder = 100
keyHint.LayoutOrder = 101

-- Cập nhật lại layout để các phần tử căn chỉnh
task.wait(0.05)
ControlsContainer.Size = UDim2.new(1, -16, 1, -38)  -- Đảm bảo đủ chỗ

-- ================================================================
-- AIMBOT ENGINE
-- ================================================================
local function getTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myPos = myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position or Vector3.new(0,0,0)
    local cameraCF = Camera.CFrame

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and isAlive(player) then
            local part = getTargetPart(player, settings.targetPart)
            if part and part.Parent and part.Parent ~= myChar then
                local pos = part.Position
                local dir = (pos - cameraCF.Position).Unit
                local angle = math.deg(math.acos(math.clamp(cameraCF.LookVector:Dot(dir), -1, 1)))
                if angle <= settings.fov then
                    local dist = (pos - myPos).Magnitude
                    table.insert(targets, {player=player, part=part, angle=angle, dist=dist})
                end
            end
        end
    end
    table.sort(targets, function(a,b) return a.angle < b.angle end)
    return targets
end

local function aimAt(targetPart)
    if not targetPart then return end
    local targetPos = targetPart.Position
    local currentCF = Camera.CFrame
    local targetCF = CFrame.lookAt(currentCF.Position, targetPos)
    if settings.smoothing > 1 then
        local factor = 1 / settings.smoothing
        Camera.CFrame = currentCF:Lerp(targetCF, factor)
    else
        Camera.CFrame = targetCF
    end
end

local function fire()
    if mouse1click then
        mouse1click()
        return true
    end
    return false
end

-- ================================================================
-- MAIN LOOP
-- ================================================================
RunService.RenderStepped:Connect(function()
    if not settings.enabled then
        statusLabel.Text = "🔴 Disabled"
        statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end

    local targets = getTargets()
    if #targets == 0 then
        statusLabel.Text = "🔴 No target"
        statusLabel.TextColor3 = Color3.fromRGB(200, 80, 80)
        return
    end

    local best = targets[1]
    statusLabel.Text = "🎯 " .. best.player.DisplayName .. " (" .. math.floor(best.dist) .. "m)"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)

    aimAt(best.part)
    if settings.autoFire then
        fire()
    end
end)

-- ================================================================
-- HOTKEY TOGGLE
-- ================================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ================================================================
-- INIT
-- ================================================================
print("🎯 AIMBOT PRO v1.2 loaded — tookit")
print("⌨️  Right Control để toggle UI")
