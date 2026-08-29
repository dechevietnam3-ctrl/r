-- ================================================================  
-- ULTIMATE TOOLKIT v6.0 – NÂNG CẤP TOÀN DIỆN – tookit  
-- Mục tiêu: Cung cấp bảng dữ liệu toàn cục + UI đa tab + hành động  
-- Tích hợp đầy đủ tính năng từ DataScout, Remote Spy, Explorer, Inspector  
-- Phím tắt: Right Control  
-- ================================================================  

local Tookit = {
	Services = {
		Players = game:GetService("Players"),
		Workspace = game:GetService("Workspace"),
		ReplicatedStorage = game:GetService("ReplicatedStorage"),
		ServerStorage = game:GetService("ServerStorage"),
		Lighting = game:GetService("Lighting"),
		UserInputService = game:GetService("UserInputService"),
		CoreGui = game:GetService("CoreGui"),
		RunService = game:GetService("RunService"),
		HttpService = game:GetService("HttpService"),
		LogService = game:GetService("LogService"),
		TweenService = game:GetService("TweenService"),
	},
	GameData = {
		players = {},
		workspace = { totalInstances = 0, parts = 0, models = 0, scripts = 0 },
		values = {},
		npcs = {},
		blocks = {},
		remoteEvents = {},
		remoteFunctions = {},
		storageItems = {},
		logs = {},
		waypoints = {},
		tpLogs = {},
		remoteLogs = {},
		lastUpdate = "",
		cacheValid = false,
	},
	Config = {
		autoRefresh = true,
		refreshInterval = 1.5,
		maxLogs = 200,
		useRegex = false,
		showStackTrace = false,
		logToFile = false,
	},
	UI = nil,
	Cleanup = {},
}

-- =====================================================================
-- UTILITY NÂNG CẤP
-- =====================================================================
local function copyToClipboard(text)
	if setclipboard then pcall(setclipboard, text) return true end
	return false
end

local function safeCall(func, fallback)
	local ok, result = pcall(func)
	if not ok then warn("[Tookit] " .. tostring(result)) end
	return ok and result or fallback
end

local function getScriptCode(scr)
	if decompile then
		local ok, code = pcall(decompile, scr)
		if ok and code and #code > 0 then return code end
	end
	if (scr:IsA("LocalScript") or scr:IsA("ModuleScript") or scr:IsA("Script")) and scr.Source and #scr.Source > 0 then
		return scr.Source
	end
	return "-- [Không thể đọc source]"
end

local function getHRP(char) return char and char:FindFirstChild("HumanoidRootPart") end
local function getPlayerCharacter(plr) return plr and plr.Character end
local function tableCount(t) local n=0 for _ in pairs(t) do n=n+1 end return n end

local function serializeArgs(args)
	if not args or #args == 0 then return "[]" end
	local s = {}
	for _,v in ipairs(args) do
		if type(v)=="string" then table.insert(s, string.format("%q", v))
		elseif type(v)=="number" or type(v)=="boolean" then table.insert(s, tostring(v))
		else table.insert(s, tostring(v))
		end
	end
	return "[" .. table.concat(s, ", ") .. "]"
end

-- =====================================================================
-- REFRESH DỮ LIỆU (tối ưu)
-- =====================================================================
local function refreshGameData()
	local GD = Tookit.GameData
	local S = Tookit.Services

	-- Reset
	GD.players = {}
	GD.values = {}
	GD.npcs = {}
	GD.blocks = {}
	GD.remoteEvents = {}
	GD.remoteFunctions = {}
	GD.storageItems = {}
	GD.workspace.totalInstances = 0
	GD.workspace.parts = 0
	GD.workspace.models = 0
	GD.workspace.scripts = 0

	-- Players
	for _, plr in pairs(S.Players:GetPlayers()) do
		local char = getPlayerCharacter(plr)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = getHRP(char)
		local pos = hrp and hrp.Position or Vector3.new(0,0,0)
		local leaderstats = plr:FindFirstChild("leaderstats")
		local stats = {}
		if leaderstats then
			for _, stat in pairs(leaderstats:GetChildren()) do
				if stat:IsA("ValueBase") then stats[stat.Name] = stat.Value end
			end
		end
		GD.players[plr] = {
			Name = plr.Name, DisplayName = plr.DisplayName,
			Character = char, Humanoid = hum, HRP = hrp,
			Position = pos, Health = hum and hum.Health or 0,
			MaxHealth = hum and hum.MaxHealth or 0,
			WalkSpeed = hum and hum.WalkSpeed or 0,
			JumpPower = hum and hum.JumpPower or 0,
			Leaderstats = stats,
			IsLocal = (plr == S.Players.LocalPlayer),
		}
	end

	-- Values
	local containers = {S.Workspace, S.Players, S.ReplicatedStorage, S.ServerStorage,
		S.Lighting, game:GetService("ScriptContext"), game:GetService("StarterGui"),
		game:GetService("StarterPack"), game:GetService("StarterPlayer")}
	for _, c in ipairs(containers) do
		if c then
			for _, obj in pairs(c:GetDescendants()) do
				if obj:IsA("NumberValue") or obj:IsA("IntValue") or obj:IsA("FloatValue") then
					local path = obj:GetFullName()
					local old = GD.values[path] and GD.values[path].value
					GD.values[path] = { obj = obj, value = obj.Value, previous = old }
				end
			end
		end
	end

	-- NPCs
	for _, model in pairs(S.Workspace:GetDescendants()) do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			if not S.Players:GetPlayerFromCharacter(model) then
				GD.npcs[model:GetFullName()] = model
			end
		end
	end

	-- Blocks
	for _, obj in pairs(S.Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and not obj:IsA("Terrain") then
			local parent = obj.Parent
			if parent and not S.Players:GetPlayerFromCharacter(parent) and not parent:FindFirstChildOfClass("Humanoid") then
				GD.blocks[obj:GetFullName()] = obj
			end
		elseif obj:IsA("Model") and not obj:FindFirstChildOfClass("Humanoid") and not S.Players:GetPlayerFromCharacter(obj) then
			GD.blocks[obj:GetFullName()] = obj
		end
	end

	-- Remotes
	for _, obj in pairs(game:GetDescendants()) do
		if obj:IsA("RemoteEvent") then GD.remoteEvents[obj:GetFullName()] = obj
		elseif obj:IsA("RemoteFunction") then GD.remoteFunctions[obj:GetFullName()] = obj end
	end

	-- Storage
	for _, container in ipairs({S.ReplicatedStorage, S.ServerStorage}) do
		if container then
			for _, child in pairs(container:GetChildren()) do
				GD.storageItems[child:GetFullName()] = child
			end
		end
	end

	-- Workspace stats
	local desc = S.Workspace:GetDescendants()
	GD.workspace.totalInstances = #desc
	local parts, models, scripts = 0,0,0
	for _, obj in ipairs(desc) do
		if obj:IsA("BasePart") and not obj:IsA("Terrain") then parts = parts + 1 end
		if obj:IsA("Model") then models = models + 1 end
		if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then scripts = scripts + 1 end
	end
	GD.workspace.parts = parts
	GD.workspace.models = models
	GD.workspace.scripts = scripts

	GD.lastUpdate = os.date("%H:%M:%S")
	GD.cacheValid = true
end

-- =====================================================================
-- UI BUILDER (NÂNG CẤP: thêm thanh công cụ, ESP, hành động)
-- =====================================================================
local function buildUI()
	local S = Tookit.Services
	local Gui = Instance.new("ScreenGui")
	Gui.Name = "UltimateToolkit_v6"
	Gui.ResetOnSpawn = false
	if gethui then
		Gui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(Gui); Gui.Parent = S.CoreGui
	else
		Gui.Parent = S.Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	local Main = Instance.new("Frame", Gui)
	Main.Size = UDim2.new(0, 960, 0, 660)
	Main.Position = UDim2.new(0.5, -480, 0.5, -330)
	Main.BackgroundColor3 = Color3.fromRGB(12,12,18)
	Main.Active = true; Main.Draggable = true
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
	local Stroke = Instance.new("UIStroke", Main)
	Stroke.Color = Color3.fromRGB(0,255,200); Stroke.Thickness = 1.5

	local Title = Instance.new("TextLabel", Main)
	Title.Size = UDim2.new(1, -120, 0, 32)
	Title.Position = UDim2.new(0,10,0,4)
	Title.Text = "🧰 ULTIMATE TOOLKIT v6.0 – tookit"
	Title.TextColor3 = Color3.fromRGB(0,255,200)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.SourceSansBold
	Title.TextSize = 14
	Title.TextXAlignment = Enum.TextXAlignment.Left

	local CloseBtn = Instance.new("TextButton", Main)
	CloseBtn.Size = UDim2.new(0,26,0,24)
	CloseBtn.Position = UDim2.new(1,-32,0,6)
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(30,30,38)
	CloseBtn.Font = Enum.Font.SourceSansBold
	CloseBtn.TextSize = 12
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,4)
	CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

	-- Tab Bar
	local TabBar = Instance.new("Frame", Main)
	TabBar.Size = UDim2.new(0, 130, 1, -50)
	TabBar.Position = UDim2.new(0,6,0,38)
	TabBar.BackgroundColor3 = Color3.fromRGB(18,18,24)
	Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0,6)
	local TabLayout = Instance.new("UIListLayout", TabBar)
	TabLayout.FillDirection = Enum.FillDirection.Vertical
	TabLayout.Padding = UDim.new(0,4)
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local Content = Instance.new("Frame", Main)
	Content.Size = UDim2.new(1, -142, 1, -50)
	Content.Position = UDim2.new(0,136,0,38)
	Content.BackgroundColor3 = Color3.fromRGB(10,10,12)
	Instance.new("UICorner", Content).CornerRadius = UDim.new(0,6)

	-- Danh sách tab mở rộng (thêm "🔧 Tools")
	local tabNames = {
		"📈 Tăng/Giảm",
		"👾 NPC",
		"🧱 Blocks",
		"📡 Remote Spy",
		"📦 Storage",
		"📊 Stats",
		"📜 Log",
		"📍 Waypoint",
		"🔧 Tools",
		"🛠 Console",
	}
	local tabs = {}
	for i, name in ipairs(tabNames) do
		local btn = Instance.new("TextButton", TabBar)
		btn.Size = UDim2.new(1, -8, 0, 30)
		btn.Text = name
		btn.BackgroundColor3 = Color3.fromRGB(22,22,26)
		btn.TextColor3 = Color3.fromRGB(150,150,160)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 9
		btn.TextXAlignment = Enum.TextXAlignment.Left
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

		local page = Instance.new("ScrollingFrame", Content)
		page.Size = UDim2.new(1, -10, 1, -10)
		page.Position = UDim2.new(0,5,0,5)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.CanvasSize = UDim2.new(0,0,0,0)
		page.ScrollBarThickness = 4
		local list = Instance.new("UIListLayout", page)
		list.Padding = UDim.new(0,4)

		tabs[name] = { btn = btn, page = page, list = list }

		btn.MouseButton1Click:Connect(function()
			for _, t in pairs(tabs) do
				t.page.Visible = false
				t.btn.BackgroundColor3 = Color3.fromRGB(22,22,26)
				t.btn.TextColor3 = Color3.fromRGB(150,150,160)
			end
			page.Visible = true
			btn.BackgroundColor3 = Color3.fromRGB(0,180,120)
			btn.TextColor3 = Color3.fromRGB(255,255,255)
			renderTab(name)
		end)
	end

	-- Chọn tab đầu
	local firstTab = tabNames[1]
	tabs[firstTab].btn.BackgroundColor3 = Color3.fromRGB(0,180,120)
	tabs[firstTab].btn.TextColor3 = Color3.fromRGB(255,255,255)
	tabs[firstTab].page.Visible = true

	-- Status Bar
	local StatusBar = Instance.new("Frame", Main)
	StatusBar.Size = UDim2.new(1, -12, 0, 24)
	StatusBar.Position = UDim2.new(0,6,1,-28)
	StatusBar.BackgroundColor3 = Color3.fromRGB(18,18,24)
	Instance.new("UICorner", StatusBar).CornerRadius = UDim.new(0,4)
	local StatusLabel = Instance.new("TextLabel", StatusBar)
	StatusLabel.Size = UDim2.new(1, -80, 1, 0)
	StatusLabel.Position = UDim2.new(0,5,0,0)
	StatusLabel.Text = "✅ Sẵn sàng"
	StatusLabel.TextColor3 = Color3.fromRGB(180,220,180)
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Font = Enum.Font.SourceSans
	StatusLabel.TextSize = 11
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

	local RefreshBtn = Instance.new("TextButton", StatusBar)
	RefreshBtn.Size = UDim2.new(0,60,0,20)
	RefreshBtn.Position = UDim2.new(1,-70,0,2)
	RefreshBtn.Text = "🔄"
	RefreshBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
	RefreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
	RefreshBtn.Font = Enum.Font.SourceSansBold
	RefreshBtn.TextSize = 12
	Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0,3)

	local cleanup = {}
	table.insert(cleanup, RefreshBtn.MouseButton1Click:Connect(function()
		refreshGameData(); renderAllTabs()
		StatusLabel.Text = "✅ Đã refresh - " .. os.date("%H:%M:%S")
	end))

	return {
		Gui = Gui, Main = Main, Tabs = tabs, TabNames = tabNames,
		StatusLabel = StatusLabel, Cleanup = cleanup, Content = Content,
	}
