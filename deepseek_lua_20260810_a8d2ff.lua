-- ============================================================
--  ██████╗  ██████╗ ██████╗     ███╗   ███╗ ██████╗ ██████╗ ███████╗
--  ██╔══██╗██╔═══██╗██╔══██╗    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
--  ██║  ██║██║   ██║██║  ██║    ██╔████╔██║██║   ██║██║  ██║█████╗  
--  ██║  ██║██║   ██║██║  ██║    ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝  
--  ██████╔╝╚██████╔╝██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗
--  ╚═════╝  ╚═════╝ ╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
-- ============================================================
--  AUTO PLACE BLOCK - GOD MODE (No Anti-Cheat)
--  Tác giả: Master of Command
--  Game cũ = TỰ DO BUNG LỤA! 🔥
-- ============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- TÌM REMOTE (TỰ ĐỘNG DÒ TÌM)
-- ============================================================

local function FindAllRemotes()
    local remotes = {}
    local function search(obj, path)
        for _, child in ipairs(obj:GetChildren()) do
            local fullPath = path .. "." .. child.Name
            if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                table.insert(remotes, {
                    Name = child.Name,
                    Path = fullPath,
                    Object = child
                })
            end
            if #child:GetChildren() > 0 then
                search(child, fullPath)
            end
        end
    end
    search(ReplicatedStorage, "ReplicatedStorage")
    return remotes
end

-- Tìm PlaceBlock
local placeBlockRemote = nil
local allRemotes = FindAllRemotes()

for _, remote in ipairs(allRemotes) do
    if remote.Name:lower():find("place") or remote.Name:lower():find("block") or remote.Name:lower():find("build") then
        placeBlockRemote = remote.Object
        print("🔍 Tìm thấy Remote: "..remote.Name.." tại "..remote.Path)
        break
    end
end

if not placeBlockRemote then
    -- Thử tìm bằng tên cụ thể
    placeBlockRemote = ReplicatedStorage:FindFirstChild("PlaceBlock")
    if not placeBlockRemote then
        placeBlockRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("PlaceBlock")
    end
    if not placeBlockRemote then
        warn("⚠️ Không tìm thấy Remote! Nhưng vẫn thử...")
    end
end

-- Xóa UI cũ
if CoreGui:FindFirstChild("PlaceBlockMenu") then
    CoreGui.PlaceBlockMenu:Destroy()
end

-- ============================================================
-- CẤU HÌNH MAX POWER (Không Anti-Cheat)
-- ============================================================

local CONFIG = {
    THREAD_COUNT = 20,          -- Khởi tạo 20 luồng luôn
    MAX_THREADS = 999,          -- Gần như không giới hạn
    MIN_DELAY = 0.0001,         -- Delay cực nhỏ
    MAX_DELAY = 0.001,          -- Delay tối đa vẫn rất nhỏ
    AUTO_OPTIMIZE = true,
    ANTI_BAN = false,           -- KHÔNG CẦN VÌ KHÔNG CÓ ANTI-CHEAT!
    SMART_RETRY = true,
    RANDOM_DELAY = false,       -- Không cần random, cứ spam đi!
    SHOW_STATS = true,
    IGNORE_LIMITS = true,       -- Bỏ qua mọi giới hạn
    SUPER_FAST = true,          -- Chế độ siêu nhanh
}

-- Biến
_G.AutoPlaceBlock = false
_G.PlaceCount = 0
_G.FailCount = 0
_G.CurrentThreads = 0
_G.Speed = 0
_G.TotalSent = 0

-- ============================================================
-- TẠO UI XỊN XÒ
-- ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlaceBlockMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 280)
Frame.Position = UDim2.new(0.5, -160, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Frame

-- Glow effect
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(1, 4, 1, 4)
Glow.Position = UDim2.new(0, -2, 0, -2)
Glow.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Glow.BackgroundTransparency = 0.8
Glow.BorderSizePixel = 0
Glow.Parent = Frame

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 14)
GlowCorner.Parent = Glow

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "💀 AUTO PLACE - GOD MODE"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
Title.Parent = Frame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = Title

