--=========================================================  
-- ULTIMATE 10-TAB CUSTOM TOOLKIT v14.0 (SIÊU NÂNG CẤP)  
-- Toggle Hotkey: Right Control  
--=========================================================  

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LogService = game:GetService("LogService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

--=========================================================  
-- UTILITY FUNCTIONS  
--=========================================================  
local function getScriptCode(scr)
	if decompile then
		local success, code = pcall(function() return decompile(scr) end)
		if success and code and #code > 0 then return code end
	end
	if (scr:IsA("LocalScript") or scr:IsA("ModuleScript")) and scr.Source and #scr.Source > 0 then
		return scr.Source
	end
	return "-- [Không thể decompile hoặc đọc source]"
end

local function safeCall(func, fallback)
	local success, result = pcall(func)
	if not success then
		warn("[Toolkit] " .. tostring(result))
		return fallback
	end
	return result
end

local function copyToClipboard(text)
	if setclipboard then
		pcall(function() setclipboard(text) end)
		return true
	end
	return false
end

local function getPlayerCharacter(plr)
	return plr and plr.Character or nil
end

local function getHumanoidRootPart(char)
	return char and char:FindFirstChild("HumanoidRootPart") or nil
end

--=========================================================  
-- UI CREATION  
--=========================================================  
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomInspectorUI_v14_0"
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
MainFrame.Size = UDim2.new(0, 800, 0, 580)
MainFrame.Position = UDim2.new(0.5, -400, 0.5, -290)
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
MiniTitle.Text = "🚀 TOOLKIT v14.0"
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
TitleLabel.Text = "🚀 ULTIMATE TOOLKIT v14.0 (SIÊU NÂNG CẤP)"
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
	btn.Size = UDim2.new(0.098, -1, 1, 0)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	btn.TextColor3 = Color3.fromRGB(150, 150, 160)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 8
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

local Page1 = createTab("1.Tọa Độ", 1)
local Page2 = createTab("2.NPC Radar", 2)
local Page3 = createTab("3.Blocks", 3)
local Page4 = createTab("4.Backpack", 4)
local Page5 = createTab("5.Stats", 5)
local Page6 = createTab("6.Spy", 6)
local Page7 = createTab("7.Console", 7)
local Page8 = createTab("8.GUI", 8)
local Page9 = createTab("9.Hitbox", 9)
local Page10 = createTab("10.Game Stats", 10)

--=========================================================  
-- TAB 1: TỌA ĐỘ & PHÁT HIỆN TP BẤT THƯỜNG (NÂNG CẤP)  
--=========================================================  
local PosLabel = Instance.new("TextLabel", Page1)
PosLabel.Size = UDim2.new(1, 0, 0, 28)
PosLabel.Text = "X: 0 | Y: 0 | Z: 0 | Yaw: 0° | Speed: 0.0 m/s"
PosLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
PosLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
PosLabel.Font = Enum.Font.SourceSansBold
PosLabel.TextSize = 11
Instance.new("UICorner", PosLabel).CornerRadius = UDim.new(0, 4)

local SpeedInput = Instance.new("TextBox", Page1)
SpeedInput.Size = UDim2.new(0.12, 0, 0, 22)
SpeedInput.Position = UDim2.new(0, 0, 0, 32)
SpeedInput.PlaceholderText = "Tốc độ"
SpeedInput.Text = "60"
SpeedInput.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
SpeedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 9
Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 4)

local CopyVecBtn = Instance.new("TextButton", Page1)
CopyVecBtn.Size = UDim2.new(0.12, 0, 0, 22)
CopyVecBtn.Position = UDim2.new(0.14, 0, 0, 32)
CopyVecBtn.Text = "📋 Vec3"
CopyVecBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
CopyVecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyVecBtn.Font = Enum.Font.SourceSansBold
CopyVecBtn.TextSize = 8
Instance.new("UICorner", CopyVecBtn).CornerRadius = UDim.new(0, 4)

local CopyCFBtn = Instance.new("TextButton", Page1)
CopyCFBtn.Size = UDim2.new(0.12, 0, 0, 22)
CopyCFBtn.Position = UDim2.new(0.27, 0, 0, 32)
CopyCFBtn.Text = "📋 CFrame"
CopyCFBtn.BackgroundColor3 = Color3.fromRGB(90, 50, 160)
CopyCFBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyCFBtn.Font = Enum.Font.SourceSansBold
CopyCFBtn.TextSize = 8
Instance.new("UICorner", CopyCFBtn).CornerRadius = UDim.new(0, 4)

-- THUẬT TOÁN PHÁT HIỆN TP BẤT THƯỜNG MỚI
local POSITION_HISTORY = {}
local TP_THRESHOLD = 50
local abnormalActive = false
local abnormalList = {}
local lastPosForTP = Vector3.new()

local function detectAbnormalTeleport(currentPos)
	table.insert(POSITION_HISTORY, currentPos)
	if #POSITION_HISTORY > 5 then
		table.remove(POSITION_HISTORY, 1)
	end

	if #POSITION_HISTORY >= 2 then
		local prev = POSITION_HISTORY[#POSITION_HISTORY - 1]
		local dist = (currentPos - prev).Magnitude

		local hasIntermediate = false
		if #POSITION_HISTORY >= 4 then
			local mid = POSITION_HISTORY[#POSITION_HISTORY - 2]
			if (currentPos - mid).Magnitude < dist / 2 then
				hasIntermediate = true
			end
		end

		if dist > TP_THRESHOLD and not hasIntermediate then
			return true, dist
		end
	end
	return false, 0
end

local AbnormalToggle = Instance.new("TextButton", Page1)
AbnormalToggle.Size = UDim2.new(0.2, 0, 0, 22)
AbnormalToggle.Position = UDim2.new(0.40, 0, 0, 32)
AbnormalToggle.Text = "🚨 TP Detect: OFF"
AbnormalToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AbnormalToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AbnormalToggle.Font = Enum.Font.SourceSansBold
AbnormalToggle.TextSize = 8
Instance.new("UICorner", AbnormalToggle).CornerRadius = UDim.new(0, 4)

local ExportWpBtn = Instance.new("TextButton", Page1)
ExportWpBtn.Size = UDim2.new(0.12, 0, 0, 22)
ExportWpBtn.Position = UDim2.new(0.62, 0, 0, 32)
ExportWpBtn.Text = "📤 Export"
ExportWpBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
ExportWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExportWpBtn.Font = Enum.Font.SourceSansBold
ExportWpBtn.TextSize = 8
Instance.new("UICorner", ExportWpBtn).CornerRadius = UDim.new(0, 4)

local ImportWpBtn = Instance.new("TextButton", Page1)
ImportWpBtn.Size = UDim2.new(0.12, 0, 0, 22)
ImportWpBtn.Position = UDim2.new(0.75, 0, 0, 32)
ImportWpBtn.Text = "📥 Import"
ImportWpBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 80)
ImportWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ImportWpBtn.Font = Enum.Font.SourceSansBold
ImportWpBtn.TextSize = 8
Instance.new("UICorner", ImportWpBtn).CornerRadius = UDim.new(0, 4)

local ClearTpLogBtn = Instance.new("TextButton", Page1)
ClearTpLogBtn.Size = UDim2.new(0.12, 0, 0, 22)
ClearTpLogBtn.Position = UDim2.new(0.88, 0, 0, 32)
ClearTpLogBtn.Text = "🗑️ Clear"
ClearTpLogBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearTpLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearTpLogBtn.Font = Enum.Font.SourceSansBold
ClearTpLogBtn.TextSize = 8
Instance.new("UICorner", ClearTpLogBtn).CornerRadius = UDim.new(0, 4)

-- KHUNG HIỂN THỊ TP BẤT THƯỜNG
local AbnormalScroll = Instance.new("ScrollingFrame", Page1)
AbnormalScroll.Size = UDim2.new(1, 0, 0, 80)
AbnormalScroll.Position = UDim2.new(0, 0, 0, 58)
AbnormalScroll.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
AbnormalScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
AbnormalScroll.ScrollBarThickness = 3
Instance.new("UICorner", AbnormalScroll).CornerRadius = UDim.new(0, 4)

local AbnormalListUI = Instance.new("UIListLayout", AbnormalScroll)
AbnormalListUI.Padding = UDim.new(0, 3)

local function addAbnormalLog(pos, cframe, dist)
	local time = os.date("%H:%M:%S")
	table.insert(abnormalList, {pos = pos, cframe = cframe, time = time, dist = dist})

	for _, child in pairs(AbnormalScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for i, data in ipairs(abnormalList) do
		local Frame = Instance.new("Frame", AbnormalScroll)
		Frame.Size = UDim2.new(1, -5, 0, 20)
		Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)

		local Label = Instance.new("TextLabel", Frame)
		Label.Size = UDim2.new(0.65, 0, 1, 0)
		Label.Position = UDim2.new(0.02, 0, 0, 0)
		Label.Text = string.format("[%s] ⚡ TP đột ngột (%.1fm) → (%.1f, %.1f, %.1f)", 
			data.time, data.dist, data.pos.X, data.pos.Y, data.pos.Z)
		Label.TextColor3 = Color3.fromRGB(255, 200, 100)
		Label.BackgroundTransparency = 1
		Label.Font = Enum.Font.SourceSans
		Label.TextSize = 9
		Label.TextXAlignment = Enum.TextXAlignment.Left

		local TpBtn = Instance.new("TextButton", Frame)
		TpBtn.Size = UDim2.new(0.3, 0, 0.8, 0)
		TpBtn.Position = UDim2.new(0.68, 0, 0.1, 0)
		TpBtn.Text = "Teleport"
		TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
		TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		TpBtn.Font = Enum.Font.SourceSansBold
		TpBtn.TextSize = 8
		Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)

		TpBtn.MouseButton1Click:Connect(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CFrame = data.cframe end
		end)
	end
	AbnormalScroll.CanvasSize = UDim2.new(0, 0, 0, AbnormalListUI.AbsoluteContentSize.Y)
end

