getgenv().TrophyFarm = false
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
