--[[

Usage Example:
getgenv().Freebies = {
	["Buy&Redeem"] = true; --boolean
	["AutoQueue"] = true; --boolean
	["Cookie"] = "_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_"; --string, .ROBLOSECURITY
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/Freebies/main/Freebies.lua"))()

https://roblox.fandom.com/wiki/Event
--]]

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MPS = game:GetService("MarketplaceService")
local HS = game:GetService("HttpService")
local MPS = game:GetService("MarketplaceService")

if getgenv().Freebies then
	if type(Freebies) == "string" then Freebies = HS:JSONDecode(Freebies) end
	if not type(Freebies["Buy&Redeem"]) == "boolean" then Freebies["Buy&Redeem"] = true end
	if not type(Freebies["AutoQueue"]) == "boolean" then Freebies.AutoQueue = true end
	if not type(Freebies["Cookie"]) then Freebies["Buy&Redeem"] = false end
else
	getgenv().Freebies = {
		["Buy&Redeem"] = false; --boolean
		["AutoQueue"] = true; --boolean
		["Cookie"] = ""; --string, .ROBLOSECURITY
	}
end

Freebies["Assets"] = {
	["PlaceIndexes"] = {}
}
function Freebies:AddAssets(PlaceId,AssetIds)
	assert(type(tonumber(PlaceId)) == "number" and tonumber(PlaceId) == math.floor(tonumber(PlaceId)) and not table.find(Freebies["Assets"].PlaceIndexes,PlaceId),"Arg1 (PlaceId) must be a valid place integer value.")
	assert(type(AssetIds) == "table" and pcall(function()
		for _,AssetId in pairs(AssetIds) do
			assert(type(tonumber(AssetId)) == "number" and AssetId == math.floor(AssetId),"")
		end
		return true
	end),"Arg2 (AssetIds) must be a valid asset integer value table.")
	table.insert(Freebies["Assets"].PlaceIndexes,PlaceId)
	table.insert(Freebies["Assets"],Assets)
end
Freebies:AddAssets("12113006580",{12179151373,12179171953})
Freebies:AddAssets("11369456293",{12070984762,12070767156,12070503643,12070674965})

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
		assert(type(tonumber(AssetId)) == "number" and AssetId == math.floor(AssetId),"Arg2 (AssetId) must be a valid asset integer value.")
		local Owns = #HS:JSONDecode(game:HttpGet("https://inventory.roblox.com/v1/users/"..Player.UserId.."/items/Asset/"..AssetId)).data >= 1
		print(Owns)
		if Owns then return true end
		return false
	end
	return OldPOA(self, ...)
end))

function Freebies:Initialize()
	local AssetIndex = table.find(Freebies["Assets"]["PlaceIndexes"],game.PlaceId)
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
		game:GetService("TeleportService"):Teleport(Freebies["Assets"]["PlaceIndexes"][1], LocalPlayer)

	end
end


if Freebies.AutoQueue then
	queue_on_teleport("getgenv().Freebies=\""..HS:JSONEncode(Freebies).."\"; "..game:HttpGet("https://raw.githubusercontent.com/qrach/Freebies/main/Freebies.lua"))
end

if Freebies["Buy&Redeem"] then
	local Auth = request({Url = "https://auth.roblox.com/", Headers = {["Content-Type"] = "application/json", ["Cookie"] = ".ROBLOSECURITY="..Freebies.Cookie}, Method = "POST"});
	if Auth.Headers["x-csrf-token"] then
		local XCSRF = Auth.Headers["x-csrf-token"];
		local ToRedeem = {["SPIDERCOLA"]=1,["TWEETROBLOX"]=1}
		for Code,Asset in pairs(ToRedeem) do
			request({Url = "https://billing.roblox.com/v1/promocodes/redeem", Headers = {["Content-Type"] = "application/json", ["Cookie"] = ".ROBLOSECURITY="..Freebies.Cookie}, Body = "{code:\""..Code.."\"}", Method = "GET"})
		end
		local ToBuy = {}
		local Cursor = ""
		repeat
			local Products = HS:JSONDecode(game:HttpGet("https://catalog.roblox.com/v2/search/items/details?Category=1&CreatorType=1&CreatorTargetId=1&MaxPrice=0&Limit=30&Cursor="..Cursor)).data
			Cursor = Products.nextPageCursor
			for _,Product in pairs(Products) do
				if table.find(ToBuy,Product.productId) then
					Cursor = ""
					break
				end
				ToBuy[Product.productId] = {["AssetId"]=Product.id,["CreatorId"]=Product.creatorTargetId}
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
					local Response = request({Url = "https://economy.roblox.com/v1/purchases/products/"..ID; Body = "{\"expectedCurrency\":1,\"expectedPrice\":0,\"expectedSellerId\":"..Info.CreatorId.."}"; Headers={["Content-Type"] = "application/json";["Cookie"]=".ROBLOSECURITY="..Freebies.Cookie,["X-CSRF-TOKEN"]=XCSRF}; Method="POST"})
					if HS:JSONDecode(Response.Body).statusCode then Owned = true end
				until Owned == true
			end
		end
	else
		warn("Your Cookie is invalid. Redeeming and purchasing skipped.")
	end
end

Freebies.Initialize()
if table.find(Freebies["Assets"].PlaceIndexes,game.PlaceId) then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/Freebies/main/Games/"..game.PlaceId..".lua"))()
end
