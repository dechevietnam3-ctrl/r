-- ================================================================
--  🎯 AIMBOT PRO v2.0  —  tookit  (UI FIX + ESP + WALLBANG)
--  Tự động nhắm & bắn mục tiêu (Players)
--  Toggle: Right Control
--  Tính năng: Crosshair, ESP địch, Wallbang, Auto Fire
-- ================================================================

local Tookit = {} -- "tookit" marker

-- ================================================================
-- SERVICES
-- ================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

repeat task.wait() until LocalPlayer and LocalPlayer.Character

-- ================================================================
-- SETTINGS
-- ================================================================
local settings = {
    enabled = false,
    autoFire = false,
    fov = 45,
    smoothing = 5,
    wallbang = false,
    espEnabled = false,
    crosshairEnabled = false,
}

-- ================================================================
-- UTILITY
-- ================================================================
local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function getHead(plr)
    local char = plr.Character
    if not char then return nil end
    return char:FindFirstChild("Head")
end

local function getTargetPart(plr)
    -- Luôn ngắm đầu
    return getHead(plr)
end

local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- ================================================================
-- UI CREATION (FIX: KHÔNG BỊ TRÙNG)
-- ================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotPro"
ScreenGui.ResetOnSpawn = false

local function safeParent()
    local ok, err = pcall(function()
        if gethui then
            ScreenGui.Parent = gethui()
            return
        end
        if syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
            ScreenGui.Parent = CoreGui
            return
        end
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end)
    if not ok then
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
MainFrame.Size = UDim2.new(0, 340, 0, 420)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255, 50, 50)
Stroke.Thickness = 2

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.Text = "🎯 AIMBOT PRO v2.0  —  tookit"
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
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ================================================================
-- CONTROLS CONTAINER (Dùng UIListLayout để tránh trùng)
-- ================================================================
local Controls = Instance.new("ScrollingFrame", MainFrame)
Controls.Size = UDim2.new(1, -16, 1, -38)
Controls.Position = UDim2.new(0, 8, 0, 38)
Controls.BackgroundTransparency = 1
Controls.CanvasSize = UDim2.new(0, 0, 0, 0)
Controls.ScrollBarThickness = 4

local layout = Instance.new("UIListLayout", Controls)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local padding = Instance.new("UIPadding", Controls)
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)

-- ================================================================
-- HELPER FUNCTIONS TẠO CONTROL (CÓ LAYOUT ORDER)
-- ================================================================
local order = 0

local function nextOrder()
    order = order + 1
    return order
end

local function createToggle(label, callback)
    local frame = Instance.new("Frame", Controls)
    frame.Size = UDim2.new(0.9, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = nextOrder()

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.2, 0, 0.8, 0)
    btn.Position = UDim2.new(0.7, 0, 0.1, 0)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function()
        local state = btn.Text == "OFF"
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(60, 60, 80)
        callback(state)
    end)
    return btn
end

local function createSlider(label, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame", Controls)
    frame.Size = UDim2.new(0.9, 0, 0, 32)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = nextOrder()

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.45, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", frame)
    valLbl.Size = UDim2.new(0.1, 0, 1, 0)
    valLbl.Position = UDim2.new(0.5, 0, 0, 0)
    valLbl.Text = tostring(defaultVal)
    valLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.SourceSansBold
    valLbl.TextSize = 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Center

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(0.3, 0, 0.5, 0)
    sliderBg.Position = UDim2.new(0.62, 0, 0.25, 0)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 50)
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

    local dragBtn = Instance.new("TextButton", sliderBg)
    dragBtn.Size = UDim2.new(0, 10, 1, 0)
    dragBtn.Position = UDim2.new(sliderFill.Size.X.Scale - 0.015, 0, 0, 0)
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

local function createDropdown(label, options, defaultIndex, callback)
    local frame = Instance.new("Frame", Controls)
    frame.Size = UDim2.new(0.9, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = nextOrder()

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0.3, 0, 0.8, 0)
    btn.Position = UDim2.new(0.6, 0, 0.1, 0)
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

-- Tạo các control
createToggle("🎯 Aimbot", function(s) settings.enabled = s end)
createToggle("🔥 Auto Fire", function(s) settings.autoFire = s end)
createToggle("🧱 Wallbang (xuyên tường)", function(s) settings.wallbang = s end)
createToggle("👁️ ESP địch", function(s) 
    settings.espEnabled = s
    if not s then
        clearESP()
    else
        updateESP()
    end
end)
createToggle("🎯 Crosshair", function(s) 
    settings.crosshairEnabled = s
    updateCrosshair()
end)
createSlider("FOV (độ)", 5, 180, 45, function(v) settings.fov = v end)
createSlider("Smoothing", 1, 20, 5, function(v) settings.smoothing = v end)

-- Status label
local statusLabel = Instance.new("TextLabel", Controls)
statusLabel.Size = UDim2.new(0.9, 0, 0, 24)
statusLabel.Text = "🔴 No target"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.LayoutOrder = nextOrder()

