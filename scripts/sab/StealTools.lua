local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")


-- Character setup
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Feature Toggles (default states)
local speedBoostEnabled = false
local autoKickEnabled = false
local playerESPEnabled = false
local godModeEnabled = false
local plotTimersEnabled = false

-- Speed Boost Vars
local BASE_SPEED = 55
local BOOST_MULTIPLIER = 0.5
local boosting = false
local attachment, linearVelocity

-- Auto Kick Vars
local keyword = "you stole"
local kickMessage = "You stole a pet!"
local connections = {}

-- Player ESP Vars
local espFolder
local espHighlights = {}
local espConnections = {}
local globalESPConnections = {}

-- Plot Timers Vars
local plotTimers_RenderConnection = nil
local plotTimers_OriginalProperties = {}

-- Colors
local OFF_COLOR = Color3.fromRGB(45, 45, 55)
local ON_COLOR = Color3.fromRGB(0, 200, 120)
local OFF_BG_TRANS = 0.75
local ON_BG_TRANS = 0.35

-- Speed setup
local function setupSpeed()
    if attachment then attachment:Destroy() end
    if linearVelocity then linearVelocity:Destroy() end

    attachment = Instance.new("Attachment", root)
    linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.MaxForce = math.huge
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    linearVelocity.Attachment0 = attachment
    linearVelocity.VectorVelocity = Vector3.zero
    linearVelocity.Enabled = boosting
    linearVelocity.Parent = root
end

-- Speed loop
local speedConn
local function startSpeedLoop()
    if speedConn then speedConn:Disconnect() end
    speedConn = RunService.RenderStepped:Connect(function()
        if not boosting then return end
        if humanoid and humanoid.MoveDirection.Magnitude > 0 then
            local dir = humanoid.MoveDirection
            dir = Vector3.new(dir.X, 0, dir.Z).Unit
            linearVelocity.VectorVelocity = dir * BASE_SPEED * BOOST_MULTIPLIER
        else
            linearVelocity.VectorVelocity = Vector3.zero
        end
    end)
end

local function toggleSpeed(enabled)
    speedBoostEnabled = enabled
    boosting = enabled
    if linearVelocity then linearVelocity.Enabled = enabled end
    if enabled then startSpeedLoop() end
end

-- Auto Kick
local function disconnectAll()
    for _, conn in pairs(connections) do
        if conn and conn.Connected then conn:Disconnect() end
    end
    connections = {}
end

local function kickPlayer()
    spawn(function()
        player:Kick(kickMessage)
    end)
end

local function hasKeyword(text)
    if typeof(text) ~= "string" then return false end
    return string.lower(text):find(keyword) ~= nil
end

local function scanAndWatchGui(gui)
    if not autoKickEnabled then return end
    for _, obj in ipairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            if hasKeyword(obj.Text) then
                kickPlayer()
                return
            end
            table.insert(connections, obj:GetPropertyChangedSignal("Text"):Connect(function()
                if autoKickEnabled and hasKeyword(obj.Text) then
                    kickPlayer()
                end
            end))
        end
    end

    table.insert(connections, gui.DescendantAdded:Connect(function(desc)
        if not autoKickEnabled then return end
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            if hasKeyword(desc.Text) then
                kickPlayer()
            end
            table.insert(connections, desc:GetPropertyChangedSignal("Text"):Connect(function()
                if autoKickEnabled and hasKeyword(desc.Text) then
                    kickPlayer()
                end
            end))
        end
    end))
end

local function enableProtection()
    disconnectAll()
    autoKickEnabled = true
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        scanAndWatchGui(gui)
    end
    table.insert(connections, PlayerGui.ChildAdded:Connect(scanAndWatchGui))
end

local function disableProtection()
    autoKickEnabled = false
    disconnectAll()
end

local function toggleProtection(enabled)
    if enabled then enableProtection() else disableProtection() end
end

-- Player ESP
local function createHighlight(char)
    local existing = espHighlights[char]
    if existing then existing:Destroy() end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 100, 100)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = espFolder
    espHighlights[char] = highlight
end

local function addESP(plr)
    if plr == player or not playerESPEnabled then return end
    local function onCharAdded(char)
        createHighlight(char)
    end
    if plr.Character then onCharAdded(plr.Character) end
    espConnections[plr] = plr.CharacterAdded:Connect(onCharAdded)
end

local function removeESP(plr)
    local conn = espConnections[plr]
    if conn then conn:Disconnect() espConnections[plr] = nil end
    local char = plr.Character
    if char and espHighlights[char] then
        espHighlights[char]:Destroy()
        espHighlights[char] = nil
    end
end

