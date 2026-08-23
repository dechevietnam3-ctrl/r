-- ===== toolkit test - Menu dành cho người chơi =====
local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local stats = game:GetService("Stats")

-- Tạo GUI chính
local gui = Instance.new("ScreenGui")
gui.Name = "ToolkitGUI"
gui.Parent = player.PlayerGui

-- ==== Frame chính ====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 540)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -270)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

-- Tiêu đề
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 32)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "toolkit test"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Nút đóng (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Nút thu nhỏ (_)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 32, 0, 32)
minBtn.Position = UDim2.new(1, -72, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(70, 170, 70)
minBtn.Text = "_"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 22
minBtn.Parent = mainFrame

-- Nút khôi phục (hiện khi đã thu nhỏ)
local restoreBtn = Instance.new("TextButton")
restoreBtn.Size = UDim2.new(0, 44, 0, 44)
restoreBtn.Position = UDim2.new(0.92, 0, 0.92, 0)
restoreBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
restoreBtn.Text = "M"
restoreBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
restoreBtn.TextSize = 24
restoreBtn.Visible = false
restoreBtn.Parent = gui

minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    restoreBtn.Visible = true
end)
restoreBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    restoreBtn.Visible = false
end)

-- ==== Vùng chứa các điều khiển (Tab 1) ====
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, 0, 1, -32)
tabContainer.Position = UDim2.new(0, 0, 0, 32)
tabContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
tabContainer.BackgroundTransparency = 0.2
tabContainer.Parent = mainFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -10)
scroll.Position = UDim2.new(0, 5, 0, 5)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 8
scroll.Parent = tabContainer

local canvas = scroll
local yPos = 0

-- ==== Hàm tạo thanh trượt (Slider) ====
local function createSlider(labelText, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 42)
    frame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = canvas
    frame.Position = UDim2.new(0, 0, 0, yPos)
    yPos = yPos + 47

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 110, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 45, 1, 0)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    valueLabel.Parent = frame

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, -170, 0, 10)
    slider.Position = UDim2.new(0, 115, 0.5, -5)
    slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    slider.BorderSizePixel = 0
    slider.Parent = frame

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Parent = slider

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 18, 0, 18)
    button.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -9, 0.5, -9)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = ""
    button.BorderSizePixel = 1
    button.Parent = slider

    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
        local val = minVal + (maxVal - minVal) * pos
        val = math.round(val * 100) / 100
        fill.Size = UDim2.new(pos, 0, 1, 0)
        button.Position = UDim2.new(pos, -9, 0.5, -9)
        valueLabel.Text = tostring(val)
        callback(val)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            dragging = true
        end
    end)
    userInput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)

    return frame, function() return tonumber(valueLabel.Text) end -- lấy giá trị hiện tại
end

-- ==== Hàm tạo nút bật/tắt (Toggle) ====
local function createToggle(labelText, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 34)
    frame.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = canvas
    frame.Position = UDim2.new(0, 0, 0, yPos)
    yPos = yPos + 39

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 150, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 65, 0, 24)
    toggleBtn.Position = UDim2.new(1, -70, 0.5, -12)
    toggleBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggleBtn.Text = defaultState and "ON" or "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 13
    toggleBtn.Parent = frame

    local state = defaultState
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleBtn.Text = state and "ON" or "OFF"
        callback(state)
    end)

    return frame, function() return state end
end

-- ==== Biến lưu giá trị hiện tại (để áp dụng khi nhân vật mới) ====
local currentSpeed = 16
local currentJump = 50
local currentBrightness = 2
local currentHitbox = 1

-- ==== TẠO CÁC ĐIỀU KHIỂN ====

-- 1. Tốc độ
local speedSlider, getSpeed = createSlider("Tốc độ", 0, 100, 16, function(val)
    currentSpeed = val
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = val
    end
end)

-- 2. Độ nhảy
local jumpSlider, getJump = createSlider("Độ nhảy", 0, 100, 50, function(val)
    currentJump = val
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = val
    end
end)

-- 3. Độ sáng (Lighting)
createSlider("Độ sáng", 0, 10, 2, function(val)
    currentBrightness = val
    game.Lighting.Brightness = val
end)

-- 4. Fly (bật/tắt)
local flyEnabled = false
local flyConnection = nil
local flyBodyVel = nil
local flyBodyGyro = nil

createToggle("Fly", false, function(state)
    flyEnabled = state
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end

    if state then
        -- Tạo BodyVelocity và BodyGyro để điều khiển bay
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBodyVel.Velocity = Vector3.new(0, 0, 0)
        flyBodyVel.Parent = char

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBodyGyro.CFrame = char.HumanoidRootPart.CFrame
        flyBodyGyro.Parent = char

        humanoid.PlatformStand = true

        -- Cập nhật vận tốc mỗi frame
        flyConnection = runService.Heartbeat:Connect(function()
            if not flyEnabled or not char or not char.Parent then
                -- Tự tắt nếu mất nhân vật
                return
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local moveDir = humanoid.MoveDirection
            local speed = 50
            local vel = moveDir * speed
            if userInput:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, speed, 0)
            end
            if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then
                vel = vel + Vector3.new(0, -speed, 0)
            end
            flyBodyVel.Velocity = vel
            flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + hrp.CFrame.LookVector)
        end)
    else
        -- Tắt bay
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        humanoid.PlatformStand = false
    end
