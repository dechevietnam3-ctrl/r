-- Menu Auto Orb & Gem (Gộp 2 trong 1)
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local orbRemote = ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("orbEvent")

-- Tránh tạo trùng Menu nếu chạy lại script
if CoreGui:FindFirstChild("OrbGemMenu") then
    CoreGui.OrbGemMenu:Destroy()
end

-- Trạng thái Auto
_G.AutoBlueOrb = false
_G.AutoGem = false

-- Khởi tạo UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrbGemMenu"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 180)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true -- Có thể kéo di chuyển menu
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "AUTO FARM MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Hàm xử lý Auto Blue Orb
local function runBlueOrb()
    task.spawn(function()
        while _G.AutoBlueOrb do
            task.spawn(function()
                while _G.AutoBlueOrb do
                    orbRemote:FireServer("collectOrb", "Blue Orb", "City")
                    task.wait()
                end
            end)
            task.wait(1)
        end
    end)
end

-- Hàm xử lý Auto Gem
local function runGem()
    task.spawn(function()
        while _G.AutoGem do
            task.spawn(function()
                while _G.AutoGem do
                    orbRemote:FireServer("collectOrb", "Gem", "City")
                    task.wait()
                end
            end)
            task.wait(1)
        end
    end)
end

-- Nút Bật/Tắt Blue Orb
local BtnBlue = Instance.new("TextButton")
BtnBlue.Size = UDim2.new(0.85, 0, 0, 35)
BtnBlue.Position = UDim2.new(0.075, 0, 0.28, 0)
BtnBlue.Text = "Auto Blue Orb: OFF"
BtnBlue.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BtnBlue.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnBlue.Font = Enum.Font.SourceSansBold
BtnBlue.TextSize = 14
BtnBlue.Parent = Frame

local BtnBlueCorner = Instance.new("UICorner")
BtnBlueCorner.CornerRadius = UDim.new(0, 6)
BtnBlueCorner.Parent = BtnBlue

BtnBlue.MouseButton1Click:Connect(function()
    _G.AutoBlueOrb = not _G.AutoBlueOrb
    if _G.AutoBlueOrb then
        BtnBlue.Text = "Auto Blue Orb: ON"
        BtnBlue.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        runBlueOrb()
    else
        BtnBlue.Text = "Auto Blue Orb: OFF"
        BtnBlue.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- Nút Bật/Tắt Gem
local BtnGem = Instance.new("TextButton")
BtnGem.Size = UDim2.new(0.85, 0, 0, 35)
BtnGem.Position = UDim2.new(0.075, 0, 0.58, 0)
BtnGem.Text = "Auto Gem: OFF"
BtnGem.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BtnGem.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnGem.Font = Enum.Font.SourceSansBold
BtnGem.TextSize = 14
BtnGem.Parent = Frame

local BtnGemCorner = Instance.new("UICorner")
BtnGemCorner.CornerRadius = UDim.new(0, 6)
BtnGemCorner.Parent = BtnGem

BtnGem.MouseButton1Click:Connect(function()
    _G.AutoGem = not _G.AutoGem
    if _G.AutoGem then
        BtnGem.Text = "Auto Gem: ON"
        BtnGem.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        runGem()
    else
        BtnGem.Text = "Auto Gem: OFF"
        BtnGem.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)