end

-- =====================================================================
-- RENDER HÀM CHI TIẾT (mỗi tab có thanh công cụ riêng)
-- =====================================================================
local function renderTab(tabName)
	local GD = Tookit.GameData
	local tab = Tookit.UI.Tabs[tabName]
	if not tab then return end
	local page = tab.page
	-- Xóa cũ
	for _, child in pairs(page:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	-- Hàm tạo thanh công cụ cho tab (tìm kiếm, lọc, hành động)
	local function createToolbar(yOffset)
		local tb = Instance.new("Frame", page)
		tb.Size = UDim2.new(1, 0, 0, 28)
		tb.Position = UDim2.new(0, 0, 0, yOffset or 0)
		tb.BackgroundTransparency = 1
		return tb
	end

	if tabName == "📈 Tăng/Giảm" then
		-- Thanh công cụ: ô tìm kiếm, step
		local tb = createToolbar(0)
		local searchBox = Instance.new("TextBox", tb)
		searchBox.Size = UDim2.new(0.2, 0, 1, -4)
		searchBox.PlaceholderText = "🔍 Lọc path..."
		searchBox.Text = ""
		searchBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
		searchBox.TextColor3 = Color3.fromRGB(255,255,255)
		searchBox.Font = Enum.Font.SourceSans
		searchBox.TextSize = 10
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,3)

		local stepBox = Instance.new("TextBox", tb)
		stepBox.Size = UDim2.new(0.08, 0, 1, -4)
		stepBox.Position = UDim2.new(0.22, 0, 0, 0)
		stepBox.PlaceholderText = "Step"
		stepBox.Text = "1"
		stepBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
		stepBox.TextColor3 = Color3.fromRGB(255,255,255)
		stepBox.Font = Enum.Font.SourceSans
		stepBox.TextSize = 10
		Instance.new("UICorner", stepBox).CornerRadius = UDim.new(0,3)

		-- Container cho danh sách values
		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0, 4)

		local function renderValues(filter, step)
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			step = tonumber(step) or 1
			filter = string.lower(filter or "")
			for path, data in pairs(GD.values) do
				if filter == "" or string.find(string.lower(path), filter) then
					local frame = Instance.new("Frame", listContainer)
					frame.Size = UDim2.new(1, -4, 0, 36)
					frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
					Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)

					local label = Instance.new("TextLabel", frame)
					label.Size = UDim2.new(0.45, 0, 1, 0)
					label.Position = UDim2.new(0.02, 0, 0, 0)
					label.Text = path .. " = " .. tostring(data.value)
					label.TextColor3 = Color3.fromRGB(200,200,200)
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.SourceSans
					label.TextSize = 9
					label.TextXAlignment = Enum.TextXAlignment.Left

					local incBtn = Instance.new("TextButton", frame)
					incBtn.Size = UDim2.new(0.06, 0, 0.7, 0)
					incBtn.Position = UDim2.new(0.48, 0, 0.15, 0)
					incBtn.Text = "+" .. step
					incBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
					incBtn.TextColor3 = Color3.fromRGB(255,255,255)
					incBtn.Font = Enum.Font.SourceSansBold
					incBtn.TextSize = 8
					Instance.new("UICorner", incBtn).CornerRadius = UDim.new(0,3)
					incBtn.MouseButton1Click:Connect(function()
						if data.obj and data.obj:IsA("NumberValue") then
							data.obj.Value = data.obj.Value + step
							refreshGameData(); renderTab("📈 Tăng/Giảm")
						end
					end)

					local decBtn = Instance.new("TextButton", frame)
					decBtn.Size = UDim2.new(0.06, 0, 0.7, 0)
					decBtn.Position = UDim2.new(0.56, 0, 0.15, 0)
					decBtn.Text = "-" .. step
					decBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
					decBtn.TextColor3 = Color3.fromRGB(255,255,255)
					decBtn.Font = Enum.Font.SourceSansBold
					decBtn.TextSize = 8
					Instance.new("UICorner", decBtn).CornerRadius = UDim.new(0,3)
					decBtn.MouseButton1Click:Connect(function()
						if data.obj and data.obj:IsA("NumberValue") then
							data.obj.Value = data.obj.Value - step
							refreshGameData(); renderTab("📈 Tăng/Giảm")
						end
					end)
				end
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		searchBox.Changed:Connect(function() renderValues(searchBox.Text, stepBox.Text) end)
		stepBox.Changed:Connect(function() renderValues(searchBox.Text, stepBox.Text) end)
		renderValues("", "1")

	elseif tabName == "👾 NPC" then
		-- Thanh công cụ: tìm, ESP all, Kill all, Refresh
		local tb = createToolbar(0)
		local searchBox = Instance.new("TextBox", tb)
		searchBox.Size = UDim2.new(0.2, 0, 1, -4)
		searchBox.PlaceholderText = "🔍 Tìm NPC..."
		searchBox.Text = ""
		searchBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
		searchBox.TextColor3 = Color3.fromRGB(255,255,255)
		searchBox.Font = Enum.Font.SourceSans
		searchBox.TextSize = 10
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,3)

		local espAllBtn = Instance.new("TextButton", tb)
		espAllBtn.Size = UDim2.new(0.12, 0, 1, -4)
		espAllBtn.Position = UDim2.new(0.22, 0, 0, 0)
		espAllBtn.Text = "ESP All: OFF"
		espAllBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		espAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
		espAllBtn.Font = Enum.Font.SourceSansBold
		espAllBtn.TextSize = 8
		Instance.new("UICorner", espAllBtn).CornerRadius = UDim.new(0,3)

		local killAllBtn = Instance.new("TextButton", tb)
		killAllBtn.Size = UDim2.new(0.1, 0, 1, -4)
		killAllBtn.Position = UDim2.new(0.36, 0, 0, 0)
		killAllBtn.Text = "💀 Kill All"
		killAllBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
		killAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
		killAllBtn.Font = Enum.Font.SourceSansBold
		killAllBtn.TextSize = 8
		Instance.new("UICorner", killAllBtn).CornerRadius = UDim.new(0,3)

		local refreshBtn = Instance.new("TextButton", tb)
		refreshBtn.Size = UDim2.new(0.06, 0, 1, -4)
		refreshBtn.Position = UDim2.new(0.48, 0, 0, 0)
		refreshBtn.Text = "🔄"
		refreshBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
		refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
		refreshBtn.Font = Enum.Font.SourceSansBold
		refreshBtn.TextSize = 10
		Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0, 4)

		local espAllState = false
		local espObjects = {}

		local function renderNPCs(filter)
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			-- Xóa ESP cũ
			for _, hl in pairs(espObjects) do safeCall(function() hl:Destroy() end) end
			espObjects = {}

			filter = string.lower(filter or "")
			for path, model in pairs(GD.npcs) do
				if filter == "" or string.find(string.lower(model.Name), filter) or string.find(string.lower(path), filter) then
					local hum = model:FindFirstChildOfClass("Humanoid")
					local hrp = getHRP(model)
					local pos = hrp and hrp.Position or Vector3.new(0,0,0)
					local health = hum and math.floor(hum.Health) or 0
					local maxHealth = hum and math.floor(hum.MaxHealth) or 0

					local frame = Instance.new("Frame", listContainer)
					frame.Size = UDim2.new(1, -4, 0, 34)
					frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
					Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)

					local label = Instance.new("TextLabel", frame)
					label.Size = UDim2.new(0.4, 0, 1, 0)
					label.Position = UDim2.new(0.02, 0, 0, 0)
					label.Text = string.format("%s | HP: %d/%d", model.Name, health, maxHealth)
					label.TextColor3 = Color3.fromRGB(200,255,200)
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.SourceSans
					label.TextSize = 9
					label.TextXAlignment = Enum.TextXAlignment.Left

					-- Nút ESP riêng
					local espBtn = Instance.new("TextButton", frame)
					espBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					espBtn.Position = UDim2.new(0.44, 0, 0.15, 0)
					espBtn.Text = "ESP"
					espBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
					espBtn.TextColor3 = Color3.fromRGB(255,255,255)
					espBtn.Font = Enum.Font.SourceSansBold
					espBtn.TextSize = 7
					Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,3)
					local espState = false
					local highlight = nil
					espBtn.MouseButton1Click:Connect(function()
						espState = not espState
						espBtn.BackgroundColor3 = espState and Color3.fromRGB(0,140,70) or Color3.fromRGB(50,50,50)
						if espState then
							highlight = Instance.new("Highlight", model)
							highlight.FillColor = Color3.fromRGB(255,100,100)
							highlight.OutlineColor = Color3.fromRGB(255,255,255)
							table.insert(espObjects, highlight)
						else
							if highlight then highlight:Destroy(); highlight = nil end
						end
					end)

					-- Teleport
					local tpBtn = Instance.new("TextButton", frame)
					tpBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					tpBtn.Position = UDim2.new(0.54, 0, 0.15, 0)
					tpBtn.Text = "TP"
					tpBtn.BackgroundColor3 = Color3.fromRGB(0,120,70)
					tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
					tpBtn.Font = Enum.Font.SourceSansBold
					tpBtn.TextSize = 7
					Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,3)
					tpBtn.MouseButton1Click:Connect(function()
						local myHrp = getHRP(S.Players.LocalPlayer.Character)
						if myHrp and hrp then myHrp.CFrame = hrp.CFrame * CFrame.new(0,2,3) end
					end)

					-- Scripts
					local scripts = {}
					for _, d in pairs(model:GetDescendants()) do
						if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
							table.insert(scripts, d)
						end
					end
					if #scripts > 0 then
						local scrBtn = Instance.new("TextButton", frame)
						scrBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
						scrBtn.Position = UDim2.new(0.64, 0, 0.15, 0)
						scrBtn.Text = "📜" .. #scripts
						scrBtn.BackgroundColor3 = Color3.fromRGB(0,150,150)
						scrBtn.TextColor3 = Color3.fromRGB(255,255,255)
						scrBtn.Font = Enum.Font.SourceSansBold
						scrBtn.TextSize = 7
						Instance.new("UICorner", scrBtn).CornerRadius = UDim.new(0,3)
						scrBtn.MouseButton1Click:Connect(function()
							local popup = Instance.new("Frame", Tookit.UI.Gui)
							popup.Size = UDim2.new(0, 500, 0, 350)
							popup.Position = UDim2.new(0.5, -250, 0.5, -175)
							popup.BackgroundColor3 = Color3.fromRGB(20,20,30)
							Instance.new("UICorner", popup).CornerRadius = UDim.new(0,8)
							local close = Instance.new("TextButton", popup)
							close.Size = UDim2.new(0,30,0,30)
							close.Position = UDim2.new(1,-35,0,5)
							close.Text = "✕"
							close.BackgroundColor3 = Color3.fromRGB(50,50,50)
							close.TextColor3 = Color3.fromRGB(255,255,255)
							close.Font = Enum.Font.SourceSansBold
							close.TextSize = 12
							close.MouseButton1Click:Connect(function() popup:Destroy() end)
							local title = Instance.new("TextLabel", popup)
							title.Size = UDim2.new(0.8, 0, 0, 30)
							title.Position = UDim2.new(0.05, 0, 0, 0)
							title.Text = "Scripts trong " .. model.Name
							title.TextColor3 = Color3.fromRGB(0,255,200)
							title.BackgroundTransparency = 1
							title.Font = Enum.Font.SourceSansBold
							title.TextSize = 12
							local scroll = Instance.new("ScrollingFrame", popup)
							scroll.Size = UDim2.new(0.95, 0, 0.85, 0)
							scroll.Position = UDim2.new(0.025, 0, 0.1, 0)
							scroll.BackgroundColor3 = Color3.fromRGB(10,10,15)
							scroll.CanvasSize = UDim2.new(0,0,0,0)
							scroll.ScrollBarThickness = 4
							local lay = Instance.new("UIListLayout", scroll)
							lay.Padding = UDim.new(0,4)
							for _, scr in ipairs(scripts) do
								local f = Instance.new("Frame", scroll)
								f.Size = UDim2.new(1, -5, 0, 24)
								f.BackgroundColor3 = Color3.fromRGB(25,25,30)
								Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
								local lb = Instance.new("TextLabel", f)
								lb.Size = UDim2.new(0.5,0,1,0)
								lb.Position = UDim2.new(0.02,0,0,0)
								lb.Text = scr.Name .. " (" .. scr.ClassName .. ")"
								lb.TextColor3 = Color3.fromRGB(200,200,200)
								lb.BackgroundTransparency = 1
								lb.Font = Enum.Font.SourceSans
								lb.TextSize = 9
								local copy = Instance.new("TextButton", f)
								copy.Size = UDim2.new(0.35,0,0.8,0)
								copy.Position = UDim2.new(0.55,0,0.1,0)
								copy.Text = "📋 Copy"
								copy.BackgroundColor3 = Color3.fromRGB(0,120,180)
								copy.TextColor3 = Color3.fromRGB(255,255,255)
								copy.Font = Enum.Font.SourceSansBold
								copy.TextSize = 8
								Instance.new("UICorner", copy).CornerRadius = UDim.new(0,3)
								copy.MouseButton1Click:Connect(function()
									copyToClipboard(getScriptCode(scr))
								end)
							end
							scroll.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y)
						end)
					end
				end
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		searchBox.Changed:Connect(function() renderNPCs(searchBox.Text) end)
		refreshBtn.MouseButton1Click:Connect(function() refreshGameData(); renderNPCs(searchBox.Text) end)

		espAllBtn.MouseButton1Click:Connect(function()
			espAllState = not espAllState
			espAllBtn.Text = espAllState and "ESP All: ON" or "ESP All: OFF"
			espAllBtn.BackgroundColor3 = espAllState and Color3.fromRGB(0,140,70) or Color3.fromRGB(50,50,50)
			-- Bật/tắt ESP cho tất cả NPC hiện có (cần render lại)
			renderNPCs(searchBox.Text)
			-- Áp dụng highlight cho tất cả
			if espAllState then
				for path, model in pairs(GD.npcs) do
					local hl = Instance.new("Highlight", model)
					hl.FillColor = Color3.fromRGB(255,100,100)
					hl.OutlineColor = Color3.fromRGB(255,255,255)
					table.insert(espObjects, hl)
				end
			else
				for _, hl in pairs(espObjects) do safeCall(function() hl:Destroy() end) end
				espObjects = {}
			end
		end)

		killAllBtn.MouseButton1Click:Connect(function()
			for _, model in pairs(GD.npcs) do
				local hum = model:FindFirstChildOfClass("Humanoid")
				if hum then hum.Health = 0 end
			end
			refreshGameData(); renderNPCs(searchBox.Text)
		end)

		renderNPCs("")

	elseif tabName == "🧱 Blocks" then
		-- Tương tự NPC với ESP All, Delete All, Teleport
		local tb = createToolbar(0)
		local searchBox = Instance.new("TextBox", tb)
		searchBox.Size = UDim2.new(0.2, 0, 1, -4)
		searchBox.PlaceholderText = "🔍 Tìm Block..."
		searchBox.Text = ""
		searchBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
		searchBox.TextColor3 = Color3.fromRGB(255,255,255)
		searchBox.Font = Enum.Font.SourceSans
		searchBox.TextSize = 10
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,3)

		local espAllBtn = Instance.new("TextButton", tb)
		espAllBtn.Size = UDim2.new(0.12, 0, 1, -4)
		espAllBtn.Position = UDim2.new(0.22, 0, 0, 0)
		espAllBtn.Text = "ESP All: OFF"
		espAllBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		espAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
		espAllBtn.Font = Enum.Font.SourceSansBold
		espAllBtn.TextSize = 8
		Instance.new("UICorner", espAllBtn).CornerRadius = UDim.new(0,3)

		local deleteAllBtn = Instance.new("TextButton", tb)
		deleteAllBtn.Size = UDim2.new(0.1, 0, 1, -4)
		deleteAllBtn.Position = UDim2.new(0.36, 0, 0, 0)
		deleteAllBtn.Text = "🗑️ Xóa All"
		deleteAllBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
		deleteAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
		deleteAllBtn.Font = Enum.Font.SourceSansBold
		deleteAllBtn.TextSize = 8
		Instance.new("UICorner", deleteAllBtn).CornerRadius = UDim.new(0,3)

		local refreshBtn = Instance.new("TextButton", tb)
		refreshBtn.Size = UDim2.new(0.06, 0, 1, -4)
		refreshBtn.Position = UDim2.new(0.48, 0, 0, 0)
		refreshBtn.Text = "🔄"
		refreshBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
		refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
		refreshBtn.Font = Enum.Font.SourceSansBold
		refreshBtn.TextSize = 10
		Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0, 4)

		local espAllState = false
		local espObjects = {}

		local function renderBlocks(filter)
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			for _, hl in pairs(espObjects) do safeCall(function() hl:Destroy() end) end
			espObjects = {}

			filter = string.lower(filter or "")
			for path, obj in pairs(GD.blocks) do
				if filter == "" or string.find(string.lower(obj.Name), filter) or string.find(string.lower(path), filter) then
					local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position) or Vector3.new(0,0,0)
					local frame = Instance.new("Frame", listContainer)
					frame.Size = UDim2.new(1, -4, 0, 28)
					frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
					Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)

					local label = Instance.new("TextLabel", frame)
					label.Size = UDim2.new(0.4, 0, 1, 0)
					label.Position = UDim2.new(0.02, 0, 0, 0)
					label.Text = string.format("%s | (%.1f, %.1f, %.1f)", obj.Name, pos.X, pos.Y, pos.Z)
					label.TextColor3 = Color3.fromRGB(200,200,200)
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.SourceSans
					label.TextSize = 9
					label.TextXAlignment = Enum.TextXAlignment.Left

					local espBtn = Instance.new("TextButton", frame)
					espBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					espBtn.Position = UDim2.new(0.44, 0, 0.15, 0)
					espBtn.Text = "ESP"
					espBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
					espBtn.TextColor3 = Color3.fromRGB(255,255,255)
					espBtn.Font = Enum.Font.SourceSansBold
					espBtn.TextSize = 7
					Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,3)
					local espState = false
					local highlight = nil
					espBtn.MouseButton1Click:Connect(function()
						espState = not espState
						espBtn.BackgroundColor3 = espState and Color3.fromRGB(0,140,70) or Color3.fromRGB(50,50,50)
						if espState then
							highlight = Instance.new("Highlight", obj)
							highlight.FillColor = Color3.fromRGB(0,255,0)
							highlight.OutlineColor = Color3.fromRGB(255,255,255)
							table.insert(espObjects, highlight)
						else
							if highlight then highlight:Destroy(); highlight = nil end
						end
					end)

					local tpBtn = Instance.new("TextButton", frame)
					tpBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					tpBtn.Position = UDim2.new(0.54, 0, 0.15, 0)
					tpBtn.Text = "TP"
					tpBtn.BackgroundColor3 = Color3.fromRGB(0,120,70)
					tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
					tpBtn.Font = Enum.Font.SourceSansBold
					tpBtn.TextSize = 7
					Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,3)
					tpBtn.MouseButton1Click:Connect(function()
						local myHrp = getHRP(S.Players.LocalPlayer.Character)
						if myHrp then myHrp.CFrame = CFrame.new(pos + Vector3.new(0,2,0)) end
					end)

					local copyBtn = Instance.new("TextButton", frame)
					copyBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					copyBtn.Position = UDim2.new(0.64, 0, 0.15, 0)
					copyBtn.Text = "📋"
					copyBtn.BackgroundColor3 = Color3.fromRGB(0,110,170)
					copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
					copyBtn.Font = Enum.Font.SourceSansBold
					copyBtn.TextSize = 7
					Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,3)
					copyBtn.MouseButton1Click:Connect(function()
						copyToClipboard(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
					end)

					local delBtn = Instance.new("TextButton", frame)
					delBtn.Size = UDim2.new(0.06, 0, 0.7, 0)
					delBtn.Position = UDim2.new(0.74, 0, 0.15, 0)
					delBtn.Text = "✕"
					delBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
					delBtn.TextColor3 = Color3.fromRGB(255,255,255)
					delBtn.Font = Enum.Font.SourceSansBold
					delBtn.TextSize = 7
					Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,3)
					delBtn.MouseButton1Click:Connect(function()
						obj:Destroy()
						refreshGameData(); renderBlocks(searchBox.Text)
					end)
				end
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		searchBox.Changed:Connect(function() renderBlocks(searchBox.Text) end)
		refreshBtn.MouseButton1Click:Connect(function() refreshGameData(); renderBlocks(searchBox.Text) end)

		espAllBtn.MouseButton1Click:Connect(function()
			espAllState = not espAllState
			espAllBtn.Text = espAllState and "ESP All: ON" or "ESP All: OFF"
			espAllBtn.BackgroundColor3 = espAllState and Color3.fromRGB(0,140,70) or Color3.fromRGB(50,50,50)
			renderBlocks(searchBox.Text)
			if espAllState then
				for _, obj in pairs(GD.blocks) do
					local hl = Instance.new("Highlight", obj)
					hl.FillColor = Color3.fromRGB(0,255,0)
					hl.OutlineColor = Color3.fromRGB(255,255,255)
					table.insert(espObjects, hl)
				end
			else
				for _, hl in pairs(espObjects) do safeCall(function() hl:Destroy() end) end
				espObjects = {}
			end
		end)

		deleteAllBtn.MouseButton1Click:Connect(function()
			for _, obj in pairs(GD.blocks) do
				safeCall(function() obj:Destroy() end)
			end
			refreshGameData(); renderBlocks(searchBox.Text)
		end)

		renderBlocks("")

	elseif tabName == "📡 Remote Spy" then
		-- Remote Spy với hook thực tế và replay
		local tb = createToolbar(0)
		local spyToggle = Instance.new("TextButton", tb)
		spyToggle.Size = UDim2.new(0.1, 0, 1, -4)
		spyToggle.Text = "📡 Spy: OFF"
		spyToggle.BackgroundColor3 = Color3.fromRGB(140,35,35)
		spyToggle.TextColor3 = Color3.fromRGB(255,255,255)
		spyToggle.Font = Enum.Font.SourceSansBold
		spyToggle.TextSize = 9
		Instance.new("UICorner", spyToggle).CornerRadius = UDim.new(0,3)

		local clearBtn = Instance.new("TextButton", tb)
		clearBtn.Size = UDim2.new(0.08, 0, 1, -4)
		clearBtn.Position = UDim2.new(0.12, 0, 0, 0)
		clearBtn.Text = "🗑️ Clear"
		clearBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
		clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
		clearBtn.Font = Enum.Font.SourceSansBold
		clearBtn.TextSize = 9
		Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,3)

		local copyAllBtn = Instance.new("TextButton", tb)
		copyAllBtn.Size = UDim2.new(0.08, 0, 1, -4)
		copyAllBtn.Position = UDim2.new(0.22, 0, 0, 0)
		copyAllBtn.Text = "📋 Copy"
		copyAllBtn.BackgroundColor3 = Color3.fromRGB(0,110,170)
		copyAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
		copyAllBtn.Font = Enum.Font.SourceSansBold
		copyAllBtn.TextSize = 9
		Instance.new("UICorner", copyAllBtn).CornerRadius = UDim.new(0,3)

		local filterBox = Instance.new("TextBox", tb)
		filterBox.Size = UDim2.new(0.15, 0, 1, -4)
		filterBox.Position = UDim2.new(0.32, 0, 0, 0)
		filterBox.PlaceholderText = "🔍 Lọc remote..."
		filterBox.Text = ""
		filterBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
		filterBox.TextColor3 = Color3.fromRGB(255,255,255)
		filterBox.Font = Enum.Font.SourceSans
		filterBox.TextSize = 9
		Instance.new("UICorner", filterBox).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0, 4)

		local spyActive = false
		local remoteLogs = {}
		local remoteCallCounts = {}
		local remoteLastArgs = {}

		-- Hook Remote
		local function setupHook()
			local rawMeta = getrawmetatable or debug.getmetatable
			if rawMeta and setreadonly then
				local gmt = rawMeta(game)
				local oldNamecall = gmt.__namecall
				setreadonly(gmt, false)
				gmt.__namecall = newcclosure(function(self, ...)
					local method = getnamecallmethod()
					if spyActive and (method == "FireServer" or method == "fireServer" or method == "InvokeServer" or method == "invokeServer") then
						if self and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
							local args = {...}
							local remoteName = self.Name
							local filter = string.lower(filterBox.Text or "")
							if filter == "" or string.find(string.lower(remoteName), filter) then
								-- Log
								local id = self:GetFullName()
								remoteCallCounts[id] = (remoteCallCounts[id] or 0) + 1
								remoteLastArgs[id] = args
								table.insert(remoteLogs, 1, {
									time = os.date("%H:%M:%S"),
									remoteName = remoteName,
									remoteClass = self.ClassName,
									method = method,
									args = args,
									count = remoteCallCounts[id],
									id = id,
									ref = self,
								})
								if #remoteLogs > 200 then table.remove(remoteLogs) end
								-- Render lại
								renderRemoteLogs()
							end
						end
					end
					return oldNamecall(self, ...)
				end)
				setreadonly(gmt, true)
			end
		end
		setupHook()

		local function renderRemoteLogs()
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			local filter = string.lower(filterBox.Text or "")
			for _, log in ipairs(remoteLogs) do
				if filter == "" or string.find(string.lower(log.remoteName), filter) or string.find(string.lower(log.method), filter) then
					local frame = Instance.new("Frame", listContainer)
					frame.Size = UDim2.new(1, -4, 0, 28)
					frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
					Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)

					local label = Instance.new("TextLabel", frame)
					label.Size = UDim2.new(0.4, 0, 1, 0)
					label.Position = UDim2.new(0.02, 0, 0, 0)
					label.Text = string.format("[%s] %s | %s (x%d)", log.time, log.remoteName, log.method, log.count)
					label.TextColor3 = Color3.fromRGB(255,200,100)
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.SourceSans
					label.TextSize = 9
					label.TextXAlignment = Enum.TextXAlignment.Left

					-- Replay
					local replayBtn = Instance.new("TextButton", frame)
					replayBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
					replayBtn.Position = UDim2.new(0.44, 0, 0.15, 0)
					replayBtn.Text = "Replay"
					replayBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
					replayBtn.TextColor3 = Color3.fromRGB(255,255,255)
					replayBtn.Font = Enum.Font.SourceSansBold
					replayBtn.TextSize = 7
					Instance.new("UICorner", replayBtn).CornerRadius = UDim.new(0,3)
					replayBtn.MouseButton1Click:Connect(function()
						local remote = log.ref
						if remote and remote.Parent then
							local args = remoteLastArgs[log.id] or {}
							safeCall(function()
								if remote:IsA("RemoteEvent") then remote:FireServer(unpack(args))
								elseif remote:IsA("RemoteFunction") then remote:InvokeServer(unpack(args)) end
							end)
						end
					end)

					-- Copy args
					local copyArgsBtn = Instance.new("TextButton", frame)
					copyArgsBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					copyArgsBtn.Position = UDim2.new(0.56, 0, 0.15, 0)
					copyArgsBtn.Text = "📋"
					copyArgsBtn.BackgroundColor3 = Color3.fromRGB(0,110,170)
					copyArgsBtn.TextColor3 = Color3.fromRGB(255,255,255)
					copyArgsBtn.Font = Enum.Font.SourceSansBold
					copyArgsBtn.TextSize = 7
					Instance.new("UICorner", copyArgsBtn).CornerRadius = UDim.new(0,3)
					copyArgsBtn.MouseButton1Click:Connect(function()
						local args = remoteLastArgs[log.id] or {}
						copyToClipboard(serializeArgs(args))
					end)

					-- Block
					local blockBtn = Instance.new("TextButton", frame)
					blockBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					blockBtn.Position = UDim2.new(0.66, 0, 0.15, 0)
					blockBtn.Text = "🚫"
					blockBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
					blockBtn.TextColor3 = Color3.fromRGB(255,255,255)
					blockBtn.Font = Enum.Font.SourceSansBold
					blockBtn.TextSize = 7
					Instance.new("UICorner", blockBtn).CornerRadius = UDim.new(0,3)
					blockBtn.MouseButton1Click:Connect(function()
						-- Block bằng cách thêm vào blacklist (đơn giản: xóa khỏi log)
						table.remove(remoteLogs, table.find(remoteLogs, log))
						renderRemoteLogs()
					end)
				end
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		spyToggle.MouseButton1Click:Connect(function()
			spyActive = not spyActive
			spyToggle.Text = spyActive and "📡 Spy: ON" or "📡 Spy: OFF"
			spyToggle.BackgroundColor3 = spyActive and Color3.fromRGB(0,140,70) or Color3.fromRGB(140,35,35)
		end)

		clearBtn.MouseButton1Click:Connect(function()
			remoteLogs = {}
			renderRemoteLogs()
		end)

		copyAllBtn.MouseButton1Click:Connect(function()
			local text = ""
			for _, log in ipairs(remoteLogs) do
				text = text .. string.format("[%s] %s | %s (x%d) Args: %s\n", log.time, log.remoteName, log.method, log.count, serializeArgs(log.args))
			end
			copyToClipboard(text)
		end)

		filterBox.Changed:Connect(renderRemoteLogs)
		renderRemoteLogs()

	elseif tabName == "📦 Storage" then
		local tb = createToolbar(0)
		local searchBox = Instance.new("TextBox", tb)
		searchBox.Size = UDim2.new(0.25, 0, 1, -4)
		searchBox.PlaceholderText = "🔍 Tìm trong Storage..."
		searchBox.Text = ""
		searchBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
		searchBox.TextColor3 = Color3.fromRGB(255,255,255)
		searchBox.Font = Enum.Font.SourceSans
		searchBox.TextSize = 10
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,3)

		local refreshBtn = Instance.new("TextButton", tb)
		refreshBtn.Size = UDim2.new(0.06, 0, 1, -4)
		refreshBtn.Position = UDim2.new(0.27, 0, 0, 0)
		refreshBtn.Text = "🔄"
		refreshBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
		refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
		refreshBtn.Font = Enum.Font.SourceSansBold
		refreshBtn.TextSize = 10
		Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0,4)

		local function renderStorage(filter)
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			filter = string.lower(filter or "")
			for path, obj in pairs(GD.storageItems) do
				if filter == "" or string.find(string.lower(obj.Name), filter) or string.find(string.lower(path), filter) then
					local frame = Instance.new("Frame", listContainer)
					frame.Size = UDim2.new(1, -4, 0, 26)
					frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
					Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)

					local label = Instance.new("TextLabel", frame)
					label.Size = UDim2.new(0.5, 0, 1, 0)
					label.Position = UDim2.new(0.02, 0, 0, 0)
					label.Text = string.format("📦 %s (%s)", obj.Name, obj.ClassName)
					label.TextColor3 = Color3.fromRGB(200,200,200)
					label.BackgroundTransparency = 1
					label.Font = Enum.Font.SourceSans
					label.TextSize = 9
					label.TextXAlignment = Enum.TextXAlignment.Left

					local cloneBtn = Instance.new("TextButton", frame)
					cloneBtn.Size = UDim2.new(0.12, 0, 0.7, 0)
					cloneBtn.Position = UDim2.new(0.55, 0, 0.15, 0)
					cloneBtn.Text = "Clone"
					cloneBtn.BackgroundColor3 = Color3.fromRGB(0,120,180)
					cloneBtn.TextColor3 = Color3.fromRGB(255,255,255)
					cloneBtn.Font = Enum.Font.SourceSansBold
					cloneBtn.TextSize = 8
					Instance.new("UICorner", cloneBtn).CornerRadius = UDim.new(0,3)
					cloneBtn.MouseButton1Click:Connect(function()
						local clone = obj:Clone()
						clone.Parent = S.Workspace
						refreshGameData(); renderStorage(searchBox.Text)
					end)

					local copyBtn = Instance.new("TextButton", frame)
					copyBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
					copyBtn.Position = UDim2.new(0.69, 0, 0.15, 0)
					copyBtn.Text = "📋 Path"
					copyBtn.BackgroundColor3 = Color3.fromRGB(0,110,170)
					copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
					copyBtn.Font = Enum.Font.SourceSansBold
					copyBtn.TextSize = 7
					Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,3)
					copyBtn.MouseButton1Click:Connect(function()
						copyToClipboard(path)
					end)
				end
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		searchBox.Changed:Connect(function() renderStorage(searchBox.Text) end)
		refreshBtn.MouseButton1Click:Connect(function() refreshGameData(); renderStorage(searchBox.Text) end)
		renderStorage("")

	elseif tabName == "📊 Stats" then
		-- Hiển thị thống kê + ping/fps/memory
		local stats = {
			["👥 Players"] = #S.Players:GetPlayers(),
			["📦 Workspace Instances"] = GD.workspace.totalInstances,
			["🧱 Parts"] = GD.workspace.parts,
			["📦 Models"] = GD.workspace.models,
			["📜 Scripts"] = GD.workspace.scripts,
			["💎 Number Values"] = tableCount(GD.values),
			["👾 NPCs"] = tableCount(GD.npcs),
			["🧱 Blocks"] = tableCount(GD.blocks),
			["📡 RemoteEvents"] = tableCount(GD.remoteEvents),
			["📡 RemoteFunctions"] = tableCount(GD.remoteFunctions),
			["📦 Storage Items"] = tableCount(GD.storageItems),
			["📜 Logs"] = #GD.logs,
		}
		for label, value in pairs(stats) do
			local frame = Instance.new("Frame", page)
			frame.Size = UDim2.new(1, -4, 0, 24)
			frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)
			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(0.8, 0, 1, 0)
			lbl.Position = UDim2.new(0.02, 0, 0, 0)
			lbl.Text = label .. ": " .. tostring(value)
			lbl.TextColor3 = Color3.fromRGB(200,255,200)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.SourceSans
			lbl.TextSize = 10
			lbl.TextXAlignment = Enum.TextXAlignment.Left
		end

		-- Thêm thông tin thời gian thực (ping, fps, memory)
		local function addLiveStats()
			local ping = 0
			if game:GetService("Stats") and game.Stats:FindFirstChild("Network") then
				local net = game.Stats.Network
				if net and net:FindFirstChild("Ping") then
					ping = math.floor(net.Ping.Value * 1000)
				end
			end
			local mem = pcall(game.GetMemoryUsage, game) and game:GetMemoryUsage() or 0
			local fps = 60 -- placeholder

			local frame = Instance.new("Frame", page)
			frame.Size = UDim2.new(1, -4, 0, 24)
			frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)
			local lbl = Instance.new("TextLabel", frame)
			lbl.Size = UDim2.new(0.8, 0, 1, 0)
			lbl.Position = UDim2.new(0.02, 0, 0, 0)
			lbl.Text = string.format("📡 Ping: %dms | 🧠 Memory: %.1f MB | 🎮 FPS: ~%d", ping, mem/1024, fps)
			lbl.TextColor3 = Color3.fromRGB(200,255,200)
			lbl.BackgroundTransparency = 1
			lbl.Font = Enum.Font.SourceSans
			lbl.TextSize = 10
			lbl.TextXAlignment = Enum.TextXAlignment.Left
		end
		addLiveStats()
		page.CanvasSize = UDim2.new(0,0,0, page.UIListLayout.AbsoluteContentSize.Y + 10)

	elseif tabName == "📜 Log" then
		local tb = createToolbar(0)
		local clearBtn = Instance.new("TextButton", tb)
		clearBtn.Size = UDim2.new(0.08, 0, 1, -4)
		clearBtn.Text = "🗑️ Clear"
		clearBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
		clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
		clearBtn.Font = Enum.Font.SourceSansBold
		clearBtn.TextSize = 9
		Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,3)

		local copyBtn = Instance.new("TextButton", tb)
		copyBtn.Size = UDim2.new(0.08, 0, 1, -4)
		copyBtn.Position = UDim2.new(0.10, 0, 0, 0)
		copyBtn.Text = "📋 Copy"
		copyBtn.BackgroundColor3 = Color3.fromRGB(0,110,170)
		copyBtn.TextColor3 = Color3.fromRGB(255,255,255)
		copyBtn.Font = Enum.Font.SourceSansBold
		copyBtn.TextSize = 9
		Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0,4)

		local function renderLogs()
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			for _, entry in ipairs(GD.logs) do
				local frame = Instance.new("Frame", listContainer)
				frame.Size = UDim2.new(1, -4, 0, 22)
				frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
				Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)
				local lbl = Instance.new("TextLabel", frame)
				lbl.Size = UDim2.new(1, -4, 1, 0)
				lbl.Position = UDim2.new(0.02, 0, 0, 0)
				lbl.Text = string.format("[%s] %s: %s", entry.time, entry.type, entry.message)
				lbl.TextColor3 = Color3.fromRGB(200,200,200)
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.SourceSans
				lbl.TextSize = 9
				lbl.TextXAlignment = Enum.TextXAlignment.Left
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		clearBtn.MouseButton1Click:Connect(function()
			GD.logs = {}
			renderLogs()
		end)

		copyBtn.MouseButton1Click:Connect(function()
			local text = ""
			for _, entry in ipairs(GD.logs) do
				text = text .. string.format("[%s] %s: %s\n", entry.time, entry.type, entry.message)
			end
			copyToClipboard(text)
		end)

		renderLogs()

	elseif tabName == "📍 Waypoint" then
		local tb = createToolbar(0)
		local addBtn = Instance.new("TextButton", tb)
		addBtn.Size = UDim2.new(0.15, 0, 1, -4)
		addBtn.Text = "➕ Lưu vị trí"
		addBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
		addBtn.TextColor3 = Color3.fromRGB(255,255,255)
		addBtn.Font = Enum.Font.SourceSansBold
		addBtn.TextSize = 9
		Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0,3)

		local exportBtn = Instance.new("TextButton", tb)
		exportBtn.Size = UDim2.new(0.1, 0, 1, -4)
		exportBtn.Position = UDim2.new(0.17, 0, 0, 0)
		exportBtn.Text = "📤 Export"
		exportBtn.BackgroundColor3 = Color3.fromRGB(0,110,170)
		exportBtn.TextColor3 = Color3.fromRGB(255,255,255)
		exportBtn.Font = Enum.Font.SourceSansBold
		exportBtn.TextSize = 9
		Instance.new("UICorner", exportBtn).CornerRadius = UDim.new(0,3)

		local importBtn = Instance.new("TextButton", tb)
		importBtn.Size = UDim2.new(0.1, 0, 1, -4)
		importBtn.Position = UDim2.new(0.29, 0, 0, 0)
		importBtn.Text = "📥 Import"
		importBtn.BackgroundColor3 = Color3.fromRGB(0,150,100)
		importBtn.TextColor3 = Color3.fromRGB(255,255,255)
		importBtn.Font = Enum.Font.SourceSansBold
		importBtn.TextSize = 9
		Instance.new("UICorner", importBtn).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0,4)

		local function renderWaypoints()
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			for i, wp in ipairs(GD.waypoints) do
				local frame = Instance.new("Frame", listContainer)
				frame.Size = UDim2.new(1, -4, 0, 26)
				frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
				Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)

				local lbl = Instance.new("TextLabel", frame)
				lbl.Size = UDim2.new(0.4, 0, 1, 0)
				lbl.Position = UDim2.new(0.02, 0, 0, 0)
				lbl.Text = string.format("%s: (%.1f, %.1f, %.1f)", wp.name, wp.cframe.X, wp.cframe.Y, wp.cframe.Z)
				lbl.TextColor3 = Color3.fromRGB(200,200,200)
				lbl.BackgroundTransparency = 1
				lbl.Font = Enum.Font.SourceSans
				lbl.TextSize = 9
				lbl.TextXAlignment = Enum.TextXAlignment.Left

				local tpBtn = Instance.new("TextButton", frame)
				tpBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
				tpBtn.Position = UDim2.new(0.44, 0, 0.15, 0)
				tpBtn.Text = "TP"
				tpBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
				tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
				tpBtn.Font = Enum.Font.SourceSansBold
				tpBtn.TextSize = 8
				Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,3)
				tpBtn.MouseButton1Click:Connect(function()
					local hrp = getHRP(S.Players.LocalPlayer.Character)
					if hrp then hrp.CFrame = wp.cframe end
				end)

				local tweenBtn = Instance.new("TextButton", frame)
				tweenBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
				tweenBtn.Position = UDim2.new(0.54, 0, 0.15, 0)
				tweenBtn.Text = "Bay"
				tweenBtn.BackgroundColor3 = Color3.fromRGB(180,90,0)
				tweenBtn.TextColor3 = Color3.fromRGB(255,255,255)
				tweenBtn.Font = Enum.Font.SourceSansBold
				tweenBtn.TextSize = 8
				Instance.new("UICorner", tweenBtn).CornerRadius = UDim.new(0,3)
				tweenBtn.MouseButton1Click:Connect(function()
					local hrp = getHRP(S.Players.LocalPlayer.Character)
					if hrp then
						local d = (hrp.Position - wp.cframe.Position).Magnitude
						S.TweenService:Create(hrp, TweenInfo.new(d/30, Enum.EasingStyle.Linear), {CFrame = wp.cframe}):Play()
					end
				end)

				local delBtn = Instance.new("TextButton", frame)
				delBtn.Size = UDim2.new(0.06, 0, 0.7, 0)
				delBtn.Position = UDim2.new(0.64, 0, 0.15, 0)
				delBtn.Text = "✕"
				delBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
				delBtn.TextColor3 = Color3.fromRGB(255,255,255)
				delBtn.Font = Enum.Font.SourceSansBold
				delBtn.TextSize = 8
				Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0,3)
				delBtn.MouseButton1Click:Connect(function()
					table.remove(GD.waypoints, i)
					renderWaypoints()
				end)
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		addBtn.MouseButton1Click:Connect(function()
			local hrp = getHRP(S.Players.LocalPlayer.Character)
			if hrp then
				local name = "WP" .. (#GD.waypoints + 1)
				table.insert(GD.waypoints, { name = name, cframe = hrp.CFrame })
				renderWaypoints()
			end
		end)

		exportBtn.MouseButton1Click:Connect(function()
			local data = {}
			for _, wp in ipairs(GD.waypoints) do
				table.insert(data, { name = wp.name, x = wp.cframe.X, y = wp.cframe.Y, z = wp.cframe.Z })
			end
			copyToClipboard(S.HttpService:JSONEncode(data))
		end)

		importBtn.MouseButton1Click:Connect(function()
			if getclipboard then
				local raw = getclipboard()
				local success, data = pcall(S.HttpService.JSONDecode, S.HttpService, raw)
				if success and type(data) == "table" then
					GD.waypoints = {}
					for _, item in ipairs(data) do
						table.insert(GD.waypoints, { name = item.name or "", cframe = CFrame.new(item.x or 0, item.y or 0, item.z or 0) })
					end
					renderWaypoints()
				end
			end
		end)

		renderWaypoints()

	elseif tabName == "🔧 Tools" then
		-- Quản lý tool: backpack, character
		local tb = createToolbar(0)
		local refreshBtn = Instance.new("TextButton", tb)
		refreshBtn.Size = UDim2.new(0.06, 0, 1, -4)
		refreshBtn.Text = "🔄"
		refreshBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
		refreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
		refreshBtn.Font = Enum.Font.SourceSansBold
		refreshBtn.TextSize = 10
		Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0,3)

		local equipAllBtn = Instance.new("TextButton", tb)
		equipAllBtn.Size = UDim2.new(0.12, 0, 1, -4)
		equipAllBtn.Position = UDim2.new(0.08, 0, 0, 0)
		equipAllBtn.Text = "⚔️ Equip All"
		equipAllBtn.BackgroundColor3 = Color3.fromRGB(0,120,180)
		equipAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
		equipAllBtn.Font = Enum.Font.SourceSansBold
		equipAllBtn.TextSize = 8
		Instance.new("UICorner", equipAllBtn).CornerRadius = UDim.new(0,3)

		local dropAllBtn = Instance.new("TextButton", tb)
		dropAllBtn.Size = UDim2.new(0.1, 0, 1, -4)
		dropAllBtn.Position = UDim2.new(0.22, 0, 0, 0)
		dropAllBtn.Text = "🗑️ Drop All"
		dropAllBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
		dropAllBtn.TextColor3 = Color3.fromRGB(255,255,255)
		dropAllBtn.Font = Enum.Font.SourceSansBold
		dropAllBtn.TextSize = 8
		Instance.new("UICorner", dropAllBtn).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0,4)

		local function renderTools()
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			local localPlr = S.Players.LocalPlayer
			local char = localPlr.Character
			local bp = localPlr:FindFirstChild("Backpack")
			local tools = {}
			if bp then
				for _, t in pairs(bp:GetChildren()) do
					if t:IsA("Tool") then table.insert(tools, {obj = t, status = "Túi"}) end
				end
			end
			if char then
				for _, t in pairs(char:GetChildren()) do
					if t:IsA("Tool") then table.insert(tools, {obj = t, status = "Cầm"}) end
				end
			end

			for _, data in ipairs(tools) do
				local frame = Instance.new("Frame", listContainer)
				frame.Size = UDim2.new(1, -4, 0, 28)
				frame.BackgroundColor3 = Color3.fromRGB(20,20,26)
				Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)

				local label = Instance.new("TextLabel", frame)
				label.Size = UDim2.new(0.4, 0, 1, 0)
				label.Position = UDim2.new(0.02, 0, 0, 0)
				label.Text = string.format("🔧 %s [%s]", data.obj.Name, data.status)
				label.TextColor3 = data.status == "Cầm" and Color3.fromRGB(255,200,50) or Color3.fromRGB(200,200,200)
				label.BackgroundTransparency = 1
				label.Font = Enum.Font.SourceSans
				label.TextSize = 9
				label.TextXAlignment = Enum.TextXAlignment.Left

				if data.status == "Túi" then
					local equipBtn = Instance.new("TextButton", frame)
					equipBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
					equipBtn.Position = UDim2.new(0.45, 0, 0.15, 0)
					equipBtn.Text = "Equip"
					equipBtn.BackgroundColor3 = Color3.fromRGB(0,140,70)
					equipBtn.TextColor3 = Color3.fromRGB(255,255,255)
					equipBtn.Font = Enum.Font.SourceSansBold
					equipBtn.TextSize = 8
					Instance.new("UICorner", equipBtn).CornerRadius = UDim.new(0,3)
					equipBtn.MouseButton1Click:Connect(function()
						local hum = char and char:FindFirstChildOfClass("Humanoid")
						if hum then hum:EquipTool(data.obj) end
						task.wait(0.2); renderTools()
					end)
				else
					local dropBtn = Instance.new("TextButton", frame)
					dropBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
					dropBtn.Position = UDim2.new(0.45, 0, 0.15, 0)
					dropBtn.Text = "Drop"
					dropBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
					dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
					dropBtn.Font = Enum.Font.SourceSansBold
					dropBtn.TextSize = 8
					Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0,3)
					dropBtn.MouseButton1Click:Connect(function()
						data.obj.Parent = S.Workspace
						task.wait(0.2); renderTools()
					end)
				end

				-- Scripts
				local scripts = {}
				for _, d in pairs(data.obj:GetDescendants()) do
					if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("ModuleScript") then
						table.insert(scripts, d)
					end
				end
				if #scripts > 0 then
					local scrBtn = Instance.new("TextButton", frame)
					scrBtn.Size = UDim2.new(0.08, 0, 0.7, 0)
					scrBtn.Position = UDim2.new(0.57, 0, 0.15, 0)
					scrBtn.Text = "📜" .. #scripts
					scrBtn.BackgroundColor3 = Color3.fromRGB(0,150,150)
					scrBtn.TextColor3 = Color3.fromRGB(255,255,255)
					scrBtn.Font = Enum.Font.SourceSansBold
					scrBtn.TextSize = 7
					Instance.new("UICorner", scrBtn).CornerRadius = UDim.new(0,3)
					scrBtn.MouseButton1Click:Connect(function()
						local popup = Instance.new("Frame", Tookit.UI.Gui)
						popup.Size = UDim2.new(0, 500, 0, 350)
						popup.Position = UDim2.new(0.5, -250, 0.5, -175)
						popup.BackgroundColor3 = Color3.fromRGB(20,20,30)
						Instance.new("UICorner", popup).CornerRadius = UDim.new(0,8)
						local close = Instance.new("TextButton", popup)
						close.Size = UDim2.new(0,30,0,30)
						close.Position = UDim2.new(1,-35,0,5)
						close.Text = "✕"
						close.BackgroundColor3 = Color3.fromRGB(50,50,50)
						close.TextColor3 = Color3.fromRGB(255,255,255)
						close.Font = Enum.Font.SourceSansBold
						close.TextSize = 12
						close.MouseButton1Click:Connect(function() popup:Destroy() end)
						local title = Instance.new("TextLabel", popup)
						title.Size = UDim2.new(0.8, 0, 0, 30)
						title.Position = UDim2.new(0.05, 0, 0, 0)
						title.Text = "Scripts trong " .. data.obj.Name
						title.TextColor3 = Color3.fromRGB(0,255,200)
						title.BackgroundTransparency = 1
						title.Font = Enum.Font.SourceSansBold
						title.TextSize = 12
						local scroll = Instance.new("ScrollingFrame", popup)
						scroll.Size = UDim2.new(0.95, 0, 0.85, 0)
						scroll.Position = UDim2.new(0.025, 0, 0.1, 0)
						scroll.BackgroundColor3 = Color3.fromRGB(10,10,15)
						scroll.CanvasSize = UDim2.new(0,0,0,0)
						scroll.ScrollBarThickness = 4
						local lay = Instance.new("UIListLayout", scroll)
						lay.Padding = UDim.new(0,4)
						for _, scr in ipairs(scripts) do
							local f = Instance.new("Frame", scroll)
							f.Size = UDim2.new(1, -5, 0, 24)
							f.BackgroundColor3 = Color3.fromRGB(25,25,30)
							Instance.new("UICorner", f).CornerRadius = UDim.new(0,4)
							local lb = Instance.new("TextLabel", f)
							lb.Size = UDim2.new(0.5,0,1,0)
							lb.Position = UDim2.new(0.02,0,0,0)
							lb.Text = scr.Name .. " (" .. scr.ClassName .. ")"
							lb.TextColor3 = Color3.fromRGB(200,200,200)
							lb.BackgroundTransparency = 1
							lb.Font = Enum.Font.SourceSans
							lb.TextSize = 9
							local copy = Instance.new("TextButton", f)
							copy.Size = UDim2.new(0.35,0,0.8,0)
							copy.Position = UDim2.new(0.55,0,0.1,0)
							copy.Text = "📋 Copy"
							copy.BackgroundColor3 = Color3.fromRGB(0,120,180)
							copy.TextColor3 = Color3.fromRGB(255,255,255)
							copy.Font = Enum.Font.SourceSansBold
							copy.TextSize = 8
							Instance.new("UICorner", copy).CornerRadius = UDim.new(0,3)
							copy.MouseButton1Click:Connect(function()
								copyToClipboard(getScriptCode(scr))
							end)
						end
						scroll.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y)
					end)
				end
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		refreshBtn.MouseButton1Click:Connect(function() refreshGameData(); renderTools() end)
		equipAllBtn.MouseButton1Click:Connect(function()
			local hum = S.Players.LocalPlayer.Character and S.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				for _, data in pairs(listContainer:GetChildren()) do
					-- Không dễ để equip all từ list, dùng backpack
				end
				local bp = S.Players.LocalPlayer:FindFirstChild("Backpack")
				if bp then
					for _, t in pairs(bp:GetChildren()) do
						if t:IsA("Tool") then hum:EquipTool(t) end
					end
				end
			end
			task.wait(0.2); renderTools()
		end)
		dropAllBtn.MouseButton1Click:Connect(function()
			local char = S.Players.LocalPlayer.Character
			if char then
				for _, t in pairs(char:GetChildren()) do
					if t:IsA("Tool") then t.Parent = S.Workspace end
				end
			end
			task.wait(0.2); renderTools()
		end)

		renderTools()

	elseif tabName == "🛠 Console" then
		-- Console với filter
		local tb = createToolbar(0)
		local filterError = Instance.new("TextButton", tb)
		filterError.Size = UDim2.new(0.05, 0, 1, -4)
		filterError.Text = "❌"
		filterError.BackgroundColor3 = Color3.fromRGB(50,50,50)
		filterError.TextColor3 = Color3.fromRGB(255,255,255)
		filterError.Font = Enum.Font.SourceSansBold
		filterError.TextSize = 10
		Instance.new("UICorner", filterError).CornerRadius = UDim.new(0,3)
		local filterWarn = Instance.new("TextButton", tb)
		filterWarn.Size = UDim2.new(0.05, 0, 1, -4)
		filterWarn.Position = UDim2.new(0.06, 0, 0, 0)
		filterWarn.Text = "⚠️"
		filterWarn.BackgroundColor3 = Color3.fromRGB(50,50,50)
		filterWarn.TextColor3 = Color3.fromRGB(255,255,255)
		filterWarn.Font = Enum.Font.SourceSansBold
		filterWarn.TextSize = 10
		Instance.new("UICorner", filterWarn).CornerRadius = UDim.new(0,3)
		local filterInfo = Instance.new("TextButton", tb)
		filterInfo.Size = UDim2.new(0.05, 0, 1, -4)
		filterInfo.Position = UDim2.new(0.12, 0, 0, 0)
		filterInfo.Text = "ℹ️"
		filterInfo.BackgroundColor3 = Color3.fromRGB(50,50,50)
		filterInfo.TextColor3 = Color3.fromRGB(255,255,255)
		filterInfo.Font = Enum.Font.SourceSansBold
		filterInfo.TextSize = 10
		Instance.new("UICorner", filterInfo).CornerRadius = UDim.new(0,3)

		local clearBtn = Instance.new("TextButton", tb)
		clearBtn.Size = UDim2.new(0.06, 0, 1, -4)
		clearBtn.Position = UDim2.new(0.18, 0, 0, 0)
		clearBtn.Text = "🗑️"
		clearBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
		clearBtn.TextColor3 = Color3.fromRGB(255,255,255)
		clearBtn.Font = Enum.Font.SourceSansBold
		clearBtn.TextSize = 10
		Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0,3)

		local searchBox = Instance.new("TextBox", tb)
		searchBox.Size = UDim2.new(0.2, 0, 1, -4)
		searchBox.Position = UDim2.new(0.25, 0, 0, 0)
		searchBox.PlaceholderText = "🔍 Tìm..."
		searchBox.Text = ""
		searchBox.BackgroundColor3 = Color3.fromRGB(24,24,30)
		searchBox.TextColor3 = Color3.fromRGB(255,255,255)
		searchBox.Font = Enum.Font.SourceSans
		searchBox.TextSize = 9
		Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0,3)

		local listContainer = Instance.new("Frame", page)
		listContainer.Size = UDim2.new(1, 0, 1, -32)
		listContainer.Position = UDim2.new(0, 0, 0, 32)
		listContainer.BackgroundTransparency = 1
		local listUI = Instance.new("UIListLayout", listContainer)
		listUI.Padding = UDim.new(0,2)

		local consoleLogs = {}
		local filters = {Error = false, Warning = false, Info = false}

		filterError.MouseButton1Click:Connect(function()
			filters.Error = not filters.Error
			filterError.BackgroundColor3 = filters.Error and Color3.fromRGB(180,40,40) or Color3.fromRGB(50,50,50)
			renderConsole()
		end)
		filterWarn.MouseButton1Click:Connect(function()
			filters.Warning = not filters.Warning
			filterWarn.BackgroundColor3 = filters.Warning and Color3.fromRGB(180,120,0) or Color3.fromRGB(50,50,50)
			renderConsole()
		end)
		filterInfo.MouseButton1Click:Connect(function()
			filters.Info = not filters.Info
			filterInfo.BackgroundColor3 = filters.Info and Color3.fromRGB(0,120,180) or Color3.fromRGB(50,50,50)
			renderConsole()
		end)

		clearBtn.MouseButton1Click:Connect(function()
			consoleLogs = {}
			renderConsole()
		end)

		local function onMessage(msg, type)
			table.insert(consoleLogs, { msg = msg, type = type, time = os.date("%H:%M:%S") })
			if #consoleLogs > 200 then table.remove(consoleLogs, 1) end
			if Tookit.UI and Tookit.UI.Tabs["🛠 Console"] then
				renderConsole()
			end
		end
		S.LogService.MessageOut:Connect(onMessage)

		local function renderConsole()
			for _, child in pairs(listContainer:GetChildren()) do
				if child:IsA("Frame") then child:Destroy() end
			end
			local filter = string.lower(searchBox.Text or "")
			for _, entry in ipairs(consoleLogs) do
				local show = true
				if entry.type == Enum.MessageType.MessageError and not filters.Error then show = false end
				if entry.type == Enum.MessageType.MessageWarning and not filters.Warning then show = false end
				if entry.type == Enum.MessageType.MessageOutput and not filters.Info then show = false end
				if filter ~= "" and not string.find(string.lower(entry.msg), filter) then show = false end
				if show then
					local frame = Instance.new("Frame", listContainer)
					frame.Size = UDim2.new(1, -4, 0, 18)
					frame.BackgroundColor3 = Color3.fromRGB(18,18,22)
					Instance.new("UICorner", frame).CornerRadius = UDim.new(0,3)
					local lbl = Instance.new("TextLabel", frame)
					lbl.Size = UDim2.new(1, -4, 1, 0)
					lbl.Position = UDim2.new(0.02, 0, 0, 0)
					lbl.Text = string.format("[%s] %s", entry.time, entry.msg)
					local color = Color3.fromRGB(220,220,220)
					if entry.type == Enum.MessageType.MessageError then color = Color3.fromRGB(255,80,80)
					elseif entry.type == Enum.MessageType.MessageWarning then color = Color3.fromRGB(255,200,50)
					elseif entry.type == Enum.MessageType.MessageOutput then color = Color3.fromRGB(200,200,200)
					else color = Color3.fromRGB(100,200,255) end
					lbl.TextColor3 = color
					lbl.BackgroundTransparency = 1
					lbl.Font = Enum.Font.SourceSans
					lbl.TextSize = 8
					lbl.TextXAlignment = Enum.TextXAlignment.Left
				end
			end
			listContainer.Size = UDim2.new(1, 0, 0, listUI.AbsoluteContentSize.Y + 10)
			page.CanvasSize = UDim2.new(0, 0, 0, listContainer.AbsoluteSize.Y + 40)
		end

		searchBox.Changed:Connect(renderConsole)
		renderConsole()
	end

	-- Cập nhật CanvasSize chung
	page.CanvasSize = UDim2.new(0, 0, 0, page.UIListLayout.AbsoluteContentSize.Y + 10)
