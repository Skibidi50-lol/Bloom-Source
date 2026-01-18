local CONFIG = {
    ContainerWidth = 380,
    ContainerHeight = 100,
    BarHeight = 8,
    BarPaddingX = 32,
    BarLerpSpeed = 0.4,
    FadeInSpeed = 0.4,
    FadeOutSpeed = 0.3,
}

local loader = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GraphiteLoader"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.ResetOnSpawn = false

local success = pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local container = Instance.new("Frame")
container.Name = "LoaderContainer"
container.Size = UDim2.new(0, CONFIG.ContainerWidth, 0, CONFIG.ContainerHeight)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.BackgroundColor3 = Color3.fromRGB(38, 38, 42)
container.BorderSizePixel = 0
container.BackgroundTransparency = 1
container.Parent = screenGui

local containerCorner = Instance.new("UICorner")
containerCorner.CornerRadius = UDim.new(0, 12)
containerCorner.Parent = container

local containerStroke = Instance.new("UIStroke")
containerStroke.Color = Color3.fromRGB(68, 68, 72)
containerStroke.Thickness = 1
containerStroke.Transparency = 1
containerStroke.Parent = container

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 46, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 38, 42))
}
gradient.Rotation = 145
gradient.Parent = container

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, 20)
statusLabel.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Initializing..."
statusLabel.TextColor3 = Color3.fromRGB(176, 176, 176)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.TextTransparency = 1
statusLabel.Parent = container

local barBackground = Instance.new("Frame")
barBackground.Name = "BarBackground"
barBackground.Size = UDim2.new(1, -CONFIG.BarPaddingX * 2, 0, CONFIG.BarHeight)
barBackground.Position = UDim2.new(0, CONFIG.BarPaddingX, 0, 60)
barBackground.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
barBackground.BorderSizePixel = 0
barBackground.BackgroundTransparency = 1
barBackground.Parent = container

local barBgCorner = Instance.new("UICorner")
barBgCorner.CornerRadius = UDim.new(0, 3)
barBgCorner.Parent = barBackground

local barFill = Instance.new("Frame")
barFill.Name = "BarFill"
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(106, 106, 106)
barFill.BorderSizePixel = 0
barFill.BackgroundTransparency = 1
barFill.Parent = barBackground

local barFillCorner = Instance.new("UICorner")
barFillCorner.CornerRadius = UDim.new(0, 3)
barFillCorner.Parent = barFill

local barGradient = Instance.new("UIGradient")
barGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(106, 106, 106))
}
barGradient.Rotation = 90
barGradient.Parent = barFill

