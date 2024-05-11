--!strict

game:GetService("Players").PlayerAdded:Connect(function(P: Player)
	game:GetService("StarterGui"):WaitForChild("Geis"):Clone().Parent = P:WaitForChild("PlayerGui")
	P:WaitForChild("PlayerGui"):WaitForChild("Freecam"):Destroy()
end)