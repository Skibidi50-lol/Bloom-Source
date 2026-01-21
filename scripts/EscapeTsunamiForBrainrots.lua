--[[
    BloomWare - Escape Tsunami For Brainrots
    Fixed for mobile input blocking + cleaned up
]]

local CONFIG = {
    ContainerWidth = 380,
    ContainerHeight = 100,
    BarHeight = 8,
    BarPaddingX = 32,
    BarLerpSpeed = 0.4,
    FadeInSpeed = 0.4,
    FadeOutSpeed = 0.3,
}

-- Services
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local GuiService       = game:GetService("GuiService")
local VirtualInput     = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer

-- Loader (your original loading screen - unchanged except wait time)
local loader = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GraphiteLoader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local success = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    screenGui.Parent = lp:WaitForChild("PlayerGui")
end

-- ... (your entire loader UI code here - container, corner, stroke, gradient, statusLabel, barBackground, etc.)
-- I'm skipping pasting the full loader again to save space - keep it exactly as you had

-- Loader functions (updateLoader, loader:Remove) - keep as is

task.spawn(function()
    wait(0.5)
    updateLoader("Bypassing Anti-Cheat", 10)
    wait(1)
    updateLoader("Loading Assets", 35)
    wait(1)
    updateLoader("Initializing Scripts", 60)
    wait(1)
    updateLoader("Finalizing", 85)
    wait(1)
    updateLoader("Complete", 100)
    wait(0.8)
    loader:Remove()
end)

wait(6)  -- give loader time to finish

-- Variables
local FLY_SPEED = 200
local CF_WALKSPEED = 16
local COORD_INDEX = 0
local COORD_TWEEN = nil
local COORD_HEIGHT_OFFSET = -2

local autoGrabEnabled   = false
local speedEnabled      = false
local flyToBaseEnabled  = false
local autoCoinsEnabled  = false
local customBaseCFrame  = nil

local FLY_COORDS = {
    CFrame.new(284.83, -2.67, 21.88),
    CFrame.new(203.92, -2.67, 45.68),
    CFrame.new(394.15, -2.67, -13.10),
    CFrame.new(543.11, -2.67, -12.48),
    CFrame.new(761.98, -2.67, -12.52),
    CFrame.new(1079.85, -2.67, 19.39),
    CFrame.new(1560.70, -2.67, 46.11),
    CFrame.new(2267.43, -2.67, -55.41),
    CFrame.new(2631.11, -5.58, 57.25)
}

-- Fluent Library
local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local Window = Library:CreateWindow{
    Title = "BloomWare - Escape Tsunami For Brainrots",
    SubTitle = "v1.0",
    TabWidth = 160,
    Size = UDim2.fromOffset(680, 480),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = false,               -- Disabled → better mobile performance
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftAlt
}

-- Mobile fix: disable default touch controls when GUI is open
local TouchGui = lp:WaitForChild("PlayerGui"):WaitForChild("TouchGui", 8)
local function updateMobileControls()
    if not UserInputService.TouchEnabled or not TouchGui then return end
    
    if Window.Visible then
        TouchGui.Enabled = false           -- hide thumbstick/jump when GUI open
        UserInputService.ModalEnabled = false
    else
        TouchGui.Enabled = true
    end
end
RunService.Heartbeat:Connect(updateMobileControls)

-- Toggle GUI Button
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "BloomToggle"
ToggleGui.Parent = game:GetService("CoreGui") or lp:WaitForChild("PlayerGui")

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -22.5)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "BW"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 16
OpenBtn.Parent = ToggleGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 9)

OpenBtn.Activated:Connect(function()
    VirtualInput:SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game)
    VirtualInput:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
end)

-- GAP Navigation GUI
local NavGui = Instance.new("ScreenGui")
NavGui.Name = "GAP_GUI"
NavGui.Enabled = false
NavGui.Parent = game:GetService("CoreGui") or lp:WaitForChild("PlayerGui")

local NavFrame = Instance.new("Frame")
NavFrame.Name = "MainFrame"
NavFrame.Size = UDim2.new(0, 200, 0, 60)
NavFrame.Position = UDim2.new(0.5, -100, 0.92, -30)
NavFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
NavFrame.Active = true
NavFrame.Draggable = true
NavFrame.Parent = NavGui
Instance.new("UICorner", NavFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", NavFrame).Color = Color3.fromRGB(60, 60, 60)

local function createNavBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = NavFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local prevBtn = createNavBtn("PREV", UDim2.new(0, 10, 0, 10))
local nextBtn = createNavBtn("NEXT", UDim2.new(1, -95, 0, 10))

local function flyToGap(cf, index)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if COORD_TWEEN then COORD_TWEEN:Cancel() end
    
    local goal = cf * CFrame.new(0, COORD_HEIGHT_OFFSET, 0)
    local distance = (hrp.Position - goal.Position).Magnitude
    local time = distance / FLY_SPEED
    
    COORD_TWEEN = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = goal})
    COORD_TWEEN:Play()
    
    Library:Notify({
        Title = "GAP Teleport",
        Content = "Moving to point #" .. index,
        Duration = 2.5
    })
