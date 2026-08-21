-- Script All-In-One Optimized: Log/TP + NPC ESP + Model Filter + Player & Item/Damage Inspector
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("UltimateTrackerGUI") then
    CoreGui.UltimateTrackerGUI:Destroy()
end

_G.AutoLock = false
_G.NPCESP = false

local lockTargetPos = Vector3.zero
local npcSpawnPositions = {}
local npcESPFolders = {}
local modelESPFolders = {}

local maxScanDistance = 150
local filterKeyword = ""
local filterCategoryIndex = 1
local filterCategories = {"Tất cả", "Vật lý", "Xuyên qua", "Có Script", "Nút / Tương tác"}

-- KHỞI TẠO GUI CHÍNH
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltimateTrackerGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 440, 0, 400)
MainFrame.Position = UDim2.new(0.05, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

-- Thanh Tiêu Đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Text = "  ULTIMATE TRACKER & ITEM INSPECTOR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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

-- THANH TAB (4 TAB)
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(0.92, 0, 0, 30)
TabFrame.Position = UDim2.new(0.04, 0, 0.10, 0)
TabFrame.BackgroundTransparency = 1

local function createTabBtn(text, posX, isActive)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0.235, 0, 1, 0)
    btn.Position = UDim2.new(posX, 0, 0, 0)
    btn.Text = text
    btn.BackgroundColor3 = isActive and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 9

    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 5)
    return btn
end

local Tab1Btn = createTabBtn("Log / Tọa Độ", 0, true)
local Tab2Btn = createTabBtn("NPC ESP", 0.255, false)
local Tab3Btn = createTabBtn("Model / Khối", 0.51, false)
local Tab4Btn = createTabBtn("Player / Item", 0.765, false)

-- PAGES
local Page1 = Instance.new("Frame", MainFrame)
Page1.Size = UDim2.new(0.92, 0, 0.78, 0)
Page1.Position = UDim2.new(0.04, 0, 0.19, 0)
Page1.BackgroundTransparency = 1

local Page2 = Instance.new("Frame", MainFrame)
Page2.Size = UDim2.new(0.92, 0, 0.78, 0)
Page2.Position = UDim2.new(0.04, 0, 0.19, 0)
Page2.BackgroundTransparency = 1
Page2.Visible = false

local Page3 = Instance.new("Frame", MainFrame)
Page3.Size = UDim2.new(0.92, 0, 0.78, 0)
Page3.Position = UDim2.new(0.04, 0, 0.19, 0)
Page3.BackgroundTransparency = 1
Page3.Visible = false

local Page4 = Instance.new("Frame", MainFrame)
Page4.Size = UDim2.new(0.92, 0, 0.78, 0)
Page4.Position = UDim2.new(0.04, 0, 0.19, 0)
Page4.BackgroundTransparency = 1
Page4.Visible = false

local function switchTab(activePage, activeBtn)
    Page1.Visible = false; Page2.Visible = false; Page3.Visible = false; Page4.Visible = false
    Tab1Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Tab2Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Tab3Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Tab4Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    activePage.Visible = true
    activeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
end

Tab1Btn.MouseButton1Click:Connect(function() switchTab(Page1, Tab1Btn) end)
Tab2Btn.MouseButton1Click:Connect(function() switchTab(Page2, Tab2Btn) end)
Tab3Btn.MouseButton1Click:Connect(function() switchTab(Page3, Tab3Btn) end)
Tab4Btn.MouseButton1Click:Connect(function() switchTab(Page4, Tab4Btn) end)

---------------------------------------------------------
-- TAB 1: LOG TỌA ĐỘ
---------------------------------------------------------
local RealtimeText = Instance.new("TextLabel", Page1)
RealtimeText.Size = UDim2.new(1, 0, 0, 22)
RealtimeText.Text = "Pos Hiện Tại: 0, 0, 0"
RealtimeText.TextColor3 = Color3.fromRGB(0, 255, 150)
RealtimeText.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
RealtimeText.Font = Enum.Font.Code
RealtimeText.TextSize = 10

local RealtimeCorner = Instance.new("UICorner", RealtimeText)
RealtimeCorner.CornerRadius = UDim.new(0, 4)

