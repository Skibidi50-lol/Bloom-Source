local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();
local Windows = NothingLibrary.new({
	Title = "BloomWare - Arsenal",
	Description = "Version : Release 1.0",
	Keybind = Enum.KeyCode.RightShift,
	Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
local GunMods = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skibidi50-lol/BloomWare/refs/heads/main/Modules/Arsenal/GunMods.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/linemaster2/esp-library/main/library.lua"))()
local speed = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skibidi50-lol/BloomWare/refs/heads/main/Modules/Arsenal/speed.lua"))()
local Misc = loadstring(game:HttpGet("https://raw.githubusercontent.com/Skibidi50-lol/BloomWare/refs/heads/main/Modules/Arsenal/Misc.lua"))()

-- Hitbox Expander Settings
getgenv().Hitbox = {
    Enabled = false,
    HitboxVisual = false,
    HitboxColor = Color3.fromRGB(255, 0, 0),
    HitboxSize = Vector3.new(5, 5, 5),
    Original = {} -- Will store original part properties
}

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- List of parts to expand
local HitboxParts = {"HumanoidRootPart", "Head", "HeadHB", "RightUpperLeg", "LeftUpperLeg"}

-- Store original values when first touching a character
local function StoreOriginal(character)
    if getgenv().Hitbox.Original[character] then return end

    getgenv().Hitbox.Original[character] = {}
    for _, partName in ipairs(HitboxParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            getgenv().Hitbox.Original[character][partName] = {
                Size = part.Size,
                Transparency = part.Transparency,
                Color = part.Color,
                Material = part.Material,
                CanCollide = part.CanCollide
            }
        end
    end
end

-- Restore original values
local function RestoreOriginal(character)
    local stored = getgenv().Hitbox.Original[character]
    if not stored then return end

    for partName, props in pairs(stored) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Size = props.Size
            part.Transparency = props.Transparency
            part.Color = props.Color
            part.Material = props.Material
            part.CanCollide = props.CanCollide
        end
    end
end

-- Apply expanded hitbox
local function ApplyHitbox(character)
    if not getgenv().Hitbox.Enabled then return end
    if character == LocalPlayer.Character then return end

    StoreOriginal(character)

    local size = getgenv().Hitbox.HitboxSize
    local transparency = getgenv().Hitbox.HitboxVisual and 0.5 or 1
    local color = getgenv().Hitbox.HitboxColor

    for _, partName in ipairs(HitboxParts) do
        local part = character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Size = size
            part.Transparency = transparency
            part.Color = color
            part.Material = Enum.Material.ForceField
            part.CanCollide = false
        end
    end
end

-- Main loop
local connection
connection = RunService.Stepped:Connect(function()
    if not getgenv().Hitbox.Enabled then
        -- When disabled: restore all characters that were modified
        for _, player in Players:GetPlayers() do
            if player.Character and getgenv().Hitbox.Original[player.Character] then
                RestoreOriginal(player.Character)
            end
        end
        return
    end

    -- When enabled: expand hitboxes
    for _, player in Players:GetPlayers() do
        if player ~= LocalPlayer and player.Character then
            ApplyHitbox(player.Character)
        end
    end
end)

-- Auto-create HeadHB + keep it welded to Head
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1) -- Wait for full character load

        if not char:FindFirstChild("HeadHB") then
            local headHB = Instance.new("Part")
            headHB.Name = "HeadHB"
            headHB.Size = Vector3.new(2, 1, 1)
            headHB.Transparency = 1
            headHB.CanCollide = false
            headHB.Anchored = false
            headHB.Parent = char

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = char.Head
            weld.Part1 = headHB
            weld.Parent = headHB
        end

        -- Keep HeadHB updated even if head moves
        if char:FindFirstChild("Head") and char:FindFirstChild("HeadHB") then
            char.HeadHB.CFrame = char.Head.CFrame
        end
    end)
end)


--kil all
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Root = Char:WaitForChild("HumanoidRootPart")