ClearTpLogBtn.MouseButton1Click:Connect(function()
	abnormalList = {}
	for _, child in pairs(AbnormalScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	AbnormalScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- WAYPOINTS
local WpScroll = Instance.new("ScrollingFrame", Page1)
WpScroll.Size = UDim2.new(1, 0, 1, -150)
WpScroll.Position = UDim2.new(0, 0, 0, 142)
WpScroll.BackgroundTransparency = 1
WpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
WpScroll.ScrollBarThickness = 3

local WpListUI = Instance.new("UIListLayout", WpScroll)
WpListUI.Padding = UDim.new(0, 4)

local waypoints = {}

local function tweenTo(cframe)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local dist = (hrp.Position - cframe.Position).Magnitude
		local spd = tonumber(SpeedInput.Text) or 60
		local info = TweenInfo.new(dist / spd, Enum.EasingStyle.Linear)
		TweenService:Create(hrp, info, {CFrame = cframe}):Play()
	end
end

local function refreshWaypoints()
	for _, child in pairs(WpScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for idx, cf in ipairs(waypoints) do
		local Frame = Instance.new("Frame", WpScroll)
		Frame.Size = UDim2.new(1, -5, 0, 24)
		Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

		local Label = Instance.new("TextLabel", Frame)
		Label.Size = UDim2.new(0.5, 0, 1, 0)
		Label.Position = UDim2.new(0.02, 0, 0, 0)
		Label.Text = string.format("📍 WP #%d: %.1f, %.1f, %.1f", idx, cf.X, cf.Y, cf.Z)
		Label.TextColor3 = Color3.fromRGB(200, 200, 200)
		Label.BackgroundTransparency = 1
		Label.Font = Enum.Font.SourceSans
		Label.TextSize = 9
		Label.TextXAlignment = Enum.TextXAlignment.Left

		local InstantBtn = Instance.new("TextButton", Frame)
		InstantBtn.Size = UDim2.new(0.18, 0, 0.75, 0)
		InstantBtn.Position = UDim2.new(0.54, 0, 0.12, 0)
		InstantBtn.Text = "⚡ TP"
		InstantBtn.BackgroundColor3 = Color3.fromRGB(180, 90, 0)
		InstantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		InstantBtn.Font = Enum.Font.SourceSansBold
		InstantBtn.TextSize = 8
		Instance.new("UICorner", InstantBtn).CornerRadius = UDim.new(0, 3)

		local TweenBtn = Instance.new("TextButton", Frame)
		TweenBtn.Size = UDim2.new(0.18, 0, 0.75, 0)
		TweenBtn.Position = UDim2.new(0.74, 0, 0.12, 0)
		TweenBtn.Text = "✈️ Tween"
		TweenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
		TweenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		TweenBtn.Font = Enum.Font.SourceSansBold
		TweenBtn.TextSize = 8
		Instance.new("UICorner", TweenBtn).CornerRadius = UDim.new(0, 3)

		local DelBtn = Instance.new("TextButton", Frame)
		DelBtn.Size = UDim2.new(0.08, 0, 0.75, 0)
		DelBtn.Position = UDim2.new(0.93, 0, 0.12, 0)
		DelBtn.Text = "✕"
		DelBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		DelBtn.Font = Enum.Font.SourceSansBold
		DelBtn.TextSize = 8
		Instance.new("UICorner", DelBtn).CornerRadius = UDim.new(0, 3)

		InstantBtn.MouseButton1Click:Connect(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then hrp.CFrame = cf end
		end)

		TweenBtn.MouseButton1Click:Connect(function() tweenTo(cf) end)

		DelBtn.MouseButton1Click:Connect(function()
			table.remove(waypoints, idx)
			refreshWaypoints()
		end)
	end
	WpScroll.CanvasSize = UDim2.new(0, 0, 0, WpListUI.AbsoluteContentSize.Y)
end

local SaveWpBtn = Instance.new("TextButton", Page1)
SaveWpBtn.Size = UDim2.new(1, 0, 0, 24)
SaveWpBtn.Position = UDim2.new(0, 0, 1, -24)
SaveWpBtn.Text = "📌 Lưu Tọa Độ Hiện Tại"
SaveWpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
SaveWpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveWpBtn.Font = Enum.Font.SourceSansBold
SaveWpBtn.TextSize = 9
Instance.new("UICorner", SaveWpBtn).CornerRadius = UDim.new(0, 4)

SaveWpBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		table.insert(waypoints, hrp.CFrame)
		refreshWaypoints()
	end
end)

ExportWpBtn.MouseButton1Click:Connect(function()
	local data = {}
	for _, cf in ipairs(waypoints) do
		table.insert(data, {cf.X, cf.Y, cf.Z})
	end
	copyToClipboard(HttpService:JSONEncode(data))
end)

ImportWpBtn.MouseButton1Click:Connect(function()
	if getclipboard then
		safeCall(function()
			local data = HttpService:JSONDecode(getclipboard())
			waypoints = {}
			for _, pos in ipairs(data) do
				table.insert(waypoints, CFrame.new(pos[1], pos[2], pos[3]))
			end
			refreshWaypoints()
		end)
	end
end)

CopyVecBtn.MouseButton1Click:Connect(function()
	copyToClipboard(PosLabel.Text)
end)

CopyCFBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		copyToClipboard(string.format("CFrame.new(%.2f, %.2f, %.2f)", hrp.Position.X, hrp.Position.Y, hrp.Position.Z))
	end
end)

AbnormalToggle.MouseButton1Click:Connect(function()
	abnormalActive = not abnormalActive
	AbnormalToggle.Text = abnormalActive and "🚨 TP Detect: ON" or "🚨 TP Detect: OFF"
	AbnormalToggle.BackgroundColor3 = abnormalActive and Color3.fromRGB(180, 80, 0) or Color3.fromRGB(50, 50, 50)
end)

-- MONITOR LOOP (có thêm speed)
local lastPosForSpeed = Vector3.new()
local currentSpeed = 0
local lastTime = tick()

task.spawn(function()
	while task.wait(0.2) do
		safeCall(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				local p = hrp.Position
				local rx, ry, rz = hrp.CFrame:ToOrientation()

				-- Tính tốc độ
				local dt = tick() - lastTime
				local dist = (p - lastPosForSpeed).Magnitude
				currentSpeed = dist / dt
				lastPosForSpeed = p
				lastTime = tick()

				PosLabel.Text = string.format("X: %.2f | Y: %.2f | Z: %.2f | Yaw: %.1f° | Speed: %.1f m/s", p.X, p.Y, p.Z, math.deg(ry), currentSpeed)

				if abnormalActive then
					local isAbnormal, distTP = detectAbnormalTeleport(p)
					if isAbnormal then
						addAbnormalLog(p, hrp.CFrame, distTP)
					end
				end
			end
		end)
	end
end)

--=========================================================  
-- TAB 2: NPC RADAR (MỖI NPC 1 KHU VỰC RIÊNG + ESP RIÊNG)  
--=========================================================  
local NpcSearchBox = Instance.new("TextBox", Page2)
NpcSearchBox.Size = UDim2.new(0.3, 0, 0, 24)
NpcSearchBox.PlaceholderText = "🔍 Tìm NPC..."
NpcSearchBox.Text = ""
NpcSearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
NpcSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
NpcSearchBox.Font = Enum.Font.SourceSans
NpcSearchBox.TextSize = 10
Instance.new("UICorner", NpcSearchBox).CornerRadius = UDim.new(0, 4)

local MaxDistBox = Instance.new("TextBox", Page2)
MaxDistBox.Size = UDim2.new(0.12, 0, 0, 24)
MaxDistBox.Position = UDim2.new(0.32, 0, 0, 0)
MaxDistBox.PlaceholderText = "Max Dist"
MaxDistBox.Text = "500"
MaxDistBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
MaxDistBox.TextColor3 = Color3.fromRGB(255, 255, 255)
MaxDistBox.Font = Enum.Font.SourceSans
MaxDistBox.TextSize = 9
Instance.new("UICorner", MaxDistBox).CornerRadius = UDim.new(0, 4)

local RefreshNpcBtn = Instance.new("TextButton", Page2)
RefreshNpcBtn.Size = UDim2.new(0.12, 0, 0, 24)
RefreshNpcBtn.Position = UDim2.new(0.46, 0, 0, 0)
RefreshNpcBtn.Text = "🔄 Refresh"
RefreshNpcBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
RefreshNpcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshNpcBtn.Font = Enum.Font.SourceSansBold
RefreshNpcBtn.TextSize = 9
Instance.new("UICorner", RefreshNpcBtn).CornerRadius = UDim.new(0, 4)

local NpcEspAllBtn = Instance.new("TextButton", Page2)
NpcEspAllBtn.Size = UDim2.new(0.18, 0, 0, 24)
NpcEspAllBtn.Position = UDim2.new(0.60, 0, 0, 0)
NpcEspAllBtn.Text = "👁️ ESP All: OFF"
NpcEspAllBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
NpcEspAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NpcEspAllBtn.Font = Enum.Font.SourceSansBold
NpcEspAllBtn.TextSize = 8
Instance.new("UICorner", NpcEspAllBtn).CornerRadius = UDim.new(0, 4)

local ShowScriptsToggle = Instance.new("TextButton", Page2)
ShowScriptsToggle.Size = UDim2.new(0.18, 0, 0, 24)
ShowScriptsToggle.Position = UDim2.new(0.80, 0, 0, 0)
ShowScriptsToggle.Text = "📜 Scripts: OFF"
ShowScriptsToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ShowScriptsToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
ShowScriptsToggle.Font = Enum.Font.SourceSansBold
ShowScriptsToggle.TextSize = 8
Instance.new("UICorner", ShowScriptsToggle).CornerRadius = UDim.new(0, 4)

local NpcScroll = Instance.new("ScrollingFrame", Page2)
NpcScroll.Size = UDim2.new(1, 0, 1, -30)
NpcScroll.Position = UDim2.new(0, 0, 0, 30)
NpcScroll.BackgroundTransparency = 1
NpcScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
NpcScroll.ScrollBarThickness = 3

local NpcListUI = Instance.new("UIListLayout", NpcScroll)
NpcListUI.Padding = UDim.new(0, 6)

local npcESPs = {}
local showScripts = false
local espAllActive = false

local function createNPCCard(npcModel, hum, hrp, distance, myHrp)
	local Card = Instance.new("Frame")
	Card.Size = UDim2.new(1, -5, 0, 32)
	Card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 4)

	-- Header
	local header = Instance.new("TextLabel", Card)
	header.Size = UDim2.new(0.4, 0, 1, 0)
	header.Position = UDim2.new(0.02, 0, 0, 0)
	header.Text = string.format("👾 %s | HP: %d/%d | %dm", 
		npcModel.Name, math.floor(hum.Health), math.floor(hum.MaxHealth), distance)
	header.TextColor3 = Color3.fromRGB(220, 220, 220)
	header.BackgroundTransparency = 1
	header.Font = Enum.Font.SourceSans
	header.TextSize = 10
	header.TextXAlignment = Enum.TextXAlignment.Left

	-- Nút Teleport
	local TpBtn = Instance.new("TextButton", Card)
	TpBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
	TpBtn.Position = UDim2.new(0.42, 0, 0.15, 0)
	TpBtn.Text = "Teleport"
	TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
	TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	TpBtn.Font = Enum.Font.SourceSansBold
	TpBtn.TextSize = 8
	Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)

	TpBtn.MouseButton1Click:Connect(function()
		if myHrp and hrp then
			myHrp.CFrame = hrp.CFrame * CFrame.new(0, 2, 3)
		end
	end)

	-- ESP riêng cho từng NPC
	local EspBtn = Instance.new("TextButton", Card)
	EspBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
	EspBtn.Position = UDim2.new(0.56, 0, 0.15, 0)
	EspBtn.Text = "ESP: OFF"
	EspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	EspBtn.Font = Enum.Font.SourceSansBold
	EspBtn.TextSize = 7
	Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 3)

	local espActive = false
	local highlight = nil

	EspBtn.MouseButton1Click:Connect(function()
		espActive = not espActive
		EspBtn.Text = espActive and "ESP: ON" or "ESP: OFF"
		EspBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)

		if espActive then
			if not highlight then
				highlight = Instance.new("Highlight", npcModel)
				highlight.Name = "NpcESP"
				highlight.FillColor = Color3.fromRGB(255, 200, 0)
				highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
				table.insert(npcESPs, highlight)
			end
		else
			if highlight then
				highlight:Destroy()
				highlight = nil
				for i, v in ipairs(npcESPs) do
					if v == highlight then table.remove(npcESPs, i) break end
				end
			end
		end
	end)

	-- Nút Scripts
	local scripts = {}
	for _, d in pairs(npcModel:GetDescendants()) do
		if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
			table.insert(scripts, d)
		end
	end

	if #scripts > 0 then
		local ScriptBtn = Instance.new("TextButton", Card)
		ScriptBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
		ScriptBtn.Position = UDim2.new(0.70, 0, 0.15, 0)
		ScriptBtn.Text = "📜 Script ("..#scripts..")"
		ScriptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
		ScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		ScriptBtn.Font = Enum.Font.SourceSansBold
		ScriptBtn.TextSize = 7
		Instance.new("UICorner", ScriptBtn).CornerRadius = UDim.new(0, 3)

		local expanded = false
		local scriptContainer = nil

		ScriptBtn.MouseButton1Click:Connect(function()
			expanded = not expanded
			if scriptContainer then scriptContainer:Destroy() scriptContainer = nil end

			if expanded then
				scriptContainer = Instance.new("Frame", Card)
				scriptContainer.Size = UDim2.new(0.96, 0, 0, 0)
				scriptContainer.Position = UDim2.new(0.02, 0, 1, 2)
				scriptContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
				scriptContainer.AutomaticSize = Enum.AutomaticSize.Y
				Instance.new("UICorner", scriptContainer).CornerRadius = UDim.new(0, 4)

				local listUI = Instance.new("UIListLayout", scriptContainer)
				listUI.Padding = UDim.new(0, 3)

				for _, scr in ipairs(scripts) do
					local scrFrame = Instance.new("Frame", scriptContainer)
					scrFrame.Size = UDim2.new(1, -4, 0, 20)
					scrFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
					Instance.new("UICorner", scrFrame).CornerRadius = UDim.new(0, 3)

					local scrLabel = Instance.new("TextLabel", scrFrame)
					scrLabel.Size = UDim2.new(0.6, 0, 1, 0)
					scrLabel.Position = UDim2.new(0.02, 0, 0, 0)
					scrLabel.Text = string.format("📜 %s", scr.Name)
					scrLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
					scrLabel.BackgroundTransparency = 1
					scrLabel.Font = Enum.Font.SourceSans
					scrLabel.TextSize = 8
					scrLabel.TextXAlignment = Enum.TextXAlignment.Left

					local CopyBtn = Instance.new("TextButton", scrFrame)
					CopyBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
					CopyBtn.Position = UDim2.new(0.63, 0, 0.1, 0)
					CopyBtn.Text = "📋 Copy"
					CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
					CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					CopyBtn.Font = Enum.Font.SourceSansBold
					CopyBtn.TextSize = 7
					Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 3)

					CopyBtn.MouseButton1Click:Connect(function()
						copyToClipboard(getScriptCode(scr))
					end)
				end

				Card.Size = UDim2.new(1, -5, 0, 32 + scriptContainer.AbsoluteSize.Y + 4)
				NpcScroll.CanvasSize = UDim2.new(0, 0, 0, NpcListUI.AbsoluteContentSize.Y)
			else
				Card.Size = UDim2.new(1, -5, 0, 32)
			end
		end)
	end

	return Card
end

