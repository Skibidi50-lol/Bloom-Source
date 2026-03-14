local Scripts = {
    -- Garden Horizons
    [130594398886540] = "https://raw.githubusercontent.com/Skibidi50-lol/Bloom-Source/refs/heads/main/scripts/GardenHorizons.lua",

    -- BasketBall legends
    [4931927012] = "github.com/Skibidi50-lol/Bloom-Source/blob/main/scripts/BasketballLegends.lua",
    -- Arsenal
    [4931927012] = "github.com/Skibidi50-lol/Bloom-Source/blob/main/scripts/BasketballLegends.lua",
}

local ScriptURL = Scripts[game.PlaceId]
if ScriptURL then
    loadstring(game:HttpGet(ScriptURL))()
else
    game.Players.LocalPlayer:Kick("BloomWare | This game is not supported. Copied to clipboard link with supported games")
end
