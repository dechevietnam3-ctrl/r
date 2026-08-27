-- ReplicatedStorage Explorer & Spawner - tookit v5.1 (FIXED - No server auto-create if unsupported)
-- Duyệt, spawn và sử dụng Tool từ ReplicatedStorage

local TookitSpawner = {}
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- ===== KIỂM TRA HỖ TRỢ TẠO SERVER SCRIPT =====
local canCreateServerScript = false
if syn and syn.create_script then
	canCreateServerScript = true
elseif secure_call and secure_call then
	canCreateServerScript = true
end

-- ===== TẠO REMOTEEVENT =====
local RemoteEvent = RS:FindFirstChild("TookitSpawnerRemote")
if not RemoteEvent then
	RemoteEvent = Instance.new("RemoteEvent")
	RemoteEvent.Name = "TookitSpawnerRemote"
	RemoteEvent.Parent = RS
end

-- ===== TẠO SERVER SCRIPT (nếu có thể) =====
local serverScriptCreated = false
local serverScriptCode = [[
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Remote = RS:FindFirstChild("TookitSpawnerRemote")
if not Remote then return end

local function giveTool(player, toolName, equipImmediately)
	local toolTemplate = RS:FindFirstChild(toolName)
	if not toolTemplate then
		warn("[TookitSpawner] Không tìm thấy Tool: " .. tostring(toolName))
		return false
	end
	if not toolTemplate:IsA("Tool") then
		warn("[TookitSpawner] Object không phải Tool: " .. tostring(toolName))
		return false
	end
	local clonedTool = toolTemplate:Clone()
	clonedTool.Parent = player.Backpack
	task.wait(0.1)
	if equipImmediately and player.Character then
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum and clonedTool.Parent == player.Backpack then
			hum:EquipTool(clonedTool)
		end
	end
	return true
end

Remote.OnServerEvent:Connect(function(player, action, toolName, equipImmediately)
	if action == "giveTool" then
		giveTool(player, toolName, equipImmediately)
	end
end)

print("[TookitSpawner] Server script ready!")
]]

if canCreateServerScript then
	local success, err = pcall(function()
		if syn and syn.create_script then
			syn.create_script("ServerScriptService", "TookitSpawnerServer", serverScriptCode)
			serverScriptCreated = true
		elseif secure_call then
			secure_call(function()
				local ss = Instance.new("Script")
				ss.Name = "TookitSpawnerServer"
				ss.Source = serverScriptCode
				ss.Parent = game:GetService("ServerScriptService")
			end)
			serverScriptCreated = true
		end
	end)
	if not success then
		serverScriptCreated = false
	end
end

-- Nếu không tạo được, copy code vào clipboard và hiển thị hướng dẫn
if not serverScriptCreated then
	local function copyServerScriptCode()
		if setclipboard then
			pcall(setclipboard, serverScriptCode)
			return true
		end
		return false
	end
	copyServerScriptCode()
	-- Hiển thị thông báo trên màn hình
	task.spawn(function()
		local notification = Instance.new("Frame")
		notification.Size = UDim2.new(0, 500, 0, 120)
		notification.Position = UDim2.new(0.5, -250, 0.5, -60)
		notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
		notification.BackgroundTransparency = 0.9
		Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 8)
		if gethui then notification.Parent = gethui() else notification.Parent = CoreGui end
		
		local label = Instance.new("TextLabel", notification)
		label.Size = UDim2.new(0.9, 0, 0.7, 0)
		label.Position = UDim2.new(0.05, 0, 0.1, 0)
		label.Text = "⚠️ KHÔNG THỂ TẠO SERVER SCRIPT TỰ ĐỘNG\n\nCode ServerScript đã được copy vào clipboard.\nVui lòng tạo một Script trong ServerScriptService và paste vào."
		label.TextColor3 = Color3.fromRGB(255, 200, 100)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.SourceSans
		label.TextSize = 12
		label.TextScaled = true
		label.TextWrapped = true
		
		local closeBtn = Instance.new("TextButton", notification)
		closeBtn.Size = UDim2.new(0, 60, 0, 30)
		closeBtn.Position = UDim2.new(0.5, -30, 0.8, 0)
		closeBtn.Text = "OK"
		closeBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
		closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeBtn.Font = Enum.Font.SourceSansBold
		closeBtn.TextSize = 14
		Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
		closeBtn.MouseButton1Click:Connect(function()
			notification:Destroy()
		end)
		
		task.wait(10)
		if notification then notification:Destroy() end
	end)
