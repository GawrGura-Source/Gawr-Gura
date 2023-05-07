local module = {}

function module.Start(plr)
	local Killed = false
	local Trident = game.ReplicatedStorage.Assets.GuraTrident:Clone()
	Trident.Parent = workspace.Map["Up Stairs"]["Upper Hallway"]
	local anim = Trident.AnimationController:LoadAnimation(Trident.Animation)
	anim:Play()
	anim.KeyframeReached:Connect(function(key)
		if key == "WindowFrame" then
			local s = script.Sound:Clone(); s.Parent = workspace.Map["Up Stairs"]["Upper Hallway"].GuraWindow; s:Play()
			workspace.Map["Up Stairs"]["Upper Hallway"].GuraWindow.Glass:Destroy()
			local GuraKillPart = game.ReplicatedStorage.Assets.GuraKillPart:Clone(); GuraKillPart.Parent = workspace.Map
			GuraKillPart.Touched:Connect(function(v)
				if v.Parent:FindFirstChild("Humanoid") then
					v.Parent.LastDamage.Value = "Gura"
					v.Parent.Humanoid.Health = 0
					Killed = true
				end
			end)
			game.Debris:AddItem(GuraKillPart,0.1)
			for i=1,math.random(4,6) do
				local Shard = game.ReplicatedStorage.Assets.GlassShards:Clone()
				local Region = workspace.Map["Up Stairs"]["Upper Hallway"].ShardsPlace
				local x = Region.Position.x
				local z = Region.Position.Z
				local xS = Region.Size.X/2
				local xZ = Region.Size.Z/2
				local random = Random.new()
				local pos1 = random:NextNumber(x-xS,x+xS)
				local pos2 = random:NextNumber(z-xZ,z+xZ)
				
				Shard.Position = Vector3.new(pos1,31.1,pos2)
				Shard.Orientation = Vector3.new(0,math.random(0,359),0)
				Shard.Parent = workspace.Map["Up Stairs"]["Upper Hallway"].ShardsPlace
				local cool = false
				Shard.Touched:Connect(function(v)
					if cool == false then
						if v.Parent:FindFirstChild("Humanoid") and v.Parent.Humanoid.Health > 0 then
							cool = true
							v.Parent.LastDamage.Value = "Glass Shards"
							v.Parent.Humanoid.Health -= 6
							task.wait(0.4)
							cool = false
						end
					end
				end)
			end
		elseif key == "Visible" then
			Trident.Trident.Transparency = 0
		end
	end)
	anim.Ended:Connect(function()
		if Killed == false then
			local contents = {
				["TextColor"] = Color3.new(1, 1, 1),
				["Font"] = Enum.Font.IndieFlower,
				["Dialogue"] = {
					[1] = "????. . .????",
					[2] = "?*Sigh* Ohio residents have been so aggressive with me lately.?",
					[3] = "?It has been like this ever since I got here.?",
					[4] = "Anyways, I'll just remove this oddly suspicious trident later..."
				},
				["Sound"] = nil,
				["FireEvent"] = nil,
				["WaitTime"] = 2
			}
			game.ReplicatedStorage.Remotes.CustomDialogue:FireClient(plr,contents)
		end
	end)
end

return module