local function toggleESP(enabled)
    playerESPEnabled = enabled
    if enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then addESP(plr) end
        end
        table.insert(globalESPConnections, Players.PlayerAdded:Connect(addESP))
        table.insert(globalESPConnections, Players.PlayerRemoving:Connect(removeESP))
    else
        for plr in pairs(espConnections) do removeESP(plr) end
        espConnections = {}
        for _, conn in ipairs(globalESPConnections) do
            if conn.Connected then conn:Disconnect() end
        end
        globalESPConnections = {}
    end
end



-- God Mode
local healthConn
local function enableGodMode()
    if godModeEnabled then return end
    godModeEnabled = true
    if humanoid then
        if healthConn then healthConn:Disconnect() end
        humanoid.Health = humanoid.MaxHealth
        healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            humanoid.Health = humanoid.MaxHealth
        end)
    end
end

local function disableGodMode()
    godModeEnabled = false
    if healthConn then healthConn:Disconnect() healthConn = nil end
end

local function toggleGodMode(enabled)
    if enabled then enableGodMode() else disableGodMode() end
end

-- Plot Timers
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

local function togglePlotTimers(enabled)
    if enabled then enablePlotTimers() else disablePlotTimers() end
end

--jump boost
local boostJumpEnabled = false
local boostJumpConnection = nil

local jumpCooldown = false

local BASE_BOOST = 55
local SPEED_SCALE = 0.45
local COOLDOWN_TIME = 0.25

local function applyBoostJump()
    if jumpCooldown or not humanoid or not root then return end
    jumpCooldown = true

    local moveSpeed = humanoid.MoveDirection.Magnitude
    local boost = BASE_BOOST + (moveSpeed * BASE_BOOST * SPEED_SCALE)

    root.AssemblyLinearVelocity = Vector3.new(
        root.AssemblyLinearVelocity.X,
        boost,
        root.AssemblyLinearVelocity.Z
    )

    local fallConn
    fallConn = RunService.Stepped:Connect(function()
        if not boostJumpEnabled or not humanoid or not root then
            fallConn:Disconnect()
            return
        end

        if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            local v = root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity = Vector3.new(
                v.X,
                math.clamp(v.Y, -28, 115),
                v.Z
            )
        else
            fallConn:Disconnect()
        end
    end)

    task.delay(COOLDOWN_TIME, function()
        jumpCooldown = false
    end)
end


local function toggleBoostJump(enabled)
    boostJumpEnabled = enabled

    if enabled then
        if boostJumpConnection then
            boostJumpConnection:Disconnect()
        end

        boostJumpConnection =
            UserInputService.JumpRequest:Connect(applyBoostJump)

    else
        if boostJumpConnection then
            boostJumpConnection:Disconnect()
            boostJumpConnection = nil
        end
    end
end



-- GUI Setup
pcall(function() CoreGui:FindFirstChild("BloomWareHub"):Destroy() end)
pcall(function() Workspace:FindFirstChild("BloomESP"):Destroy() end)

espFolder = Instance.new("Folder")
espFolder.Name = "BloomESP"
espFolder.Parent = Workspace

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BloomWareHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 300)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BackgroundTransparency = 0.5
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Title Bar
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
titleBar.BackgroundTransparency = 0.6
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "BloomWare - Steal Tools"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15

-- MINIMIZE BUTTON
local minimized = false
local fullSize = frame.Size

local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 28, 0, 28)
minimizeBtn.Position = UDim2.new(1, -34, 0.5, -14)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
minimizeBtn.BackgroundTransparency = 0.2
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 6)

-- Content container
local togglesFrame = Instance.new("Frame", frame)
togglesFrame.Size = UDim2.new(1, -20, 1, -55)
togglesFrame.Position = UDim2.new(0, 10, 0, 40)
togglesFrame.BackgroundTransparency = 1

local togglesLayout = Instance.new("UIListLayout", togglesFrame)
toglesLayout = togglesLayout -- avoid warnings
togglesLayout.Padding = UDim.new(0, 5)

-- Minimize toggle handler
minimizeBtn.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        fullSize = frame.Size
        togglesFrame.Visible = false
        frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 38)
        minimizeBtn.Text = "+"
    else
        togglesFrame.Visible = true
        frame.Size = fullSize
        minimizeBtn.Text = "-"
    end
end)

