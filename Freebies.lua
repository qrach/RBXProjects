--[[
loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))()
https://roblox.fandom.com/wiki/Event
--]]
local Cookie = "" -- ".ROBLOSECURITY"
if not getgenv().Freebies then
    getgenv().Freebies = {}
end
if not table.find(Freebies,"Buy&Redeem") then Freebies["Buy&Redeem"] = true end
if not table.find(Freebies,"AutoQueue") then Freebies.AutoQueue = true end

Freebies["Assets"] = {
    ["PlaceIndexes"] = {}
}
Freebies.AddAssets = function(PlaceId,AssetIds)
    assert(type(tonumber(PlaceId)) == "number" and tonumber(PlaceId) == math.floor(tonumber(PlaceId)),"Arg1 (PlaceId) must be a valid place integer value.")
    assert(type(AssetIds) == "table" and pcall(function()
        for _,AssetId in pairs(AssetIds) do
            assert(type(tonumber(AssetId)) == "number" and AssetId == math.floor(AssetId) and pcall(function() MPS:GetProductInfo(AssetId),"")
        end
    end),"Arg2 (AssetIds) must be a valid asset integer value table.")
    table.insert(Freebies["Assets"].PlaceIndexes,PlaceId)
    table.insert(Freebies["Assets"],Assets)
end
Freebies.AddAssets("12113006580",{12179151373,12179171953})
Freebies.AddAssets("11369456293",{12070984762,12070767156,12070503643,12070674965})

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MPS = game:GetService("MarketplaceService")
local HS = game:GetService("HttpService")
local MPS = game:GetService("MPS")

local OldNC 
OldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local NameCallMethod = getnamecallmethod()
    local Args = {...}
    if self == MPS and NameCallMethod == "PlayerOwnsAsset" and #Args == 2 then
	local Player = Args[1]
	local AssetId = Args[2]
        assert(type(Player) == "userdata" and Player:IsA("Player"),"Arg1 (Player) must be a valid player instance.")
        assert(type(tonumber(AssetId)) == "number" and AssetId == math.floor(AssetId) and pcall(function() MPS:GetProductInfo(AssetId) end),"Arg2 (AssetId) must be a valid asset integer value.")
        local Owns = #HS:JSONDecode(game:HttpGet("https://inventory.roblox.com/v1/users/"..Player.UserId.."/items/Asset/"..AssetId)).data >= 1
        if Owns then return true end
        return false
    end
    return OldNC(self, ...)
end))

local OldPOA
OldPOA = hookfunction(MPS.PlayerOwnsAsset, newcclosure(function(self, ...)
    local Args = {...}
    if self == MPS and #Args == 2 then
	local Player = Args[1]
	local AssetId = Args[2]
        assert(type(Player) == "userdata" and Player:IsA("Player"),"Arg1 (Player) must be a valid player instance.")
        assert(type(tonumber(AssetId)) == "number" and AssetId == math.floor(AssetId) and pcall(function() MPS:GetProductInfo(AssetId) end),"Arg2 (AssetId) must be a valid asset integer value.")
        local Owns = #HS:JSONDecode(game:HttpGet("https://inventory.roblox.com/v1/users/"..Player.UserId.."/items/Asset/"..AssetId)).data >= 1
        if Owns then return true end
        return false
    end
    return OldPOA(self, ...)
end))
        
Freebies["CheckGame"] = function(ID)
    local AssetIndex = table.find(Freebies["Assets"]["PlaceIndexes"],tostring(ID))
    if AssetIndex then
        local AssetIds = Freebies.Assets[AssetIndex]
        local AllOwned = true
        for _, AssetId in ipairs(AssetIds) do
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
        game:GetService("TeleportService"):Teleport(Freebies["Assets"]["PlaceIndexes"][0], LocalPlayer)
    end
end


if Freebies.AutoQueue then
    queue_on_teleport("getgenv().Freebies={[\"WebStuff\"]=false}; "..game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))
end

if Freebies["Buy&Redeem"] then
	local Auth = request({Url = "https://billing.roblox.com/v1/promocodes/redeem", Method = "POST",
		Headers = {["Content-Type"] = "application/json", ["Cookie"] = ".ROBLOSECURITY="..Cookie,
		}
	});
	if Auth.Headers["x-csrf-token"] then
		local XCSRF = Auth.Headers["x-csrf-token"];
		local ToRedeem = {["SPIDERCOLA"]=1,["TWEETROBLOX"]=1}
		for Code,Asset in pairs(ToRedeem) do
			request({
			Url = "https://billing.roblox.com/v1/promocodes/redeem",
			Body = "{code:\""..Code.."\"}",
			Headers = {
					["Content-Type"] = "application/json",
					["Cookie"] = ".ROBLOSECURITY="..Cookie,
				}
			}
		end
		Method = "POST");
		local ToBuy = {}
		local Cursor = ""
		repeat
			local Products = HS:JSONDecode(game:HttpGet("https://catalog.roblox.com/v2/search/items/details?Category=1&CreatorType=1&CreatorTargetId=1&MaxPrice=0&Limit=30&Cursor="..Cursor)).data
			Cursor = Products.nextPageCursor
			for _,Product in pairs(Products) do
				if table.find(ToBuy,Product.productId) then
					Cursor = ""
					break
				else
					ToBuy[Product.productId] = {["AssetId"]=Product.id,["CreatorId"]=Product.creatorTargetId}
				end
			end
			if #Products < 30 then
				Cursor = ""
			end
		until Cursor == ""
		for ID,Info in pairs(ToBuy) do
			if not (#HS:JSONDecode(game:HttpGet("https://inventory.roblox.com/v1/users/"..LocalPlayer.UserId.."/items/Asset/"..Info.AssetId)).data >= 1) then
				local Owned = false
				repeat
					wait(1)
					local Response = request({Url = "https://economy.roblox.com/v1/purchases/products/"..ID; Body = "{\"expectedCurrency\":1,\"expectedPrice\":0,\"expectedSellerId\":"..Info.CreatorId.."}"; Headers={["Content-Type"] = "application/json";["Cookie"]=".ROBLOSECURITY="..Cookie,["X-CSRF-TOKEN"]=XCSRF}; Method="POST"})
					if HS:JSONDecode(Response.Body).statusCode then Owned = true end
				until Owned == true
			end
		end
	else
		warn("Your cookie is invalid. Redeeming and purchasing skipped.")
	end
end

Freebies.CheckGame(game.PlaceId)
--loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies/"..game.PlaceId..".lua"))()