local function updateNpcList()
	for _, child in pairs(NpcScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	-- Xóa ESP cũ
	for _, hl in pairs(npcESPs) do
		safeCall(function() hl:Destroy() end)
	end
	npcESPs = {}

	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local filterText = string.lower(NpcSearchBox.Text)
	local maxDistLimit = tonumber(MaxDistBox.Text) or 500

	for _, model in pairs(Workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			if not Players:GetPlayerFromCharacter(model) then
				local hum = model:FindFirstChildOfClass("Humanoid")
				local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
				local dist = (myHrp and hrp) and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0

				if (filterText == "" or string.find(string.lower(model.Name), filterText)) and dist <= maxDistLimit then
					local card = createNPCCard(model, hum, hrp, dist, myHrp)
					card.Parent = NpcScroll
				end
			end
		end
	end

	NpcScroll.CanvasSize = UDim2.new(0, 0, 0, NpcListUI.AbsoluteContentSize.Y)
end

RefreshNpcBtn.MouseButton1Click:Connect(updateNpcList)

NpcEspAllBtn.MouseButton1Click:Connect(function()
	espAllActive = not espAllActive
	NpcEspAllBtn.Text = espAllActive and "👁️ ESP All: ON" or "👁️ ESP All: OFF"
	NpcEspAllBtn.BackgroundColor3 = espAllActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
	updateNpcList()
end)

ShowScriptsToggle.MouseButton1Click:Connect(function()
	showScripts = not showScripts
	ShowScriptsToggle.Text = showScripts and "📜 Scripts: ON" or "📜 Scripts: OFF"
	ShowScriptsToggle.BackgroundColor3 = showScripts and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
	updateNpcList()
end)

--=========================================================  
-- TAB 3: BLOCKS (MỖI KHỐI ESP RIÊNG + XÓA ALL)  
--=========================================================  
local BlockSearchBox = Instance.new("TextBox", Page3)
BlockSearchBox.Size = UDim2.new(0.2, 0, 0, 24)
BlockSearchBox.PlaceholderText = "🔍 Tìm Block..."
BlockSearchBox.Text = ""
BlockSearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
BlockSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BlockSearchBox.Font = Enum.Font.SourceSans
BlockSearchBox.TextSize = 10
Instance.new("UICorner", BlockSearchBox).CornerRadius = UDim.new(0, 4)

local RefreshBlockBtn = Instance.new("TextButton", Page3)
RefreshBlockBtn.Size = UDim2.new(0.09, 0, 0, 24)
RefreshBlockBtn.Position = UDim2.new(0.22, 0, 0, 0)
RefreshBlockBtn.Text = "🔄"
RefreshBlockBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
RefreshBlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBlockBtn.Font = Enum.Font.SourceSansBold
RefreshBlockBtn.TextSize = 9
Instance.new("UICorner", RefreshBlockBtn).CornerRadius = UDim.new(0, 4)

-- Nút xóa tất cả block
local ClearAllBlocksBtn = Instance.new("TextButton", Page3)
ClearAllBlocksBtn.Size = UDim2.new(0.1, 0, 0, 24)
ClearAllBlocksBtn.Position = UDim2.new(0.32, 0, 0, 0)
ClearAllBlocksBtn.Text = "🗑️ Xóa All"
ClearAllBlocksBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ClearAllBlocksBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearAllBlocksBtn.Font = Enum.Font.SourceSansBold
ClearAllBlocksBtn.TextSize = 8
Instance.new("UICorner", ClearAllBlocksBtn).CornerRadius = UDim.new(0, 4)

local InstantHoldBtn = Instance.new("TextButton", Page3)
InstantHoldBtn.Size = UDim2.new(0.1, 0, 0, 24)
InstantHoldBtn.Position = UDim2.new(0.43, 0, 0, 0)
InstantHoldBtn.Text = "⚡ Hold=0"
InstantHoldBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 0)
InstantHoldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InstantHoldBtn.Font = Enum.Font.SourceSansBold
InstantHoldBtn.TextSize = 8
Instance.new("UICorner", InstantHoldBtn).CornerRadius = UDim.new(0, 4)

local FirePromptsBtn = Instance.new("TextButton", Page3)
FirePromptsBtn.Size = UDim2.new(0.12, 0, 0, 24)
FirePromptsBtn.Position = UDim2.new(0.54, 0, 0, 0)
FirePromptsBtn.Text = "🔥 Fire Prompts"
FirePromptsBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
FirePromptsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FirePromptsBtn.Font = Enum.Font.SourceSansBold
FirePromptsBtn.TextSize = 8
Instance.new("UICorner", FirePromptsBtn).CornerRadius = UDim.new(0, 4)

local AutoLoopBtn = Instance.new("TextButton", Page3)
AutoLoopBtn.Size = UDim2.new(0.1, 0, 0, 24)
AutoLoopBtn.Position = UDim2.new(0.67, 0, 0, 0)
AutoLoopBtn.Text = "🔄 Loop: OFF"
AutoLoopBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoLoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoLoopBtn.Font = Enum.Font.SourceSansBold
AutoLoopBtn.TextSize = 8
Instance.new("UICorner", AutoLoopBtn).CornerRadius = UDim.new(0, 4)

local BlockScroll = Instance.new("ScrollingFrame", Page3)
BlockScroll.Size = UDim2.new(1, 0, 1, -30)
BlockScroll.Position = UDim2.new(0, 0, 0, 30)
BlockScroll.BackgroundTransparency = 1
BlockScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
BlockScroll.ScrollBarThickness = 3

local BlockListUI = Instance.new("UIListLayout", BlockScroll)
BlockListUI.Padding = UDim.new(0, 4)

local blockHighlights = {}
local autoLoopActive = false

ClearAllBlocksBtn.MouseButton1Click:Connect(function()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj:IsA("Terrain") then
			local parent = obj.Parent
			if parent and not Players:GetPlayerFromCharacter(parent) then
				obj:Destroy()
			end
		end
	end
	updateBlockList()
end)

InstantHoldBtn.MouseButton1Click:Connect(function()
	safeCall(function()
		for _, prompt in pairs(Workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				prompt.HoldDuration = 0
			end
		end
	end)
end)

FirePromptsBtn.MouseButton1Click:Connect(function()
	safeCall(function()
		for _, prompt in pairs(Workspace:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") and fireproximityprompt then
				fireproximityprompt(prompt)
			end
		end
	end)
end)

AutoLoopBtn.MouseButton1Click:Connect(function()
	autoLoopActive = not autoLoopActive
	AutoLoopBtn.Text = autoLoopActive and "🔄 Loop: ON" or "🔄 Loop: OFF"
	AutoLoopBtn.BackgroundColor3 = autoLoopActive and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(50, 50, 50)
end)

task.spawn(function()
	while task.wait(0.5) do
		if autoLoopActive then
			safeCall(function()
				for _, prompt in pairs(Workspace:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") and fireproximityprompt then
						fireproximityprompt(prompt)
					end
				end
			end)
		end
	end
end)

local function updateBlockList()
	for _, child in pairs(BlockScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	-- Xóa ESP cũ
	for _, hl in pairs(blockHighlights) do
		safeCall(function() hl:Destroy() end)
	end
	blockHighlights = {}

	local filterText = string.lower(BlockSearchBox.Text)
	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj:IsA("Terrain") then
			local name = obj.Name or ""
			local parentName = obj.Parent and obj.Parent.Name or ""

			if filterText == "" or string.find(string.lower(name), filterText) or string.find(string.lower(parentName), filterText) then
				local dist = myHrp and math.floor((obj.Position - myHrp.Position).Magnitude) or 0

				local Card = Instance.new("Frame", BlockScroll)
				Card.Size = UDim2.new(1, -5, 0, 30)
				Card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
				Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 4)

				-- Thông tin
				local info = Instance.new("TextLabel", Card)
				info.Size = UDim2.new(0.35, 0, 1, 0)
				info.Position = UDim2.new(0.02, 0, 0, 0)
				info.Text = string.format("📦 %s | %dm", obj.Name, dist)
				info.TextColor3 = Color3.fromRGB(200, 200, 200)
				info.BackgroundTransparency = 1
				info.Font = Enum.Font.SourceSans
				info.TextSize = 9
				info.TextXAlignment = Enum.TextXAlignment.Left

				-- Nút Teleport
				local TpBtn = Instance.new("TextButton", Card)
				TpBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
				TpBtn.Position = UDim2.new(0.38, 0, 0.15, 0)
				TpBtn.Text = "TP"
				TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
				TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				TpBtn.Font = Enum.Font.SourceSansBold
				TpBtn.TextSize = 8
				Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)

				TpBtn.MouseButton1Click:Connect(function()
					if myHrp then
						myHrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
					end
				end)

				-- Nút Copy Position
				local CopyBtn = Instance.new("TextButton", Card)
				CopyBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
				CopyBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
				CopyBtn.Text = "📋 Pos"
				CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
				CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				CopyBtn.Font = Enum.Font.SourceSansBold
				CopyBtn.TextSize = 7
				Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 3)

				CopyBtn.MouseButton1Click:Connect(function()
					copyToClipboard(string.format("%.1f, %.1f, %.1f", obj.Position.X, obj.Position.Y, obj.Position.Z))
				end)

				-- ESP riêng cho từng block
				local EspBtn = Instance.new("TextButton", Card)
				EspBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
				EspBtn.Position = UDim2.new(0.66, 0, 0.15, 0)
				EspBtn.Text = "ESP: OFF"
				EspBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				EspBtn.Font = Enum.Font.SourceSansBold
				EspBtn.TextSize = 7
				Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 3)

				local espActive = false
				local highlight = nil

				EspBtn.MouseButton1Click:Connect(function()
					espActive = not espActive
					EspBtn.Text = espActive and "ESP: ON" or "ESP: OFF"
					EspBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)

					if espActive then
						highlight = Instance.new("Highlight", obj)
						highlight.Name = "BlockESP"
						highlight.FillColor = Color3.fromRGB(0, 255, 0)
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
						table.insert(blockHighlights, highlight)
					else
						if highlight then
							highlight:Destroy()
							for i, v in ipairs(blockHighlights) do
								if v == highlight then table.remove(blockHighlights, i) break end
							end
							highlight = nil
						end
					end
				end)

				-- Scripts trong block
				local scripts = {}
				for _, d in pairs(obj:GetDescendants()) do
					if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
						table.insert(scripts, d)
					end
				end

				if #scripts > 0 then
					local ScriptBtn = Instance.new("TextButton", Card)
					ScriptBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
					ScriptBtn.Position = UDim2.new(0.80, 0, 0.15, 0)
					ScriptBtn.Text = "📜"..#scripts
					ScriptBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
					ScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					ScriptBtn.Font = Enum.Font.SourceSansBold
					ScriptBtn.TextSize = 7
					Instance.new("UICorner", ScriptBtn).CornerRadius = UDim.new(0, 3)

					ScriptBtn.MouseButton1Click:Connect(function()
						local popup = Instance.new("Frame", ScreenGui)
						popup.Size = UDim2.new(0, 400, 0, 300)
						popup.Position = UDim2.new(0.5, -200, 0.5, -150)
						popup.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
						Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)

						local close = Instance.new("TextButton", popup)
						close.Size = UDim2.new(0, 30, 0, 30)
						close.Position = UDim2.new(1, -35, 0, 5)
						close.Text = "✕"
						close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
						close.TextColor3 = Color3.fromRGB(255, 255, 255)
						close.Font = Enum.Font.SourceSansBold
						close.TextSize = 12
						close.MouseButton1Click:Connect(function() popup:Destroy() end)

						local title = Instance.new("TextLabel", popup)
						title.Size = UDim2.new(0.8, 0, 0, 30)
						title.Position = UDim2.new(0.05, 0, 0, 0)
						title.Text = "Scripts trong "..obj.Name
						title.TextColor3 = Color3.fromRGB(0, 255, 200)
						title.BackgroundTransparency = 1
						title.Font = Enum.Font.SourceSansBold
						title.TextSize = 12

						local scroll = Instance.new("ScrollingFrame", popup)
						scroll.Size = UDim2.new(0.95, 0, 0.85, 0)
						scroll.Position = UDim2.new(0.025, 0, 0.1, 0)
						scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
						scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
						scroll.ScrollBarThickness = 3

						local listUI = Instance.new("UIListLayout", scroll)
						listUI.Padding = UDim.new(0, 4)

						for _, scr in ipairs(scripts) do
							local frame = Instance.new("Frame", scroll)
							frame.Size = UDim2.new(1, -5, 0, 24)
							frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
							Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

							local label = Instance.new("TextLabel", frame)
							label.Size = UDim2.new(0.55, 0, 1, 0)
							label.Position = UDim2.new(0.02, 0, 0, 0)
							label.Text = scr.Name
							label.TextColor3 = Color3.fromRGB(200, 200, 200)
							label.BackgroundTransparency = 1
							label.Font = Enum.Font.SourceSans
							label.TextSize = 9
							label.TextXAlignment = Enum.TextXAlignment.Left

							local copy = Instance.new("TextButton", frame)
							copy.Size = UDim2.new(0.38, 0, 0.8, 0)
							copy.Position = UDim2.new(0.59, 0, 0.1, 0)
							copy.Text = "📋 Copy Code"
							copy.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
							copy.TextColor3 = Color3.fromRGB(255, 255, 255)
							copy.Font = Enum.Font.SourceSansBold
							copy.TextSize = 8
							Instance.new("UICorner", copy).CornerRadius = UDim.new(0, 3)

							copy.MouseButton1Click:Connect(function()
								copyToClipboard(getScriptCode(scr))
							end)
						end
						scroll.CanvasSize = UDim2.new(0, 0, 0, listUI.AbsoluteContentSize.Y)
					end)
				end
			end
		end
	end

	BlockScroll.CanvasSize = UDim2.new(0, 0, 0, BlockListUI.AbsoluteContentSize.Y)
end

RefreshBlockBtn.MouseButton1Click:Connect(updateBlockList)

--=========================================================  
-- TAB 4: BACKPACK + STORAGE (NÂNG CẤP)  
--=========================================================  
local BpSearchBox = Instance.new("TextBox", Page4)
BpSearchBox.Size = UDim2.new(0.25, 0, 0, 22)
BpSearchBox.PlaceholderText = "🔍 Tìm item..."
BpSearchBox.Text = ""
BpSearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
BpSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
BpSearchBox.Font = Enum.Font.SourceSans
BpSearchBox.TextSize = 9
Instance.new("UICorner", BpSearchBox).CornerRadius = UDim.new(0, 4)

local RefreshBpBtn = Instance.new("TextButton", Page4)
RefreshBpBtn.Size = UDim2.new(0.1, 0, 0, 22)
RefreshBpBtn.Position = UDim2.new(0.27, 0, 0, 0)
RefreshBpBtn.Text = "🔄"
RefreshBpBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
RefreshBpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBpBtn.Font = Enum.Font.SourceSansBold
RefreshBpBtn.TextSize = 10
Instance.new("UICorner", RefreshBpBtn).CornerRadius = UDim.new(0, 4)

local EquipAllBtn = Instance.new("TextButton", Page4)
EquipAllBtn.Size = UDim2.new(0.15, 0, 0, 22)
EquipAllBtn.Position = UDim2.new(0.38, 0, 0, 0)
EquipAllBtn.Text = "⚔️ Equip All"
EquipAllBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
EquipAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EquipAllBtn.Font = Enum.Font.SourceSansBold
EquipAllBtn.TextSize = 8
Instance.new("UICorner", EquipAllBtn).CornerRadius = UDim.new(0, 4)

