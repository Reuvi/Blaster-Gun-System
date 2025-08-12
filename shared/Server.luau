------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|																						|
------------------------------------------------------------------------------------------------------------------------------------------

local BlasterFolder = game:GetService("ReplicatedStorage").Blasters;
local CommsRemote = BlasterFolder.Remotes.CommsRemote;
local StunsRemote = BlasterFolder.Remotes.StunRemote;
local ProjRemote = BlasterFolder.Remotes.ProjectileRemote
local HttpService = game:GetService("HttpService")

local dontTouch = 
	{
	["HumanoidRootPart"] = true;
	["UL1"] = true;
	["UL2"] = true;
	["L1"] = true;
	["H1"] = true;
	["R1"] = true;
	["Grip"] = true;
	["Barrel"] = true;
	}

local resetTime = 5
local walkSpeedDefault = 16
local walkSpeedReduced = 5
local timer;
local Stuns = {}

local function makeJoint(kind,part0,part1,c0,name)				
	local w = Instance.new(kind)
	w.Part0 = part0
	w.Part1 = part1
	w.C0 = c0

	if name then 
		w.Name = name 
	end

	w.Parent = w.Part0				
end

--Welds Gun handle to Players Torso Motor6d Joint which is on the body
local function Setup(Player, Table)
	
	Player.DevEnableMouseLock = true
	
	if Player.Character:FindFirstChild("Primary") then
		Player.Character.Primary:Destroy()
	end
	
	if Player.Character:FindFirstChild("MedStick") then
		Player.Character.MedStick:Destroy()
	end
	
	if Player.Character:FindFirstChild("Secondary") then
		Player.Character.Secondary:Destroy()
	end
	
	if Player.Character.UL1:FindFirstChild("Weld") then
		Player.Character.UL1:FindFirstChild("Weld"):Destroy()
	end
	
	if Player.Character.UL2:FindFirstChild("Weld") then
		Player.Character.UL2:FindFirstChild("Weld"):Destroy()
	end
	
	if Player.Character.L1:FindFirstChild("Weld") then
		Player.Character.L1:FindFirstChild("Weld"):Destroy()
	end
	
	if Player.Character.H1:FindFirstChild("Weld") then
		Player.Character.H1:FindFirstChild("Weld"):Destroy()
	end
	
	if Player.Character.R1:FindFirstChild("Weld") then
		Player.Character.R1:FindFirstChild("Weld"):Destroy()
	end
	CommsRemote:FireClient(Player, "Destroy")
	
	--Give Player Flashlight if they dont have one
	if not Player.Character.Head:FindFirstChild("FlashLight") then
		local FlashLightObj = Instance.new("SpotLight")
		FlashLightObj.Parent = Player.Character.Head
		FlashLightObj.Name = "FlashLight"
		FlashLightObj.Enabled = false
		FlashLightObj.Brightness = 10
		FlashLightObj.Range = 60
		FlashLightObj.Color = Color3.new(1, 1, 0.498039)
	end
	
	local Primary, Secondary = nil, nil;
	local ReturnTable = {}
	if Table["Primary"] then
		Primary = Table["Primary"].Primary:Clone()
		Primary.Parent = Player.Character;
		makeJoint("Weld", Player.Character:FindFirstChild("H1"),Primary.Grip,CFrame.new()*CFrame.fromEulerAnglesXYZ(math.pi/-2,-.9,-1.6))
		ReturnTable["Primary"] = Primary;
	else
		return
	end
	
	--Welds Secondary handle to Players left leg Motor6d Joint which is on the body
	
	if Table["Secondary"] then
		Secondary = Table["Secondary"].Secondary:Clone()
		Secondary.Parent = Player.Character;
		makeJoint("Weld", Player.Character:FindFirstChild("UL1"),Secondary.Grip,CFrame.new()*CFrame.fromEulerAnglesXYZ(math.pi,0,0));
		ReturnTable["Secondary"] = Secondary;
	end
	
	CommsRemote:FireClient(Player, "SetupClient", ReturnTable);
end

--removing back weld for player and adding weld to other motorjoint for gun or opposite

local function Equip(Character, isEquip, Weapon)
	Weapon:SetAttribute("Equipped", isEquip)
	if Weapon.Name == "Primary" then
	-- Add in Check for Secondary 
	-- Ah okay, the only changes for Primary to Seco	-- kk 
	 	if isEquip then if not Character.H1:FindFirstChild("Weld") then return end end 
		if not isEquip then if not Character.R1:FindFirstChild("Weld") then return end end
			
		
		local Weld = if isEquip then Character.H1:FindFirstChild("Weld") else Character.R1:FindFirstChild("Weld");
		local WeldPoint = if isEquip then Character.R1 else Character.H1; 
		local Eulers = if isEquip then CFrame.fromEulerAnglesXYZ(math.pi/-1,0,0) else CFrame.fromEulerAnglesXYZ(math.pi/-2,-0.9,-1.6) 
		Weld:Destroy()
		makeJoint("Weld", WeldPoint,Weapon.Grip,CFrame.new()*Eulers)
	elseif Weapon.Name == "Secondary" then
		if isEquip then if not Character.UL1:FindFirstChild("Weld") then return end end 
		if not isEquip then if not Character.R1:FindFirstChild("Weld") then return end end


		local Weld = if isEquip then Character.UL1:FindFirstChild("Weld") else Character.R1:FindFirstChild("Weld");
		local WeldPoint = if isEquip then Character.R1 else Character.UL1; 
		local Eulers = if isEquip then CFrame.fromEulerAnglesXYZ(math.pi/-1,0,0) else CFrame.fromEulerAnglesXYZ(math.pi,0,0) 
		Weld:Destroy()
		makeJoint("Weld", WeldPoint,Weapon.Grip,CFrame.new()*Eulers)
	end