local target = nil
local conn = nil

local function getEnemy()
    local enemies = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and (not LP.Team or not p.Team or LP.Team ~= p.Team) then
                table.insert(enemies, p)
            end
        end
    end
    return #enemies > 0 and enemies[math.random(#enemies)] or nil
end

local function tp()
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
        target = getEnemy()
        return
    end
    local tRoot = target.Character.HumanoidRootPart
    local behind = tRoot.Position - tRoot.CFrame.LookVector * 2
    Root.CFrame = CFrame.new(behind, tRoot.Position)
end

LP.CharacterAdded:Connect(function(c)
    Char = c
    Root = c:WaitForChild("HumanoidRootPart")
end)

getgenv().tp = false

spawn(function()
    while wait(0.1) do
        if getgenv().tp then
            if not conn then
                conn = RunService.Heartbeat:Connect(function()
                    if getgenv().tp then tp() end
                end)
            end
        else
            if conn then conn:Disconnect() conn = nil end
            target = nil
        end
    end
end)
--lol
local Main = Windows:NewTab({
	Title = "Main",
	Description = "Main things are in here",
	Icon = "rbxassetid://7733960981"
})

local AimSection = Main:NewSection({
	Title = "Aimbot",
	Icon = "rbxassetid://7733765307",
	Position = "Left"
})

AimSection:NewToggle({
	Title = "Aimbot",
	Default = false,
	Callback = function(Value)
		Aimbot.Load()
        getgenv().ExunysDeveloperAimbot.Settings.Enabled = Value
	end,
})

AimSection:NewToggle({
	Title = "Wall Check",
	Default = false,
	Callback = function(Value)
		Aimbot.Load()
        getgenv().ExunysDeveloperAimbot.Settings.WallCheck = Value
	end,
})


AimSection:NewToggle({
	Title = "Team Check",
	Default = false,
	Callback = function(Value)
		Aimbot.Load()
        getgenv().ExunysDeveloperAimbot.Settings.TeamCheck = Value
	end,
})

AimSection:NewToggle({
	Title = "Alive Check",
	Default = false,
	Callback = function(Value)
		Aimbot.Load()
        getgenv().ExunysDeveloperAimbot.Settings.AliveCheck = Value
	end,
})

AimSection:NewSlider({
	Title = "Camera Smoothness",
	Min = 0,
	Max = 1,
	Default = 0,
	Callback = function(Value)
		getgenv().ExunysDeveloperAimbot.FOVSettings.Sensitivity = Value
	end,
})

AimSection:NewSlider({
	Title = "Mouse Smoothness",
	Min = 1,
	Max = 10,
	Default = 3.5,
	Callback = function(Value)
		getgenv().ExunysDeveloperAimbot.FOVSettings.Sensitivity2 = Value
	end,
})


AimSection:NewDropdown({
	Title = "Aim Part",
	Data = {"Head","HumanoidRootPart"},
	Default = "Head",
	Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.Settings.LockPart = Value
	end,
})

AimSection:NewDropdown({
	Title = "Aimbot Mode (1 = Camera 2 = Mouse)",
	Data = {1,2},
	Default = 1,
	Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.Settings.LockMode = Value
	end,
})

getgenv().triggerb = false
local teamcheck = "Team-Based"
local delay = 0.1
local isAlive = true

local TriggerSection = Main:NewSection({
	Title = "TriggerBot",
	Icon = "rbxassetid://7733765307",
	Position = "Left"
})

TriggerSection:NewToggle({
	Title = "TriggerBot",
	Default = false,
	Callback = function(Value)
		getgenv().triggerb = Value
	end,
})

TriggerSection:NewDropdown({
	Title = "Team Check Mode",
	Data = {"FFA", "Team-Based", "Everyone"},
	Default = "Everyone",
	Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.Settings.LockMode = Value
	end,
})

