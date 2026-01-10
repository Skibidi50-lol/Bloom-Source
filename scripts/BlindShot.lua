local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()


local Window = Library:CreateWindow({
    Title = 'BloomWare - Blind Shot',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

--esp
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    LineDistance = 500,
    LineThickness = 2,
    LineThicknessAlert = 4,
    NormalColor = Color3.fromRGB(255, 80, 80),
    AlertColor = Color3.fromRGB(255, 0, 0),
    DetectionRadius = 3.2,
    EnableVFX = false,
    FlashSpeed = 2,
    VignetteIntensity = 0.35,
    HeadCircleRadius = 12,
    HeadBoxSize = 24,
}

local playerLines = {}
local playerHeadCircles = {}
local playerHeadBoxes = {}
local playerNameTags = {}
local warningUI = nil
local connections = {}
local isRunning = true

--Enabled variables
local ENABLE_LINES = false
local ENABLE_HEAD_CIRCLE = false
local ENABLE_HEAD_BOX = false
local ENABLE_NAMES = false

local function createWarningUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LookWarningVFX"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999

    local vignette = Instance.new("Frame")
    vignette.Name = "Vignette"
    vignette.Size = UDim2.new(1, 0, 1, 0)
    vignette.BackgroundTransparency = 1
    vignette.BorderSizePixel = 0
    vignette.Parent = screenGui

    local warningText = Instance.new("TextLabel")
    warningText.Name = "WarningText"
    warningText.Size = UDim2.new(0, 340, 0, 60)
    warningText.Position = UDim2.new(0.5, -170, 0.08, 0)
    warningText.BackgroundTransparency = 1
    warningText.Text = "WARNING: SOMEONE IS LOOKING AT YOU"
    warningText.TextColor3 = Color3.fromRGB(255, 40, 40)
    warningText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    warningText.TextStrokeTransparency = 0.1
    warningText.Font = Enum.Font.GothamBold
    warningText.TextSize = 35
    warningText.TextTransparency = 1
    warningText.Parent = screenGui

    local directionIndicator = Instance.new("TextLabel")
    directionIndicator.Name = "DirectionIndicator"
    directionIndicator.Size = UDim2.new(0, 400, 0, 40)
    directionIndicator.Position = UDim2.new(0.5, -200, 0.16, 0)
    directionIndicator.BackgroundTransparency = 1
    directionIndicator.Text = ""
    directionIndicator.TextColor3 = Color3.fromRGB(255, 160, 160)
    directionIndicator.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    directionIndicator.TextStrokeTransparency = 0.4
    directionIndicator.Font = Enum.Font.Gotham
    directionIndicator.TextSize = 18
    directionIndicator.TextTransparency = 1
    directionIndicator.Parent = screenGui

    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)

    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    return {
        Gui = screenGui,
        Vignette = vignette,
        Text = warningText,
        Direction = directionIndicator
    }
end

local function createDrawingLine()
    local line = Drawing.new("Line")
    line.Visible = false
    line.Transparency = 0.7
    return line
end

local function createHeadCircle()
    local circle = Drawing.new("Circle")
    circle.Visible = false
    circle.Filled = false
    circle.Transparency = 0.75
    return circle
end

local function createHeadBox()
    local lines = {}
    for _ = 1, 4 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Transparency = 0.75
        table.insert(lines, line)
    end
    return lines
end

local function createNameTag()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    return text
end

local function checkIfLookingAtMe(player)
    local character = player.Character
    local myCharacter = LocalPlayer.Character

    if not character or not myCharacter then
        return false, nil, nil
    end

    local head = character:FindFirstChild("Head")
    local myHRP = myCharacter:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not head or not myHRP or not humanoid or humanoid.Health <= 0 then
        return false, nil, nil
    end

    local lookVector = head.CFrame.LookVector
    local eyePosition = head.Position + Vector3.new(0, 0.4, 0) -- slightly more realistic eye level

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {character, myCharacter} -- also exclude yourself

    local rayResult = workspace:Raycast(eyePosition, lookVector * CONFIG.LineDistance, rayParams)

    if rayResult then
        local hitModel = rayResult.Instance:FindFirstAncestorWhichIsA("Model")
        if hitModel == myCharacter then
            return true, eyePosition, rayResult.Position
        end
    end

    -- Fallback - cone check
    local toMe = (myHRP.Position - eyePosition).Unit
    local dot = lookVector:Dot(toMe)
    local distance = (myHRP.Position - eyePosition).Magnitude

    if dot > 0.985 and distance < CONFIG.LineDistance then
        local projection = eyePosition + lookVector * (distance * dot)
        local perpDistance = (myHRP.Position - projection).Magnitude

        if perpDistance < CONFIG.DetectionRadius then
            return true, eyePosition, myHRP.Position
        end
    end

    return false, nil, nil