end


local function Blast(Player, ...)
	
	local Weapon, End, spread, Config, deflect, currentMode = ...;
		
	if Weapon.Info.Ammo.Value < 0 or not Weapon:GetAttribute("Equipped") then return end;
	
	local range
	
	if Config:FindFirstChild("ShotgunPellets") then range = Config.ShotgunPellets.Value else range = 1 end; 

	for i = 1, range do
		coroutine.wrap(function()
			
			local Origin = 0
			local speed = 0
			local Offset = 0
			local Direction = 0
			
			if not deflect then
				Origin = Weapon.Barrel.Position;
				speed = Config.BulletSpeed.Value;
				Offset = Vector3.new(
					math.random(-100,100),
					math.random(-100,100),
					math.random(-100,100)
				)/100 * 0.05

				Offset *= math.floor(spread/40);
				Direction = (End - Origin).Unit;

				Direction += Offset;
			else
				Origin = Player.HumanoidRootPart.Position;
				speed = Config.BulletSpeed.Value * 0.1
				Offset = Vector3.new(
					math.random(-1,1),
					math.random(-1,1),
					math.random(0,0)
				)
				End += Offset
				Direction = (End - Origin).Unit;
				Direction += Offset
			end
			
			local Info = {
				Weapon = Weapon;
				Start = Origin;
				End = End;
				Direction = Direction;
				Player = Player;
				Speed = speed;
				Settings = Config;
				Deflect = deflect;
				Spread = spread;
				Mode = currentMode;
			}
			
			local RayParams = RaycastParams.new();
			if not deflect then
				RayParams.FilterDescendantsInstances = {Player.Character, workspace.Blasts}
			else
				RayParams.FilterDescendantsInstances = {Player, workspace.Blasts}
			end
			RayParams.FilterType = Enum.RaycastFilterType.Exclude;
			ProjRemote:FireAllClients(Info);
		end)()
	end
	if not deflect then
		Weapon.Info.Ammo.Value -= 1;
	end
end		
			
	
local function Hit(Player, ...)	
	local Weapon, End, spread, Config, deflect, Char, Result, Direction, Mode = ...;
	local saber = Char:FindFirstChild("Saber");
	if saber and not deflect and Mode ~= 1 then --and saber.Info.LiveSettings.Blocking.Value then
--|					
--|					
--|-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--|  					UnComment Rest of Condition In Production rn for Testing @Storm, @Prime													------------------------[]
--|-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--|
--|
		task.spawn(function()
			Blast(Char, Weapon, Player.Character.Head.Position, Direction, Config, true, Mode)
			
		end)
		

	elseif Mode == 0 or Mode == 2 then	
		task.spawn(function()
			local headMult
			if Config:FindFirstChild("HeadShotMult") then headMult = Config:FindFirstChild("HeadShotMult").Value else headMult = 1.5 end;
			if Result.Name == "Head" then
				Char.Humanoid:TakeDamage(Config.Damage.Value*headMult);
				if not deflect then
					CommsRemote:FireClient(Player, "HeadShot")
				end
			elseif string.match(Result.Name, "Arm") or string.match(Result.Name, "Leg")  then
				Char.Humanoid:TakeDamage(Config.Damage.Value*.75);
				if not deflect then
					CommsRemote:FireClient(Player, "Hit")
				end
			else
				Char.Humanoid:TakeDamage(Config.Damage.Value);
				if not deflect then
					CommsRemote:FireClient(Player, "Hit")
				end
			end
		end)
	elseif Mode == 1 then
		
		--Testing the Ragdoll?
		
		task.spawn(function()
			
			Char.Humanoid:TakeDamage(5);
			
			if Char.Humanoid.WalkSpeed ~= walkSpeedReduced then
				
				local Lightning = BlasterFolder.Effects.Projectiles.shockbullet.ParticleEmitter2:Clone()
				Lightning.Parent = Char.Torso
				
				Char.Humanoid.WalkSpeed = walkSpeedReduced
				
				local playerFromCharacter = game:GetService("Players"):GetPlayerFromCharacter(Char)
				
			
				
				for _, v in pairs(Char:GetDescendants()) do
					if v:IsA("Motor6D") then
						local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
						a0.CFrame = v.C0
						a1.CFrame = v.C1
						a0.Parent = v.Part0
						a1.Parent = v.Part1

						local b = Instance.new("RigidConstraint")
						b.Attachment0 = a0
						b.Attachment1 = a1
						b.Parent = v.Part0
						v.Enabled = false
					end
				end
				
				if playerFromCharacter then
					CommsRemote:FireClient(playerFromCharacter, "CamOff")
					task.wait(0.5)
					StunsRemote:FireClient(playerFromCharacter, "Disable")
				end
				
				Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
				Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

				Char:PivotTo(CFrame.new(Char.HumanoidRootPart.Position + Vector3.new(0, 0, 0)) * CFrame.Angles(math.rad(90), 0, 0))
				
				Char:SetAttribute("ID", HttpService:GenerateGUID(false))
			end
			
			if Stuns[Char:GetAttribute("ID")] then
				task.cancel(Stuns[Char:GetAttribute("ID")])
			end

			-- Start a new timer
			timer = task.delay(resetTime, function()
				
				local playerFromCharacter = game:GetService("Players"):GetPlayerFromCharacter(Char)
				
				if playerFromCharacter then
					CommsRemote:FireClient(playerFromCharacter, "CamOn")
					StunsRemote:FireClient(playerFromCharacter, "Enable")
				end
				
				Stuns[Char:GetAttribute("ID")] = nil
				
				for i, object in pairs(Char:GetDescendants()) do
					if object:IsA("RigidConstraint") then
						object:Destroy()
					end
				end
				
				Char.Humanoid.WalkSpeed = walkSpeedDefault
				
				Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				Char.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
				
				Char.Torso.ParticleEmitter2:Destroy()

				for i, joint in pairs(Char:GetDescendants()) do
					if joint:IsA('Motor6D') then
						joint.Enabled = true
					end
				end
				
			end)
			
			Stuns[Char:GetAttribute("ID")] = timer
		end)
	end
	
