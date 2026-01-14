--[[
    BloomWare : Escape Tsunami For Brainrots
    Version : 1.0
    Note From Devoloper : Feel Free To Skid :)
]]

-- UI
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()
local Window = Modal:CreateWindow({
    Title = "BloomWare",
    SubTitle = "Escape Tsunami For Brainrots",
    Size = UDim2.fromOffset(475, 475),
    MinimumSize = Vector2.new(275, 225),
    Transparency = 0,
    Icon = "rbxassetid://68073547",
})

local GET_BRAINROT = false
local BRAINROT_LOOP = nil

local p = game:GetService'Players'
local reps = game:GetService'ReplicatedStorage'
local rf = reps.RemoteFunctions
local lp = p.LocalPlayer
local ts = game:GetService("TweenService") --this shit : x twween service : o

local function godmode()
 local at = workspace.ActiveTsunamis
 if not at then return end
 for i, v in pairs(at:GetDescendants()) do
  if v:IsA'BasePart' and v.Name == 'Hitbox' then
   v:Destroy()
  end
 end
end

godmode() --Fuck ass shit

local function applyAntiDeath(state)
    if Humanoid then
        for _, s in pairs({
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.PlatformStanding,
            Enum.HumanoidStateType.Seated
        }) do
            Humanoid:SetStateEnabled(s, not state)
        end
        if state then
            Humanoid.Health = Humanoid.MaxHealth
            Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if Humanoid.Health <= 0 then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
        end
    end
end



local function getbase()
 local bases = workspace.Bases
 for i, v in pairs(bases:GetChildren()) do
  if v:IsA'Model' and v:GetAttribute'Holder' == lp.UserId then
   return v
  end
 end
 return nil
end

local function home()
 local base = getbase()
 if not base then return end
 local part = base.Home
 if not part then return end
 pcall(function()
  game:GetService'Players'.LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
 end)
end

local FLY_SPEED = 200 -- studs per second
local USE_CUSTOM_POS = false
local CUSTOM_CFRAME = nil
local activeTween = nil

local activeTween = nil

