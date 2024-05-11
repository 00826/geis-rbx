--!nonstrict

--[read more about geis-rbx](github.com/00826/geis-rbx)

export type JobTable = {
	Header: string; -- display header of job
	SortBy: ("Server"|"ServerP"|"Client"|"ClientP")?; -- sort by speed in ascending order (default: "Server")
	Size: number; -- size of times to sample from
	P: number; -- latency-time constant, usually 90, 95, or 99
	Work: { { Name: string, F: () -> () } }; -- array of work-tables to benchmark
}

--[[
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

local Toolbox = game:GetService("ReplicatedStorage"):WaitForChild("Toolbox")

local R = Random.new()
]]

return {
	Header = "";
	SortBy = "Server";
	Size = 10000;
	P = 95;

	Work = {
		--[[ -- work-table template
		{
			Name = "";
			F = function()
				return
			end;
		};
		]]
	};
} :: JobTable