local DropAllBtn = Instance.new("TextButton", Page4)
DropAllBtn.Size = UDim2.new(0.12, 0, 0, 22)
DropAllBtn.Position = UDim2.new(0.55, 0, 0, 0)
DropAllBtn.Text = "🗑️ Drop"
DropAllBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
DropAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DropAllBtn.Font = Enum.Font.SourceSansBold
DropAllBtn.TextSize = 8
Instance.new("UICorner", DropAllBtn).CornerRadius = UDim.new(0, 4)

local StorageBtn = Instance.new("TextButton", Page4)
StorageBtn.Size = UDim2.new(0.15, 0, 0, 22)
StorageBtn.Position = UDim2.new(0.68, 0, 0, 0)
StorageBtn.Text = "📦 Storage"
StorageBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 150)
StorageBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StorageBtn.Font = Enum.Font.SourceSansBold
StorageBtn.TextSize = 8
Instance.new("UICorner", StorageBtn).CornerRadius = UDim.new(0, 4)

local CopyFromPlayerBtn = Instance.new("TextButton", Page4)
CopyFromPlayerBtn.Size = UDim2.new(0.15, 0, 0, 22)
CopyFromPlayerBtn.Position = UDim2.new(0.84, 0, 0, 0)
CopyFromPlayerBtn.Text = "📋 Copy From"
CopyFromPlayerBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
CopyFromPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyFromPlayerBtn.Font = Enum.Font.SourceSansBold
CopyFromPlayerBtn.TextSize = 7
Instance.new("UICorner", CopyFromPlayerBtn).CornerRadius = UDim.new(0, 4)

local BpScroll = Instance.new("ScrollingFrame", Page4)
BpScroll.Size = UDim2.new(1, 0, 1, -28)
BpScroll.Position = UDim2.new(0, 0, 0, 28)
BpScroll.BackgroundTransparency = 1
BpScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
BpScroll.ScrollBarThickness = 3

local BpListUI = Instance.new("UIListLayout", BpScroll)
BpListUI.Padding = UDim.new(0, 6)

-- Tab Switch cho Backpack / Storage
local bpMode = "backpack" -- "backpack" or "storage"

EquipAllBtn.MouseButton1Click:Connect(function()
	safeCall(function()
		local bp = LocalPlayer:FindFirstChild("Backpack")
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if bp and hum then
			for _, tool in pairs(bp:GetChildren()) do
				if tool:IsA("Tool") then
					hum:EquipTool(tool)
				end
			end
		end
	end)
end)

DropAllBtn.MouseButton1Click:Connect(function()
	safeCall(function()
		local char = LocalPlayer.Character
		if char then
			for _, tool in pairs(char:GetChildren()) do
				if tool:IsA("Tool") then
					tool.Parent = Workspace
				end
			end
		end
	end)
end)

StorageBtn.MouseButton1Click:Connect(function()
	bpMode = bpMode == "backpack" and "storage" or "backpack"
	StorageBtn.Text = bpMode == "backpack" and "📦 Backpack" or "📦 Storage"
	updateBackpackList()
end)

local function buildItemScriptsUI(item, parentFrame)
	local scriptsFound = {}
	for _, desc in pairs(item:GetDescendants()) do
		if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("ModuleScript") then
			table.insert(scriptsFound, desc)
		end
	end

	if #scriptsFound == 0 then
		local EmptyText = Instance.new("TextLabel", parentFrame)
		EmptyText.Size = UDim2.new(1, 0, 0, 14)
		EmptyText.Text = "  └─ [Không có Script]"
		EmptyText.TextColor3 = Color3.fromRGB(110, 110, 110)
		EmptyText.BackgroundTransparency = 1
		EmptyText.Font = Enum.Font.SourceSansItalic
		EmptyText.TextSize = 8
		EmptyText.TextXAlignment = Enum.TextXAlignment.Left
	else
		for _, scr in pairs(scriptsFound) do
			local ScrFrame = Instance.new("Frame", parentFrame)
			ScrFrame.Size = UDim2.new(1, -4, 0, 18)
			ScrFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
			Instance.new("UICorner", ScrFrame).CornerRadius = UDim.new(0, 3)

			local ScrLabel = Instance.new("TextLabel", ScrFrame)
			ScrLabel.Size = UDim2.new(0.6, 0, 1, 0)
			ScrLabel.Position = UDim2.new(0.02, 0, 0, 0)
			ScrLabel.Text = string.format("📜 %s (%s)", scr.Name, scr.ClassName)
			ScrLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
			ScrLabel.BackgroundTransparency = 1
			ScrLabel.Font = Enum.Font.SourceSans
			ScrLabel.TextSize = 8
			ScrLabel.TextXAlignment = Enum.TextXAlignment.Left

			local CopyCodeBtn = Instance.new("TextButton", ScrFrame)
			CopyCodeBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
			CopyCodeBtn.Position = UDim2.new(0.62, 0, 0.1, 0)
			CopyCodeBtn.Text = "📋 Copy"
			CopyCodeBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
			CopyCodeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			CopyCodeBtn.Font = Enum.Font.SourceSansBold
			CopyCodeBtn.TextSize = 7
			Instance.new("UICorner", CopyCodeBtn).CornerRadius = UDim.new(0, 3)

			CopyCodeBtn.MouseButton1Click:Connect(function()
				copyToClipboard(getScriptCode(scr))
			end)
		end
	end
end

local function getItemsFromStorage()
	local items = {}
	local containers = {ReplicatedStorage, ServerStorage}
	for _, container in pairs(containers) do
		if container then
			for _, child in pairs(container:GetChildren()) do
				if child:IsA("Tool") or child:IsA("Model") or child:IsA("Folder") then
					table.insert(items, child)
				end
			end
		end
	end
	return items
end

