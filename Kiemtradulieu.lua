-- Script Tích Hợp: Tracker Tọa Độ Bất Thường & NPC Tracker
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Xóa GUI cũ nếu tồn tại
if CoreGui:FindFirstChild("AbnormalTrackerGUI") then
    CoreGui.AbnormalTrackerGUI:Destroy()
end

_G.AutoLock = false
local lockTargetPos = Vector3.new(0, 0, 0)
local npcSpawnPositions = {}

-- KHỞI TẠO GUI CHÍNH
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "AbnormalTrackerGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 380, 0, 330)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Thanh Tiêu Đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Text = "  TRACKER TỌA ĐỘ BẤT THƯỜNG & NPC"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- Nút Đóng
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

-- THANH TAB
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(0.92, 0, 0, 30)
TabFrame.Position = UDim2.new(0.04, 0, 0.12, 0)
TabFrame.BackgroundTransparency = 1

local Tab1Btn = Instance.new("TextButton", TabFrame)
Tab1Btn.Size = UDim2.new(0.48, 0, 1, 0)
Tab1Btn.Text = "Log Tọa Độ Bất Thường"
Tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab1Btn.Font = Enum.Font.SourceSansBold
Tab1Btn.TextSize = 11

local Tab1Corner = Instance.new("UICorner", Tab1Btn)
Tab1Corner.CornerRadius = UDim.new(0, 5)

local Tab2Btn = Instance.new("TextButton", TabFrame)
Tab2Btn.Size = UDim2.new(0.48, 0, 1, 0)
Tab2Btn.Position = UDim2.new(0.52, 0, 0, 0)
Tab2Btn.Text = "Danh Sách NPC"
Tab2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Tab2Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
Tab2Btn.Font = Enum.Font.SourceSansBold
Tab2Btn.TextSize = 11

local Tab2Corner = Instance.new("UICorner", Tab2Btn)
Tab2Corner.CornerRadius = UDim.new(0, 5)

-- PAGES
local Page1 = Instance.new("Frame", MainFrame) -- Tab Log Bất Thường
Page1.Size = UDim2.new(0.92, 0, 0.74, 0)
Page1.Position = UDim2.new(0.04, 0, 0.23, 0)
Page1.BackgroundTransparency = 1

local Page2 = Instance.new("Frame", MainFrame) -- Tab NPC Tracker
Page2.Size = UDim2.new(0.92, 0, 0.74, 0)
Page2.Position = UDim2.new(0.04, 0, 0.23, 0)
Page2.BackgroundTransparency = 1
Page2.Visible = false

Tab1Btn.MouseButton1Click:Connect(function()
    Page1.Visible = true; Page2.Visible = false
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

Tab2Btn.MouseButton1Click:Connect(function()
    Page1.Visible = false; Page2.Visible = true
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

---------------------------------------------------------
-- TAB 1: HIỂN THỊ LOG TỌA ĐỘ BẤT THƯỜNG
---------------------------------------------------------
local RealtimeText = Instance.new("TextLabel", Page1)
RealtimeText.Size = UDim2.new(1, 0, 0, 25)
RealtimeText.Text = "Tọa độ hiện tại: 0, 0, 0"
RealtimeText.TextColor3 = Color3.fromRGB(0, 255, 150)
RealtimeText.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RealtimeText.Font = Enum.Font.Code
RealtimeText.TextSize = 10

local RealtimeCorner = Instance.new("UICorner", RealtimeText)
RealtimeCorner.CornerRadius = UDim.new(0, 4)

local LogScroll = Instance.new("ScrollingFrame", Page1)
LogScroll.Size = UDim2.new(1, 0, 0, 170)
LogScroll.Position = UDim2.new(0, 0, 0.14, 0)
LogScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 4

local LogUIList = Instance.new("UIListLayout", LogScroll)
LogUIList.SortOrder = Enum.SortOrder.LayoutOrder
LogUIList.Padding = UDim.new(0, 4)

local LockToggleBtn = Instance.new("TextButton", Page1)
LockToggleBtn.Size = UDim2.new(1, 0, 0, 28)
LockToggleBtn.Position = UDim2.new(0, 0, 0.88, 0)
LockToggleBtn.Text = "Khóa Vị Trí Vừa Chọn: OFF"
LockToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
LockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockToggleBtn.Font = Enum.Font.SourceSansBold
LockToggleBtn.TextSize = 11

local LockCorner = Instance.new("UICorner", LockToggleBtn)
LockCorner.CornerRadius = UDim.new(0, 4)

---------------------------------------------------------
-- TAB 2: NPC TRACKER
---------------------------------------------------------
local NPCScroll = Instance.new("ScrollingFrame", Page2)
NPCScroll.Size = UDim2.new(1, 0, 1, 0)
NPCScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
NPCScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
NPCScroll.ScrollBarThickness = 4

local NPCUIList = Instance.new("UIListLayout", NPCScroll)
NPCUIList.SortOrder = Enum.SortOrder.LayoutOrder
NPCUIList.Padding = UDim.new(0, 5)

-- NÚT THU NHỎ
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 110, 0, 30)
OpenBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
OpenBtn.Text = "Mở Tracker"
OpenBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.TextSize = 12
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true

local OpenCorner = Instance.new("UICorner", OpenBtn)
OpenCorner.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)