local function tphomeTween()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetCFrame

    if USE_CUSTOM_POS and CUSTOM_CFRAME then
        targetCFrame = CUSTOM_CFRAME
    else
        --fly to base home
        local base = getbase()
        local home = base and base:FindFirstChild("Home")
        if not home then return end
        targetCFrame = home.CFrame
    end

    if activeTween then
        activeTween:Cancel()
        activeTween = nil
    end

    local speed = tonumber(FLY_SPEED) or 10
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local travelTime = distance / math.max(speed, 1)

    local tweenInfo = TweenInfo.new(
        travelTime,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    activeTween = ts:Create(hrp, tweenInfo, {
        CFrame = targetCFrame
    })

    activeTween:Play()
end



--Auto Collect
AUTO_COLLECT = false

RS = game:GetService("ReplicatedStorage")
REMOTE = RS:WaitForChild("RemoteEvents"):WaitForChild("CollectMoney")

function CollectAll()
    for i = 1, 100 do
        REMOTE:FireServer("Slot" .. i)
        task.wait(0.05)
    end
end


-- Brainrots
local Brainrots = Window:AddTab("Brainrots")

Brainrots:New("Title")({
    Title = "Main settings",
})

Brainrots:New("Button")({
    Title = "Remove Tsunami",
    Description = "Remove All The Tsunami",
    Callback = function()
        Window:Notify({
            Title = "Applied!",
            Description = "Remove Tsunami Applied!",
            Duration = 5,
            Type = "Info",
        })
        workspace.ActiveTsunamis:Destroy()
    end,
})

Brainrots:New("Button")({
    Title = "Remove Vip Walls",
    Description = "Remove All Vip Walls",
    Callback = function()
        Window:Notify({
            Title = "Applied!",
            Description = "Remove Vip Walls Applied!",
            Duration = 5,
            Type = "Info",
        })
        delVipw()
    end,
})

Brainrots:New("Button")({
    Title = "Get Brainrot",
    Description = "Get The Brainrot You Holding",
    Callback = function()
        Window:Notify({
            Title = "Applied!",
            Description = "Get Brainrot Applied!",
            Duration = 5,
            Type = "Info",
        })
        home()
    end,
})

Brainrots:New("Toggle")({
    Title = "Fly To Base",
    Description = "Fly To Your Base",
    DefaultValue = false,
    Callback = function(Value)
        GET_BRAINROT = Value

        if GET_BRAINROT then
            BRAINROT_LOOP = task.spawn(function()
                while GET_BRAINROT do
                    applyAntiDeath(true)
                    tphomeTween()
                    task.wait(4.5)
                end
            end)
        else
            GET_BRAINROT = false

            if BRAINROT_LOOP then
                task.cancel(BRAINROT_LOOP)
                BRAINROT_LOOP = nil
            end

            if activeTween then
                activeTween:Cancel()
                activeTween = nil
            end

            applyAntiDeath(false)
        end
    end,
})

Brainrots:New("Slider")({
    Title = "Fly Speed",
    Description = "Change the Fly To Base Speed",
    Default = 200,
    Minimum = 10,
    Maximum = 300,
    DecimalCount = 0,
    Callback = function(Amount)
        FLY_SPEED = Amount
    end,
})

Brainrots:New("Toggle")({
    Title = "Use Custom Fly Position",
    Description = "Fly to custom position instead of Home",
    DefaultValue = false,
    Callback = function(Value)
        USE_CUSTOM_POS = Value
    end,
})

Brainrots:New("Button")({
    Title = "Set Fly Position Here",
    Description = "Save exact current position",
    Callback = function()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        CUSTOM_CFRAME = hrp.CFrame
        USE_CUSTOM_POS = true

        Window:Notify({
            Title = "Fly Position Saved",
            Description = "Exact position stored",
            Duration = 3,
            Type = "Success",
        })
    end,
})

local Auto = Window:AddTab("Automation")

Auto:New("Title")({
    Title = "Automation settings",
})

Auto:New("Toggle")({
    Title = "Auto Collect",
    Description = "Auto Collect Money From Brainrots",
    DefaultValue = false,
    Callback = function(Value)
       AUTO_COLLECT = Value
        task.spawn(function()
            while AUTO_COLLECT do
                for i = 1, 100 do
                    REMOTE:FireServer("Slot" .. i)
                    task.wait(0.05)
                end
                task.wait(0.01)
            end
        end)
    end,
})

Auto:New("Button")({
    Title = "Collect All",
    Description = "Collect All Money From Brainrots",
    Callback = function()
        Window:Notify({
            Title = "Applied!",
            Description = "Collect All Money Applied!",
            Duration = 5,
            Type = "Info",
        })
        CollectAll()
    end,
})

local rf = reps.RemoteFunctions

local function sellall()
 local remote = rf.SellAll
 remote:InvokeServer()
end

AUTO_SELL = false

Auto:New("Toggle")({
    Title = "Auto Sell All",
    Description = "Auto Sell All Stuff",
    DefaultValue = false,
    Callback = function(Value)
       AUTO_SELL = Value
        task.spawn(function()
            while AUTO_SELL do
                sellall()
                task.wait(0.2)
            end
        end)
    end,
})


local function upgradecr()
 local remote = rf.UpgradeCarry
 remote:InvokeServer()
end

local AUTO_CARRY = false

Auto:New("Toggle")({
    Title = "Auto Upgrade Carry",
    Description = "Auto Upgrade Your Carry Strength",
    DefaultValue = false,
    Callback = function(Value)
       AUTO_CARRY = Value
        task.spawn(function()
            while AUTO_CARRY do
                upgradecr()
                task.wait(0.2)
            end
        end)
    end,
})

local function upgrade()
 local remote = rf.UpgradeBase
 remote:InvokeServer()
end

local AUTO_UPGRADE = false

Auto:New("Toggle")({
    Title = "Auto Upgrade Base",
    Description = "Auto Upgrade Your Base",
    DefaultValue = false,
    Callback = function(Value)
       AUTO_UPGRADE = Value
        task.spawn(function()
            while AUTO_UPGRADE do
                upgrade()
                task.wait(0.2)
            end
        end)
    end,
})

local function upgradeb(slot)
 local remote = rf.UpgradeBrainrot
 remote:InvokeServer(slot)
end

local function upgradeallb()
 local base = getbase()
 if not base then print("nobase") return end
 for i, v in pairs(base.Slots:GetChildren()) do
  if v:IsA("Model") and v.Name:lower():find("slot") and v:FindFirstChildWhichIsA("Tool") then
   upgradeb(v.Name)
  end
 end
end

local AUTO_BRAINROT = false

Auto:New("Toggle")({
    Title = "Auto Upgrade Brainrots",
    Description = "Auto Upgrade Your Brainrots",
    DefaultValue = false,
    Callback = function(Value)
       AUTO_BRAINROT = Value
        task.spawn(function()
            while AUTO_BRAINROT do
                upgradeallb()
                task.wait(0.2)
            end
        end)
    end,
})

local function upgradespeed()
 local remote = rf.UpgradeSpeed
 remote:InvokeServer(5)
end

local AUTO_SPEED = false

Auto:New("Toggle")({
    Title = "Auto Upgrade Speed",
    Description = "Auto Upgrade Your Speed",
    DefaultValue = false,
    Callback = function(Value)
       AUTO_SPEED = Value
        task.spawn(function()
            while AUTO_SPEED do
                upgradespeed()
                task.wait(0.2)
            end
        end)
    end,
})

local function rebirth()
 local remote = rf.Rebirth
 remote:InvokeServer()
end

local AUTO_REBIRTH = false

Auto:New("Toggle")({
    Title = "Auto Rebirth",
    Description = "Auto Rebirth Your Player",
    DefaultValue = false,
    Callback = function(Value)
       AUTO_REBIRTH = Value
        task.spawn(function()
            while AUTO_REBIRTH do
                rebirth()
                task.wait(0.2)
            end
        end)
    end,
})
--Misc
local Misc = Window:AddTab("Miscellaneous")

Misc:New("Title")({
    Title = "Miscellaneous settings",
})

Misc:New("Button")({
    Title = "Get Free Epic (ONLY 1)",
    Description = "Get A Free Guesto Angelic",
    Callback = function()
        Window:Notify({
            Title = "Applied!",
            Description = "Get Free Epic Applied!",
            Duration = 5,
            Type = "Info",
        })
        local remote = rf.TakeFreeEpic
        remote:InvokeServer()
    end,
})



Misc:New("Button")({
    Title = "Jerk Off",
    Description = "Ummmmmm",
    Callback = function()
        Window:Notify({
            Title = "Applied!",
            Description = "Jerk Off Applied!",
            Duration = 5,
            Type = "Info",
        })
        loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()
    end,
})

local function dupeHeldTool(player)
    if not player or not player.Character then return end

    local character = player.Character

    local tool = character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local clonedTool = tool:Clone()
    clonedTool.Parent = player.Backpack
end


Misc:New("Button")({
    Title = "Dupe Held Tool",
    Description = "Visuals BTW",
    Callback = function()
        Window:Notify({
            Title = "Applied!",
            Description = "Dupe Held Tool Applied!",
            Duration = 5,
            Type = "Info",
        })
        dupeHeldTool(game.Players.LocalPlayer)
    end,
})
-- Settings
local Settings = Window:AddTab("Settings")

Settings:New("Title")({
    Title = "Themes"
})

Settings:New("Dropdown")({
    Title = "Theme",
    Description = "Default theme options",
    Options = { "Light", "Dark", "Midnight", "Rose", "Emerald" },
    Callback = function(Theme)
        Window:SetTheme(Theme)
    end,
})


Settings:New("Button")({
    Title = "Destroy GUI",
    Description = "Click to get rid of the UI (can't be brought back)",
    Callback = function()
        Window:Destroy();
    end,
})

Window:SetTab("Brainrots")
local CustomTheme = {
    Mode = "Dark",
    Accent = Color3.fromRGB(255, 170, 70),
    Background = {
        Rotation = 120,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 18, 14)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 6))
        }),
        Line = {
            Color = Color3.fromRGB(255, 200, 120),
            Transparency = 0.9
        },
            OuterOutline = {
                Transparency = 0,
                Color = Color3.fromRGB(5, 4, 3),
                Rotation = 0,
            },
            InnerOutline = {
                Transparency = 0.78,
                Color = Color3.fromRGB(170, 130, 90),
                Rotation = 0,
            }
        },

        Text = {
            Title = {
                Color = Color3.fromRGB(255, 245, 230),
            },
            Description = {
                Color = Color3.fromRGB(205, 190, 170),
            }
        },

        Icons = {
            ActionButtons = {
                Color = Color3.fromRGB(255, 215, 160),
                Transparency = 0.18,
            }
        },

        Content = {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 20, 16)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 13, 10))
            }),
                
            Rotation = 240,
            ScrollBarColor = Color3.fromRGB(200, 160, 110),

            InnerOutline = {
                Transparency = 0.92,
                Color = Color3.fromRGB(160, 125, 85),
                Rotation = 0,
            },

            OuterOutline = {
                Transparency = 0,
                Color = Color3.fromRGB(6, 5, 4),
                Rotation = 0,
            },
        },

    Component = {
        Color = Color3.fromRGB(26, 22, 18),
        Rotation = 0,
    },

    Controls = {
        Color = Color3.fromRGB(36, 30, 24),
        Outline = Color3.fromRGB(48, 40, 32)
    },
}

            
Window:SetTheme(CustomTheme);
