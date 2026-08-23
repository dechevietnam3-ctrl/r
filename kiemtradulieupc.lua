--=========================================================  
-- ULTIMATE 9-TAB CUSTOM TOOLKIT v12.0 (NÂNG CẤP THEO YÊU CẦU)  
-- Toggle Hotkey: Right Control  
--=========================================================  

local Players = game:GetService("Players")  
local Workspace = game:GetService("Workspace")  
local UserInputService = game:GetService("UserInputService")  
local LogService = game:GetService("LogService")  
local TweenService = game:GetService("TweenService")  
local HttpService = game:GetService("HttpService")  
local CoreGui = game:GetService("CoreGui")  
local LocalPlayer = Players.LocalPlayer  

local function getScriptCode(scr)  
    if decompile then  
        local success, code = pcall(function() return decompile(scr) end)  
        if success and code and #code > 0 then return code end  
    end  
    if (scr:IsA("LocalScript") or scr:IsA("ModuleScript")) and scr.Source and #scr.Source > 0 then   
        return scr.Source   
    end  
    return "-- [Không thể decompile hoặc đọc source của script này]"  
end  

local ScreenGui = Instance.new("ScreenGui")  
ScreenGui.Name = "CustomInspectorUI_v12_0"  
ScreenGui.ResetOnSpawn = false  

if gethui then  
    ScreenGui.Parent = gethui()  
elseif syn and syn.protect_gui then  
    syn.protect_gui(ScreenGui)  
    ScreenGui.Parent = CoreGui  
else  
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")  
end  

-- MAIN FRAME  
local MainFrame = Instance.new("Frame", ScreenGui)  
MainFrame.Size = UDim2.new(0, 680, 0, 480)  
MainFrame.Position = UDim2.new(0.5, -340, 0.5, -240)  
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)  
MainFrame.Active = true  
MainFrame.Draggable = true  
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)  

local MainStroke = Instance.new("UIStroke", MainFrame)  
MainStroke.Color = Color3.fromRGB(0, 255, 170)  
MainStroke.Thickness = 1.2  

-- MINI BAR  
local MiniFrame = Instance.new("Frame", ScreenGui)  
MiniFrame.Size = UDim2.new(0, 220, 0, 32)  
MiniFrame.Position = UDim2.new(0.5, -110, 0.05, 0)  
MiniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)  
MiniFrame.Active = true  
MiniFrame.Draggable = true  
MiniFrame.Visible = false  
Instance.new("UICorner", MiniFrame).CornerRadius = UDim.new(0, 6)  

local MiniStroke = Instance.new("UIStroke", MiniFrame)  
MiniStroke.Color = Color3.fromRGB(0, 255, 170)  
MiniStroke.Thickness = 1.2  

local MiniTitle = Instance.new("TextLabel", MiniFrame)  
MiniTitle.Size = UDim2.new(1, -40, 1, 0)  
MiniTitle.Position = UDim2.new(0, 8, 0, 0)  
MiniTitle.Text = "🚀 TOOLKIT v12.0"  
MiniTitle.TextColor3 = Color3.fromRGB(0, 255, 170)  
MiniTitle.BackgroundTransparency = 1  
MiniTitle.Font = Enum.Font.SourceSansBold  
MiniTitle.TextSize = 12  
MiniTitle.TextXAlignment = Enum.TextXAlignment.Left  

local ExpandBtn = Instance.new("TextButton", MiniFrame)  
ExpandBtn.Size = UDim2.new(0, 24, 0, 22)  
ExpandBtn.Position = UDim2.new(1, -28, 0, 5)  
ExpandBtn.Text = "🗖"  
ExpandBtn.TextColor3 = Color3.fromRGB(0, 255, 170)  
ExpandBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)  
ExpandBtn.Font = Enum.Font.SourceSansBold  
ExpandBtn.TextSize = 12  
Instance.new("UICorner", ExpandBtn).CornerRadius = UDim.new(0, 4)  

-- HEADER  
local TitleLabel = Instance.new("TextLabel", MainFrame)  
TitleLabel.Size = UDim2.new(1, -100, 0, 32)  
TitleLabel.Position = UDim2.new(0, 12, 0, 0)  
TitleLabel.Text = "🚀 ULTIMATE TOOLKIT v12.0 (NÂNG CẤP THEO YÊU CẦU)"  
TitleLabel.TextColor3 = Color3.fromRGB(0, 255, 170)  
TitleLabel.BackgroundTransparency = 1  
TitleLabel.Font = Enum.Font.SourceSansBold  
TitleLabel.TextSize = 13  
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left  

local MinimizeBtn = Instance.new("TextButton", MainFrame)  
MinimizeBtn.Size = UDim2.new(0, 26, 0, 22)  
MinimizeBtn.Position = UDim2.new(1, -60, 0, 5)  
MinimizeBtn.Text = "—"  
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 200, 50)  
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)  
MinimizeBtn.Font = Enum.Font.SourceSansBold  
MinimizeBtn.TextSize = 12  
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)  

local CloseBtn = Instance.new("TextButton", MainFrame)  
CloseBtn.Size = UDim2.new(0, 26, 0, 22)  
CloseBtn.Position = UDim2.new(1, -30, 0, 5)  
CloseBtn.Text = "✕"  
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)  
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)  
CloseBtn.Font = Enum.Font.SourceSansBold  
CloseBtn.TextSize = 12  
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)  

MinimizeBtn.MouseButton1Click:Connect(function()  
    MainFrame.Visible = false  
    MiniFrame.Visible = true  
end)  

ExpandBtn.MouseButton1Click:Connect(function()  
    MiniFrame.Visible = false  
    MainFrame.Visible = true  
end)  

CloseBtn.MouseButton1Click:Connect(function()  
    MainFrame.Visible = false  
    MiniFrame.Visible = false  
end)  

UserInputService.InputBegan:Connect(function(input, gpe)  
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then  
        if MiniFrame.Visible then  
            MiniFrame.Visible = false  
            MainFrame.Visible = true  
        else  
            MainFrame.Visible = not MainFrame.Visible  
        end  
    end  
end)  

-- NAVIGATION  
local TabBar = Instance.new("Frame", MainFrame)  
TabBar.Size = UDim2.new(1, -16, 0, 30)  
TabBar.Position = UDim2.new(0, 8, 0, 34)  
TabBar.BackgroundTransparency = 1  

local TabListUI = Instance.new("UIListLayout", TabBar)  
TabListUI.FillDirection = Enum.FillDirection.Horizontal  
TabListUI.Padding = UDim.new(0, 3)  

local ContentContainer = Instance.new("Frame", MainFrame)  
ContentContainer.Size = UDim2.new(1, -16, 1, -74)  
ContentContainer.Position = UDim2.new(0, 8, 0, 68)  
ContentContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 12)  
Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 6)  

local pages = {}  
local tabButtons = {}  

local function createTab(name, id)  
    local btn = Instance.new("TextButton", TabBar)  
    btn.Size = UDim2.new(0.108, -1, 1, 0)  
    btn.Text = name  
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)  
    btn.TextColor3 = Color3.fromRGB(150, 150, 160)  
    btn.Font = Enum.Font.SourceSansBold  
    btn.TextSize = 9  
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)  

    local page = Instance.new("Frame", ContentContainer)  
    page.Size = UDim2.new(1, -10, 1, -10)  
    page.Position = UDim2.new(0, 5, 0, 5)  
    page.BackgroundTransparency = 1  
    page.Visible = false  

    pages[id] = page  
    tabButtons[id] = btn  

    btn.MouseButton1Click:Connect(function()  
        for pageId, p in pairs(pages) do  
            p.Visible = (pageId == id)  
            tabButtons[pageId].BackgroundColor3 = (pageId == id) and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(22, 22, 26)  
            tabButtons[pageId].TextColor3 = (pageId == id) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)  
        end  
    end)  
    return page  
end  

local Page1 = createTab("1. Tọa Độ", 1)  
local Page2 = createTab("2. NPC Radar", 2)  
local Page3 = createTab("3. Blocks", 3)  
local Page4 = createTab("4. Backpack", 4)  
local Page5 = createTab("5. Stats Pro", 5)  
local Page6 = createTab("6. Spy Pro", 6)  
local Page7 = createTab("7. Console", 7)  
local Page8 = createTab("8. GUI Master", 8)  
local Page9 = createTab("9. Hitbox", 9)  

--=========================================================  
-- TAB 1: TỌA ĐỘ & WAYPOINTS + PHÁT HIỆN DỊCH CHUYỂN BẤT THƯỜNG  
--=========================================================  
local PosLabel = Instance.new("TextLabel", Page1)  
PosLabel.Size = UDim2.new(1, 0, 0, 28); PosLabel.Text = "X: 0 | Y: 0 | Z: 0 | Yaw: 0°"; PosLabel.TextColor3 = Color3.fromRGB(0, 255, 200); PosLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22); PosLabel.Font = Enum.Font.SourceSansBold; PosLabel.TextSize = 11; Instance.new("UICorner", PosLabel).CornerRadius = UDim.new(0, 4)  

local SpeedInput = Instance.new("TextBox", Page1)  
SpeedInput.Size = UDim2.new(0.15, 0, 0, 22); SpeedInput.Position = UDim2.new(0, 0, 0, 32); SpeedInput.PlaceholderText = "Tốc độ"; SpeedInput.Text = "60"; SpeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30); SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255); SpeedInput.Font = Enum.Font.SourceSans; SpeedInput.TextSize = 9; Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 4)  

local CopyVecBtn = Instance.new("TextButton", Page1); CopyVecBtn.Size = UDim2.new(0.14, 0, 0, 22); CopyVecBtn.Position = UDim2.new(0.17, 0, 0, 32); CopyVecBtn.Text = "📋 Vec3"; CopyVecBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170); CopyVecBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyVecBtn.Font = Enum.Font.SourceSansBold; CopyVecBtn.TextSize = 8; Instance.new("UICorner", CopyVecBtn).CornerRadius = UDim.new(0, 4)  
local CopyCFBtn = Instance.new("TextButton", Page1); CopyCFBtn.Size = UDim2.new(0.14, 0, 0, 22); CopyCFBtn.Position = UDim2.new(0.32, 0, 0, 32); CopyCFBtn.Text = "📋 CFrame"; CopyCFBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 160); CopyCFBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyCFBtn.Font = Enum.Font.SourceSansBold; CopyCFBtn.TextSize = 8; Instance.new("UICorner", CopyCFBtn).CornerRadius = UDim.new(0, 4)  
local ExportWpBtn = Instance.new("TextButton", Page1); ExportWpBtn.Size = UDim2.new(0.14, 0, 0, 22); ExportWpBtn.Position = UDim2.new(0.47, 0, 0, 32); ExportWpBtn.Text = "📤 Export"; ExportWpBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0); ExportWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ExportWpBtn.Font = Enum.Font.SourceSansBold; ExportWpBtn.TextSize = 8; Instance.new("UICorner", ExportWpBtn).CornerRadius = UDim.new(0, 4)  
local ImportWpBtn = Instance.new("TextButton", Page1); ImportWpBtn.Size = UDim2.new(0.14, 0, 0, 22); ImportWpBtn.Position = UDim2.new(0.62, 0, 0, 32); ImportWpBtn.Text = "📥 Import"; ImportWpBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 80); ImportWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ImportWpBtn.Font = Enum.Font.SourceSansBold; ImportWpBtn.TextSize = 8; Instance.new("UICorner", ImportWpBtn).CornerRadius = UDim.new(0, 4)  

-- Nút bật/tắt phát hiện dịch chuyển bất thường  
local AbnormalToggle = Instance.new("TextButton", Page1)  
AbnormalToggle.Size = UDim2.new(0.22, 0, 0, 22)  
AbnormalToggle.Position = UDim2.new(0.78, 0, 0, 32)  
AbnormalToggle.Text = "🚨 Theo dõi TP: OFF"  
AbnormalToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
AbnormalToggle.TextColor3 = Color3.fromRGB(255, 255, 255)  
AbnormalToggle.Font = Enum.Font.SourceSansBold  
AbnormalToggle.TextSize = 8  
Instance.new("UICorner", AbnormalToggle).CornerRadius = UDim.new(0, 4)  