local SavePosBtn = Instance.new("TextButton", Page1)
SavePosBtn.Size = UDim2.new(0.48, 0, 0, 25)
SavePosBtn.Position = UDim2.new(0, 0, 0.09, 0)
SavePosBtn.Text = "Lưu Vị Trí Hiện Tại"
SavePosBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtn.Font = Enum.Font.SourceSansBold
SavePosBtn.TextSize = 10

local SaveCorner = Instance.new("UICorner", SavePosBtn)
SaveCorner.CornerRadius = UDim.new(0, 4)

local FindSpawnBtn = Instance.new("TextButton", Page1)
FindSpawnBtn.Size = UDim2.new(0.48, 0, 0, 25)
FindSpawnBtn.Position = UDim2.new(0.52, 0, 0.09, 0)
FindSpawnBtn.Text = "Tìm Pos Spawn Map"
FindSpawnBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
FindSpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FindSpawnBtn.Font = Enum.Font.SourceSansBold
FindSpawnBtn.TextSize = 10

local FindCorner = Instance.new("UICorner", FindSpawnBtn)
FindCorner.CornerRadius = UDim.new(0, 4)

local LogScroll = Instance.new("ScrollingFrame", Page1)
LogScroll.Size = UDim2.new(1, 0, 0, 195)
LogScroll.Position = UDim2.new(0, 0, 0.19, 0)
LogScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 4

local LogUIList = Instance.new("UIListLayout", LogScroll)
LogUIList.SortOrder = Enum.SortOrder.LayoutOrder
LogUIList.Padding = UDim.new(0, 4)

local LockToggleBtn = Instance.new("TextButton", Page1)
LockToggleBtn.Size = UDim2.new(1, 0, 0, 26)
LockToggleBtn.Position = UDim2.new(0, 0, 0.89, 0)
LockToggleBtn.Text = "Khóa Vị Trí Vừa Chọn: OFF"
LockToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
LockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockToggleBtn.Font = Enum.Font.SourceSansBold
LockToggleBtn.TextSize = 11

local LockCorner = Instance.new("UICorner", LockToggleBtn)
LockCorner.CornerRadius = UDim.new(0, 4)

---------------------------------------------------------
-- TAB 2: NPC TRACKER & ESP
---------------------------------------------------------
local ESPToggleBtn = Instance.new("TextButton", Page2)
ESPToggleBtn.Size = UDim2.new(1, 0, 0, 26)
ESPToggleBtn.Position = UDim2.new(0, 0, 0, 0)
ESPToggleBtn.Text = "Bật/Tắt ESP Toàn Bộ NPC: OFF"
ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ESPToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggleBtn.Font = Enum.Font.SourceSansBold
ESPToggleBtn.TextSize = 11

local ESPCorner = Instance.new("UICorner", ESPToggleBtn)
ESPCorner.CornerRadius = UDim.new(0, 4)

local NPCScroll = Instance.new("ScrollingFrame", Page2)
NPCScroll.Size = UDim2.new(1, 0, 0, 250)
NPCScroll.Position = UDim2.new(0, 0, 0.11, 0)
NPCScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
NPCScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
NPCScroll.ScrollBarThickness = 4

local NPCUIList = Instance.new("UIListLayout", NPCScroll)
NPCUIList.SortOrder = Enum.SortOrder.LayoutOrder
NPCUIList.Padding = UDim.new(0, 4)

---------------------------------------------------------
-- TAB 3: MODEL & BLOCK TRACKER
---------------------------------------------------------
local SearchBox = Instance.new("TextBox", Page3)
SearchBox.Size = UDim2.new(0.48, 0, 0, 25)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.PlaceholderText = "Lọc tên..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 11

local SearchCorner = Instance.new("UICorner", SearchBox)
SearchCorner.CornerRadius = UDim.new(0, 4)

local DistBtn = Instance.new("TextButton", Page3)
DistBtn.Size = UDim2.new(0.24, 0, 0, 25)
DistBtn.Position = UDim2.new(0.50, 0, 0, 0)
DistBtn.Text = "Bán Kính: 150m"
DistBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
DistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DistBtn.Font = Enum.Font.SourceSansBold
DistBtn.TextSize = 9

