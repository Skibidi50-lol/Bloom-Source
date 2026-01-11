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
