-- This file is part of geis-rbx and is licensed under MIT License; see LICENSE.txt for details
-- [read more about geis-rbx](github.com/00826/geis-rbx)

local RunService			= game:GetService("RunService")

local Timer					= require(script.Parent:WaitForChild("Timer"))
local Histogram				= require(script.Parent:WaitForChild("Histogram"))
local Colors				= require(script.Parent:WaitForChild("Colors"))

local JobTable				= require(script.Parent)

local ScreenGui				= script:FindFirstAncestorOfClass("ScreenGui")

local Display				= ScreenGui:WaitForChild("Display")
local Main					= Display:WaitForChild("Main")

local Graph					= Main:WaitForChild("Graph") :: Frame
local HistTemplate			= Graph:WaitForChild("Histogram") :: Frame
local UnitContainer			= Graph:WaitForChild("Units") :: Frame
local KeyFrame				= Graph:WaitForChild("Key") :: Frame
local KeyEntry				= KeyFrame:WaitForChild("Entry") :: TextLabel
local FreqN					= Main:WaitForChild("FreqN") :: TextLabel
local Header				= Main:WaitForChild("Header") :: TextLabel

local UnitLabels			= table.create(10)
local UnitSuffix			= "µs"
local UnitPrecision			= "%.2f"

local EntryPrefix			= "■ "

do
	local Column = HistTemplate:WaitForChild("Column") :: Frame
	Column.Visible = false

	local UnitFrame = UnitContainer:WaitForChild("UnitFrame") :: Frame
	UnitFrame.Visible = false
	for i = 1, 10 do
		local C = Column:Clone()
		C.Name = tostring(i)
		C.LayoutOrder = i
		C.Visible = true
		C.Parent = HistTemplate

		local U = UnitFrame:Clone()
		U.Name = tostring(i)
		U.LayoutOrder = i
		U.Visible = true
		U.Parent = UnitContainer
		local RLabel = U:FindFirstChild("RLabel") :: TextLabel
		local LLabel = U:FindFirstChild("LLabel") :: TextLabel

		if i == 1 then
			RLabel.Visible = true
			LLabel.Visible = true
			LLabel.Text = "0" .. UnitSuffix
		else
			RLabel.Visible = true
			LLabel.Visible = false
		end
		table.insert(UnitLabels, RLabel)
	end

	HistTemplate.Visible = false
end

Header.Text = JobTable.Header

---cache timer objects and make histogram entries
local Timers				= {}
local TimerColors			= {}

local Hidden				= {}
local Graphs				= {}
local Columns				= {}

local LastMax				= 0
local MaxTime				= 0

for Name, F in JobTable.Work do
	Timers[Name] = Timer(Name, F, JobTable.Cycles)
	local Color = table.remove(Colors, 1) or Color3.fromRGB(255, 255, 255)
	TimerColors[Name] = Color

	local WorkGraph = HistTemplate:Clone()
	WorkGraph.Name = Name
	WorkGraph.Visible = true
	WorkGraph.Parent = Graph
	Graphs[Name] = WorkGraph
	Columns[Name] = table.create(10)

	local K = KeyEntry:Clone()
	K.Name = Name
	K.Text = EntryPrefix .. Name
	K.TextColor3 = Color
	K.Visible = true
	K.Parent = KeyFrame

	for i = 1, 10 do
		local Column = WorkGraph:FindFirstChild(tostring(i)) :: Frame
		Column.BackgroundColor3 = Color
		local UIStroke = Column:FindFirstChildOfClass("UIStroke")
		if UIStroke then
			UIStroke.Color = Color
		end

		Columns[Name][i] = Column
	end
end

---refresh histograms on refresh rate
local Elapsed = 0
RunService.Heartbeat:Connect(function(dt: number)
	Elapsed += dt
	if Elapsed < JobTable.RefreshRate then return end
	Elapsed -= JobTable.RefreshRate

	local TimesNow = {}
	local MaxTimes = table.create(8)
	local Histograms = {}
	local MaxFreqs = table.create(8)

	for Name, T in Timers do
		local SortedTimes = T:Read(1)
		table.insert(MaxTimes, SortedTimes[#SortedTimes])
		TimesNow[Name] = SortedTimes

		local H = Histogram(SortedTimes, MaxTime)
		Histograms[Name] = H
		table.insert(MaxFreqs, math.max(unpack(H)))
	end

	if #MaxTimes == 0 then return end
	if #MaxFreqs == 0 then return end

	MaxTime = math.max(unpack(MaxTimes))
	local MaxFreq = math.max(unpack(MaxFreqs))

	for Name, SortedTimes in TimesNow do
		local H = Histograms[Name]
		local ColumnArray = Columns[Name]

		for i, Freq in ipairs(H) do
			local Column = ColumnArray[i]
			Column.Size = UDim2.fromScale(0.1, Freq / MaxFreq)
			Column.ZIndex = 10 + (MaxFreq - Freq)
		end
	end

	FreqN.Text = tostring(MaxFreq)

	if LastMax ~= MaxTime then
		LastMax = MaxTime
		for i, Label: TextLabel in ipairs(UnitLabels) do
			Label.Text = (UnitPrecision):format((i / 10) * MaxTime) .. UnitSuffix
		end
	end
end)