end

-- ===== UTILITY =====
local function copyToClipboard(text)
	if setclipboard then
		pcall(setclipboard, text)
		return true
	end
	return false
end

local function safeCall(func, ...)
	local ok, result = pcall(func, ...)
	if not ok then
		warn("[TookitSpawner] Error: " .. tostring(result))
		return nil, result
	end
	return result
end

local function getObjectPath(obj)
	local path = {}
	local current = obj
	while current do
		table.insert(path, 1, current.Name)
		current = current.Parent
	end
	return table.concat(path, "/")
end

local function getObjectInfo(obj)
	return string.format("%s (%s)", obj.Name, obj.ClassName)
end

local function isTool(obj) return obj:IsA("Tool") end
local function isPart(obj) return obj:IsA("BasePart") and not obj:IsA("Terrain") end
local function isModel(obj) return obj:IsA("Model") end
local function isScript(obj) return obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") end

-- ===== GỬI YÊU CẦU CLONE TỪ SERVER (nếu có RemoteEvent) =====
local function requestToolFromServer(toolName, equipImmediately)
	if not RemoteEvent then
		return false, "RemoteEvent không tồn tại"
	end
	if not serverScriptCreated then
		return false, "ServerScript chưa được tạo! Vui lòng tạo ServerScript theo hướng dẫn."
	end
	RemoteEvent:FireServer("giveTool", toolName, equipImmediately)
	return true
end

-- ===== UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TookitSpawner"
ScreenGui.ResetOnSpawn = false
if gethui then
	ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then
	syn.protect_gui(ScreenGui)
	ScreenGui.Parent = CoreGui
else
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 720, 0, 540)
MainFrame.Position = UDim2.new(0.5, -360, 0.5, -270)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 16)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 220, 180)

-- Title
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -80, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 4)
Title.Text = "📦 ReplicatedStorage Explorer - tookit v5.1"
Title.TextColor3 = Color3.fromRGB(0, 220, 180)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 4)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
CloseBtn.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Controls
local Controls = Instance.new("Frame", MainFrame)
Controls.Size = UDim2.new(1, -16, 0, 32)
Controls.Position = UDim2.new(0, 8, 0, 36)
Controls.BackgroundTransparency = 1

local SearchBox = Instance.new("TextBox", Controls)
SearchBox.Size = UDim2.new(0.3, 0, 1, -4)
SearchBox.PlaceholderText = "🔍 Tìm..."
SearchBox.Text = ""
SearchBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 11
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

local RefreshBtn = Instance.new("TextButton", Controls)
RefreshBtn.Size = UDim2.new(0, 50, 0, 24)
RefreshBtn.Position = UDim2.new(0.32, 0, 0, 0)
RefreshBtn.Text = "🔄"
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.TextSize = 14
Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 4)

local ExpandAllBtn = Instance.new("TextButton", Controls)
ExpandAllBtn.Size = UDim2.new(0, 60, 0, 24)
ExpandAllBtn.Position = UDim2.new(0.38, 0, 0, 0)
ExpandAllBtn.Text = "📂 Mở hết"
ExpandAllBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ExpandAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExpandAllBtn.Font = Enum.Font.SourceSansBold
ExpandAllBtn.TextSize = 9
Instance.new("UICorner", ExpandAllBtn).CornerRadius = UDim.new(0, 4)

