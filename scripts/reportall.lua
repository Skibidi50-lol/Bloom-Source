getgenv().enabled = true
--message
local reasons = {
    {category = "Bullying", comment = ""},
    {category = "Swearing", comment = ""},
    {category = "Cheating", comment = ""},
    {category = "Scamming", comment = ""},
    {category = "Off-platform links", comment = ""},
    {category = "Personal Information", comment = ""}
}

while getgenv().enabled do
    for i, v in pairs(game.Players:GetChildren()) do
        task.wait(0.03)
        if v.Name ~= game.Players.LocalPlayer.Name then
            local reason = reasons[math.random(1, #reasons)]
            game:GetService("Players"):ReportAbuse(v, reason.category, reason.comment)
            warn("Successfully Reported " .. v.Name .. " for " .. reason.category)
        end
    end
end