end

local function drawHeadBox(boxLines, center, size, color, visible)
    if not visible then
        for _, line in ipairs(boxLines) do line.Visible = false end
        return
    end

    local hs = size / 2
    local corners = {
        Vector2.new(center.X - hs, center.Y - hs),
        Vector2.new(center.X + hs, center.Y - hs),
        Vector2.new(center.X + hs, center.Y + hs),
        Vector2.new(center.X - hs, center.Y + hs),
    }

    local order = {1,2, 2,3, 3,4, 4,1}
    for i = 1, 8, 2 do
        local a, b = order[i], order[i+1]
        boxLines[(i+1)/2].From = corners[a]
        boxLines[(i+1)/2].To = corners[b]
        boxLines[(i+1)/2].Color = color
        boxLines[(i+1)/2].Visible = true
    end
end

local function updateSystem()
    if not isRunning then return end

    local camera = workspace.CurrentCamera
    local watchingPlayers = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        -- Initialize drawings if needed
        if not playerLines[player] then
            playerLines[player] = createDrawingLine()
            playerHeadCircles[player] = createHeadCircle()
            playerHeadBoxes[player] = createHeadBox()
            playerNameTags[player] = createNameTag()
        end

        local line = playerLines[player]
        local circle = playerHeadCircles[player]
        local box = playerHeadBoxes[player]
        local nameTag = playerNameTags[player]

        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if not head or not hum or hum.Health <= 0 then
            line.Visible = false
            circle.Visible = false
            drawHeadBox(box, Vector2.zero, 0, Color3.new(), false)
            nameTag.Visible = false
            continue
        end

        local isLooking, startPos3D, endPos3D = checkIfLookingAtMe(player)
        local headPos2D, onScreen = camera:WorldToViewportPoint(head.Position)

        if not onScreen or headPos2D.Z < 0.01 then
            line.Visible = false
            circle.Visible = false
            drawHeadBox(box, Vector2.zero, 0, Color3.new(), false)
            nameTag.Visible = false
            continue
        end

        local distanceFactor = math.clamp(60 / headPos2D.Z, 0.4, 2.2)
        local pulse = isLooking and math.abs(math.sin(tick() * CONFIG.FlashSpeed)) or 0

        local currentColor = isLooking and CONFIG.AlertColor or CONFIG.NormalColor

        -- Head Circle
        if ENABLE_HEAD_CIRCLE then
            circle.Position = Vector2.new(headPos2D.X, headPos2D.Y)
            circle.Radius = CONFIG.HeadCircleRadius * distanceFactor + (pulse * 5)
            circle.Color = currentColor
            circle.Thickness = isLooking and 3 or 2
            circle.Visible = true
        else
            circle.Visible = false
        end

        -- Head Box
        if ENABLE_HEAD_BOX then
            drawHeadBox(
                box,
                Vector2.new(headPos2D.X, headPos2D.Y),
                CONFIG.HeadBoxSize * distanceFactor + (pulse * 8),
                currentColor,
                true
            )
        else
            drawHeadBox(box, Vector2.zero, 0, Color3.new(), false)
        end

        -- Name tag
        if ENABLE_NAMES then
            nameTag.Text = player.Name
            nameTag.Position = Vector2.new(headPos2D.X, headPos2D.Y - circle.Radius - 18)
            nameTag.Color = currentColor
            nameTag.Size = math.clamp(14 * distanceFactor, 11, 19)
            nameTag.Visible = true
        else
            nameTag.Visible = false
        end

        -- Looking line
        if ENABLE_LINES and startPos3D and endPos3D then
            local start2D = camera:WorldToViewportPoint(startPos3D)
            local end2D = camera:WorldToViewportPoint(endPos3D)

            if start2D.Z > 0 then
                line.From = Vector2.new(start2D.X, start2D.Y)
                line.To = Vector2.new(end2D.X, end2D.Y)
                line.Color = currentColor
                line.Thickness = isLooking and (CONFIG.LineThicknessAlert + pulse * 2.5) or CONFIG.LineThickness
                line.Transparency = isLooking and (0.35 + pulse * 0.35) or 0.65
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end

        if isLooking then
            table.insert(watchingPlayers, player)
        end
    end

    -- Warning UI
    if warningUI and CONFIG.EnableVFX then
        local isWatched = #watchingPlayers > 0

        if isWatched then
            local pulse = math.abs(math.sin(tick() * CONFIG.FlashSpeed))

            warningUI.Vignette.BackgroundColor3 = CONFIG.AlertColor
            warningUI.Vignette.BackgroundTransparency = 1 - (CONFIG.VignetteIntensity * (0.4 + pulse * 0.6))

            warningUI.Text.TextTransparency = 0.15 + pulse * 0.25
            warningUI.Text.TextSize = 28 + pulse * 5

            local names = {}
            for _, p in watchingPlayers do
                table.insert(names, p.Name)
            end
            warningUI.Direction.Text = "by: " .. table.concat(names, ", ")
            warningUI.Direction.TextTransparency = 0.25 + pulse * 0.15
        else
            warningUI.Vignette.BackgroundTransparency = 1
            warningUI.Text.TextTransparency = 1
            warningUI.Direction.TextTransparency = 1
        end
    end
