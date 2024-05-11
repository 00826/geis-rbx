--!strict

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

local Jobs = require(script.Parent)
local Job_Count = #Jobs.Work
local Job_Size = Jobs.Size
local Job_P = Jobs.P
local Job_SortBy = Jobs.SortBy

local function Average(T: {number}): number
	if #T == 0 then
		return 0
	end

	local Sum = 0
	for _, Time in T do
		Sum += Time
	end

	return Sum / #T
end

local function Evaluate(P: number, T: {number}): number
	return math.ceil((1 - (P / 100)) * #T)
end

local function Slowest(a: Frame): number
	return math.max( a:GetAttribute("Server") or 0, a:GetAttribute("ServerP") or 0, a:GetAttribute("Client") or 0, a:GetAttribute("ClientP") or 0 )
end

local function SlowestNonP(a: Frame): number
	return a:GetAttribute(Job_SortBy or "Server") or a:GetAttribute("Server") or 0
end

local function Sort(a: Frame, b: Frame): boolean
	return Slowest(a) < Slowest(b)
end

local function SortNonP(a: Frame, b: Frame): boolean
	return SlowestNonP(a) < SlowestNonP(b)
end

local Timer = {
	JobTimes = table.create(Job_Count) :: { {number} };
	CatFrames = table.create(Job_Count) :: { Frame };
	Max = 0;
}

function Timer.Run(Job: () -> ()): number
	local start = os.clock()
	Job()
	local finish = os.clock()
	return finish - start
end

function Timer.Avg(JobId: number): number
	local TimeList = Timer.JobTimes[JobId]
	if not TimeList then
		return 0
	end

	return Average(TimeList)
end

function Timer.Per(JobId: number): number
	local TimeList = Timer.JobTimes[JobId]
	if not TimeList then
		return 0
	end

	local FastestToSlowest = table.clone(TimeList)
	table.sort(FastestToSlowest)
	
	return Average({unpack(FastestToSlowest, #FastestToSlowest - Evaluate(Job_P, FastestToSlowest))})
end

assert(script.Parent)

local ScreenGui = script.Parent:FindFirstAncestorOfClass("ScreenGui") :: ScreenGui

local Display = ScreenGui:WaitForChild("Display") :: Frame
local Main = Display:WaitForChild("Main") :: Frame

local template = Main:WaitForChild("_template") :: Frame
template.Visible = false

local HeaderLabel = Main:WaitForChild("Header") :: TextLabel
HeaderLabel.Text = Jobs.Header

for i, JobInfo in ipairs(Jobs.Work) do
	local Name, JobFn = JobInfo.Name, JobInfo.F

	Timer.JobTimes[i] = table.create(Job_Size + 1)
	
	local Frame = nil
	if IsServer then
		Frame = template:Clone()
		Frame.Name = tostring(i)
		Frame.Visible = true
		Frame.LayoutOrder = i
		Frame.Parent = template.Parent
	else
		Frame = Main:WaitForChild(tostring(i)) :: Frame
		Timer.CatFrames[i] = Frame
		
		local JobLabel = Frame:WaitForChild("JobName") :: TextLabel
		
		Frame:GetAttributeChangedSignal("SampleSize"):Connect(function()
			JobLabel.Text = ("[%d]:	" .. Name .. "	(rolling avg %d / %d)"):format(i, Frame:GetAttribute("SampleSize") or 0, Job_Size)
		end)
		
		do
			local Cat = "Server"
			local Append = ": "
			local T = { ["$c"] = Cat; ["$a"] = Append; }

			local CatFrame = Frame:WaitForChild(Cat)
			local Bar = CatFrame:WaitForChild("Bar") :: Frame
			local Speed = CatFrame:WaitForChild("Speed") :: TextLabel
			
			Frame:GetAttributeChangedSignal(Cat):Connect(function()
				local Value = Frame:GetAttribute(Cat) or 0
				Speed.Text = ("$c$a %.3fμs"):format(Value):gsub("$%w", T)
				Bar.Size = UDim2.fromScale(math.clamp(Value / (Timer.Max == 0 and Value or Timer.Max), 0, 1), 1)
			end)
		end
		do
			local Cat = "ServerP"
			local Append = "er" .. Job_P .. ": "
			local T = { ["$c"] = Cat; ["$a"] = Append; }

			local CatFrame = Frame:WaitForChild(Cat)
			local Bar = CatFrame:WaitForChild("Bar") :: Frame
			local Speed = CatFrame:WaitForChild("Speed") :: TextLabel

			Frame:GetAttributeChangedSignal(Cat):Connect(function()
				local Value = Frame:GetAttribute(Cat) or 0
				Speed.Text = ("$c$a %.3fμs"):format(Value):gsub("$%w", T)
				Bar.Size = UDim2.fromScale(math.clamp(Value / (Timer.Max == 0 and Value or Timer.Max), 0, 1), 1)
			end)
		end
		do
			local Cat = "Client"
			local Append = ": "
			local T = { ["$c"] = Cat; ["$a"] = Append; }

			local CatFrame = Frame:WaitForChild(Cat)
			local Bar = CatFrame:WaitForChild("Bar") :: Frame
			local Speed = CatFrame:WaitForChild("Speed") :: TextLabel

			Frame:GetAttributeChangedSignal(Cat):Connect(function()
				local Value = Frame:GetAttribute(Cat) or 0
				Speed.Text = ("$c$a %.3fμs"):format(Value):gsub("$%w", T)
				Bar.Size = UDim2.fromScale(math.clamp(Value / (Timer.Max == 0 and Value or Timer.Max), 0, 1), 1)
			end)
		end
		do
			local Cat = "ClientP"
			local Append = "er" .. Job_P .. ": "
			local T = { ["$c"] = Cat; ["$a"] = Append; }

			local CatFrame = Frame:WaitForChild(Cat)
			local Bar = CatFrame:WaitForChild("Bar") :: Frame
			local Speed = CatFrame:WaitForChild("Speed") :: TextLabel

			Frame:GetAttributeChangedSignal(Cat):Connect(function()
				local Value = Frame:GetAttribute(Cat) or 0
				Speed.Text = ("$c$a %.3fμs"):format(Value):gsub("$%w", T)
				Bar.Size = UDim2.fromScale(math.clamp(Value / (Timer.Max == 0 and Value or Timer.Max), 0, 1), 1)
			end)
		end
	end

	RunService.Stepped:Connect(function()
		local TimeList = Timer.JobTimes[i]
		table.insert(TimeList, 1, Timer.Run(JobFn))
		if #TimeList > Job_Size then
			repeat table.remove(TimeList)
			until #TimeList >= Job_Size
		end
		
		if IsServer then
			Frame:SetAttribute("Server", Timer.Avg(i) * 1000000)
			Frame:SetAttribute("ServerP", Timer.Per(i) * 1000000)
			Frame:SetAttribute("SampleSize", #TimeList)
		else
			Frame:SetAttribute("Client", Timer.Avg(i) * 1000000)
			Frame:SetAttribute("ClientP", Timer.Per(i) * 1000000)
			
			if i == Job_Count then
				table.sort(Timer.CatFrames, SortNonP)
				
				for n, ThisFrame in ipairs(Timer.CatFrames) do
					ThisFrame.LayoutOrder = n
				end
				
				table.sort(Timer.CatFrames, Sort)
				Timer.Max = Slowest(Timer.CatFrames[i])
			end
		end
	end)
end

return Timer