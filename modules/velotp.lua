local function instantTP(targetCFrame)
    if not canTeleport() then return end

    local char = game.Players.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local oldVelocity = hrp.Velocity
    hrp.Velocity = Vector3.new(0, 0, 0)
    
    hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
    task.wait(0.04)
    hrp.Velocity = oldVelocity  -- restore natural fall
    
    task.wait(0.06)
    hrp.CFrame = targetCFrame  -- snap exactly
end
