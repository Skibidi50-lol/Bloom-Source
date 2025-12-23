local function instantTP(cf)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChild("Humanoid")
	if not root or not hum then return end
	hum.Health = 100
	root.Anchored = true
	root.CFrame = cf + Vector3.new(0,1,0)
	task.wait(0.05)
	root.Anchored = false
end
