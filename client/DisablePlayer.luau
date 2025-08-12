------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|


local Player = game:GetService("Players").LocalPlayer
local Comm = game:GetService("ReplicatedStorage").Blasters.Remotes.StunRemote

local Controls = require(Player.PlayerScripts.PlayerModule):GetControls()

Comm.OnClientEvent:Connect(function(command)
	
	if command == "Disable" then
		print("Disabled for player")
		Controls:Disable()
	end	

	if command == "Enable" then
		print("Enabled for player")
		Controls:Enable()
	end	
	
end)

Player.CharacterAdded:Connect(function()
	print("Respawned")
	Controls:Enable()
end)