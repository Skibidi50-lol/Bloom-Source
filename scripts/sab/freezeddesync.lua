local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Create minimal GUI
local gui = Instance.new("ScreenGui")
gui.Name = "DesyncHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)  -- Increased height to fit the new label
frame.Position = UDim2.new(0.5, -110, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(120, 120, 120)
stroke.Thickness = 2
stroke.Parent = frame

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -20, 0, 30)
header.Position = UDim2.new(0, 10, 0, 8)
header.BackgroundTransparency = 1
header.Text = "Desync Tool"
header.Font = Enum.Font.GothamBold
header.TextSize = 18
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Parent = frame

-- Desync Button
local desyncBtn = Instance.new("TextButton")
desyncBtn.Size = UDim2.new(0, 160, 0, 40)
desyncBtn.Position = UDim2.new(0.5, -80, 0, 50)  -- Moved up slightly for spacing
desyncBtn.Text = "Desync"
desyncBtn.Font = Enum.Font.GothamBold
desyncBtn.TextSize = 16
desyncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
desyncBtn.BorderSizePixel = 0
desyncBtn.Parent = frame

Instance.new("UICorner", desyncBtn).CornerRadius = UDim.new(0, 10)

desyncBtn.MouseEnter:Connect(function()
    desyncBtn.BackgroundColor3 = Color3.fromRGB(220, 80, 80)
end)

desyncBtn.MouseLeave:Connect(function()
    desyncBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
end)

-- Discord Invite Label (added below the button)
local discordLabel = Instance.new("TextLabel")
discordLabel.Size = UDim2.new(1, -20, 0, 30)
discordLabel.Position = UDim2.new(0, 10, 0, 100)
discordLabel.BackgroundTransparency = 1
discordLabel.Text = "discord.gg/JMRC5wXhV9"
discordLabel.Font = Enum.Font.Gotham
discordLabel.TextSize = 16
discordLabel.TextColor3 = Color3.fromRGB(100, 200, 255)  -- Light blue for visibility/link feel
discordLabel.Parent = frame

-- Desync Function (original flags + character fake swap)
desyncBtn.MouseButton1Click:Connect(function()
    local flags = {
        {"GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-5000"},
        {"LargeReplicatorWrite5", "true"},
        {"LargeReplicatorEnabled9", "true"},
        {"AngularVelociryLimit", "360"},
        {"TimestepArbiterVelocityCriteriaThresholdTwoDt", "2147483646"},
        {"S2PhysicsSenderRate", "15000"},
        {"DisableDPIScale", "true"},
        {"MaxDataPacketPerSend", "2147483647"},
        {"ServerMaxBandwith", "52"},
        {"PhysicsSenderMaxBandwidthBps", "20000"},
        {"MaxTimestepMultiplierBuoyancy", "2147483647"},
        {"SimOwnedNOUCountThresholdMillionth", "2147483647"},
        {"MaxMissedWorldStepsRemembered", "-2147483648"},
        {"CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth", "1"},
        {"StreamJobNOUVolumeLengthCap", "2147483647"},
        {"DebugSendDistInSteps", "-2147483648"},
        {"MaxTimestepMultiplierAcceleration", "2147483647"},
        {"LargeReplicatorRead5", "true"},
        {"SimExplicitlyCappedTimestepMultiplier", "2147483646"},
        {"GameNetDontSendRedundantNumTimes", "1"},
        {"CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent", "1"},
        {"CheckPVCachedRotVelThresholdPercent", "10"},
        {"LargeReplicatorSerializeRead3", "true"},
        {"ReplicationFocusNouExtentsSizeCutoffForPauseStuds", "2147483647"},
        {"NextGenReplicatorEnabledWrite4", "true"},
        {"CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth", "1"},
        {"GameNetDontSendRedundantDeltaPositionMillionth", "1"},
        {"InterpolationFrameVelocityThresholdMillionth", "5"},
        {"StreamJobNOUVolumeCap", "2147483647"},
        {"InterpolationFrameRotVelocityThresholdMillionth", "5"},
        {"WorldStepMax", "30"},
        {"TimestepArbiterHumanoidLinearVelThreshold", "1"},
        {"InterpolationFramePositionThresholdMillionth", "5"},
        {"TimestepArbiterHumanoidTurningVelThreshold", "1"},
        {"MaxTimestepMultiplierContstraint", "2147483647"},
        {"GameNetPVHeaderLinearVelocityZeroCutoffExponent", "-5000"},
        {"CheckPVCachedVelThresholdPercent", "10"},
        {"TimestepArbiterOmegaThou", "1073741823"},
        {"MaxAcceptableUpdateDelay", "1"},
        {"LargeReplicatorSerializeWrite4", "true"},
    }
   
    for _, data in ipairs(flags) do
        pcall(function()
            if setfflag then
                setfflag(data[1], data[2])
            end
        end)
    end
   
    local char = player.Character
    if not char then return end
   
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    end
   
    char:ClearAllChildren()
   
    local fakeModel = Instance.new("Model", workspace)
    player.Character = fakeModel
    task.wait()
    player.Character = char
    fakeModel:Destroy()
end)

-- Make the GUI draggable
local dragging = false
local dragStart
local startPos

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
