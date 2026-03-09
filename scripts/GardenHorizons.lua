local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = true
Library.ShowToggleFrameInKeybinds = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlantRemote = ReplicatedStorage.RemoteEvents:WaitForChild("PlantSeed")
local PurchaseShopItemRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("PurchaseShopItem")
local GetShopDataRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("GetShopData")
local ClaimQuestRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("ClaimQuest")
local RequestQuestsRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("RequestQuests")
local UpdateQuestsRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("UpdateQuests")
local SellItemsRemote = ReplicatedStorage.RemoteEvents:FindFirstChild("SellItems")

local ItemInventory = nil
pcall(function()
    ItemInventory = require(ReplicatedStorage:WaitForChild("Inventory"):WaitForChild("ItemInventory"))
end)

local SeedShopData = nil
pcall(function()
    SeedShopData = require(ReplicatedStorage:WaitForChild("Shop"):WaitForChild("ShopData"):WaitForChild("SeedShopData"))
end)

local GearShopData = nil
pcall(function()
    GearShopData = require(ReplicatedStorage:WaitForChild("Shop"):WaitForChild("ShopData"):WaitForChild("GearShopData"))
end)

local Settings = {
    Enabled = false,
    AutoHarvestTeleport = false,
    IgnoreFavorited = true,
    AutoPlantAtCharacter = false,
    AutoEquipPlantSeeds = false,
    SavedPlantPosition = nil,
    SelectedSeed = nil,
    TeleportToShopOnBuy = true,
    CheckSeedStockBeforeBuy = true,
    AutoBuyLoop = false,
    AutoBuyDelay = 1.0,
    SeedShopNpcPosition = Vector3.new(177, 204, 672),
    SelectedGear = nil,
    TeleportToGearShopOnBuy = true,
    CheckGearStockBeforeBuy = true,
    AutoBuyGearLoop = false,
    AutoBuyGearDelay = 1.0,
    GearShopNpcPosition = Vector3.new(212, 204, 609),
    AutoSellLoop = false,
    AutoSellDelay = 1.0,
    AutoSellOnlyWhenInventoryFull = false,
    InventoryFullSellCooldown = 1.0,
    SellMode = "Sell All",
    TeleportToSellNpcOnSell = true,
    SellNpcPosition = Vector3.new(150, 204, 674),
    AutoClaimQuests = false,
    AutoClaimQuestDelay = 1.0,
    Range = 50,
    HarvestBatchSize = 10,
    Delay = 0.1,
}

local lastPlantTime = 0
local lastHarvestTeleportTime = 0
local lastAutoBuyTime = 0
local lastAutoBuyGearTime = 0
local lastAutoSellTime = 0
local lastInventoryFullSellTime = 0
local lastAutoClaimQuestTime = 0
local warnedMissingSavedPosition = false
local warnedMissingQuestRemotes = false
local warnedMissingSellRemotes = false
local harvestCooldownByPrompt = {}
local harvestFailCountByPrompt = {}
local harvestBlacklistUntilByPrompt = {}
local HARVEST_PROMPT_SCAN_INTERVAL = 0.35
local harvestPromptScanCache = {}
local harvestPromptScanCacheAt = 0
local latestQuestData = nil
local INVENTORY_FULL_TEXT = "Your inventory is full! Sell or remove items to make space"

if UpdateQuestsRemote and UpdateQuestsRemote:IsA("RemoteEvent") then
    UpdateQuestsRemote.OnClientEvent:Connect(function(data)
        if type(data) == "table" then
            latestQuestData = data
        end
    end)
end

local Window = Library:CreateWindow({
    Title = "Garden Horizons",
    Footer = "BloomWare | By Skibidi50-lol | ".. (identifyexecutor()),
    NotifySide = "Right",
    Size = UDim2.fromOffset(630, 450),
    ToggleKeybind = Enum.KeyCode.RightShift,
    ShowCustomCursor = true,
})

local Tabs = {
    Main = Window:AddTab("Main", "leaf"),
    Shop = Window:AddTab("Shop", "shopping-cart"),
    ["UI Settings"] = Window:AddTab("UI Settings", "wrench"),
}

local UISettingsGroup = Tabs["UI Settings"]:AddLeftGroupbox("Ui")
UISettingsGroup:AddButton("Unload", function()
    Library:Unload()
end)

local MainGroup = Tabs.Main:AddLeftGroupbox("Auto Harvest")
local PlantGroup = Tabs.Main:AddRightGroupbox("Auto Plant")
local SavedPositionLabel = PlantGroup:AddLabel("Saved Position: Not set")

local BuyGroup = Tabs.Shop:AddLeftGroupbox("Seed Shop")
local GearGroup = Tabs.Shop:AddRightGroupbox("Gear Shop")
local SellGroup = Tabs.Shop:AddRightGroupbox("Auto Sell")

local seedOptions = {}
local seedPriceByName = {}
if SeedShopData and SeedShopData.ShopData then
    local seedEntries = {}
    for _, shopEntry in pairs(SeedShopData.ShopData) do
        if type(shopEntry) == "table" and type(shopEntry.Name) == "string" then
            if shopEntry.DisplayInShop ~= false then
                table.insert(seedEntries, {
                    Name = shopEntry.Name,
                    Price = tonumber(shopEntry.Price) or math.huge,
                })
                seedPriceByName[shopEntry.Name] = tonumber(shopEntry.Price) or nil
            end
        end
    end

    table.sort(seedEntries, function(a, b)
        if a.Price == b.Price then
            return a.Name < b.Name
        end
        return a.Price < b.Price
    end)

    for _, entry in ipairs(seedEntries) do
        table.insert(seedOptions, entry.Name)
    end
end

if #seedOptions == 0 then
    seedOptions = {
        "Carrot",
    }
end

Settings.SelectedSeed = seedOptions[1]
local selectedAutoPlantSeedsMap = {}
local autoPlantEquipCycleIndex = 1
local selectedBuySeedsMap = {}
local buySeedCycleIndex = 1