local function updateBackpackList()
	for _, child in pairs(BpScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local filterText = string.lower(BpSearchBox.Text)

	if bpMode == "backpack" then
		-- Hiển thị Backpack của tất cả người chơi
		for _, plr in pairs(Players:GetPlayers()) do
			local allItems = {}
			local bp = plr:FindFirstChild("Backpack")
			if bp then
				for _, item in pairs(bp:GetChildren()) do
					if item:IsA("Tool") then
						table.insert(allItems, {Obj = item, Status = "Túi đồ"})
					end
				end
			end
			if plr.Character then
				for _, item in pairs(plr.Character:GetChildren()) do
					if item:IsA("Tool") then
						table.insert(allItems, {Obj = item, Status = "Đang cầm"})
					end
				end
			end

			local PlayerCard = Instance.new("Frame", BpScroll)
			PlayerCard.Size = UDim2.new(1, -5, 0, 100 + (#allItems * 30))
			PlayerCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
			Instance.new("UICorner", PlayerCard).CornerRadius = UDim.new(0, 5)

			local PlayerTitle = Instance.new("TextLabel", PlayerCard)
			PlayerTitle.Size = UDim2.new(0.96, 0, 0, 18)
			PlayerTitle.Position = UDim2.new(0.02, 0, 0.02, 0)
			PlayerTitle.Text = string.format("👤 %s (%d items)", plr.DisplayName, #allItems)
			PlayerTitle.TextColor3 = plr == LocalPlayer and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 210, 80)
			PlayerTitle.BackgroundTransparency = 1
			PlayerTitle.Font = Enum.Font.SourceSansBold
			PlayerTitle.TextSize = 10
			PlayerTitle.TextXAlignment = Enum.TextXAlignment.Left

			local ItemsContainer = Instance.new("ScrollingFrame", PlayerCard)
			ItemsContainer.Size = UDim2.new(0.96, 0, 0, 75)
			ItemsContainer.Position = UDim2.new(0.02, 0, 0.18, 0)
			ItemsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
			ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
			ItemsContainer.ScrollBarThickness = 3

			local ItemsListUI = Instance.new("UIListLayout", ItemsContainer)
			ItemsListUI.Padding = UDim.new(0, 3)

			if #allItems == 0 then
				local EmptyText = Instance.new("TextLabel", ItemsContainer)
				EmptyText.Size = UDim2.new(1, 0, 0, 20)
				EmptyText.Text = "Túi đồ trống"
				EmptyText.TextColor3 = Color3.fromRGB(120, 120, 120)
				EmptyText.BackgroundTransparency = 1
				EmptyText.Font = Enum.Font.SourceSansItalic
				EmptyText.TextSize = 9
			else
				for _, itemData in pairs(allItems) do
					if filterText == "" or string.find(string.lower(itemData.Obj.Name), filterText) then
						local toolFrame = Instance.new("Frame", ItemsContainer)
						toolFrame.Size = UDim2.new(1, -4, 0, 28)
						toolFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
						Instance.new("UICorner", toolFrame).CornerRadius = UDim.new(0, 4)

						local ToolTitle = Instance.new("TextLabel", toolFrame)
						ToolTitle.Size = UDim2.new(0.4, 0, 1, 0)
						ToolTitle.Position = UDim2.new(0.02, 0, 0, 0)
						ToolTitle.Text = string.format("🗡️ %s [%s]", itemData.Obj.Name, itemData.Status)
						ToolTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
						ToolTitle.BackgroundTransparency = 1
						ToolTitle.Font = Enum.Font.SourceSansBold
						ToolTitle.TextSize = 8
						ToolTitle.TextXAlignment = Enum.TextXAlignment.Left

						-- Nút Copy từ người khác (nếu không phải local player)
						if plr ~= LocalPlayer then
							local CopyFromBtn = Instance.new("TextButton", toolFrame)
							CopyFromBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
							CopyFromBtn.Position = UDim2.new(0.42, 0, 0.1, 0)
							CopyFromBtn.Text = "📋 Copy Item"
							CopyFromBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
							CopyFromBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
							CopyFromBtn.Font = Enum.Font.SourceSansBold
							CopyFromBtn.TextSize = 7
							Instance.new("UICorner", CopyFromBtn).CornerRadius = UDim.new(0, 3)

							CopyFromBtn.MouseButton1Click:Connect(function()
								safeCall(function()
									local clone = itemData.Obj:Clone()
									local bp = LocalPlayer:FindFirstChild("Backpack")
									if bp then
										clone.Parent = bp
									end
								end)
							end)
						end

						-- Scripts
						local ScriptsSubContainer = Instance.new("Frame", toolFrame)
						ScriptsSubContainer.Size = UDim2.new(0.5, 0, 0, 0)
						ScriptsSubContainer.Position = UDim2.new(0.5, 0, 0.1, 0)
						ScriptsSubContainer.BackgroundTransparency = 1
						ScriptsSubContainer.AutomaticSize = Enum.AutomaticSize.Y

						local SubListUI = Instance.new("UIListLayout", ScriptsSubContainer)
						SubListUI.Padding = UDim.new(0, 2)

						buildItemScriptsUI(itemData.Obj, ScriptsSubContainer)
					end
				end
			end

			ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, ItemsListUI.AbsoluteContentSize.Y)
		end
	else
		-- Hiển thị Storage
		local storageItems = getItemsFromStorage()

		local StorageCard = Instance.new("Frame", BpScroll)
		StorageCard.Size = UDim2.new(1, -5, 0, 80 + (#storageItems * 30))
		StorageCard.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		Instance.new("UICorner", StorageCard).CornerRadius = UDim.new(0, 5)

		local Title = Instance.new("TextLabel", StorageCard)
		Title.Size = UDim2.new(0.96, 0, 0, 18)
		Title.Position = UDim2.new(0.02, 0, 0.02, 0)
		Title.Text = string.format("📦 Storage (%d items)", #storageItems)
		Title.TextColor3 = Color3.fromRGB(255, 200, 100)
		Title.BackgroundTransparency = 1
		Title.Font = Enum.Font.SourceSansBold
		Title.TextSize = 10
		Title.TextXAlignment = Enum.TextXAlignment.Left

		local ItemsContainer = Instance.new("ScrollingFrame", StorageCard)
		ItemsContainer.Size = UDim2.new(0.96, 0, 0, 55)
		ItemsContainer.Position = UDim2.new(0.02, 0, 0.18, 0)
		ItemsContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
		ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
		ItemsContainer.ScrollBarThickness = 3

		local ItemsListUI = Instance.new("UIListLayout", ItemsContainer)
		ItemsListUI.Padding = UDim.new(0, 3)

		for _, item in pairs(storageItems) do
			if filterText == "" or string.find(string.lower(item.Name), filterText) then
				local frame = Instance.new("Frame", ItemsContainer)
				frame.Size = UDim2.new(1, -4, 0, 24)
				frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
				Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

				local label = Instance.new("TextLabel", frame)
				label.Size = UDim2.new(0.5, 0, 1, 0)
				label.Position = UDim2.new(0.02, 0, 0, 0)
				label.Text = string.format("📦 %s (%s)", item.Name, item.ClassName)
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.SourceSans
				label.TextSize = 8
				label.TextXAlignment = Enum.TextXAlignment.Left

				local GiveBtn = Instance.new("TextButton", frame)
				GiveBtn.Size = UDim2.new(0.25, 0, 0.8, 0)
				GiveBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
				GiveBtn.Text = "🎁 Give to Me"
				GiveBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
				GiveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				GiveBtn.Font = Enum.Font.SourceSansBold
				GiveBtn.TextSize = 7
				Instance.new("UICorner", GiveBtn).CornerRadius = UDim.new(0, 3)

				GiveBtn.MouseButton1Click:Connect(function()
					safeCall(function()
						local clone = item:Clone()
						local bp = LocalPlayer:FindFirstChild("Backpack")
						if bp then
							clone.Parent = bp
						end
					end)
				end)

				local CopyBtn = Instance.new("TextButton", frame)
				CopyBtn.Size = UDim2.new(0.2, 0, 0.8, 0)
				CopyBtn.Position = UDim2.new(0.78, 0, 0.1, 0)
				CopyBtn.Text = "📋 Copy Name"
				CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
				CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				CopyBtn.Font = Enum.Font.SourceSansBold
				CopyBtn.TextSize = 6
				Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 3)

				CopyBtn.MouseButton1Click:Connect(function()
					copyToClipboard(item.Name)
				end)
			end
		end

		ItemsContainer.CanvasSize = UDim2.new(0, 0, 0, ItemsListUI.AbsoluteContentSize.Y)
	end

	BpScroll.CanvasSize = UDim2.new(0, 0, 0, BpListUI.AbsoluteContentSize.Y)
end

RefreshBpBtn.MouseButton1Click:Connect(updateBackpackList)

--=========================================================  
-- TAB 5: STATS INSPECTOR + TÌM SCRIPT TĂNG CHỈ SỐ (VERSION 12)  
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
		CopyValBtn.MouseButton1Click:Connect(function() copyToClipboard(valStr) end)  
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
					copy.MouseButton1Click:Connect(function() copyToClipboard(getScriptCode(scr)) end)  
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
-- TAB 6: REMOTE SPY (NÂNG CẤP + COPY ALL LOGS)  
--=========================================================  
local SpyFilterBox = Instance.new("TextBox", Page6)
SpyFilterBox.Size = UDim2.new(0.2, 0, 0, 24)
SpyFilterBox.PlaceholderText = "🔍 Lọc Remote..."
SpyFilterBox.Text = ""
SpyFilterBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
SpyFilterBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpyFilterBox.Font = Enum.Font.SourceSans
SpyFilterBox.TextSize = 9
Instance.new("UICorner", SpyFilterBox).CornerRadius = UDim.new(0, 4)

local RemoteSpyToggle = Instance.new("TextButton", Page6)
RemoteSpyToggle.Size = UDim2.new(0.1, 0, 0, 24)
RemoteSpyToggle.Position = UDim2.new(0.22, 0, 0, 0)
RemoteSpyToggle.Text = "📡 Spy: OFF"
RemoteSpyToggle.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
RemoteSpyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RemoteSpyToggle.Font = Enum.Font.SourceSansBold
RemoteSpyToggle.TextSize = 9
Instance.new("UICorner", RemoteSpyToggle).CornerRadius = UDim.new(0, 4)

local ScanRemotesBtn = Instance.new("TextButton", Page6)
ScanRemotesBtn.Size = UDim2.new(0.1, 0, 0, 24)
ScanRemotesBtn.Position = UDim2.new(0.33, 0, 0, 0)
ScanRemotesBtn.Text = "🔍 Quét"
ScanRemotesBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
ScanRemotesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanRemotesBtn.Font = Enum.Font.SourceSansBold
ScanRemotesBtn.TextSize = 8
Instance.new("UICorner", ScanRemotesBtn).CornerRadius = UDim.new(0, 4)

local CopyAllSpyBtn = Instance.new("TextButton", Page6)
CopyAllSpyBtn.Size = UDim2.new(0.1, 0, 0, 24)
CopyAllSpyBtn.Position = UDim2.new(0.44, 0, 0, 0)
CopyAllSpyBtn.Text = "📋 Copy All"
CopyAllSpyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
CopyAllSpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyAllSpyBtn.Font = Enum.Font.SourceSansBold
CopyAllSpyBtn.TextSize = 7
Instance.new("UICorner", CopyAllSpyBtn).CornerRadius = UDim.new(0, 4)

local ClearSpyBtn = Instance.new("TextButton", Page6)
ClearSpyBtn.Size = UDim2.new(0.1, 0, 0, 24)
ClearSpyBtn.Position = UDim2.new(0.55, 0, 0, 0)
ClearSpyBtn.Text = "🗑️ Clear"
ClearSpyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearSpyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearSpyBtn.Font = Enum.Font.SourceSansBold
ClearSpyBtn.TextSize = 9
Instance.new("UICorner", ClearSpyBtn).CornerRadius = UDim.new(0, 4)

local SpyTypeFilter = Instance.new("TextBox", Page6)
SpyTypeFilter.Size = UDim2.new(0.15, 0, 0, 24)
SpyTypeFilter.Position = UDim2.new(0.67, 0, 0, 0)
SpyTypeFilter.PlaceholderText = "Loại (Fire/Invoke)"
SpyTypeFilter.Text = ""
SpyTypeFilter.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
SpyTypeFilter.TextColor3 = Color3.fromRGB(255, 255, 255)
SpyTypeFilter.Font = Enum.Font.SourceSans
SpyTypeFilter.TextSize = 8
Instance.new("UICorner", SpyTypeFilter).CornerRadius = UDim.new(0, 4)

local SpyScroll = Instance.new("ScrollingFrame", Page6)
SpyScroll.Size = UDim2.new(1, 0, 1, -30)
SpyScroll.Position = UDim2.new(0, 0, 0, 30)
SpyScroll.BackgroundTransparency = 1
SpyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SpyScroll.ScrollBarThickness = 3

local SpyListUI = Instance.new("UIListLayout", SpyScroll)
SpyListUI.Padding = UDim.new(0, 4)

local spyActive = false
local blacklistedRemoteNames = {}
local loggedUIFrames = {}
local remoteCallCounts = {}
local remoteLastArgs = {}

local function logRemoteEvent(remote, args, method)
	if not spyActive then return end
	local rName = remote.Name
	if blacklistedRemoteNames[rName] then return end

	local filterText = string.lower(SpyFilterBox.Text)
	if filterText ~= "" and not string.find(string.lower(rName), filterText) then return end

	local typeFilter = string.lower(SpyTypeFilter.Text)
	if typeFilter ~= "" and not string.find(string.lower(method or ""), typeFilter) then return end

	remoteCallCounts[remote] = (remoteCallCounts[remote] or 0) + 1
	remoteLastArgs[remote] = args

	if loggedUIFrames[remote] and loggedUIFrames[remote].Parent then
		local frame = loggedUIFrames[remote]
		local infoLabel = frame:FindFirstChild("InfoText")
		if infoLabel then
			infoLabel.Text = string.format("⚡ [%s] %s | %s (x%d)", 
				remote.ClassName, rName, method or "?", remoteCallCounts[remote])
		end
		return
	end

	local ItemFrame = Instance.new("Frame", SpyScroll)
	ItemFrame.Size = UDim2.new(1, -5, 0, 28)
	ItemFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	Instance.new("UICorner", ItemFrame).CornerRadius = UDim.new(0, 4)

	local InfoText = Instance.new("TextLabel", ItemFrame)
	InfoText.Name = "InfoText"
	InfoText.Size = UDim2.new(0.4, 0, 1, 0)
	InfoText.Position = UDim2.new(0.02, 0, 0, 0)
	local argsStr = ""
	if args and #args > 0 then
		argsStr = string.sub(tostring(args), 1, 30)
	end
	InfoText.Text = string.format("⚡ [%s] %s | %s (x%d)", 
		remote.ClassName, rName, method or "?", remoteCallCounts[remote])
	InfoText.TextColor3 = Color3.fromRGB(255, 180, 50)
	InfoText.BackgroundTransparency = 1
	InfoText.Font = Enum.Font.SourceSansBold
	InfoText.TextSize = 8
	InfoText.TextXAlignment = Enum.TextXAlignment.Left

	local FireTestBtn = Instance.new("TextButton", ItemFrame)
	FireTestBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
	FireTestBtn.Position = UDim2.new(0.42, 0, 0.15, 0)
	FireTestBtn.Text = "🔥 Fire"
	FireTestBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
	FireTestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	FireTestBtn.Font = Enum.Font.SourceSansBold
	FireTestBtn.TextSize = 8
	Instance.new("UICorner", FireTestBtn).CornerRadius = UDim.new(0, 3)

	FireTestBtn.MouseButton1Click:Connect(function()
		safeCall(function()
			local lastArgs = remoteLastArgs[remote] or {}
			if remote:IsA("RemoteEvent") then
				remote:FireServer(unpack(lastArgs))
			elseif remote:IsA("RemoteFunction") then
				remote:InvokeServer(unpack(lastArgs))
			end
		end)
	end)

	local CopyCallBtn = Instance.new("TextButton", ItemFrame)
	CopyCallBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
	CopyCallBtn.Position = UDim2.new(0.56, 0, 0.15, 0)
	CopyCallBtn.Text = "📋 Copy"
	CopyCallBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
	CopyCallBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	CopyCallBtn.Font = Enum.Font.SourceSansBold
	CopyCallBtn.TextSize = 7
	Instance.new("UICorner", CopyCallBtn).CornerRadius = UDim.new(0, 3)

	CopyCallBtn.MouseButton1Click:Connect(function()
		local lastArgs = remoteLastArgs[remote] or {}
		local argsStr = ""
		for i, v in ipairs(lastArgs) do
			argsStr = argsStr .. tostring(v) .. (i < #lastArgs and ", " or "")
		end
		copyToClipboard(string.format("%s:%s(%s)", 
			remote:GetFullName(), 
			remote:IsA("RemoteEvent") and "FireServer" or "InvokeServer",
			argsStr))
	end)

	local PurgeBtn = Instance.new("TextButton", ItemFrame)
	PurgeBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
	PurgeBtn.Position = UDim2.new(0.73, 0, 0.15, 0)
	PurgeBtn.Text = "🚫 Purge"
	PurgeBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
	PurgeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	PurgeBtn.Font = Enum.Font.SourceSansBold
	PurgeBtn.TextSize = 7
	Instance.new("UICorner", PurgeBtn).CornerRadius = UDim.new(0, 3)

	PurgeBtn.MouseButton1Click:Connect(function()
		blacklistedRemoteNames[rName] = true
		ItemFrame:Destroy()
	end)

	-- Hiện args chi tiết
	local ArgsBtn = Instance.new("TextButton", ItemFrame)
	ArgsBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
	ArgsBtn.Position = UDim2.new(0.87, 0, 0.15, 0)
	ArgsBtn.Text = "📋 Args"
	ArgsBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	ArgsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ArgsBtn.Font = Enum.Font.SourceSansBold
	ArgsBtn.TextSize = 7
	Instance.new("UICorner", ArgsBtn).CornerRadius = UDim.new(0, 3)

	ArgsBtn.MouseButton1Click:Connect(function()
		local lastArgs = remoteLastArgs[remote] or {}
		local argsStr = ""
		for i, v in ipairs(lastArgs) do
			argsStr = argsStr .. string.format("[%d] %s\n", i, tostring(v))
		end
		if argsStr == "" then argsStr = "[No arguments]" end
		copyToClipboard(argsStr)
		-- Hiển thị popup
		local popup = Instance.new("Frame", ScreenGui)
		popup.Size = UDim2.new(0, 400, 0, 250)
		popup.Position = UDim2.new(0.5, -200, 0.5, -125)
		popup.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)

		local close = Instance.new("TextButton", popup)
		close.Size = UDim2.new(0, 30, 0, 30)
		close.Position = UDim2.new(1, -35, 0, 5)
		close.Text = "✕"
		close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		close.TextColor3 = Color3.fromRGB(255, 255, 255)
		close.Font = Enum.Font.SourceSansBold
		close.TextSize = 12
		close.MouseButton1Click:Connect(function() popup:Destroy() end)

		local title = Instance.new("TextLabel", popup)
		title.Size = UDim2.new(0.8, 0, 0, 30)
		title.Position = UDim2.new(0.05, 0, 0, 0)
		title.Text = "Arguments: "..rName
		title.TextColor3 = Color3.fromRGB(0, 255, 200)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.SourceSansBold
		title.TextSize = 12

		local scroll = Instance.new("ScrollingFrame", popup)
		scroll.Size = UDim2.new(0.95, 0, 0.85, 0)
		scroll.Position = UDim2.new(0.025, 0, 0.1, 0)
		scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.ScrollBarThickness = 3

		local listUI = Instance.new("UIListLayout", scroll)
		listUI.Padding = UDim.new(0, 3)

		if #lastArgs == 0 then
			local empty = Instance.new("TextLabel", scroll)
			empty.Size = UDim2.new(1, 0, 0, 30)
			empty.Text = "Không có argument"
			empty.BackgroundTransparency = 1
			empty.TextColor3 = Color3.fromRGB(200, 200, 200)
			empty.Font = Enum.Font.SourceSans
			empty.TextSize = 12
		else
			for i, v in ipairs(lastArgs) do
				local frame = Instance.new("Frame", scroll)
				frame.Size = UDim2.new(1, -5, 0, 22)
				frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
				Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 3)

				local label = Instance.new("TextLabel", frame)
				label.Size = UDim2.new(1, 0, 1, 0)
				label.Position = UDim2.new(0.02, 0, 0, 0)
				label.Text = string.format("[%d] %s", i, tostring(v))
				label.TextColor3 = Color3.fromRGB(200, 200, 200)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.SourceSans
				label.TextSize = 9
				label.TextXAlignment = Enum.TextXAlignment.Left
			end
		end
		scroll.CanvasSize = UDim2.new(0, 0, 0, listUI.AbsoluteContentSize.Y)
	end)

	loggedUIFrames[remote] = ItemFrame
	SpyScroll.CanvasSize = UDim2.new(0, 0, 0, SpyListUI.AbsoluteContentSize.Y)
end

RemoteSpyToggle.MouseButton1Click:Connect(function()
	spyActive = not spyActive
	RemoteSpyToggle.Text = spyActive and "📡 Spy: ON" or "📡 Spy: OFF"
	RemoteSpyToggle.BackgroundColor3 = spyActive and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(140, 35, 35)
end)

CopyAllSpyBtn.MouseButton1Click:Connect(function()
	local text = ""
	for remote, frame in pairs(loggedUIFrames) do
		local info = frame:FindFirstChild("InfoText")
		if info then
			text = text .. info.Text .. "\n"
		end
	end
	copyToClipboard(text)
end)

ClearSpyBtn.MouseButton1Click:Connect(function()
	for _, child in pairs(SpyScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	loggedUIFrames = {}
	remoteCallCounts = {}
	remoteLastArgs = {}
	SpyScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

ScanRemotesBtn.MouseButton1Click:Connect(function()
	local remotes = {}
	local scanTargets = {Workspace, Players, game}
	for _, target in pairs(scanTargets) do
		for _, obj in pairs(target:GetDescendants()) do
			if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
				table.insert(remotes, obj)
			end
		end
	end

	local popup = Instance.new("Frame", ScreenGui)
	popup.Size = UDim2.new(0, 500, 0, 400)
	popup.Position = UDim2.new(0.5, -250, 0.5, -200)
	popup.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)

	local close = Instance.new("TextButton", popup)
	close.Size = UDim2.new(0, 30, 0, 30)
	close.Position = UDim2.new(1, -35, 0, 5)
	close.Text = "✕"
	close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Font = Enum.Font.SourceSansBold
	close.TextSize = 12
	close.MouseButton1Click:Connect(function() popup:Destroy() end)

	local title = Instance.new("TextLabel", popup)
	title.Size = UDim2.new(0.8, 0, 0, 30)
	title.Position = UDim2.new(0.05, 0, 0, 0)
	title.Text = "Danh sách Remote ("..#remotes..")"
	title.TextColor3 = Color3.fromRGB(0, 255, 200)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 12

	local scroll = Instance.new("ScrollingFrame", popup)
	scroll.Size = UDim2.new(0.95, 0, 0.85, 0)
	scroll.Position = UDim2.new(0.025, 0, 0.1, 0)
	scroll.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 3

	local listUI = Instance.new("UIListLayout", scroll)
	listUI.Padding = UDim.new(0, 4)

	for _, r in ipairs(remotes) do
		local frame = Instance.new("Frame", scroll)
		frame.Size = UDim2.new(1, -5, 0, 24)
		frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

		local label = Instance.new("TextLabel", frame)
		label.Size = UDim2.new(0.5, 0, 1, 0)
		label.Position = UDim2.new(0.02, 0, 0, 0)
		label.Text = string.format("📡 %s (%s)", r.Name, r.ClassName)
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.SourceSans
		label.TextSize = 9
		label.TextXAlignment = Enum.TextXAlignment.Left

		local fireBtn = Instance.new("TextButton", frame)
		fireBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
		fireBtn.Position = UDim2.new(0.52, 0, 0.15, 0)
		fireBtn.Text = "🔥 Fire"
		fireBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
		fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		fireBtn.Font = Enum.Font.SourceSansBold
		fireBtn.TextSize = 8
		Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 3)

		fireBtn.MouseButton1Click:Connect(function()
			safeCall(function()
				if r:IsA("RemoteEvent") then
					r:FireServer()
				elseif r:IsA("RemoteFunction") then
					r:InvokeServer()
				end
			end)
		end)

		local copyBtn = Instance.new("TextButton", frame)
		copyBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
		copyBtn.Position = UDim2.new(0.69, 0, 0.15, 0)
		copyBtn.Text = "📋 Copy Path"
		copyBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
		copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		copyBtn.Font = Enum.Font.SourceSansBold
		copyBtn.TextSize = 7
		Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 3)

		copyBtn.MouseButton1Click:Connect(function()
			copyToClipboard(r:GetFullName())
		end)
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, listUI.AbsoluteContentSize.Y)
end)

-- HOOK REMOTE
local rawMeta = getrawmetatable or debug.getmetatable
if rawMeta and setreadonly then
	local gmt = rawMeta(game)
	local oldNamecall = gmt.__namecall
	setreadonly(gmt, false)
	gmt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		if spyActive and (method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer") then
			if self and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
				logRemoteEvent(self, {...}, method)
			end
		end
		return oldNamecall(self, ...)
	end)
	setreadonly(gmt, true)
end

--=========================================================  
-- TAB 7: CONSOLE (GIỐNG F9)  
--=========================================================  
local ConsoleSearchBox = Instance.new("TextBox", Page7)
ConsoleSearchBox.Size = UDim2.new(0.25, 0, 0, 22)
ConsoleSearchBox.PlaceholderText = "🔍 Tìm trong log..."
ConsoleSearchBox.Text = ""
ConsoleSearchBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
ConsoleSearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ConsoleSearchBox.Font = Enum.Font.SourceSans
ConsoleSearchBox.TextSize = 9
Instance.new("UICorner", ConsoleSearchBox).CornerRadius = UDim.new(0, 3)

local FilterErrorBtn = Instance.new("TextButton", Page7)
FilterErrorBtn.Size = UDim2.new(0.08, 0, 0, 22)
FilterErrorBtn.Position = UDim2.new(0.27, 0, 0, 0)
FilterErrorBtn.Text = "❌"
FilterErrorBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FilterErrorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FilterErrorBtn.Font = Enum.Font.SourceSansBold
FilterErrorBtn.TextSize = 10
Instance.new("UICorner", FilterErrorBtn).CornerRadius = UDim.new(0, 3)

local FilterWarnBtn = Instance.new("TextButton", Page7)
FilterWarnBtn.Size = UDim2.new(0.08, 0, 0, 22)
FilterWarnBtn.Position = UDim2.new(0.36, 0, 0, 0)
FilterWarnBtn.Text = "⚠️"
FilterWarnBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FilterWarnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FilterWarnBtn.Font = Enum.Font.SourceSansBold
FilterWarnBtn.TextSize = 10
Instance.new("UICorner", FilterWarnBtn).CornerRadius = UDim.new(0, 3)

local FilterInfoBtn = Instance.new("TextButton", Page7)
FilterInfoBtn.Size = UDim2.new(0.08, 0, 0, 22)
FilterInfoBtn.Position = UDim2.new(0.45, 0, 0, 0)
FilterInfoBtn.Text = "ℹ️"
FilterInfoBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FilterInfoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FilterInfoBtn.Font = Enum.Font.SourceSansBold
FilterInfoBtn.TextSize = 10
Instance.new("UICorner", FilterInfoBtn).CornerRadius = UDim.new(0, 3)

local FilterDebugBtn = Instance.new("TextButton", Page7)
FilterDebugBtn.Size = UDim2.new(0.08, 0, 0, 22)
FilterDebugBtn.Position = UDim2.new(0.54, 0, 0, 0)
FilterDebugBtn.Text = "🐞"
FilterDebugBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FilterDebugBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FilterDebugBtn.Font = Enum.Font.SourceSansBold
FilterDebugBtn.TextSize = 10
Instance.new("UICorner", FilterDebugBtn).CornerRadius = UDim.new(0, 3)

local ClearConsoleBtn = Instance.new("TextButton", Page7)
ClearConsoleBtn.Size = UDim2.new(0.08, 0, 0, 22)
ClearConsoleBtn.Position = UDim2.new(0.63, 0, 0, 0)
ClearConsoleBtn.Text = "🗑️"
ClearConsoleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearConsoleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearConsoleBtn.Font = Enum.Font.SourceSansBold
ClearConsoleBtn.TextSize = 10
Instance.new("UICorner", ClearConsoleBtn).CornerRadius = UDim.new(0, 3)

local SaveConsoleBtn = Instance.new("TextButton", Page7)
SaveConsoleBtn.Size = UDim2.new(0.08, 0, 0, 22)
SaveConsoleBtn.Position = UDim2.new(0.72, 0, 0, 0)
SaveConsoleBtn.Text = "💾"
SaveConsoleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
SaveConsoleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveConsoleBtn.Font = Enum.Font.SourceSansBold
SaveConsoleBtn.TextSize = 10
Instance.new("UICorner", SaveConsoleBtn).CornerRadius = UDim.new(0, 3)

local AutoScrollBtn = Instance.new("TextButton", Page7)
AutoScrollBtn.Size = UDim2.new(0.08, 0, 0, 22)
AutoScrollBtn.Position = UDim2.new(0.81, 0, 0, 0)
AutoScrollBtn.Text = "🔽"
AutoScrollBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutoScrollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoScrollBtn.Font = Enum.Font.SourceSansBold
AutoScrollBtn.TextSize = 10
Instance.new("UICorner", AutoScrollBtn).CornerRadius = UDim.new(0, 3)

local ConsoleScroll = Instance.new("ScrollingFrame", Page7)
ConsoleScroll.Size = UDim2.new(1, 0, 1, -28)
ConsoleScroll.Position = UDim2.new(0, 0, 0, 28)
ConsoleScroll.BackgroundTransparency = 1
ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ConsoleScroll.ScrollBarThickness = 3

local ConsoleListUI = Instance.new("UIListLayout", ConsoleScroll)
ConsoleListUI.Padding = UDim.new(0, 2)

local filterTypes = {Error = false, Warning = false, Info = false, Debug = false}
local logHistory = {}
local autoScroll = true

local function setFilter(type, state)
	filterTypes[type] = state
	if type == "Error" then
		FilterErrorBtn.BackgroundColor3 = state and Color3.fromRGB(180, 40, 40) or Color3.fromRGB(50, 50, 50)
	elseif type == "Warning" then
		FilterWarnBtn.BackgroundColor3 = state and Color3.fromRGB(180, 120, 0) or Color3.fromRGB(50, 50, 50)
	elseif type == "Info" then
		FilterInfoBtn.BackgroundColor3 = state and Color3.fromRGB(0, 120, 180) or Color3.fromRGB(50, 50, 50)
	elseif type == "Debug" then
		FilterDebugBtn.BackgroundColor3 = state and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(50, 50, 50)
	end
	-- Refresh log
	renderLogs()
end

FilterErrorBtn.MouseButton1Click:Connect(function() setFilter("Error", not filterTypes.Error) end)
FilterWarnBtn.MouseButton1Click:Connect(function() setFilter("Warning", not filterTypes.Warning) end)
FilterInfoBtn.MouseButton1Click:Connect(function() setFilter("Info", not filterTypes.Info) end)
FilterDebugBtn.MouseButton1Click:Connect(function() setFilter("Debug", not filterTypes.Debug) end)

AutoScrollBtn.MouseButton1Click:Connect(function()
	autoScroll = not autoScroll
	AutoScrollBtn.BackgroundColor3 = autoScroll and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(50, 50, 50)
end)

local function renderLogs()
	for _, child in pairs(ConsoleScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local searchKeyword = string.lower(ConsoleSearchBox.Text)

	for _, entry in ipairs(logHistory) do
		local show = true
		if entry.type == Enum.MessageType.MessageError and not filterTypes.Error then show = false end
		if entry.type == Enum.MessageType.MessageWarning and not filterTypes.Warning then show = false end
		if entry.type == Enum.MessageType.MessageOutput and not filterTypes.Info then show = false end
		if entry.type == Enum.MessageType.MessageInfo and not filterTypes.Debug then show = false end

		if show and (searchKeyword == "" or string.find(string.lower(entry.msg), searchKeyword)) then
			local Frame = Instance.new("Frame", ConsoleScroll)
			Frame.Size = UDim2.new(1, -5, 0, 18)
			Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)

			local LogText = Instance.new("TextLabel", Frame)
			LogText.Size = UDim2.new(0.98, 0, 1, 0)
			LogText.Position = UDim2.new(0.01, 0, 0, 0)
			LogText.Text = string.format("[%s] %s", entry.time or os.date("%H:%M:%S"), entry.msg)
			LogText.BackgroundTransparency = 1
			LogText.Font = Enum.Font.SourceSans
			LogText.TextSize = 8
			LogText.TextXAlignment = Enum.TextXAlignment.Left

			if entry.type == Enum.MessageType.MessageOutput then
				LogText.TextColor3 = Color3.fromRGB(220, 220, 220)
			elseif entry.type == Enum.MessageType.MessageWarning then
				LogText.TextColor3 = Color3.fromRGB(255, 200, 50)
			elseif entry.type == Enum.MessageType.MessageError then
				LogText.TextColor3 = Color3.fromRGB(255, 70, 70)
			else
				LogText.TextColor3 = Color3.fromRGB(100, 200, 255)
			end
		end
	end

	ConsoleScroll.CanvasSize = UDim2.new(0, 0, 0, ConsoleListUI.AbsoluteContentSize.Y)
	if autoScroll then
		ConsoleScroll.CanvasPosition = Vector2.new(0, ConsoleScroll.CanvasSize.Y.Offset)
	end
end

local function appendLog(message, messageType)
	table.insert(logHistory, {msg = message, type = messageType, time = os.date("%H:%M:%S")})
	-- Giới hạn log
	if #logHistory > 500 then
		table.remove(logHistory, 1)
	end
	renderLogs()
end

LogService.MessageOut:Connect(appendLog)

ClearConsoleBtn.MouseButton1Click:Connect(function()
	logHistory = {}
	renderLogs()
end)

SaveConsoleBtn.MouseButton1Click:Connect(function()
	local fullLog = ""
	for _, entry in ipairs(logHistory) do
		fullLog = fullLog .. string.format("[%s] %s\n", entry.time or "?", entry.msg)
	end
	copyToClipboard(fullLog)
end)

ConsoleSearchBox.Changed:Connect(function()
	renderLogs()
end)

--=========================================================  
-- TAB 8: GUI MASTER (ẨN GUI NGƯỜI KHÁC + XÓA GUI)  
--=========================================================  
local GuiTargetBox = Instance.new("TextBox", Page8)
GuiTargetBox.Size = UDim2.new(0, 220, 0, 24)
GuiTargetBox.PlaceholderText = "🔍 Tên Player (Trống = Bản thân)..."
GuiTargetBox.Text = ""
GuiTargetBox.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
GuiTargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
GuiTargetBox.Font = Enum.Font.SourceSans
GuiTargetBox.TextSize = 9
Instance.new("UICorner", GuiTargetBox).CornerRadius = UDim.new(0, 4)

local ScanGuiBtn = Instance.new("TextButton", Page8)
ScanGuiBtn.Size = UDim2.new(0, 90, 0, 24)
ScanGuiBtn.Position = UDim2.new(0, 230, 0, 0)
ScanGuiBtn.Text = "🔍 Quét"
ScanGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
ScanGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScanGuiBtn.Font = Enum.Font.SourceSansBold
ScanGuiBtn.TextSize = 9
Instance.new("UICorner", ScanGuiBtn).CornerRadius = UDim.new(0, 4)

local ToggleAllGuiBtn = Instance.new("TextButton", Page8)
ToggleAllGuiBtn.Size = UDim2.new(0, 90, 0, 24)
ToggleAllGuiBtn.Position = UDim2.new(0, 330, 0, 0)
ToggleAllGuiBtn.Text = "👁️ Toggle All"
ToggleAllGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 180)
ToggleAllGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleAllGuiBtn.Font = Enum.Font.SourceSansBold
ToggleAllGuiBtn.TextSize = 8
Instance.new("UICorner", ToggleAllGuiBtn).CornerRadius = UDim.new(0, 4)