local abnormalActive = false  
local lastPos = Vector3.new()  
local abnormalList = {}  

-- Khung hiển thị danh sách dịch chuyển bất thường  
local AbnormalScroll = Instance.new("ScrollingFrame", Page1)  
AbnormalScroll.Size = UDim2.new(1, 0, 0, 80)  
AbnormalScroll.Position = UDim2.new(0, 0, 0, 58)  
AbnormalScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 12)  
AbnormalScroll.CanvasSize = UDim2.new(0, 0, 0, 0)  
AbnormalScroll.ScrollBarThickness = 3  
Instance.new("UICorner", AbnormalScroll).CornerRadius = UDim.new(0, 4)  

local AbnormalListUI = Instance.new("UIListLayout", AbnormalScroll)  
AbnormalListUI.Padding = UDim.new(0, 3)  

local WpScroll = Instance.new("ScrollingFrame", Page1)  
WpScroll.Size = UDim2.new(1, 0, 1, -150)  
WpScroll.Position = UDim2.new(0, 0, 0, 142)  
WpScroll.BackgroundTransparency = 1  
WpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)  
WpScroll.ScrollBarThickness = 3  
local WpListUI = Instance.new("UIListLayout", WpScroll); WpListUI.Padding = UDim.new(0, 4)  

local SaveWpBtn = Instance.new("TextButton", Page1)  
SaveWpBtn.Size = UDim2.new(1, 0, 0, 24)  
SaveWpBtn.Position = UDim2.new(0, 0, 1, -24)  
SaveWpBtn.Text = "📌 Lưu Tọa Độ Hiện Tại Vào Danh Sách"  
SaveWpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)  
SaveWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  
SaveWpBtn.Font = Enum.Font.SourceSansBold  
SaveWpBtn.TextSize = 9  
Instance.new("UICorner", SaveWpBtn).CornerRadius = UDim.new(0, 4)  

local waypoints = {}  

local function tweenTo(cframe)  
    local char = LocalPlayer.Character  
    if char and char:FindFirstChild("HumanoidRootPart") then  
        local hrp = char.HumanoidRootPart  
        local dist = (hrp.Position - cframe.Position).Magnitude  
        local spd = tonumber(SpeedInput.Text) or 60  
        local info = TweenInfo.new(dist / spd, Enum.EasingStyle.Linear)  
        TweenService:Create(hrp, info, {CFrame = cframe}):Play()  
    end  
end  

local function refreshWaypoints()  
    for _, child in pairs(WpScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    for idx, cf in ipairs(waypoints) do  
        local Frame = Instance.new("Frame", WpScroll); Frame.Size = UDim2.new(1, -5, 0, 24); Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)  
        local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(0.55, 0, 1, 0); Label.Position = UDim2.new(0.02, 0, 0, 0); Label.Text = string.format("📍 WP #%d: %.1f, %.1f, %.1f", idx, cf.X, cf.Y, cf.Z); Label.TextColor3 = Color3.fromRGB(200, 200, 200); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.SourceSans; Label.TextSize = 9; Label.TextXAlignment = Enum.TextXAlignment.Left  
        local InstantBtn = Instance.new("TextButton", Frame); InstantBtn.Size = UDim2.new(0.18, 0, 0.75, 0); InstantBtn.Position = UDim2.new(0.58, 0, 0.12, 0); InstantBtn.Text = "⚡ Teleport"; InstantBtn.BackgroundColor3 = Color3.fromRGB(180, 90, 0); InstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255); InstantBtn.Font = Enum.Font.SourceSansBold; InstantBtn.TextSize = 8; Instance.new("UICorner", InstantBtn).CornerRadius = UDim.new(0, 3)  
        local TweenBtn = Instance.new("TextButton", Frame); TweenBtn.Size = UDim2.new(0.18, 0, 0.75, 0); TweenBtn.Position = UDim2.new(0.78, 0, 0.12, 0); TweenBtn.Text = "✈️ Tween"; TweenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180); TweenBtn.TextColor3 = Color3.fromRGB(255, 255, 255); TweenBtn.Font = Enum.Font.SourceSansBold; TweenBtn.TextSize = 8; Instance.new("UICorner", TweenBtn).CornerRadius = UDim.new(0, 3)  

        InstantBtn.MouseButton1Click:Connect(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = cf end end)  
        TweenBtn.MouseButton1Click:Connect(function() tweenTo(cf) end)  
    end  
    WpScroll.CanvasSize = UDim2.new(0, 0, 0, WpListUI.AbsoluteContentSize.Y)  
end  

SaveWpBtn.MouseButton1Click:Connect(function() pcall(function() table.insert(waypoints, LocalPlayer.Character.HumanoidRootPart.CFrame); refreshWaypoints() end) end)  
ExportWpBtn.MouseButton1Click:Connect(function() local data = {}; for _, cf in ipairs(waypoints) do table.insert(data, {cf.X, cf.Y, cf.Z}) end if setclipboard then setclipboard(HttpService:JSONEncode(data)) end end)  
ImportWpBtn.MouseButton1Click:Connect(function() pcall(function() if getclipboard then local data = HttpService:JSONDecode(getclipboard()); waypoints = {}; for _, pos in ipairs(data) do table.insert(waypoints, CFrame.new(pos[1], pos[2], pos[3])) end refreshWaypoints() end end) end)  
CopyVecBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(PosLabel.Text) end end)  
CopyCFBtn.MouseButton1Click:Connect(function() pcall(function() local cf = LocalPlayer.Character.HumanoidRootPart.CFrame; if setclipboard then setclipboard(string.format("CFrame.new(%.2f, %.2f, %.2f)", cf.X, cf.Y, cf.Z)) end end) end)  

AbnormalToggle.MouseButton1Click:Connect(function()  
    abnormalActive = not abnormalActive  
    AbnormalToggle.Text = abnormalActive and "🚨 Theo dõi TP: ON" or "🚨 Theo dõi TP: OFF"  
    AbnormalToggle.BackgroundColor3 = abnormalActive and Color3.fromRGB(180, 80, 0) or Color3.fromRGB(50, 50, 50)  
end)  

local function addAbnormalLog(pos, cframe)  
    local time = os.date("%H:%M:%S")  
    table.insert(abnormalList, {pos = pos, cframe = cframe, time = time})  
    -- Cập nhật giao diện  
    for _, child in pairs(AbnormalScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    for i, data in ipairs(abnormalList) do  
        local Frame = Instance.new("Frame", AbnormalScroll); Frame.Size = UDim2.new(1, -5, 0, 20); Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)  
        local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(0.7, 0, 1, 0); Label.Position = UDim2.new(0.02, 0, 0, 0); Label.Text = string.format("[%s] TP đến (%.1f, %.1f, %.1f)", data.time, data.pos.X, data.pos.Y, data.pos.Z); Label.TextColor3 = Color3.fromRGB(255, 200, 100); Label.BackgroundTransparency = 1; Label.Font = Enum.Font.SourceSans; Label.TextSize = 9; Label.TextXAlignment = Enum.TextXAlignment.Left  
        local TpBtn = Instance.new("TextButton", Frame); TpBtn.Size = UDim2.new(0.25, 0, 0.8, 0); TpBtn.Position = UDim2.new(0.73, 0, 0.1, 0); TpBtn.Text = "Teleport"; TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70); TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); TpBtn.Font = Enum.Font.SourceSansBold; TpBtn.TextSize = 8; Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)  
        TpBtn.MouseButton1Click:Connect(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = data.cframe end end)  
    end  
    AbnormalScroll.CanvasSize = UDim2.new(0, 0, 0, AbnormalListUI.AbsoluteContentSize.Y)  
end  

local function monitorAbnormalTeleport()  
    if not abnormalActive then return end  
    pcall(function()  
        local char = LocalPlayer.Character  
        if char and char:FindFirstChild("HumanoidRootPart") then  
            local hrp = char.HumanoidRootPart  
            local curPos = hrp.Position  
            if lastPos ~= Vector3.new(0,0,0) then  
                local dist = (curPos - lastPos).Magnitude  
                if dist > 100 then -- ngưỡng bất thường  
                    addAbnormalLog(curPos, hrp.CFrame)  
                end  
            end  
            lastPos = curPos  
        end  
    end)  
end  

task.spawn(function()  
    while task.wait(0.2) do  
        pcall(function()  
            local char = LocalPlayer.Character  
            if char and char:FindFirstChild("HumanoidRootPart") then  
                local p = char.HumanoidRootPart.Position  
                local rx, ry, rz = char.HumanoidRootPart.CFrame:ToOrientation()  
                PosLabel.Text = string.format("X: %.2f | Y: %.2f | Z: %.2f | Yaw: %.1f°", p.X, p.Y, p.Z, math.deg(ry))  
            end  
        end)  
        monitorAbnormalTeleport()  
    end  
end)  

--=========================================================  
-- TAB 2: NPC RADAR + SCRIPT TRONG NPC  
--=========================================================  
local NpcSearchBox = Instance.new("TextBox", Page2); NpcSearchBox.Size = UDim2.new(0.38, 0, 0, 24); NpcSearchBox.PlaceholderText = "🔍 Tên NPC..."; NpcSearchBox.Text = ""; NpcSearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28); NpcSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); NpcSearchBox.Font = Enum.Font.SourceSans; NpcSearchBox.TextSize = 10; Instance.new("UICorner", NpcSearchBox).CornerRadius = UDim.new(0, 4)  
local MaxDistBox = Instance.new("TextBox", Page2); MaxDistBox.Size = UDim2.new(0.16, 0, 0, 24); MaxDistBox.Position = UDim2.new(0.40, 0, 0, 0); MaxDistBox.PlaceholderText = "Max Dist..."; MaxDistBox.Text = ""; MaxDistBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28); MaxDistBox.TextColor3 = Color3.fromRGB(255, 255, 255); MaxDistBox.Font = Enum.Font.SourceSans; MaxDistBox.TextSize = 9; Instance.new("UICorner", MaxDistBox).CornerRadius = UDim.new(0, 4)  
local EspToggleBtn = Instance.new("TextButton", Page2); EspToggleBtn.Size = UDim2.new(0.2, 0, 0, 24); EspToggleBtn.Position = UDim2.new(0.58, 0, 0, 0); EspToggleBtn.Text = "👁️ ESP: OFF"; EspToggleBtn.BackgroundColor3 = Color3.fromRGB(140, 35, 35); EspToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); EspToggleBtn.Font = Enum.Font.SourceSansBold; EspToggleBtn.TextSize = 9; Instance.new("UICorner", EspToggleBtn).CornerRadius = UDim.new(0, 4)  
local ShowScriptsToggle = Instance.new("TextButton", Page2); ShowScriptsToggle.Size = UDim2.new(0.2, 0, 0, 24); ShowScriptsToggle.Position = UDim2.new(0.80, 0, 0, 0); ShowScriptsToggle.Text = "📜 Scripts: OFF"; ShowScriptsToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50); ShowScriptsToggle.TextColor3 = Color3.fromRGB(255, 255, 255); ShowScriptsToggle.Font = Enum.Font.SourceSansBold; ShowScriptsToggle.TextSize = 8; Instance.new("UICorner", ShowScriptsToggle).CornerRadius = UDim.new(0, 4)  

local NpcScroll = Instance.new("ScrollingFrame", Page2); NpcScroll.Size = UDim2.new(1, 0, 1, -30); NpcScroll.Position = UDim2.new(0, 0, 0, 30); NpcScroll.BackgroundTransparency = 1; NpcScroll.CanvasSize = UDim2.new(0, 0, 0, 0); NpcScroll.ScrollBarThickness = 3  
local NpcListUI = Instance.new("UIListLayout", NpcScroll); NpcListUI.Padding = UDim.new(0, 4)  
local espActive = false; local espHighlights = {}  
local showScripts = false  