end)

-- 5. Hitbox người chơi (tỉ lệ kích thước)
local hitboxSlider, getHitbox = createSlider("Hitbox người chơi", 0.5, 3, 1, function(val)
    currentHitbox = val
    local char = player.Character
    if char then
        -- Lưu kích thước gốc nếu chưa có
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not part:FindFirstChild("OriginalSize") then
                local orig = Instance.new("Vector3Value")
                orig.Name = "OriginalSize"
                orig.Value = part.Size
                orig.Parent = part
            end
        end
        -- Áp dụng tỉ lệ
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part:FindFirstChild("OriginalSize") then
                local origSize = part.OriginalSize.Value
                part.Size = origSize * val
            end
        end
    end
end)

-- 6. NPC (tạo/xoá)
createToggle("NPC", false, function(state)
    if state then
        -- Tạo NPC đơn giản
        local npc = Instance.new("Model")
        npc.Name = "TestNPC"
        local hrp = Instance.new("Part")
        hrp.Name = "HumanoidRootPart"
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Position = player.Character and player.Character.HumanoidRootPart.Position + Vector3.new(6, 0, 0) or Vector3.new(0, 5, 0)
        hrp.Anchored = false
        hrp.Parent = npc
        local humanoid = Instance.new("Humanoid")
        humanoid.Parent = npc
        npc.Parent = workspace
    else
        local npc = workspace:FindFirstChild("TestNPC")
        if npc then npc:Destroy() end
    end
end)

-- 7. ESP (bật/tắt cho người chơi khác và NPC)
local espActive = false
local espHighlights = {}

local function addESP(obj, color)
    for _, part in ipairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then
            local hl = Instance.new("Highlight")
            hl.FillColor = color or Color3.fromRGB(255, 0, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.Parent = part
            table.insert(espHighlights, hl)
        end
    end
end

local function clearESP()
    for _, hl in ipairs(espHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    espHighlights = {}
end

createToggle("ESP", false, function(state)
    espActive = state
    clearESP()
    if state then
        -- ESP cho người chơi khác
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                addESP(plr.Character, Color3.fromRGB(255, 50, 50))
            end
        end
        -- ESP cho NPC nếu có
        local npc = workspace:FindFirstChild("TestNPC")
        if npc then
            addESP(npc, Color3.fromRGB(50, 255, 50))
        end
        -- Theo dõi người chơi mới vào
        game.Players.PlayerAdded:Connect(function(plr)
            if espActive then
                plr.CharacterAdded:Connect(function(char)
                    if espActive and plr ~= player then
                        addESP(char, Color3.fromRGB(255, 50, 50))
                    end
                end)
            end
        end)
    end
end)

-- 8. Thông số game (FPS, Ping)
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 0, 30)
infoLabel.Position = UDim2.new(0, 0, 0, yPos)
yPos = yPos + 35
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "FPS: 0  |  Ping: 0 ms"
infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infoLabel.TextSize = 14
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.Parent = canvas

local frameCount = 0
local lastTime = tick()
runService.Heartbeat:Connect(function(delta)
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        local fps = math.round(frameCount / (now - lastTime))
        frameCount = 0
        lastTime = now
        local ping = stats.Network.ServerStatsItem.DataPing:GetValueString() or "0"
        infoLabel.Text = "FPS: " .. tostring(fps) .. "  |  Ping: " .. ping .. " ms"
    end
end)

-- Cập nhật CanvasSize
scroll.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)

-- ==== Xử lý khi nhân vật mới xuất hiện ====
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = currentSpeed
        humanoid.JumpPower = currentJump
        -- Áp dụng hitbox
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not part:FindFirstChild("OriginalSize") then
                local orig = Instance.new("Vector3Value")
                orig.Name = "OriginalSize"
                orig.Value = part.Size
                orig.Parent = part
            end
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part:FindFirstChild("OriginalSize") then
                part.Size = part.OriginalSize.Value * currentHitbox
            end
        end
    end
end)

-- Nếu đang bay mà nhân vật mới, khởi tạo lại fly
player.CharacterAdded:Connect(function(char)
    if flyEnabled then
        wait(0.5)
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBodyVel.Velocity = Vector3.new(0, 0, 0)
            flyBodyVel.Parent = char

            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyBodyGyro.CFrame = char.HumanoidRootPart.CFrame
            flyBodyGyro.Parent = char

            humanoid.PlatformStand = true
            if not flyConnection then
                flyConnection = runService.Heartbeat:Connect(function()
                    if not flyEnabled or not char or not char.Parent then return end
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local moveDir = humanoid.MoveDirection
                    local speed = 50
                    local vel = moveDir * speed
                    if userInput:IsKeyDown(Enum.KeyCode.Space) then
                        vel = vel + Vector3.new(0, speed, 0)
                    end
                    if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then
                        vel = vel + Vector3.new(0, -speed, 0)
                    end
                    flyBodyVel.Velocity = vel
                    flyBodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + hrp.CFrame.LookVector)
                end)
            end
        end
    end
end)

print("toolkit test GUI đã sẵn sàng!")
