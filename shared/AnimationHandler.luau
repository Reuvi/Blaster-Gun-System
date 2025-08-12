------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|
-----------------------------------------------------------------------

local module = {}

local SystemFolder = game:GetService("ReplicatedStorage").Blasters;
local CommsRemote = SystemFolder.Remotes.CommsRemote;
local AnimsFolder = game:GetService("ReplicatedStorage").Blasters.Animations;
local Player = game:GetService("Players").LocalPlayer;
local Character, Humanoid, WeaponAnimationsFolder = nil, nil, nil
local AimAnimation, EquipAnimation, UnEquipAnimation, IdleAnimation, ForwardRollAnimation, BackwardRollAnimation, LeftRollAnimation, RightRollAnimation = nil, nil, nil, nil, nil, nil, nil, nil;
local lock = false

function module.LoadAnimations(GunName : string, Type : string)

	Character = Player.Character
	Humanoid = Character:FindFirstChildOfClass("Humanoid");
	
	if Type == "Primary" then
		if AnimsFolder:FindFirstChild(GunName) then WeaponAnimationsFolder = AnimsFolder:FindFirstChild(GunName) else WeaponAnimationsFolder = AnimsFolder:FindFirstChild("DefaultPrimary") end;
	else
		if AnimsFolder:FindFirstChild(GunName) then WeaponAnimationsFolder = AnimsFolder:FindFirstChild(GunName) else WeaponAnimationsFolder = AnimsFolder:FindFirstChild("DefaultSecondary") end;
	end
	AimAnimation =  Humanoid.Animator:LoadAnimation(WeaponAnimationsFolder.Aim);
	ShootAnimation =  Humanoid.Animator:LoadAnimation(WeaponAnimationsFolder.Aim);
	EquipAnimation = Humanoid.Animator:LoadAnimation(WeaponAnimationsFolder.Equip);
	UnEquipAnimation = Humanoid.Animator:LoadAnimation(WeaponAnimationsFolder.Unequip);
	IdleAnimation = Humanoid.Animator:LoadAnimation(WeaponAnimationsFolder.Idle);
	
	local RollFolder = if Humanoid.RigType == Enum.HumanoidRigType.R15 then AnimsFolder.Roll.R15 else AnimsFolder.Roll.R6
	local HealFolder = AnimsFolder.HealingAnims
	
	ForwardRollAnimation = Humanoid.Animator:LoadAnimation(RollFolder.DashFront);
	BackwardRollAnimation = Humanoid.Animator:LoadAnimation(RollFolder.DashBack);
	LeftRollAnimation = Humanoid.Animator:LoadAnimation(RollFolder.DashLeft);
	RightRollAnimation = Humanoid.Animator:LoadAnimation(RollFolder.DashRight);
	CrouchAnimation = Humanoid.Animator:LoadAnimation(WeaponAnimationsFolder.CrouchAim);
	HealAnimation = Humanoid.Animator:LoadAnimation(HealFolder.Healing1);
end

function module.Equip(bool : boolean)
	if IdleAnimation.IsPlaying then IdleAnimation:Stop() end
	if ShootAnimation.IsPlaying then ShootAnimation:Stop() end
	if AimAnimation.IsPlaying then AimAnimation:Stop() end
	if CrouchAnimation.IsPlaying then CrouchAnimation:Stop() end
	if bool then
		EquipAnimation:Play()
		EquipAnimation:AdjustSpeed(1.6)
		EquipAnimation.Stopped:Wait()
	else
		UnEquipAnimation:Play()
		UnEquipAnimation:AdjustSpeed(1.8)
		UnEquipAnimation.Stopped:Wait()
	end
	--if bool then IdleAnimation:Play() end
	
	module.Idle(bool)
end

function module.CancelAllAnims()
	if AimAnimation.IsPlaying then AimAnimation:Stop() end
	if IdleAnimation.IsPlaying then IdleAnimation:Stop() end
	if EquipAnimation.IsPlaying then EquipAnimation:Stop() end
	if UnEquipAnimation.IsPlaying then UnEquipAnimation:Stop() end
	if ShootAnimation.IsPlaying then ShootAnimation:Stop() end
	if HealAnimation.IsPlaying then HealAnimation:Stop() end

end

function module.Idle(bool)
	if ShootAnimation.IsPlaying then ShootAnimation:Stop() end
	if AimAnimation.IsPlaying then AimAnimation:Stop() end
	if CrouchAnimation.IsPlaying then CrouchAnimation:Stop() end
	if bool then IdleAnimation:Play() else IdleAnimation:Stop() end
end

function module.Heal()
	task.wait(0.2)
	if IdleAnimation.IsPlaying then IdleAnimation:Stop() end
	if ShootAnimation.IsPlaying then ShootAnimation:Stop() end
	if AimAnimation.IsPlaying then AimAnimation:Stop() end
	if CrouchAnimation.IsPlaying then CrouchAnimation:Stop() end
	HealAnimation:Play()
	HealAnimation.Stopped:Wait()
	CommsRemote:FireServer("Heal", false)
end

function module.Roll(Direction : string)
	local DirectionToRoll = {
		["W"] = ForwardRollAnimation,
		["A"] = LeftRollAnimation,
		["S"] = BackwardRollAnimation;
		["D"] = RightRollAnimation;
	}
	DirectionToRoll[Direction]:Play()
end

function module.Shoot(bool : boolean, isEquip: boolean)
	if IdleAnimation.IsPlaying then IdleAnimation:Stop() end
	if ShootAnimation.IsPlaying then ShootAnimation:Stop() end
	if AimAnimation.IsPlaying then AimAnimation:Stop() end
	if bool then ShootAnimation:Play() end
	if not bool and isEquip then IdleAnimation:Play() end
end


function module.Aim(bool : boolean, isEquip: boolean)
	if IdleAnimation.IsPlaying then IdleAnimation:Stop() end
	if ShootAnimation.IsPlaying then ShootAnimation:Stop() end
	if AimAnimation.IsPlaying then AimAnimation:Stop() end
	if bool then AimAnimation:Play() end
	if not bool and isEquip then ShootAnimation:Stop(); IdleAnimation:Play() end
end

function module.Crouch(bool : boolean)
	if IdleAnimation.IsPlaying then IdleAnimation:Stop() end
	if ShootAnimation.IsPlaying then ShootAnimation:Stop() end
	if AimAnimation.IsPlaying then AimAnimation:Stop() end
	if CrouchAnimation.IsPlaying then CrouchAnimation:Stop() end
	if bool then CrouchAnimation:Play() end
	if not bool then IdleAnimation:Play();  end
end

return module
