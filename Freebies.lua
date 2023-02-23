--[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))()
https://roblox.fandom.com/wiki/Event
--]]
local Cookie = "" -- ".ROBLOSECURITY"
getgenv().Freebies = {
    ["Buy&Redeem"] = false;
}
if not getgenv().Freebies then
    getgenv().Freebies = {}
end
if not Freebies.WebStuff then Freebies["Buy&Redeem"] = true end
if not Freebies.AutoQueue then Freebies.AutoQueue = true end

Freebies["Assets"] = {
    ["12113006580"] = {12179151373,12179171953};
    ["11369456293"] = {12070984762,12070767156,12070503643,12070674965}
}

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MPS = game:GetService("MarketplaceService")
local HS = game:GetService("HttpService")

local MPSMT = getrawmetatable(MPS)
setreadonly(MPSMT,false)
rawset(MPSMT, "PlayerOwnsAsset", function(Player,AssetId)
        assert(type(Player) == "userdata" and Player:IsA("Player"),"Arg1 (Player) must be a valid player instance.")
        assert(type(tonumber(AID)) == "number" and AID == math.floor(AID) and pcall(function() MPS:GetProductInfo(AID) end),"Arg2 (AssetId) must be a valid asset integer value.")
        local Owns = #HS:JSONDecode(game:HttpGet("https://inventory.roblox.com/v1/users/"..Player.UserId.."/items/Asset/"..AID)).data >= 1
        if Owns then print('hi') return true end
        print('baller')
        return false
 end)
 setreadonly(MPSMT,true)
        
Freebies["CheckGame"] = function(ID)
    if Freebies.Assets[ID] then
        local AllOwned = true
        for _, Asset in pairs(Freebies.Assets[ID]) do
            local Owned = MPS:PlayerOwnsAsset(LocalPlayer,Asset)
            if not Owned then
                AllOwned = false
                break
            end
        end
        if AllOwned then
            local Idx
            for i, v in pairs(Freebies.Assets) do
                if i == ID then
                    Idx = i
                    break
                end
            end
            for i, _ in pairs(Freebies.Assets) do
                if i == Freebies.Assets[Idx + 1] then
                    game:GetService("TeleportService"):Teleport(i, LocalPlayer)
                    break
                end
            end
        end
    else
        for i, _ in pairs(Freebies.Assets) do
            game:GetService("TeleportService"):Teleport(i, LocalPlayer)
            break
        end
    end
end


if Freebies.AutoQueue then
    queue_on_teleport("getgenv().Freebies={[\"WebStuff\"]=false}; "..game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))
end

if Freebies["Buy&Redeem"] then
    local Auth = request({
        Url = "https://auth.roblox.com/v2/login",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Cookie"] = ".ROBLOSECURITY="..Cookie,
        }
    });

    if Auth.Success then
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
end

Freebies.CheckGame(game.PlaceId)
loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies/"..game.PlaceId..".lua"))()