---------------------------------------------------------
-- LOGIC BẮT DỊCH CHUYỂN BẤT THƯỜNG
---------------------------------------------------------
local function teleportTo(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

LockToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoLock = not _G.AutoLock
    if _G.AutoLock then
        LockToggleBtn.Text = "Khóa Vị Trí Vừa Chọn: ON"
        LockToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    else
        LockToggleBtn.Text = "Khóa Vị Trí Vừa Chọn: OFF"
        LockToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

RunService.Stepped:Connect(function()
    if _G.AutoLock then teleportTo(lockTargetPos) end
end)

-- Ghi log dịch chuyển bất thường
local function addAbnormalLog(fromPos, toPos)
    local timeStr = os.date("%X")
    local fromStr = string.format("%.1f, %.1f, %.1f", fromPos.X, fromPos.Y, fromPos.Z)
    local toStr = string.format("%.1f, %.1f, %.1f", toPos.X, toPos.Y, toPos.Z)
    local copyText = string.format("[%s] Từ: (%s) -> Đến: (%s)", timeStr, fromStr, toStr)

    local ItemFrame = Instance.new("Frame", LogScroll)
    ItemFrame.Size = UDim2.new(1, -5, 0, 48)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(35, 20, 20)

    local ItemCorner = Instance.new("UICorner", ItemFrame)
    ItemCorner.CornerRadius = UDim.new(0, 4)

    local LogLabel = Instance.new("TextLabel", ItemFrame)
    LogLabel.Size = UDim2.new(0.62, 0, 1, 0)
    LogLabel.Position = UDim2.new(0.02, 0, 0, 0)
    LogLabel.Text = string.format("[%s] BẤT THƯỜNG!\nTừ: (%s)\nĐến: (%s)", timeStr, fromStr, toStr)
    LogLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Font = Enum.Font.SourceSans
    LogLabel.TextSize = 10
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Nút TP lại điểm Bất Thường
    local TPBackBtn = Instance.new("TextButton", ItemFrame)
    TPBackBtn.Size = UDim2.new(0.16, 0, 0.6, 0)
    TPBackBtn.Position = UDim2.new(0.65, 0, 0.2, 0)
    TPBackBtn.Text = "TP Tới"
    TPBackBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    TPBackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TPBackBtn.Font = Enum.Font.SourceSansBold
    TPBackBtn.TextSize = 10

    local TPCorner = Instance.new("UICorner", TPBackBtn)
    TPCorner.CornerRadius = UDim.new(0, 4)

    -- Nút Copy Log
    local CopyLogBtn = Instance.new("TextButton", ItemFrame)
    CopyLogBtn.Size = UDim2.new(0.15, 0, 0.6, 0)
    CopyLogBtn.Position = UDim2.new(0.83, 0, 0.2, 0)
    CopyLogBtn.Text = "Copy"
    CopyLogBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    CopyLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyLogBtn.Font = Enum.Font.SourceSansBold
    CopyLogBtn.TextSize = 10

    local CopyCorner = Instance.new("UICorner", CopyLogBtn)
    CopyCorner.CornerRadius = UDim.new(0, 4)

    TPBackBtn.MouseButton1Click:Connect(function()
        lockTargetPos = toPos
        teleportTo(toPos)
    end)

    CopyLogBtn.MouseButton1Click:Connect(function()
        setclipboard(copyText)
        CopyLogBtn.Text = "OK"
        task.wait(1)
        CopyLogBtn.Text = "Copy"
    end)

    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogUIList.AbsoluteContentSize.Y)