local HideOtherGuiBtn = Instance.new("TextButton", Page8)
HideOtherGuiBtn.Size = UDim2.new(0, 90, 0, 24)
HideOtherGuiBtn.Position = UDim2.new(0, 430, 0, 0)
HideOtherGuiBtn.Text = "🙈 Ẩn GUI Khác"
HideOtherGuiBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
HideOtherGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HideOtherGuiBtn.Font = Enum.Font.SourceSansBold
HideOtherGuiBtn.TextSize = 8
Instance.new("UICorner", HideOtherGuiBtn).CornerRadius = UDim.new(0, 4)

local DeleteGuiBtn = Instance.new("TextButton", Page8)
DeleteGuiBtn.Size = UDim2.new(0, 80, 0, 24)
DeleteGuiBtn.Position = UDim2.new(0, 530, 0, 0)
DeleteGuiBtn.Text = "❌ Xóa GUI"
DeleteGuiBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
DeleteGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DeleteGuiBtn.Font = Enum.Font.SourceSansBold
DeleteGuiBtn.TextSize = 8
Instance.new("UICorner", DeleteGuiBtn).CornerRadius = UDim.new(0, 4)

local GuiScroll = Instance.new("ScrollingFrame", Page8)
GuiScroll.Size = UDim2.new(1, 0, 1, -30)
GuiScroll.Position = UDim2.new(0, 0, 0, 30)
GuiScroll.BackgroundTransparency = 1
GuiScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
GuiScroll.ScrollBarThickness = 3

