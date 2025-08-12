------------------------------------------------------------------------------------------------------------------------------------------
--|		*Developed by RedfireYoutube12/LightEngineer*																					|																							|
------------------------------------------------------------------------------------------------------------------------------------------

local Players = game:GetService("Players")

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

local function ProvideArms(Character)
	local Humanoid = Character:FindFirstChildOfClass("Humanoid");
	local hand = Instance.new("Part")
	hand.Size = Vector3.new(.2,.2,.2)
	hand.Transparency = 1
	hand.CanCollide = false

	local r1 = hand:clone()
	r1.Name = "R1"
	r1.Parent = Character;

	local l1 = hand:clone()
	l1.Name = "L1"
	l1.Parent = Character;
	
	local h1 = hand:Clone();
	h1.Name = "H1"
	h1.Parent = Character;
	
	local ul1 = hand:clone()
	ul1.Name = "UL1"
	ul1.Parent = Character;

	local ul2 = hand:clone()
	ul2.Name = "UL2"
	ul2.Parent = Character;

	hand:Destroy()
	
	if Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
		-- R6 Rig
		makeJoint("Motor6D",Character["Right Arm"],r1,CFrame.new(0,-1,0))					
		makeJoint("Motor6D",Character["Left Arm"],l1,CFrame.new(0,-1,0))
		makeJoint("Motor6D",Character["Torso"],h1,CFrame.new(0,-0.7,.52))
		--makeJoint("Motor6D", Character["Right Leg"], ul1, CFrame.new(.6,0,0)) Original values
		makeJoint("Motor6D", Character["Right Leg"], ul1, CFrame.new(0.6,0.6,0))
		makeJoint("Motor6D", Character["Left Leg"], ul2, CFrame.new(-.6,0,0))
	else
		-- R15 Rig
		makeJoint("Motor6D", Character.RightHand, r1, CFrame.new(0,-.15,0))
		makeJoint("Motor6D", Character.UpperTorso, h1, CFrame.new(0,-.5,.5))
		makeJoint("Motor6D", Character.LeftHand, l1, CFrame.new(0,-.15,0))
		makeJoint("Motor6D", Character.RightUpperLeg, ul1, CFrame.new(.6,0,0))
		makeJoint("Motor6D", Character.LeftUpperLeg, ul2, CFrame.new(-.6,0,0))
	end
	
end

--ProvideArms(workspace.SecondaryRig);

Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Char)
		ProvideArms(Char);
	end)
end)