-- Toggle factory
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function createToggle(labelText, callback, defaultState)
    local row = Instance.new("Frame", togglesFrame)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 160, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("Frame", row)
    toggleBg.Size = UDim2.new(0, 52, 0, 28)
    toggleBg.Position = UDim2.new(1, -60, 0.5, -14)
    toggleBg.BackgroundColor3 = defaultState and ON_COLOR or OFF_COLOR
    toggleBg.BackgroundTransparency = defaultState and ON_BG_TRANS or OFF_BG_TRANS
    toggleBg.BorderSizePixel = 0
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 14)

    local slider = Instance.new("Frame", toggleBg)
    slider.Size = UDim2.new(0, 22, 0, 22)
    slider.Position = defaultState and UDim2.new(0, 27, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
    slider.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    slider.BorderSizePixel = 0
    Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 11)

    local btn = Instance.new("TextButton", toggleBg)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local isOn = defaultState
    btn.Activated:Connect(function()
        isOn = not isOn
        TweenService:Create(toggleBg, tweenInfo, {
            BackgroundColor3 = isOn and ON_COLOR or OFF_COLOR,
            BackgroundTransparency = isOn and ON_BG_TRANS or OFF_BG_TRANS
        }):Play()
        TweenService:Create(slider, tweenInfo, {
            Position = isOn and UDim2.new(0, 27, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
        }):Play()
        callback(isOn)
    end)

    if defaultState then callback(true) end
end

-- Create toggles
createToggle("Speed Boost", toggleSpeed, speedBoostEnabled)
createToggle("Jump Boost", toggleBoostJump, boostJumpEnabled)
createToggle("Auto Kick", toggleProtection, autoKickEnabled)
createToggle("Player ESP", toggleESP, playerESPEnabled)
createToggle("Plot Timers", togglePlotTimers, plotTimersEnabled)

local xrayEnabled = false
local originalTransparency = {}

local function XrayOn(obj)
    for _, v in pairs(obj:GetChildren()) do
        if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
            if originalTransparency[v] == nil then
                originalTransparency[v] = v.LocalTransparencyModifier
            end
            v.LocalTransparencyModifier = 0.75
        end
        XrayOn(v)
    end
end

local function XrayOff(obj)
    for _, v in pairs(obj:GetChildren()) do
        if v:IsA("BasePart") and originalTransparency[v] ~= nil then
            v.LocalTransparencyModifier = originalTransparency[v]
            originalTransparency[v] = nil
        end
        XrayOff(v)
    end
end

local function toggleXray(enabled)
    xrayEnabled = enabled
    if enabled then
        XrayOn(Workspace)
    else
        XrayOff(Workspace)
    end
end

createToggle("Xray", toggleXray, xrayEnabled)

--float
local floatingEnabled = false
local floor = nil
local heartbeatConn = nil
local char = nil

local smoothBase = 7 -- responsiveness (higher = faster follow)

local function makeFloor()
    if floor then return end

    floor = Instance.new("Part")
    floor.Name = "FloatingPlatform"
    floor.Size = Vector3.new(12, 0.3, 12)
    floor.Material = Enum.Material.Neon
    floor.BrickColor = BrickColor.new("Really white")
    floor.Anchored = true
    floor.CanCollide = true
    floor.CastShadow = false
    floor.CFrame = CFrame.new(0, -1000, 0)

    local tex = Instance.new("Decal")
    tex.Texture = "rbxassetid://14650903579"
    tex.Parent = floor

    floor.Parent = workspace
end

local function updateFloorPos(dt)
    if not floatingEnabled then return end
    if not floor or not floor.Parent then return end
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local targetPos = Vector3.new(
        root.Position.X,
        root.Position.Y - 0.35,
        root.Position.Z
    )

    local currentPos = floor.Position
    local distance = (targetPos - currentPos).Magnitude

    -- snap instantly if too far (no waiting delay)
    if distance > 14 then
        floor.CFrame = CFrame.new(targetPos)
        return
    end

    -- adaptive smoothing
    -- farther = faster catch-up
    -- closer = floaty glide
    local boost = math.clamp(distance / 5, 0.6, 3)
    local alpha = math.clamp(dt * smoothBase * boost, 0, 1)

    local newPos = currentPos:Lerp(targetPos, alpha)
    floor.CFrame = CFrame.new(newPos)
end

local function enableFloat()
    floatingEnabled = true
    char = player.Character or player.CharacterAdded:Wait()

    makeFloor()

    -- snap instantly on enable
    local root = char:WaitForChild("HumanoidRootPart")
    floor.CFrame = CFrame.new(
        root.Position.X,
        root.Position.Y - 0.35,
        root.Position.Z
    )

    heartbeatConn = RunService.Heartbeat:Connect(updateFloorPos)
end

local function disableFloat()
    floatingEnabled = false

    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end

    if floor then
        floor:Destroy()
        floor = nil
    end
end

local function toggleFloat(enabled)
    if enabled then enableFloat() else disableFloat() end
end

createToggle("Float", toggleFloat, floatingEnabled)

-- Respawn handler
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    setupSpeed()
    if speedBoostEnabled then boosting = true startSpeedLoop() end
    if godModeEnabled then enableGodMode() end
    if boostJumpEnabled then toggleBoostJump(true) end
end)

setupSpeed()