local CollapseAllBtn = Instance.new("TextButton", Controls)
CollapseAllBtn.Size = UDim2.new(0, 60, 0, 24)
CollapseAllBtn.Position = UDim2.new(0.46, 0, 0, 0)
CollapseAllBtn.Text = "📁 Thu hết"
CollapseAllBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
CollapseAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CollapseAllBtn.Font = Enum.Font.SourceSansBold
CollapseAllBtn.TextSize = 9
Instance.new("UICorner", CollapseAllBtn).CornerRadius = UDim.new(0, 4)

-- Position & Action
local ActionFrame = Instance.new("Frame", MainFrame)
ActionFrame.Size = UDim2.new(1, -16, 0, 28)
ActionFrame.Position = UDim2.new(0, 8, 0, 72)
ActionFrame.BackgroundTransparency = 1

local XBox = Instance.new("TextBox", ActionFrame)
XBox.Size = UDim2.new(0.07, 0, 1, 0)
XBox.PlaceholderText = "X"
XBox.Text = ""
XBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
XBox.TextColor3 = Color3.fromRGB(255, 255, 255)
XBox.Font = Enum.Font.SourceSans
XBox.TextSize = 10
Instance.new("UICorner", XBox).CornerRadius = UDim.new(0, 3)

local YBox = Instance.new("TextBox", ActionFrame)
YBox.Size = UDim2.new(0.07, 0, 1, 0)
YBox.Position = UDim2.new(0.09, 0, 0, 0)
YBox.PlaceholderText = "Y"
YBox.Text = ""
YBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
YBox.TextColor3 = Color3.fromRGB(255, 255, 255)
YBox.Font = Enum.Font.SourceSans
YBox.TextSize = 10
Instance.new("UICorner", YBox).CornerRadius = UDim.new(0, 3)

local ZBox = Instance.new("TextBox", ActionFrame)
ZBox.Size = UDim2.new(0.07, 0, 1, 0)
ZBox.Position = UDim2.new(0.18, 0, 0, 0)
ZBox.PlaceholderText = "Z"
ZBox.Text = ""
ZBox.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
ZBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ZBox.Font = Enum.Font.SourceSans
ZBox.TextSize = 10
Instance.new("UICorner", ZBox).CornerRadius = UDim.new(0, 3)

local GetPosBtn = Instance.new("TextButton", ActionFrame)
GetPosBtn.Size = UDim2.new(0.06, 0, 1, 0)
GetPosBtn.Position = UDim2.new(0.27, 0, 0, 0)
GetPosBtn.Text = "📌"
GetPosBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
GetPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetPosBtn.Font = Enum.Font.SourceSansBold
GetPosBtn.TextSize = 12
Instance.new("UICorner", GetPosBtn).CornerRadius = UDim.new(0, 3)
GetPosBtn.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local p = hrp.Position
		XBox.Text = string.format("%.2f", p.X)
		YBox.Text = string.format("%.2f", p.Y)
		ZBox.Text = string.format("%.2f", p.Z)
	end
end)

-- NÚT "THÊM VÀO BACKPACK"
local BackpackBtn = Instance.new("TextButton", ActionFrame)
BackpackBtn.Size = UDim2.new(0.12, 0, 1, 0)
BackpackBtn.Position = UDim2.new(0.35, 0, 0, 0)
BackpackBtn.Text = "🎒 Backpack"
BackpackBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
BackpackBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BackpackBtn.Font = Enum.Font.SourceSansBold
BackpackBtn.TextSize = 10
Instance.new("UICorner", BackpackBtn).CornerRadius = UDim.new(0, 3)

