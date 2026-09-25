--[[
    🚂 TOOKIT DEAD RAILS HUB v1.0
    ------------------------------------
    Tổng hợp các tính năng hack & khám phá phổ biến nhất cho game Dead Rails.
    Sử dụng: Copy toàn bộ script -> Dán vào executor -> Execute.
    Nhấn Right Control để ẩn/hiện menu.
--]]

-- == SERVICES ==
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- == CONFIG & STATE ==
local CONFIG = {
    -- Combat
    KillAura = false,
    Aimbot = false,
    -- Automation
    AutoFarm = false,
    AutoWin = false,
    -- Visuals
    PlayerESP = false,
    ZombieESP = false,
    ItemESP = false,
    -- Movement
    SpeedHack = false,
    Fly = false,
    Noclip = false,
    -- Utility
    FullBright = false,
    NoFog = false,
}
local State = {
    OriginalSpeed = 16,
    FlySpeed = 50,
    AuraRange = 30,
    ESPObjects = {},
    Connections = {},
}

-- == UTILITY FUNCTIONS ==
local function getCharacter()
    return LocalPlayer.Character
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function log(msg)
    if UI and UI.StatusLabel then
        UI.StatusLabel.Text = msg
    end
    print("[DeadRailsHub] " .. msg)
end

-- == CLEANUP ==
local function cleanup()
    for _, conn in ipairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    State.Connections = {}
    for _, obj in pairs(State.ESPObjects) do
        if obj and obj.Parent then obj:Destroy() end
    end
    State.ESPObjects = {}
    -- Reset state
    for k, v in pairs(CONFIG) do CONFIG[k] = false end
    local hum = getCharacter() and getCharacter():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = State.OriginalSpeed end
    log("Đã dọn dẹp và tắt tất cả tính năng.")
end

-- == ESP FUNCTIONS ==
local function createESP(object, color, text)
    if not object or not object.Parent then return end
    if State.ESPObjects[object] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = object
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text or object.Name
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    billboard.Parent = object
    State.ESPObjects[object] = billboard
end

local function updateESP()
    -- Clear old
    for obj, gui in pairs(State.ESPObjects) do
        if not obj or not obj.Parent then
            gui:Destroy()
            State.ESPObjects[obj] = nil
        end
    end

    if CONFIG.PlayerESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    createESP(hrp, Color3.fromRGB(0, 255, 255), player.Name)
                end
            end
        end
    end

    if CONFIG.ZombieESP then
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                if hrp then
                    createESP(hrp, Color3.fromRGB(255, 50, 50), "ZOMBIE: " .. model.Name)
                end
            end
        end
    end

    if CONFIG.ItemESP then
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("Tool") or (item:IsA("Model") and item.Name:lower():find("bag")) then
                createESP(item, Color3.fromRGB(255, 255, 0), "ITEM: " .. item.Name)
            end
        end
    end
end

-- == MOVEMENT FUNCTIONS ==
local function updateMovement()
    local char = getCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = getHRP()
    if not hum or not hrp then return end

    -- Speed Hack
    if CONFIG.SpeedHack then
        hum.WalkSpeed = 100 -- Tốc độ hack
    else
        hum.WalkSpeed = State.OriginalSpeed
    end

    -- Fly
    if CONFIG.Fly then
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - workspace.CurrentCamera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + workspace.CurrentCamera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        if moveDir.Magnitude > 0 then
            hrp.Velocity = moveDir.Unit * State.FlySpeed
        else
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end

    -- Noclip
    if CONFIG.Noclip then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- == COMBAT FUNCTIONS ==
