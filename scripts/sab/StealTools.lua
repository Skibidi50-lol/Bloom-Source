local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- // Auto Kick Logic
local autoKickEnabled = false
local kickKeyword = "you stole"
local kickMessage = "You stole a pet!"
local kickConnections = {}

local function hasKeyword(text)
    if typeof(text) ~= "string" then return false end
    return string.lower(text):find(kickKeyword) ~= nil
end

local function disconnectAllKick()
    for _, conn in pairs(kickConnections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    kickConnections = {}
end

local function kickPlayer()
    spawn(function()
        player:Kick(kickMessage)
    end)
end

local function scanGui(gui)
    if not autoKickEnabled then return end
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if hasKeyword(obj.Text) then
                kickPlayer()
                return
            end
            table.insert(kickConnections, obj:GetPropertyChangedSignal("Text"):Connect(function()
                if autoKickEnabled and hasKeyword(obj.Text) then
                    kickPlayer()
                end
            end))
        end
    end
    table.insert(kickConnections, gui.DescendantAdded:Connect(function(desc)
        if not autoKickEnabled then return end
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            if hasKeyword(desc.Text) then
                kickPlayer()
            end
            table.insert(kickConnections, desc:GetPropertyChangedSignal("Text"):Connect(function()
                if autoKickEnabled and hasKeyword(desc.Text) then
                    kickPlayer()
                end
            end))
        end
    end))
end

local function enableAutoKick()
    disconnectAllKick()
    autoKickEnabled = true
    for _, gui in ipairs(player.PlayerGui:GetChildren()) do
        scanGui(gui)
    end
    table.insert(kickConnections, player.PlayerGui.ChildAdded:Connect(scanGui))
end

local function disableAutoKick()
    autoKickEnabled = false
    disconnectAllKick()
end

-- // God Mode Logic
local godModeEnabled = false
local godConnections = {}
local godHeartbeat = nil

local function disableGodMode()
    for _, conn in ipairs(godConnections) do
        if conn.Connected then conn:Disconnect() end
    end
    godConnections = {}
    if godHeartbeat then godHeartbeat:Disconnect() godHeartbeat = nil end
    godModeEnabled = false
end

local function applyGodMode(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.BreakJointsOnDeath = false
    table.insert(godConnections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end))
    if godHeartbeat then godHeartbeat:Disconnect() end
    godHeartbeat = RunService.Heartbeat:Connect(function()
        if humanoid and humanoid.Parent and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end

local function enableGodMode()
    disableGodMode()
    godModeEnabled = true
    local char = player.Character or player.CharacterAdded:Wait()
    applyGodMode(char)
    table.insert(godConnections, player.CharacterAdded:Connect(function(newChar)
        task.wait(0.5)
        applyGodMode(newChar)
    end))
end

-- // Plot Timers ESP
local plotTimersEnabled = false
local plotTimers_RenderConnection = nil
local plotTimers_OriginalProperties = {}

local function disablePlotTimers()
    plotTimersEnabled = false
    if plotTimers_RenderConnection then
        pcall(function() plotTimers_RenderConnection:Disconnect() end)
        plotTimers_RenderConnection = nil
    end
    for label, props in pairs(plotTimers_OriginalProperties) do
        pcall(function()
            if label and label.Parent then
                local bb = label:FindFirstAncestorWhichIsA("BillboardGui")
                if not bb then return end
                bb.Enabled = props.bb_enabled
                bb.AlwaysOnTop = props.bb_alwaysOnTop
                bb.Size = props.bb_size
                bb.MaxDistance = props.bb_maxDistance
                label.TextScaled = props.label_textScaled
                label.TextWrapped = props.label_textWrapped
                label.AutomaticSize = props.label_automaticSize
                label.Size = props.label_size
                label.TextSize = props.label_textSize
            end
        end)
    end
    table.clear(plotTimers_OriginalProperties)
end

local function enablePlotTimers()
    disablePlotTimers()
    plotTimersEnabled = true
    local camera = Workspace.CurrentCamera
    local DISTANCE_THRESHOLD = 45
    local SCALE_START, SCALE_RANGE = 100, 300
    local MIN_TEXT_SIZE, MAX_TEXT_SIZE = 30, 36
    local lastUpdate = 0
    plotTimers_RenderConnection = RunService.RenderStepped:Connect(function()
        if not plotTimersEnabled then return end
        if tick() - lastUpdate < 0.1 then return end
        lastUpdate = tick()
        for _, label in ipairs(Workspace.Plots:GetDescendants()) do
            if label:IsA("TextLabel") and label.Name == "RemainingTime" then
                local bb = label:FindFirstAncestorWhichIsA("BillboardGui")
                if not bb then continue end
                local model = bb:FindFirstAncestorWhichIsA("Model")
                if not model then continue end
                local basePart = model:FindFirstChildWhichIsA("BasePart", true)
                if not basePart then continue end
                if not plotTimers_OriginalProperties[label] then
                    plotTimers_OriginalProperties[label] = {
                        bb_enabled = bb.Enabled,
                        bb_alwaysOnTop = bb.AlwaysOnTop,
                        bb_size = bb.Size,
                        bb_maxDistance = bb.MaxDistance,
                        label_textScaled = label.TextScaled,
                        label_textWrapped = label.TextWrapped,
                        label_automaticSize = label.AutomaticSize,
                        label_size = label.Size,
                        label_textSize = label.TextSize,
                    }
                end
                bb.MaxDistance = 10000
                bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0, 300, 0, 150)
                local distance = (camera.CFrame.Position - basePart.Position).Magnitude
                if distance > DISTANCE_THRESHOLD and basePart.Position.Y >= 0 then
                    bb.Enabled = false
                else
                    bb.Enabled = true
                    local t = math.clamp((distance - SCALE_START) / SCALE_RANGE, 0, 1)
                    label.TextSize = MIN_TEXT_SIZE + (MAX_TEXT_SIZE - MIN_TEXT_SIZE) * t
                end
            end
        end
    end)
end

-- // Main GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "BloomWARE"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 290)
frame.Position = UDim2.new(0.5, -110, 0.5, -145)
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
header.Text = "BLOOMWARE - SAB"
header.Font = Enum.Font.GothamBold
header.TextSize = 18
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.Parent = frame

-- // NEW: Desync Small Frame (The Popup)
local desyncPopup = Instance.new("Frame")
desyncPopup.Size = UDim2.new(0, 140, 0, 80)
desyncPopup.Position = UDim2.new(1, 10, 0, 0) -- Positioned to the right of main frame
desyncPopup.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
desyncPopup.BorderSizePixel = 0
desyncPopup.Visible = false -- Hidden by default
desyncPopup.Parent = frame

Instance.new("UICorner", desyncPopup).CornerRadius = UDim.new(0, 10)
local popupStroke = Instance.new("UIStroke")
popupStroke.Color = Color3.fromRGB(200, 60, 60)
popupStroke.Thickness = 2
popupStroke.Parent = desyncPopup

local popupTitle = Instance.new("TextLabel")
popupTitle.Size = UDim2.new(1, 0, 0, 25)
popupTitle.BackgroundTransparency = 1
popupTitle.Text = "Desync Menu"
popupTitle.Font = Enum.Font.GothamBold
popupTitle.TextSize = 12
popupTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
popupTitle.Parent = desyncPopup

local executeDesyncBtn = Instance.new("TextButton")
executeDesyncBtn.Size = UDim2.new(0, 110, 0, 35)
executeDesyncBtn.Position = UDim2.new(0.5, -55, 0.5, -5)
executeDesyncBtn.Text = "EXECUTE"
executeDesyncBtn.Font = Enum.Font.GothamBold
executeDesyncBtn.TextSize = 14
executeDesyncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
executeDesyncBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
executeDesyncBtn.BorderSizePixel = 0
executeDesyncBtn.Parent = desyncPopup
Instance.new("UICorner", executeDesyncBtn).CornerRadius = UDim.new(0, 6)

-- // Desync Main Button (The Trigger)
local desyncBtn = Instance.new("TextButton")
desyncBtn.Size = UDim2.new(0, 160, 0, 40)
desyncBtn.Position = UDim2.new(0.5, -80, 0, 45)
desyncBtn.Text = "Desync"
desyncBtn.Font = Enum.Font.GothamBold
desyncBtn.TextSize = 16
desyncBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
desyncBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
desyncBtn.BorderSizePixel = 0
desyncBtn.Parent = frame
Instance.new("UICorner", desyncBtn).CornerRadius = UDim.new(0, 10)

desyncBtn.MouseButton1Click:Connect(function()
    desyncPopup.Visible = not desyncPopup.Visible
end)

-- // Auto Kick Toggle
local autoKickToggle = Instance.new("TextButton")
autoKickToggle.Size = UDim2.new(0, 160, 0, 40)
autoKickToggle.Position = UDim2.new(0.5, -80, 0, 95)
autoKickToggle.Text = "Auto Kick: OFF"
autoKickToggle.Font = Enum.Font.GothamBold
autoKickToggle.TextSize = 16
autoKickToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoKickToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
autoKickToggle.BorderSizePixel = 0
autoKickToggle.Parent = frame
Instance.new("UICorner", autoKickToggle).CornerRadius = UDim.new(0, 10)

local isKickOn = false
autoKickToggle.MouseButton1Click:Connect(function()
    isKickOn = not isKickOn
    if isKickOn then
        autoKickToggle.Text = "Auto Kick: ON"
        autoKickToggle.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        enableAutoKick()
    else
        autoKickToggle.Text = "Auto Kick: OFF"
        autoKickToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        disableAutoKick()
    end
end)

-- // God Mode Toggle
local godToggle = Instance.new("TextButton")
godToggle.Size = UDim2.new(0, 160, 0, 40)
godToggle.Position = UDim2.new(0.5, -80, 0, 145)
godToggle.Text = "God Mode: OFF"
godToggle.Font = Enum.Font.GothamBold
godToggle.TextSize = 16
godToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
godToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
godToggle.BorderSizePixel = 0
godToggle.Parent = frame
Instance.new("UICorner", godToggle).CornerRadius = UDim.new(0, 10)

godToggle.MouseButton1Click:Connect(function()
    godModeEnabled = not godModeEnabled
    if godModeEnabled then
        godToggle.Text = "God Mode: ON"
        godToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        enableGodMode()
    else
        godToggle.Text = "God Mode: OFF"
        godToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        disableGodMode()
    end
end)

-- // Plot Timers Toggle
local plotTimersToggle = Instance.new("TextButton")
plotTimersToggle.Size = UDim2.new(0, 160, 0, 40)
plotTimersToggle.Position = UDim2.new(0.5, -80, 0, 195)
plotTimersToggle.Text = "Plot Timers: OFF"
plotTimersToggle.Font = Enum.Font.GothamBold
plotTimersToggle.TextSize = 16
plotTimersToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
plotTimersToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
plotTimersToggle.BorderSizePixel = 0
plotTimersToggle.Parent = frame
Instance.new("UICorner", plotTimersToggle).CornerRadius = UDim.new(0, 10)

local isPlotTimersOn = false
plotTimersToggle.MouseButton1Click:Connect(function()
    isPlotTimersOn = not isPlotTimersOn
    if isPlotTimersOn then
        plotTimersToggle.Text = "Plot Timers: ON"
        plotTimersToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
        enablePlotTimers()
    else
        plotTimersToggle.Text = "Plot Timers: OFF"
        plotTimersToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        disablePlotTimers()
    end
end)

-- Discord Label
local discordLabel = Instance.new("TextLabel")
discordLabel.Size = UDim2.new(1, -20, 0, 30)
discordLabel.Position = UDim2.new(0, 10, 1, -40)
discordLabel.BackgroundTransparency = 1
discordLabel.Text = "discord.gg/JMRC5wXhV9"
discordLabel.Font = Enum.Font.Gotham
discordLabel.TextSize = 14
discordLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
discordLabel.Parent = frame

-- // Desync Execution Function
local function performDesync()
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
end

-- Connect desync ONLY to the button inside the popup
executeDesyncBtn.MouseButton1Click:Connect(function()
    performDesync()
    desyncPopup.Visible = false -- Close popup after executing
end)

-- // Draggable GUI Logic
local dragging = false
local dragStart, startPos
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

-- Final Character check (Warning: Original script destroys character instantly)
local char = player.Character
if char then
    char:Destroy()
end
