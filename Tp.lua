-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Bảng lưu trữ tọa độ đã lưu
local savedWaypoints = {}

--------------------------------------------------------------------------------
-- 1. TẠO GIAO DIỆN (UI)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WaypointAndEggTPGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "TP Trứng & Lưu Tọa Độ"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 55, 0, 22)
RefreshBtn.Position = UDim2.new(1, -60, 0, 5)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
RefreshBtn.Text = "Quét Map"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 11
RefreshBtn.Parent = MainFrame

local BtnCorner1 = Instance.new("UICorner")
BtnCorner1.CornerRadius = UDim.new(0, 4)
BtnCorner1.Parent = RefreshBtn

--------------------------------------------------------------------------------
-- 2. KHUNG LƯU TỌA ĐỘ BẰNG TAY (WAYPOINT INPUT)
--------------------------------------------------------------------------------
local SaveFrame = Instance.new("Frame")
SaveFrame.Size = UDim2.new(1, -20, 0, 35)
SaveFrame.Position = UDim2.new(0, 10, 0, 35)
SaveFrame.BackgroundTransparency = 1
SaveFrame.Parent = MainFrame

local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(0.65, -5, 1, 0)
NameBox.Position = UDim2.new(0, 0, 0, 0)
NameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
NameBox.PlaceholderText = "Nhập tên điểm..."
NameBox.Text = ""
NameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NameBox.Font = Enum.Font.SourceSans
NameBox.TextSize = 13
NameBox.Parent = SaveFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 4)
BoxCorner.Parent = NameBox

local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0.35, 0, 1, 0)
SaveBtn.Position = UDim2.new(0.65, 5, 0, 0)
SaveBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
SaveBtn.Text = "+ Lưu Vị Trí"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.Font = Enum.Font.SourceSansBold
SaveBtn.TextSize = 12
SaveBtn.Parent = SaveFrame

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 4)
SaveCorner.Parent = SaveBtn

--------------------------------------------------------------------------------
-- 3. KHUNG CUỘN DANH SÁCH (SCROLLING FRAME)
--------------------------------------------------------------------------------
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -80)
ScrollFrame.Position = UDim2.new(0, 5, 0, 75)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

--------------------------------------------------------------------------------
-- 4. HÀM DỊCH CHUYỂN & TẠO NÚT BẤM
--------------------------------------------------------------------------------
local function teleportTo(targetCFrame)
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if hrp and targetCFrame then
            hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
        end
    end
end

local function createTpButton(name, getCFrameFunc, color, isCustomWaypoint)
    local btnFrame = Instance.new("Frame")
    btnFrame.Size = UDim2.new(1, -8, 0, 28)
    btnFrame.BackgroundTransparency = 1
    btnFrame.Parent = ScrollFrame

    local mainBtn = Instance.new("TextButton")
    mainBtn.Size = isCustomWaypoint and UDim2.new(1, -32, 1, 0) or UDim2.new(1, 0, 1, 0)
    mainBtn.Position = UDim2.new(0, 0, 0, 0)
    mainBtn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    mainBtn.Text = name
    mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainBtn.Font = Enum.Font.SourceSans
    mainBtn.TextSize = 13
    mainBtn.Parent = btnFrame

    local corner1 = Instance.new("UICorner")
    corner1.CornerRadius = UDim.new(0, 4)
    corner1.Parent = mainBtn

    mainBtn.MouseButton1Click:Connect(function()
        local cf = getCFrameFunc()
        if cf then teleportTo(cf) end
    end)

    -- Nút xóa (chỉ xuất hiện đối với các điểm do người chơi tự lưu)
    if isCustomWaypoint then
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0, 28, 1, 0)
        delBtn.Position = UDim2.new(1, -28, 0, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.SourceSansBold
        delBtn.TextSize = 12
        delBtn.Parent = btnFrame

        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(0, 4)
        corner2.Parent = delBtn

        delBtn.MouseButton1Click:Connect(function()
            savedWaypoints[name] = nil
            btnFrame:Destroy()
            task.wait(0.05)
            ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
        end)
    end
end

--------------------------------------------------------------------------------
-- 5. LOGIC QUÉT TRỨNG, VẬT THỂ VÀ HIỂN THỊ TỌA ĐỘ ĐÃ LƯU
--------------------------------------------------------------------------------
local keywords = {"egg", "pet", "animal", "mob", "chest", "orb", "coin", "gem", "crystal", "spawn"}
local ignoredNames = {["Baseplate"] = true, ["Terrain"] = true, ["Camera"] = true, ["Workspace"] = true}

local function renderAll()
    -- Clear danh sách cũ
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- 1. HIỂN THỊ CÁC TỌA ĐỘ DO NGƯỜI CHƠI LƯU TRƯỚC (Màu vàng da cam)
    for wpName, cf in pairs(savedWaypoints) do
        createTpButton("[Đã Lưu] " .. wpName, function()
            return cf
        end, Color3.fromRGB(180, 100, 20), true)
    end

    -- 2. QUÉT TRỨNG VÀ VẬT THỂ TỪ MAP
    local foundObjects = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not ignoredNames[obj.Name] and not Players:GetPlayerFromCharacter(obj) then
            local objNameLower = string.lower(obj.Name)
            local isMatch = false
            for _, key in ipairs(keywords) do
                if string.find(objNameLower, key) then
                    isMatch = true
                    break
                end
            end

            if isMatch then
                local targetModel = obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model") or obj
                if not foundObjects[targetModel] then
                    foundObjects[targetModel] = true

                    local isEgg = string.find(string.lower(targetModel.Name), "egg")
                    local btnColor = isEgg and Color3.fromRGB(130, 60, 180) or Color3.fromRGB(60, 80, 90)

                    createTpButton("[" .. targetModel.ClassName .. "] " .. targetModel.Name, function()
                        if targetModel:IsA("Model") then
                            return targetModel:GetPivot()
                        elseif targetModel:IsA("BasePart") then
                            return targetModel.CFrame
                        end
                        return nil
                    end, btnColor, false)
                end
            end
        end
    end

    -- Cập nhật kích thước khung cuộn
    task.wait(0.05)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

-- Sự kiện bấm nút "+ Lưu Vị Trí"
SaveBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local nameText = NameBox.Text ~= "" and NameBox.Text or ("Điểm " .. tostring(#savedWaypoints + 1))
        savedWaypoints[nameText] = char.HumanoidRootPart.CFrame
        NameBox.Text = "" -- Reset ô nhập
        renderAll() -- Render lại danh sách
    end
end)

-- Sự kiện bấm nút "Quét Map"
RefreshBtn.MouseButton1Click:Connect(renderAll)

-- Chạy lần đầu
renderAll()
