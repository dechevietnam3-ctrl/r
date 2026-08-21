-- Script Bảng Tọa Độ Real-time & Cảnh Báo Dịch Chuyển + Theo Dõi NPC
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Xóa GUI cũ nếu đã tồn tại
if CoreGui:FindFirstChild("CoordTrackerGUI") then
    CoreGui.CoordTrackerGUI:Destroy()
end

-- Dữ liệu lưu trữ tọa độ bất thường và NPC spawn
_G.AbnormalLogs = {}
_G.NPCSpawnLogs = {}

-- ======= KHỞI TẠO GIAO DIỆN =======
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "CoordTrackerGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 360, 0, 480) -- Tăng chiều cao
MainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Thanh tiêu đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Text = "  TỌA ĐỘ & BÁO LỖI TP + NPC"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- Nút đóng
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

-- Nút mở lại (thu nhỏ)
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 120, 0, 30)
OpenBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
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

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- ==== Khu vực hiển thị tọa độ real-time ====
local RealtimeText = Instance.new("TextLabel", MainFrame)
RealtimeText.Size = UDim2.new(0.9, 0, 0, 35)
RealtimeText.Position = UDim2.new(0.05, 0, 0.09, 0)
RealtimeText.Text = "X: 0 | Y: 0 | Z: 0"
RealtimeText.TextColor3 = Color3.fromRGB(0, 255, 150)
RealtimeText.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RealtimeText.Font = Enum.Font.Code
RealtimeText.TextSize = 13
local RealtimeCorner = Instance.new("UICorner", RealtimeText)
RealtimeCorner.CornerRadius = UDim.new(0, 6)

-- ==== Khung log TP bất thường ====
local LogScroll = Instance.new("ScrollingFrame", MainFrame)
LogScroll.Size = UDim2.new(0.9, 0, 0, 90)
LogScroll.Position = UDim2.new(0.05, 0, 0.19, 0)
LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 4
local UIList = Instance.new("UIListLayout", LogScroll)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 3)

-- ==== KHUNG NPC XUNG QUANH ====
local NPCTitle = Instance.new("TextLabel", MainFrame)
NPCTitle.Size = UDim2.new(0.9, 0, 0, 22)
NPCTitle.Position = UDim2.new(0.05, 0, 0.42, 0)
NPCTitle.Text = "🟢 NPC xung quanh (cập nhật 0.5s)"
NPCTitle.TextColor3 = Color3.fromRGB(200, 255, 200)
NPCTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
NPCTitle.Font = Enum.Font.SourceSansBold
NPCTitle.TextSize = 12
NPCTitle.TextXAlignment = Enum.TextXAlignment.Left

local NPCScroll = Instance.new("ScrollingFrame", MainFrame)
NPCScroll.Size = UDim2.new(0.9, 0, 0, 100)
NPCScroll.Position = UDim2.new(0.05, 0, 0.48, 0)
NPCScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
NPCScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
NPCScroll.ScrollBarThickness = 4
local NPCListLayout = Instance.new("UIListLayout", NPCScroll)
NPCListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NPCListLayout.Padding = UDim.new(0, 2)

-- ==== KHUNG LOG SPAWN NPC ====
local SpawnTitle = Instance.new("TextLabel", MainFrame)
SpawnTitle.Size = UDim2.new(0.9, 0, 0, 22)
SpawnTitle.Position = UDim2.new(0.05, 0, 0.7, 0)
SpawnTitle.Text = "🟡 NPC vừa spawn (log)"
SpawnTitle.TextColor3 = Color3.fromRGB(255, 255, 150)
SpawnTitle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SpawnTitle.Font = Enum.Font.SourceSansBold
SpawnTitle.TextSize = 12
SpawnTitle.TextXAlignment = Enum.TextXAlignment.Left

local SpawnScroll = Instance.new("ScrollingFrame", MainFrame)
SpawnScroll.Size = UDim2.new(0.9, 0, 0, 80)
SpawnScroll.Position = UDim2.new(0.05, 0, 0.76, 0)
SpawnScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SpawnScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SpawnScroll.ScrollBarThickness = 4
local SpawnListLayout = Instance.new("UIListLayout", SpawnScroll)
SpawnListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SpawnListLayout.Padding = UDim.new(0, 2)

-- ==== Nút EXPORT DỮ LIỆU (tọa độ NPC + log) ====
local ExportBtn = Instance.new("TextButton", MainFrame)
ExportBtn.Size = UDim2.new(0.3, 0, 0, 25)
ExportBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
ExportBtn.Text = "📋 Xuất Data"
ExportBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
ExportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExportBtn.Font = Enum.Font.SourceSansBold
ExportBtn.TextSize = 12
local ExportCorner = Instance.new("UICorner", ExportBtn)
ExportCorner.CornerRadius = UDim.new(0, 6)

