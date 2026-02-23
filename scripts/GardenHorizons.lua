--BOIIII SKIDDING IS FUNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN

local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/SaveManager.luau"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()

local version = "1.0"

local Window = Library:CreateWindow{
    Title = "BloomWare - Garden Horizons | Version : " .. version,
    SubTitle = "by Skibidi50-lol",
    TabWidth = 160,
    Size = UDim2.fromOffset(860, 655),
    Resize = true,
    MinSize = Vector2.new(470, 380),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightShift
}

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "BloomToggle"
ToggleGui.Parent = (game:GetService("CoreGui") or lp:WaitForChild("PlayerGui"))

local vim = game:GetService("VirtualInputManager")

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 45, 0, 45)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -22)
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Text = "BW"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 15
OpenBtn.Parent = ToggleGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)

OpenBtn.Activated:Connect(function()
    vim:SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
end)

local Tabs = {
    Upd = Window:CreateTab{ Title = "Updates", Icon = "phosphor-users-bold" },
    Farm = Window:CreateTab{ Title = "Farming", Icon = "apple" },
	Shop = Window:CreateTab{ Title = "Shops", Icon = "cherry" },
    Settings = Window:CreateTab{ Title = "Settings", Icon = "settings" }
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local RemoteEvents = RS:WaitForChild("RemoteEvents")
local BuyRemote = RemoteEvents:WaitForChild("PurchaseShopItem")
local SellRemote = RemoteEvents:WaitForChild("SellItems")
local PlantRemote = RemoteEvents:WaitForChild("PlantSeed")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 8)

local AutoCollect = false
local AutoBuySeeds = false
local AutoBuyGear = false
local AutoSell = false
local AutoPlant = false
local CollectMode = "Tween"
local LOOP_DELAY = 1.2

local PLANT_GRID_RANGE = 4
local PLANT_GRID_SIZE = 2

local AllSeedsBuy = {
    "Carrot Seed", "Corn Seed", "Onion Seed", "Strawberry Seed", "Mushroom Seed",
    "Beetroot Seed", "Tomato Seed", "Potato Seed", "Wheat Seed", "Pumpkin Seed",
    "Banana Seed", "Apple Seed", "Plum Seed", "Cabbage Seed", "Cherry Seed",
    "Olive Seed", "Rose Seed", "Dandelion Seed", "Sunpetal Seed", "Bellpepper Seed",
    "Amberpine Seed", "Birch Seed", "Goldenberry Seed", "Amberwood Seed", "Orange Seed",
    "Dawnblossom Seed", "Dawnfruit Seed"
}

local AllPlantNames = {
    "Carrot", "Corn", "Onion", "Strawberry", "Mushroom", "Beetroot", "Tomato", "Potato",
    "Wheat", "Pumpkin", "Banana", "Apple", "Plum", "Cabbage", "Cherry", "Olive", "Rose",
    "Dandelion", "Sunpetal", "Bellpepper", "Amberpine", "Birch", "Goldenberry", "Amberwood",
    "Orange", "Dawnblossom", "Dawnfruit"
}

local SelectedBuySeeds = {}
local SelectedPlantSeeds = {}
local SelectedHarvestPlants = {}

local AllGears = {
    "Watering Can", "Basic Sprinkler", "Harvest Bell", "Turbo Sprinkler",
    "Favorite Tool", "Super Sprinkler"
}
local SelectedGears = {}

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    HumanoidRootPart = newChar:WaitForChild("HumanoidRootPart", 8)
end)

local function isValidCharacter()
    return Character and Character.Parent and HumanoidRootPart and HumanoidRootPart.Parent
end