EspToggleBtn.MouseButton1Click:Connect(function()  
    espActive = not espActive  
    EspToggleBtn.Text = espActive and "👁️ ESP: ON" or "👁️ ESP: OFF"  
    EspToggleBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(140, 35, 35)  
    if not espActive then for _, hl in pairs(espHighlights) do if hl then hl:Destroy() end end espHighlights = {} end  
end)  

ShowScriptsToggle.MouseButton1Click:Connect(function()  
    showScripts = not showScripts  
    ShowScriptsToggle.Text = showScripts and "📜 Scripts: ON" or "📜 Scripts: OFF"  
    ShowScriptsToggle.BackgroundColor3 = showScripts and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)  
    updateNpcList()  
end)  

local function updateNpcList()  
    for _, child in pairs(NpcScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
    local filterText = string.lower(NpcSearchBox.Text)  
    local maxDistLimit = tonumber(MaxDistBox.Text) or 999999  

    for _, model in pairs(Workspace:GetDescendants()) do  
        if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(model) then  
            local hum = model:FindFirstChildOfClass("Humanoid")  
            local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart  
            local dist = (myHrp and hrp) and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0  

            if (filterText == "" or string.find(string.lower(model.Name), filterText)) and dist <= maxDistLimit then  
                if espActive and not model:FindFirstChild("NPCHighlight") then  
                    pcall(function()  
                        local hl = Instance.new("Highlight", model); hl.Name = "NPCHighlight"; hl.FillColor = Color3.fromRGB(255, 200, 0); hl.OutlineColor = Color3.fromRGB(255, 0, 0)  
                        table.insert(espHighlights, hl)  
                    end)  
                end  

                local ItemFrame = Instance.new("Frame", NpcScroll); ItemFrame.Size = UDim2.new(1, -5, 0, 28); ItemFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)  
                local InfoText = Instance.new("TextLabel", ItemFrame); InfoText.Size = UDim2.new(0.6, 0, 1, 0); InfoText.Position = UDim2.new(0.02, 0, 0, 0); InfoText.Text = string.format("👾 %s | HP: %d/%d | (%dm)", model.Name, math.floor(hum.Health), math.floor(hum.MaxHealth), dist); InfoText.TextColor3 = Color3.fromRGB(220, 220, 220); InfoText.BackgroundTransparency = 1; InfoText.Font = Enum.Font.SourceSans; InfoText.TextSize = 10; InfoText.TextXAlignment = Enum.TextXAlignment.Left  
                local TpBtn = Instance.new("TextButton", ItemFrame); TpBtn.Size = UDim2.new(0.18, 0, 0.7, 0); TpBtn.Position = UDim2.new(0.62, 0, 0.15, 0); TpBtn.Text = "Teleport"; TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70); TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); TpBtn.Font = Enum.Font.SourceSansBold; TpBtn.TextSize = 9; Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)  
                TpBtn.MouseButton1Click:Connect(function() if myHrp and hrp then myHrp.CFrame = hrp.CFrame * CFrame.new(0, 2, 3) end end)  

                if showScripts then  
                    local scripts = {}  
                    for _, d in pairs(model:GetDescendants()) do  
                        if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then table.insert(scripts, d) end  
                    end  
                    if #scripts > 0 then  
                        local ExpandBtn = Instance.new("TextButton", ItemFrame); ExpandBtn.Size = UDim2.new(0.18, 0, 0.7, 0); ExpandBtn.Position = UDim2.new(0.81, 0, 0.15, 0); ExpandBtn.Text = "📜 Scripts ("..#scripts..")"; ExpandBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150); ExpandBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ExpandBtn.Font = Enum.Font.SourceSansBold; ExpandBtn.TextSize = 8; Instance.new("UICorner", ExpandBtn).CornerRadius = UDim.new(0, 3)  
                        local expanded = false  
                        ExpandBtn.MouseButton1Click:Connect(function()  
                            expanded = not expanded  
                            -- Tạo frame chứa script dưới item  
                            local scriptFrame = ItemFrame:FindFirstChild("ScriptContainer")  
                            if scriptFrame then scriptFrame:Destroy() end  
                            if expanded then  
                                local container = Instance.new("Frame", ItemFrame)  
                                container.Name = "ScriptContainer"  
                                container.Size = UDim2.new(0.98, 0, 0, 0)  
                                container.Position = UDim2.new(0.01, 0, 1, 2)  
                                container.BackgroundColor3 = Color3.fromRGB(15, 15, 20)  
                                container.AutomaticSize = Enum.AutomaticSize.Y  
                                Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)  
                                local listUI = Instance.new("UIListLayout", container); listUI.Padding = UDim.new(0, 3)  
                                for _, scr in ipairs(scripts) do  
                                    local scrFrame = Instance.new("Frame", container); scrFrame.Size = UDim2.new(1, -4, 0, 20); scrFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", scrFrame).CornerRadius = UDim.new(0, 3)  
                                    local scrLabel = Instance.new("TextLabel", scrFrame); scrLabel.Size = UDim2.new(0.7, 0, 1, 0); scrLabel.Position = UDim2.new(0.02, 0, 0, 0); scrLabel.Text = string.format("📜 %s", scr.Name); scrLabel.TextColor3 = Color3.fromRGB(200, 200, 255); scrLabel.BackgroundTransparency = 1; scrLabel.Font = Enum.Font.SourceSans; scrLabel.TextSize = 9; scrLabel.TextXAlignment = Enum.TextXAlignment.Left  
                                    local CopyBtn = Instance.new("TextButton", scrFrame); CopyBtn.Size = UDim2.new(0.28, 0, 0.8, 0); CopyBtn.Position = UDim2.new(0.70, 0, 0.1, 0); CopyBtn.Text = "📋 Copy Code"; CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180); CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyBtn.Font = Enum.Font.SourceSansBold; CopyBtn.TextSize = 8; Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 3)  
                                    CopyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(getScriptCode(scr)) end end)  
                                end  
                                ItemFrame.Size = UDim2.new(1, -5, 0, 28 + container.AbsoluteSize.Y + 4)  
                                NpcScroll.CanvasSize = UDim2.new(0, 0, 0, NpcListUI.AbsoluteContentSize.Y)  
                            else  
                                ItemFrame.Size = UDim2.new(1, -5, 0, 28)  
                            end  
                        end)  
                    end  
                end  
            end  
        end  
    end  
    NpcScroll.CanvasSize = UDim2.new(0, 0, 0, NpcListUI.AbsoluteContentSize.Y)  
end  

--=========================================================  
-- TAB 3: BLOCKS + SCRIPT, ESP, TP, TỌA ĐỘ  
--=========================================================  
local InstantHoldBtn = Instance.new("TextButton", Page3); InstantHoldBtn.Size = UDim2.new(0.24, 0, 0, 24); InstantHoldBtn.Text = "⚡ Hold Time = 0"; InstantHoldBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 0); InstantHoldBtn.TextColor3 = Color3.fromRGB(255, 255, 255); InstantHoldBtn.Font = Enum.Font.SourceSansBold; InstantHoldBtn.TextSize = 9; Instance.new("UICorner", InstantHoldBtn).CornerRadius = UDim.new(0, 4)  
local FirePromptsBtn = Instance.new("TextButton", Page3); FirePromptsBtn.Size = UDim2.new(0.24, 0, 0, 24); FirePromptsBtn.Position = UDim2.new(0.26, 0, 0, 0); FirePromptsBtn.Text = "🔥 Fire Prompts"; FirePromptsBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40); FirePromptsBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FirePromptsBtn.Font = Enum.Font.SourceSansBold; FirePromptsBtn.TextSize = 9; Instance.new("UICorner", FirePromptsBtn).CornerRadius = UDim.new(0, 4)  
local AutoLoopBtn = Instance.new("TextButton", Page3); AutoLoopBtn.Size = UDim2.new(0.24, 0, 0, 24); AutoLoopBtn.Position = UDim2.new(0.52, 0, 0, 0); AutoLoopBtn.Text = "🔄 Loop: OFF"; AutoLoopBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); AutoLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255); AutoLoopBtn.Font = Enum.Font.SourceSansBold; AutoLoopBtn.TextSize = 8; Instance.new("UICorner", AutoLoopBtn).CornerRadius = UDim.new(0, 4)  
local BlockEspToggle = Instance.new("TextButton", Page3); BlockEspToggle.Size = UDim2.new(0.24, 0, 0, 24); BlockEspToggle.Position = UDim2.new(0.78, 0, 0, 0); BlockEspToggle.Text = "🟩 ESP Block: OFF"; BlockEspToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50); BlockEspToggle.TextColor3 = Color3.fromRGB(255, 255, 255); BlockEspToggle.Font = Enum.Font.SourceSansBold; BlockEspToggle.TextSize = 8; Instance.new("UICorner", BlockEspToggle).CornerRadius = UDim.new(0, 4)  
local autoLoopActive = false  
local blockEspActive = false  
local blockHighlights = {}  

local ScanScroll = Instance.new("ScrollingFrame", Page3); ScanScroll.Size = UDim2.new(1, 0, 1, -30); ScanScroll.Position = UDim2.new(0, 0, 0, 30); ScanScroll.BackgroundTransparency = 1; ScanScroll.CanvasSize = UDim2.new(0, 0, 0, 0); ScanScroll.ScrollBarThickness = 3  
local ScanListUI = Instance.new("UIListLayout", ScanScroll); ScanListUI.Padding = UDim.new(0, 4)  

AutoLoopBtn.MouseButton1Click:Connect(function()  
    autoLoopActive = not autoLoopActive  
    AutoLoopBtn.Text = autoLoopActive and "🔄 Loop: ON" or "🔄 Loop: OFF"  
    AutoLoopBtn.BackgroundColor3 = autoLoopActive and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)  
end)  

BlockEspToggle.MouseButton1Click:Connect(function()  
    blockEspActive = not blockEspActive  
    BlockEspToggle.Text = blockEspActive and "🟩 ESP Block: ON" or "🟩 ESP Block: OFF"  
    BlockEspToggle.BackgroundColor3 = blockEspActive and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)  
    if not blockEspActive then  
        for _, hl in pairs(blockHighlights) do if hl then hl:Destroy() end end  
        blockHighlights = {}  
    else  
        updateBlockScanner()  
    end  
end)  

task.spawn(function()  
    while task.wait(0.5) do  
        if autoLoopActive then  
            pcall(function()  
                for _, prompt in pairs(Workspace:GetDescendants()) do  
                    if prompt:IsA("ProximityPrompt") and fireproximityprompt then fireproximityprompt(prompt) end  
                end  
            end)  
        end  
    end  
end)  

InstantHoldBtn.MouseButton1Click:Connect(function() pcall(function() for _, prompt in pairs(Workspace:GetDescendants()) do if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end end end) end)  
FirePromptsBtn.MouseButton1Click:Connect(function() pcall(function() for _, prompt in pairs(Workspace:GetDescendants()) do if prompt:IsA("ProximityPrompt") and fireproximityprompt then fireproximityprompt(prompt) end end end) end)  