local DistCorner = Instance.new("UICorner", DistBtn)
DistCorner.CornerRadius = UDim.new(0, 4)

local TypeFilterBtn = Instance.new("TextButton", Page3)
TypeFilterBtn.Size = UDim2.new(0.24, 0, 0, 25)
TypeFilterBtn.Position = UDim2.new(0.76, 0, 0, 0)
TypeFilterBtn.Text = "Lọc: Tất cả"
TypeFilterBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 215)
TypeFilterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TypeFilterBtn.Font = Enum.Font.SourceSansBold
TypeFilterBtn.TextSize = 9

local FilterCorner = Instance.new("UICorner", TypeFilterBtn)
FilterCorner.CornerRadius = UDim.new(0, 4)

local ModelScroll = Instance.new("ScrollingFrame", Page3)
ModelScroll.Size = UDim2.new(1, 0, 0, 250)
ModelScroll.Position = UDim2.new(0, 0, 0.11, 0)
ModelScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ModelScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ModelScroll.ScrollBarThickness = 4

local ModelUIList = Instance.new("UIListLayout", ModelScroll)
ModelUIList.SortOrder = Enum.SortOrder.LayoutOrder
ModelUIList.Padding = UDim.new(0, 4)

---------------------------------------------------------
-- TAB 4: PLAYER & ITEM INSPECTOR
---------------------------------------------------------
local RefreshPlayerBtn = Instance.new("TextButton", Page4)
RefreshPlayerBtn.Size = UDim2.new(1, 0, 0, 25)
RefreshPlayerBtn.Position = UDim2.new(0, 0, 0, 0)
RefreshPlayerBtn.Text = "Làm Mới Danh Sách Người Chơi & Item"
RefreshPlayerBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 180)
RefreshPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshPlayerBtn.Font = Enum.Font.SourceSansBold
RefreshPlayerBtn.TextSize = 10

local RefCorner = Instance.new("UICorner", RefreshPlayerBtn)
RefCorner.CornerRadius = UDim.new(0, 4)

local PlayerScroll = Instance.new("ScrollingFrame", Page4)
PlayerScroll.Size = UDim2.new(1, 0, 0, 250)
PlayerScroll.Position = UDim2.new(0, 0, 0.11, 0)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 4

local PlayerUIList = Instance.new("UIListLayout", PlayerScroll)
PlayerUIList.SortOrder = Enum.SortOrder.LayoutOrder
PlayerUIList.Padding = UDim.new(0, 4)

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
-- LOGIC HỆ THỐNG DÙNG CHUNG
---------------------------------------------------------
local function teleportTo(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(pos)
    end
end

-- LOGIC TAB 1
LockToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoLock = not _G.AutoLock
    LockToggleBtn.Text = _G.AutoLock and "Khóa Vị Trí Vừa Chọn: ON" or "Khóa Vị Trí Vừa Chọn: OFF"
    LockToggleBtn.BackgroundColor3 = _G.AutoLock and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

RunService.Stepped:Connect(function()
    if _G.AutoLock and lockTargetPos ~= Vector3.zero then 
        teleportTo(lockTargetPos) 
    end
end)

local function addCustomLog(titleText, pos, color)
    local timeStr = os.date("%X")
    local posStr = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)
    local copyText = string.format("[%s] %s: (%s)", timeStr, titleText, posStr)

    local ItemFrame = Instance.new("Frame", LogScroll)
    ItemFrame.Size = UDim2.new(1, -5, 0, 42)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

    local ItemCorner = Instance.new("UICorner", ItemFrame)
    ItemCorner.CornerRadius = UDim.new(0, 4)

    local LogLabel = Instance.new("TextLabel", ItemFrame)
    LogLabel.Size = UDim2.new(0.62, 0, 1, 0)
    LogLabel.Position = UDim2.new(0.02, 0, 0, 0)
    LogLabel.Text = string.format("[%s] %s\nPos: (%s)", timeStr, titleText, posStr)
    LogLabel.TextColor3 = color
    LogLabel.BackgroundTransparency = 1
    LogLabel.Font = Enum.Font.SourceSans
    LogLabel.TextSize = 10
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left

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
        lockTargetPos = pos
        teleportTo(pos)
    end)

    CopyLogBtn.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard(copyText) end
        CopyLogBtn.Text = "OK"
        task.wait(1)
        CopyLogBtn.Text = "Copy"
    end)

    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogUIList.AbsoluteContentSize.Y)
