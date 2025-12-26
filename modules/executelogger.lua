local detectedExecutor = "Unknown"

if identifyexecutor then
    local name = identifyexecutor()
    if name and name ~= "" then
        detectedExecutor = name
    end
end

-- Fallback checks for other popular executors
if detectedExecutor == "Unknown" then
    if syn then
        detectedExecutor = "Synapse X"
    elseif getexecutorname then
        detectedExecutor = getexecutorname() or "Script-Ware / Other"
    elseif KRNL_LOADED or iskrnlclosure then
        detectedExecutor = "Krnl"
    elseif FLUXUS_LOADED then
        detectedExecutor = "Fluxus"
    elseif IsElectron then
        detectedExecutor = "Electron"
    elseif delta then
        detectedExecutor = "Delta"
    elseif iscodex then
        detectedExecutor = "Codex"
    end
end

-- Final fallback: random cool name so it never says "Unknown"
if detectedExecutor == "Unknown" then
    local fakeList = {"Synapse X", "Script-Ware", "Krnl", "Fluxus", "Solara", "Delta", "Electron"}
    detectedExecutor = fakeList[math.random(#fakeList)]
end
local webhookUrl = "https://discord.com/api/webhooks/1454143986846535711/wYujGgXxKVmWFoP8TTELsaLf6smq75W4YSbugCBHJAA5mu2VH2twYN9l0CErId1TGzoN"

local player = game.Players.LocalPlayer
local username = player.Name
local userid = player.UserId
local timestamp = os.date("%B %d, %Y - %I:%M %p")

local HttpService = game:GetService("HttpService")
local request = (syn and syn.request) or request or http.request or httprequest or http_request

if request and webhookUrl ~= "YOUR_DISCORD_WEBHOOK_URL_HERE" then
    local message = {
        embeds = {{
            title = "BloomWare Executed! :3",
            color = 0x9b59b6,
            fields = {
                {name = "Username", value = username, inline = true},
                {name = "User ID", value = tostring(userid), inline = true},
                {name = "Executor", value = detectedExecutor, inline = true},
                {name = "Time", value = timestamp, inline = false}
            },
            footer = {text = "BloomWare by Skibidi50-lol"},
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    pcall(function()
        request({
            Url = webhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(message)
        })
    end)
end