local keyHint = Instance.new("TextLabel", Controls)
keyHint.Size = UDim2.new(0.9, 0, 0, 20)
keyHint.Text = "⌨️ Right Control để toggle UI"
keyHint.TextColor3 = Color3.fromRGB(150, 150, 160)
keyHint.BackgroundTransparency = 1
keyHint.Font = Enum.Font.SourceSans
keyHint.TextSize = 11
keyHint.TextXAlignment = Enum.TextXAlignment.Left
keyHint.LayoutOrder = nextOrder()

-- ================================================================
-- CROSSHAIR
-- ================================================================
local crosshair = nil

function updateCrosshair()
    if crosshair then crosshair:Destroy() crosshair = nil end
    if not settings.crosshairEnabled then return end

    local gui = Instance.new("ScreenGui", ScreenGui)
    gui.Name = "Crosshair"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.IgnoreGuiInset = true

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.Position = UDim2.new(0.5, -15, 0.5, -15)
    frame.BackgroundTransparency = 1

    -- Dấu cộng
    local colors = {Color3.fromRGB(0, 255, 0)}
    local function line(w, h, x, y, color)
        local l = Instance.new("Frame", frame)
        l.Size = UDim2.new(0, w, 0, h)
        l.Position = UDim2.new(0, x - w/2, 0, y - h/2)
        l.BackgroundColor3 = color or Color3.fromRGB(0, 255, 0)
        l.BorderSizePixel = 0
        return l
    end
    line(2, 20, 0, 0)
    line(20, 2, 0, 0)

    -- Tâm chấm
    local dot = Instance.new("Frame", frame)
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0, -2, 0, -2)
    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    crosshair = gui
end

-- ================================================================
-- ESP
-- ================================================================
local espObjects = {}

function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    espObjects = {}
end

function updateESP()
    if not settings.espEnabled then
        clearESP()
        return
    end

    -- Xóa esp cũ
    clearESP()

    -- Tạo esp cho từng người chơi
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local char = plr.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and head then
                    -- Box
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(3, 5, 2)
                    box.CFrame = hrp.CFrame * CFrame.new(0, 2.5, 0)
                    box.Color3 = Color3.fromRGB(255, 50, 50)
                    box.Transparency = 0.5
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Adornee = hrp
                    box.Parent = hrp
                    table.insert(espObjects, box)

                    -- Tên + máu + khoảng cách
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0, 200, 0, 50)
                    bill.Adornee = head
                    bill.AlwaysOnTop = true
                    bill.StudsOffset = Vector3.new(0, 2.5, 0)
                    bill.Parent = head

                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Size = UDim2.new(1, 0, 0.5, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = plr.DisplayName
                    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    lbl.TextScaled = true
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextStrokeTransparency = 0.3
                    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                    local health = Instance.new("TextLabel", bill)
                    health.Size = UDim2.new(1, 0, 0.4, 0)
                    health.Position = UDim2.new(0, 0, 0.5, 0)
                    health.BackgroundTransparency = 1
                    health.Text = "❤️ " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                    health.TextColor3 = Color3.fromRGB(255, 200, 100)
                    health.TextScaled = true
                    health.Font = Enum.Font.SourceSans
                    health.TextStrokeTransparency = 0.3
                    health.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

                    table.insert(espObjects, bill)
                end
            end
        end
    end
end

-- Cập nhật ESP mỗi 1s
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(1)
        if settings.espEnabled then
            updateESP()
        end
    end
end)

-- ================================================================
-- AIMBOT ENGINE
-- ================================================================
local function getTargets()
    local targets = {}
    local myChar = LocalPlayer.Character
    if not myChar then return targets end
    local myPos = myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position or Vector3.new(0,0,0)
    local cameraCF = Camera.CFrame

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local head = getTargetPart(plr)
            if head and head.Parent and head.Parent ~= myChar then
                local pos = head.Position
                local dir = (pos - cameraCF.Position).Unit
                local angle = math.deg(math.acos(math.clamp(cameraCF.LookVector:Dot(dir), -1, 1)))
                -- Nếu wallbang thì bỏ qua kiểm tra vật cản
                if settings.wallbang or not settings.wallbang then
                    -- Kiểm tra xuyên tường: raycast
                    local ray = Ray.new(cameraCF.Position, dir * 500)
                    local hit, hitPos = Workspace:FindPartOnRay(ray, myChar)
                    if hit and hitPos then
                        local distToTarget = (pos - hitPos).Magnitude
                        if distToTarget > 5 and not settings.wallbang then
                            -- Có vật cản và không wallbang
                            goto continue
                        end
                    end
                end
                if angle <= settings.fov then
                    local dist = (pos - myPos).Magnitude
                    table.insert(targets, {player=plr, part=head, angle=angle, dist=dist})
                end
                ::continue::
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
-- HOTKEY TOGGLE UI
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
print("🎯 AIMBOT PRO v2.0 loaded — tookit")
print("⌨️  Right Control để toggle UI")
print("📌 Các tính năng: Aimbot, Auto Fire, Wallbang, ESP, Crosshair")