end

SavePosBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then addCustomLog("LƯU POS BẢN THÂN", hrp.Position, Color3.fromRGB(0, 255, 150)) end
end)

FindSpawnBtn.MouseButton1Click:Connect(function()
    local spawnFound = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            addCustomLog("SPAWN MAP: " .. obj.Name, obj.Position, Color3.fromRGB(255, 200, 50))
            spawnFound = true
        end
    end
    if not spawnFound then addCustomLog("KHÔNG TÌM THẤY SPAWNLOCATION", Vector3.zero, Color3.fromRGB(255, 100, 100)) end
end)

local lastPosition = nil
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local currentPos = hrp.Position
            RealtimeText.Text = string.format("Pos Hiện Tại: %.1f, %.1f, %.1f", currentPos.X, currentPos.Y, currentPos.Z)
            
            if lastPosition then
                local distance = (currentPos - lastPosition).Magnitude
                if distance >= 30 then
                    addCustomLog("BẤT THƯỜNG! VĂNG TỚI", currentPos, Color3.fromRGB(255, 100, 100))
                end
            end
            lastPosition = currentPos
        end
    end
end)

-- LOGIC TAB 2: NPC
local function isNPC(model)
    if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
        if not Players:GetPlayerFromCharacter(model) then return true end
    end
    return false
end

local function removeNPCESP(model)
    if npcESPFolders[model] then
        npcESPFolders[model]:Destroy()
        npcESPFolders[model] = nil
    end
end

local function applyNPCESP(model)
    if not _G.NPCESP or not isNPC(model) or npcESPFolders[model] then return end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local folder = Instance.new("Folder", CoreGui)
    folder.Name = "ESP_" .. model.Name

    local highlight = Instance.new("Highlight", folder)
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

    local billboard = Instance.new("BillboardGui", folder)
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.Text = model.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 12

    npcESPFolders[model] = folder

    model.AncestryChanged:Connect(function(_, parent)
        if not parent then removeNPCESP(model) end
    end)
end

ESPToggleBtn.MouseButton1Click:Connect(function()
    _G.NPCESP = not _G.NPCESP
    ESPToggleBtn.Text = _G.NPCESP and "Bật/Tắt ESP Toàn Bộ NPC: ON" or "Bật/Tắt ESP Toàn Bộ NPC: OFF"
    ESPToggleBtn.BackgroundColor3 = _G.NPCESP and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isNPC(obj) then
            if _G.NPCESP then applyNPCESP(obj) else removeNPCESP(obj) end
        end
    end
end)

local function registerNPCSpawn(model)
    if isNPC(model) and not npcSpawnPositions[model] then
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if hrp then npcSpawnPositions[model] = hrp.Position end
    end
    if _G.NPCESP then applyNPCESP(model) end
end

for _, obj in ipairs(Workspace:GetDescendants()) do registerNPCSpawn(obj) end
Workspace.DescendantAdded:Connect(function(desc)
    task.wait(0.1)
    if isNPC(desc) then registerNPCSpawn(desc) end
end)

