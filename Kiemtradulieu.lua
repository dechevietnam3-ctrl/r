-- Script Ultimate Tracker V3: Log Pos + NPC + Model/Block + Soi Tool & Code Script
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

local lockTargetPos = Vector3.new(0, 0, 0)
local npcSpawnPositions = {}
local npcESPFolders = {}
local modelESPFolders = {}
local playerESPFolders = {}

local maxScanDistance = 150
local filterKeyword = ""

-- TẠO MÀN HÌNH CHÍNH
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "UltimateTrackerGUI"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 450, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- Thanh Tiêu Đề
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Text = "  ULTIMATE TRACKER V3 - SCRIPT & ITEM INSPECTOR"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 11
Title.Font = Enum.Font.SourceSansBold
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -33, 0, 2)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- THANH TAB
local TabFrame = Instance.new("Frame", MainFrame)
TabFrame.Size = UDim2.new(0.92, 0, 0, 30)
TabFrame.Position = UDim2.new(0.04, 0, 0.10, 0)
TabFrame.BackgroundTransparency = 1

local function createTabBtn(text, pos)
    local btn = Instance.new("TextButton", TabFrame)
    btn.Size = UDim2.new(0.23, 0, 1, 0)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 9
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    return btn
end

local Tab1Btn = createTabBtn("Log & Pos", UDim2.new(0, 0, 0, 0))
local Tab2Btn = createTabBtn("NPC Tracker", UDim2.new(0.25, 0, 0, 0))
local Tab3Btn = createTabBtn("Model/Block", UDim2.new(0.50, 0, 0, 0))
local Tab4Btn = createTabBtn("Soi Script Item", UDim2.new(0.75, 0, 0, 0))

Tab1Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
Tab1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)

local function createPage()
    local p = Instance.new("Frame", MainFrame)
    p.Size = UDim2.new(0.92, 0, 0.81, 0)
    p.Position = UDim2.new(0.04, 0, 0.18, 0)
    p.BackgroundTransparency = 1
    return p
end

local Page1 = createPage()
local Page2 = createPage()
local Page3 = createPage()
local Page4 = createPage()

Page2.Visible = false
Page3.Visible = false
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
Instance.new("UICorner", RealtimeText).CornerRadius = UDim.new(0, 4)

local SavePosBtn = Instance.new("TextButton", Page1)
SavePosBtn.Size = UDim2.new(0.48, 0, 0, 25)
SavePosBtn.Position = UDim2.new(0, 0, 0.08, 0)
SavePosBtn.Text = "Lưu Vị Trí Hiện Tại"
SavePosBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SavePosBtn.Font = Enum.Font.SourceSansBold
SavePosBtn.TextSize = 10
Instance.new("UICorner", SavePosBtn).CornerRadius = UDim.new(0, 4)

local FindSpawnBtn = Instance.new("TextButton", Page1)
FindSpawnBtn.Size = UDim2.new(0.48, 0, 0, 25)
FindSpawnBtn.Position = UDim2.new(0.52, 0, 0.08, 0)
FindSpawnBtn.Text = "Tìm Pos Spawn Map"
FindSpawnBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
FindSpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FindSpawnBtn.Font = Enum.Font.SourceSansBold
FindSpawnBtn.TextSize = 10
Instance.new("UICorner", FindSpawnBtn).CornerRadius = UDim.new(0, 4)

local LogScroll = Instance.new("ScrollingFrame", Page1)
LogScroll.Size = UDim2.new(1, 0, 0, 230)
LogScroll.Position = UDim2.new(0, 0, 0.17, 0)
LogScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 4

local LogUIList = Instance.new("UIListLayout", LogScroll)
LogUIList.SortOrder = Enum.SortOrder.LayoutOrder
LogUIList.Padding = UDim.new(0, 4)

local LockToggleBtn = Instance.new("TextButton", Page1)
LockToggleBtn.Size = UDim2.new(1, 0, 0, 26)
LockToggleBtn.Position = UDim2.new(0, 0, 0.91, 0)
LockToggleBtn.Text = "Khóa Vị Trí Vừa Chọn: OFF"
LockToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
LockToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockToggleBtn.Font = Enum.Font.SourceSansBold
LockToggleBtn.TextSize = 11
Instance.new("UICorner", LockToggleBtn).CornerRadius = UDim.new(0, 4)