local function updateBlockScanner()  
    for _, child in pairs(ScanScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    if blockEspActive then  
        for _, hl in pairs(blockHighlights) do if hl then hl:Destroy() end end  
        blockHighlights = {}  
    end  
    for _, obj in pairs(Workspace:GetDescendants()) do  
        if obj:IsA("BasePart") then  
            -- Tìm script liên quan  
            local scripts = {}  
            for _, d in pairs(obj:GetDescendants()) do if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then table.insert(scripts, d) end end  

            if blockEspActive then  
                pcall(function()  
                    local hl = Instance.new("Highlight", obj); hl.Name = "BlockHighlight"; hl.FillColor = Color3.fromRGB(0, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 255, 255)  
                    table.insert(blockHighlights, hl)  
                end)  
            end  

            local ItemFrame = Instance.new("Frame", ScanScroll); ItemFrame.Size = UDim2.new(1, -5, 0, 26 + (#scripts > 0 and 18 or 0)); ItemFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)  
            local InfoText = Instance.new("TextLabel", ItemFrame); InfoText.Size = UDim2.new(0.5, 0, 0.5, 0); InfoText.Position = UDim2.new(0.02, 0, 0, 0); InfoText.Text = string.format("📦 %s [%s]\n(%.1f, %.1f, %.1f)", obj.Name, obj.ClassName, obj.Position.X, obj.Position.Y, obj.Position.Z); InfoText.TextColor3 = Color3.fromRGB(200, 200, 200); InfoText.BackgroundTransparency = 1; InfoText.Font = Enum.Font.SourceSans; InfoText.TextSize = 9; InfoText.TextXAlignment = Enum.TextXAlignment.Left  
            local TpBtn = Instance.new("TextButton", ItemFrame); TpBtn.Size = UDim2.new(0.16, 0, 0.4, 0); TpBtn.Position = UDim2.new(0.54, 0, 0.05, 0); TpBtn.Text = "Teleport"; TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70); TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255); TpBtn.Font = Enum.Font.SourceSansBold; TpBtn.TextSize = 8; Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)  
            TpBtn.MouseButton1Click:Connect(function() if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0)) end end)  
            local CopyPosBtn = Instance.new("TextButton", ItemFrame); CopyPosBtn.Size = UDim2.new(0.16, 0, 0.4, 0); CopyPosBtn.Position = UDim2.new(0.72, 0, 0.05, 0); CopyPosBtn.Text = "📋 Tọa độ"; CopyPosBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170); CopyPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyPosBtn.Font = Enum.Font.SourceSansBold; CopyPosBtn.TextSize = 8; Instance.new("UICorner", CopyPosBtn).CornerRadius = UDim.new(0, 3)  
            CopyPosBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(string.format("%.1f, %.1f, %.1f", obj.Position.X, obj.Position.Y, obj.Position.Z)) end end)  

            if #scripts > 0 then  
                local ScriptLabel = Instance.new("TextLabel", ItemFrame); ScriptLabel.Size = UDim2.new(0.3, 0, 0.4, 0); ScriptLabel.Position = UDim2.new(0.02, 0, 0.55, 0); ScriptLabel.Text = "📜 Có script ("..#scripts..")"; ScriptLabel.TextColor3 = Color3.fromRGB(255, 200, 80); ScriptLabel.BackgroundTransparency = 1; ScriptLabel.Font = Enum.Font.SourceSans; ScriptLabel.TextSize = 8; ScriptLabel.TextXAlignment = Enum.TextXAlignment.Left  
                local ViewScriptsBtn = Instance.new("TextButton", ItemFrame); ViewScriptsBtn.Size = UDim2.new(0.2, 0, 0.4, 0); ViewScriptsBtn.Position = UDim2.new(0.78, 0, 0.55, 0); ViewScriptsBtn.Text = "Xem Script"; ViewScriptsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ViewScriptsBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ViewScriptsBtn.Font = Enum.Font.SourceSansBold; ViewScriptsBtn.TextSize = 8; Instance.new("UICorner", ViewScriptsBtn).CornerRadius = UDim.new(0, 3)  
                ViewScriptsBtn.MouseButton1Click:Connect(function()  
                    local popup = Instance.new("Frame", ScreenGui)  
                    popup.Size = UDim2.new(0, 400, 0, 300)  
                    popup.Position = UDim2.new(0.5, -200, 0.5, -150)  
                    popup.BackgroundColor3 = Color3.fromRGB(20, 20, 30)  
                    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)  
                    local close = Instance.new("TextButton", popup); close.Size = UDim2.new(0, 30, 0, 30); close.Position = UDim2.new(1, -35, 0, 5); close.Text = "✕"; close.BackgroundColor3 = Color3.fromRGB(50, 50, 50); close.TextColor3 = Color3.fromRGB(255, 255, 255); close.Font = Enum.Font.SourceSansBold; close.TextSize = 12; close.MouseButton1Click:Connect(function() popup:Destroy() end)  
                    local title = Instance.new("TextLabel", popup); title.Size = UDim2.new(0.8, 0, 0, 30); title.Position = UDim2.new(0.05, 0, 0, 0); title.Text = "Scripts trong "..obj.Name; title.TextColor3 = Color3.fromRGB(0, 255, 200); title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold; title.TextSize = 12  
                    local scroll = Instance.new("ScrollingFrame", popup); scroll.Size = UDim2.new(0.95, 0, 0.85, 0); scroll.Position = UDim2.new(0.025, 0, 0.1, 0); scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15); scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.ScrollBarThickness = 3  
                    local listUI = Instance.new("UIListLayout", scroll); listUI.Padding = UDim.new(0, 4)  
                    for _, scr in ipairs(scripts) do  
                        local frame = Instance.new("Frame", scroll); frame.Size = UDim2.new(1, -5, 0, 22); frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)  
                        local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(0.6, 0, 1, 0); label.Position = UDim2.new(0.02, 0, 0, 0); label.Text = scr.Name; label.TextColor3 = Color3.fromRGB(200, 200, 200); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSans; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left  
                        local copy = Instance.new("TextButton", frame); copy.Size = UDim2.new(0.35, 0, 0.8, 0); copy.Position = UDim2.new(0.62, 0, 0.1, 0); copy.Text = "📋 Copy Code"; copy.BackgroundColor3 = Color3.fromRGB(0, 120, 180); copy.TextColor3 = Color3.fromRGB(255, 255, 255); copy.Font = Enum.Font.SourceSansBold; copy.TextSize = 8; Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 3)  
                        copy.MouseButton1Click:Connect(function() if setclipboard then setclipboard(getScriptCode(scr)) end end)  
                    end  
                    scroll.CanvasSize = UDim2.new(0, 0, 0, listUI.AbsoluteContentSize.Y)  
                end)  
            end  
        end  
    end  
    ScanScroll.CanvasSize = UDim2.new(0, 0, 0, ScanListUI.AbsoluteContentSize.Y)  
end  

--=========================================================  
-- TAB 4: BACKPACK (GIỮ NGUYÊN)  
--=========================================================  
local EquipAllBtn = Instance.new("TextButton", Page4); EquipAllBtn.Size = UDim2.new(0.48, 0, 0, 22); EquipAllBtn.Text = "⚔️ Equip All Tools"; EquipAllBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180); EquipAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255); EquipAllBtn.Font = Enum.Font.SourceSansBold; EquipAllBtn.TextSize = 9; Instance.new("UICorner", EquipAllBtn).CornerRadius = UDim.new(0, 4)  
local DropAllBtn = Instance.new("TextButton", Page4); DropAllBtn.Size = UDim2.new(0.48, 0, 0, 22); DropAllBtn.Position = UDim2.new(0.51, 0, 0, 0); DropAllBtn.Text = "🗑️ Drop Holding Tool"; DropAllBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); DropAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255); DropAllBtn.Font = Enum.Font.SourceSansBold; DropAllBtn.TextSize = 9; Instance.new("UICorner", DropAllBtn).CornerRadius = UDim.new(0, 4)  

local InvScroll = Instance.new("ScrollingFrame", Page4); InvScroll.Size = UDim2.new(1, 0, 1, -28); InvScroll.Position = UDim2.new(0, 0, 0, 28); InvScroll.BackgroundTransparency = 1; InvScroll.CanvasSize = UDim2.new(0, 0, 0, 0); InvScroll.ScrollBarThickness = 3  
local InvListUI = Instance.new("UIListLayout", InvScroll); InvListUI.Padding = UDim.new(0, 6)  

EquipAllBtn.MouseButton1Click:Connect(function()  
    pcall(function()  
        local bp = LocalPlayer:FindFirstChild("Backpack")  
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")  
        if bp and hum then for _, tool in pairs(bp:GetChildren()) do if tool:IsA("Tool") then hum:EquipTool(tool) end end end  
    end)  
end)  

DropAllBtn.MouseButton1Click:Connect(function()  
    pcall(function()  
        if LocalPlayer.Character then  
            for _, tool in pairs(LocalPlayer.Character:GetChildren()) do  
                if tool:IsA("Tool") then tool.Parent = Workspace end  
            end  
        end  
    end)  
end)  

local function buildItemScriptsUI(item, parentFrame)  
    local scriptsFound = {}  
    for _, desc in pairs(item:GetDescendants()) do if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then table.insert(scriptsFound, desc) end end  
    if #scriptsFound == 0 then  
        local EmptyText = Instance.new("TextLabel", parentFrame); EmptyText.Size = UDim2.new(1, 0, 0, 14); EmptyText.Text = "  └─ [Không có Script]"; EmptyText.TextColor3 = Color3.fromRGB(110, 110, 110); EmptyText.BackgroundTransparency = 1; EmptyText.Font = Enum.Font.SourceSansItalic; EmptyText.TextSize = 9; EmptyText.TextXAlignment = Enum.TextXAlignment.Left  
    else  
        for _, scr in pairs(scriptsFound) do  
            local ScrFrame = Instance.new("Frame", parentFrame); ScrFrame.Size = UDim2.new(1, -4, 0, 20); ScrFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Instance.new("UICorner", ScrFrame).CornerRadius = UDim.new(0, 3)  
            local ScrLabel = Instance.new("TextLabel", ScrFrame); ScrLabel.Size = UDim2.new(0.65, 0, 1, 0); ScrLabel.Position = UDim2.new(0.02, 0, 0, 0); ScrLabel.Text = string.format("📜 %s (%s)", scr.Name, scr.ClassName); ScrLabel.TextColor3 = Color3.fromRGB(255, 200, 80); ScrLabel.BackgroundTransparency = 1; ScrLabel.Font = Enum.Font.SourceSans; ScrLabel.TextSize = 9; ScrLabel.TextXAlignment = Enum.TextXAlignment.Left  
            local CopyCodeBtn = Instance.new("TextButton", ScrFrame); CopyCodeBtn.Size = UDim2.new(0.3, 0, 0.8, 0); CopyCodeBtn.Position = UDim2.new(0.68, 0, 0.1, 0); CopyCodeBtn.Text = "📋 Copy Code"; CopyCodeBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170); CopyCodeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyCodeBtn.Font = Enum.Font.SourceSansBold; CopyCodeBtn.TextSize = 8; Instance.new("UICorner", CopyCodeBtn).CornerRadius = UDim.new(0, 3)  
            CopyCodeBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(getScriptCode(scr)) end end)  
        end  
    end  
end  

