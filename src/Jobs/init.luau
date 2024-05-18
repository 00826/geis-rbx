--!nonstrict

-- This file is part of geis-rbx and is licensed under MIT License; see LICENSE.txt for details
-- [read more about geis-rbx](github.com/00826/geis-rbx)

--[[
["Job"] = function()
	
end;
]]

export type JobTable = {
	Header: string;
	Work: { [string]: () -> () };
	RefreshRate: number;
	Cycles: number;
}

return {
	Header			= "";

	Work			= {

	};

	RefreshRate		= 1 / 15;
	Cycles			= 5000;
} :: JobTable