end

-- Quét kiểm tra nhảy tọa độ (> 30 studs trong 0.1s)
local lastPosition = nil
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local currentPos = hrp.Position
            RealtimeText.Text = string.format("Tọa độ hiện tại: %.1f, %.1f, %.1f", currentPos.X, currentPos.Y, currentPos.Z)
            
            if lastPosition then
                local distance = (currentPos - lastPosition).Magnitude
                if distance >= 30 then
                    addAbnormalLog(lastPosition, currentPos)
                end
            end
            lastPosition = currentPos
        end
    end
end)

---------------------------------------------------------
-- LOGIC NPC TRACKER
---------------------------------------------------------
local function isNPC(model)
    if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if not Players:GetPlayerFromCharacter(model) then return true end
    end
    return false
end

local function registerNPCSpawn(model)
    if isNPC(model) and not npcSpawnPositions[model] then
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp then npcSpawnPositions[model] = hrp.Position end
    end
end

for _, obj in pairs(Workspace:GetDescendants()) do registerNPCSpawn(obj) end
Workspace.DescendantAdded:Connect(function(desc) task.wait(0.1) registerNPCSpawn(desc) end)

local function updateNPCList()
    for _, child in pairs(NPCScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if isNPC(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            
            if hum and hrp and hum.Health > 0 then
                local currentPos = hrp.Position
                local spawnPos = npcSpawnPositions[obj] or currentPos
                
                local currentPosStr = string.format("%.1f, %.1f, %.1f", currentPos.X, currentPos.Y, currentPos.Z)
                local spawnPosStr = string.format("%.1f, %.1f, %.1f", spawnPos.X, spawnPos.Y, spawnPos.Z)

                local ItemFrame = Instance.new("Frame", NPCScroll)
                ItemFrame.Size = UDim2.new(1, -5, 0, 50)
                ItemFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

                local ItemCorner = Instance.new("UICorner", ItemFrame)
                ItemCorner.CornerRadius = UDim.new(0, 4)

                local InfoLabel = Instance.new("TextLabel", ItemFrame)
                InfoLabel.Size = UDim2.new(0.78, 0, 1, 0)
                InfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
                InfoLabel.Text = string.format("Tên: %s | HP: %d/%d\nPos: (%s)\nSpawn: (%s)", obj.Name, math.floor(hum.Health), math.floor(hum.MaxHealth), currentPosStr, spawnPosStr)
                InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                InfoLabel.BackgroundTransparency = 1
                InfoLabel.Font = Enum.Font.SourceSans
                InfoLabel.TextSize = 10
                InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

                local NPCTPBtn = Instance.new("TextButton", ItemFrame)
                NPCTPBtn.Size = UDim2.new(0.18, 0, 0.6, 0)
                NPCTPBtn.Position = UDim2.new(0.8, 0, 0.2, 0)
                NPCTPBtn.Text = "TP Tới"
                NPCTPBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
                NPCTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                NPCTPBtn.Font = Enum.Font.SourceSansBold
                NPCTPBtn.TextSize = 10

                local TPCorner = Instance.new("UICorner", NPCTPBtn)
                TPCorner.CornerRadius = UDim.new(0, 4)

                NPCTPBtn.MouseButton1Click:Connect(function()
                    teleportTo(hrp.Position + Vector3.new(0, 3, 0))
                end)
            end
        end
    end
    NPCScroll.CanvasSize = UDim2.new(0, 0, 0, NPCUIList.AbsoluteContentSize.Y)
end

task.spawn(function()
    while task.wait(1) do
        if MainFrame.Visible and Page2.Visible then
            updateNPCList()
        end
    end
end)