local function updateNPCList()
    for _, child in ipairs(NPCScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isNPC(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local currentPos = hrp.Position
                local spawnPos = npcSpawnPositions[obj] or currentPos

                local ItemFrame = Instance.new("Frame", NPCScroll)
                ItemFrame.Size = UDim2.new(1, -5, 0, 48)
                ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

                local ItemCorner = Instance.new("UICorner", ItemFrame)
                ItemCorner.CornerRadius = UDim.new(0, 4)

                local InfoLabel = Instance.new("TextLabel", ItemFrame)
                InfoLabel.Size = UDim2.new(0.78, 0, 1, 0)
                InfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
                InfoLabel.Text = string.format("Tên: %s | HP: %d/%d\nPos: (%.1f, %.1f, %.1f)\nSpawn: (%.1f, %.1f, %.1f)", 
                    obj.Name, math.floor(hum.Health), math.floor(hum.MaxHealth), 
                    currentPos.X, currentPos.Y, currentPos.Z, 
                    spawnPos.X, spawnPos.Y, spawnPos.Z)
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

-- LOGIC TAB 3: MODEL & BLOCK
local distances = {100, 150, 300, 500}
local currentDistIndex = 2

DistBtn.MouseButton1Click:Connect(function()
    currentDistIndex = (currentDistIndex % #distances) + 1
    maxScanDistance = distances[currentDistIndex]
    DistBtn.Text = "Bán Kính: " .. maxScanDistance .. "m"
end)

TypeFilterBtn.MouseButton1Click:Connect(function()
    filterCategoryIndex = (filterCategoryIndex % #filterCategories) + 1
    TypeFilterBtn.Text = "Lọc: " .. filterCategories[filterCategoryIndex]
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterKeyword = string.lower(SearchBox.Text)
end)

local function getObjectPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local p = obj:FindFirstChildOfClass("BasePart")
        if p then return p.Position end
    end
    return nil
end

local function matchesCategoryFilter(obj)
    local cat = filterCategories[filterCategoryIndex]
    if cat == "Tất cả" then
        return true
    elseif cat == "Vật lý" then
        if obj:IsA("BasePart") then return obj.CanCollide end
        if obj:IsA("Model") then
            for _, p in ipairs(obj:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then return true end
            end
        end
        return false
    elseif cat == "Xuyên qua" then
        if obj:IsA("BasePart") then return not obj.CanCollide end
        if obj:IsA("Model") then
            local p = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
            if p then return not p.CanCollide end
        end
        return false
    elseif cat == "Có Script" then
        return obj:FindFirstChildWhichIsA("LuaSourceContainer", true) ~= nil
    elseif cat == "Nút / Tương tác" then
        return obj:FindFirstChildOfClass("ClickDetector", true) ~= nil 
            or obj:FindFirstChildOfClass("ProximityPrompt", true) ~= nil
            or obj:FindFirstChildOfClass("TouchTransmitter", true) ~= nil
    end
    return true
end

local function removeModelESP(obj)
    if modelESPFolders[obj] then
        modelESPFolders[obj]:Destroy()
        modelESPFolders[obj] = nil
    end
end

local function applyModelESP(obj, color)
    if modelESPFolders[obj] then return end
    local folder = Instance.new("Folder", CoreGui)
    folder.Name = "ModelESP_" .. obj.Name

    local highlight = Instance.new("Highlight", folder)
    highlight.Adornee = obj
    highlight.FillColor = color
    highlight.FillTransparency = 0.6

    local targetPart = obj:IsA("BasePart") and obj or (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
    if targetPart then
        local billboard = Instance.new("BillboardGui", folder)
        billboard.Adornee = targetPart
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.AlwaysOnTop = true

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = obj.Name
        label.TextColor3 = color
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 11
    end
    modelESPFolders[obj] = folder

    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then removeModelESP(obj) end
    end)
end

local function updateModelList()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, child in ipairs(ModelScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    local myPos = hrp.Position
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj ~= char and not Players:GetPlayerFromCharacter(obj) and not isNPC(obj) then
            local objPos = getObjectPos(obj)
            if objPos then
                local dist = (objPos - myPos).Magnitude
                if dist <= maxScanDistance then
                    local nameMatch = (filterKeyword == "") or string.find(string.lower(obj.Name), filterKeyword)
                    local categoryMatch = matchesCategoryFilter(obj)
                    
                    if nameMatch and categoryMatch then
                        local isModel = obj:IsA("Model")
                        local themeColor = isModel and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(0, 200, 255)

                        local ItemFrame = Instance.new("Frame", ModelScroll)
                        ItemFrame.Size = UDim2.new(1, -5, 0, 45)
                        ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

                        local ItemCorner = Instance.new("UICorner", ItemFrame)
                        ItemCorner.CornerRadius = UDim.new(0, 4)

                        local InfoLabel = Instance.new("TextLabel", ItemFrame)
                        InfoLabel.Size = UDim2.new(0.55, 0, 1, 0)
                        InfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
                        InfoLabel.Text = string.format("[%s] %s\nCách: %dm | Pos: (%.1f, %.1f, %.1f)", 
                            isModel and "MODEL" or "BLOCK", obj.Name, math.floor(dist), objPos.X, objPos.Y, objPos.Z)
                        InfoLabel.TextColor3 = themeColor
                        InfoLabel.BackgroundTransparency = 1
                        InfoLabel.Font = Enum.Font.SourceSans
                        InfoLabel.TextSize = 10
                        InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

                        local MESPBtn = Instance.new("TextButton", ItemFrame)
                        MESPBtn.Size = UDim2.new(0.18, 0, 0.6, 0)
                        MESPBtn.Position = UDim2.new(0.58, 0, 0.2, 0)
                        MESPBtn.Text = modelESPFolders[obj] and "ESP: ON" or "ESP: OFF"
                        MESPBtn.BackgroundColor3 = modelESPFolders[obj] and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(70, 70, 70)
                        MESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        MESPBtn.Font = Enum.Font.SourceSansBold
                        MESPBtn.TextSize = 10

                        local ESPCorner = Instance.new("UICorner", MESPBtn)
                        ESPCorner.CornerRadius = UDim.new(0, 4)

                        MESPBtn.MouseButton1Click:Connect(function()
                            if modelESPFolders[obj] then
                                removeModelESP(obj)
                                MESPBtn.Text = "ESP: OFF"
                                MESPBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                            else
                                applyModelESP(obj, themeColor)
                                MESPBtn.Text = "ESP: ON"
                                MESPBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
                            end
                        end)

                        local TPBtn = Instance.new("TextButton", ItemFrame)
                        TPBtn.Size = UDim2.new(0.18, 0, 0.6, 0)
                        TPBtn.Position = UDim2.new(0.78, 0, 0.2, 0)
                        TPBtn.Text = "TP Tới"
                        TPBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
                        TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        TPBtn.Font = Enum.Font.SourceSansBold
                        TPBtn.TextSize = 10

                        local TPCorner = Instance.new("UICorner", TPBtn)
                        TPCorner.CornerRadius = UDim.new(0, 4)

                        TPBtn.MouseButton1Click:Connect(function()
                            teleportTo(objPos + Vector3.new(0, 3, 0))
                        end)
                    end
                end
            end
        end
    end
    ModelScroll.CanvasSize = UDim2.new(0, 0, 0, ModelUIList.AbsoluteContentSize.Y)
end

---------------------------------------------------------
-- LOGIC TAB 4: PLAYER & ITEM / DAMAGE / SCRIPT INSPECTOR
---------------------------------------------------------
local function inspectToolDetails(tool)
    if not tool or not tool:IsA("Tool") then return nil end

    local details = {
        name = tool.Name,
        damage = "N/A",
        scripts = {}
    }

    -- 1. Quét tìm Sát thương trong Attributes
    for attrName, attrVal in pairs(tool:GetAttributes()) do
        local low = string.lower(attrName)
        if string.find(low, "dam") or string.find(low, "dmg") or string.find(low, "atk") or string.find(low, "power") then
            details.damage = tostring(attrVal)
            break
        end
    end

    -- 2. Quét tìm Sát thương trong Values (IntValue, NumberValue, StringValue)
    if details.damage == "N/A" then
        for _, val in ipairs(tool:GetDescendants()) do
            if val:IsA("ValueBase") then
                local low = string.lower(val.Name)
                if string.find(low, "dam") or string.find(low, "dmg") or string.find(low, "atk") or string.find(low, "power") then
                    details.damage = tostring(val.Value)
                    break
                end
            end
        end
    end

    -- 3. Quét danh sách Scripts
    for _, s in ipairs(tool:GetDescendants()) do
        if s:IsA("LuaSourceContainer") then
            local tag = s:IsA("LocalScript") and "[L]" or (s:IsA("ModuleScript") and "[M]" or "[S]")
            table.insert(details.scripts, tag .. s.Name)
        end
    end

    return details
end

local function updatePlayerList()
    for _, child in ipairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        local heldTool = char and char:FindFirstChildOfClass("Tool")
        local toolInfo = heldTool and inspectToolDetails(heldTool)

        local ItemFrame = Instance.new("Frame", PlayerScroll)
        ItemFrame.Size = UDim2.new(1, -5, 0, 58)
        ItemFrame.BackgroundColor3 = (plr == LocalPlayer) and Color3.fromRGB(30, 45, 30) or Color3.fromRGB(25, 25, 25)

        local ItemCorner = Instance.new("UICorner", ItemFrame)
        ItemCorner.CornerRadius = UDim.new(0, 4)

        local scriptSummary = "None"
        if toolInfo and #toolInfo.scripts > 0 then
            scriptSummary = table.concat(toolInfo.scripts, ", ")
            if #scriptSummary > 32 then scriptSummary = string.sub(scriptSummary, 1, 30) .. ".." end
        end

        local textDesc = string.format(
            "Player: %s (@%s)\nItem Cầm: %s | Dame: %s\nScripts: %s",
            plr.DisplayName, plr.Name,
            toolInfo and toolInfo.name or "[Trống]",
            toolInfo and toolInfo.damage or "--",
            scriptSummary
        )

        local InfoLabel = Instance.new("TextLabel", ItemFrame)
        InfoLabel.Size = UDim2.new(0.66, 0, 1, 0)
        InfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
        InfoLabel.Text = textDesc
        InfoLabel.TextColor3 = toolInfo and Color3.fromRGB(255, 220, 100) or Color3.fromRGB(200, 200, 200)
        InfoLabel.BackgroundTransparency = 1
        InfoLabel.Font = Enum.Font.SourceSans
        InfoLabel.TextSize = 10
        InfoLabel.TextXAlignment = Enum.TextXAlignment.Left

        local TPBtn = Instance.new("TextButton", ItemFrame)
        TPBtn.Size = UDim2.new(0.14, 0, 0.55, 0)
        TPBtn.Position = UDim2.new(0.69, 0, 0.22, 0)
        TPBtn.Text = "TP Tới"
        TPBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TPBtn.Font = Enum.Font.SourceSansBold
        TPBtn.TextSize = 10

        local TPCorner = Instance.new("UICorner", TPBtn)
        TPCorner.CornerRadius = UDim.new(0, 4)

        TPBtn.MouseButton1Click:Connect(function()
            if hrp then teleportTo(hrp.Position + Vector3.new(0, 3, 0)) end
        end)

        local CopyBtn = Instance.new("TextButton", ItemFrame)
        CopyBtn.Size = UDim2.new(0.14, 0, 0.55, 0)
        CopyBtn.Position = UDim2.new(0.84, 0, 0.22, 0)
        CopyBtn.Text = "Copy"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyBtn.Font = Enum.Font.SourceSansBold
        CopyBtn.TextSize = 10

        local CopyCorner = Instance.new("UICorner", CopyBtn)
        CopyCorner.CornerRadius = UDim.new(0, 4)

        CopyBtn.MouseButton1Click:Connect(function()
            local fullScriptList = toolInfo and table.concat(toolInfo.scripts, ", ") or "None"
            local fullCopy = string.format("Player: %s (@%s)\nItem: %s\nDamage: %s\nScripts: %s",
                plr.DisplayName, plr.Name,
                toolInfo and toolInfo.name or "None",
                toolInfo and toolInfo.damage or "N/A",
                fullScriptList
            )
            if setclipboard then setclipboard(fullCopy) end
            CopyBtn.Text = "OK"
            task.wait(1)
            CopyBtn.Text = "Copy"
        end)
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerUIList.AbsoluteContentSize.Y)
end

RefreshPlayerBtn.MouseButton1Click:Connect(updatePlayerList)

-- VÒNG LẶP CẬP NHẬT TỰ ĐỘNG
task.spawn(function()
    while task.wait(1.5) do
        if MainFrame.Visible then
            if Page2.Visible then updateNPCList() end
            if Page3.Visible then updateModelList() end
            if Page4.Visible then updatePlayerList() end
        end
    end
end)
