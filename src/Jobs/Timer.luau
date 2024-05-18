-- This file is part of geis-rbx and is licensed under MIT License; see LICENSE.txt for details
-- [read more about geis-rbx](github.com/00826/geis-rbx)

local RunService = game:GetService("RunService")

local Cache = {}
local Priority = Enum.RenderPriority.First.Value
local Offset = 0

local Timer = { __index = {}; }

---calls associated function and stores its runtime in microseconds
function Timer.__index:Run()
	local T0 = os.clock()
	self.Job()
	local T1 = os.clock()
	table.insert(self.Times, (T1 - T0) * 1000000)
	if #self.Times > self.Cycles then
		repeat table.remove(self.Times, 1)
		until #self.Times <= self.Cycles
	end
end

---returns a sorted copy of benchmark times with an option to cull a percentage of outlying (slow) times
---@return number[]
function Timer.__index:Read(Cull: number?): {number}
	local T = table.clone(self.Times)
	table.sort(T)
	if Cull then
		local n = math.ceil(#T * (1 - (Cull / 100)))
		repeat table.remove(T)
		until #T <= n
	end
	return T
end

return function(Name: string, Job: (() -> ())?, Cycles: number?)
	if not Cache[Name] then
		local T = setmetatable({
			Job = Job;
			Cycles = Cycles or 10000;
			Times = table.create(Cycles or 10000);
		}, Timer)

		Cache[Name] = T

		Offset += 1
		RunService:BindToRenderStep(Name, Priority + Offset, function() T:Run() end)
	end
	return Cache[Name]
end