local function updateBackpackInspector()  
    for _, child in pairs(InvScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    for _, plr in pairs(Players:GetPlayers()) do  
        local allItems = {}  
        local bp = plr:FindFirstChild("Backpack")  
        if bp then for _, item in pairs(bp:GetChildren()) do if item:IsA("Tool") then table.insert(allItems, {Obj = item, Status = "Túi đồ"}) end end end  
        if plr.Character then for _, item in pairs(plr.Character:GetChildren()) do if item:IsA("Tool") then table.insert(allItems, {Obj = item, Status = "Đang cầm"}) end end end  

        local PlayerCard = Instance.new("Frame", InvScroll); PlayerCard.Size = UDim2.new(1, -5, 0, 130); PlayerCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", PlayerCard).CornerRadius = UDim.new(0, 5)  
        local PlayerTitle = Instance.new("TextLabel", PlayerCard); PlayerTitle.Size = UDim2.new(0.96, 0, 0, 18); PlayerTitle.Position = UDim2.new(0.02, 0, 0.02, 0); PlayerTitle.Text = string.format("👤 %s (%d items)", plr.DisplayName, #allItems); PlayerTitle.TextColor3 = Color3.fromRGB(255, 210, 80); PlayerTitle.BackgroundTransparency = 1; PlayerTitle.Font = Enum.Font.SourceSansBold; PlayerTitle.TextSize = 10; PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left  
        local ItemsContainer = Instance.new("ScrollingFrame", PlayerCard); ItemsContainer.Size = UDim2.new(0.96, 0, 0, 102); ItemsContainer.Position = UDim2.new(0.02, 0, 0.18, 0); ItemsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 15); ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0); ItemsContainer.ScrollBarThickness = 3  
        local ItemsListUI = Instance.new("UIListLayout", ItemsContainer); ItemsListUI.Padding = UDim.new(0, 4)  

        if #allItems == 0 then  
            local EmptyText = Instance.new("TextLabel", ItemsContainer); EmptyText.Size = UDim2.new(1, 0, 0, 20); EmptyText.Text = "Túi đồ trống"; EmptyText.TextColor3 = Color3.fromRGB(120, 120, 120); EmptyText.BackgroundTransparency = 1; EmptyText.Font = Enum.Font.SourceSansItalic; EmptyText.TextSize = 10  
        else  
            for _, itemData in pairs(allItems) do  
                local toolFrame = Instance.new("Frame", ItemsContainer); toolFrame.Size = UDim2.new(1, -4, 0, 42); toolFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Instance.new("UICorner", toolFrame).CornerRadius = UDim.new(0, 4)  
                local ToolTitle = Instance.new("TextLabel", toolFrame); ToolTitle.Size = UDim2.new(1, 0, 0, 15); ToolTitle.Position = UDim2.new(0.02, 0, 0, 0); ToolTitle.Text = string.format("🗡️ %s [%s]", itemData.Obj.Name, itemData.Status); ToolTitle.TextColor3 = Color3.fromRGB(0, 200, 255); ToolTitle.BackgroundTransparency = 1; ToolTitle.Font = Enum.Font.SourceSansBold; ToolTitle.TextSize = 9; ToolTitle.TextXAlignment = Enum.TextXAlignment.Left  
                local ScriptsSubContainer = Instance.new("Frame", toolFrame); ScriptsSubContainer.Size = UDim2.new(0.96, 0, 0, 22); ScriptsSubContainer.Position = UDim2.new(0.02, 0, 0.42, 0); ScriptsSubContainer.BackgroundTransparency = 1  
                local SubListUI = Instance.new("UIListLayout", ScriptsSubContainer); SubListUI.Padding = UDim.new(0, 2)  
                buildItemScriptsUI(itemData.Obj, ScriptsSubContainer)  
            end  
        end  
        ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, ItemsListUI.AbsoluteContentSize.Y)  
    end  
    InvScroll.CanvasSize = UDim2.new(0, 0, 0, InvListUI.AbsoluteContentSize.Y)  
end  

--=========================================================  
-- TAB 5: STATS INSPECTOR + TÌM SCRIPT TĂNG CHỈ SỐ  
--=========================================================  
local StatsScroll = Instance.new("ScrollingFrame", Page5); StatsScroll.Size = UDim2.new(1, 0, 1, 0); StatsScroll.BackgroundTransparency = 1; StatsScroll.CanvasSize = UDim2.new(0, 0, 0, 0); StatsScroll.ScrollBarThickness = 3  
local StatsListUI = Instance.new("UIListLayout", StatsScroll); StatsListUI.Padding = UDim.new(0, 6)  

local function findScriptsModifyingStat(statName, statValue)  
    -- Tìm tất cả script trong game có chứa tên stat hoặc tham chiếu đến giá trị  
    local results = {}  
    local allScripts = {}  
    for _, obj in pairs(Workspace:GetDescendants()) do  
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then  
            table.insert(allScripts, obj)  
        end  
    end  
    for _, obj in pairs(Players:GetDescendants()) do  
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then  
            table.insert(allScripts, obj)  
        end  
    end  
    for _, scr in ipairs(allScripts) do  
        local code = getScriptCode(scr)  
        if code and #code > 0 then  
            if string.find(string.lower(code), string.lower(statName)) or string.find(string.lower(code), string.lower(tostring(statValue))) then  
                table.insert(results, scr)  
            end  
        end  
    end  
    return results  
end  

local function buildStatDetails(plr, parentFrame)  
    local leaderstats = plr:FindFirstChild("leaderstats")  
    if not leaderstats or #leaderstats:GetChildren() == 0 then  
        local EmptyText = Instance.new("TextLabel", parentFrame); EmptyText.Size = UDim2.new(1, 0, 0, 18); EmptyText.Text = "• Không có dữ liệu leaderstats"; EmptyText.TextColor3 = Color3.fromRGB(140, 140, 140); EmptyText.BackgroundTransparency = 1; EmptyText.Font = Enum.Font.SourceSansItalic; EmptyText.TextSize = 9; EmptyText.TextXAlignment = Enum.TextXAlignment.Left  
        return  
    end  
    for _, stat in pairs(leaderstats:GetChildren()) do  
        local StatFrame = Instance.new("Frame", parentFrame); StatFrame.Size = UDim2.new(1, -4, 0, 28); StatFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Instance.new("UICorner", StatFrame).CornerRadius = UDim.new(0, 4)  
        local valStr = stat:IsA("ValueBase") and tostring(stat.Value) or "N/A"  
        local StatLabel = Instance.new("TextLabel", StatFrame); StatLabel.Size = UDim2.new(0.4, 0, 1, 0); StatLabel.Position = UDim2.new(0.02, 0, 0, 0); StatLabel.Text = string.format("💎 %s: %s", stat.Name, valStr); StatLabel.TextColor3 = Color3.fromRGB(100, 220, 255); StatLabel.BackgroundTransparency = 1; StatLabel.Font = Enum.Font.SourceSansBold; StatLabel.TextSize = 9; StatLabel.TextXAlignment = Enum.TextXAlignment.Left  
        local CopyValBtn = Instance.new("TextButton", StatFrame); CopyValBtn.Size = UDim2.new(0.2, 0, 0.7, 0); CopyValBtn.Position = UDim2.new(0.42, 0, 0.15, 0); CopyValBtn.Text = "📋 Value"; CopyValBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50); CopyValBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyValBtn.Font = Enum.Font.SourceSansBold; CopyValBtn.TextSize = 8; Instance.new("UICorner", CopyValBtn).CornerRadius = UDim.new(0, 3)  
        CopyValBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(valStr) end end)  
        local FindScriptBtn = Instance.new("TextButton", StatFrame); FindScriptBtn.Size = UDim2.new(0.35, 0, 0.7, 0); FindScriptBtn.Position = UDim2.new(0.63, 0, 0.15, 0); FindScriptBtn.Text = "🔍 Tìm script tăng"; FindScriptBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180); FindScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FindScriptBtn.Font = Enum.Font.SourceSansBold; FindScriptBtn.TextSize = 8; Instance.new("UICorner", FindScriptBtn).CornerRadius = UDim.new(0, 3)  
        FindScriptBtn.MouseButton1Click:Connect(function()  
            local scripts = findScriptsModifyingStat(stat.Name, valStr)  
            local popup = Instance.new("Frame", ScreenGui)  
            popup.Size = UDim2.new(0, 500, 0, 300)  
            popup.Position = UDim2.new(0.5, -250, 0.5, -150)  
            popup.BackgroundColor3 = Color3.fromRGB(20, 20, 30)  
            Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)  
            local close = Instance.new("TextButton", popup); close.Size = UDim2.new(0, 30, 0, 30); close.Position = UDim2.new(1, -35, 0, 5); close.Text = "✕"; close.BackgroundColor3 = Color3.fromRGB(50, 50, 50); close.TextColor3 = Color3.fromRGB(255, 255, 255); close.Font = Enum.Font.SourceSansBold; close.TextSize = 12; close.MouseButton1Click:Connect(function() popup:Destroy() end)  
            local title = Instance.new("TextLabel", popup); title.Size = UDim2.new(0.8, 0, 0, 30); title.Position = UDim2.new(0.05, 0, 0, 0); title.Text = "Scripts liên quan đến "..stat.Name; title.TextColor3 = Color3.fromRGB(0, 255, 200); title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold; title.TextSize = 12  
            local scroll = Instance.new("ScrollingFrame", popup); scroll.Size = UDim2.new(0.95, 0, 0.85, 0); scroll.Position = UDim2.new(0.025, 0, 0.1, 0); scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15); scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.ScrollBarThickness = 3  
            local listUI = Instance.new("UIListLayout", scroll); listUI.Padding = UDim.new(0, 4)  
            if #scripts == 0 then  
                local empty = Instance.new("TextLabel", scroll); empty.Size = UDim2.new(1, 0, 0, 30); empty.Text = "Không tìm thấy script nào tham chiếu đến chỉ số này."; empty.BackgroundTransparency = 1; empty.TextColor3 = Color3.fromRGB(200, 200, 200); empty.Font = Enum.Font.SourceSans; empty.TextSize = 12  
            else  
                for _, scr in ipairs(scripts) do  
                    local frame = Instance.new("Frame", scroll); frame.Size = UDim2.new(1, -5, 0, 24); frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)  
                    local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(0.55, 0, 1, 0); label.Position = UDim2.new(0.02, 0, 0, 0); label.Text = string.format("📜 %s (%s)", scr.Name, scr.ClassName); label.TextColor3 = Color3.fromRGB(200, 200, 200); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSans; label.TextSize = 9; label.TextXAlignment = Enum.TextXAlignment.Left  
                    local copy = Instance.new("TextButton", frame); copy.Size = UDim2.new(0.4, 0, 0.8, 0); copy.Position = UDim2.new(0.57, 0, 0.1, 0); copy.Text = "📋 Copy Code"; copy.BackgroundColor3 = Color3.fromRGB(0, 120, 180); copy.TextColor3 = Color3.fromRGB(255, 255, 255); copy.Font = Enum.Font.SourceSansBold; copy.TextSize = 8; Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 3)  
                    copy.MouseButton1Click:Connect(function() if setclipboard then setclipboard(getScriptCode(scr)) end end)  
                end  
            end  
            scroll.CanvasSize = UDim2.new(0, 0, 0, listUI.AbsoluteContentSize.Y)  
        end)  
    end  
end  

local function updateStatsInspector()  
    for _, child in pairs(StatsScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
    for _, plr in pairs(Players:GetPlayers()) do  
        local char = plr.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")  
        local distStr = (myHrp and hrp) and string.format("%dm", math.floor((hrp.Position - myHrp.Position).Magnitude)) or "N/A"  
        local spdStr = hum and string.format("WalkSpd: %d | JumpPwr: %d", hum.WalkSpeed, hum.JumpPower) or "N/A"  

        local CardFrame = Instance.new("Frame", StatsScroll); CardFrame.Size = UDim2.new(1, -5, 0, 145); CardFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", CardFrame).CornerRadius = UDim.new(0, 5)  
        local HeaderLabel = Instance.new("TextLabel", CardFrame); HeaderLabel.Size = UDim2.new(0.96, 0, 0, 18); HeaderLabel.Position = UDim2.new(0.02, 0, 0.02, 0); HeaderLabel.Text = string.format("👤 %s (@%s) | HP: %d/%d | %s | Cách: %s", plr.DisplayName, plr.Name, hum and math.floor(hum.Health) or 0, hum and math.floor(hum.MaxHealth) or 0, spdStr, distStr); HeaderLabel.TextColor3 = (plr == LocalPlayer) and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 200, 50); HeaderLabel.BackgroundTransparency = 1; HeaderLabel.Font = Enum.Font.SourceSansBold; HeaderLabel.TextSize = 9; HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left  
        local StatsContainer = Instance.new("ScrollingFrame", CardFrame); StatsContainer.Size = UDim2.new(0.96, 0, 0, 118); StatsContainer.Position = UDim2.new(0.02, 0, 0.18, 0); StatsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 15); StatsContainer.CanvasSize = UDim2.new(0, 0, 0, 0); StatsContainer.ScrollBarThickness = 3  
        local ContainerListUI = Instance.new("UIListLayout", StatsContainer); ContainerListUI.Padding = UDim.new(0, 4)  
        buildStatDetails(plr, StatsContainer)  
        StatsContainer.CanvasSize = UDim2.new(0, 0, 0, ContainerListUI.AbsoluteContentSize.Y)  
    end  
    StatsScroll.CanvasSize = UDim2.new(0, 0, 0, StatsListUI.AbsoluteContentSize.Y)  
end  