end

function renderAllTabs()
	for name, _ in pairs(Tookit.UI.Tabs) do
		renderTab(name)
	end
end

-- =====================================================================
-- INIT
-- =====================================================================
local function init()
	local UI = buildUI()
	Tookit.UI = UI

	refreshGameData()
	renderAllTabs()
	UI.StatusLabel.Text = "✅ Đã tải v6.0 - " .. os.date("%H:%M:%S")

	-- Auto refresh loop
	task.spawn(function()
		while task.wait(Tookit.Config.refreshInterval) do
			if Tookit.Config.autoRefresh and UI.Main.Visible then
				refreshGameData()
				local currentTabName = nil
				for name, tab in pairs(UI.Tabs) do
					if tab.page.Visible then currentTabName = name; break end
				end
				if currentTabName then renderTab(currentTabName) end
				UI.StatusLabel.Text = "🔄 Cập nhật - " .. os.date("%H:%M:%S")
			end
		end
	end)

	-- Hotkey
	local inputConn = S.UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
			UI.Main.Visible = not UI.Main.Visible
		end
	end)
	table.insert(UI.Cleanup, inputConn)

	local function cleanAll()
		for _, conn in ipairs(UI.Cleanup) do pcall(conn.Disconnect, conn) end
	end
	local scriptObj = script or coroutine.running()
	if scriptObj and scriptObj:IsA("BaseScript") then
		scriptObj.AncestryChanged:Connect(function()
			if not scriptObj.Parent then cleanAll() end
		end)
	end

	print("🧰 ULTIMATE TOOLKIT v6.0 ĐÃ SẴN SÀNG – Press Right Control")
end

init()
_G.Tookit = Tookit