---------------------------------------------------------
-- TAB 2: NPC TRACKER
---------------------------------------------------------
local ESPToggleBtn = Instance.new("TextButton", Page2)
ESPToggleBtn.Size = UDim2.new(1, 0, 0, 25)
ESPToggleBtn.Text = "Bật/Tắt ESP Toàn Bộ NPC: OFF"
ESPToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ESPToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPToggleBtn.Font = Enum.Font.SourceSansBold
ESPToggleBtn.TextSize = 10
Instance.new("UICorner", ESPToggleBtn).CornerRadius = UDim.new(0, 4)

local NPCScroll = Instance.new("ScrollingFrame", Page2)
NPCScroll.Size = UDim2.new(1, 0, 0, 280)
NPCScroll.Position = UDim2.new(0, 0, 0.1, 0)
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
SearchBox.Size = UDim2.new(0.6, 0, 0, 25)
SearchBox.PlaceholderText = "Lọc tên Model / Khối..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 11
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

local DistBtn = Instance.new("TextButton", Page3)
DistBtn.Size = UDim2.new(0.38, 0, 0, 25)
DistBtn.Position = UDim2.new(0.62, 0, 0, 0)
DistBtn.Text = "Bán Kính: 150m"
DistBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
DistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DistBtn.Font = Enum.Font.SourceSansBold
DistBtn.TextSize = 10
Instance.new("UICorner", DistBtn).CornerRadius = UDim.new(0, 4)

local ModelScroll = Instance.new("ScrollingFrame", Page3)
ModelScroll.Size = UDim2.new(1, 0, 0, 280)
ModelScroll.Position = UDim2.new(0, 0, 0.1, 0)
ModelScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ModelScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ModelScroll.ScrollBarThickness = 4

local ModelUIList = Instance.new("UIListLayout", ModelScroll)
ModelUIList.SortOrder = Enum.SortOrder.LayoutOrder
ModelUIList.Padding = UDim.new(0, 4)

---------------------------------------------------------
-- TAB 4: SOI INVENTORY PLAYER & COPY SCRIPT / TOOL NAME
---------------------------------------------------------
local PlayerScroll = Instance.new("ScrollingFrame", Page4)
PlayerScroll.Size = UDim2.new(1, 0, 1, 0)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 4

local PlayerUIList = Instance.new("UIListLayout", PlayerScroll)
PlayerUIList.SortOrder = Enum.SortOrder.LayoutOrder
PlayerUIList.Padding = UDim.new(0, 6)

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
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)

---------------------------------------------------------
-- HÀM XỬ LÝ DỮ LIỆU
---------------------------------------------------------
local function teleportTo(pos)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

-- LOGIC TAB 1
LockToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoLock = not _G.AutoLock
    LockToggleBtn.Text = _G.AutoLock and "Khóa Vị Trí Vừa Chọn: ON" or "Khóa Vị Trí Vừa Chọn: OFF"
    LockToggleBtn.BackgroundColor3 = _G.AutoLock and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(180, 50, 50)
end)

RunService.Stepped:Connect(function()
    if _G.AutoLock then teleportTo(lockTargetPos) end
end)

local function addCustomLog(titleText, pos, color)
    local timeStr = os.date("%X")
    local posStr = string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z)

    local ItemFrame = Instance.new("Frame", LogScroll)
    ItemFrame.Size = UDim2.new(1, -5, 0, 42)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

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
    Instance.new("UICorner", TPBackBtn).CornerRadius = UDim.new(0, 4)

    TPBackBtn.MouseButton1Click:Connect(function()
        lockTargetPos = pos
        teleportTo(pos)
    end)

    LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogUIList.AbsoluteContentSize.Y)
end

SavePosBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then addCustomLog("LƯU POS BẢN THÂN", hrp.Position, Color3.fromRGB(0, 255, 150)) end
end)

FindSpawnBtn.MouseButton1Click:Connect(function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            addCustomLog("SPAWN MAP: " .. obj.Name, obj.Position, Color3.fromRGB(255, 200, 50))
        end
    end
end)