--=========================================================  
-- TAB 6: REMOTE SPY PRO (NÂNG CẤP GIỐNG SPY)  
--=========================================================  
local SpyFilterBox = Instance.new("TextBox", Page6); SpyFilterBox.Size = UDim2.new(0.35, 0, 0, 24); SpyFilterBox.PlaceholderText = "🔍 Lọc Remote..."; SpyFilterBox.Text = ""; SpyFilterBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28); SpyFilterBox.TextColor3 = Color3.fromRGB(255, 255, 255); SpyFilterBox.Font = Enum.Font.SourceSans; SpyFilterBox.TextSize = 9; Instance.new("UICorner", SpyFilterBox).CornerRadius = UDim.new(0, 4)  
local RemoteSpyToggle = Instance.new("TextButton", Page6); RemoteSpyToggle.Size = UDim2.new(0.18, 0, 0, 24); RemoteSpyToggle.Position = UDim2.new(0.37, 0, 0, 0); RemoteSpyToggle.Text = "📡 Spy: OFF"; RemoteSpyToggle.BackgroundColor3 = Color3.fromRGB(140, 35, 35); RemoteSpyToggle.TextColor3 = Color3.fromRGB(255, 255, 255); RemoteSpyToggle.Font = Enum.Font.SourceSansBold; RemoteSpyToggle.TextSize = 9; Instance.new("UICorner", RemoteSpyToggle).CornerRadius = UDim.new(0, 4)  
local ScanRemotesBtn = Instance.new("TextButton", Page6); ScanRemotesBtn.Size = UDim2.new(0.18, 0, 0, 24); ScanRemotesBtn.Position = UDim2.new(0.57, 0, 0, 0); ScanRemotesBtn.Text = "🔍 Quét Remotes"; ScanRemotesBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70); ScanRemotesBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ScanRemotesBtn.Font = Enum.Font.SourceSansBold; ScanRemotesBtn.TextSize = 8; Instance.new("UICorner", ScanRemotesBtn).CornerRadius = UDim.new(0, 4)  
local ClearSpyBtn = Instance.new("TextButton", Page6); ClearSpyBtn.Size = UDim2.new(0.18, 0, 0, 24); ClearSpyBtn.Position = UDim2.new(0.77, 0, 0, 0); ClearSpyBtn.Text = "🗑️ Clear Log"; ClearSpyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ClearSpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ClearSpyBtn.Font = Enum.Font.SourceSansBold; ClearSpyBtn.TextSize = 9; Instance.new("UICorner", ClearSpyBtn).CornerRadius = UDim.new(0, 4)  
local SpyScroll = Instance.new("ScrollingFrame", Page6); SpyScroll.Size = UDim2.new(1, 0, 1, -30); SpyScroll.Position = UDim2.new(0, 0, 0, 30); SpyScroll.BackgroundTransparency = 1; SpyScroll.CanvasSize = UDim2.new(0, 0, 0, 0); SpyScroll.ScrollBarThickness = 3  
local SpyListUI = Instance.new("UIListLayout", SpyScroll); SpyListUI.Padding = UDim.new(0, 4)  

local spyActive = false; local blacklistedRemoteNames = {}; local loggedUIFrames = {}; local remoteCallCounts = {}; local remoteLastArgs = {}  

RemoteSpyToggle.MouseButton1Click:Connect(function()  
    spyActive = not spyActive  
    RemoteSpyToggle.Text = spyActive and "📡 Spy: ON" or "📡 Spy: OFF"  
    RemoteSpyToggle.BackgroundColor3 = spyActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(140, 35, 35)  
end)  

ClearSpyBtn.MouseButton1Click:Connect(function()  
    for _, child in pairs(SpyScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    loggedUIFrames = {}; remoteCallCounts = {}; remoteLastArgs = {}; SpyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)  
end)  

ScanRemotesBtn.MouseButton1Click:Connect(function()  
    -- Quét tất cả RemoteEvent và RemoteFunction trong game  
    local remotes = {}  
    for _, obj in pairs(Workspace:GetDescendants()) do  
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then  
            table.insert(remotes, obj)  
        end  
    end  
    for _, obj in pairs(Players:GetDescendants()) do  
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then  
            table.insert(remotes, obj)  
        end  
    end  
    for _, obj in pairs(game:GetDescendants()) do  
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then  
            table.insert(remotes, obj)  
        end  
    end  
    -- Hiển thị danh sách remotes trong một popup  
    local popup = Instance.new("Frame", ScreenGui)  
    popup.Size = UDim2.new(0, 500, 0, 400)  
    popup.Position = UDim2.new(0.5, -250, 0.5, -200)  
    popup.BackgroundColor3 = Color3.fromRGB(20, 20, 30)  
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)  
    local close = Instance.new("TextButton", popup); close.Size = UDim2.new(0, 30, 0, 30); close.Position = UDim2.new(1, -35, 0, 5); close.Text = "✕"; close.BackgroundColor3 = Color3.fromRGB(50, 50, 50); close.TextColor3 = Color3.fromRGB(255, 255, 255); close.Font = Enum.Font.SourceSansBold; close.TextSize = 12; close.MouseButton1Click:Connect(function() popup:Destroy() end)  
    local title = Instance.new("TextLabel", popup); title.Size = UDim2.new(0.8, 0, 0, 30); title.Position = UDim2.new(0.05, 0, 0, 0); title.Text = "Danh sách Remote ("..#remotes..")"; title.TextColor3 = Color3.fromRGB(0, 255, 200); title.BackgroundTransparency = 1; title.Font = Enum.Font.SourceSansBold; title.TextSize = 12  
    local scroll = Instance.new("ScrollingFrame", popup); scroll.Size = UDim2.new(0.95, 0, 0.85, 0); scroll.Position = UDim2.new(0.025, 0, 0.1, 0); scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15); scroll.CanvasSize = UDim2.new(0, 0, 0, 0); scroll.ScrollBarThickness = 3  
    local listUI = Instance.new("UIListLayout", scroll); listUI.Padding = UDim.new(0, 4)  
    for _, r in ipairs(remotes) do  
        local frame = Instance.new("Frame", scroll); frame.Size = UDim2.new(1, -5, 0, 24); frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)  
        local label = Instance.new("TextLabel", frame); label.Size = UDim2.new(0.5, 0, 1, 0); label.Position = UDim2.new(0.02, 0, 0, 0); label.Text = string.format("📡 %s (%s)", r.Name, r.ClassName); label.TextColor3 = Color3.fromRGB(200, 200, 200); label.BackgroundTransparency = 1; label.Font = Enum.Font.SourceSans; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left  
        local fireBtn = Instance.new("TextButton", frame); fireBtn.Size = UDim2.new(0.2, 0, 0.7, 0); fireBtn.Position = UDim2.new(0.52, 0, 0.15, 0); fireBtn.Text = "🔥 Fire"; fireBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70); fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255); fireBtn.Font = Enum.Font.SourceSansBold; fireBtn.TextSize = 8; Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 3)  
        fireBtn.MouseButton1Click:Connect(function() pcall(function() if r:IsA("RemoteEvent") then r:FireServer() elseif r:IsA("RemoteFunction") then r:InvokeServer() end end) end)  
        local copyBtn = Instance.new("TextButton", frame); copyBtn.Size = UDim2.new(0.2, 0, 0.7, 0); copyBtn.Position = UDim2.new(0.74, 0, 0.15, 0); copyBtn.Text = "📋 Copy Path"; copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180); copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); copyBtn.Font = Enum.Font.SourceSansBold; copyBtn.TextSize = 8; Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 3)  
        copyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(r:GetFullName()) end end)  
    end  
    scroll.CanvasSize = UDim2.new(0, 0, 0, listUI.AbsoluteContentSize.Y)  
end)  

local function logRemoteEvent(remote, args)  
    if not spyActive then return end  
    local rName = remote.Name  
    if blacklistedRemoteNames[rName] then return end  
    local filterText = string.lower(SpyFilterBox.Text)  
    if filterText ~= "" and not string.find(string.lower(rName), filterText) then return end  

    remoteCallCounts[remote] = (remoteCallCounts[remote] or 0) + 1; remoteLastArgs[remote] = args  
    if loggedUIFrames[remote] and loggedUIFrames[remote].Parent then  
        local frame = loggedUIFrames[remote]; local infoLabel = frame:FindFirstChild("InfoText")  
        if infoLabel then infoLabel.Text = string.format("⚡ [%s] %s (x%d)", remote.ClassName, rName, remoteCallCounts[remote]) end  
        return  
    end  

    local ItemFrame = Instance.new("Frame", SpyScroll); ItemFrame.Size = UDim2.new(1, -5, 0, 26); ItemFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)  
    local InfoText = Instance.new("TextLabel", ItemFrame); InfoText.Name = "InfoText"; InfoText.Size = UDim2.new(0.42, 0, 1, 0); InfoText.Position = UDim2.new(0.02, 0, 0, 0); InfoText.Text = string.format("⚡ [%s] %s (x1)", remote.ClassName, rName); InfoText.TextColor3 = Color3.fromRGB(255, 180, 50); InfoText.BackgroundTransparency = 1; InfoText.Font = Enum.Font.SourceSansBold; InfoText.TextSize = 9; InfoText.TextXAlignment = Enum.TextXAlignment.Left  
    local FireTestBtn = Instance.new("TextButton", ItemFrame); FireTestBtn.Size = UDim2.new(0.16, 0, 0.7, 0); FireTestBtn.Position = UDim2.new(0.45, 0, 0.15, 0); FireTestBtn.Text = "🔥 Fire"; FireTestBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70); FireTestBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FireTestBtn.Font = Enum.Font.SourceSansBold; FireTestBtn.TextSize = 8; Instance.new("UICorner", FireTestBtn).CornerRadius = UDim.new(0, 3)  
    local CopyCallBtn = Instance.new("TextButton", ItemFrame); CopyCallBtn.Size = UDim2.new(0.18, 0, 0.7, 0); CopyCallBtn.Position = UDim2.new(0.62, 0, 0.15, 0); CopyCallBtn.Text = "📋 Copy Code"; CopyCallBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180); CopyCallBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyCallBtn.Font = Enum.Font.SourceSansBold; CopyCallBtn.TextSize = 8; Instance.new("UICorner", CopyCallBtn).CornerRadius = UDim.new(0, 3)  
    local PurgeBtn = Instance.new("TextButton", ItemFrame); PurgeBtn.Size = UDim2.new(0.18, 0, 0.7, 0); PurgeBtn.Position = UDim2.new(0.81, 0, 0.15, 0); PurgeBtn.Text = "🚫 Purge"; PurgeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40); PurgeBtn.TextColor3 = Color3.fromRGB(255, 255, 255); PurgeBtn.Font = Enum.Font.SourceSansBold; PurgeBtn.TextSize = 8; Instance.new("UICorner", PurgeBtn).CornerRadius = UDim.new(0, 3)  

    FireTestBtn.MouseButton1Click:Connect(function() pcall(function() local lastArgs = remoteLastArgs[remote] or {}; if remote:IsA("RemoteEvent") then remote:FireServer(unpack(lastArgs)) elseif remote:IsA("RemoteFunction") then remote:InvokeServer(unpack(lastArgs)) end end) end)  
    CopyCallBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(string.format("game.%s:%s(unpack(args))", remote:GetFullName(), remote:IsA("RemoteEvent") and "FireServer" or "InvokeServer")) end end)  
    PurgeBtn.MouseButton1Click:Connect(function() blacklistedRemoteNames[rName] = true; ItemFrame:Destroy() end)  

    loggedUIFrames[remote] = ItemFrame  
    SpyScroll.CanvasSize = UDim2.new(0, 0, 0, SpyListUI.AbsoluteContentSize.Y)  
end  