-- Stats Panel
local StatsPanel = Instance.new("Frame")
StatsPanel.Size = UDim2.new(1, -20, 0, 80)
StatsPanel.Position = UDim2.new(0, 10, 0.18, 0)
StatsPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
StatsPanel.BackgroundTransparency = 0.3
StatsPanel.BorderSizePixel = 0
StatsPanel.Parent = Frame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 8)
StatsCorner.Parent = StatsPanel

-- Stats
local function CreateStat(text, posX, posY, color, size)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -5, 0.5, -2)
    label.Position = UDim2.new(posX, 0, posY, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(200, 200, 200)
    label.TextSize = size or 13
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = StatsPanel
    return label
end

local StatPlace = CreateStat("📦 Đã đặt: 0", 0, 0, Color3.fromRGB(0, 255, 0), 14)
local StatFail = CreateStat("❌ Thất bại: 0", 0.5, 0, Color3.fromRGB(255, 100, 100), 14)
local StatSpeed = CreateStat("⚡ Tốc độ: 0/s", 0, 0.5, Color3.fromRGB(100, 255, 255), 14)
local StatThread = CreateStat("🧵 Luồng: 0", 0.5, 0.5, Color3.fromRGB(255, 200, 100), 14)
local StatTotal = CreateStat("📊 Tổng gửi: 0", 0, 0, Color3.fromRGB(255, 150, 255), 12)
StatTotal.Position = UDim2.new(0, 0, 0.75, 0)
StatTotal.Size = UDim2.new(0.5, -5, 0.25, -2)

-- Toggle Button (LỚN)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.85, 0, 0, 50)
ToggleBtn.Position = UDim2.new(0.075, 0, 0.5, 0)
ToggleBtn.Text = "🚀 BẬT GOD MODE"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 18
ToggleBtn.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = ToggleBtn

-- Control Buttons
local function CreateControlBtn(text, posX, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -5, 0, 30)
    btn.Position = UDim2.new(posX, 0, 0.78, 0)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 80, 150)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = Frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local BtnThreadUp = CreateControlBtn("➕ Luồng", 0.04, Color3.fromRGB(0, 150, 100), function()
    CONFIG.THREAD_COUNT = CONFIG.THREAD_COUNT + 10
    if _G.AutoPlaceBlock then
        for i = 1, 10 do SpawnThread() end
    end
    print("🧵 Tăng lên "..CONFIG.THREAD_COUNT.." luồng!")
end)

local BtnThreadDown = CreateControlBtn("➖ Luồng", 0.33, Color3.fromRGB(150, 50, 50), function()
    if CONFIG.THREAD_COUNT > 10 then
        CONFIG.THREAD_COUNT = CONFIG.THREAD_COUNT - 10
        print("🧵 Giảm xuống "..CONFIG.THREAD_COUNT.." luồng!")
    end
end)

local BtnReset = CreateControlBtn("🔄 Reset", 0.62, Color3.fromRGB(100, 100, 100), function()
    _G.PlaceCount = 0
    _G.FailCount = 0
    _G.Speed = 0
    print("🔄 Đã reset stats!")
end)

local BtnBoost = CreateControlBtn("⚡ Boost", 0.91, Color3.fromRGB(200, 150, 0), function()
    CONFIG.THREAD_COUNT = CONFIG.THREAD_COUNT + 50
    for i = 1, 50 do SpawnThread() end
    print("⚡ BOOST! Luồng: "..CONFIG.THREAD_COUNT)
end)

-- ============================================================
-- HÀM LÕI - SPAM CỰC MẠNH
-- ============================================================

