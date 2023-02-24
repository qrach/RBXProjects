--[[

Usage Example:
getgenv().Freebies = {
	["Buy&Redeem"] = true; --boolean
	["AutoQueue"] = true; --boolean
	["Cookie"] = "_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_"; --string, .ROBLOSECURITY
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))()

https://roblox.fandom.com/wiki/Event
--]]

getgenv().Freebies = {
	["Cookie"] = "_|WARNING:-DO-NOT-SHARE-THIS.--Sharing-this-will-allow-someone-to-log-in-as-you-and-to-steal-your-ROBUX-and-items.|_07C67EE9439860E8109B84CE6245029D259E9E42808F4FCED26A6148641BA171676B3F53B8B246FC9F9E25C931864F4AD90A07DE629462A8E1CBC2D0518B8343168372CCD90AD36C169E765E00270D31F36C5AAB4AE515116B58019CA981F9A2C8DEB85A31C79F82F8465B5E08A89D2697EFB126A8D0EC9CBC44F8FA9F977DCED99EEA7ED28F6AFF2A650E159591F9186D7B7B54E07FD04E9C6D411EE13E69DCD196BE64BAF308E601EC53F39158B7DDE123DD12A3CAC229A0F27EE50C621592D8A5859E5ABE216C2AE4298042F023D71D6B912BF1683CDDA69F441ECDA1A87F99E4D19AC8A5EC581787E0943E88810CB8C653C3052C0032EA6792422C9BD0B66B202F5FED700F9B45D32B03AC111EF0941E60F3E1C79EE772AAEA2D00BD50A76AC7171C47C0AF624D117AD2A192442EFBD8C6E7C9F089AA265572C6C3E0E68B607266F7457BFE080FB973CF9D3E23BEF279E5D290D8733958FEF60CF17449E12A7F2127D7DC5AB6EDCAAF560344D7254E937613"
}

if getgenv().Freebies then
	if not type(Freebies["Buy&Redeem"]) == "boolean" then Freebies["Buy&Redeem"] = true end
	if not type(Freebies["AutoQueue"]) == "boolean" then Freebies.AutoQueue = true end
	if not type(Freebies["Cookie"]) then Freebies["Buy&Redeem"] = false end
else
	getgenv().Freebies = {
		["Buy&Redeem"] = true; --boolean
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
	end),"Arg2 (AssetIds) must be a valid asset integer value table.")
	table.insert(Freebies["Assets"].PlaceIndexes,PlaceId)
	table.insert(Freebies["Assets"],Assets)
end
Freebies:AddAssets("12113006580",{12179151373,12179171953})
Freebies:AddAssets("11369456293",{12070984762,12070767156,12070503643,12070674965})

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local MPS = game:GetService("MarketplaceService")
local HS = game:GetService("HttpService")
local MPS = game:GetService("MarketplaceService")

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
		if Owns then return true end
		return false
	end
	return OldPOA(self, ...)
end))
	
function Freebies:Initialize(ID)
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
	end
	game:GetService("TeleportService"):Teleport(Freebies["Assets"]["PlaceIndexes"][0], LocalPlayer)
end


if Freebies.AutoQueue then
	queue_on_teleport("getgenv().Freebies="..HS:JSONEncode(Freebies).."; "..game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))
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
		warn("Your Freebies.Cookie is invalid. Redeeming and purchasing skipped.")
	end
end

Freebies.Initialize(game.PlaceId)
if table.find(Freebies["Assets"].PlaceIndexes,game.PlaceId) then
	loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies/"..game.PlaceId..".lua"))()
end
