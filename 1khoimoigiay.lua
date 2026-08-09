-- Script Auto PlaceBlock + Menu Bật/Tắt (Nhân bản luồng)
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local placeBlockRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlaceBlock")

-- Xóa Menu cũ nếu đã tồn tại
if CoreGui:FindFirstChild("PlaceBlockMenu") then
    CoreGui.PlaceBlockMenu:Destroy()
end

_G.AutoPlaceBlock = false

-- Khởi tạo UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaceBlockMenu"
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AUTO PLACE BLOCK"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.45, 0)
ToggleBtn.Text = "Auto Place: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- Hàm xử lý Auto nhân bản
local function startAuto()
    task.spawn(function()
        while _G.AutoPlaceBlock do
            -- Tạo 1 luồng gửi PlaceBlock liên tục
            task.spawn(function()
                while _G.AutoPlaceBlock do
                    placeBlockRemote:FireServer()
                    task.wait()
                end
            end)
            task.wait(1) -- Cứ mỗi 1s nhân bản thêm 1 luồng
        end
    end)
end

-- Sự kiện bấm nút
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoPlaceBlock = not _G.AutoPlaceBlock
    if _G.AutoPlaceBlock then
        ToggleBtn.Text = "Auto Place: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        startAuto()
    else
        ToggleBtn.Text = "Auto Place: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)
