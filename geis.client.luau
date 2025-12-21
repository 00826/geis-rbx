--!strict

--- ### geis.client.luau
---
--- geis client benchmarker

--- setup
do
	--- disable coregui
	local startergui = game:GetService("StarterGui")
	local success; repeat
		success = pcall(function() startergui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
		task.wait()
	until success == true

	--- wait for load
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
end

--- benchmark
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local geis = require(ReplicatedFirst:WaitForChild("geis"))

local receipt = geis.receipt(geis.run(require(ReplicatedFirst:WaitForChild("params"))))

print("benchmark receipt:", receipt)