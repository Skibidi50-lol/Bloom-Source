local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SleighLaggerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BackgroundTransparency = 0.55
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = frame

-- Rainbow Stroke (Frame)
local stroke = Instance.new("UIStroke")
stroke.Thickness = 5
stroke.Transparency = 0
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
}
gradient.Parent = stroke

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "Sleigh Lagger"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 30
title.Font = Enum.Font.GothamBlack
title.Parent = frame

-- Button
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 220, 0, 55)
button.Position = UDim2.new(0.5, -110, 0.6, 0)
button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
button.BackgroundTransparency = 0.4
button.Text = "Activate"
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 24
button.Font = Enum.Font.GothamBold
button.AutoButtonColor = false
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 12)
buttonCorner.Parent = button

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Thickness = 4
buttonStroke.Transparency = 0
buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
buttonStroke.Parent = button

local buttonGradient = Instance.new("UIGradient")
buttonGradient.Color = gradient.Color  -- Same colors
buttonGradient.Parent = buttonStroke

-- Dragging
local dragging = false
local dragInput, mousePos, frameStartPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        frameStartPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

-- FIXED RAINBOW ANIMATION: Rotate the gradient for smooth flowing rainbow border
RunService.RenderStepped:Connect(function()
    local rotation = tick() * 60 % 360  -- Adjust speed here (higher = faster)
    gradient.Rotation = rotation
    buttonGradient.Rotation = rotation
    
    -- Dragging
    if dragging and dragInput then
        local delta = dragInput.Position - mousePos
        frame.Position = UDim2.new(
            frameStartPos.X.Scale,
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale,
            frameStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Button Click
button.MouseButton1Click:Connect(function()
    button.Text = "ACTIVE"
    button.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
    
    -- Press animation
    TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 200, 0, 50)
    }):Play()
    task.delay(0.1, function()
        TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 220, 0, 55)
        }):Play()
    end)
    
    -- Glow pulse
    TweenService:Create(buttonStroke, TweenInfo.new(0.3), {Thickness = 8}):Play()
    task.delay(0.3, function()
        TweenService:Create(buttonStroke, TweenInfo.new(0.3), {Thickness = 4}):Play()
    end)
    
    -- Revert visual after 2 seconds
    task.delay(2, function()
        button.Text = "Activate"
        button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    end)
    
    -- YOUR ORIGINAL LAG SCRIPT (runs permanently)
    local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local remote = Net:RemoteEvent("Tools/SantasSleigh/DropPresent")

local lp = game.Players.LocalPlayer
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) 
end)

local function data()
    local data = {}
    for i = 1, math.random(800, 1200) do
        data[tostring(i)] = Vector3.new(math.random(-500, 500), math.random(100, 200), math.random(-500, 500))
    end
    return data
end

RunService.Stepped:Connect(function()
    if tick() % 0.5 < 0.2 then 
        for i = 1, 250 do
            task.spawn(function()
                remote:FireServer(data())
            end)
        end
    end
end)


workspace.ChildAdded:Connect(function(v)
    if v.Name:lower():find("present") or v.Name:lower():find("explosion") then
        RunService.RenderStepped:Wait()
        v:Destroy()
    end
end)
end)
