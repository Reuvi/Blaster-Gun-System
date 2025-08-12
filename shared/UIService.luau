------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|																					|
------------------------------------------------------------------------------------------------------------------------------------------

local module = {}

local Player = game:GetService("Players").LocalPlayer;
local UI = Player.PlayerGui:WaitForChild("BlasterUI");
local sniper = UI.Scope
local Crosshair = UI.Crosshair.NewCrosshair;
--local DynamicCrosshair = require(script.Parent.DynamicCrosshair).New(UI,120,5,3);
local RunService = game:GetService("RunService");
local isReloading = false;
local Mouse = Player:GetMouse();
local TweenService = game:GetService("TweenService");
local forceReload = false;
local ReloadTween, ForcedReloadTween;

--RunService.RenderStepped:Connect(function(dt)
--	DynamicCrosshair:Update(dt);
--end)

module.Test = Crosshair.Square

function UIVisible(bool : boolean)
	--Crosshair.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)
	Crosshair.Square.Visible = false;
	Crosshair.Triangles.Bottom.Visible = bool;
	Crosshair.Triangles.Top.Visible = bool;
	Crosshair.Triangles.Left.Visible = bool;
	Crosshair.Triangles.Right.Visible = bool;
end

function module.UpdateNameData(Gun, Bool, mode)
	local LabelFrame = UI:WaitForChild("LabelFrame");
	LabelFrame.Visible = Bool;
	LabelFrame.Type.Text = Gun.Name;
	LabelFrame.GunName.Text = Gun:GetAttribute("Name");
	LabelFrame.Mode.Text = mode -- this is the text output for the mode.
	local Info = Gun:WaitForChild("Info");
	--LabelFrame.MaxAmmo.Text = Gun.Info.Ammo.MaxValue
	--LabelFrame.CurrAmmo.Text = Gun.Info.Ammo.Value
	local Heat = UI:WaitForChild("Heat");
	
	Heat.Visible = Bool
	
	if not mode then
		UIVisible(Bool);
	end

	
end

function module.PlayHitmarker()
	
end

function module.HitMarker(bool)
	local Hitmarker = UI.Crosshair.Hitmarker;
	local HeadShot = UI.Crosshair.HeadShot
	if bool then
		task.spawn(function()
			HeadShot.Visible = true;
			wait(.1);
			HeadShot.Visible = false;
		end)
	else
		task.spawn(function()
			Hitmarker.Visible = true;
			wait(.1);
			Hitmarker.Visible = false;
		end)
	end
end

function module.CancelReload()
	if ReloadTween then ReloadTween:Pause(); ReloadTween:Cancel(); ReloadTween = nil; end;
	if ForcedReloadTween then ForcedReloadTween:Pause(); ForcedReloadTween:Cancel(); ForcedReloadTween = nil end;
	forceReload = false;
	isReloading = false;
end

function module.GetIsHeatShowing()
	local Heat = UI:WaitForChild("Heat");
	
	return Heat.Visible;
end

function module.ShowHeat(Bool)
	local Heat = UI:WaitForChild("Heat");
	Heat.Visible = Bool;
end

function module.TurnWhite()
	local Heat = UI:WaitForChild("Heat");
	Heat.BarFrame.Heat.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
end

function module.TurnRed()
	local Heat = UI:WaitForChild("Heat");
	Heat.BarFrame.Heat.BackgroundColor3 = Color3.fromRGB(255, 62, 65);
end

function module.ForcedReload(Seconds, CurrSettings, CurrSelection)
	
	
	if ForcedReloadTween then
		--forceReload = false
		ForcedReloadTween:Cancel()
		task.wait()
	end
	
	UI.Heat.BarFrame.Heat.BackgroundColor3 = Color3.fromRGB(255, 62, 65);
--	print(CurrSelection:GetAttribute("Name") .. "UI")
	--print(CurrSettings.Name .. "UI")
	--print(Seconds)
	--print((CurrSettings.ReloadTime.Value+.1) * (CurrSelection.Info.Ammo.MaxValue - CurrSelection.Info.Ammo.Value))
	ForcedReloadTween = TweenService:Create(UI.Heat.BarFrame.Heat,TweenInfo.new((CurrSettings.ReloadTime.Value+.1) * (CurrSelection.Info.Ammo.MaxValue - CurrSelection.Info.Ammo.Value), Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.fromScale(0,1)})
	ForcedReloadTween:Play();
	forceReload = true;
	task.spawn(function()
		ForcedReloadTween.Completed:Wait()
		--print("Turning White After Tween Cancelled")
		forceReload = false;
		UI.Heat.BarFrame.Heat.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	end)
	
end

function module.NewReload(Seconds)
	if forceReload then return end
	isReloading = true;
	ReloadTween = TweenService:Create(UI.Heat.BarFrame.Heat, TweenInfo.new(Seconds, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.fromScale(0,1)})
	ReloadTween:Play();
	task.spawn(function()
		ReloadTween.Completed:Wait()
		isReloading = false;
	end)
end

function module.AmmoUdim(Ammo)
	local Heat = UI.Heat;
	local SizeCAlc = (Ammo.MaxValue - Ammo.Value)/Ammo.MaxValue
	if not forceReload and not isReloading then
		Heat.BarFrame.Heat:TweenSize(UDim2.new(SizeCAlc,0,1,0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, .2);
	end
	--UI.LabelFrame.CurrAmmo.Text = Ammo.Value
end


function module.ProvideRay(sniper)
	--return DynamicCrosshair:Raycast()
	return Mouse.Hit.Position
end

function module.Scope(bool)
	Crosshair.Square.Visible = not bool;
	Crosshair.Triangles.Bottom.Visible = not bool;
	Crosshair.Triangles.Top.Visible = not bool;
	Crosshair.Triangles.Left.Visible = not bool;
	Crosshair.Triangles.Right.Visible = not bool;
	sniper.Visible = bool
end

function module.Return()
	return module;
end


return module