local function pickFirstSelectedValue(selection, valueMap)
    if type(selection) == "table" then
        local labels = {}
        for label, isSelected in pairs(selection) do
            if isSelected then
                table.insert(labels, label)
            end
        end
        table.sort(labels)
        local firstLabel = labels[1]
        if not firstLabel then
            return nil
        end
        if valueMap then
            return valueMap[firstLabel] or firstLabel
        end
        return firstLabel
    end

    if valueMap then
        return valueMap[selection] or selection
    end
    return selection
end

local gearOptions = {}
local gearPriceByName = {}
if GearShopData and GearShopData.ShopData then
    local gearEntries = {}
    for _, shopEntry in pairs(GearShopData.ShopData) do
        if type(shopEntry) == "table" and type(shopEntry.Name) == "string" then
            if shopEntry.DisplayInShop ~= false then
                table.insert(gearEntries, {
                    Name = shopEntry.Name,
                    Price = tonumber(shopEntry.Price) or math.huge,
                })
                gearPriceByName[shopEntry.Name] = tonumber(shopEntry.Price) or nil
            end
        end
    end

    table.sort(gearEntries, function(a, b)
        if a.Price == b.Price then
            return a.Name < b.Name
        end
        return a.Price < b.Price
    end)

    for _, entry in ipairs(gearEntries) do
        table.insert(gearOptions, entry.Name)
    end
end

if #gearOptions == 0 then
    gearOptions = {
        "Recall Wrench",
    }
end

Settings.SelectedGear = gearOptions[1]
local selectedBuyGearsMap = {}
local buyGearCycleIndex = 1

MainGroup:AddToggle("AutoHarvestEnabled", {
    Text = "Enable",
    Default = false,
    Callback = function(value)
        Settings.Enabled = value
    end,
})

MainGroup:AddToggle("IgnoreFavoritedToggle", {
    Text = "Ignore Favorited",
    Default = true,
    Callback = function(value)
        Settings.IgnoreFavorited = value
    end,
})

MainGroup:AddToggle("AutoHarvestTeleportToggle", {
    Text = "Auto Teleport",
    Default = false,
    Callback = function(value)
        Settings.AutoHarvestTeleport = value
    end,
})

MainGroup:AddSlider("HarvestDelaySlider", {
    Text = "Harvest Delay (s)",
    Default = Settings.Delay,
    Min = 0.05,
    Max = 1.0,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        Settings.Delay = value
    end,
})

MainGroup:AddToggle("AutoClaimQuestsToggle", {
    Text = "Auto Claim Quests",
    Default = false,
    Callback = function(value)
        Settings.AutoClaimQuests = value
        if value and RequestQuestsRemote and RequestQuestsRemote:IsA("RemoteEvent") then
            pcall(function()
                RequestQuestsRemote:FireServer()
            end)
        end
    end,
})

PlantGroup:AddToggle("AutoPlantAtCharacterToggle", {
    Text = "Auto Plant",
    Default = false,
    Callback = function(value)
        if value and not Settings.SavedPlantPosition then
            Settings.AutoPlantAtCharacter = false
            Library:Notify("Set a plant position first.", 3)
            task.defer(function()
                if Toggles.AutoPlantAtCharacterToggle then
                    Toggles.AutoPlantAtCharacterToggle:SetValue(false)
                end
            end)
            return
        end

        Settings.AutoPlantAtCharacter = value
        warnedMissingSavedPosition = false
    end,
})

PlantGroup:AddToggle("AutoEquipPlantSeedsToggle", {
    Text = "Auto Equip Seeds",
    Default = false,
    Tooltip = "If no seeds are selected, it will plant all seeds you have ",
    Callback = function(value)
        Settings.AutoEquipPlantSeeds = value
    end,
})

PlantGroup:AddDropdown("AutoPlantSeedMultiDropdown", {
    Text = "Auto Plant Seeds",
    Values = seedOptions,
    Default = {},
    Multi = true,
    AllowNull = true,
    Callback = function(value)
        selectedAutoPlantSeedsMap = {}
        if type(value) == "table" then
            for seedName, isSelected in pairs(value) do
                if isSelected then
                    selectedAutoPlantSeedsMap[tostring(seedName)] = true
                end
            end
        end
        autoPlantEquipCycleIndex = 1
    end,
})

PlantGroup:AddButton("Save Position", function()
    local char = LocalPlayer.Character
    if not char then
        SavedPositionLabel:SetText("Saved Position: Failed (no character)")
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not root then
        SavedPositionLabel:SetText("Saved Position: Failed (no root)")
        return
    end

    Settings.SavedPlantPosition = root.Position
    warnedMissingSavedPosition = false
    SavedPositionLabel:SetText(string.format(
        "Saved Position: X %.2f | Y %.2f | Z %.2f",
        root.Position.X,
        root.Position.Y,
        root.Position.Z
    ))
end)

BuyGroup:AddDropdown("SeedToBuyDropdown", {
    Text = "Seed",
    Values = seedOptions,
    Default = {},
    Multi = true,
    AllowNull = true,
    Callback = function(value)
        selectedBuySeedsMap = {}
        if type(value) == "table" then
            for key, isSelected in pairs(value) do
                if type(key) == "number" then
                    selectedBuySeedsMap[tostring(isSelected)] = true
                elseif isSelected then
                    selectedBuySeedsMap[tostring(key)] = true
                end
            end
        elseif type(value) == "string" and value ~= "" then
            selectedBuySeedsMap[value] = true
        end

        local selected = pickFirstSelectedValue(value, nil)
        if selected then
            Settings.SelectedSeed = tostring(selected)
        end
        buySeedCycleIndex = 1
    end,
})
BuyGroup:AddButton("Open Seed Shop", function()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return
    end
    local seedShopGui = playerGui:FindFirstChild("SeedShop")
    if seedShopGui then
        seedShopGui.Enabled = true
    end
end)

BuyGroup:AddToggle("TeleportToShopOnBuyToggle", {
    Text = "Teleport To NPC On Buy",
    Default = true,
    Callback = function(value)
        Settings.TeleportToShopOnBuy = value
    end,
})
BuyGroup:AddToggle("CheckSeedStockBeforeBuyToggle", {
    Text = "Check Stock Before Buy",
    Default = Settings.CheckSeedStockBeforeBuy,
    Callback = function(value)
        Settings.CheckSeedStockBeforeBuy = value
    end,
})