TriggerSection:NewSlider({
	Title = "Shoot Delay",
	Min = 0.1,
	Max = 10,
	Default = 0,
	Callback = function(Value)
		delay = Value
	end,
})
--triggerbot func
local function isEnemy(targetPlayer)
    if teamcheck == "FFA" then
        return true
    elseif teamcheck == "Everyone" then
        return targetPlayer ~= game.Players.LocalPlayer
    elseif teamcheck == "Team-Based" then
        local localPlayerTeam = game.Players.LocalPlayer.Team
        return targetPlayer.Team ~= localPlayerTeam
    end
    return false
end

local function checkhealth()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.HealthChanged:Connect(function(health)
            isAlive = health > 0
        end)
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(checkhealth)
checkhealth()

game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().triggerb and isAlive then
        local player = game.Players.LocalPlayer
        local mouse = player:GetMouse()
        local target = mouse.Target
        if target and target.Parent:FindFirstChild("Humanoid") and target.Parent.Name ~= player.Name then
            local targetPlayer = game:GetService("Players"):FindFirstChild(target.Parent.Name)
            if targetPlayer and isEnemy(targetPlayer) then
                mouse1press()
                wait(delay)
                mouse1release()
            end
        end
    end
end)


local FovSection = Main:NewSection({
	Title = "FOV Settings",
	Icon = "rbxassetid://7733765307",
	Position = "Right"
})

FovSection:NewToggle({
	Title = "FOV Circle",
	Default = false,
	Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.FOVSettings.Enabled = Value
	end,
})

FovSection:NewSlider({
	Title = "FOV Radius",
	Min = 50,
	Max = 500,
	Default = 90,
	Callback = function(Value)
		getgenv().ExunysDeveloperAimbot.FOVSettings.Radius = Value
	end,
})

FovSection:NewSlider({
	Title = "FOV Transparency",
	Min = 0,
	Max = 1,
	Default = 1,
	Callback = function(Value)
		getgenv().ExunysDeveloperAimbot.FOVSettings.Transparency = Value
	end,
})

FovSection:NewToggle({
	Title = "Filled",
	Default = false,
	Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.FOVSettings.Filled = Valuewefg
	end,
})


FovSection:NewToggle({
	Title = "Rainbow FOV",
	Default = false,
	Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.FOVSettings.RainbowColor = Value
	end,
})

FovSection:NewToggle({
	Title = "Rainbow Outline",
	Default = false,
	Callback = function(Value)
        getgenv().ExunysDeveloperAimbot.FOVSettings.RainbowOutlineColor  = Value
	end,
})

FovSection:NewSlider({
	Title = "Rainbow Speed",
	Min = 1,
	Max = 100,
	Default = 1,
	Callback = function(Value)
		getgenv().ExunysDeveloperAimbot.DeveloperSettings.RainbowSpeed = Value
	end,
})

local hitboxSection = Main:NewSection({
	Title = "Hitbox Expander",
	Icon = "rbxassetid://7733917120",
	Position = "Right"
})

hitboxSection:NewToggle({
	Title = "Hitbox Expander",
	Default = false,
	Callback = function(Value)
        getgenv().Hitbox.Enabled = Value
	end,
})

hitboxSection:NewToggle({
	Title = "Hitbox Visualizer",
	Default = false,
	Callback = function(Value)
        getgenv().Hitbox.HitboxVisual = Value
	end,
})

hitboxSection:NewSlider({
	Title = "Hitbox Size",
	Min = 1,
	Max = 50,
	Default = 5,
	Callback = function(Value)
		getgenv().Hitbox.HitboxSize = Vector3.new(Value,Value,Value)
	end,
})

local Weapon = Windows:NewTab({
	Title = "Weaponry",
	Description = "Gun Mods",
	Icon = "rbxassetid://7743872758"
})

local GunSection = Weapon:NewSection({
	Title = "Gun Mods",
	Icon = "rbxassetid://7743872758",
	Position = "Left"
})