end

local function cleanupPlayer(player)
    if playerLines[player] then
        playerLines[player]:Remove()
        playerLines[player] = nil
    end
    if playerHeadCircles[player] then
        playerHeadCircles[player]:Remove()
        playerHeadCircles[player] = nil
    end
    if playerHeadBoxes[player] then
        for _, ln in playerHeadBoxes[player] do ln:Remove() end
        playerHeadBoxes[player] = nil
    end
    if playerNameTags[player] then
        playerNameTags[player]:Remove()
        playerNameTags[player] = nil
    end
end

local function fullCleanup()
    isRunning = false

    for _, conn in connections do
        pcall(conn.Disconnect, conn)
    end
    table.clear(connections)

    for player in pairs(playerLines) do
        cleanupPlayer(player)
    end

    if warningUI and warningUI.Gui then
        warningUI.Gui:Destroy()
        warningUI = nil
    end
end

-- Initialize
warningUI = createWarningUI()

-- Connections
table.insert(connections, Players.PlayerRemoving:Connect(cleanupPlayer))
table.insert(connections, RunService.RenderStepped:Connect(updateSystem))

-- Stop handler
spawn(function()
    while isRunning do
        task.wait(0.6)
        if _G.StopLookChams then
            fullCleanup()
            _G.StopLookChams = false
            break
        end
    end
end)
--aimbos
local aimbotEnabled = false
local aimAtPart = "Head"
local wallCheckEnabled = false
local teamCheckEnabled = false
local fovEnabled = false
local fovRadius = 50
local fovVisible = false

local fovColor = Color3.fromRGB(0, 255, 0)
local fovFillColor = Color3.fromRGB(0, 150, 0)
local fovThickness = 1
local fovFillTransparency = 0.25
local fovOutlineTransparency = 0.9
local fovNumSides = 150

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local localRoot = character:WaitForChild("HumanoidRootPart")

-- FOV Circles
local fovCircleFill = Drawing.new("Circle")
local fovCircleOutline = Drawing.new("Circle")

fovCircleFill.Filled = true
fovCircleFill.Color = fovFillColor
fovCircleFill.Transparency = fovFillTransparency
fovCircleFill.NumSides = fovNumSides
fovCircleFill.Radius = fovRadius
fovCircleFill.Visible = false

fovCircleOutline.Filled = false
fovCircleOutline.Color = fovColor
fovCircleOutline.Transparency = fovOutlineTransparency
fovCircleOutline.Thickness = fovThickness
fovCircleOutline.NumSides = fovNumSides
fovCircleOutline.Radius = fovRadius
fovCircleOutline.Visible = false

-- Helper: Check if target is inside FOV circle
local function isInFOV(targetPosition)
    if not fovEnabled then return true end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPosition)
    if not onScreen then return false end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    
    return distanceFromCenter <= fovRadius
end

-- Update FOV visuals
local function updateFOV()
    if not fovVisible then
        fovCircleFill.Visible = false
        fovCircleOutline.Visible = false
        return
    end
    
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircleFill.Position = center
    fovCircleOutline.Position = center
    
    fovCircleFill.Visible = aimbotEnabled
    fovCircleOutline.Visible = aimbotEnabled
end