local GuiListUI = Instance.new("UIListLayout", GuiScroll)
GuiListUI.Padding = UDim.new(0, 4)

local currentScannedGuiPlayer = LocalPlayer

local function scanGuiOfPlayer(targetPlayer)
	currentScannedGuiPlayer = targetPlayer
	for _, child in pairs(GuiScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local pGui = targetPlayer:FindFirstChild("PlayerGui")
	if not pGui then
		local noGui = Instance.new("TextLabel", GuiScroll)
		noGui.Size = UDim2.new(1, 0, 0, 30)
		noGui.Text = "Không tìm thấy PlayerGui của người chơi này"
		noGui.TextColor3 = Color3.fromRGB(200, 200, 200)
		noGui.BackgroundTransparency = 1
		noGui.Font = Enum.Font.SourceSans
		noGui.TextSize = 12
		GuiScroll.CanvasSize = UDim2.new(0, 0, 0, GuiListUI.AbsoluteContentSize.Y)
		return
	end

	for _, screenGui in pairs(pGui:GetChildren()) do
		if screenGui:IsA("ScreenGui") then
			local innerScripts = {}
			for _, d in pairs(screenGui:GetDescendants()) do
				if d:IsA("LocalScript") or d:IsA("ModuleScript") or d:IsA("Script") then
					table.insert(innerScripts, d)
				end
			end

			local Frame = Instance.new("Frame", GuiScroll)
			Frame.Size = UDim2.new(1, -5, 0, math.max(60, 40 + (#innerScripts * 20)))
			Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

			local InfoText = Instance.new("TextLabel", Frame)
			InfoText.Size = UDim2.new(0.5, 0, 0, 18)
			InfoText.Position = UDim2.new(0.02, 0, 0, 4)
			InfoText.Text = string.format("🖥️ %s (Enabled: %s)", screenGui.Name, tostring(screenGui.Enabled))
			InfoText.TextColor3 = Color3.fromRGB(255, 210, 80)
			InfoText.BackgroundTransparency = 1
			InfoText.Font = Enum.Font.SourceSansBold
			InfoText.TextSize = 10
			InfoText.TextXAlignment = Enum.TextXAlignment.Left

			local ToggleVisBtn = Instance.new("TextButton", Frame)
			ToggleVisBtn.Size = UDim2.new(0.2, 0, 0, 20)
			ToggleVisBtn.Position = UDim2.new(0.55, 0, 0, 4)
			ToggleVisBtn.Text = screenGui.Enabled and "👁️ Bật" or "🙈 Ẩn"
			ToggleVisBtn.BackgroundColor3 = screenGui.Enabled and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(180, 40, 40)
			ToggleVisBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			ToggleVisBtn.Font = Enum.Font.SourceSansBold
			ToggleVisBtn.TextSize = 8
			Instance.new("UICorner", ToggleVisBtn).CornerRadius = UDim.new(0, 3)

			ToggleVisBtn.MouseButton1Click:Connect(function()
				screenGui.Enabled = not screenGui.Enabled
				ToggleVisBtn.Text = screenGui.Enabled and "👁️ Bật" or "🙈 Ẩn"
				ToggleVisBtn.BackgroundColor3 = screenGui.Enabled and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(180, 40, 40)
				InfoText.Text = string.format("🖥️ %s (Enabled: %s)", screenGui.Name, tostring(screenGui.Enabled))
			end)

			local ScriptContainer = Instance.new("Frame", Frame)
			ScriptContainer.Size = UDim2.new(0.96, 0, 1, -28)
			ScriptContainer.Position = UDim2.new(0.02, 0, 0, 24)
			ScriptContainer.BackgroundTransparency = 1

			local ScriptList = Instance.new("UIListLayout", ScriptContainer)
			ScriptList.Padding = UDim.new(0, 2)

			for _, scr in ipairs(innerScripts) do
				local ScrSubFrame = Instance.new("Frame", ScriptContainer)
				ScrSubFrame.Size = UDim2.new(1, 0, 0, 18)
				ScrSubFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
				Instance.new("UICorner", ScrSubFrame).CornerRadius = UDim.new(0, 3)

				local ScrLabel = Instance.new("TextLabel", ScrSubFrame)
				ScrLabel.Size = UDim2.new(0.6, 0, 1, 0)
				ScrLabel.Position = UDim2.new(0.02, 0, 0, 0)
				ScrLabel.Text = string.format("📜 %s (%s)", scr.Name, scr.ClassName)
				ScrLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
				ScrLabel.BackgroundTransparency = 1
				ScrLabel.Font = Enum.Font.SourceSans
				ScrLabel.TextSize = 8
				ScrLabel.TextXAlignment = Enum.TextXAlignment.Left

				local CopyCodeGuiBtn = Instance.new("TextButton", ScrSubFrame)
				CopyCodeGuiBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
				CopyCodeGuiBtn.Position = UDim2.new(0.62, 0, 0.1, 0)
				CopyCodeGuiBtn.Text = "📋 Copy"
				CopyCodeGuiBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
				CopyCodeGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				CopyCodeGuiBtn.Font = Enum.Font.SourceSansBold
				CopyCodeGuiBtn.TextSize = 7
				Instance.new("UICorner", CopyCodeGuiBtn).CornerRadius = UDim.new(0, 3)

				CopyCodeGuiBtn.MouseButton1Click:Connect(function()
					copyToClipboard(getScriptCode(scr))
				end)
			end
		end
	end

	GuiScroll.CanvasSize = UDim2.new(0, 0, 0, GuiListUI.AbsoluteContentSize.Y)
end

ScanGuiBtn.MouseButton1Click:Connect(function()
	local targetName = string.lower(GuiTargetBox.Text)
	local targetPlr = LocalPlayer
	if targetName ~= "" then
		for _, p in pairs(Players:GetPlayers()) do
			if string.find(string.lower(p.Name), targetName) or string.find(string.lower(p.DisplayName), targetName) then
				targetPlr = p
				break
			end
		end
	end
	scanGuiOfPlayer(targetPlr)
end)

ToggleAllGuiBtn.MouseButton1Click:Connect(function()
	safeCall(function()
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

HideOtherGuiBtn.MouseButton1Click:Connect(function()
	safeCall(function()
		-- Ẩn GUI của tất cả người chơi khác
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer then
				local pGui = plr:FindFirstChild("PlayerGui")
				if pGui then
					for _, sg in pairs(pGui:GetChildren()) do
						if sg:IsA("ScreenGui") then
							sg.Enabled = false
						end
					end
				end
			end
		end
	end)
	scanGuiOfPlayer(currentScannedGuiPlayer)
end)

DeleteGuiBtn.MouseButton1Click:Connect(function()
	local pGui = currentScannedGuiPlayer:FindFirstChild("PlayerGui")
	if pGui then
		for _, sg in pairs(pGui:GetChildren()) do
			if sg:IsA("ScreenGui") and sg ~= ScreenGui then
				sg:Destroy()
			end
		end
		scanGuiOfPlayer(currentScannedGuiPlayer)
	end
end)

--=========================================================  
-- TAB 9: HITBOX MASTER (5 NÚT PHÂN LOẠI)  
--=========================================================  
local HitboxScroll = Instance.new("ScrollingFrame", Page9)
HitboxScroll.Size = UDim2.new(1, 0, 1, 0)
HitboxScroll.BackgroundTransparency = 1
HitboxScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
HitboxScroll.ScrollBarThickness = 3

local HitboxListUI = Instance.new("UIListLayout", HitboxScroll)
HitboxListUI.Padding = UDim.new(0, 6)

-- Danh sách các loại
local hitboxTypes = {
	{name = "👾 NPC", key = "NPC", color = Color3.fromRGB(255, 50, 50), hasExpand = true},
	{name = "👤 Player", key = "Players", color = Color3.fromRGB(50, 150, 255), hasExpand = true},
	{name = "🧱 Blocks", key = "Blocks", color = Color3.fromRGB(0, 255, 120), hasExpand = false},
	{name = "👻 Invisible", key = "InvisBlocks", color = Color3.fromRGB(255, 255, 0), hasExpand = false},
	{name = "⚡ Trigger", key = "TouchTriggers", color = Color3.fromRGB(200, 0, 255), hasExpand = false}
}

local hitboxConfigs = {}
local activeAdornments = {}

for _, ht in ipairs(hitboxTypes) do
	hitboxConfigs[ht.key] = {
		Box = false,
		XRay = false,
		Size = 10,
		Expand = false,
		Color = ht.color
	}
end

local function clearAdornments()
	for _, v in pairs(activeAdornments) do
		safeCall(function() v:Destroy() end)
	end
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
		safeCall(function()
			if obj:IsA("BasePart") and not obj:IsA("Terrain") then
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

-- Tạo danh sách các khối theo loại
local function showBlocksByType(typeKey)
	-- Xóa danh sách hiện tại
	for _, child in pairs(HitboxScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	local myChar = LocalPlayer.Character
	local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
	local count = 0

	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj:IsA("Terrain") then
			local isMatch = false
			local parentModel = obj:FindFirstAncestorOfClass("Model")

			if typeKey == "NPC" then
				if parentModel and parentModel:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(parentModel) then
					isMatch = true
				end
			elseif typeKey == "Players" then
				if parentModel and Players:GetPlayerFromCharacter(parentModel) and parentModel ~= LocalPlayer.Character then
					isMatch = true
				end
			elseif typeKey == "Blocks" then
				if not parentModel or not parentModel:FindFirstChildOfClass("Humanoid") then
					if obj.Transparency <= 0.8 and obj.CanCollide and not obj:FindFirstChildOfClass("TouchTransmitter") then
						isMatch = true
					end
				end
			elseif typeKey == "InvisBlocks" then
				if not parentModel or not parentModel:FindFirstChildOfClass("Humanoid") then
					if obj.Transparency > 0.8 or not obj.CanCollide then
						isMatch = true
					end
				end
			elseif typeKey == "TouchTriggers" then
				if obj:FindFirstChildOfClass("TouchTransmitter") then
					isMatch = true
				end
			end

			if isMatch then
				count = count + 1
				local dist = myHrp and math.floor((obj.Position - myHrp.Position).Magnitude) or 0

				local Card = Instance.new("Frame", HitboxScroll)
				Card.Size = UDim2.new(1, -5, 0, 26)
				Card.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
				Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 4)

				local info = Instance.new("TextLabel", Card)
				info.Size = UDim2.new(0.4, 0, 1, 0)
				info.Position = UDim2.new(0.02, 0, 0, 0)
				info.Text = string.format("📦 %s | %dm", obj.Name, dist)
				info.TextColor3 = Color3.fromRGB(200, 200, 200)
				info.BackgroundTransparency = 1
				info.Font = Enum.Font.SourceSans
				info.TextSize = 9
				info.TextXAlignment = Enum.TextXAlignment.Left

				local TpBtn = Instance.new("TextButton", Card)
				TpBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
				TpBtn.Position = UDim2.new(0.42, 0, 0.15, 0)
				TpBtn.Text = "TP"
				TpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 70)
				TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				TpBtn.Font = Enum.Font.SourceSansBold
				TpBtn.TextSize = 8
				Instance.new("UICorner", TpBtn).CornerRadius = UDim.new(0, 3)

				TpBtn.MouseButton1Click:Connect(function()
					if myHrp then
						myHrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
					end
				end)

				local CopyBtn = Instance.new("TextButton", Card)
				CopyBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
				CopyBtn.Position = UDim2.new(0.54, 0, 0.15, 0)
				CopyBtn.Text = "📋"
				CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 110, 170)
				CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				CopyBtn.Font = Enum.Font.SourceSansBold
				CopyBtn.TextSize = 8
				Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 3)

				CopyBtn.MouseButton1Click:Connect(function()
					copyToClipboard(string.format("%.1f, %.1f, %.1f", obj.Position.X, obj.Position.Y, obj.Position.Z))
				end)

				local SizeBox = Instance.new("TextBox", Card)
				SizeBox.Size = UDim2.new(0.1, 0, 0.7, 0)
				SizeBox.Position = UDim2.new(0.66, 0, 0.15, 0)
				SizeBox.PlaceholderText = "Size"
				SizeBox.Text = ""
				SizeBox.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
				SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
				SizeBox.Font = Enum.Font.SourceSans
				SizeBox.TextSize = 7
				Instance.new("UICorner", SizeBox).CornerRadius = UDim.new(0, 3)

				local SetSizeBtn = Instance.new("TextButton", Card)
				SetSizeBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
				SetSizeBtn.Position = UDim2.new(0.77, 0, 0.15, 0)
				SetSizeBtn.Text = "Set"
				SetSizeBtn.BackgroundColor3 = Color3.fromRGB(140, 90, 0)
				SetSizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				SetSizeBtn.Font = Enum.Font.SourceSansBold
				SetSizeBtn.TextSize = 7
				Instance.new("UICorner", SetSizeBtn).CornerRadius = UDim.new(0, 3)

				SetSizeBtn.MouseButton1Click:Connect(function()
					local newSize = tonumber(SizeBox.Text)
					if newSize and newSize > 0 then
						obj.Size = Vector3.new(newSize, newSize, newSize)
					end
				end)

				local DelBtn = Instance.new("TextButton", Card)
				DelBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
				DelBtn.Position = UDim2.new(0.87, 0, 0.15, 0)
				DelBtn.Text = "✕"
				DelBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
				DelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
				DelBtn.Font = Enum.Font.SourceSansBold
				DelBtn.TextSize = 8
				Instance.new("UICorner", DelBtn).CornerRadius = UDim.new(0, 3)

				DelBtn.MouseButton1Click:Connect(function()
					obj:Destroy()
					Card:Destroy()
				end)
			end
		end
	end

	HitboxScroll.CanvasSize = UDim2.new(0, 0, 0, HitboxListUI.AbsoluteContentSize.Y)
end

-- Tạo 5 nút phân loại ở đầu Tab 9
local CategoryBar = Instance.new("Frame", Page9)
CategoryBar.Size = UDim2.new(1, -10, 0, 28)
CategoryBar.Position = UDim2.new(0, 5, 0, 0)
CategoryBar.BackgroundTransparency = 1

local CategoryUI = Instance.new("UIListLayout", CategoryBar)
CategoryUI.FillDirection = Enum.FillDirection.Horizontal
CategoryUI.Padding = UDim.new(0, 4)

for _, ht in ipairs(hitboxTypes) do
	local btn = Instance.new("TextButton", CategoryBar)
	btn.Size = UDim2.new(0.19, 0, 1, 0)
	btn.Text = ht.name
	btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	btn.TextColor3 = Color3.fromRGB(150, 150, 160)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 8
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	btn.MouseButton1Click:Connect(function()
		-- Reset màu các nút
		for _, b in pairs(CategoryBar:GetChildren()) do
			if b:IsA("TextButton") then
				b.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
				b.TextColor3 = Color3.fromRGB(150, 150, 160)
			end
		end
		btn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		showBlocksByType(ht.key)
	end)
end

-- Đặt ScrollFrame bên dưới
HitboxScroll.Size = UDim2.new(1, 0, 1, -34)
HitboxScroll.Position = UDim2.new(0, 0, 0, 34)

--=========================================================  
-- TAB 10: GAME STATS (GIÁM SÁT TOÀN CỤC)  
--=========================================================  
local StatsContainer = Instance.new("Frame", Page10)
StatsContainer.Size = UDim2.new(1, -10, 0, 220)
StatsContainer.Position = UDim2.new(0, 5, 0, 5)
StatsContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Instance.new("UICorner", StatsContainer).CornerRadius = UDim.new(0, 6)

local StatsListUI = Instance.new("UIListLayout", StatsContainer)
StatsListUI.Padding = UDim.new(0, 4)
StatsListUI.SortOrder = Enum.SortOrder.LayoutOrder

-- Hàm tạo một dòng thông tin
local function createStatLine(parent, label, initialValue, order)
	local line = Instance.new("Frame", parent)
	line.Size = UDim2.new(1, -8, 0, 22)
	line.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	line.LayoutOrder = order
	Instance.new("UICorner", line).CornerRadius = UDim.new(0, 4)

	local lbl = Instance.new("TextLabel", line)
	lbl.Size = UDim2.new(0.45, 0, 1, 0)
	lbl.Position = UDim2.new(0.02, 0, 0, 0)
	lbl.Text = label
	lbl.TextColor3 = Color3.fromRGB(180, 180, 190)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.SourceSansBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left

	local val = Instance.new("TextLabel", line)
	val.Size = UDim2.new(0.5, 0, 1, 0)
	val.Position = UDim2.new(0.48, 0, 0, 0)
	val.Text = initialValue or "Đang tải..."
	val.TextColor3 = Color3.fromRGB(0, 255, 200)
	val.BackgroundTransparency = 1
	val.Font = Enum.Font.SourceSansBold
	val.TextSize = 11
	val.TextXAlignment = Enum.TextXAlignment.Left
	val.Name = "Value"
	return val
end

-- Tạo các dòng
local statLines = {}
statLines.uptime = createStatLine(StatsContainer, "⏱ Uptime:", "0s", 1)
statLines.time = createStatLine(StatsContainer, "🕒 Hiện tại:", os.date("%H:%M:%S"), 2)
statLines.players = createStatLine(StatsContainer, "👥 Người chơi:", tostring(#Players:GetPlayers()), 3)
statLines.workspace = createStatLine(StatsContainer, "📦 Workspace Instances:", "0", 4)
statLines.parts = createStatLine(StatsContainer, "🧱 Số Part:", "0", 5)
statLines.scripts = createStatLine(StatsContainer, "📜 Scripts:", "0", 6)
statLines.fps = createStatLine(StatsContainer, "🎮 FPS:", "0", 7)
statLines.memory = createStatLine(StatsContainer, "🧠 Memory (MB):", "0", 8)
statLines.ping = createStatLine(StatsContainer, "📡 Ping (ms):", "0", 9)

-- Khung log Instance mới
local LogContainer = Instance.new("Frame", Page10)
LogContainer.Size = UDim2.new(1, -10, 0, 280)
LogContainer.Position = UDim2.new(0, 5, 0, 230)
LogContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
Instance.new("UICorner", LogContainer).CornerRadius = UDim.new(0, 4)

local LogTitle = Instance.new("TextLabel", LogContainer)
LogTitle.Size = UDim2.new(0.5, 0, 0, 20)
LogTitle.Position = UDim2.new(0.02, 0, 0, 0)
LogTitle.Text = "🔄 Instance mới xuất hiện (10 giây gần nhất)"
LogTitle.TextColor3 = Color3.fromRGB(255, 200, 80)
LogTitle.BackgroundTransparency = 1
LogTitle.Font = Enum.Font.SourceSansBold
LogTitle.TextSize = 10
LogTitle.TextXAlignment = Enum.TextXAlignment.Left

local ClearLogBtn = Instance.new("TextButton", LogContainer)
ClearLogBtn.Size = UDim2.new(0, 80, 0, 20)
ClearLogBtn.Position = UDim2.new(1, -90, 0, 0)
ClearLogBtn.Text = "🗑️ Clear"
ClearLogBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ClearLogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearLogBtn.Font = Enum.Font.SourceSansBold
ClearLogBtn.TextSize = 9
Instance.new("UICorner", ClearLogBtn).CornerRadius = UDim.new(0, 3)

local LogScroll = Instance.new("ScrollingFrame", LogContainer)
LogScroll.Size = UDim2.new(1, -6, 1, -26)
LogScroll.Position = UDim2.new(0, 3, 0, 22)
LogScroll.BackgroundTransparency = 1
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
LogScroll.ScrollBarThickness = 3

local LogListUI = Instance.new("UIListLayout", LogScroll)
LogListUI.Padding = UDim.new(0, 2)

local instanceLog = {}
local MAX_LOG = 100

-- Hàm thêm log instance
local function addInstanceLog(inst)
	local time = os.date("%H:%M:%S")
	local path = inst:GetFullName()
	-- Giới hạn độ dài
	if #path > 60 then path = string.sub(path, 1, 57) .. "..." end
	table.insert(instanceLog, {time = time, name = inst.Name, class = inst.ClassName, path = path})
	if #instanceLog > MAX_LOG then table.remove(instanceLog, 1) end

	-- Render lại
	for _, child in pairs(LogScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for i, data in ipairs(instanceLog) do
		local frame = Instance.new("Frame", LogScroll)
		frame.Size = UDim2.new(1, -4, 0, 18)
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 3)

		local text = Instance.new("TextLabel", frame)
		text.Size = UDim2.new(1, -4, 1, 0)
		text.Position = UDim2.new(0.02, 0, 0, 0)
		text.Text = string.format("[%s] %s (%s) – %s", data.time, data.name, data.class, data.path)
		text.TextColor3 = Color3.fromRGB(200, 200, 200)
		text.BackgroundTransparency = 1
		text.Font = Enum.Font.SourceSans
		text.TextSize = 9
		text.TextXAlignment = Enum.TextXAlignment.Left
	end
	LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogListUI.AbsoluteContentSize.Y)
	LogScroll.CanvasPosition = Vector2.new(0, LogScroll.CanvasSize.Y.Offset)
end

-- Bắt sự kiện InstanceAdded trong Workspace
local function trackNewInstances()
	Workspace.InstanceAdded:Connect(addInstanceLog)
end
task.spawn(trackNewInstances)

ClearLogBtn.MouseButton1Click:Connect(function()
	instanceLog = {}
	for _, child in pairs(LogScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

-- Vòng lặp cập nhật thông số
local startTime = tick()
local fpsCounter = 0
local fpsTime = 0
local fpsValue = 0

RunService.RenderStepped:Connect(function(dt)
	fpsCounter = fpsCounter + 1
	fpsTime = fpsTime + dt
	if fpsTime >= 1 then
		fpsValue = fpsCounter
		fpsCounter = 0
		fpsTime = 0
	end
end)

task.spawn(function()
	while task.wait(1) do
		safeCall(function()
			-- Uptime
			local uptime = tick() - startTime
			local hours = math.floor(uptime / 3600)
			local minutes = math.floor((uptime % 3600) / 60)
			local seconds = math.floor(uptime % 60)
			local uptimeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)
			statLines.uptime.Text = uptimeStr

			-- Thời gian hiện tại
			statLines.time.Text = os.date("%H:%M:%S")

			-- Số người chơi
			statLines.players.Text = tostring(#Players:GetPlayers())

			-- Tổng số instance trong Workspace
			local wsCount = 0
			local partCount = 0
			local scriptCount = 0
			for _, obj in pairs(Workspace:GetDescendants()) do
				wsCount = wsCount + 1
				if obj:IsA("BasePart") and not obj:IsA("Terrain") then partCount = partCount + 1 end
				if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then scriptCount = scriptCount + 1 end
			end
			statLines.workspace.Text = tostring(wsCount)
			statLines.parts.Text = tostring(partCount)
			statLines.scripts.Text = tostring(scriptCount)

			-- FPS
			statLines.fps.Text = tostring(fpsValue)

			-- Memory (sửa lỗi cú pháp)
			local mem = pcall(game.GetMemoryUsage, game) and game:GetMemoryUsage() or 0
			statLines.memory.Text = string.format("%.1f", mem / 1024)

			-- Ping (ước lượng từ Stats)
			local ping = 0
			if game:GetService("Stats") and game.Stats:FindFirstChild("Network") then
				local net = game.Stats.Network
				if net and net:FindFirstChild("Ping") then
					ping = math.floor(net.Ping.Value * 1000)
				end
			end
			statLines.ping.Text = tostring(ping)
		end)
	end
end)

--=========================================================  
-- AUTO REFRESH LOOP  
--=========================================================  
task.spawn(function()
	while task.wait(3) do
		safeCall(function()
			if Page2.Visible then updateNpcList() end
			if Page3.Visible then updateBlockList() end
			if Page4.Visible then updateBackpackList() end
			if Page5.Visible then updateStatsInspector() end
			if Page9.Visible then applyHitboxVisuals() end
			-- Tab 10 tự cập nhật qua vòng lặp riêng
		end)
	end
end)

-- Kích hoạt tab mặc định
tabButtons[1].BackgroundColor3 = Color3.fromRGB(0, 180, 120)
tabButtons[1].TextColor3 = Color3.fromRGB(255, 255, 255)
Page1.Visible = true

--=========================================================  
-- KHỞI TẠO DỮ LIỆU BAN ĐẦU  
--=========================================================  
task.spawn(function()
	task.wait(0.5)
	safeCall(updateNpcList)
	safeCall(updateBlockList)
	safeCall(updateBackpackList)
	safeCall(updateStatsInspector)
	safeCall(applyHitboxVisuals)
	-- Thêm log mẫu cho tab 10
	addInstanceLog(Workspace)
end)

print("🚀 ULTIMATE TOOLKIT v14.0 ĐÃ SẴN SÀNG!")
print("📌 Nhấn Right Control để toggle UI")
