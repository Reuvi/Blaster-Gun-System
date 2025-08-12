------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|																						|
------------------------------------------------------------------------------------------------------------------------------------------

local module = {}
local Player = game:GetService("Players").LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera;
local UIService = require(script.Parent.UIService);
local UI = Player.PlayerGui:FindFirstChild("BlasterUI");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local OGCFrame = Camera.CFrame;
local ContextActionService = game:GetService("ContextActionService");
local TweenService = game:GetService("TweenService");
local Mouse = Player:GetMouse();
local tweening = false;
local isZoomed = false;
local camOffset = Vector3.new(2, 2, 8);
local isOvershoulder = false;
local isRight = true;
local isProning = false;
local isCrouching = false;
local lastShakeTime = 0
local currentRecoilValue = nil
local mainTriangleTween;
local UITweenRotation;
--[[
local zoomMultiplyer = 
	{
	[1] = 15;
	[2] = 5;
	[3] = 0;
	}
	
--]]
function module.ProvideSpread()
	return Camera.FieldOfView;
end

function module.Zoom(bool, sniper, Slow, slowedFOV)
	
	if UITweenRotation then
		UITweenRotation:Cancel()
	end
	
	if mainTriangleTween then
		mainTriangleTween:Cancel()
	end
	
	local Humanoid = Player.Character:FindFirstChild("Humanoid");
	local Root = Humanoid.RootPart;
	
	isZoomed = bool;
	local Info = if bool then TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) else TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.In);
	
	local FOV = 0
	
	UIService.Scope(false)
	if sniper then
		
		if bool then
			UIService.Scope(true)
			if slowedFOV then FOV = slowedFOV else FOV = 10 end;
		else
			UIService.Scope(false)
			FOV = 70;
		end
	else
		UIService.Scope(false)
		if bool and isCrouching then 
			FOV = 35; 
		elseif bool then 
			FOV = 55;	
		else 
			FOV = 70;
		end
	end
	
	local Tween = TweenService:Create(Camera, Info, {FieldOfView = FOV})
	local rotation = if bool then 45 else 0
	--UserInputService.MouseDeltaSensitivity = if bool then .2 elseif isOvershoulder then .5 else 1; -- Original Line that handled it- commented out.
	-- Alright, this slows the camera sens when you scope in to a nice amount, makes it usable at distance. -JDL
	
	UserInputService.MouseDeltaSensitivity = if bool and Slow then 0.005 * (slowedFOV + 1) elseif bool then .2 elseif isOvershoulder then .5 else 1
	--print(UserInputService.MouseDeltaSensitivity)
	--[[
	if sniper and isOvershoulder then
		UserInputService.MouseDeltaSensitivity = .025;
	elseif isOvershoulder then
		UserInputService.MouseDeltaSensitivity = .3;
	else
		UserInputService.MouseDeltaSensitivity = 1;
	end
	--]]
	Tween:Play();
	
	
	
	
	UI.Crosshair.NewCrosshair.Triangles.Visible = true;
	UI.Crosshair.NewCrosshair.Square.Visible = false;
	
	
	UITweenRotation = TweenService:Create(UI.Crosshair.NewCrosshair.Triangles, Info, {Rotation = rotation})
	
	
	local udim = if bool then UDim2.new(0,4,0,4) else UDim2.new(0,100,0,100);
	local triangleudimSide = if bool then UDim2.fromOffset(4,4) else UDim2.fromOffset(2,15);
	local triangleudimTop = if bool then UDim2.fromOffset(4,4) else UDim2.fromOffset(15,2);
	mainTriangleTween = TweenService:Create(UI.Crosshair.NewCrosshair.Triangles, Info, {Size = udim});
	UITweenRotation:Play()
	mainTriangleTween:Play()
	
	UI.Crosshair.NewCrosshair.Triangles.Bottom:TweenSize(triangleudimTop, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
	UI.Crosshair.NewCrosshair.Triangles.Left:TweenSize(triangleudimSide, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
	UI.Crosshair.NewCrosshair.Triangles.Top:TweenSize(triangleudimTop, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
	UI.Crosshair.NewCrosshair.Triangles.Right:TweenSize(triangleudimSide, Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
	
	
	mainTriangleTween.Completed:Wait();
	
	
	if bool then
		UI.Crosshair.NewCrosshair.Triangles.Visible = false;
		UI.Crosshair.NewCrosshair.Square.Visible = true;
	end
	
	if not bool then
		UI.Crosshair.NewCrosshair.Triangles.Visible = true;
		UI.Crosshair.NewCrosshair.Square.Visible = false;
		UI.Crosshair.NewCrosshair.Triangles.Bottom:TweenSize(UDim2.fromOffset(15,2), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
		UI.Crosshair.NewCrosshair.Triangles.Left:TweenSize( UDim2.fromOffset(2,15), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
		UI.Crosshair.NewCrosshair.Triangles.Top:TweenSize(UDim2.fromOffset(15,2), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
		UI.Crosshair.NewCrosshair.Triangles.Right:TweenSize( UDim2.fromOffset(2,15), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad,.2, false);
	end
	
	--UIService.UpdateCrosshair(bool);
	
	--UI Small = 45 Rotation, Size 8,8 Offset
	--UI Big = 0 Rotation, Size

end

function module.OTS(bool)
	
	
	isOvershoulder = bool;
	local Humanoid = Player.Character:FindFirstChild("Humanoid");
	local Barrel = Humanoid.Parent.Primary.Barrel
	local Root = Humanoid.RootPart;
	--Camera.CameraSubject = Barrel
	
	Player.CameraMaxZoomDistance = if bool then 8 else 150;
	Player.CameraMinZoomDistance = if bool then 6 else 5;
	Humanoid.AutoRotate = not bool --Disable the automatic rotation since we are the ones setting it.
	--Vector3.new(1.45,0,-11)
	local Offset = if bool and isRight then Vector3.new(2,1.5,2) elseif bool and not isRight then Vector3.new(-2,1.5,2) else Vector3.new(0,0,0);-- I assume this is about the right camera offset.
	local TInfo = TweenInfo.new(.25,Enum.EasingStyle.Linear, Enum.EasingDirection.In);
	local Tween = TweenService:Create(Humanoid, TInfo, {CameraOffset = Offset})
	
	Tween:Play()
	
	UserInputService.MouseDeltaSensitivity = if bool then .5 else 1;
	
	Tween.Completed:wait();
	
	 -- Allow mouse to move freely.
	
	if bool then
		
		RunService:BindToRenderStep("ShiftLock", Enum.RenderPriority.Character.Value, function()
			local _, y = workspace.CurrentCamera.CFrame.Rotation:ToEulerAnglesYXZ() --Get the angles of the camera
			Root.CFrame = CFrame.new(Root.Position) * CFrame.Angles(0,y,0) --Set the root part to the camera's rotation
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
			UserInputService.MouseIconEnabled = false;
		end)
		task.wait(1);
		--UI.Crosshair.Position = UDim2.new(Mouse.ViewSizeX, 0, Mouse.ViewSizeY, 0);
		UI.Crosshair.NewCrosshair.Triangles.Visible = true;
	else
		UI.Crosshair.NewCrosshair.Triangles.Visible = false;
		RunService:UnbindFromRenderStep("ShiftLock")
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true;
	end
	
	
	if not isOvershoulder and isZoomed then
		module.Zoom(false);
	end
end

function module.Crouch()
	isCrouching = not isCrouching
	local TInfo = TweenInfo.new(.25,Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	local Offset = if isCrouching and isRight then Vector3.new(2,1,2) elseif isCrouching and not isRight then Vector3.new(-2,1,2)  elseif not isCrouching and isRight then Vector3.new(3,2,2) else Vector3.new(-3,2,2);
	local Humanoid = Player.Character:FindFirstChild("Humanoid");
	local Tween = TweenService:Create(Humanoid, TInfo, {CameraOffset = Offset})
	Tween:Play()
	Tween.Completed:wait();
end

function module.SwapShoulders()
	isRight = not isRight
	
	if isCrouching then
		local TInfo = TweenInfo.new(.25,Enum.EasingStyle.Linear, Enum.EasingDirection.In)
		local Offset = if isCrouching and isRight then Vector3.new(2,1,2) elseif isCrouching and not isRight then Vector3.new(-2,1,2)  elseif not isCrouching and isRight then Vector3.new(3,2,2) else Vector3.new(-3,2,2);
		local Humanoid = Player.Character:FindFirstChild("Humanoid");
		local Tween = TweenService:Create(Humanoid, TInfo, {CameraOffset = Offset})
		Tween:Play()
		Tween.Completed:wait();
	elseif isOvershoulder then
		local TInfo = TweenInfo.new(.25,Enum.EasingStyle.Linear, Enum.EasingDirection.In);
		
		local Offset = if isRight then Vector3.new(2,1.5,2) else Vector3.new(-2,1.5,2);
	
		local Humanoid = Player.Character:FindFirstChild("Humanoid");
	
		local Tween = TweenService:Create(Humanoid, TInfo, {CameraOffset = Offset})
		Tween:Play()
		Tween.Completed:wait();
	end
end



function module.ApplyShake(config)
	local currentTime = tick()  -- Get the current time
	local originalRecoilValue = config.Recoil.Value

	-- Initialize currentRecoilValue if it's nil
	if currentRecoilValue == nil then
		currentRecoilValue = originalRecoilValue
	end

	-- Check the time since the last shake
	if currentTime - lastShakeTime <= 0.2 then
		-- Apply diminishing effect
		--currentRecoilValue = currentRecoilValue * 0.9  -- Adjust the factor as needed to diminish the effect -- commented out for safety
		currentRecoilValue = currentRecoilValue * config.recoilDiminshingReturns.Value  -- Adjust the factor as needed to diminish the effect
	else
		-- Reset the recoil after time
		currentRecoilValue = originalRecoilValue
	end

	-- Create the target CFrame with the current recoil value
	--This makes Recoil Less Choppy
	for i=1,5 do
		task.wait()
		local targetCFrame = Camera.CFrame * CFrame.Angles(math.rad(currentRecoilValue/(6 - i)), 0, 0)
		Camera.CFrame = targetCFrame
	end
	lastShakeTime = currentTime
end

function module.Return()
	return module;
end


return module