-- Get closest valid target
local function getClosestTarget()
    local nearestTarget = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player == localPlayer then continue end
        if teamCheckEnabled and player.Team == localPlayer.Team then continue end
        
        local char = player.Character
        if not char then continue end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local targetPart = char:FindFirstChild(aimAtPart)
        
        if not humanoid or not targetPart or humanoid.Health <= 0 then continue end
        
        -- FOV check
        if not isInFOV(targetPart.Position) then continue end

        local distance = (targetPart.Position - localRoot.Position).Magnitude
        
        if distance < shortestDistance then
            if wallCheckEnabled then
                local rayDirection = (targetPart.Position - Camera.CFrame.Position).Unit * 1500
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                
                local result = workspace:Raycast(Camera.CFrame.Position, rayDirection, rayParams)
                
                if result and result.Instance:IsDescendantOf(char) then
                    shortestDistance = distance
                    nearestTarget = char
                end
            else
                shortestDistance = distance
                nearestTarget = char
            end
        end
    end
    
    return nearestTarget
end

-- Smooth camera look-at
local function lookAt(targetPosition)
    if not targetPosition then return end
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
end

-- Main loop
local mainConnection = RunService.RenderStepped:Connect(function()
    updateFOV()
    
    if not aimbotEnabled then return end
    
    local target = getClosestTarget()
    if target then
        local targetPart = target:FindFirstChild(aimAtPart)
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        if targetPart and humanoid and humanoid.Health > 0 then
            lookAt(targetPart.Position)
        end
    end
end)

-- Handle respawn
localPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    localRoot = newChar:WaitForChild("HumanoidRootPart")
end)

local Tabs = {
    Main = Window:AddTab('Main'),
    Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

--main

local TabBoxAimbot = Tabs.Main:AddLeftTabbox()

local AimbotTAB = TabBoxAimbot:AddTab('Aimbot')


AimbotTAB:AddToggle('AimbotToggle', {
    Text = 'Aimbot',
    Default = false, -- Default value (true / false)
    Tooltip = 'Auto Aim', -- Information shown when you hover over the toggle

    Callback = function(Value)
        aimbotEnabled = Value
    end
})

AimbotTAB:AddToggle('AimbotFOVToggle', {
    Text = 'FOV Circle',
    Default = false, -- Default value (true / false)
    Tooltip = 'Draw A Circle', -- Information shown when you hover over the toggle

    Callback = function(Value)
        fovVisible = Value
        fovEnabled = Value
    end
})

AimbotTAB:AddToggle('AimbotWallToggle', {
    Text = 'Visibility Check',
    Default = false, -- Default value (true / false)
    Tooltip = 'Check If The Player Is In Your Screen Or Not', -- Information shown when you hover over the toggle

    Callback = function(Value)
        wallCheckEnabled = Value
    end
})

local plrBox = Tabs.Main:AddLeftGroupbox('Players')


plrBox:AddToggle('AntiVoidToggle', {
    Text = 'Anti Void UI',
    Default = false, -- Default value (true / false)
    Tooltip = 'Create A PlatForm To Not Let You Fall', -- Information shown when you hover over the toggle

    Callback = function(Value)
        local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

-- Remove old GUI
local old = CoreGui:FindFirstChild("DeltaToggleGui")
if old then old:Destroy() end

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "DeltaToggleGui"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

-- Draggable tiny button
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 44, 0, 44)
btn.Position = UDim2.new(1, -60, 0, 20)
btn.AnchorPoint = Vector2.new(1, 0)
btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)  -- red = off
btn.Text = ""
btn.BorderSizePixel = 0
btn.ZIndex = 9999
btn.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = btn

-- Dragging (works on touch & mouse)
local dragging, dragInput, dragStart, startPos

btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = btn.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        btn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Toggle platform (using .Activated - best for mobile + PC)
local function togglePlatform()
    local existing = cam:FindFirstChild("DeltaClientNet")
    
    if existing then
        existing:Destroy()
        btn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)   -- off
    else
        local plate = Instance.new("Part")
        plate.Name = "DeltaClientNet"
        plate.Size = Vector3.new(10000, 2, 10000)
        plate.CFrame = CFrame.new(0, -8, 0)
        plate.Anchored = true
        plate.CanCollide = true
        plate.Transparency = 0.35
        plate.Color = Color3.fromRGB(40, 230, 100)
        plate.Material = Enum.Material.Neon
        plate.Parent = cam
        
        btn.BackgroundColor3 = Color3.fromRGB(60, 255, 100)  -- on
    end
end

