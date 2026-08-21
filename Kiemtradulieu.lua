-- Script Bảng Tọa Độ Real-time & Cảnh Báo Dịch Chuyển Bất Thường
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Xóa GUI cũ nếu đã tồn tại
if CoreGui:FindFirstChild("CoordTrackerGUI") then
    CoreGui.CoordTrackerGUI:Destroy()
end

-- Dữ liệu lưu trữ tọa độ bất thường
_G.AbnormalLogs = {}

-- KHỞI TẠO TẠO GIAO DIỆN GUI
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "CoordTrackerGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 320, 0, 260)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Có thể kéo thả trên màn hình

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Thanh tiêu đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Text = "  TỌA ĐỘ & BÁO LỖI TP"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- Nút Thoát / Đóng Bảng
local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -33, 0, 2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14

local CloseCorner = Instance.new("UICorner", CloseBtn)
CloseCorner.CornerRadius = UDim.new(0, 6)

-- Khung hiển thị Tọa độ Real-time
local RealtimeText = Instance.new("TextLabel", MainFrame)
RealtimeText.Size = UDim2.new(0.9, 0, 0, 40)
RealtimeText.Position = UDim2.new(0.05, 0, 0.16, 0)
RealtimeText.Text = "X: 0 | Y: 0 | Z: 0"
RealtimeText.TextColor3 = Color3.fromRGB(0, 255, 150)
RealtimeText.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RealtimeText.Font = Enum.Font.Code
RealtimeText.TextSize = 13

local RealtimeCorner = Instance.new("UICorner", RealtimeText)
RealtimeCorner.CornerRadius = UDim.new(0, 6)

-- Khung danh sách Lưu Tọa Độ Bất Thường
local LogScroll = Instance.new("ScrollingFrame", MainFrame)
LogScroll.Size = UDim2.new(0.9, 0, 0, 120)
LogScroll.Position = UDim2.new(0.05, 0, 0.35, 0)
LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 4

local UIList = Instance.new("UIListLayout", LogScroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 3)

-- Nút Mở Lại Bảng (Thu Nhỏ)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 100, 0, 30)
OpenBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
OpenBtn.Text = "Mở Bảng Tọa Độ"
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 12
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true

local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(0, 6)

-- Xử lý nút Đóng / Mở
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- LOGIC CẬP NHẬT TỌA ĐỘ REAL-TIME & THEO DÕI BẤT THƯỜNG
local lastPosition = nil
local TELEPORT_THRESHOLD = 30 -- Khoảng cách biến đổi đột ngột (studs) trong 0.1s coi là bất thường

local function addAbnormalLog(pos, reason)
    local formattedCoord = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
    local timeStr = os.date("%X")
    
    -- Lưu vào mảng
    table.insert(_G.AbnormalLogs, {Time = timeStr, Coord = formattedCoord, Reason = reason})
    
    -- Hiển thị lên UI Log
    local LogLabel = Instance.new("TextLabel", LogScroll)
    LogLabel.Size = UDim2.new(1, -5, 0, 22)
    LogLabel.Text = string.format("[%s] %s: (%s)", timeStr, reason, formattedCoord)
    LogLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    LogLabel.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
    LogLabel.Font = Enum.Font.SourceSans
    LogLabel.TextSize = 11
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local LogLabelCorner = Instance.new("UICorner", LogLabel)
    LogLabelCorner.CornerRadius = UDim.new(0, 4)
    
    -- Cập nhật độ dài thanh cuộn
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, UIList.AbsoluteContentSize.Y)
end

-- Vòng lặp quét vị trí mỗi 0.1 giây
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local currentPos = hrp.Position
            
            -- 1. Cập nhật giao diện Tọa độ Real-time
            RealtimeText.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", currentPos.X, currentPos.Y, currentPos.Z)
            
            -- 2. Kiểm tra sự thay đổi vị trí bất thường
            if lastPosition then
                local distance = (currentPos - lastPosition).Magnitude
                
                -- Nếu khoảng cách di chuyển bất ngờ vượt ngưỡng trong 0.1 giây
                if distance >= TELEPORT_THRESHOLD then
                    addAbnormalLog(currentPos, "TP Bất Thường")
                end
            end
            
            lastPosition = currentPos
        end
    end
end)