local rawMeta = getrawmetatable or debug.getmetatable  
if rawMeta and setreadonly then  
    local gmt = rawMeta(game); local oldNamecall = gmt.__namecall  
    setreadonly(gmt, false)  
    gmt.__namecall = newcclosure(function(self, ...)  
        local method = getnamecallmethod()  
        if spyActive and (method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer") then  
            if self and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then logRemoteEvent(self, {...}) end  
        end  
        return oldNamecall(self, ...)  
    end)  
    setreadonly(gmt, true)  
end  

--=========================================================  
-- TAB 7: CONSOLE LOG (GIỐNG F9)  
--=========================================================  
local ConsoleSearchBox = Instance.new("TextBox", Page7); ConsoleSearchBox.Size = UDim2.new(0.3, 0, 0, 22); ConsoleSearchBox.PlaceholderText = "🔍 Tìm log..."; ConsoleSearchBox.Text = ""; ConsoleSearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28); ConsoleSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255); ConsoleSearchBox.Font = Enum.Font.SourceSans; ConsoleSearchBox.TextSize = 9; Instance.new("UICorner", ConsoleSearchBox).CornerRadius = UDim.new(0, 3)  
local FilterErrorBtn = Instance.new("TextButton", Page7); FilterErrorBtn.Size = UDim2.new(0.12, 0, 0, 22); FilterErrorBtn.Position = UDim2.new(0.33, 0, 0, 0); FilterErrorBtn.Text = "❌ Lỗi"; FilterErrorBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); FilterErrorBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FilterErrorBtn.Font = Enum.Font.SourceSansBold; FilterErrorBtn.TextSize = 9; Instance.new("UICorner", FilterErrorBtn).CornerRadius = UDim.new(0, 3)  
local FilterWarnBtn = Instance.new("TextButton", Page7); FilterWarnBtn.Size = UDim2.new(0.12, 0, 0, 22); FilterWarnBtn.Position = UDim2.new(0.46, 0, 0, 0); FilterWarnBtn.Text = "⚠️ Cảnh báo"; FilterWarnBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); FilterWarnBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FilterWarnBtn.Font = Enum.Font.SourceSansBold; FilterWarnBtn.TextSize = 9; Instance.new("UICorner", FilterWarnBtn).CornerRadius = UDim.new(0, 3)  
local FilterInfoBtn = Instance.new("TextButton", Page7); FilterInfoBtn.Size = UDim2.new(0.12, 0, 0, 22); FilterInfoBtn.Position = UDim2.new(0.59, 0, 0, 0); FilterInfoBtn.Text = "ℹ️ Thông tin"; FilterInfoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); FilterInfoBtn.TextColor3 = Color3.fromRGB(255, 255, 255); FilterInfoBtn.Font = Enum.Font.SourceSansBold; FilterInfoBtn.TextSize = 9; Instance.new("UICorner", FilterInfoBtn).CornerRadius = UDim.new(0, 3)  
local ClearConsoleBtn = Instance.new("TextButton", Page7); ClearConsoleBtn.Size = UDim2.new(0.12, 0, 0, 22); ClearConsoleBtn.Position = UDim2.new(0.73, 0, 0, 0); ClearConsoleBtn.Text = "🗑️ Clear"; ClearConsoleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ClearConsoleBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ClearConsoleBtn.Font = Enum.Font.SourceSansBold; ClearConsoleBtn.TextSize = 9; Instance.new("UICorner", ClearConsoleBtn).CornerRadius = UDim.new(0, 3)  

local ConsoleScroll = Instance.new("ScrollingFrame", Page7); ConsoleScroll.Size = UDim2.new(1, 0, 1, -28); ConsoleScroll.Position = UDim2.new(0, 0, 0, 28); ConsoleScroll.BackgroundTransparency = 1; ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0); ConsoleScroll.ScrollBarThickness = 3  
local ConsoleListUI = Instance.new("UIListLayout", ConsoleScroll); ConsoleListUI.Padding = UDim.new(0, 3)  

local filterTypes = {Error = false, Warning = false, Info = false}  
-- Mặc định hiện tất cả  
local function setFilter(type, state)  
    filterTypes[type] = state  
    -- Cập nhật màu nút  
    if type == "Error" then FilterErrorBtn.BackgroundColor3 = state and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(50, 50, 50)  
    elseif type == "Warning" then FilterWarnBtn.BackgroundColor3 = state and Color3.fromRGB(180, 120, 0) or Color3.fromRGB(50, 50, 50)  
    elseif type == "Info" then FilterInfoBtn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(50, 50, 50)  
    end  
    -- Refresh logs hiện có (không lưu lại, chỉ lọc)  
    -- Chúng ta sẽ lọc ngay khi hiển thị log mới, nhưng cần cập nhật lại danh sách hiện tại?  
    -- Cách đơn giản: xóa hết và thêm lại từ bộ nhớ log (cần lưu log)  
    -- Ta sẽ lưu tất cả log vào một mảng và render lại  
end  

FilterErrorBtn.MouseButton1Click:Connect(function() setFilter("Error", not filterTypes.Error) end)  
FilterWarnBtn.MouseButton1Click:Connect(function() setFilter("Warning", not filterTypes.Warning) end)  
FilterInfoBtn.MouseButton1Click:Connect(function() setFilter("Info", not filterTypes.Info) end)  

local logHistory = {}  

local function appendLog(message, messageType)  
    table.insert(logHistory, {msg = message, type = messageType})  
    -- Kiểm tra filter  
    local show = true  
    if messageType == Enum.MessageType.MessageError and not filterTypes.Error then show = false end  
    if messageType == Enum.MessageType.MessageWarning and not filterTypes.Warning then show = false end  
    if messageType == Enum.MessageType.MessageOutput and not filterTypes.Info then show = false end  
    if not show then return end  

    local searchKeyword = string.lower(ConsoleSearchBox.Text)  
    if searchKeyword ~= "" and not string.find(string.lower(message), searchKeyword) then return end  

    local Frame = Instance.new("Frame", ConsoleScroll); Frame.Size = UDim2.new(1, -5, 0, 20); Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)  
    local LogText = Instance.new("TextLabel", Frame); LogText.Size = UDim2.new(0.98, 0, 1, 0); LogText.Position = UDim2.new(0.01, 0, 0, 0); LogText.Text = string.format("[%s] %s", os.date("%H:%M:%S"), message); LogText.BackgroundTransparency = 1; LogText.Font = Enum.Font.SourceSans; LogText.TextSize = 9; LogText.TextXAlignment = Enum.TextXAlignment.Left  
    if messageType == Enum.MessageType.MessageOutput then LogText.TextColor3 = Color3.fromRGB(220, 220, 220)  
    elseif messageType == Enum.MessageType.MessageWarning then LogText.TextColor3 = Color3.fromRGB(255, 200, 50)  
    elseif messageType == Enum.MessageType.MessageError then LogText.TextColor3 = Color3.fromRGB(255, 70, 70)  
    else LogText.TextColor3 = Color3.fromRGB(100, 200, 255) end  
    ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, ConsoleListUI.AbsoluteContentSize.Y)  
    -- Auto scroll down  
    ConsoleScroll.CanvasPosition = Vector2.new(0, ConsoleScroll.CanvasSize.Y.Offset)  
end  

LogService.MessageOut:Connect(appendLog)  

ClearConsoleBtn.MouseButton1Click:Connect(function()  
    for _, child in pairs(ConsoleScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)  
    logHistory = {}  
end)  

--=========================================================  
-- TAB 8: GUI INSPECTOR (GIỮ NGUYÊN)  
--=========================================================  
local GuiTargetBox = Instance.new("TextBox", Page8); GuiTargetBox.Size = UDim2.new(0, 280, 0, 24); GuiTargetBox.PlaceholderText = "🔍 Tên Player (Trống = Bản thân)..."; GuiTargetBox.Text = ""; GuiTargetBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28); GuiTargetBox.TextColor3 = Color3.fromRGB(255, 255, 255); GuiTargetBox.Font = Enum.Font.SourceSans; GuiTargetBox.TextSize = 9; Instance.new("UICorner", GuiTargetBox).CornerRadius = UDim.new(0, 4)  
local ScanGuiBtn = Instance.new("TextButton", Page8); ScanGuiBtn.Size = UDim2.new(0, 110, 0, 24); ScanGuiBtn.Position = UDim2.new(0, 290, 0, 0); ScanGuiBtn.Text = "🔍 Quét GUI"; ScanGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70); ScanGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ScanGuiBtn.Font = Enum.Font.SourceSansBold; ScanGuiBtn.TextSize = 9; Instance.new("UICorner", ScanGuiBtn).CornerRadius = UDim.new(0, 4)  
local ToggleAllGuiBtn = Instance.new("TextButton", Page8); ToggleAllGuiBtn.Size = UDim2.new(0, 120, 0, 24); ToggleAllGuiBtn.Position = UDim2.new(0, 410, 0, 0); ToggleAllGuiBtn.Text = "👁️ Bật/Tắt All UI"; ToggleAllGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 180); ToggleAllGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ToggleAllGuiBtn.Font = Enum.Font.SourceSansBold; ToggleAllGuiBtn.TextSize = 8; Instance.new("UICorner", ToggleAllGuiBtn).CornerRadius = UDim.new(0, 4)  

local GuiScroll = Instance.new("ScrollingFrame", Page8); GuiScroll.Size = UDim2.new(1, 0, 1, -30); GuiScroll.Position = UDim2.new(0, 0, 0, 30); GuiScroll.BackgroundTransparency = 1; GuiScroll.CanvasSize = UDim2.new(0, 0, 0, 0); GuiScroll.ScrollBarThickness = 3  
local GuiListUI = Instance.new("UIListLayout", GuiScroll); GuiListUI.Padding = UDim.new(0, 4)  