local TweenService = game:GetService("TweenService")
local fadeInTween = TweenService:Create(container, TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
local strokeFadeIn = TweenService:Create(containerStroke, TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0})
local textFadeIn = TweenService:Create(statusLabel, TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0})
local barBgFadeIn = TweenService:Create(barBackground, TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
local barFillFadeIn = TweenService:Create(barFill, TweenInfo.new(CONFIG.FadeInSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})

fadeInTween:Play()
strokeFadeIn:Play()
textFadeIn:Play()
barBgFadeIn:Play()
barFillFadeIn:Play()

function updateLoader(status, progress)
    progress = math.clamp(progress, 0, 100)
    statusLabel.Text = status
    local targetSize = UDim2.new(progress / 100, 0, 1, 0)
    barFill:TweenSize(targetSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, CONFIG.BarLerpSpeed, true)
end

function loader:Remove()
    local fadeOutTween = TweenService:Create(container, TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
    local strokeFadeOut = TweenService:Create(containerStroke, TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1})
    local textFadeOut = TweenService:Create(statusLabel, TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1})
    local barBgFadeOut = TweenService:Create(barBackground, TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
    local barFillFadeOut = TweenService:Create(barFill, TweenInfo.new(CONFIG.FadeOutSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
    
    fadeOutTween:Play()
    strokeFadeOut:Play()
    textFadeOut:Play()
    barBgFadeOut:Play()
    barFillFadeOut:Play()
    
    fadeOutTween.Completed:Connect(function() screenGui:Destroy() end)
end

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
    wait(1)
    loader:Remove()
end)

wait(7)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local FLY_SPEED = 190
local activeTween = nil
local customBaseCFrame = nil
local isFlying = false
local isMinimized = false
local infZoomEnabled = false

local COORD_INDEX = 0
local COORD_TWEEN = nil
local COORD_HEIGHT_OFFSET = -2
local FLY_COORDS = {
    CFrame.new(284.83,  -2.67,  21.88),
    CFrame.new(203.92,  -2.67,  45.68),
    CFrame.new(394.15,  -2.67, -13.10),
    CFrame.new(543.11,  -2.67, -12.48),
    CFrame.new(761.98,  -2.67, -12.52),
    CFrame.new(1079.85, -2.67,  19.39),
    CFrame.new(1560.70, -2.67,  46.11),
    CFrame.new(2267.43, -2.67, -55.41),
    CFrame.new(2631.11, -5.58,  57.25)
}

lp.CharacterAdded:Connect(function()
    COORD_INDEX = 0
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UnifiedFlyDupeGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local function ShowNotification(title, text, duration)
    duration = duration or 3
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 250, 0, 80)
    frame.Position = UDim2.new(1, -260, 1, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    frame.BackgroundTransparency = 0.2
    frame.Parent = ScreenGui
    frame.AnchorPoint = Vector2.new(0, 1)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.new(1, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -20, 0, 24)
    titleLabel.Position = UDim2.new(0, 10, 0, 6)
    titleLabel.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Text = text
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextSize = 14
    messageLabel.TextColor3 = Color3.new(1, 1, 1)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Size = UDim2.new(1, -20, 1, -34)
    messageLabel.Position = UDim2.new(0, 10, 0, 30)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, -260, 1, -100)}):Play()
    task.delay(duration, function()
        if frame and frame.Parent then
            local hide = TweenService:Create(frame, TweenInfo.new(0.3), {Position = UDim2.new(1, -260, 1, 20)})
            hide:Play()
            hide.Completed:Wait()
            frame:Destroy()
        end
    end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 200, 0, 410)
MainFrame.Position = UDim2.new(0.01, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local BloomTitle = Instance.new("TextLabel")
BloomTitle.Size = UDim2.new(1, -40, 1, 0)
BloomTitle.Position = UDim2.new(0, 12, 0, 0)
BloomTitle.BackgroundTransparency = 1
BloomTitle.Text = "BloomWare"
BloomTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
BloomTitle.TextXAlignment = Enum.TextXAlignment.Left
BloomTitle.Font = Enum.Font.GothamBold
BloomTitle.TextSize = 16
BloomTitle.Parent = TitleBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -35, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "–"
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.TextSize = 20
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = TitleBar

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -35)
ContentFrame.Position = UDim2.new(0, 0, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = ContentFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 5)
UIPadding.Parent = ContentFrame

local function CreateButton(text, order, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 170, 0, 35)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = ContentFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local MainLabel = Instance.new("TextLabel")
MainLabel.Text = "Main Features"
MainLabel.Size = UDim2.new(0, 170, 0, 20)
MainLabel.BackgroundTransparency = 1
MainLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
MainLabel.Font = Enum.Font.GothamBold
MainLabel.TextSize = 13
MainLabel.LayoutOrder = 1
MainLabel.Parent = ContentFrame

local FlyButton = CreateButton("FLY: OFF", 2, Color3.fromRGB(60, 0, 0))
FlyButton.TextColor3 = Color3.fromRGB(255, 100, 100)
local SetPosButton = CreateButton("SET BASE POS", 3)
local DupeButton = CreateButton("DUPE HELD TOOL", 4, Color3.fromRGB(80, 0, 0))

local ZoomButton = CreateButton("INF ZOOM: OFF", 4.5, Color3.fromRGB(40, 40, 40))

