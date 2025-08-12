------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|

local System = game:GetService("ReplicatedStorage").Blasters;
local Effects = System.Effects
local Debris = game:GetService("Debris");
local RunService = game:GetService("RunService");
local ProjectileRemote = System.Remotes.ProjectileRemote;
local ServerRemote = System.Remotes.CommsRemote
local Player = game:GetService("Players").LocalPlayer

function accToBody(enum, char) 
	if enum.Value > 0 and enum.Value < 5 then
		return char.Head
	else
		return char.Torso
	end
end

function recFindChar(char)
	
	if char.Parent == workspace or char:FindFirstChild("Humanoid") or char == workspace then
		return char
	else
		char = recFindChar(char.Parent)
		return char
	end
end

ProjectileRemote.OnClientEvent:Connect(function(Info)
	--Weapon, End, spread, Config, deflect, Result, Direction
	--[[
	local Info = 
		{
		Weapon = Weapon;
		Start = Origin;
		End = End;
		Direction = Direction;
		Player = Player;
		Speed = speed;
		Settings = Config;
		Deflect = deflect;
		Spread = spread
		Mode = currentMode;
		}
		
	
	local ModeEnum = {
		[0] = "dmgMode";
		[1] = "stunMode";
		[2] = "cloakMode";
		[3] = "explosiveMode";
	}
	]]
	--Info.Weapon.Sounds.Shoot:Play();
	local RayParams = RaycastParams.new();
	
	if not Info.Deflect then
		RayParams.FilterDescendantsInstances = {workspace.Blasts, Info.Weapon.Parent, Info.Player};
	else
		RayParams.FilterDescendantsInstances = {workspace.Blasts, Info.Player};
	end
	RayParams.FilterType = Enum.RaycastFilterType.Exclude;
	
	if not Info.Deflect then
		Info.Weapon.Barrel.one.Enabled = true;
		Info.Weapon.Barrel.two.Enabled = true;
		Info.Weapon.Barrel.three.Enabled = true;
		Info.Weapon.Barrel.four.Enabled = true;
		Info.Weapon.Barrel.PointLight.Enabled = true;
		Info.Weapon.Barrel.Sparks2.Enabled = true;
		
		task.spawn(function()
			task.wait(.2)
			Info.Weapon.Barrel.one.Enabled = false;
			Info.Weapon.Barrel.two.Enabled = false;
			Info.Weapon.Barrel.three.Enabled = false;
			Info.Weapon.Barrel.four.Enabled = false;
			Info.Weapon.Barrel.PointLight.Enabled = false;
			Info.Weapon.Barrel.Sparks2.Enabled = false;
		end)
	end
	
	local bullet;
	
	if Info.Weapon:GetAttribute("Sniper") then
		bullet = Effects.Projectiles.sniperbullet:Clone();
	elseif Info.Mode == 1 then
		bullet = Effects.Projectiles.shockbullet:Clone();
	elseif Info.Mode == 0 then
		bullet = Effects.Projectiles.bullet:Clone();
	elseif Info.Mode == 2 then
		bullet = Effects.Projectiles.bullet:Clone();
	end
	
	bullet.Parent = workspace.Blasts;
	bullet.Sound:Play();
	bullet.PointLight.Enabled = true;
	
	local latency = 0
	local range = 0
	local speed = Info.Speed
	
	
	if Info.Deflect then 
		range = Info.Settings.BulletRange.Value * 0.5
		bullet.CFrame = CFrame.new(Info.Start, Info.End) * CFrame.new(0,0,-3);
	else
		range = Info.Settings.BulletRange.Value
		bullet.CFrame = CFrame.new(Info.Weapon.Barrel.Position, Info.End) --* CFrame.new(0,0,-3);
	end
	
	task.spawn(function()
		local state = false
		while (bullet.CFrame.Position - Info.Start).Magnitude < range and not state do
			latency = RunService.RenderStepped:Wait()
			bullet.CFrame = bullet.CFrame *CFrame.new(0,0,-latency*speed)
			local result = workspace:Raycast(Info.Start, Info.Direction*(Info.Start - bullet.Position).Magnitude, RayParams)
			
			if result then
				state = true
				
				local Hit;
				
				if Info.Weapon:GetAttribute("Sniper") then
					Hit = Effects["Hit Effects"].hit:Clone();
				elseif Info.Mode == 1 then
					Hit = Effects["Hit Effects"].shockhit:Clone();
				elseif Info.Mode == 0 then
					Hit = Effects["Hit Effects"].hit:Clone();
				elseif Info.Mode == 2 then
					Hit = Effects["Hit Effects"].hit:Clone();
				end
				
				Hit.Parent = workspace.Blasts;
				Hit.CFrame = CFrame.new(result.Position, result.Position+result.Normal);
				if Info.Mode == 1 then
					Hit.ShockSparks:Emit(10)
					Hit.Flash:Emit(.9)
					Hit.Sparks:Emit(30)
					Hit.Explosion:Emit(15)
				else
					Hit.Smoke:Emit(10)
					Hit.Flash:Emit(.9)
					Hit.Sparks:Emit(30)
					Hit.Explosion:Emit(15)
				end
				Hit.Sound:Play()				
				Debris:AddItem(Hit,5);
				for _,v in next,Hit:GetChildren()do
					if v:IsA('ParticleEmitter') or v:IsA('PointLight') then
						v.Enabled = true
					end
				end
				task.spawn(function()
					task.wait(.1);
					for _,v in next,Hit:GetChildren()do 
						if v:IsA('ParticleEmitter') or v:IsA('PointLight') then
							v.Enabled = false
						end
					end 
				end)
				
				if Info.Player == Player then
					
					local Char = recFindChar(result.Instance:FindFirstAncestorWhichIsA("Model"));
					if Char and Char:FindFirstChild("Humanoid") then
						
						
						if result.Instance.Parent:IsA("Accessory") then
							result = accToBody(result.Instance.Parent.AccessoryType, Char)
						elseif result.Instance:IsA("MeshPart") or result.Instance.Name == "Middle" then
							result = result.Instance:FindFirstAncestorWhichIsA("Model")
						else
							result = result.Instance
						end
						ServerRemote:FireServer("Hit", Info.Weapon, Info.End, Info.spread, Info.Settings, Info.Deflect, Char, result, Info.Direction, Info.Mode)
					end	
				elseif Info.Deflect then
					print(result.Instance.Name)
					local Char = recFindChar(result.Instance:FindFirstAncestorWhichIsA("Model"));
					if Char and Char:FindFirstChild("Humanoid") then


						if result.Instance.Parent:IsA("Accessory") then
							result = accToBody(result.Instance.Parent.AccessoryType, Char)
						elseif result.Instance:IsA("MeshPart") or result.Instance.Name == "Middle" then
							result = result.Instance:FindFirstAncestorWhichIsA("Model")
						else
							result = result.Instance
						end
						
						print(Char.Name)
						
						if Player.Character.Name == Char.Name then
							ServerRemote:FireServer("Hit", Info.Weapon, Info.End, Info.spread, Info.Settings, Info.Deflect, Char, result, Info.Direction, Info.Mode)
						end
					end	
					
					
				end
			end
		end
		bullet:Destroy();
	end)
	--bullet.CFrame = CFrame.new(bullet.Position, bullet.Position + Info.Direction);
	--bullet.Trail.Color = ColorSequence.new(Info.Weapon.Info.Color.Value);
	--bullet.Trail.Lifetime = Info.Weapon.Info.BulletSpeed.Value / 100;
	--Debris:AddItem(bullet, Info.Weapon.Info.BulletSpeed.Value / 100);
	
	
end)