-- ---- HÀM XUẤT DỮ LIỆU ----
ExportBtn.MouseButton1Click:Connect(function()
    local data = {
        AbnormalLogs = _G.AbnormalLogs,
        NPCSpawnLogs = _G.NPCSpawnLogs,
        Timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }
    local json = HttpService:JSONEncode(data)
    -- Sao chép ra clipboard (nếu executor hỗ trợ)
    pcall(function()
        setclipboard(json)
        print("✅ Đã sao chép dữ liệu JSON ra clipboard!")
    end)
    -- In ra console để xem
    print("===== DỮ LIỆU XUẤT =====")
    print(json)
    print("Số lượng log TP: " .. #_G.AbnormalLogs)
    print("Số lượng log spawn NPC: " .. #_G.NPCSpawnLogs)
end)

-- ======= LOGIC THEO DÕI =======

-- 1. Theo dõi TP bất thường (giữ nguyên)
local lastPosition = nil
local TELEPORT_THRESHOLD = 30

local function addAbnormalLog(pos, reason)
    local formattedCoord = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
    local timeStr = os.date("%X")
    table.insert(_G.AbnormalLogs, {Time = timeStr, Coord = formattedCoord, Reason = reason})
    
    local LogLabel = Instance.new("TextLabel", LogScroll)
    LogLabel.Size = UDim2.new(1, -5, 0, 22)
    LogLabel.Text = string.format("[%s] %s: (%s)", timeStr, reason, formattedCoord)
    LogLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    LogLabel.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
    LogLabel.Font = Enum.Font.SourceSans
    LogLabel.TextSize = 11
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    local corner = Instance.new("UICorner", LogLabel)
    corner.CornerRadius = UDim.new(0, 4)
    
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y)
    LogScroll.CanvasPosition = Vector2.new(0, UIList.AbsoluteContentSize.Y)
end

-- Vòng lặp cập nhật tọa độ và phát hiện TP
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local currentPos = hrp.Position
            RealtimeText.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", currentPos.X, currentPos.Y, currentPos.Z)
            
            if lastPosition then
                local distance = (currentPos - lastPosition).Magnitude
                if distance >= TELEPORT_THRESHOLD then
                    addAbnormalLog(currentPos, "TP Bất Thường")
                end
            end
            lastPosition = currentPos
        end
    end
end)

-- Reset lastPosition khi respawn
LocalPlayer.CharacterAdded:Connect(function()
    lastPosition = nil
end)

-- 2. Theo dõi NPC xung quanh (cập nhật danh sách)
local function isNPC(model)
    if not model:IsA("Model") then return false end
    if model == LocalPlayer.Character then return false end
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then return false end
    -- Kiểm tra xem model có phải là character của player nào không
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    return true
end

local function updateNPCList()
    -- Xóa các label cũ (giữ layout)
    for _, child in ipairs(NPCScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    for _, obj in ipairs(Workspace:GetChildren()) do
        if isNPC(obj) then
            local humanoid = obj:FindFirstChild("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if humanoid and hrp and humanoid.Health > 0 then
                local pos = hrp.Position
                local name = obj.Name
                local health = math.floor(humanoid.Health)
                local label = Instance.new("TextLabel", NPCScroll)
                label.Size = UDim2.new(1, -5, 0, 20)
                label.Text = string.format("%s | HP:%d | X:%.1f Y:%.1f Z:%.1f", name, health, pos.X, pos.Y, pos.Z)
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
                label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                label.Font = Enum.Font.SourceSans
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                local corner = Instance.new("UICorner", label)
                corner.CornerRadius = UDim.new(0, 3)
            end
        end
    end
    
    NPCScroll.CanvasSize = UDim2.new(0, 0, 0, NPCListLayout.AbsoluteContentSize.Y)
end

-- Cập nhật danh sách NPC mỗi 0.5 giây
task.spawn(function()
    while task.wait(0.5) do
        updateNPCList()
    end
end)

-- 3. Phát hiện NPC mới spawn
workspace.ChildAdded:Connect(function(child)
    if isNPC(child) then
        local hrp = child:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            local timeStr = os.date("%X")
            local coordStr = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
            table.insert(_G.NPCSpawnLogs, {Time = timeStr, Name = child.Name, Coord = coordStr})
            
            local label = Instance.new("TextLabel", SpawnScroll)
            label.Size = UDim2.new(1, -5, 0, 18)
            label.Text = string.format("[%s] %s spawn tại (%s)", timeStr, child.Name, coordStr)
            label.TextColor3 = Color3.fromRGB(100, 255, 100)
            label.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
            label.Font = Enum.Font.SourceSans
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            local corner = Instance.new("UICorner", label)
            corner.CornerRadius = UDim.new(0, 3)
            
            SpawnScroll.CanvasSize = UDim2.new(0, 0, 0, SpawnListLayout.AbsoluteContentSize.Y)
            SpawnScroll.CanvasPosition = Vector2.new(0, SpawnListLayout.AbsoluteContentSize.Y)
        end
    end
end)

-- Khởi tạo danh sách NPC ban đầu
task.wait(1)
updateNPCList()