local function SpawnThread()
    if CONFIG.IGNORE_LIMITS then
        _G.CurrentThreads = _G.CurrentThreads + 1
    else
        if _G.CurrentThreads >= CONFIG.MAX_THREADS then return end
        _G.CurrentThreads = _G.CurrentThreads + 1
    end
    
    task.spawn(function()
        local threadId = _G.CurrentThreads
        while _G.AutoPlaceBlock do
            -- Gửi không delay (tối đa tốc độ)
            if placeBlockRemote then
                pcall(function()
                    placeBlockRemote:FireServer()
                    _G.PlaceCount = _G.PlaceCount + 1
                    _G.TotalSent = _G.TotalSent + 1
                end)
            else
                -- Nếu không tìm thấy remote, thử tìm lại
                placeBlockRemote = ReplicatedStorage:FindFirstChild("PlaceBlock")
                if not placeBlockRemote then
                    placeBlockRemote = ReplicatedStorage:FindFirstChild("Remotes"):FindFirstChild("PlaceBlock")
                end
            end
            
            -- Delay cực nhỏ (0.0001s = 10,000 lần/giây)
            if CONFIG.SUPER_FAST then
                task.wait(0.0001)
            else
                task.wait(CONFIG.MIN_DELAY)
            end
        end
        _G.CurrentThreads = _G.CurrentThreads - 1
    end)
end

-- Bật GOD MODE
local function StartGodMode()
    _G.AutoPlaceBlock = true
    _G.PlaceCount = 0
    _G.FailCount = 0
    
    -- Spawn số luồng khởi tạo
    for i = 1, CONFIG.THREAD_COUNT do
        SpawnThread()
        task.wait(0.001)
    end
    
    print("🚀 GOD MODE BẬT! "..CONFIG.THREAD_COUNT.." luồng đang chạy!")
end

-- Tắt
local function StopGodMode()
    _G.AutoPlaceBlock = false
    task.wait(0.3)
    _G.CurrentThreads = 0
    print("💤 GOD MODE TẮT!")
end

-- ============================================================
-- SỰ KIỆN
-- ============================================================

ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoPlaceBlock = not _G.AutoPlaceBlock
    if _G.AutoPlaceBlock then
        ToggleBtn.Text = "💀 TẮT GOD MODE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        StartGodMode()
    else
        ToggleBtn.Text = "🚀 BẬT GOD MODE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        StopGodMode()
    end
end)

-- ============================================================
-- CẬP NHẬT STATS
-- ============================================================

task.spawn(function()
    local lastCount = 0
    while true do
        task.wait(1)
        StatPlace.Text = "📦 Đã đặt: ".._G.PlaceCount
        StatFail.Text = "❌ Thất bại: ".._G.FailCount
        StatThread.Text = "🧵 Luồng: ".._G.CurrentThreads.."/∞"
        StatTotal.Text = "📊 Tổng gửi: ".._G.TotalSent
        
        local speed = _G.PlaceCount - lastCount
        _G.Speed = speed
        StatSpeed.Text = "⚡ Tốc độ: "..speed.."/s"
        lastCount = _G.PlaceCount
        
        -- Hiển thị thông báo đẹp
        if speed > 1000 then
            StatSpeed.TextColor3 = Color3.fromRGB(255, 0, 255)
        elseif speed > 500 then
            StatSpeed.TextColor3 = Color3.fromRGB(255, 200, 0)
        elseif speed > 100 then
            StatSpeed.TextColor3 = Color3.fromRGB(0, 255, 200)
        end
    end
end)

-- ============================================================
-- PHÍM TẮT
-- ============================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        ToggleBtn.MouseButton1Click:Fire()
    end
    if input.KeyCode == Enum.KeyCode.F9 then
        _G.PlaceCount = 0
        _G.FailCount = 0
        print("🔄 Reset stats!")
    end
    if input.KeyCode == Enum.KeyCode.F10 then
        CONFIG.THREAD_COUNT = CONFIG.THREAD_COUNT + 20
        for i = 1, 20 do SpawnThread() end
        print("⚡ +20 luồng! Tổng: "..CONFIG.THREAD_COUNT)
    end
end)

-- ============================================================
-- KHỞI CHẠY
-- ============================================================

print("==================================================")
print("  💀 AUTO PLACE BLOCK - GOD MODE")
print("  👑 Tác giả: Master of Command")
print("  🎮 Game cũ - Không Anti-Cheat = MAX POWER!")
print("  📌 F8: Bật/Tắt")
print("  📌 F9: Reset stats")
print("  📌 F10: +20 luồng")
print("  ⚡ Tốc độ tối đa: 10,000+ lần/giây")
print("==================================================")
print("🔥 GOD MODE SẴN SÀNG!")

-- ============================================================
-- KẾT THÚC
-- ============================================================