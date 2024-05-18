local SGUI = game:GetService("StarterGui")

local S; repeat
	S = pcall(function() SGUI:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
	task.wait()
until S == true