local NavLabel = Instance.new("TextLabel")
NavLabel.Text = "Gaps Teleport"
NavLabel.Size = UDim2.new(0, 170, 0, 20)
NavLabel.BackgroundTransparency = 1
NavLabel.TextColor3 = Color3.fromRGB(200, 0, 0)
NavLabel.Font = Enum.Font.GothamBold
NavLabel.TextSize = 13
NavLabel.LayoutOrder = 5
NavLabel.Parent = ContentFrame

local NextButton = CreateButton("NEXT GAP", 7, Color3.fromRGB(35, 35, 35))
local PrevButton = CreateButton("PREVIOUS GAP", 6, Color3.fromRGB(35, 35, 35))

local DiscordLabel = Instance.new("TextLabel")
DiscordLabel.Size = UDim2.new(0, 170, 0, 25)
DiscordLabel.BackgroundTransparency = 1
DiscordLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
DiscordLabel.Text = "discord.gg/JMRC5wXhV9"
DiscordLabel.Font = Enum.Font.GothamBold
DiscordLabel.TextSize = 13
DiscordLabel.LayoutOrder = 8
DiscordLabel.Parent = ContentFrame

MinimizeBtn.Activated:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 200, 0, 35), "Out", "Quad", 0.3, true)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 200, 0, 440), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        ContentFrame.Visible = true
        MinimizeBtn.Text = "–"
    end
end)

local function flyToCoords(cf)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if COORD_TWEEN then COORD_TWEEN:Cancel() end
    local adjustedCF = cf * CFrame.new(0, COORD_HEIGHT_OFFSET, 0)
    local time = (hrp.Position - adjustedCF.Position).Magnitude / FLY_SPEED
    COORD_TWEEN = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = adjustedCF})
    COORD_TWEEN:Play()
end

NextButton.Activated:Connect(function()
    COORD_INDEX = (COORD_INDEX % #FLY_COORDS) + 1
    ShowNotification("Navigation", "Target: Gap #" .. COORD_INDEX, 2)
    flyToCoords(FLY_COORDS[COORD_INDEX])
end)

PrevButton.Activated:Connect(function()
    COORD_INDEX = COORD_INDEX - 1
    if COORD_INDEX < 1 then COORD_INDEX = #FLY_COORDS end
    ShowNotification("Navigation", "Target: Gap #" .. COORD_INDEX, 2)
    flyToCoords(FLY_COORDS[COORD_INDEX])
end)

SetPosButton.Activated:Connect(function()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then 
        customBaseCFrame = hrp.CFrame 
        ShowNotification("System", "Base Position Set", 2)
    end
end)

DupeButton.Activated:Connect(function()
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    if tool then 
        tool:Clone().Parent = lp.Backpack 
        ShowNotification("Dupe", "Cloned successfully", 2)
    else 
        ShowNotification("Error", "Equip a tool first", 2) 
    end
end)

-- INFINITE ZOOM TOGGLE
ZoomButton.Activated:Connect(function()
    infZoomEnabled = not infZoomEnabled
    if infZoomEnabled then
        lp.CameraMaxZoomDistance = 10000
        ZoomButton.Text = "INF ZOOM: ON"
        ZoomButton.BackgroundColor3 = Color3.fromRGB(0, 80, 0)
    else
        lp.CameraMaxZoomDistance = 128
        ZoomButton.Text = "INF ZOOM: OFF"
        ZoomButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
end)

FlyButton.Activated:Connect(function()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if isFlying then
        isFlying = false
        if activeTween then activeTween:Cancel() end
        FlyButton.Text = "FLY: OFF"
        FlyButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    else
        if not customBaseCFrame then ShowNotification("Error", "Set Base Pos first", 2) return end
        isFlying = true
        FlyButton.Text = "FLYING..."
        FlyButton.BackgroundColor3 = Color3.fromRGB(0, 60, 0)
        local time = (hrp.Position - customBaseCFrame.Position).Magnitude / FLY_SPEED
        activeTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = customBaseCFrame})
        activeTween.Completed:Connect(function() 
            isFlying = false 
            FlyButton.Text = "FLY: OFF"
            FlyButton.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        end)
        activeTween:Play()
    end
end)

local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

ShowNotification("System", "Script Fully Loaded", 3)