-- NÚT "TRANG BỊ"
local EquipBtn = Instance.new("TextButton", ActionFrame)
EquipBtn.Size = UDim2.new(0.12, 0, 1, 0)
EquipBtn.Position = UDim2.new(0.49, 0, 0, 0)
EquipBtn.Text = "⚔️ Trang bị"
EquipBtn.BackgroundColor3 = Color3.fromRGB(180, 120, 0)
EquipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EquipBtn.Font = Enum.Font.SourceSansBold
EquipBtn.TextSize = 10
Instance.new("UICorner", EquipBtn).CornerRadius = UDim.new(0, 3)

-- NÚT "SPAWN" (vào Workspace)
local SpawnBtn = Instance.new("TextButton", ActionFrame)
SpawnBtn.Size = UDim2.new(0.1, 0, 1, 0)
SpawnBtn.Position = UDim2.new(0.63, 0, 0, 0)
SpawnBtn.Text = "📦 Spawn"
SpawnBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 70)
SpawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnBtn.Font = Enum.Font.SourceSansBold
SpawnBtn.TextSize = 10
Instance.new("UICorner", SpawnBtn).CornerRadius = UDim.new(0, 3)

local ScriptBtn = Instance.new("TextButton", ActionFrame)
ScriptBtn.Size = UDim2.new(0.08, 0, 1, 0)
ScriptBtn.Position = UDim2.new(0.75, 0, 0, 0)
ScriptBtn.Text = "📜 Script"
ScriptBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
ScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptBtn.Font = Enum.Font.SourceSansBold
ScriptBtn.TextSize = 9
Instance.new("UICorner", ScriptBtn).CornerRadius = UDim.new(0, 3)

local InfoBtn = Instance.new("TextButton", ActionFrame)
InfoBtn.Size = UDim2.new(0.08, 0, 1, 0)
InfoBtn.Position = UDim2.new(0.85, 0, 0, 0)
InfoBtn.Text = "ℹ️ Info"
InfoBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
InfoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InfoBtn.Font = Enum.Font.SourceSansBold
InfoBtn.TextSize = 9
Instance.new("UICorner", InfoBtn).CornerRadius = UDim.new(0, 3)

-- Tree
local TreeScroll = Instance.new("ScrollingFrame", MainFrame)
TreeScroll.Size = UDim2.new(1, -16, 1, -170)
TreeScroll.Position = UDim2.new(0, 8, 0, 104)
TreeScroll.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
TreeScroll.BorderSizePixel = 0
TreeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TreeScroll.ScrollBarThickness = 4
Instance.new("UICorner", TreeScroll).CornerRadius = UDim.new(0, 4)

local TreeLayout = Instance.new("UIListLayout", TreeScroll)
TreeLayout.Padding = UDim.new(0, 2)

-- Status
local StatusFrame = Instance.new("Frame", MainFrame)
StatusFrame.Size = UDim2.new(1, -16, 0, 40)
StatusFrame.Position = UDim2.new(0, 8, 1, -44)
StatusFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 4)

local StatusLabel = Instance.new("TextLabel", StatusFrame)
StatusLabel.Size = UDim2.new(1, -10, 1, 0)
StatusLabel.Position = UDim2.new(0, 5, 0, 0)
StatusLabel.Text = "✅ Sẵn sàng"
StatusLabel.TextColor3 = Color3.fromRGB(180, 220, 180)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

-- ===== State =====
local selectedObject = nil
local expandedNodes = {}
local searchFilter = ""
local nodeMap = {}