BuyGroup:AddToggle("AutoBuyLoopToggle", {
    Text = "Auto Buy Loop",
    Default = false,
    Callback = function(value)
        Settings.AutoBuyLoop = value
    end,
})

BuyGroup:AddSlider("SeedBuyDelaySlider", {
    Text = "Seed Buy Delay (s)",
    Default = Settings.AutoBuyDelay,
    Min = 0.1,
    Max = 5.0,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        Settings.AutoBuyDelay = value
    end,
})

GearGroup:AddDropdown("GearToBuyDropdown", {
    Text = "Gear",
    Values = gearOptions,
    Default = {},
    Multi = true,
    AllowNull = true,
    Callback = function(value)
        selectedBuyGearsMap = {}
        if type(value) == "table" then
            for key, isSelected in pairs(value) do
                if type(key) == "number" then
                    selectedBuyGearsMap[tostring(isSelected)] = true
                elseif isSelected then
                    selectedBuyGearsMap[tostring(key)] = true
                end
            end
        elseif type(value) == "string" and value ~= "" then
            selectedBuyGearsMap[value] = true
        end

        local selected = pickFirstSelectedValue(value, nil)
        if selected then
            Settings.SelectedGear = tostring(selected)
        end
        buyGearCycleIndex = 1
    end,
})
GearGroup:AddButton("Open Gear Shop", function()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return
    end
    local gearShopGui = playerGui:FindFirstChild("GearShop")
    if gearShopGui then
        gearShopGui.Enabled = true
    end
end)

GearGroup:AddToggle("TeleportToGearShopOnBuyToggle", {
    Text = "Teleport To NPC On Buy",
    Default = true,
    Callback = function(value)
        Settings.TeleportToGearShopOnBuy = value
    end,
})
GearGroup:AddToggle("CheckGearStockBeforeBuyToggle", {
    Text = "Check Stock Before Buy",
    Default = Settings.CheckGearStockBeforeBuy,
    Callback = function(value)
        Settings.CheckGearStockBeforeBuy = value
    end,
})

GearGroup:AddToggle("AutoBuyGearLoopToggle", {
    Text = "Auto Buy Loop",
    Default = false,
    Callback = function(value)
        Settings.AutoBuyGearLoop = value
    end,
})

GearGroup:AddSlider("GearBuyDelaySlider", {
    Text = "Gear Buy Delay (s)",
    Default = Settings.AutoBuyGearDelay,
    Min = 0.1,
    Max = 5.0,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        Settings.AutoBuyGearDelay = value
    end,
})

SellGroup:AddDropdown("SellModeDropdown", {
    Text = "Sell Mode",
    Values = { "Sell All", "Sell Held Item", "Sell All on Inventory Full" },
    Default = "Sell All",
    Multi = false,
    AllowNull = false,
    Callback = function(value)
        local selected = pickFirstSelectedValue(value, nil)
        if selected == "Sell All" then
            Settings.SellMode = "SellAll"
            Settings.AutoSellOnlyWhenInventoryFull = false
        elseif selected == "Sell Held Item" then
            Settings.SellMode = "Sell Held Item"
            Settings.AutoSellOnlyWhenInventoryFull = false
        elseif selected == "Sell All on Inventory Full" then
            Settings.SellMode = "SellAll"
            Settings.AutoSellOnlyWhenInventoryFull = true
        end
    end,
})

SellGroup:AddToggle("TeleportToSellNpcOnSellToggle", {
    Text = "Teleport To NPC On Sell",
    Default = true,
    Callback = function(value)
        Settings.TeleportToSellNpcOnSeellll = value
    end,
})

SellGroup:AddToggle("AutoSellLoopToggle", {
    Text = "Auto Sell",
    Default = false,
    Callback = function(value)
        Settings.AutoSellLoop = value
    end,
})

SellGroup:AddSlider("AutoSellDelaySlider", {
    Text = "Auto Sell Delay (s)",
    Default = Settings.AutoSellDelay,
    Min = 0.1,
    Max = 10.0,
    Rounding = 2,
    Compact = false,
    Callback = function(value)
        Settings.AutoSellDelay = value
    end,
})

local function getCharacterRoot()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end

    return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
end

local function isNearNpc(rootPos, targetPos, horizontalDist, maxYDiff)
    local dx = rootPos.X - targetPos.X
    local dz = rootPos.Z - targetPos.Z
    local horizontal = math.sqrt(dx * dx + dz * dz)
    local yDiff = math.abs(rootPos.Y - targetPos.Y)
    return horizontal <= horizontalDist and yDiff <= maxYDiff
end

local function teleportRootAndWait(root, targetPos, timeoutSec, horizontalDist, maxYDiff, stableFramesRequired)
    local timeout = timeoutSec or 0.75
    local nearHorizontal = horizontalDist or 2.5
    local nearY = maxYDiff or 10
    local stableFrames = stableFramesRequired or 5
    local started = tick()
    local stableCount = 0

    while tick() - started < timeout do
        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        task.wait()

        local currentRoot = getCharacterRoot()
        if not currentRoot then
            return false
        end
        root = currentRoot

        if isNearNpc(root.Position, targetPos, nearHorizontal, nearY) then
            stableCount = stableCount + 1
            if stableCount >= stableFrames then
                for _ = 1, 3 do
                    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
                    task.wait()
                end
                return true
            end
        else
            stableCount = 0
        end
    end

    return isNearNpc(root.Position, targetPos, nearHorizontal, nearY)
end