GunSection:NewToggle({
	Title = "Infinite Ammo",
	Default = false,
	Callback = function(Value)
        getgenv().GunMods.InfiniteAmmo = Value
	end,
})

GunSection:NewToggle({
	Title = "No Spread",
	Default = false,
	Callback = function(Value)
        getgenv().GunMods.NoSpread = Value
	end,
})

GunSection:NewToggle({
	Title = "No Recoil",
	Default = false,
	Callback = function(Value)
        getgenv().GunMods.NoRecoil = Value
	end,
})

GunSection:NewToggle({
	Title = "Fast Fire Rate",
	Default = false,
	Callback = function(Value)
        getgenv().GunMods.FastFireRate = Value
	end,
})

GunSection:NewToggle({
	Title = "Automatic Weapon",
	Default = false,
	Callback = function(Value)
        getgenv().GunMods.Auto = Value
	end,
})

local Visual = Windows:NewTab({
	Title = "Visuals",
	Description = "Visuals Settings",
	Icon = "rbxassetid://7733774602"
})

local ESPSection = Visual:NewSection({
	Title = "ESP Settings",
	Icon = "rbxassetid://7733774602",
	Position = "Left"
})

ESPSection:NewToggle({
	Title = "Enabled ESP",
	Default = false,
	Callback = function(Value)
        ESP.Enabled = Value
	end,
})

ESPSection:NewToggle({
	Title = "Boxes ESP",
	Default = false,
	Callback = function(Value)
        ESP.ShowBox = Value
	end,
})

ESPSection:NewDropdown({
	Title = "Box Type",
	Data = {"2D","Corner Box Esp"},
	Default = "2D",
	Callback = function(Value)
		ESP.BoxType = Value
	end,
})

ESPSection:NewToggle({
	Title = "Names ESP",
	Default = false,
	Callback = function(Value)
        ESP.ShowName = Value
	end,
})

ESPSection:NewToggle({
	Title = "Health Bar ESP",
	Default = false,
	Callback = function(Value)
        ESP.ShowHealth = Value
	end,
})

ESPSection:NewToggle({
	Title = "Tracers ESP",
	Default = false,
	Callback = function(Value)
        ESP.ShowTracer = Value
	end,
})

ESPSection:NewToggle({
	Title = "Distance ESP",
	Default = false,
	Callback = function(Value)
        ESP.ShowDistance = Value
	end,
})

ESPSection:NewToggle({
	Title = "Team Check",
	Default = false,
	Callback = function(Value)
        ESP.Teamcheck = Value
	end,
})

local plr = Windows:NewTab({
	Title = "Player",
	Description = "LocalPlayer Stuff",
	Icon = "rbxassetid://7743876054"
})

local PlayerSection = plr:NewSection({
	Title = "Player Settings",
	Icon = "rbxassetid://77438760547",
	Position = "Left"
})

PlayerSection:NewToggle({
	Title = "Speed Boost",
	Default = false,
	Callback = function(Value)
        getgenv().speed.enabled = Value
	end,
})

PlayerSection:NewSlider({
	Title = "Player Speed",
	Min = 16,
	Max = 1000,
	Default = 16,
	Callback = function(Value)
		getgenv().speed.speed = Value
	end,
})

PlayerSection:NewToggle({
	Title = "Enchantment Control",
	Default = false,
	Callback = function(Value)
        getgenv().speed.control = Value
	end,
})

PlayerSection:NewSlider({
	Title = "Control Friction",
	Min = 1,
	Max = 100,
	Default = 2,
	Callback = function(Value)
		getgenv().speed.friction = Value
	end,
})

PlayerSection:NewKeybind({
	Title = "Speed Keybind",
	Default = Enum.KeyCode.KeypadDivide,
	Callback = function(Value)
		getgenv().speed.keybind = Value
	end,
})

getgenv().infjump = false


PlayerSection:NewToggle({
	Title = "Infinite Jump",
	Default = false,
	Callback = function(Value)
        getgenv().infjump = Value
        game:GetService("UserInputService").JumpRequest:connect(function()
            if getgenv().infjump then
                game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
            end
        end)
	end,
})


