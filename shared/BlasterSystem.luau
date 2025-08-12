------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|																							|
------------------------------------------------------------------------------------------------------------------------------------------

local BlasterFolder = game:GetService("ReplicatedStorage").Blasters;
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
local module = {}

function module.Run(Table)
	print("Initialised")
	local Gun, Secondary = Table["Primary"], Table["Secondary"]
	local Player = game:GetService("Players").LocalPlayer
	local UIS = game:GetService("UserInputService");
	local Mouse = Player:GetMouse();
	local Camera = workspace.CurrentCamera;
	local SoundService = game:GetService("SoundService");
	local AnimationService = require(script.AnimationHandler);
	local CamService = require(script.CamService);
	local UI = require(script.UIService);
	local RunService = game:GetService("RunService");
	local Character = Player.Character;
	local SystemFolder = game:GetService("ReplicatedStorage").Blasters;
	local CommsRemote = SystemFolder.Remotes.CommsRemote;
	local CurrSelection = Gun;
	local Config = BlasterFolder.GunConfigs;
	local CurrSettings = Config[CurrSelection:GetAttribute("Name")];
	local Ammo = CurrSelection.Info.Ammo
	local Heals = 2
	local TweenService = game:GetService("TweenService");
	
	
	print("Running", Player)
	
	-----------------------------------------------------------
	local KeyW, KeyA, KeyS, KeyD = false, false, false, false;
	local isEquipped = false;
	local SystemTick = tick();
	local MouseLDown = false;
	local MouseRDown = false;
	local isFiring = false;
	local isReloading = false;
	--local forcedreload = false;
	local Debounce = false;
	local isCrouching = false;
	local isSprinting = false;
	local flashlight = false;
	local ReloadTick = tick();
	local dead = false
	local isSlow = false
	local isSwapping = false
	local zMIDX = 1
	local scopped = false
	local scopeFOV = 10
	local scopeMIN = 0
	local scopeMAX = 10
	local isHealing = false
	local isCloak = false
	local forceOff = false
	local Timer;
	local currentHealth = 100
	local cloakLock = false
	
	local currentMode = 0
	
	local ModeEnum = {
		[0] = "dmgMode";
		[1] = "stunMode";
		[2] = "cloakMode";
		[3] = "explosiveMode";
	}
	
	
	-----------------------------------------------------------
	AnimationService.LoadAnimations(CurrSelection:GetAttribute("Name"), CurrSelection.Name);
	
	-----------------------------------------------------------
	
	local function NewReload()
		if isReloading or not isEquipped or Ammo.Value >= Ammo.MaxValue or isFiring then return end;
		
		--print(CurrSelection:GetAttribute("forcedreload"))
		
		isReloading = true;
		if Ammo.Value <= 0 or CurrSelection:GetAttribute("forcedreload") then
			CurrSelection:SetAttribute("forcedreload", true)
			CurrSelection.Sounds.Overheat:Play();
			UI.CancelReload();
			task.spawn(function()
				UI.ForcedReload((CurrSettings.ReloadTime.Value+.1) * (Ammo.MaxValue - Ammo.Value), CurrSettings, CurrSelection);
			end)
			
		end
		
		if not CurrSelection:GetAttribute("forcedreload") then UI.NewReload((CurrSettings.ReloadTime.Value+.1) * (Ammo.MaxValue - Ammo.Value)) end;
		while Ammo.Value < Ammo.MaxValue and not isFiring and isEquipped do
			if isSwapping then break end;
			if isReloading and not CurrSelection:GetAttribute("forcedreload") and tick() - ReloadTick <= 1 then break end;
			--print(CurrSelection:GetAttribute("Name") .. " Not UI")
			task.wait(.1 + CurrSettings.ReloadTime.Value) 
			CommsRemote:FireServer("Reload", CurrSelection);

		end
		ReloadTick = tick();
		UI.CancelReload();
		if Ammo.Value == Ammo.MaxValue then
			CurrSelection:SetAttribute("forcedreload", false)
		end
		isReloading = false;
		 
		
	end
	
	local function AmmoHandler()
		UI.AmmoUdim(Ammo);
	end
	
	local AmmoConnection = Ammo:GetPropertyChangedSignal("Value"):Connect(AmmoHandler);
	
	local function ForceCloakToggle()

		--Add In Sound for Deactivate

		forceOff = true
		isCloak = false
		CommsRemote:FireServer("Cloak", isCloak)

		if Timer then
			task.cancel(Timer)
		end

		Timer = task.delay(4, function()
			forceOff = false
		end)

	end
	
	local function Equip()
		
		if Player.Character.Humanoid.WalkSpeed == 5 then return end;
		
		if isCrouching then Player.Character.Humanoid.WalkSpeed = 16; isCrouching = not isCrouching; end
		if isFiring or MouseRDown or MouseLDown then return end;
		
		if currentMode == 2 then
			ForceCloakToggle()
		end
		
		Player.Character.Humanoid.HipHeight = 0
		isSwapping = true
		
		UI.CancelReload();
		isEquipped = not isEquipped;
		AnimationService.Equip(isEquipped);
		CommsRemote:FireServer("Equip", isEquipped, CurrSelection);
		
		if isEquipped then CurrSelection.Sounds.Equip:Play() end;
		CamService.OTS(isEquipped)
		UI.UpdateNameData(CurrSelection, isEquipped, ModeEnum[currentMode]);
		
		if not CurrSelection:GetAttribute("forcedreload") then
			UI.TurnWhite()
		end
		
		isSwapping = false
		
	end
	
	local function Roll()
		
		if Player.Character.Humanoid.WalkSpeed < 16 then return end;
		
		if tick() - SystemTick >= 2 then
			SystemTick = tick();

			local DirectionMultiplication = if KeyW or KeyD then 60 elseif KeyS or KeyA then -60 else 60
			local Vector = if KeyW or KeyS then Character.HumanoidRootPart.CFrame.LookVector elseif KeyA or KeyD then Character.HumanoidRootPart.CFrame.RightVector else Character.HumanoidRootPart.CFrame.LookVector
			AnimationService.Roll(if KeyW then "W" elseif KeyS then "S" elseif KeyA then "A" elseif KeyD then "D" else "W");
			
			local Direction = Vector * DirectionMultiplication;
			
			local Torso = if Character.Humanoid.RigType == Enum.HumanoidRigType.R15 then Character.UpperTorso else Character.Torso;
			for i = 1, 25 do
				if Player.Character.Humanoid.WalkSpeed < 16 then return end;
				Player.Character.PrimaryPart.Velocity = Vector3.new(Direction.X, Torso.Velocity.Y, Direction.Z)
				RunService.RenderStepped:Wait()
			end
		end
	end
	
	
	local function Crouch()
		if Player.Character.Humanoid.WalkSpeed == 5 then return end;
		isCrouching = not isCrouching;
		CamService.Crouch();
		AnimationService.Crouch(isCrouching)
		Player.Character.Humanoid.WalkSpeed = if isCrouching then 10 else 16;
		Player.Character.Humanoid.HipHeight = if isCrouching then -1 else 0;

		if isCrouching then
			Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false);
		else
			Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true);
		end

	end
	
	local function SwapWeapon(WeaponWanted)
		
		if Player.Character.Humanoid.WalkSpeed == 5 then return end;
		
		if currentMode == 2 then
			ForceCloakToggle()
		end
		
		currentMode = 0
		
		if isFiring or MouseRDown or MouseLDown then return end;
		
		if isSwapping then return end
		
		isSwapping = true
		
		if MouseRDown or MouseLDown then return end
		
		if CurrSelection == WeaponWanted then
			isSwapping = false
			return
		end
		
		local wasEquipped = false;
		if isEquipped then
			wasEquipped = true;
			Equip(); 
		end;

		if CurrSelection ~= WeaponWanted and WeaponWanted ~= nil then 
			CurrSelection = WeaponWanted 
		else 
			CurrSelection = CurrSelection
		end
		CurrSettings = Config[CurrSelection:GetAttribute("Name")];
		Ammo = CurrSelection.Info.Ammo;
		UI.AmmoUdim(Ammo);
		--if CurrSelection:GetAttribute("forcedreload") then CurrSelection:SetAttribute("forcedreload", not CurrSelection:GetAttribute("forcedreload")) end;
		AmmoConnection:Disconnect()
		AmmoConnection = Ammo:GetPropertyChangedSignal("Value"):Connect(AmmoHandler);
		AnimationService.LoadAnimations(CurrSelection:GetAttribute("Name"), CurrSelection.Name);
		if wasEquipped then Equip() end;
		
		isSwapping = false
		
	end
	
	local function Shoot()
		if dead then return true end;
		if not isEquipped or not isFiring or Ammo.Value < 1 or CurrSelection:GetAttribute("forcedreload") then return true end;
		if currentMode == 2 then
			ForceCloakToggle()
		end
		AnimationService.Shoot(true);
		if not UI.GetIsHeatShowing() then UI.ShowHeat(true) end;
		UI.CancelReload();
		ReloadTick = tick()
		--Temporary Custom Shoot Sound
		if currentMode == 0 then
			CurrSelection.Sounds.Shoot:Play();
		elseif currentMode == 1 then
			CurrSelection.Sounds.Stun:Play();
		elseif currentMode == 2 then
			CurrSelection.Sounds.Shoot:Play();
		elseif currentMode == 3 then
			CurrSelection.Sounds.Shoot:Play();
		end

		CommsRemote:FireServer("Blast", CurrSelection, UI.ProvideRay(CurrSelection:GetAttribute("Sniper")), CamService.ProvideSpread() * CurrSettings.BulletSpread.Value * .1, CurrSettings, false, currentMode);
		CamService.ApplyShake(CurrSettings);
		task.wait(60/CurrSettings.FireRate.Value)
	end

	local function AutoFire()
		if Shoot() then
			isFiring = false;
		end
		if MouseLDown and isFiring then
			AutoFire()
		end
	end

	local function Burst() -- returns true if should break / stop trying to fire
		
		for i=1,CurrSettings.BurstAmount.Value do
			if Shoot() then
				return true
			end
		end
	end
	
	local function AutoBurst() -- Recursive function for auto burst
		if Burst() then
			isFiring = false
		end

		if MouseLDown and isFiring then
			AutoBurst()
		end
	end
	
	local function ShootHandler()
		--UI.CancelReload();
		--CurrSettings = Config[CurrSelection:GetAttribute("Name")]
		if CurrSelection:GetAttribute("forcedreload") then isFiring = false return end;
		if isFiring or not isEquipped then return end
		--if isReloading then isReloading = false return end;
		isFiring = true;
		if CurrSettings.FullAuto.Value and CurrSettings.Burst.Value then 
			AutoBurst()
		elseif CurrSettings.FullAuto.Value then
			AutoFire()
		elseif CurrSettings.Burst.Value then
			Burst()
			task.wait(CurrSettings.BurstDelay.Value)
		elseif CurrSettings.Single.Value then
			Shoot()
		end
		isFiring = false
	end
	
	local function Sprint(bool)
		if Player.Character.Humanoid.WalkSpeed < 16 then return end;
		if isCrouching then return end
		isSprinting = bool
		Player.Character.Humanoid.WalkSpeed = if isSprinting then 22 else 16;
	end
	
	local function Heal()
		CommsRemote:FireServer("Heal", true)
		AnimationService.Heal();
	end
	
	local function ScopeToggle()
		
		--Check if Sniper
		if CurrSelection:GetAttribute("Sniper") == false or CurrSelection:GetAttribute("Sniper") == nil then
			return
		end
		
		if not isReloading and MouseRDown then
			scopped = not scopped
			scopeFOV = 10
			--Possibly Switch somewhere Else RN Reset here
			CamService.Zoom(true, scopped, false)
		end
		
	end
	
	local function ChangeFOV(bool)
		
		if not scopped or not isEquipped or not MouseRDown then
			return
		end
		
		if bool then
			if scopeFOV > scopeMIN then
				scopeFOV -= 0.5
			end
		else
			if scopeFOV < scopeMAX then
				scopeFOV += 0.5
			end
		end
		
		
		local FOV = scopeFOV
		
		--print(FOV)
		
		local Info = if bool then TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) else TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In);
		local Tween = TweenService:Create(Camera, Info, {FieldOfView = FOV})
		Tween:Play()
	end
	
	local function SlowToggle(bool)

		--Check Reloading
		if not isReloading and MouseRDown and CurrSelection:GetAttribute("Sniper") then
			isSlow = bool
			CamService.Zoom(true, scopped, isSlow, scopeFOV)
		end

	end
	
	local function ToggleGunModes()
		
		if CurrSelection:GetAttribute("forcedreload") then return end
		
		while task.wait() do
			currentMode = (currentMode + 1) % 4
			if CurrSettings[tostring(ModeEnum[currentMode])].Value == true then
				
				if currentMode == 0 then
					CurrSettings = Config[CurrSelection:GetAttribute("Name")];
				elseif currentMode == 1 then
					CurrSettings = Config["StunGun"];
				elseif currentMode == 2 then
					print("CloackMode")
				elseif currentMode == 3 then
					print("Explosive?")
				end
				
				UI.UpdateNameData(CurrSelection, isEquipped, ModeEnum[currentMode]);
				break
			end
		end
	end
	
	local function CloakToggle()
		
		if currentMode == 2 and not forceOff then
			
			isCloak = not isCloak
			
			--Add In Sound for Activate and Deactivate
			
			CommsRemote:FireServer("Cloak", isCloak)
			
		end
	end
	
	local KeyToFunc = {
		
		[Enum.KeyCode.One] = function()
			SwapWeapon(Gun)
		end,
		[Enum.KeyCode.Two] = function()
			SwapWeapon(Secondary)
		end,
		
		[Enum.KeyCode.Q] = function()
			if isSwapping then return end;
			Equip();
		end,
		
		[Enum.KeyCode.LeftControl] = function()
			Roll();
		end,
		
		[Enum.KeyCode.E] = function()
			CamService.SwapShoulders();
		end,
		[Enum.KeyCode.V] = function()
			if not isEquipped then return end
			flashlight = not flashlight
			CommsRemote:FireServer("Flashlight", flashlight, CurrSelection);
		end,
		[Enum.KeyCode.C] = function()
			if not isEquipped then return end
			Crouch()
		end,
		[Enum.KeyCode.R] = function()
			--NewReload()
			-- changing this to 'Scope Toggle'
			ScopeToggle();
		end,
		[Enum.KeyCode.T] = function()
			if Player.Character.Humanoid.WalkSpeed == 5 then return end;
			if forceOff then return end;
			
			if cloakLock then return end;
			
			cloakLock = true;
			task.delay(2, function()
				cloakLock = false;
			end)
			
			CloakToggle();
		end,
		[Enum.KeyCode.LeftShift] = function()
			Sprint(true)
		end,
		[Enum.KeyCode.X] = function()
			if Player.Character.Humanoid.WalkSpeed == 5 then return end;
			
			if isHealing then return end
			
			isHealing = true
			
			task.delay(3.5, function()
				isHealing = false
			end)
			
			Heals -= 1
			if Heals >= 0 then
				Heal()
			end
		end,
		
		[Enum.KeyCode.W] = function()
			KeyW = true
		end,
		[Enum.KeyCode.A] = function ()
			KeyA = true;
		end,
		[Enum.KeyCode.S] = function()
			KeyS = true
		end,
		[Enum.KeyCode.D] = function ()
			KeyD = true;
		end,
		[Enum.KeyCode.Z] = function ()
			SlowToggle(true)
		end,
		[Enum.KeyCode.F] = function ()
			if currentMode == 2 then
				ForceCloakToggle()
			end
			ToggleGunModes()
		end,
	}
	
	local EndToFunc = {
		[Enum.KeyCode.W] = function()
			KeyW = false
		end,
		[Enum.KeyCode.A] = function ()
			KeyA = false;
		end,
		[Enum.KeyCode.S] = function()
			KeyS = false
		end,
		[Enum.KeyCode.D] = function ()
			KeyD = false;
		end,
		[Enum.KeyCode.LeftShift] = function()
			Sprint(false)
		end,
		[Enum.KeyCode.Z] = function ()
			SlowToggle(false)
		end,
	}
	
	local keyInput
	local keyEndput
	local mouse1Down
	local mouse1Up
	local mouse2Down
	local mouse2Up
	local scrollWheel
	local Comms
	
	
	keyInput = UIS.InputBegan:Connect(function(Input, gameP)
		if gameP then return end;
				
		if KeyToFunc[Input.KeyCode] then
			KeyToFunc[Input.KeyCode]();
		end
	end)
	
	keyEndput = UIS.InputEnded:Connect(function(Input, gameP)
		if gameP then return end;
		if EndToFunc[Input.KeyCode] then 
			EndToFunc[Input.KeyCode]();
		end
	end)
	
	mouse1Down = Mouse.Button1Down:Connect(function()
		
		if Player.Character.Humanoid.WalkSpeed == 5 then return end;
		
		if isSwapping then return end;
		
		if not isEquipped then return end;
		MouseLDown = true;
		if isFiring then return end;
		if not Debounce then
			Debounce = true;
			ShootHandler();
			--wait(.05);
			Debounce = false;
		end

	end)

	mouse1Up = Mouse.Button1Up:Connect(function()
		if not isEquipped then return end;
		if not MouseRDown then 
			--AnimationService.Shoot(false)
			task.delay(4, function()
				if not MouseLDown then AnimationService.Shoot(false, isEquipped) end
			end)
			--AnimationService.Aim(false)	
		end
		MouseLDown = false;
		isFiring = false;
	end)
	
	mouse2Down = Mouse.Button2Down:Connect(function()
		
		if Player.Character.Humanoid.WalkSpeed == 5 then return end;
		
		if isSwapping then return end;
		
		if not isEquipped then return end;
		MouseRDown = true
		if CurrSelection.Name == "Secondary" then
			for _, v in pairs(Player.Character:FindFirstChild("Primary"):GetDescendants()) do

				if v:IsA("BasePart") or v:IsA("MeshPart") then

					if not dontTouch[v.Name] then
						v.Transparency = 0.9
					end
				end
			end
		end
		AnimationService.Aim(true, isEquipped)
		if CurrSelection:GetAttribute("Sniper") then
			CamService.Zoom(true, scopped)
			ChangeFOV(false)
		else
			CamService.Zoom(true)
		end
	end)
	
	mouse2Up = Mouse.Button2Up:Connect(function()
		if not isEquipped then return end;
		if CurrSelection.Name == "Secondary" then
			for _, v in pairs(Player.Character:FindFirstChild("Primary"):GetDescendants()) do

				if v:IsA("BasePart") or v:IsA("MeshPart") then

					if not dontTouch[v.Name] then
						v.Transparency = 0
					end
				end
			end
		end
		MouseRDown = false
		isSlow = false
		CamService.Zoom(false, false, false)
		AnimationService.Aim(false, isEquipped)
	end)
	
	scrollWheel = UIS.InputChanged:Connect(function(input, processed)
		if processed or input.UserInputType ~= Enum.UserInputType.MouseWheel then
			return
		end
		
		if CurrSelection:GetAttribute("Sniper") then
			local bool = input.Position.Z >= 0
			ChangeFOV(bool)
		else
			return
		end
		
	end)
	
	Comms = CommsRemote.OnClientEvent:Connect(function(Command, ...)
		--if Command == "Projectile" then
		--	local Info = ...;
		--	ProjectileSystem.Cast(Info);
		if Command == "Hit" then
			--SoundService:PlayLocalSound(CurrSelected.Sounds.Hitmarker);
			CurrSelection.Sounds.Hitmarker:Play()
			UI.HitMarker();
		end
		
		if Command == "HeadShot" then
			CurrSelection.Sounds.Hitmarker:Play()
			UI.HitMarker(true);
		end
		
		if Command == "CamOff" then
			CamService.OTS(false)
		end
		
		if Command == "CamOn" then
			if isEquipped then
				CamService.OTS(true)
			end
		end
		
		if Command == "Destroy" then
			
			CommsRemote:FireServer("ActivateShiftLock")
			
			keyInput:Disconnect()
			keyEndput:Disconnect()
			mouse1Down:Disconnect()
			mouse1Up:Disconnect()
			mouse2Down:Disconnect()
			mouse2Up:Disconnect()
			Comms:Disconnect()
			scrollWheel:Disconnect()
			
			if isEquipped then
				UI.UpdateNameData(CurrSelection, false, ModeEnum[currentMode]);
				CamService.OTS(false);
			end
			script:Destroy();
		end
	end)
	
	Player.Character.Humanoid.Died:Connect(function()
		
		CommsRemote:FireServer("ActivateShiftLock")
		
		dead = true
		keyInput:Disconnect()
		keyEndput:Disconnect()
		mouse1Down:Disconnect()
		mouse1Up:Disconnect()
		mouse2Down:Disconnect()
		mouse2Up:Disconnect()
		Comms:Disconnect()
		scrollWheel:Disconnect()
		
		if isEquipped then
			UI.UpdateNameData(CurrSelection, false, ModeEnum[currentMode]);
			CamService.OTS(false);
		end
		script:Destroy();
		return module;
	end)
	
	Player.Character.Humanoid.HealthChanged:Connect(function()
		
		if currentHealth > Player.Character.Humanoid.Health then
			if currentMode == 2 then
				ForceCloakToggle()
			end
		end
		
		currentHealth = Player.Character.Humanoid.Health
	end)
	
	task.spawn(function()
		while task.wait(.5) do
			
			if isSwapping then
				--print("Skipped")
				continue
			end
			
			if tick() - ReloadTick >= 1 and Ammo.Value < Ammo.MaxValue and not isFiring and isEquipped then
				--print("Called No Force Set")
				NewReload();
			end
			if (Ammo.Value == 0 and not isFiring and isEquipped) or CurrSelection:GetAttribute("forcedreload") then
				--print("Called Force Set")
				CurrSelection:SetAttribute("forcedreload", true)
				NewReload();
			end
		end
	end)
	
end

return module