-- ===== Tree Builder =====
local function buildTreeUI(object, depth, parentFrame)
	local children = {}
	for _, child in ipairs(object:GetChildren()) do
		table.insert(children, child)
	end
	table.sort(children, function(a, b) return a.Name < b.Name end)

	local isExpanded = expandedNodes[object] or false

	local nodeFrame = Instance.new("Frame", parentFrame)
	nodeFrame.Size = UDim2.new(1, -4, 0, 24)
	nodeFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
	Instance.new("UICorner", nodeFrame).CornerRadius = UDim.new(0, 3)

	local indent = Instance.new("Frame", nodeFrame)
	indent.Size = UDim2.new(0, depth * 16, 1, 0)
	indent.BackgroundTransparency = 1

	local expandBtn = nil
	if #children > 0 then
		expandBtn = Instance.new("TextButton", nodeFrame)
		expandBtn.Size = UDim2.new(0, 20, 1, 0)
		expandBtn.Position = UDim2.new(0, depth * 16, 0, 0)
		expandBtn.Text = isExpanded and "▾" or "▸"
		expandBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		expandBtn.BackgroundTransparency = 1
		expandBtn.Font = Enum.Font.SourceSansBold
		expandBtn.TextSize = 12
		expandBtn.MouseButton1Click:Connect(function()
			expandedNodes[object] = not expandedNodes[object]
			refreshTree()
		end)
	end

	local labelX = (expandBtn and 20 or 0) + depth * 16 + 4
	local label = Instance.new("TextLabel", nodeFrame)
	label.Size = UDim2.new(1, -labelX - 8, 1, 0)
	label.Position = UDim2.new(0, labelX, 0, 0)
	
	local icon = ""
	if isTool(object) then icon = "🔧 " end
	label.Text = icon .. getObjectInfo(object)
	label.TextColor3 = isTool(object) and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(220, 220, 220)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SourceSans
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left

	local selectBtn = Instance.new("TextButton", nodeFrame)
	selectBtn.Size = UDim2.new(1, 0, 1, 0)
	selectBtn.BackgroundTransparency = 1
	selectBtn.Text = ""
	selectBtn.MouseButton1Click:Connect(function()
		selectedObject = object
		local toolStatus = isTool(object) and " (Tool)" or ""
		StatusLabel.Text = string.format("📌 Đã chọn: %s%s", object.Name, toolStatus)
		StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 180)
	end)

	nodeMap[object] = nodeFrame

	if #children > 0 and isExpanded then
		local childContainer = Instance.new("Frame", parentFrame)
		childContainer.Size = UDim2.new(1, -4, 0, 0)
		childContainer.BackgroundTransparency = 1
		childContainer.AutomaticSize = Enum.AutomaticSize.Y
		childContainer.LayoutOrder = 1
		local childLayout = Instance.new("UIListLayout", childContainer)
		childLayout.Padding = UDim.new(0, 2)

		for _, child in ipairs(children) do
			if searchFilter == "" or string.find(string.lower(child.Name), searchFilter) then
				buildTreeUI(child, depth + 1, childContainer)
			end
		end
	end

	return nodeFrame
end

