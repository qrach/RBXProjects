local Cookie = "" -- ".ROBLOSECURITY"

local HS = game:GetService("HttpService")

local Auth = request({
    Url = "https://auth.roblox.com/v1/account/pin",
    Method = "GET",
    Headers = {
        ["Content-Type"] = "application/json",
        ["Cookie"] = ".ROBLOSECURITY="..Cookie,
    }
});
print(Auth.Success)

--if Auth.Success then
    local XCSRF = Auth.Headers["x-csrf-token"];
    local ToRedeem = {"SPIDERCOLA","TWEETROBLOX"}
    local ToBuy = {}
    local Cursor = ""

    repeat
        local Products = HS:JSONDecode(game:HttpGet("https://catalog.roblox.com/v1/search/items/details?Category=11&Subcategory=19&MaxPrice=0&Limit=30&Cursor="..Cursor))
        Cursor = Products.nextPageCursor
        for _,Product in pairs(Products.data) do
            if table.find(ToBuy,Product.productId) then
                Cursor = ""
                break
            else
                ToBuy[Product.productId] = Product.creatorTargetId
            end
        end
        if #Products.data < 30 then
            Cursor = ""
        end
    until Cursor == ""
    for ID,CID in pairs(ToBuy) do
        request({Url = "https://economy.roblox.com/v1/purchases/products/"..ID; Body = "{\"expectedCurrency\":1,\"expectedPrice\":0,\"expectedSellerId\":1}"; Headers={["Content-Type"] = "application/json";["Cookie"]=".ROBLOSECURITY="..Cookie,["X-CSRF-TOKEN"]=XCSRF}; Method="POST"})
    end
else
    warn("Your cookie is invalid. Redeeming and purchasing skipped.")
end

repeat task.wait() until game:IsLoaded()
if game.PlaceId == 11369456293 then
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local PingData = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:wait()
    repeat task.wait() until Character:FindFirstChildOfClass("Humanoid") and Character.PrimaryPart
    Character:SetPrimaryPartCFrame(workspace.CheckPointSpawns.checkPoint1.CFrame)
    task.wait(PingData:GetValue()/250)
    Character:SetPrimaryPartCFrame(workspace.CheckPointSpawns.checkPoint2.CFrame)
    task.wait(PingData:GetValue()/250)
    Character:SetPrimaryPartCFrame(workspace.CheckPointSpawns.End.CFrame)
    task.wait(PingData:GetValue()/250)
    local Queue = workspace.FutureBall.Queue.FutureBallQueue.UI.PlayerBoardOrange.Info.Q
    repeat task.wait() until not string.find(Queue.Text,"4/4") and not string.find(Queue.Text,"Starting")
    local Con
    local Map
    Con = workspace.MinigameBin.ChildAdded:Connect(function(Added)
        Map = Added
        repeat task.wait() until LocalPlayer.PlayerGui.ChooseTeamUI.Enabled
        game:GetService("ReplicatedStorage").Packages["_Index"]["sleitnick_knit@1"]["4"]["2"].knit.Services.FutureBallGameService.RE.TeamChange:FireServer(false)
        Con:Disconnect()
    end)
    repeat
        Character:SetPrimaryPartCFrame(workspace.FutureBall.Queue.FutureBallQueue.Base.CFrame)
        task.wait()
    until Map
end
