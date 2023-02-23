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

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MPS = game:GetService("MarketplaceService")
local HS = game:GetService("HttpService")

if not table.find(Freebies,"Buy&Redeem") then Freebies["Buy&Redeem"] = true end
if not table.find(Freebies,"AutoQueue") then Freebies.AutoQueue = true end

Freebies["Assets"] = {
    ["PlaceIndexes"] = {}
}

Freebies.AddAssets = function(PlaceId,AssetIds)
    assert(type(tonumber(PlaceId)) == "number" and tonumber(PlaceId) == math.floor(tonumber(PlaceId)),"Arg1 (PlaceId) must be a valid place integer value.")
    assert(type(AssetIds) == "table" and pcall(function() for _,AssetId in pairs(AssetIds) do assert(type(tonumber(AssetId)) == "number" and tonumber(AssetId) == math.floor(tonumber(AssetId)),"") end end),"Arg2 (AssetIds) must be a valid asset integer value table.")
    table.insert(Freebies["Assets"].PlaceIndexes,PlaceId)
    table.insert(Freebies["Assets"],HS:JSONEncode(AssetIds))
end
Freebies.AddAssets("12113006580",{12179151373,12179171953})
Freebies.AddAssets("11369456293",{12070984762,12070767156,12070503643,12070674965})

local MPSMT = getrawmetatable(MPS)
setreadonly(MPSMT,false)
rawset(MPSMT, "PlayerOwnsAsset", function(Player,AssetId)
        assert(type(Player) == "userdata" and Player:IsA("Player"),"Arg1 (Player) must be a valid player instance.")
        assert(type(tonumber(AssetId)) == "number" and AssetId == math.floor(AssetId) and pcall(function() MPS:GetProductInfo(AssetId) end),"Arg2 (AssetId) must be a valid asset integer value.")
        local Owns = #HS:JSONDecode(game:HttpGet("https://inventory.roblox.com/v1/users/"..Player.UserId.."/items/Asset/"..AssetId)).data >= 1
        if Owns then return true end
        return false
 end)
 setreadonly(MPSMT,true)
        
Freebies["CheckGame"] = function(ID)
    local AssetIndex = table.find(Freebies["Assets"]["PlaceIndexes"],tostring(ID))
    if AssetIndex then
        local AssetIds = HS:JSONDecode(Freebies.Assets[AssetIndex])
        local AllOwned = true
        for _, AssetId in pairs(AssetIds) do
            local Owned = pcall(function() return MPS:PlayerOwnsAsset(LocalPlayer,AssetId) end)
            if not Owned then
                AllOwned = false
                break
			end
        end
        if AllOwned then
            game:GetService("TeleportService"):Teleport(Freebies["Assets"]["PlaceIndexes"][AssetIndex+1],LocalPlayer)
        end
    else
        game:GetService("TeleportService"):Teleport(Freebies["Assets"]["PlaceIndexes"][1], LocalPlayer)
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
--loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies/"..game.PlaceId..".lua"))()