end

prevBtn.Activated:Connect(function()
    COORD_INDEX = COORD_INDEX - 1
    if COORD_INDEX < 1 then COORD_INDEX = #FLY_COORDS end
    flyToGap(FLY_COORDS[COORD_INDEX], COORD_INDEX)
end)

nextBtn.Activated:Connect(function()
    COORD_INDEX = (COORD_INDEX % #FLY_COORDS) + 1
    flyToGap(FLY_COORDS[COORD_INDEX], COORD_INDEX)
end)

-- Tabs
local Tabs = {
    Player = Window:CreateTab{Title = "Player", Icon = "user"},
    Move   = Window:CreateTab{Title = "Movement", Icon = "move"},
    Radioactive = Window:CreateTab{Title = "Radioactive", Icon = "radiation"},
    Settings = Window:CreateTab{Title = "Settings", Icon = "settings"}
}

-- Player Tab
Tabs.Player:AddSection("Player Settings")

Tabs.Player:AddToggle("InfiniteZoom", {
    Title = "Infinite Zoom",
    Description = "Zoom out extremely far",
    Default = false,
    Callback = function(v)
        lp.CameraMaxZoomDistance = v and 10000 or 128
    end
})

Tabs.Player:AddToggle("TPWalk", {
    Title = "TP Walk (Speed)",
    Description = "Teleport-style movement (higher = faster)",
    Default = false,
    Callback = function(v) speedEnabled = v end
})

Tabs.Player:AddSlider("WalkSpeed", {
    Title = "TP Walk Speed",
    Description = "How fast TP Walk moves you",
    Default = 16,
    Min = 1,
    Max = 120,
    Rounding = 0,
    Callback = function(v) CF_WALKSPEED = v end
})

Tabs.Player:AddToggle("AutoGrab", {
    Title = "Auto Grab Prompts",
    Description = "Auto-activates nearby proximity prompts",
    Default = false,
    Callback = function(v) autoGrabEnabled = v end
})

-- Movement Tab
Tabs.Move:AddSection("Movement")

Tabs.Move:AddToggle("ShowGapGUI", {
    Title = "Show GAP GUI",
    Description = "Opens the navigation buttons for gaps",
    Default = false,
    Callback = function(v) NavGui.Enabled = v end
})

Tabs.Move:AddSlider("FlySpeed", {
    Title = "Fly / TP Speed",
    Description = "Speed for flying & teleporting",
    Default = 200,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Callback = function(v) FLY_SPEED = v end
})

Tabs.Move:AddButton({
    Title = "Save Current Position",
    Description = "Set current spot as Fly-to-Base location",
    Callback = function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            customBaseCFrame = hrp.CFrame
            Library:Notify({Title = "Saved", Content = "Base position updated!", Duration = 3})
        end
    end
})

Tabs.Move:AddToggle("FlyToBase", {
    Title = "Fly to Saved Base",
    Description = "Automatically fly to your saved position",
    Default = false,
    Callback = function(v)
        flyToBaseEnabled = v
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if v and hrp and customBaseCFrame then
            local dist = (hrp.Position - customBaseCFrame.Position).Magnitude
            local t = dist / FLY_SPEED
            local tween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame = customBaseCFrame})
            tween:Play()
        end
    end
})

-- Radioactive Tab
Tabs.Radioactive:AddSection("Farming")

Tabs.Radioactive:AddToggle("AutoCoins", {
    Title = "Auto Farm Coins",
    Description = "Pulls coins to you automatically",
    Default = false,
    Callback = function(v) autoCoinsEnabled = v end
})

-- TP Walk logic
RunService.Heartbeat:Connect(function(dt)
    if not speedEnabled then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
        hrp.CFrame += hum.MoveDirection * (CF_WALKSPEED / 10) * (dt * 60)
    end
end)

-- Auto Grab loop
task.spawn(function()
    while true do
        task.wait(0.18)
        if not autoGrabEnabled then continue end
        
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        for _, obj in workspace:GetDescendants() do
            if obj:IsA("ProximityPrompt") and (hrp.Position - obj.Parent.Position).Magnitude <= 16 then
                fireproximityprompt(obj)
            end
        end
    end
end)

-- Auto Coins loop
task.spawn(function()
    while true do
        task.wait(0.25)
        if not autoCoinsEnabled then continue end
        
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        
        for _, v in workspace:GetDescendants() do
            if v:IsA("BasePart") and v.Name:lower():find("coin") then
                pcall(function()
                    v.CanCollide = false
                    v.Anchored = false
                    v.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)  -- better positioning
                end)
            end
        end
    end
end)

-- Config / Interface
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BloomWare")
SaveManager:SetFolder("BloomWare/ETFB")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Library:Notify({
    Title = "BloomWare Loaded",
    Content = "Mobile fix applied • Enjoy!",
    Duration = 5
})
