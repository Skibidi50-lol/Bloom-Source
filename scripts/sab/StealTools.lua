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


local Luna = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/luna", true))()
local Window = Luna:CreateWindow({
    Name = "BloomWare - SAB", -- This Is Title Of Your Window
    Subtitle = "Version 1.0", -- A Gray Subtitle next To the main title.
    LogoID = "82795327169782", -- The Asset ID of your logo. Set to nil if you do not have a logo for Luna to use.
    LoadingEnabled = true, -- Whether to enable the loading animation. Set to false if you do not want the loading screen or have your own custom one.
    LoadingTitle = "Loading....", -- Header for loading screen
    LoadingSubtitle = "by Skibidi50-lol", -- Subtitle for loading screen

    ConfigSettings = {
        RootFolder = nil, -- The Root Folder Is Only If You Have A Hub With Multiple Game Scripts and u may remove it. DO NOT ADD A SLASH
        ConfigFolder = "BloomHub" -- The Name Of The Folder Where Luna Will Store Configs For This Script. DO NOT ADD A SLASH
    },

    KeySystem = false, -- As Of Beta 6, Luna Has officially Implemented A Key System!
    KeySettings = {
        Title = "Luna Example Key",
        Subtitle = "Key System",
        Note = "Best Key System Ever! Also, Please Use A HWID Keysystem like Pelican, Luarmor etc. that provide key strings based on your HWID since putting a simple string is very easy to bypass",
        SaveInRoot = false, -- Enabling will save the key in your RootFolder (YOU MUST HAVE ONE BEFORE ENABLING THIS OPTION)
        SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
        Key = {"Example Key"}, -- List of keys that will be accepted by the system, please use a system like Pelican or Luarmor that provide key strings based on your HWID since putting a simple string is very easy to bypass
        SecondAction = {
            Enabled = true, -- Set to false if you do not want a second action,
            Type = "Link", -- Link / Discord.
            Parameter = "" -- If Type is Discord, then put your invite link (DO NOT PUT DISCORD.GG/). Else, put the full link of your key system here.
        }
    }
})


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
--auto kick
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
--No anim
local animationsDisabled = false
local animationConnections = {}

local function clearAnimConnections()
	for _, c in ipairs(animationConnections) do
		if c.Connected then c:Disconnect() end
	end
	table.clear(animationConnections)
end

local function applyNoAnimations(humanoid)
	if not humanoid then return end

	-- stop everything currently running
	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:Stop()
	end

	-- block new animations
	local conn = humanoid.AnimationPlayed:Connect(function(track)
        if animationsDisabled then
            track:Stop()
        end
	end)

	table.insert(animationConnections, conn)
end

local function toggleNoAnimations(enabled)
	animationsDisabled = enabled
	clearAnimConnections()

	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	if enabled then
		applyNoAnimations(humanoid)
	end
end

-- re-apply after respawn when enabled
player.CharacterAdded:Connect(function(char)
	if not animationsDisabled then return end
	local humanoid = char:WaitForChild("Humanoid")
	applyNoAnimations(humanoid)
end)


--steal tab
local StealTab = Window:CreateTab({
    Name = "Stealer",
    Icon = "mobile_theft",
    ImageSource = "Material",
    ShowTitle = true -- This will determine whether the big header text in the tab will show
})

StealTab:CreateSection("Steal Helper")

StealTab:CreateButton({
    Name = "Desync No Tool",
    Description = "May Causing Bugs",
    Callback = function()
        performDesync()
    end
})

StealTab:CreateToggle({
    Name = "Auto Kick After Steal",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        autoKickEnabled = Value
    end
}, "AutoKickToggle")

StealTab:CreateToggle({
    Name = "Infinite Jump",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        boostJumpEnabled = Value
        toggleBoostJump(Value)
    end
}, "InfJumpToggle")

StealTab:CreateToggle({
    Name = "Remove Animations",
    Description = "Remove All Of Your Animations",
    CurrentValue = false,
    Callback = function(Value)
        animationsDisabled = Value
        toggleNoAnimations(Value)
    end
}, "AnimToggle")
--Handler
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    root = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    if boostJumpEnabled then toggleBoostJump(true) end
end)