btn.Activated:Connect(togglePlatform)
    end
})
--esp
getgenv().esp = false
local RunService = game:GetService("RunService")
local plr = game.Players.LocalPlayer
RunService.RenderStepped:Connect(function()
	if getgenv().esp == true then
		for _, plrs in pairs(game.Players:GetPlayers()) do
			if plrs ~= plr then
				local chars = plrs.Character
				if chars then
					for _, obj in pairs(chars:GetDescendants()) do
						if obj:IsA("BasePart") then
							if obj then
								if obj.Name ~= "hitbox" and obj.Name ~= "HumanoidRootPart" then
									if obj.Transparency ~= 0 then
										obj.Transparency = 0
									end
								end
							end
						elseif obj:IsA("Beam") then
							if obj then
								if obj.Enabled == false then
									obj.Enabled = true
								end
							end
						elseif obj:IsA("BillboardGui") and obj.Name == "OrdemBillboard" then
							if obj then
								if obj.Enabled == false then
									obj.Enabled = true
								end
							end
						end
					end
				end
			end
		end
	end
end)

local trophyBox = Tabs.Main:AddRightGroupbox('Auto Farm')

local player = game.Players.LocalPlayer



trophyBox:AddToggle('AutoTrophyToggle', {
    Text = 'Auto Farm Money',
    Default = false, -- Default value (true / false)
    Tooltip = 'Auto Farming Money For You', -- Information shown when you hover over the toggle

    Callback = function(Value)
        getgenv().TrophyFarm = Value
        while getgenv().TrophyFarm do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local trophyPart = workspace:FindFirstChild("Trophy", true)
                        
            if trophyPart and hrp then
                firetouchinterest(hrp, trophyPart, 0)
                    task.wait()
                firetouchinterest(hrp, trophyPart, 1)
            end
            task.wait(0.3)
        end
    end
})

getgenv().AutoRandomWalk = false

trophyBox:AddToggle('AutoWalkToggle', {
    Text = 'Auto Walk',
    Default = false, -- Default value (true / false)
    Tooltip = 'Auto Walking For You', -- Information shown when you hover over the toggle

    Callback = function(Value)
       getgenv().AutoRandomWalk = Value

        local player = game.Players.LocalPlayer
        local RunService = game:GetService("RunService")

        spawn(function()
            while true do
                if not getgenv().AutoRandomWalk then
                    task.wait(1)
                    continue
                end

                local char = player.Character
                if not char then 
                    task.wait(1.5) 
                    continue 
                end

                local hrp = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChild("Humanoid")

                if not (hrp and humanoid and humanoid.Health > 0) then
                    task.wait(1.5)
                    continue
                end

                -- Random position around current location (10-35 studs away)
                local randomAngle = math.random() * math.pi * 2
                local randomDist = math.random(10, 35)
                
                local offset = Vector3.new(
                    math.cos(randomAngle) * randomDist,
                    0,
                    math.sin(randomAngle) * randomDist
                )
                
                local targetPos = hrp.Position + offset
                
                local ray = Ray.new(targetPos + Vector3.new(0, 50, 0), Vector3.new(0, -100, 0))
                local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {char})
                
                if hit then
                    targetPos = pos + Vector3.new(0, 3, 0)
                end

                humanoid:MoveTo(targetPos)
                
                local waitTime = math.random(3, 8) * 0.1   -- 0.3 to 0.8 seconds
                task.wait(waitTime)
            end
        end)
    end
})