local function updateCombat()
    local char = getCharacter()
    if not char then return end
    local myHRP = getHRP()
    if not myHRP then return end

    -- Kill Aura (Melee)
    if CONFIG.KillAura then
        for _, model in ipairs(Workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then
                local targetHRP = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                if targetHRP and (targetHRP.Position - myHRP.Position).Magnitude <= State.AuraRange then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        -- Đây là cách tấn công đơn giản, có thể không hoạt động tùy game
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        if tool and tool:FindFirstChild("Handle") then
                            tool:Activate()
                        end
                    end
                end
            end
        end
    end
end

-- == AUTOMATION FUNCTIONS ==
local function updateAutomation()
    if CONFIG.AutoFarm then
        -- Logic Auto Farm: ví dụ tự động thu thập vật phẩm gần đó
        local char = getCharacter()
        local hrp = getHRP()
        if hrp then
            for _, item in ipairs(Workspace:GetDescendants()) do
                if item:IsA("Tool") and not item.Parent:IsA("Model") then
                    if (item.Position - hrp.Position).Magnitude < 20 then
                        item.Parent = LocalPlayer.Backpack -- Tự động nhặt
                    end
                end
            end
        end
    end

    if CONFIG.AutoWin then
        -- Logic Auto Win: ví dụ kích hoạt các sự kiện kết thúc
        -- Cần tìm hiểu RemoteEvent của game để kích hoạt
        -- Ví dụ: game.ReplicatedStorage.EndRound:FireServer()
    end
end

-- == VISUAL FUNCTIONS ==
local function updateVisuals()
    if CONFIG.FullBright then
        game.Lighting.Ambient = Color3.new(1, 1, 1)
        game.Lighting.Brightness = 3
        game.Lighting.ClockTime = 12
        game.Lighting.FogEnd = 100000
    else
        game.Lighting.Ambient = Color3.new(0.1, 0.1, 0.1)
        game.Lighting.Brightness = 1
        game.Lighting.FogEnd = 1000
    end

    if CONFIG.NoFog then
        game.Lighting.FogEnd = 100000
    else
        game.Lighting.FogEnd = 1000
    end
end

-- == MAIN UPDATE LOOP ==
task.spawn(function()
    while task.wait(0.1) do
        pcall(updateESP)
        pcall(updateMovement)
        pcall(updateCombat)
        pcall(updateAutomation)
        pcall(updateVisuals)
    end
end)

-- == UI CREATION (Sử dụng Rayfield UI) ==
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🚂 TOOKIT DEAD RAILS HUB",
   LoadingTitle = "Đang tải script...",
   LoadingSubtitle = "by TOOKIT",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

-- Combat Tab
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
CombatTab:CreateToggle({
   Name = "Kill Aura (Melee)",
   CurrentValue = false,
   Flag = "KillAura",
   Callback = function(Value) CONFIG.KillAura = Value end,
})
CombatTab:CreateToggle({
   Name = "Gun Aura / Aimbot",
   CurrentValue = false,
   Flag = "Aimbot",
   Callback = function(Value) CONFIG.Aimbot = Value end,
})

-- Automation Tab
local AutoTab = Window:CreateTab("🤖 Automation", 4483362458)
AutoTab:CreateToggle({
   Name = "Auto Farm Bonds",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value) CONFIG.AutoFarm = Value end,
})
AutoTab:CreateToggle({
   Name = "Auto Win",
   CurrentValue = false,
   Flag = "AutoWin",
   Callback = function(Value) CONFIG.AutoWin = Value end,
})

-- Visuals Tab
local VisualTab = Window:CreateTab("👁️ Visuals", 4483362458)
VisualTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(Value) CONFIG.PlayerESP = Value end,
})
VisualTab:CreateToggle({
   Name = "Zombie ESP",
   CurrentValue = false,
   Flag = "ZombieESP",
   Callback = function(Value) CONFIG.ZombieESP = Value end,
})
VisualTab:CreateToggle({
   Name = "Item ESP",
   CurrentValue = false,
   Flag = "ItemESP",
   Callback = function(Value) CONFIG.ItemESP = Value end,
})
VisualTab:CreateToggle({
   Name = "Full Bright",
   CurrentValue = false,
   Flag = "FullBright",
   Callback = function(Value) CONFIG.FullBright = Value end,
})
VisualTab:CreateToggle({
   Name = "No Fog",
   CurrentValue = false,
   Flag = "NoFog",
   Callback = function(Value) CONFIG.NoFog = Value end,
})

-- Movement Tab
local MoveTab = Window:CreateTab("🏃 Movement", 4483362458)
MoveTab:CreateToggle({
   Name = "Speed Hack",
   CurrentValue = false,
   Flag = "SpeedHack",
   Callback = function(Value) CONFIG.SpeedHack = Value end,
})
MoveTab:CreateSlider({
   Name = "Fly Speed",
   Range = {10, 200},
   Increment = 1,
   Suffix = "studs/s",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value) State.FlySpeed = Value end,
})
MoveTab:CreateToggle({
   Name = "Fly (WASD + Space)",
   CurrentValue = false,
   Flag = "Fly",
   Callback = function(Value) 
       CONFIG.Fly = Value 
       local hrp = getHRP()
       if hrp then hrp.Velocity = Vector3.new(0,0,0) end
   end,
})
MoveTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value) CONFIG.Noclip = Value end,
})

-- Utility Tab
local UtilTab = Window:CreateTab("🛠️ Utility", 4483362458)
UtilTab:CreateButton({
   Name = "Teleport To Train",
   Callback = function()
       -- Cần tìm object của tàu trong workspace
       local train = Workspace:FindFirstChild("Train") or Workspace:FindFirstChild("Engine")
       local hrp = getHRP()
       if train and hrp then
           hrp.CFrame = train.CFrame * CFrame.new(0, 5, 0)
           log("Đã dịch chuyển đến Tàu")
       else
           log("Không tìm thấy Tàu.")
       end
   end,
})
UtilTab:CreateButton({
   Name = "Dọn dẹp & Tắt tất cả",
   Callback = function()
       cleanup()
       Rayfield:Notify({Title = "TOOKIT Hub", Content = "Đã tắt tất cả tính năng và dọn dẹp.", Duration = 3})
   end,
})

-- Hotkey to toggle UI
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        Rayfield:Toggle() -- Rayfield có hàm toggle
    end
end)

-- Load notification
Rayfield:Notify({
   Title = "🚂 TOOKIT DEAD RAILS HUB",
   Content = "Script đã tải thành công! Nhấn Right Control để mở menu.",
   Duration = 5,
   Image = 4483362458,
})

log("Script đã sẵn sàng!")