local function trySell(mode, silent)
    if not SellItemsRemote then
        if not silent then
            Library:Notify("SellItems remote not found.", 3)
        end
        return false
    end

    local sellMode = mode
    if sellMode == "Sell Held Item" then
        sellMode = "SellSingle"
    elseif sellMode ~= "SellSingle" and sellMode ~= "SellAll" then
        sellMode = Settings.SellMode == "Sell Held Item" and "SellSingle" or "SellAll"
    end

    local originalPos = nil
    local didTeleport = false
    local root = getCharacterRoot()

    if Settings.TeleportToSellNpcOnSell then
        if not root then
            if not silent then
                Library:Notify("Character root not found.", 3)
            end
            return false
        end

        local npcPos = Settings.SellNpcPosition
        if not npcPos then
            if not silent then
                Library:Notify("Sell NPC not found.", 3)
            end
            return false
        end

        originalPos = root.Position
        local reached = teleportRootAndWait(root, npcPos, 1.2, 2.5, 10, 5)
        if not reached then
            if not silent then
                Library:Notify("Could not reach sell NPC.", 3)
            end
            return false
        end
        didTeleport = true
        task.wait(0.15)
    end

    local ok, result = pcall(function()
        if SellItemsRemote:IsA("RemoteFunction") then
            return SellItemsRemote:InvokeServer(sellMode)
        end
        SellItemsRemote:FireServer(sellMode)
        return true
    end)

    if didTeleport and originalPos then
        local backRoot = getCharacterRoot()
        if backRoot then
            backRoot.CFrame = CFrame.new(originalPos)
        end
    end

    if not ok then
        if not silent then
            Library:Notify("Sell failed (invoke error).", 3)
        end
        return false
    end

    local response = tostring(result or "")
    local responseLower = string.lower(response)
    local sold = result == true
        or string.find(responseLower, "here's", 1, true) ~= nil
        or string.find(responseLower, "sold", 1, true) ~= nil

    if sold then
        if not silent then
        end
        return true
    end

    if not silent then
        if response ~= "" and response ~= "nil" then
            Library:Notify(response, 3)
        else
            Library:Notify("Nothing to sell.", 2)
        end
    end
    return false
end