local currentScannedGuiPlayer = LocalPlayer  
local function scanGuiOfPlayer(targetPlayer)  
    currentScannedGuiPlayer = targetPlayer  
    for _, child in pairs(GuiScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end  
    local pGui = targetPlayer:FindFirstChild("PlayerGui")  
    if not pGui then return end  
    for _, screenGui in pairs(pGui:GetChildren()) do  
        if screenGui:IsA("ScreenGui") then  
            local innerScripts = {}  
            for _, d in pairs(screenGui:GetDescendants()) do if d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Script") then table.insert(innerScripts, d) end end  
            local Frame = Instance.new("Frame", GuiScroll); Frame.Size = UDim2.new(1, -5, 0, math.max(65, 50 + (#innerScripts * 22))); Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)  
            local InfoText = Instance.new("TextLabel", Frame); InfoText.Size = UDim2.new(0.6, 0, 0, 18); InfoText.Position = UDim2.new(0.02, 0, 0, 4); InfoText.Text = string.format("🖥️ %s (Enabled: %s)", screenGui.Name, tostring(screenGui.Enabled)); InfoText.TextColor3 = Color3.fromRGB(255, 210, 80); InfoText.BackgroundTransparency = 1; InfoText.Font = Enum.Font.SourceSansBold; InfoText.TextSize = 10; InfoText.TextXAlignment = Enum.TextXAlignment.Left  
            local ToggleVisBtn = Instance.new("TextButton", Frame); ToggleVisBtn.Size = UDim2.new(0.3, 0, 0, 20); ToggleVisBtn.Position = UDim2.new(0.67, 0, 0, 4); ToggleVisBtn.Text = screenGui.Enabled and "👁️ Bật/Tắt UI" or "🙈 UI Đang Ẩn"; ToggleVisBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); ToggleVisBtn.TextColor3 = Color3.fromRGB(255, 255, 255); ToggleVisBtn.Font = Enum.Font.SourceSansBold; ToggleVisBtn.TextSize = 8; Instance.new("UICorner", ToggleVisBtn).CornerRadius = UDim.new(0, 3)  
            ToggleVisBtn.MouseButton1Click:Connect(function() screenGui.Enabled = not screenGui.Enabled; ToggleVisBtn.Text = screenGui.Enabled and "👁️ Bật/Tắt UI" or "🙈 UI Đang Ẩn" end)  

            local ScriptContainer = Instance.new("Frame", Frame); ScriptContainer.Size = UDim2.new(0.96, 0, 1, -28); ScriptContainer.Position = UDim2.new(0.02, 0, 0, 26); ScriptContainer.BackgroundTransparency = 1  
            local ScriptList = Instance.new("UIListLayout", ScriptContainer); ScriptList.Padding = UDim.new(0, 2)  
            for _, scr in ipairs(innerScripts) do  
                local ScrSubFrame = Instance.new("Frame", ScriptContainer); ScrSubFrame.Size = UDim2.new(1, 0, 0, 20); ScrSubFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Instance.new("UICorner", ScrSubFrame).CornerRadius = UDim.new(0, 3)  
                local ScrLabel = Instance.new("TextLabel", ScrSubFrame); ScrLabel.Size = UDim2.new(0.65, 0, 1, 0); ScrLabel.Position = UDim2.new(0.02, 0, 0, 0); ScrLabel.Text = string.format("📜 %s (%s)", scr.Name, scr.ClassName); ScrLabel.TextColor3 = Color3.fromRGB(200, 220, 255); ScrLabel.BackgroundTransparency = 1; ScrLabel.Font = Enum.Font.SourceSans; ScrLabel.TextSize = 9; ScrLabel.TextXAlignment = Enum.TextXAlignment.Left  
                local CopyCodeGuiBtn = Instance.new("TextButton", ScrSubFrame); CopyCodeGuiBtn.Size = UDim2.new(0.3, 0, 0.8, 0); CopyCodeGuiBtn.Position = UDim2.new(0.68, 0, 0.1, 0); CopyCodeGuiBtn.Text = "📋 Copy Code"; CopyCodeGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180); CopyCodeGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CopyCodeGuiBtn.Font = Enum.Font.SourceSansBold; CopyCodeGuiBtn.TextSize = 8; Instance.new("UICorner", CopyCodeGuiBtn).CornerRadius = UDim.new(0, 3)  
                CopyCodeGuiBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(getScriptCode(scr)) end end)  
            end  
        end  
    end  
    GuiScroll.CanvasSize = UDim2.new(0, 0, 0, GuiListUI.AbsoluteContentSize.Y)  
end  

ScanGuiBtn.MouseButton1Click:Connect(function()  
    local targetName = string.lower(GuiTargetBox.Text); local targetPlr = LocalPlayer  
    if targetName ~= "" then for _, p in pairs(Players:GetPlayers()) do if string.find(string.lower(p.Name), targetName) or string.find(string.lower(p.DisplayName), targetName) then targetPlr = p; break end end end  
    scanGuiOfPlayer(targetPlr)  
end)  

ToggleAllGuiBtn.MouseButton1Click:Connect(function()  
    pcall(function()  
        local pGui = currentScannedGuiPlayer:FindFirstChild("PlayerGui")  
        if pGui then  
            for _, sg in pairs(pGui:GetChildren()) do  
                if sg:IsA("ScreenGui") and sg ~= ScreenGui then  
                    sg.Enabled = not sg.Enabled  
                end  
            end  
            scanGuiOfPlayer(currentScannedGuiPlayer)  
        end  
    end)  
end)  

--=========================================================  
-- TAB 9: HITBOX MASTER (GIỮ NGUYÊN)  
--=========================================================  
local HitboxScroll = Instance.new("ScrollingFrame", Page9); HitboxScroll.Size = UDim2.new(1, 0, 1, 0); HitboxScroll.BackgroundTransparency = 1; HitboxScroll.CanvasSize = UDim2.new(0, 0, 0, 0); HitboxScroll.ScrollBarThickness = 3  
local HitboxListUI = Instance.new("UIListLayout", HitboxScroll); HitboxListUI.Padding = UDim.new(0, 6)  

local hitboxConfigs = {  
    NPC = {Box = false, XRay = false, Size = 10, Expand = false, Color = Color3.fromRGB(255, 50, 50)},  
    Players = {Box = false, XRay = false, Size = 10, Expand = false, Color = Color3.fromRGB(50, 150, 255)},  
    Blocks = {Box = false, XRay = false, Color = Color3.fromRGB(0, 255, 120)},  
    InvisBlocks = {Box = false, XRay = false, Color = Color3.fromRGB(255, 255, 0)},  
    TouchTriggers = {Box = false, XRay = false, Color = Color3.fromRGB(200, 0, 255)}  
}  

local activeAdornments = {}  

local function clearAdornments()  
    for _, v in pairs(activeAdornments) do if v then v:Destroy() end end  
    activeAdornments = {}  
end  

local function applyHitboxVisuals()  
    clearAdornments()  

    local function addVisuals(part, config, isChar)  
        if not part or not part:IsA("BasePart") then return end  

        if isChar and config.Expand and part.Name == "HumanoidRootPart" then  
            part.Size = Vector3.new(config.Size, config.Size, config.Size)  
            part.Transparency = 0.6  
            part.BrickColor = BrickColor.new("Bright red")  
            part.Material = Enum.Material.ForceField  
            part.CanCollide = false  
        end  

        if config.Box then  
            local box = Instance.new("SelectionBox")  
            box.Adornee = part  
            box.Color3 = config.Color  
            box.LineThickness = 0.05  
            box.Parent = part  
            table.insert(activeAdornments, box)  
        end  

        if config.XRay then  
            local handle = Instance.new("BoxHandleAdornment")  
            handle.Size = part.Size  
            handle.Color3 = config.Color  
            handle.Transparency = 0.5  
            handle.AlwaysOnTop = true  
            handle.ZIndex = 5  
            handle.Adornee = part  
            handle.Parent = part  
            table.insert(activeAdornments, handle)  
        end  
    end  

    for _, obj in pairs(Workspace:GetDescendants()) do  
        pcall(function()  
            if obj:IsA("BasePart") then  
                local parentModel = obj:FindFirstAncestorOfClass("Model")  
                if parentModel and parentModel:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(parentModel) then  
                    addVisuals(obj, hitboxConfigs.NPC, true)  
                elseif parentModel and Players:GetPlayerFromCharacter(parentModel) and parentModel ~= LocalPlayer.Character then  
                    addVisuals(obj, hitboxConfigs.Players, true)  
                elseif obj.Transparency > 0.8 or not obj.CanCollide then  
                    addVisuals(obj, hitboxConfigs.InvisBlocks, false)  
                elseif obj:FindFirstChildOfClass("TouchTransmitter") then  
                    addVisuals(obj, hitboxConfigs.TouchTriggers, false)  
                else  
                    addVisuals(obj, hitboxConfigs.Blocks, false)  
                end  
            end  
        end)  
    end  
end  

local function createHitboxCard(title, configKey, hasExpand)  
    local cfg = hitboxConfigs[configKey]  
    local Card = Instance.new("Frame", HitboxScroll)  
    Card.Size = UDim2.new(1, -5, 0, hasExpand and 65 or 40)  
    Card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)  
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 5)  

    local TitleLabel = Instance.new("TextLabel", Card)  
    TitleLabel.Size = UDim2.new(0.3, 0, 0, 20)  
    TitleLabel.Position = UDim2.new(0.02, 0, 0, 4)  
    TitleLabel.Text = title  
    TitleLabel.TextColor3 = cfg.Color  
    TitleLabel.BackgroundTransparency = 1  
    TitleLabel.Font = Enum.Font.SourceSansBold  
    TitleLabel.TextSize = 10  
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left  

    local BoxToggleBtn = Instance.new("TextButton", Card)  
    BoxToggleBtn.Size = UDim2.new(0.3, 0, 0, 22)  
    BoxToggleBtn.Position = UDim2.new(0.35, 0, 0, 4)  
    BoxToggleBtn.Text = "📦 Box: OFF"  
    BoxToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
    BoxToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  
    BoxToggleBtn.Font = Enum.Font.SourceSansBold  
    BoxToggleBtn.TextSize = 8  
    Instance.new("UICorner", BoxToggleBtn).CornerRadius = UDim.new(0, 3)  

    local XRayToggleBtn = Instance.new("TextButton", Card)  
    XRayToggleBtn.Size = UDim2.new(0.3, 0, 0, 22)  
    XRayToggleBtn.Position = UDim2.new(0.67, 0, 0, 4)  
    XRayToggleBtn.Text = "👁️ X-Ray: OFF"  
    XRayToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
    XRayToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  
    XRayToggleBtn.Font = Enum.Font.SourceSansBold  
    XRayToggleBtn.TextSize = 8  
    Instance.new("UICorner", XRayToggleBtn).CornerRadius = UDim.new(0, 3)  

    BoxToggleBtn.MouseButton1Click:Connect(function()  
        cfg.Box = not cfg.Box  
        BoxToggleBtn.Text = cfg.Box and "📦 Box: ON" or "📦 Box: OFF"  
        BoxToggleBtn.BackgroundColor3 = cfg.Box and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)  
        applyHitboxVisuals()  
    end)  

    XRayToggleBtn.MouseButton1Click:Connect(function()  
        cfg.XRay = not cfg.XRay  
        XRayToggleBtn.Text = cfg.XRay and "👁️ X-Ray: ON" or "👁️ X-Ray: OFF"  
        XRayToggleBtn.BackgroundColor3 = cfg.XRay and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)  
        applyHitboxVisuals()  
    end)  

    if hasExpand then  
        local ExpandToggleBtn = Instance.new("TextButton", Card)  
        ExpandToggleBtn.Size = UDim2.new(0.45, 0, 0, 22)  
        ExpandToggleBtn.Position = UDim2.new(0.02, 0, 0, 34)  
        ExpandToggleBtn.Text = "💥 Expand Hitbox: OFF"  
        ExpandToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  
        ExpandToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  
        ExpandToggleBtn.Font = Enum.Font.SourceSansBold  
        ExpandToggleBtn.TextSize = 8  
        Instance.new("UICorner", ExpandToggleBtn).CornerRadius = UDim.new(0, 3)  

        local SizeInput = Instance.new("TextBox", Card)  
        SizeInput.Size = UDim2.new(0.48, 0, 0, 22)  
        SizeInput.Position = UDim2.new(0.49, 0, 0, 34)  
        SizeInput.PlaceholderText = "Kích thước (Default: 10)..."  
        SizeInput.Text = "10"  
        SizeInput.BackgroundColor3 = Color3.fromRGB(15, 15, 18)  
        SizeInput.TextColor3 = Color3.fromRGB(255, 255, 255)  
        SizeInput.Font = Enum.Font.SourceSans  
        SizeInput.TextSize = 8  
        Instance.new("UICorner", SizeInput).CornerRadius = UDim.new(0, 3)  

        ExpandToggleBtn.MouseButton1Click:Connect(function()  
            cfg.Expand = not cfg.Expand  
            cfg.Size = tonumber(SizeInput.Text) or 10  
            ExpandToggleBtn.Text = cfg.Expand and "💥 Expand Hitbox: ON" or "💥 Expand Hitbox: OFF"  
            ExpandToggleBtn.BackgroundColor3 = cfg.Expand and Color3.fromRGB(180, 80, 0) or Color3.fromRGB(50, 50, 50)  
            applyHitboxVisuals()  
        end)  
    end  
end  

createHitboxCard("👾 NPC Hitbox", "NPC", true)  
createHitboxCard("👤 Player Hitbox", "Players", true)  
createHitboxCard("🧱 Khối Thường (Blocks)", "Blocks", false)  
createHitboxCard("👻 Khối Tàng Hình (Invis)", "InvisBlocks", false)  
createHitboxCard("⚡ Touch/Trigger Hitbox", "TouchTriggers", false)  

HitboxScroll.CanvasSize = UDim2.new(0, 0, 0, HitboxListUI.AbsoluteContentSize.Y)  

--=========================================================  
-- AUTO REFRESH LOOP  
--=========================================================  
task.spawn(function()  
    while task.wait(2) do  
        pcall(function()  
            if Page2.Visible then updateNpcList() end  
            if Page3.Visible then updateBlockScanner() end  
            if Page4.Visible then updateBackpackInspector() end  
            if Page5.Visible then updateStatsInspector() end  
            if Page9.Visible then applyHitboxVisuals() end  
        end)  
    end  
end)  

-- Kích hoạt tab mặc định  
tabButtons[1].BackgroundColor3 = Color3.fromRGB(0, 180, 120)  
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)  
Page1.Visible = true  
