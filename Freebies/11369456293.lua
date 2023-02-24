local LocalPlayer = game:GetService("Players").LocalPlayer
local MPS = game:GetService("MarketplaceService")
if game.PlaceId == 11369456293 then
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()
    LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
        Character = NewCharacter
    end)
    if not MPS:PlayerOwnsAsset(LocalPlayer,12070674965) then
        repeat task.wait() until Character:FindFirstChildOfClass("Humanoid") and Character.PrimaryPart
        Character:SetPrimaryPartCFrame(CFrame.new(workspace.Zones.checkPoint1.CFrame.Position))
        repeat task.wait() until workspace.CheckPointSpawns.checkPoint1.CheckPointReached.Enabled
        Character:SetPrimaryPartCFrame(CFrame.new(workspace.Zones.checkPoint2.CFrame.Position))
        repeat task.wait() until workspace.CheckPointSpawns.checkPoint2.CheckPointReached.Enabled
        Character:SetPrimaryPartCFrame(CFrame.new(workspace.Zones.End.CFrame.Position))
        repeat task.wait() until workspace.CheckPointSpawns.End.CheckPointReached.Enabled
        Character.PrimaryPart.Anchored = true
        repeat task.wait() until LocalPlayer.PlayerGui.FadeGui.Fade.Transparency ~= 1
        repeat task.wait() until LocalPlayer.PlayerGui.FadeGui.Fade.Transparency == 1
    end
    local Queue = workspace.FutureBall.Queue.FutureBallQueue.UI.PlayerBoardOrange.Info.Q
    repeat task.wait() until not string.find(Queue.Text,"4/4") and not string.find(Queue.Text,"Starting")
    local Wins = 0
    local Scores = 0
    local Games = 0
        TargetWins = 1
        TargetScores = 10
        TargetGames = 3
        local WinGui = LocalPlayer.PlayerGui.WinnerGui
        local ScoreGui = LocalPlayer.PlayerGui.ScoreGui
        WinGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        wait(.25)
        if WinGui.Enabled and WinGui:WaitForChild("Container"):WaitForChild("Title").Text == "WINNER" then
            Wins = Wins+1
        end
    end)
    ScoreGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        task.wait(.25)
        if ScoreGui.Enabled and ScoreGui:WaitForChild("Container"):WaitForChild("Description2").Text:find(LocalPlayer.DisplayName.." scored!") then
            Scores = Scores+1
        end
    end)
    LocalPlayer.PlayerGui.ChooseTeamUI:GetPropertyChangedSignal("Enabled"):Connect(function()
    	LocalPlayer.PlayerGui.ChooseTeamUI.Enabled = false
    end)
    repeat
		Games = Games+1
        local Con1
        local Map
        Con1 = workspace.MinigameBin.ChildAdded:Connect(function(Added1)
            Map = Added1
        end)
        local Con2
        local OpNum
        Con2 = Character.DescendantAdded:Connect(function(Added2)
             if Added2.Name == "BlueAtt" then
                OpNum = 1
                Con1:Disconnect()
                Con2:Disconnect()
            elseif Added2.Name == "OrangeAtt" then
                OpNum = 2
                Con1:Disconnect()
                Con2:Disconnect()
            end
        end)
        repeat
			if not OpNum then
				Character.PrimaryPart.Anchored = false
				repeat
					Character:SetPrimaryPartCFrame(workspace.FutureBall.Queue.FutureBallQueue.Base.CFrame+Vector3.new(0,1,0))
					task.wait()
				until Map
				Character:SetPrimaryPartCFrame(workspace.FutureBall.Queue.FutureBallQueue.Base.CFrame+Vector3.new(0,100000,0))
				Character.PrimaryPart.Anchored = true
				local Done = false
				task.spawn(function()
					task.wait(25)
					Done = true
				end)
				repeat task.wait() until Done or OpNum
			end
		until OpNum
        local Goal = Map:WaitForChild("Court"):WaitForChild("Goals"):WaitForChild("T"..tostring(OpNum).."Goal")
        local BallCon
        BallCon = Map.Court.BallBin.ChildAdded:Connect(function(Ball)
            
         	wait(.5)
         	Character.PrimaryPart.Anchored = false
        	repeat
				if Scores < TargetScores or Wins < TargetWins then
					local FurthestPoint = -((Goal.Position - Ball.Position).Unit) * (Ball.Size/2) + Ball.Position
					local VelDirection = (FurthestPoint - Goal.Position).Unit
					Character:SetPrimaryPartCFrame(CFrame.new(FurthestPoint))
					Character.PrimaryPart.Velocity = VelDirection*50
				end
	    		task.wait()
        	until Ball.Parent ~= Map.Court.BallBin or LocalPlayer.PlayerGui.WinnerGui.Enabled
        	Character.PrimaryPart.Anchored = true
        	if LocalPlayer.PlayerGui.WinnerGui.Enabled or (Scores >= TargetScores and Wins >= TargetWins) then
        		BallCon:Disconnect()
			end
	    end)
        repeat task.wait() until LocalPlayer.PlayerGui.WinnerGui.Enabled
    until Wins >= TargetWins and Scores >= TargetScores and Games >= TargetGames
    Character.PrimaryPart.Anchored = false
    if getgenv().Freebies then
        local AssetIndex = table.find(Freebies["Assets"]["PlaceIndexes"], game.PlaceId)
        game:GetService("TeleportService"):Teleport(Freebies["Assets"]["PlaceIndexes"][AssetIndex+1], LocalPlayer)
    end
end