local function collectAll()
    if not isValidCharacter() then return end
    
    if CollectMode == "Proximity" then
        for _, obj in pairs(workspace.ClientPlants:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" then
                local plantPart = obj.Parent
                if plantPart and plantPart:IsA("BasePart") then
                    fireproximityprompt(obj)
                end
            end
        end
    elseif CollectMode == "Tween" then
        local plants = {}
        for _, obj in pairs(workspace.ClientPlants:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Name == "HarvestPrompt" then
                local plantPart = obj.Parent
                if plantPart and plantPart:IsA("BasePart") then
                    table.insert(plants, {part = plantPart, prompt = obj})
                end
            end
        end
        if #plants == 0 then return end
        
        local currentPos = HumanoidRootPart.Position
        table.sort(plants, function(a, b)
            return (a.part.Position - currentPos).Magnitude < (b.part.Position - currentPos).Magnitude
        end)
        
        for _, data in ipairs(plants) do
            local targetCFrame = CFrame.new(data.part.Position)
            local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
            tween:Play()
            tween.Completed:Wait()
            fireproximityprompt(data.prompt)
        end
    end
end

local function tryBuySeeds()
    if not AutoBuySeeds then return end
    for _, seed in ipairs(SelectedBuySeeds) do
        pcall(function()
            BuyRemote:InvokeServer("SeedShop", seed)
        end)
    end
end

local function tryBuyGear()
    if not AutoBuyGear then return end
    for _, gear in ipairs(SelectedGears) do
        pcall(function()
            BuyRemote:InvokeServer("GearShop", gear)
        end)
    end
end

local function trySellAll()
    if not AutoSell then return end
    pcall(function()
        SellRemote:InvokeServer("SellAll")
    end)
end

local function tryPlantAround()
    if not AutoPlant or not isValidCharacter() then return end
    local rootPos = HumanoidRootPart.Position
    for _, seed in ipairs(SelectedPlantSeeds) do
        for x = -PLANT_GRID_RANGE, PLANT_GRID_RANGE, PLANT_GRID_SIZE do
            for z = -PLANT_GRID_RANGE, PLANT_GRID_RANGE, PLANT_GRID_SIZE do
                pcall(function()
                    PlantRemote:InvokeServer(seed, rootPos + Vector3.new(x, -3, z))
                end)
            end
        end
    end
end

local function tryHarvestSelected()
    if not isValidCharacter() then return end
    for _, plant in pairs(workspace.ClientPlants:GetChildren()) do
        local base = plant.Name:gsub("%d+$", "")
        if table.find(SelectedHarvestPlants, base) then
            for _, v in pairs(plant:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Name == "HarvestPrompt" then
                    v.HoldDuration = 0
                    fireproximityprompt(v)
                end
            end
        end
    end
end

-- Main loop
task.spawn(function()
    while true do
        if AutoCollect then pcall(collectAll) end
        if AutoBuySeeds then pcall(tryBuySeeds) end
        if AutoBuyGear then pcall(tryBuyGear) end
        if AutoSell then pcall(trySellAll) end
        if AutoPlant then pcall(tryPlantAround) end
        task.wait(LOOP_DELAY)
    end
end)

-- GUI
local Options = Library.Options

-- Updates
Tabs.Upd:AddSection("Updates")
Tabs.Upd:CreateParagraph("UpdParagraph", {
    Title = "🟩 Release 1.0",
    Content = "Features:\nAuto Buy Seeds/Gear\nAuto Sell\nAuto Plant\nSeed selectors\nAuto Harvest"
})

-- Farming tab
Tabs.Farm:AddSection("Auto Collect")
Tabs.Farm:CreateToggle("AutoCollectToggle", {Title = "Auto Harvest Fruits (NEAR GARDEN)", Default = false})
    :OnChanged(function(v) AutoCollect = v end)

Tabs.Farm:CreateDropdown("CollectMode", {
    Title = "Collect Mode",
    Values = {"Proximity", "Tween"},
    Multi = false,
    Default = "Tween"
}):OnChanged(function(v)
	 CollectMode = v 
end)

Tabs.Farm:AddSection("Misc")
Tabs.Farm:CreateSlider("LoopDelaySlider", {
    Title = "Loop Delay (seconds)",
    Min = 0.1,
    Max = 5,
    Default = 0.1,
    Rounding = 1
}):OnChanged(function(v) 
	LOOP_DELAY = v
 end)

--Shops
Tabs.Shop:AddSection("Auto Buy Seeds")
Tabs.Shop:CreateToggle("AutoBuySeedsToggle", {Title = "Auto Buy Selected Seeds", Default = false})
:OnChanged(function(v) 
	AutoBuySeeds = v 
end)

Tabs.Shop:CreateDropdown("BuySeedsDropdown", {
    Title = "Seeds to Auto-Buy",
    Values = AllSeedsBuy,
    Multi = true,
    Default = {}
}):OnChanged(function(v)
    SelectedBuySeeds = {}
    for seed, state in pairs(v) do
        if state then table.insert(SelectedBuySeeds, seed) end
    end
end)

Tabs.Shop:AddSection("Auto Buy Gear")
Tabs.Shop:CreateToggle("AutoBuyGearToggle", {Title = "Auto Buy Selected Gear", Default = false})
    :OnChanged(function(v) AutoBuyGear = v end)

Tabs.Shop:CreateDropdown("GearDropdown", {
    Title = "Gear to Auto-Buy",
    Values = AllGears,
    Multi = true,
    Default = {}
}):OnChanged(function(v)
    SelectedGears = {}
    for gear, state in pairs(v) do
        if state then table.insert(SelectedGears, gear) end
    end
end)

Tabs.Shop:AddSection("Auto Sell")

Tabs.Shop:CreateToggle("AutoSellToggle", {Title = "Auto Sell All", Default = false})
    :OnChanged(function(v) AutoSell = v 
end)

Tabs.Shop:AddSection("Auto Plant")

Tabs.Shop:CreateToggle("AutoPlantToggle", {Title = "Auto Plant Seeds (HOLD SEEDS)", Default = false})
    :OnChanged(function(v) AutoPlant = v 
end)

Tabs.Shop:CreateDropdown("PlantSeedsDropdown", {
    Title = "Seeds to Auto-Plant",
    Values = AllPlantNames,
    Multi = true,
    Default = {}
}):OnChanged(function(v)
    SelectedPlantSeeds = {}
    for seed, state in pairs(v) do
        if state then table.insert(SelectedPlantSeeds, seed) end
    end
end)
-- Settings setup
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("BloomWareGardenHorizons")
SaveManager:SetFolder("BloomWareGardenHorizons/Config")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
