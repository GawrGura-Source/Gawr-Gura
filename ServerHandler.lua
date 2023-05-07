local TweenService = game:GetService("TweenService")
local GameValues = {
	["Cup"] = 0,
	["Room Key"] = 0,
	["CurrentObjective"] = 0,	
	["Yubi"] = 0,
}
local CutsceneFolder = script.Parent.Cutscenes

local function createSFX(c,destiny)
	local c2 = c:Clone()
	c2.Parent = destiny
	c2:Play()
	game.Debris:AddItem(c2,c2.TimeLength)
end

local function ObjectiveChecker(Object,player)
	if Object:FindFirstChild("FillsObjective") then
		if (Object.FillsObjective.Value):FindFirstChild("_Finished") == nil then
			local Folder,Amount = Object.FillsObjective.Value,Object.FillsObjective:GetAttribute("Amount")
			Folder.Quantity.Value += Amount
			if Folder.Quantity.Value >= Folder.Quantity:GetAttribute("MaxQuantity") then
				player.GameValues.CurrentObjective.Value += 1
				local tag = Instance.new("StringValue",Folder); tag.Name = "_Finished"	
				for i,v in pairs(workspace.GameInteractables:GetDescendants()) do
					if v:FindFirstChild("ProximityPrompt") and v:FindFirstChild("NeedsObjectiveDone") then
						if player.GameValues.CurrentObjective.Value > v.NeedsObjectiveDone.Value then
							v.ProximityPrompt.MaxActivationDistance = v.ProximityPrompt.OriginalDistance.Value
						end
					end
				end
			end
		end
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	local Folder = Instance.new("Folder",plr)
	Folder.Name = "GameValues"
	plr:LoadCharacter()
	for i,v in pairs(GameValues) do
		local value = Instance.new("IntValue",Folder)
		value.Name = i; value.Value = v
	end
end)

for i,v in pairs(workspace.GameInteractables:GetDescendants()) do
	if v:FindFirstChildOfClass("ProximityPrompt") then
		local cooldown = false
		local SavedCFrame = v.CFrame
		v.ProximityPrompt.Triggered:connect(function(plr)
			if v.Parent == workspace.GameInteractables.PickableItems then
				if plr.GameValues:FindFirstChild(v.Name) then
					plr.GameValues[v.Name].Value = 1
					ObjectiveChecker(v,plr)
					v:Destroy()
				end
			elseif v:IsDescendantOf(workspace.GameInteractables.Doors) then
				if cooldown == false then
					cooldown = true
					if v.ProximityPrompt.ActionText == "Open" then
						ObjectiveChecker(v,plr)
						TweenService:Create(v,TweenInfo.new(0.5),{CFrame = v.Hinge.CFrame*CFrame.new(-0.15,0,2.2)*CFrame.Angles(0,math.rad(90),0)}):Play()
						v.ProximityPrompt.ActionText = "Close"
						createSFX(game.ServerStorage.SFX.DoorOpen,v)
					elseif v.ProximityPrompt.ActionText == "Close" then
						TweenService:Create(v,TweenInfo.new(0.45),{CFrame = SavedCFrame}):Play()
						v.ProximityPrompt.ActionText = "Open"
						createSFX(game.ServerStorage.SFX.DoorClose,v)
					elseif v.ProximityPrompt.ActionText == "Needs Key" then
						if plr.GameValues[v.NeedsKey.Value].Value > 0 then
							plr.GameValues[v.NeedsKey.Value].Value -= 1
							v.ProximityPrompt.ActionText = "Open"
							v.ProximityPrompt.HoldDuration = 0
						end
					end
					task.wait(0.5)
					cooldown = false
				end
			elseif v.Parent == workspace.GameInteractables.SpecialInteractables then
				if v.Name == "Clock" then
					local m = require(CutsceneFolder.KroniiCutscene); m.Start(plr)
				end
			end
		end)
		v.ProximityPrompt.PromptButtonHoldBegan:connect(function(plr)
			if cooldown == false then
				cooldown = true
				if v.ProximityPrompt.ActionText == "Needs Key" then
					if plr.GameValues[v.NeedsKey.Value].Value > 0 then
						v.DoorUnlock:Play()
					end
				end
				task.wait(0.5)
				cooldown = false
			end
		end)
		v.ProximityPrompt.PromptButtonHoldEnded:connect(function(plr)
			if v.ProximityPrompt.ActionText == "Needs Key" then
				v.DoorUnlock:Stop()
			end
		end)
	end
end

game.ReplicatedStorage.Remotes.StartGame.OnServerEvent:Connect(function(plr)
	while game.Lighting.ClockTime < 7 do
		task.wait(1)
		game.Lighting.ClockTime += 1
	end
	task.wait(6)
	for i,v in pairs(game.Players:GetPlayers()) do
		v.Character.Humanoid.Health = 0; v.Character.LastDamage.Value = "Sleep Deprivation"
	end
end)

game.ReplicatedStorage.Remotes.Quest.OnServerEvent:Connect(function(plr,action,value) 
	if action == "GiveObjective" then 
		plr.GameValues.CurrentObjective.Value = value 
		for i,v in pairs(workspace.GameInteractables:GetDescendants()) do
			if v:FindFirstChild("ProximityPrompt") and v:FindFirstChild("NeedsObjectiveDone") then
				if plr.GameValues.CurrentObjective.Value > v.NeedsObjectiveDone.Value then
					v.ProximityPrompt.MaxActivationDistance = v.ProximityPrompt.OriginalDistance.Value
				end
			end
		end
	end 
end)

game.ReplicatedStorage.Remotes.SpecialRemotes.Reset.OnServerEvent:Connect(function(plr) 
	plr.Character.Humanoid.Health = 0; plr.Character.LastDamage.Value = "yourself"
end)

for i,v in pairs(workspace.GameAreas.CutsceneTriggers:GetChildren()) do
	if v:IsA("BasePart") and v:FindFirstChild("TriggerCutscene") then
		local c
		c = v.Touched:Connect(function(h)
			if game.Players:GetPlayerFromCharacter(h.Parent) then
				c:Disconnect()
				local m = require(CutsceneFolder[v.TriggerCutscene.Value]) m.Start(game.Players:GetPlayerFromCharacter(h.Parent))
			end
		end)
	end
end