function refreshTree()
	for _, child in pairs(TreeScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	nodeMap = {}

	local root = RS
	local rootFrame = Instance.new("Frame", TreeScroll)
	rootFrame.Size = UDim2.new(1, -4, 0, 24)
	rootFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	Instance.new("UICorner", rootFrame).CornerRadius = UDim.new(0, 3)
	local rootLabel = Instance.new("TextLabel", rootFrame)
	rootLabel.Size = UDim2.new(1, -8, 1, 0)
	rootLabel.Position = UDim2.new(0, 4, 0, 0)
	rootLabel.Text = "📁 ReplicatedStorage"
	rootLabel.TextColor3 = Color3.fromRGB(0, 220, 180)
	rootLabel.BackgroundTransparency = 1
	rootLabel.Font = Enum.Font.SourceSansBold
	rootLabel.TextSize = 11
	rootLabel.TextXAlignment = Enum.TextXAlignment.Left

	local childContainer = Instance.new("Frame", TreeScroll)
	childContainer.Size = UDim2.new(1, -4, 0, 0)
	childContainer.BackgroundTransparency = 1
	childContainer.AutomaticSize = Enum.AutomaticSize.Y
	local childLayout = Instance.new("UIListLayout", childContainer)
	childLayout.Padding = UDim.new(0, 2)

	local children = root:GetChildren()
	table.sort(children, function(a, b) return a.Name < b.Name end)
	for _, child in ipairs(children) do
		if searchFilter == "" or string.find(string.lower(child.Name), searchFilter) then
			buildTreeUI(child, 0, childContainer)
		end
	end

	TreeScroll.CanvasSize = UDim2.new(0, 0, 0, TreeLayout.AbsoluteContentSize.Y)
end

-- ===== Spawn Actions =====
local function getSpawnPosition()
	local x = tonumber(XBox.Text)
	local y = tonumber(YBox.Text)
	local z = tonumber(ZBox.Text)
	if x and y and z then
		return Vector3.new(x, y, z)
	end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		return hrp.Position + Vector3.new(0, 3, 0)
	end
	return Vector3.new(0, 10, 0)
end

local function spawnToWorkspace(obj, pos)
	if not obj or not obj.Parent then
		StatusLabel.Text = "❌ Object không còn tồn tại"
		return nil
	end
	local clone = obj:Clone()
	clone.Parent = Workspace
	if pos then
		if clone:IsA("BasePart") then
			clone.Position = pos
		elseif clone:IsA("Model") then
			local primary = clone.PrimaryPart
			if primary then
				clone:SetPrimaryPartCFrame(CFrame.new(pos))
			else
				local parts = {}
				for _, part in pairs(clone:GetDescendants()) do
					if part:IsA("BasePart") then
						table.insert(parts, part)
					end
				end
				if #parts > 0 then
					local offset = pos - parts[1].Position
					for _, part in ipairs(parts) do
						part.CFrame = part.CFrame + offset
					end
				end
			end
		elseif clone:IsA("Tool") then
			local handle = clone:FindFirstChild("Handle")
			if handle and handle:IsA("BasePart") then
				handle.Position = pos
			end
		end
	end
	return clone
end

local function getScripts(obj)
	local scripts = {}
	for _, child in pairs(obj:GetDescendants()) do
		if child:IsA("Script") or child:IsA("LocalScript") or child:IsA("ModuleScript") then
			table.insert(scripts, child)
		end
	end
	return scripts
end

-- ===== Button Events =====

BackpackBtn.MouseButton1Click:Connect(function()
	if not selectedObject then
		StatusLabel.Text = "⚠️ Chưa chọn object!"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		return
	end
	if not isTool(selectedObject) then
		StatusLabel.Text = "❌ Đây không phải Tool!"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		return
	end
	
	local toolName = selectedObject.Name
	local success, err = requestToolFromServer(toolName, false)
	
	if success then
		StatusLabel.Text = string.format("✅ Đang thêm %s vào Backpack...", toolName)
		StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	else
		StatusLabel.Text = "❌ " .. (err or "Không thể gửi yêu cầu")
		StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)

EquipBtn.MouseButton1Click:Connect(function()
	if not selectedObject then
		StatusLabel.Text = "⚠️ Chưa chọn object!"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		return
	end
	if not isTool(selectedObject) then
		StatusLabel.Text = "❌ Đây không phải Tool!"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		return
	end
	
	local toolName = selectedObject.Name
	local success, err = requestToolFromServer(toolName, true)
	
	if success then
		StatusLabel.Text = string.format("✅ Đang trang bị %s...", toolName)
		StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	else
		StatusLabel.Text = "❌ " .. (err or "Không thể gửi yêu cầu")
		StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)

SpawnBtn.MouseButton1Click:Connect(function()
	if not selectedObject then
		StatusLabel.Text = "⚠️ Chưa chọn object!"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		return
	end
	local pos = getSpawnPosition()
	local result = safeCall(spawnToWorkspace, selectedObject, pos)
	if result then
		StatusLabel.Text = string.format("✅ Đã spawn: %s vào Workspace", selectedObject.Name)
		StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	else
		StatusLabel.Text = string.format("❌ Lỗi spawn: %s", tostring(result))
		StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)

ScriptBtn.MouseButton1Click:Connect(function()
	if not selectedObject then
		StatusLabel.Text = "⚠️ Chưa chọn object!"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		return
	end
	local scripts = getScripts(selectedObject)
	if #scripts == 0 then
		StatusLabel.Text = "📜 Không tìm thấy script"
		StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		return
	end
	local text = "Scripts trong " .. selectedObject.Name .. ":\n"
	for i, scr in ipairs(scripts) do
		text = text .. string.format("%d. %s (%s)\n", i, scr.Name, scr.ClassName)
		if scr:IsA("ModuleScript") or scr:IsA("LocalScript") or scr:IsA("Script") then
			if scr.Source and #scr.Source > 0 then
				text = text .. "   Code:\n" .. scr.Source .. "\n\n"
			end
		end
	end
	copyToClipboard(text)
	StatusLabel.Text = string.format("📋 Đã copy %d script", #scripts)
	StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 180)
end)

InfoBtn.MouseButton1Click:Connect(function()
	if not selectedObject then
		StatusLabel.Text = "⚠️ Chưa chọn object!"
		StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		return
	end
	local details = {
		Name = selectedObject.Name,
		ClassName = selectedObject.ClassName,
		Path = getObjectPath(selectedObject),
		Parent = selectedObject.Parent and selectedObject.Parent.Name or "nil",
		Children = #selectedObject:GetChildren(),
		Descendants = #selectedObject:GetDescendants(),
		IsTool = isTool(selectedObject),
	}
	if selectedObject:IsA("BasePart") then
		details.Position = string.format("%.2f, %.2f, %.2f", selectedObject.Position.X, selectedObject.Position.Y, selectedObject.Position.Z)
		details.Size = string.format("%.2f, %.2f, %.2f", selectedObject.Size.X, selectedObject.Size.Y, selectedObject.Size.Z)
	end
	if selectedObject:IsA("Tool") then
		local handle = selectedObject:FindFirstChild("Handle")
		details.Handle = handle and handle.Name or "None"
	end
	local scripts = getScripts(selectedObject)
	details.Scripts = #scripts
	local text = "=== Thông tin object ===\n"
	for k, v in pairs(details) do
		text = text .. string.format("%s: %s\n", k, tostring(v))
	end
	copyToClipboard(text)
	StatusLabel.Text = "📋 Đã copy thông tin"
	StatusLabel.TextColor3 = Color3.fromRGB(0, 220, 180)
end)

ExpandAllBtn.MouseButton1Click:Connect(function()
	local function expandAll(obj)
		expandedNodes[obj] = true
		for _, child in pairs(obj:GetChildren()) do
			expandAll(child)
		end
	end
	expandAll(RS)
	refreshTree()
end)

CollapseAllBtn.MouseButton1Click:Connect(function()
	expandedNodes = {}
	refreshTree()
end)

RefreshBtn.MouseButton1Click:Connect(refreshTree)
SearchBox.Changed:Connect(function()
	searchFilter = string.lower(SearchBox.Text)
	refreshTree()
end)

-- ===== Hotkey =====
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
		MainFrame.Visible = not MainFrame.Visible
		if MainFrame.Visible then refreshTree() end
	end
end)

-- ===== Init =====
refreshTree()
local statusText = "✅ Sẵn sàng"
if not serverScriptCreated then
	statusText = statusText .. " | ⚠️ ServerScript chưa tạo. Tool sẽ không hoạt động. Xem hướng dẫn."
end
StatusLabel.Text = statusText
print("📦 ReplicatedStorage Explorer - tookit v5.1 loaded.")
if not serverScriptCreated then
	print("⚠️ Không thể tạo ServerScript tự động. Vui lòng tạo Script trong ServerScriptService với nội dung đã copy vào clipboard.")
end
