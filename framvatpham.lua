-- tookit – nâng cấp với lọc "slot" và Auto Return mặc định
-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Bảng lưu trữ tọa độ đã lưu
local savedWaypoints = {}

-- Biến cho Auto Return
local returnPoint = nil            -- CFrame điểm về
local autoReturnEnabled = true     -- Bật mặc định để tự động quay về
local returnDelay = 1              -- Thời gian chờ (giây) trước khi quay về

--------------------------------------------------------------------------------
-- 1. TẠO GIAO DIỆN (UI)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WaypointAndEggTPGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 480)
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
-- 2. KHUNG ĐIỀU KHIỂN AUTO RETURN
--------------------------------------------------------------------------------
local ControlFrame = Instance.new("Frame")
ControlFrame.Size = UDim2.new(1, -20, 0, 30)
ControlFrame.Position = UDim2.new(0, 10, 0, 35)
ControlFrame.BackgroundTransparency = 1
ControlFrame.Parent = MainFrame

-- Nút "Set Return"
local SetReturnBtn = Instance.new("TextButton")
SetReturnBtn.Size = UDim2.new(0, 70, 1, 0)
SetReturnBtn.Position = UDim2.new(0, 0, 0, 0)
SetReturnBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
SetReturnBtn.Text = "Đặt Điểm Về"
SetReturnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetReturnBtn.Font = Enum.Font.SourceSansBold
SetReturnBtn.TextSize = 11
SetReturnBtn.Parent = ControlFrame

local SetCorner = Instance.new("UICorner")
SetCorner.CornerRadius = UDim.new(0, 4)
SetCorner.Parent = SetReturnBtn

-- Nút "Return"
local ReturnBtn = Instance.new("TextButton")
ReturnBtn.Size = UDim2.new(0, 60, 1, 0)
ReturnBtn.Position = UDim2.new(0, 75, 0, 0)
ReturnBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
ReturnBtn.Text = "Quay Về"
ReturnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ReturnBtn.Font = Enum.Font.SourceSansBold
ReturnBtn.TextSize = 11
ReturnBtn.Parent = ControlFrame

local ReturnCorner = Instance.new("UICorner")
ReturnCorner.CornerRadius = UDim.new(0, 4)
ReturnCorner.Parent = ReturnBtn

-- Nút toggle Auto Return
local AutoToggle = Instance.new("TextButton")
AutoToggle.Size = UDim2.new(0, 70, 1, 0)
AutoToggle.Position = UDim2.new(0, 140, 0, 0)
AutoToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 80)  -- mặc định bật
AutoToggle.Text = "Auto: BẬT"
AutoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoToggle.Font = Enum.Font.SourceSansBold
AutoToggle.TextSize = 11
AutoToggle.Parent = ControlFrame

local AutoCorner = Instance.new("UICorner")
AutoCorner.CornerRadius = UDim.new(0, 4)
AutoCorner.Parent = AutoToggle

-- Ô nhập delay
local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0, 40, 1, 0)
DelayBox.Position = UDim2.new(0, 215, 0, 0)
DelayBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
DelayBox.PlaceholderText = "1s"
DelayBox.Text = "1"
DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayBox.Font = Enum.Font.SourceSans
DelayBox.TextSize = 13
DelayBox.Parent = ControlFrame

local DelayCorner = Instance.new("UICorner")
DelayCorner.CornerRadius = UDim.new(0, 4)
DelayCorner.Parent = DelayBox

--------------------------------------------------------------------------------
-- 3. KHUNG LƯU TỌA ĐỘ BẰNG TAY
--------------------------------------------------------------------------------
local SaveFrame = Instance.new("Frame")
SaveFrame.Size = UDim2.new(1, -20, 0, 35)
SaveFrame.Position = UDim2.new(0, 10, 0, 70)
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
-- 4. KHUNG CUỘN DANH SÁCH
--------------------------------------------------------------------------------
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -120)
ScrollFrame.Position = UDim2.new(0, 5, 0, 110)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

--------------------------------------------------------------------------------
-- 5. HÀM DỊCH CHUYỂN & TẠO NÚT BẤM
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

local function teleportWithReturn(targetCFrame)
    if autoReturnEnabled then
        -- Nếu chưa có điểm về, tự động lưu vị trí hiện tại
        if not returnPoint then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                returnPoint = char.HumanoidRootPart.CFrame
            else
                -- Không có nhân vật, vẫn TP nhưng không về được
                teleportTo(targetCFrame)
                return
            end
        end
        teleportTo(targetCFrame)
        task.delay(returnDelay, function()
            if returnPoint then
                teleportTo(returnPoint)
            end
        end)
    else
        teleportTo(targetCFrame)
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
        if cf then 
            teleportWithReturn(cf)
        end
    end)

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
-- 6. LOGIC QUÉT TRỨNG, VẬT THỂ (có lọc "slot")
--------------------------------------------------------------------------------
local keywords = {"egg", "pet", "animal", "mob", "chest", "orb", "coin", "gem", "crystal", "spawn"}
local ignoredNames = {
    ["Baseplate"] = true,
    ["Terrain"] = true,
    ["Camera"] = true,
    ["Workspace"] = true
}
-- Thêm lọc theo tên chứa "slot" (không phân biệt hoa thường)
local function isSlotName(name)
    return string.find(string.lower(name), "slot") ~= nil
end

local function renderAll()
    -- Clear danh sách cũ
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- 1. HIỂN THỊ CÁC TỌA ĐỘ ĐÃ LƯU
    for wpName, cf in pairs(savedWaypoints) do
        createTpButton("[Đã Lưu] " .. wpName, function()
            return cf
        end, Color3.fromRGB(180, 100, 20), true)
    end

    -- 2. QUÉT TRỨNG VÀ VẬT THỂ (bỏ qua "slot")
    local foundObjects = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        -- Bỏ qua các đối tượng có tên bị cấm hoặc chứa "slot"
        if not ignoredNames[obj.Name] and not isSlotName(obj.Name) and not Players:GetPlayerFromCharacter(obj) then
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

    task.wait(0.05)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
end

--------------------------------------------------------------------------------
-- 7. SỰ KIỆN CHO CÁC NÚT ĐIỀU KHIỂN
--------------------------------------------------------------------------------
SetReturnBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        returnPoint = char.HumanoidRootPart.CFrame
        SetReturnBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.delay(0.5, function()
            SetReturnBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        end)
    end
end)

ReturnBtn.MouseButton1Click:Connect(function()
    if returnPoint then
        teleportTo(returnPoint)
    end
end)

AutoToggle.MouseButton1Click:Connect(function()
    autoReturnEnabled = not autoReturnEnabled
    if autoReturnEnabled then
        AutoToggle.Text = "Auto: BẬT"
        AutoToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    else
        AutoToggle.Text = "Auto: TẮT"
        AutoToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

DelayBox.FocusLost:Connect(function()
    local val = tonumber(DelayBox.Text)
    if val and val > 0 then
        returnDelay = val
    else
        DelayBox.Text = tostring(returnDelay)
    end
end)

SaveBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local nameText = NameBox.Text ~= "" and NameBox.Text or ("Điểm " .. tostring(#savedWaypoints + 1))
        savedWaypoints[nameText] = char.HumanoidRootPart.CFrame
        NameBox.Text = ""
        renderAll()
    end
end)

RefreshBtn.MouseButton1Click:Connect(renderAll)

-- Chạy lần đầu
renderAll()