end

local function Reload(Player, Weapon)
	if Weapon:GetAttribute("Equipped") and Weapon.Info.Ammo.Value < Weapon.Info.Ammo.MaxValue then
		Weapon.Info.Ammo.Value += 1;
	end

end

local function Heal(Player, bool)
	
	if not bool then
		
		if Player.Character.L1:FindFirstChild("Weld") then
			Player.Character.L1:FindFirstChild("Weld"):Destroy()
		end
		
		if Player.Character:FindFirstChild("MedStick") then
			Player.Character.MedStick:Destroy()
		end
		
		return
	end
	
	local Char = Player.Character

	local Heal = BlasterFolder.OtherModels.MedStick:Clone()
	Heal.Parent = Player.Character;

	local WeldPoint = Char.L1; 
	local Eulers =  CFrame.fromEulerAnglesXYZ(-math.pi/-2,0.7,1.6) 
	makeJoint("Weld", WeldPoint,Heal,CFrame.new()*Eulers)
	
	local i = 0
	while i < 30 do
		i += 1
		task.wait(0.133)
		Char.Humanoid:TakeDamage(-1.33)
		if Char.Humanoid.Health >= 100 then
			Char.Humanoid.Health = 100
			break
		end
	end
end

local function Flashlight(Player, Bool : boolean)
	Player.Character.Head.FlashLight.Enabled = Bool;
end

local function Cloak(Player, bool)
	
	local Char = Player.Character
	
	if bool then
		for _, v in pairs(Char:GetDescendants()) do
			
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				
				if not dontTouch[v.Name] then
					v.Transparency = 0.95
				end
			end
		end
	else
		for _, v in pairs(Char:GetDescendants()) do
			
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				
				if not dontTouch[v.Name] then
					v.Transparency = 0
				end
			end
		end
	end
end


local CommandsToFunction = {
	["SetupServer"] = function(Player, Table)
		Setup(Player, Table);
	end,
	["Equip"] = function(Player, isEquip, Weapon)
		
		if isEquip then
			Player.DevEnableMouseLock = false
		else
			Player.DevEnableMouseLock = true
		end
		
		Equip(Player.Character, isEquip, Weapon);
	end,
	["Blast"] = function(Player, ...)
		Blast(Player, ...)
	end,
	["Reload"] = function(Player, Weapon)
		Reload(Player, Weapon)
	end,
	["Flashlight"] = function(Player, Bool, Weapon)
		Flashlight(Player, Bool, Weapon);
	end,
	["Destroy"] = function(Player)
		CommsRemote:FireClient(Player, "Destroy")
	end,
	["Heal"] = function(Player, bool)
		Heal(Player, bool)
	end,
	["Hit"] = function(Player, ...)
		Hit(Player, ...)
	end,
	["ActivateShiftLock"] = function(Player, ...)
		Player.DevEnableMouseLock = true
		StunsRemote:FireClient(Player, "Enable")
	end,
	["Cloak"] = function(Player, ...)
		Cloak(Player, ...)
	end,
}


CommsRemote.OnServerEvent:Connect(function(Player, Command, ...)
	CommandsToFunction[Command](Player, ...);
end)