local Misc = Windows:NewTab({
	Title = "Misc",
	Description = "Miscellaneous",
	Icon = "rbxassetid://7743876054"
})

local MiscSection = Misc:NewSection({
	Title = "Misc Settings",
	Icon = "rbxassetid://7734022107",
	Position = "Left"
})

MiscSection:NewToggle({
	Title = "Kill All (Recommend With Aimbot)",
	Default = false,
	Callback = function(Value)
        getgenv().tp = Value
	end,
})

getgenv().AutoFarm = false



MiscSection:NewToggle({
	Title = "Auto Farm (BETA) (BANNABLE)",
	Default = false,
	Callback = function(Value)
		getgenv().AutoFarm = Value

		local runServiceConnection
		local mouseDown = false
		local player = game.Players.LocalPlayer
		local camera = game.Workspace.CurrentCamera

		game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = bool and "Infinite Ammo" or ""

		function closestplayer()
			local closestDistance = math.huge
			local closestPlayer = nil

			for _, enemyPlayer in pairs(game.Players:GetPlayers()) do
				if enemyPlayer ~= player and enemyPlayer.TeamColor ~= player.TeamColor and enemyPlayer.Character then
					local character = enemyPlayer.Character
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					local humanoid = character:FindFirstChild("Humanoid")
					if humanoidRootPart and humanoid and humanoid.Health > 0 then
						local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
						if distance < closestDistance then
							closestDistance = distance
							closestPlayer = enemyPlayer
						end
					end
				end
			end

			return closestPlayer
		end

		local function AutoFarm()
			game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 12

			runServiceConnection = game:GetService("RunService").Stepped:Connect(function()
				if getgenv().AutoFarm then
					local closestPlayer = closestplayer()
					if closestPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local enemyRootPart = closestPlayer.Character.HumanoidRootPart

						local targetPosition = enemyRootPart.Position - enemyRootPart.CFrame.LookVector * 2 + Vector3.new(0, 2, 0)
						player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)

						if closestPlayer.Character:FindFirstChild("Head") then
							local enemyHead = closestPlayer.Character.Head.Position
							camera.CFrame = CFrame.new(camera.CFrame.Position, enemyHead)
						end

						if not mouseDown then
							mouse1press()
							mouseDown = true
						end
					else
						if mouseDown then
							mouse1release()
							mouseDown = false
						end
					end
				else
					if runServiceConnection then
						runServiceConnection:Disconnect()
						runServiceConnection = nil
					end
					if mouseDown then
						mouse1release()
						mouseDown = false
					end
				end
			end)
		end

		local function onCharacterAdded(character)
			wait(0.5)
			AutoFarm()
		end

		player.CharacterAdded:Connect(onCharacterAdded)

		if Value then
			wait(0.5)
			AutoFarm()
		else
			game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = ""
			getgenv().AutoFarm = false
			game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 1
			if runServiceConnection then
				runServiceConnection:Disconnect()
				runServiceConnection = nil
			end
			if mouseDown then
				mouse1release()
				mouseDown = false
			end
		end
	end,
})

MiscSection:NewTitle('USE WITH TRIGGERBOT OTHERWISE IT WILL NOT WORKING')
MiscSection:NewTitle('VERY BANNABLE!!!!')


MiscSection:NewToggle({
	Title = "Bhop (BETA)",
	Default = false,
	Callback = function(Value)
        getgenv().Misc.Bhop = Value
	end,
})

MiscSection:NewToggle({
	Title = "Instant Respawn",
	Default = false,
	Callback = function(Value)
        getgenv().Misc.InstantRespawn = Value
	end,
})

local Notification = NothingLibrary.Notification();

Notification.new({
	Description = 'Loaded!';
	Title = "BloomWare Loaded!";
	Duration = 3;
	Icon = "rbxassetid://7733993369",
})
