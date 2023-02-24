repeat task.wait() until game:IsLoaded()
local LocalPlayer = game:GetService("Players").LocalPlayer
if game.PlaceId == 12113006580 then
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()
    repeat task.wait() until Character.PrimaryPart
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Currency = LocalPlayer.PlayerGui:WaitForChild("Currency"):WaitForChild("Amount")
    for _,Reward in pairs(workspace.Folder:GetChildren()) do
        local Current = tonumber(Currency.Text)
        if not (Current >= 22550) then
            if Reward.Transparency == 0 then
                repeat
                    Character.PrimaryPart.CFrame = Reward.CFrame
                    task.wait()
                until tonumber(Currency.Text) > Current
            end
        end
    end
    for _,Inst in pairs(workspace:GetDescendants()) do
    	if Inst:IsA("BasePart") and Inst.Transparency == 0 and Inst.Name == "Star" then
    	    local Current = tonumber(Currency.Text)
            if not (Current >= 22550) then
                repeat
                    Character.PrimaryPart.CFrame = Inst.CFrame
                    task.wait()
                until tonumber(Currency.Text) > Current
            end
        end
    end
    if tonumber(Currency.Text) >= 22550 then
        ReplicatedStorage.Packages._Index["sleitnick_knit@1.4.7"].knit.Services.ShopService.RE.PurchaseItem:FireServer("Accessories", "008")
        ReplicatedStorage.Packages._Index["sleitnick_knit@1.4.7"].knit.Services.ShopService.RE.PurchaseItem:FireServer("Accessories", "007")
        if getgenv().Freebies then
            local AssetIndex = table.find(Freebies["Assets"]["PlaceIndexes"], game.PlaceId)
            game:GetService("TeleportService"):Teleport(Freebies["Assets"]["PlaceIndexes"][AssetIndex+1], LocalPlayer)
        end
    else
        queue_on_teleport(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies/"..game.PlaceId..".lua"))
        task.wait(1)
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end