local lastPosition = nil
task.spawn(function()
    while task.wait(0.1) do
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local currentPos = hrp.Position
            RealtimeText.Text = string.format("Pos Hiện Tại: %.1f, %.1f, %.1f", currentPos.X, currentPos.Y, currentPos.Z)
            if lastPosition and (currentPos - lastPosition).Magnitude >= 30 then
                addCustomLog("BẤT THƯỜNG! VĂNG TỚI", currentPos, Color3.fromRGB(255, 100, 100))
            end
            lastPosition = currentPos
        end
    end
end)

-- LOGIC TAB 2: NPC
local function isNPC(model)
    return model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(model)
end

local function applyNPCESP(model)
    if not _G.NPCESP or not isNPC(model) or npcESPFolders[model] then return end
    local folder = Instance.new("Folder", CoreGui)
    local highlight = Instance.new("Highlight", folder)
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 50, 50)

    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp then
        local billboard = Instance.new("BillboardGui", folder)
        billboard.Adornee = hrp
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = model.Name
        label.TextColor3 = Color3.fromRGB(255, 255, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 11
    end
    npcESPFolders[model] = folder
end

local function updateNPCList()
    for _, child in pairs(NPCScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isNPC(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local ItemFrame = Instance.new("Frame", NPCScroll)
                ItemFrame.Size = UDim2.new(1, -5, 0, 42)
                ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

                local InfoLabel = Instance.new("TextLabel", ItemFrame)
                InfoLabel.Size = UDim2.new(0.78, 0, 1, 0)
                InfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
                InfoLabel.Text = string.format("Tên: %s | HP: %d/%d\nPos: (%.1f, %.1f, %.1f)", obj.Name, math.floor(hum.Health), math.floor(hum.MaxHealth), hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
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
                Instance.new("UICorner", NPCTPBtn).CornerRadius = UDim.new(0, 4)

                NPCTPBtn.MouseButton1Click:Connect(function() teleportTo(hrp.Position + Vector3.new(0, 3, 0)) end)
            end
        end
    end
    NPCScroll.CanvasSize = UDim2.new(0, 0, 0, NPCUIList.AbsoluteContentSize.Y)
end

-- LOGIC TAB 3: MODEL/BLOCK
local distances = {100, 150, 300, 500}
local currentDistIndex = 2
DistBtn.MouseButton1Click:Connect(function()
    currentDistIndex = currentDistIndex + 1
    if currentDistIndex > #distances then currentDistIndex = 1 end
    maxScanDistance = distances[currentDistIndex]
    DistBtn.Text = "Bán Kính: " .. maxScanDistance .. "m"
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function() filterKeyword = string.lower(SearchBox.Text) end)

local function getObjectPos(obj)
    if obj:IsA("BasePart") then return obj.Position end
    if obj:IsA("Model") then return obj.PrimaryPart and obj.PrimaryPart.Position or (obj:FindFirstChildOfClass("BasePart") and obj:FindFirstChildOfClass("BasePart").Position) end
    return nil
end

local function applyModelESP(obj, color)
    if modelESPFolders[obj] then return end
    local folder = Instance.new("Folder", CoreGui)
    local highlight = Instance.new("Highlight", folder)
    highlight.Adornee = obj
    highlight.FillColor = color
    modelESPFolders[obj] = folder
end

local function updateModelList()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, child in pairs(ModelScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local myPos = hrp.Position

    for _, obj in pairs(Workspace:GetChildren()) do
        if obj ~= char and not Players:GetPlayerFromCharacter(obj) and not isNPC(obj) then
            local objPos = getObjectPos(obj)
            if objPos and (objPos - myPos).Magnitude <= maxScanDistance then
                if filterKeyword == "" or string.find(string.lower(obj.Name), filterKeyword) then
                    local isModel = obj:IsA("Model")
                    local themeColor = isModel and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(0, 200, 255)

                    local ItemFrame = Instance.new("Frame", ModelScroll)
                    ItemFrame.Size = UDim2.new(1, -5, 0, 42)
                    ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                    Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

                    local InfoLabel = Instance.new("TextLabel", ItemFrame)
                    InfoLabel.Size = UDim2.new(0.55, 0, 1, 0)
                    InfoLabel.Position = UDim2.new(0.02, 0, 0, 0)
                    InfoLabel.Text = string.format("[%s] %s\nCách: %dm | Pos: (%.1f, %.1f, %.1f)", isModel and "MODEL" or "BLOCK", obj.Name, math.floor((objPos - myPos).Magnitude), objPos.X, objPos.Y, objPos.Z)
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
                    Instance.new("UICorner", MESPBtn).CornerRadius = UDim.new(0, 4)

                    MESPBtn.MouseButton1Click:Connect(function()
                        if modelESPFolders[obj] then
                            modelESPFolders[obj]:Destroy(); modelESPFolders[obj] = nil
                            MESPBtn.Text = "ESP: OFF"; MESPBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                        else
                            applyModelESP(obj, themeColor)
                            MESPBtn.Text = "ESP: ON"; MESPBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
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
                    Instance.new("UICorner", TPBtn).CornerRadius = UDim.new(0, 4)

                    TPBtn.MouseButton1Click:Connect(function() teleportTo(objPos + Vector3.new(0, 3, 0)) end)
                end
            end
        end
    end
    ModelScroll.CanvasSize = UDim2.new(0, 0, 0, ModelUIList.AbsoluteContentSize.Y)
end

---------------------------------------------------------
-- LOGIC TAB 4: NÂNG CẤP COPY SCRIPT VÀ TÊN VẬT PHẨM
---------------------------------------------------------
local function togglePlayerESP(plr)
    if playerESPFolders[plr] then
        playerESPFolders[plr]:Destroy()
        playerESPFolders[plr] = nil
        return false
    else
        local char = plr.Character
        if char then
            local folder = Instance.new("Folder", CoreGui)
            local highlight = Instance.new("Highlight", folder)
            highlight.Adornee = char
            highlight.FillColor = Color3.fromRGB(180, 0, 255)

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local billboard = Instance.new("BillboardGui", folder)
                billboard.Adornee = hrp
                billboard.Size = UDim2.new(0, 120, 0, 30)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true

                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.Text = plr.DisplayName
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 12
            end
            playerESPFolders[plr] = folder
            return true
        end
    end
    return false
end

-- Hàm Decompile / Lấy Mã Nguồn Script
local function getScriptSource(scr)
    if decompile then
        local success, code = pcall(function() return decompile(scr) end)
        if success and code and #code > 0 then return code end
    end
    if scr:IsA("LocalScript") and scr.Source and #scr.Source > 0 then
        return scr.Source
    end
    return "-- [Không thể giải mã source của Script này hoặc Executor không hỗ trợ decompile]"
end

local function buildToolItemsList(plr, parentContainer)
    local toolsList = {}
    
    local function processTool(tool, locationTag)
        table.insert(toolsList, tool)
    end

    local backpack = plr:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") then processTool(item, "[Túi]") end
        end
    end

    local char = plr.Character
    if char then
        for _, item in pairs(char:GetChildren()) do
            if item:IsA("Tool") then processTool(item, "[Tay]") end
        end
    end

    if #toolsList == 0 then
        local EmptyText = Instance.new("TextLabel", parentContainer)
        EmptyText.Size = UDim2.new(1, 0, 0, 25)
        EmptyText.Text = "Không có vật phẩm/Tool trong người."
        EmptyText.TextColor3 = Color3.fromRGB(120, 120, 120)
        EmptyText.BackgroundTransparency = 1
        EmptyText.Font = Enum.Font.SourceSansItalic
        EmptyText.TextSize = 10
        return
    end

    for _, tool in pairs(toolsList) do
        local isEquipped = tool.Parent == plr.Character
        local locationTag = isEquipped and "[Đang cầm]" or "[Túi đồ]"
        
        local ToolBox = Instance.new("Frame", parentContainer)
        ToolBox.Size = UDim2.new(1, -5, 0, 65)
        ToolBox.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        Instance.new("UICorner", ToolBox).CornerRadius = UDim.new(0, 4)

        -- Tên Tool
        local ToolNameLabel = Instance.new("TextLabel", ToolBox)
        ToolNameLabel.Size = UDim2.new(0.55, 0, 0, 20)
        ToolNameLabel.Position = UDim2.new(0.02, 0, 0.05, 0)
        ToolNameLabel.Text = string.format("🗡️ %s %s", locationTag, tool.Name)
        ToolNameLabel.TextColor3 = isEquipped and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(100, 200, 255)
        ToolNameLabel.BackgroundTransparency = 1
        ToolNameLabel.Font = Enum.Font.SourceSansBold
        ToolNameLabel.TextSize = 10
        ToolNameLabel.TextXAlignment = Enum.TextXAlignment.Left

        -- Nút Copy Tên Vật Phẩm
        local CopyNameBtn = Instance.new("TextButton", ToolBox)
        CopyNameBtn.Size = UDim2.new(0.38, 0, 0, 18)
        CopyNameBtn.Position = UDim2.new(0.60, 0, 0.05, 0)
        CopyNameBtn.Text = "📋 Copy Tên Item"
        CopyNameBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        CopyNameBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyNameBtn.Font = Enum.Font.SourceSansBold
        CopyNameBtn.TextSize = 9
        Instance.new("UICorner", CopyNameBtn).CornerRadius = UDim.new(0, 3)

        CopyNameBtn.MouseButton1Click:Connect(function()
            setclipboard(tool.Name)
            CopyNameBtn.Text = "✓ Đã Copy Tên"
            task.wait(1)
            CopyNameBtn.Text = "📋 Copy Tên Item"
        end)

        -- Cây Script Inside
        local scriptsInside = {}
        for _, desc in pairs(tool:GetDescendants()) do
            if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
                table.insert(scriptsInside, desc)
            end
        end

        local ScriptScroll = Instance.new("ScrollingFrame", ToolBox)
        ScriptScroll.Size = UDim2.new(0.96, 0, 0, 36)
        ScriptScroll.Position = UDim2.new(0.02, 0, 0.38, 0)
        ScriptScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        ScriptScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        ScriptScroll.ScrollBarThickness = 2

        local ScriptListUI = Instance.new("UIListLayout", ScriptScroll)
        ScriptListUI.SortOrder = Enum.SortOrder.LayoutOrder
        ScriptListUI.Padding = UDim.new(0, 2)

        if #scriptsInside == 0 then
            local NoScrLabel = Instance.new("TextLabel", ScriptScroll)
            NoScrLabel.Size = UDim2.new(1, 0, 1, 0)
            NoScrLabel.Text = "   (Không có script nào bên trong)"
            NoScrLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
            NoScrLabel.BackgroundTransparency = 1
            NoScrLabel.Font = Enum.Font.SourceSansItalic
            NoScrLabel.TextSize = 9
            NoScrLabel.TextXAlignment = Enum.TextXAlignment.Left
        else
            for _, scr in pairs(scriptsInside) do
                local ScrFrame = Instance.new("Frame", ScriptScroll)
                ScrFrame.Size = UDim2.new(1, -4, 0, 18)
                ScrFrame.BackgroundTransparency = 1

                local ScrLabel = Instance.new("TextLabel", ScrFrame)
                ScrLabel.Size = UDim2.new(0.6, 0, 1, 0)
                ScrLabel.Position = UDim2.new(0.02, 0, 0, 0)
                ScrLabel.Text = string.format("📜 %s (%s)", scr.Name, scr.ClassName)
                ScrLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
                ScrLabel.BackgroundTransparency = 1
                ScrLabel.Font = Enum.Font.SourceSans
                ScrLabel.TextSize = 9
                ScrLabel.TextXAlignment = Enum.TextXAlignment.Left

                -- Nút Copy Code Script
                local CopyCodeBtn = Instance.new("TextButton", ScrFrame)
                CopyCodeBtn.Size = UDim2.new(0.35, 0, 0.9, 0)
                CopyCodeBtn.Position = UDim2.new(0.63, 0, 0.05, 0)
                CopyCodeBtn.Text = "Copy Code"
                CopyCodeBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
                CopyCodeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                CopyCodeBtn.Font = Enum.Font.SourceSansBold
                CopyCodeBtn.TextSize = 8
                Instance.new("UICorner", CopyCodeBtn).CornerRadius = UDim.new(0, 3)

                CopyCodeBtn.MouseButton1Click:Connect(function()
                    local code = getScriptSource(scr)
                    setclipboard(code)
                    CopyCodeBtn.Text = "✓ Copied Code"
                    task.wait(1)
                    CopyCodeBtn.Text = "Copy Code"
                end)
            end
        end

        ScriptScroll.CanvasSize = UDim2.new(0, 0, 0, ScriptListUI.AbsoluteContentSize.Y)
    end
end

local function updatePlayerInspector()
    for _, child in pairs(PlayerScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end

    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hum and hum.Health > 0 then
            local pos = char:GetPivot().Position
            local healthStr = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))

            local CardFrame = Instance.new("Frame", PlayerScroll)
            CardFrame.Size = UDim2.new(1, -5, 0, 150)
            CardFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", CardFrame).CornerRadius = UDim.new(0, 5)

            -- Player Header
            local HeaderLabel = Instance.new("TextLabel", CardFrame)
            HeaderLabel.Size = UDim2.new(0.58, 0, 0, 22)
            HeaderLabel.Position = UDim2.new(0.02, 0, 0.02, 0)
            HeaderLabel.Text = string.format("👤 %s | %s", plr.DisplayName, healthStr)
            HeaderLabel.TextColor3 = (plr == LocalPlayer) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 200, 50)
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Font = Enum.Font.SourceSansBold
            HeaderLabel.TextSize = 11
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left

            -- Nút ESP Player
            local PESPBtn = Instance.new("TextButton", CardFrame)
            PESPBtn.Size = UDim2.new(0.18, 0, 0.14, 0)
            PESPBtn.Position = UDim2.new(0.61, 0, 0.03, 0)
            PESPBtn.Text = playerESPFolders[plr] and "ESP: ON" or "ESP: OFF"
            PESPBtn.BackgroundColor3 = playerESPFolders[plr] and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(70, 70, 70)
            PESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PESPBtn.Font = Enum.Font.SourceSansBold
            PESPBtn.TextSize = 9
            Instance.new("UICorner", PESPBtn).CornerRadius = UDim.new(0, 4)

            PESPBtn.MouseButton1Click:Connect(function()
                local status = togglePlayerESP(plr)
                PESPBtn.Text = status and "ESP: ON" or "ESP: OFF"
                PESPBtn.BackgroundColor3 = status and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(70, 70, 70)
            end)

            -- Nút Teleport Tới Player
            local PTPBtn = Instance.new("TextButton", CardFrame)
            PTPBtn.Size = UDim2.new(0.17, 0, 0.14, 0)
            PTPBtn.Position = UDim2.new(0.80, 0, 0.03, 0)
            PTPBtn.Text = "TP Tới"
            PTPBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            PTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PTPBtn.Font = Enum.Font.SourceSansBold
            PTPBtn.TextSize = 9
            Instance.new("UICorner", PTPBtn).CornerRadius = UDim.new(0, 4)

            PTPBtn.MouseButton1Click:Connect(function()
                teleportTo(pos + Vector3.new(0, 3, 0))
            end)

            -- Khung Chứa Danh Sách Vật Phẩm
            local ItemsContainer = Instance.new("ScrollingFrame", CardFrame)
            ItemsContainer.Size = UDim2.new(0.96, 0, 0, 118)
            ItemsContainer.Position = UDim2.new(0.02, 0, 0.18, 0)
            ItemsContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
            ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
            ItemsContainer.ScrollBarThickness = 3

            local ItemsUIList = Instance.new("UIListLayout", ItemsContainer)
            ItemsUIList.SortOrder = Enum.SortOrder.LayoutOrder
            ItemsUIList.Padding = UDim.new(0, 4)

            buildToolItemsList(plr, ItemsContainer)
            ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, ItemsUIList.AbsoluteContentSize.Y)
        end
    end
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerUIList.AbsoluteContentSize.Y)
end

-- VÒNG LẶP CẬP NHẬT AUTOMATIC
task.spawn(function()
    while task.wait(1.5) do
        if MainFrame.Visible then
            if Page2.Visible then updateNPCList() end
            if Page3.Visible then updateModelList() end
            if Page4.Visible then updatePlayerInspector() end
        end
    end
end)