trophyBox:AddToggle('AntiAFKToggle', {
    Text = 'Anti AFK',
    Default = false,
    Tooltip = 'Prevents Roblox from kicking you for being idle',

    Callback = function(Value)
        if Value then
            local vu = game:GetService("VirtualUser")
            local player = game:GetService("Players").LocalPlayer
            getgenv().AntiAFKConnection = player.Idled:Connect(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        else
            if getgenv().AntiAFKConnection then
                getgenv().AntiAFKConnection:Disconnect()
                getgenv().AntiAFKConnection = nil
            end
        end
    end
})


local espBox = Tabs.Visuals:AddLeftGroupbox('Player ESP')
espBox:AddToggle('PlayerESPToggle', {
    Text = 'Players ESP',
    Default = false, -- Default value (true / false)
    Tooltip = 'Show All Player', -- Information shown when you hover over the toggle

    Callback = function(Value)
        getgenv().esp = Value
    end
})

local TabBoxHead = Tabs.Visuals:AddLeftTabbox()

local HeadESP = TabBoxHead:AddTab('Head ESP')

HeadESP:AddToggle('NamesESPToggle', {
    Text = 'Names ESP',
    Default = false, -- Default value (true / false)
    Tooltip = 'Show other player Names', -- Information shown when you hover over the toggle

    Callback = function(Value)
        ENABLE_NAMES = Value
    end
})

HeadESP:AddToggle('HeadBoxESPToggle', {
    Text = 'Head Box ESP',
    Default = false, -- Default value (true / false)
    Tooltip = 'Show other player Head like a Box', -- Information shown when you hover over the toggle

    Callback = function(Value)
        ENABLE_HEAD_BOX = Value
    end
})

HeadESP:AddToggle('HeadBoxESPToggle', {
    Text = 'Head Circle ESP',
    Default = false, -- Default value (true / false)
    Tooltip = 'Show other player Head like a Circle', -- Information shown when you hover over the toggle

    Callback = function(Value)
        ENABLE_HEAD_CIRCLE = Value
    end
})


local HeadESPCONFIGS = TabBoxHead:AddTab('Configs')

HeadESPCONFIGS:AddSlider('HeadBoxSize', {
    Text = 'Head Box Size',
    Default = 24,
    Min = 10,
    Max = 75,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        CONFIG.HeadBoxSize = Value
    end
})

HeadESPCONFIGS:AddSlider('HeadBoxSize', {
    Text = 'Head Circle Radius',
    Default = 12,
    Min = 5,
    Max = 150,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        CONFIG.HeadCircleRadius = Value
    end
})

--ESP LINE
local TabBoxESPLINE = Tabs.Visuals:AddLeftTabbox()

local LineESP = TabBoxESPLINE:AddTab('Line ESP')
local LineESPCONFIGS = TabBoxESPLINE:AddTab('Configs')

LineESP:AddToggle('LineESPToggle', {
    Text = 'Lines ESP',
    Default = false, -- Default value (true / false)
    Tooltip = 'Show other player Look Lines', -- Information shown when you hover over the toggle

    Callback = function(Value)
        ENABLE_LINES = Value
    end
})

LineESP:AddToggle('LineESPToggle', {
    Text = 'Lines Alert',
    Default = false, -- Default value (true / false)
    Tooltip = 'Lines That Show the Player Aiming at You', -- Information shown when you hover over the toggle

    Callback = function(Value)
        CONFIG.EnableVFX = Value
    end
})

LineESPCONFIGS:AddSlider('LineESPDistance', {
    Text = 'Max Distance',
    Default = 500,
    Min = 100,
    Max = 1000,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        CONFIG.LineDistance = Value
    end
})

LineESPCONFIGS:AddSlider('LineESPThickness', {
    Text = 'Line Thickness',
    Default = 2,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        CONFIG.LineThickness = Value
    end
})

LineESPCONFIGS:AddSlider('LineESPThicknessAlert', {
    Text = 'Line Thickness Alert',
    Default = 4,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        CONFIG.LineThicknessAlert = Value
    end
})

LineESPCONFIGS:AddSlider('VignetteIntensity', {
    Text = 'Vignette Intensity',
    Default = 0.35,
    Min = 0.1,
    Max = 2,
    Rounding = 2,
    Compact = false,

    Callback = function(Value)
        CONFIG.VignetteIntensity = Value
    end
})

LineESPCONFIGS:AddSlider('Alert Flash Speed', {
    Text = 'Alert Flash Speed',
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        CONFIG.FlashSpeed = Value
    end
})

LineESPCONFIGS:AddSlider('DetectionSize', {
    Text = 'Detection Radius',
    Default = 3.2,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        CONFIG.DetectionRadius = Value
    end
})

LineESPCONFIGS:AddLabel('Alert Color'):AddColorPicker('AlertColorPicker', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'Alert Color', -- Optional. Allows you to have a custom color picker title (when you open it)
    Transparency = 0, -- Optional. Enables transparency changing for this color picker (leave as nil to disable)

    Callback = function(Value)
        CONFIG.AlertColor = Value
    end
})

Library:SetWatermarkVisibility(true)

-- Example of dynamically-updating watermark with common traits (fps and ping)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    Library:SetWatermark(('BloomWare | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

Library.KeybindFrame.Visible = true; -- todo: add a function for this

Library:OnUnload(function()
    WatermarkConnection:Disconnect()

    print('Unloaded!')
    Library.Unloaded = true
end)

-- UI Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

-- I set NoUI so it does not show up in the keybinds menu
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'RightSift', NoUI = true, Text = 'Menu keybind' })


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('BloomWare')
SaveManager:SetFolder('BloomWare/BlindShot')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
ThemeManager:ApplyTheme('Quartz')