local function isInventoryFullNotificationText(text)
    if type(text) ~= "string" then
        return false
    end

    local normalized = string.gsub(text, "^%s+", "")
    normalized = string.gsub(normalized, "%s+$", "")

    if normalized == INVENTORY_FULL_TEXT then
        return true
    end

    if string.sub(normalized, 1, #INVENTORY_FULL_TEXT) ~= INVENTORY_FULL_TEXT then
        return false
    end

    local suffix = string.sub(normalized, #INVENTORY_FULL_TEXT + 1)
    suffix = string.gsub(suffix, "^%s+", "")
    if suffix == "" then
        return true
    end

    if string.match(suffix, "^%.[%s]*%[X%d+%]$") then
        return true
    end
    if string.match(suffix, "^%[X%d+%]$") then
        return true
    end

    return false
end

local function shouldSellFromInventoryFullNotification()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return false
    end

    local notification = playerGui:FindFirstChild("Notification")
    if not notification then
        return false
    end

    local frame = notification:FindFirstChild("Frame")
    if not frame then
        return false
    end

    local frameChildren = frame:GetChildren()
    local slot = frameChildren[5]
    if slot then
        local content = slot:FindFirstChild("CONTENT")
        local shadow = content and content:FindFirstChild("CONTENT_SHADOW")
        if shadow and shadow:IsA("TextLabel") and isInventoryFullNotificationText(shadow.Text) then
            return true
        end
    end

    for _, node in ipairs(frame:GetDescendants()) do
        if node:IsA("TextLabel") and isInventoryFullNotificationText(node.Text) then
            return true
        end
    end

    return false
end

local function getSeedStockAmount(seedName)
    if not GetShopDataRemote then
        return nil, "GetShopData remote not found."
    end

    local ok, data = pcall(function()
        return GetShopDataRemote:InvokeServer("SeedShop")
    end)

    if not ok or type(data) ~= "table" or type(data.Items) ~= "table" then
        return nil, "Failed to fetch stock."
    end

    for itemName, itemData in pairs(data.Items) do
        if tostring(itemName):lower() == tostring(seedName):lower() then
            if type(itemData) == "table" then
                return tonumber(itemData.Amount) or 0, nil
            end
            return 0, nil
        end
    end

    return 0, nil
end

local function getPlayerShillings()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    local function readNumericStat(container, name)
        if not container then
            return nil
        end
        local valueObj = container:FindFirstChild(name)
        if valueObj and (valueObj:IsA("IntValue") or valueObj:IsA("NumberValue")) then
            return tonumber(valueObj.Value)
        end
        return nil
    end

    local amount = readNumericStat(stats, "Shillings")
    if amount ~= nil then
        return amount
    end

    amount = readNumericStat(LocalPlayer, "Shillings")
    if amount ~= nil then
        return amount
    end

    if stats then
        local numericValues = {}
        for _, child in ipairs(stats:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") then
                table.insert(numericValues, child)
            end
        end
        if #numericValues == 1 then
            local amount = tonumber(numericValues[1].Value)
            if amount ~= nil then
                return amount
            end
        end
    end

    return nil
end

local function canAffordPrice(price)
    local numericPrice = tonumber(price)
    if not numericPrice or numericPrice <= 0 then
        return true
    end

    local shillings = getPlayerShillings()
    if shillings == nil then
        return true
    end

    return shillings >= numericPrice
end

local function tryBuySelectedSeed(silent, forcedSeedName)
    local seedName = forcedSeedName or Settings.SelectedSeed
    if not PurchaseShopItemRemote then
        if not silent then
            Library:Notify("Purchase remote not found.", 3)
        end
        return false
    end

    if not seedName then
        if not silent then
            Library:Notify("Select a seed first.", 3)
        end
        return false
    end

    if Settings.CheckSeedStockBeforeBuy then
        local stockAmount, stockErr = getSeedStockAmount(seedName)
        if stockAmount == nil then
            if not silent then
                Library:Notify(stockErr or "Could not check stock.", 3)
            end
            return false
        end

        if stockAmount <= 0 then
            if not silent then
                Library:Notify(seedName .. " is out of stock.", 3)
            end
            return false
        end
    end

    local seedPrice = seedPriceByName[seedName]
    if not canAffordPrice(seedPrice) then
        if not silent then
            Library:Notify("Not enough shillings to buy " .. seedName .. ".", 3)
        end
        return false
    end

    local originalPos = nil
    local didTeleport = false
    local root = getCharacterRoot()

    if Settings.TeleportToShopOnBuy then
        if not root then
            if not silent then
                Library:Notify("Character root not found.", 3)
            end
            return false
        end

        local npcPos = Settings.SeedShopNpcPosition
        if not npcPos then
            if not silent then
                Library:Notify("Seed shop NPC not found.", 3)
            end
            return false
        end

        originalPos = root.Position
        local reached = teleportRootAndWait(root, npcPos, 1.2, 2.5, 10, 5)
        if not reached then
            if not silent then
                Library:Notify("Could not reach seed shop NPC.", 3)
            end
            return false
        end
        didTeleport = true
        task.wait(0.2)
    end

    local ok, result, reason = pcall(function()
        return PurchaseShopItemRemote:InvokeServer("SeedShop", seedName)
    end)

    if not ok then
        if not silent then
            Library:Notify("Purchase failed (invoke error).", 3)
        end
        return false
    end

    local reasonText = string.lower(tostring(reason or ""))
    local outOfStock = string.find(reasonText, "out of stock", 1, true) ~= nil
        or string.find(reasonText, "no stock", 1, true) ~= nil

    if result then
        if didTeleport and originalPos then
            local backRoot = getCharacterRoot()
            if backRoot then
                backRoot.CFrame = CFrame.new(originalPos)
            end
        end
        if not silent then
            Library:Notify("Bought: " .. seedName, 2)
        end
        return true
    else
        if outOfStock and didTeleport and originalPos then
            local backRoot = getCharacterRoot()
            if backRoot then
                backRoot.CFrame = CFrame.new(originalPos)
            end
        end
        if not silent then
            Library:Notify("Purchase failed: " .. tostring(reason or "Unknown"), 3)
        end
        return false
    end
end

local function getSelectedBuySeedList()
    local selectedSeedList = {}

    for _, seedName in ipairs(seedOptions) do
        if selectedBuySeedsMap[seedName] then
            table.insert(selectedSeedList, seedName)
        end
    end

    if #selectedSeedList == 0 and Settings.SelectedSeed then
        table.insert(selectedSeedList, Settings.SelectedSeed)
    end

    return selectedSeedList
end

local function tryBuyNextSelectedSeed(silent)
    local selectedSeedList = getSelectedBuySeedList()
    if #selectedSeedList == 0 then
        if not silent then
            Library:Notify("Select a seed first.", 3)
        end
        return false
    end

    if buySeedCycleIndex < 1 or buySeedCycleIndex > #selectedSeedList then
        buySeedCycleIndex = 1
    end

    local startIndex = buySeedCycleIndex
    for offset = 0, #selectedSeedList - 1 do
        local idx = ((startIndex - 1 + offset) % #selectedSeedList) + 1
        local seedName = selectedSeedList[idx]
        if tryBuySelectedSeed(silent, seedName) then
            buySeedCycleIndex = (idx % #selectedSeedList) + 1
            return true
        end
    end

    buySeedCycleIndex = (startIndex % #selectedSeedList) + 1
    return false
end

BuyGroup:AddButton("Buy Seed", function()
    tryBuyNextSelectedSeed(false)
end)

local function getGearStockAmount(gearName)
    if not GetShopDataRemote then
        return nil, "GetShopData remote not found."
    end

    local ok, data = pcall(function()
        return GetShopDataRemote:InvokeServer("GearShop")
    end)

    if not ok or type(data) ~= "table" or type(data.Items) ~= "table" then
        return nil, "Failed to fetch stock."
    end

    for itemName, itemData in pairs(data.Items) do
        if tostring(itemName):lower() == tostring(gearName):lower() then
            if type(itemData) == "table" then
                return tonumber(itemData.Amount) or 0, nil
            end
            return 0, nil
        end
    end

    return 0, nil
end

local function tryBuySelectedGear(silent, forcedGearName)
    local gearName = forcedGearName or Settings.SelectedGear
    if not PurchaseShopItemRemote then
        if not silent then
            Library:Notify("Purchase remote not found.", 3)
        end
        return false
    end

    if not gearName then
        if not silent then
            Library:Notify("Select a gear first.", 3)
        end
        return false
    end

    if Settings.CheckGearStockBeforeBuy then
        local stockAmount, stockErr = getGearStockAmount(gearName)
        if stockAmount == nil then
            if not silent then
                Library:Notify(stockErr or "Could not check stock.", 3)
            end
            return false
        end

        if stockAmount <= 0 then
            if not silent then
                Library:Notify(gearName .. " is out of stock.", 3)
            end
            return false
        end
    end

    local gearPrice = gearPriceByName[gearName]
    if not canAffordPrice(gearPrice) then
        if not silent then
            Library:Notify("Not enough shillings to buy " .. gearName .. ".", 3)
        end
        return false
    end

    local originalPos = nil
    local didTeleport = false
    local root = getCharacterRoot()

    if Settings.TeleportToGearShopOnBuy then
        if not root then
            if not silent then
                Library:Notify("Character root not found.", 3)
            end
            return false
        end

        local npcPos = Settings.GearShopNpcPosition
        if not npcPos then
            if not silent then
                Library:Notify("Gear shop NPC not found.", 3)
            end
            return false
        end

        originalPos = root.Position
        local reached = teleportRootAndWait(root, npcPos, 1.2, 2.5, 10, 5)
        if not reached then
            if not silent then
                Library:Notify("Could not reach gear shop NPC.", 3)
            end
            return false
        end
        didTeleport = true
        task.wait(0.2)
    end

    local ok, result, reason = pcall(function()
        return PurchaseShopItemRemote:InvokeServer("GearShop", gearName)
    end)

    if not ok then
        if not silent then
            Library:Notify("Purchase failed (invoke error).", 3)
        end
        return false
    end

    local reasonText = string.lower(tostring(reason or ""))
    local outOfStock = string.find(reasonText, "out of stock", 1, true) ~= nil
        or string.find(reasonText, "no stock", 1, true) ~= nil

    if result then
        if didTeleport and originalPos then
            local backRoot = getCharacterRoot()
            if backRoot then
                backRoot.CFrame = CFrame.new(originalPos)
            end
        end
        if not silent then
            Library:Notify("Bought: " .. gearName, 2)
        end
        return true
    else
        if outOfStock and didTeleport and originalPos then
            local backRoot = getCharacterRoot()
            if backRoot then
                backRoot.CFrame = CFrame.new(originalPos)
            end
        end
        if not silent then
            Library:Notify("Purchase failed: " .. tostring(reason or "Unknown"), 3)
        end
        return false
    end
end

local function getSelectedBuyGearList()
    local selectedGearList = {}

    for _, gearName in ipairs(gearOptions) do
        if selectedBuyGearsMap[gearName] then
            table.insert(selectedGearList, gearName)
        end
    end

    if #selectedGearList == 0 and Settings.SelectedGear then
        table.insert(selectedGearList, Settings.SelectedGear)
    end

    return selectedGearList
end

local function tryBuyNextSelectedGear(silent)
    local selectedGearList = getSelectedBuyGearList()
    if #selectedGearList == 0 then
        if not silent then
            Library:Notify("Select a gear first.", 3)
        end
        return false
    end

    if buyGearCycleIndex < 1 or buyGearCycleIndex > #selectedGearList then
        buyGearCycleIndex = 1
    end

    local startIndex = buyGearCycleIndex
    for offset = 0, #selectedGearList - 1 do
        local idx = ((startIndex - 1 + offset) % #selectedGearList) + 1
        local gearName = selectedGearList[idx]
        if tryBuySelectedGear(silent, gearName) then
            buyGearCycleIndex = (idx % #selectedGearList) + 1
            return true
        end
    end

    buyGearCycleIndex = (startIndex % #selectedGearList) + 1
    return false
end

GearGroup:AddButton("Buy Gear", function()
    tryBuyNextSelectedGear(false)
end)

SellGroup:AddButton("Sell", function()
    trySell(Settings.SellMode, false)
end)

local function getPromptWorldPosition(prompt)
    if not prompt or not prompt.Parent then
        return nil
    end
    if prompt.Parent:IsA("Attachment") then
        return prompt.Parent.WorldPosition
    end
    if prompt.Parent:IsA("BasePart") then
        return prompt.Parent.Position
    end
    return nil
end

local function getPromptModel(promptObj)
    if not promptObj or not promptObj.Parent then
        return nil
    end

    local node = promptObj.Parent
    if node:IsA("Attachment") then
        node = node.Parent
    end
    if node and node:IsA("BasePart") then
        node = node.Parent
    end
    while node and node ~= workspace and not node:IsA("Model") do
        node = node.Parent
    end
    if node and node:IsA("Model") then
        return node
    end
    return nil
end

local function getOwnerModel(model)
    local node = model
    while node and node ~= workspace do
        if node:IsA("Model") and node:GetAttribute("OwnerUserId") ~= nil then
            return node
        end
        node = node.Parent
    end
    return nil
end

local function isIgnoredSignPrompt(promptObj)
    local node = promptObj
    while node and node ~= workspace do
        if node.Name == "PlayerSign" or node.Name == "GrowAllSign" then
            local parentNode = node.Parent
            while parentNode and parentNode ~= workspace do
                if parentNode.Name == "Plots" then
                    return true
                end
                parentNode = parentNode.Parent
            end
        end
        node = node.Parent
    end
    return false
end

local function refreshHarvestPromptScanCache()
    local clientPlants = workspace:FindFirstChild("ClientPlants")
    if not clientPlants then
        harvestPromptScanCache = {}
        harvestPromptScanCacheAt = tick()
        return
    end

    local entries = {}
    for _, d in ipairs(clientPlants:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Parent and d.Enabled and (not isIgnoredSignPrompt(d)) then
            local model = getPromptModel(d)
            local ownerUserId = nil
            local isFavorited = false
            if model then
                local ownerModel = getOwnerModel(model)
                if ownerModel then
                    local ownerAttr = ownerModel:GetAttribute("OwnerUserId")
                    ownerUserId = tonumber(ownerAttr) or ownerAttr
                    isFavorited = ownerModel:GetAttribute("Favorited") == true
                end
            end
            local pos = getPromptWorldPosition(d)
            if pos then
                table.insert(entries, {
                    Prompt = d,
                    Pos = pos,
                    OwnerUserId = ownerUserId,
                    IsFavorited = isFavorited,
                })
            end
        end
    end

    harvestPromptScanCache = entries
    harvestPromptScanCacheAt = tick()
end

local function getClosestHarvestPrompts(limit, maxDistOverride)
    local char = LocalPlayer.Character
    if not char then
        return {}
    end

    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not root then
        return {}
    end

    local now = tick()
    if now - harvestPromptScanCacheAt >= HARVEST_PROMPT_SCAN_INTERVAL or #harvestPromptScanCache == 0 then
        refreshHarvestPromptScanCache()
    end

    local myPos = root.Position
    local maxDist = tonumber(maxDistOverride)
    if maxDist == nil then
        maxDist = Settings.Range
    end
    local candidates = {}

    for _, entry in ipairs(harvestPromptScanCache) do
        local prompt = entry.Prompt
        if prompt and prompt.Parent and prompt.Enabled then
            local blacklistedUntil = harvestBlacklistUntilByPrompt[prompt]
            if not (blacklistedUntil and now < blacklistedUntil) then
                local cooldownUntil = harvestCooldownByPrompt[prompt]
                if not (cooldownUntil and now < cooldownUntil) then
                    if entry.OwnerUserId == nil or entry.OwnerUserId == LocalPlayer.UserId then
                        if (not Settings.IgnoreFavorited) or (not entry.IsFavorited) then
                            local dist = (myPos - entry.Pos).Magnitude
                            if dist < maxDist then
                                table.insert(candidates, {
                                    Prompt = prompt,
                                    Pos = entry.Pos,
                                    Dist = dist,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        return a.Dist < b.Dist
    end)

    local out = {}
    local take = math.max(1, math.floor(tonumber(limit) or 1))
    for i = 1, math.min(#candidates, take) do
        table.insert(out, candidates[i].Prompt)
    end
    return out
end

local function markHarvestFailure(prompt)
    local fails = (harvestFailCountByPrompt[prompt] or 0) + 1
    harvestFailCountByPrompt[prompt] = fails
    harvestCooldownByPrompt[prompt] = tick() + 0.2
    if fails >= 4 then
        harvestBlacklistUntilByPrompt[prompt] = tick() + 3
        harvestFailCountByPrompt[prompt] = 0
    end
end

local function triggerHarvestPrompt(prompt)
    if typeof(fireproximityprompt) == "function" then
        return pcall(function()
            fireproximityprompt(prompt)
            fireproximityprompt(prompt)
            fireproximityprompt(prompt)
        end)
    end

    return pcall(function()
        prompt:InputHoldBegin()
        wait(0.1)
        prompt:InputHoldEnd()
    end)
end

local function harvestPromptBatch(prompts)
    if type(prompts) ~= "table" or #prompts == 0 then
        return false
    end

    local anySuccess = false
    for _, prompt in ipairs(prompts) do
        if prompt and prompt.Parent and prompt.Enabled then
            local ok = triggerHarvestPrompt(prompt)
            if ok then
                anySuccess = true
                harvestCooldownByPrompt[prompt] = tick() + 0.15
                harvestFailCountByPrompt[prompt] = 0
            else
                markHarvestFailure(prompt)
            end
        end
    end

    return anySuccess
end

local function getEquippedSeedTool()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end

    local function normalizeSeedName(seedName)
        return string.lower((tostring(seedName or "")):gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function resolvePlantTypeFromTool(tool)
        if not tool then
            return nil
        end

        local plantType = tool:GetAttribute("PlantType")
        if plantType and tostring(plantType) ~= "" then
            return tostring(plantType)
        end

        local name = tostring(tool.Name or "")
        local parsed = string.match(name, "^[xX]%d+%s+(.+)%s+[Ss]eed")
        if parsed and parsed ~= "" then
            return parsed
        end

        parsed = string.match(name, "^(.+)%s+[Ss]eed")
        if parsed and parsed ~= "" then
            return parsed
        end

        return nil
    end

    local function isSeedAllowed(plantType)
        if not plantType then
            return false
        end
        if next(selectedAutoPlantSeedsMap) == nil then
            return true
        end
        return selectedAutoPlantSeedsMap[tostring(plantType)] == true
    end

    local function isValidSeedTool(tool)
        if not tool or not tool:IsA("Tool") then
            return false
        end
        if tool:GetAttribute("IsCrate") or tool:GetAttribute("IsHarvested") then
            return false
        end

        local plantType = resolvePlantTypeFromTool(tool)
        if not isSeedAllowed(plantType) then
            local toolNameLower = string.lower(tostring(tool.Name or ""))
            local looksLikeSeedTool = string.find(toolNameLower, "seed", 1, true) ~= nil
            if not looksLikeSeedTool then
                return false
            end

            if next(selectedAutoPlantSeedsMap) == nil then
                return true
            end

            local matchedSelected = false
            for seedName, isSelected in pairs(selectedAutoPlantSeedsMap) do
                if isSelected and string.find(toolNameLower, normalizeSeedName(seedName), 1, true) then
                    matchedSelected = true
                    break
                end
            end
            if not matchedSelected then
                return false
            end
            return true
        end

        local toolNameLower = string.lower(tostring(tool.Name or ""))
        if string.find(toolNameLower, "seed", 1, true) == nil then
            return false
        end

        if ItemInventory and ItemInventory.getItemCount then
            local ok, count = pcall(ItemInventory.getItemCount, tool)
            if ok and count ~= nil then
                local numericCount = tonumber(count)
                if numericCount ~= nil then
                    return numericCount > 0
                end
                return true
            end
        end

        return true
    end

    for _, tool in ipairs(char:GetChildren()) do
        if isValidSeedTool(tool) then
            return tool
        end
    end

    if not Settings.AutoEquipPlantSeeds then
        return nil
    end

    local backpack = LocalPlayer:FindFirstChild("Backpack") or LocalPlayer:WaitForChild("Backpack", 2)
    if not backpack then
        return nil
    end

    local candidateTools = {}
    local selectedSeedList = {}
    if next(selectedAutoPlantSeedsMap) == nil then
        for _, seedName in ipairs(seedOptions) do
            table.insert(selectedSeedList, seedName)
        end
    else
        for _, seedName in ipairs(seedOptions) do
            if selectedAutoPlantSeedsMap[seedName] then
                table.insert(selectedSeedList, seedName)
            end
        end
    end

    for _, tool in ipairs(backpack:GetChildren()) do
        if isValidSeedTool(tool) then
            table.insert(candidateTools, tool)
        end
    end
    if #candidateTools == 0 then
        return nil
    end

    local orderedSeedNames = {}
    for _, seedName in ipairs(selectedSeedList) do
        table.insert(orderedSeedNames, seedName)
    end
    if #orderedSeedNames == 0 then
        for _, tool in ipairs(candidateTools) do
            local parsed = resolvePlantTypeFromTool(tool)
            if parsed and not table.find(orderedSeedNames, parsed) then
                table.insert(orderedSeedNames, parsed)
            end
        end
    end
    if #orderedSeedNames == 0 then
        for _, tool in ipairs(candidateTools) do
            table.insert(orderedSeedNames, tostring(tool.Name))
        end
    end

    if autoPlantEquipCycleIndex > #orderedSeedNames then
        autoPlantEquipCycleIndex = 1
    end
    local preferredSeedName = orderedSeedNames[autoPlantEquipCycleIndex]
    autoPlantEquipCycleIndex = autoPlantEquipCycleIndex + 1
    if autoPlantEquipCycleIndex > #orderedSeedNames then
        autoPlantEquipCycleIndex = 1
    end

    local toolToEquip = nil
    local preferredLower = normalizeSeedName(preferredSeedName)
    for _, tool in ipairs(candidateTools) do
        local toolLower = string.lower(tostring(tool.Name or ""))
        if string.find(toolLower, preferredLower, 1, true) and string.find(toolLower, "seed", 1, true) then
            toolToEquip = tool
            break
        end
    end
    if not toolToEquip then
        for _, tool in ipairs(candidateTools) do
            local parsed = resolvePlantTypeFromTool(tool)
            if parsed and normalizeSeedName(parsed) == preferredLower then
                toolToEquip = tool
                break
            end
        end
    end
    if not toolToEquip then
        toolToEquip = candidateTools[1]
    end

    if not toolToEquip then
        return nil
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return nil
    end

    for _ = 1, 4 do
        pcall(function()
            humanoid:UnequipTools()
            humanoid:EquipTool(toolToEquip)
        end)
        task.wait(0.08)

        if toolToEquip.Parent == char or toolToEquip:IsDescendantOf(char) then
            return toolToEquip
        end

        pcall(function()
            toolToEquip.Parent = char
        end)
        task.wait(0.05)
        if toolToEquip.Parent == char or toolToEquip:IsDescendantOf(char) then
            return toolToEquip
        end
    end

    return nil
end

local function plantAtCharacterPosition()
    if not Settings.AutoPlantAtCharacter then
        return
    end

    local now = tick()
    if now - lastPlantTime < Settings.Delay then
        return
    end

    local tool = getEquippedSeedTool()
    if not tool then
        return
    end

    local plantType = tool:GetAttribute("PlantType")
    if not plantType then
        local name = tostring(tool.Name or "")
        plantType = string.match(name, "^[xX]%d+%s+(.+)%s+[Ss]eed")
            or string.match(name, "^(.+)%s+[Ss]eed")
    end
    if not plantType then
        return
    end

    local plantPos = Settings.SavedPlantPosition
    if not plantPos then
        Settings.AutoPlantAtCharacter = false
        if not warnedMissingSavedPosition then
            warnedMissingSavedPosition = true
            Library:Notify("Set a plant position first.", 3)
        end
        task.defer(function()
            if Toggles.AutoPlantAtCharacterToggle then
                Toggles.AutoPlantAtCharacterToggle:SetValue(false)
            end
        end)
        return
    end

    lastPlantTime = now

    pcall(function()
        if PlantRemote:IsA("RemoteFunction") then
            PlantRemote:InvokeServer(plantType, plantPos)
        else
            PlantRemote:FireServer(plantType, plantPos)
        end
    end)
end

local function isQuestEntryClaimable(entry)
    if type(entry) ~= "table" then
        return false
    end

    if entry.Claimed == true or entry.IsClaimed == true then
        return false
    end

    if entry.Completed == true or entry.IsCompleted == true or entry.Done == true then
        return true
    end

    local status = tostring(entry.Status or ""):lower()
    if status == "completed" or status == "complete" then
        return true
    end

    local progress = tonumber(entry.Progress or entry.Current or entry.Value or entry.Amount or 0) or 0
    local goal = tonumber(entry.Goal or entry.Target or entry.Required or entry.Max or 0) or 0
    return goal > 0 and progress >= goal
end

local function autoClaimQuests()
    if not (ClaimQuestRemote and ClaimQuestRemote:IsA("RemoteEvent")) then
        return
    end

    if RequestQuestsRemote and RequestQuestsRemote:IsA("RemoteEvent") then
        pcall(function()
            RequestQuestsRemote:FireServer()
        end)
    end

    if type(latestQuestData) ~= "table" then
        return
    end

    for _, questType in ipairs({ "Daily", "Weekly" }) do
        local bucket = latestQuestData[questType]
        local active = bucket and bucket.Active
        if type(active) == "table" then
            for i = 1, 5 do
                local questIndex = tostring(i)
                if isQuestEntryClaimable(active[questIndex]) then
                    pcall(function()
                        ClaimQuestRemote:FireServer(questType, questIndex)
                    end)
                end
            end
        end
    end
end

task.spawn(function()
    while task.wait(Settings.Delay) do
        local ok, err = pcall(function()
            local now = tick()

            if Settings.Enabled then
                local batchSize = math.max(1, math.floor(tonumber(Settings.HarvestBatchSize) or 5))
                local closestPrompts = getClosestHarvestPrompts(batchSize)
                if Settings.AutoHarvestTeleport and now - lastHarvestTeleportTime >= 0.5 then
                    local teleportPrompts = getClosestHarvestPrompts(1, math.huge)
                    local teleportPrompt = teleportPrompts[1]
                    if teleportPrompt then
                        local root = getCharacterRoot()
                        local promptPos = getPromptWorldPosition(teleportPrompt)
                        if root and promptPos then
                            root.CFrame = CFrame.new(promptPos + Vector3.new(0, 3, 0))
                            lastHarvestTeleportTime = now
                        end
                    end
                    closestPrompts = getClosestHarvestPrompts(batchSize)
                end

                local firstPrompt = closestPrompts[1]
                if firstPrompt then
                    harvestPromptBatch(closestPrompts)
                end
            end

            if Settings.AutoPlantAtCharacter then
                plantAtCharacterPosition()
            end

            if Settings.AutoBuyLoop then
                if now - lastAutoBuyTime >= Settings.AutoBuyDelay then
                    lastAutoBuyTime = now
                    tryBuyNextSelectedSeed(true)
                end
            end

            if Settings.AutoBuyGearLoop then
                if now - lastAutoBuyGearTime >= Settings.AutoBuyGearDelay then
                    lastAutoBuyGearTime = now
                    tryBuyNextSelectedGear(true)
                end
            end

            if Settings.AutoSellLoop then
                if not SellItemsRemote then
                    if not warnedMissingSellRemotes then
                        warnedMissingSellRemotes = true
                        Library:Notify("SellItems remote not found.", 3)
                    end
                elseif now - lastAutoSellTime >= Settings.AutoSellDelay then
                    lastAutoSellTime = now
                    if Settings.AutoSellOnlyWhenInventoryFull then
                        if now - lastInventoryFullSellTime >= Settings.InventoryFullSellCooldown
                            and shouldSellFromInventoryFullNotification() then
                            lastInventoryFullSellTime = now
                            trySell(Settings.SellMode, true)
                        end
                    else
                        trySell(Settings.SellMode, true)
                    end
                end
            end

            if Settings.AutoClaimQuests then
                if not (ClaimQuestRemote and RequestQuestsRemote and UpdateQuestsRemote) then
                    if not warnedMissingQuestRemotes then
                        warnedMissingQuestRemotes = true
                        Library:Notify("Quest remotes not found.", 3)
                    end
                else
                    if now - lastAutoClaimQuestTime >= Settings.AutoClaimQuestDelay then
                        lastAutoClaimQuestTime = now
                        autoClaimQuests()
                    end
                end
            end
        end)

        if not ok then
            warn("[Garden] Main loop recovered from error:", err)
        end
    end
end)

SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("BloomWare/Theme")
ThemeManager:ApplyToTab(Tabs["UI Settings"])
ThemeManager:ApplyTheme("Default")
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:SetFolder("BloomWare/GardenHorizons")
SaveManager:LoadAutoloadConfig()
