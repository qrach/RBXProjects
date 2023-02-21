-- loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))()
local Cookie = "" -- ".ROBLOSECURITY"
getgenv().Freebies = {
    ["WebStuff"] = false;
}
if not getgenv().Freebies then
    getgenv().Freebies = {
        ["WebStuff"] = true;
        ["AutoQueue"] = true;
    }
end

Freebies["Assets"] = {
    ["12113006580"] = {12179151373,12179171953};
    ["11369456293"] = {12070984762,12070767156,12070503643,12070674965}
}

repeat task.wait() until game:IsLoaded()
local LocalPlayer = game:GetService("Players").LocalPlayer
local MPS = game:GetService("MarketplaceService")

Freebies["CheckGame"] = function(ID)
    if Freebies.Assets[ID] then
    	local AllOwned = true
        for _,Asset in pairs(Freebies.Assets[ID]) do
            local Owned = MPS:PlayerOwnsAsset(LocalPlayer,Asset)
            if not Owned then
            	AllOwned = false
            	break
            end
        end
        if AllOwned then
			local Idx = table.find(Freebies.Assets,ID)
			for Idx2, _ in pairs(Freebies.Assets) do
				if Idx2 == Freebies.Assets[Idx+1] then
					game:GetService("TeleportService"):Teleport(Idx2, LocalPlayer)
					repeat task.wait() until not true
					break
				end
			end
		end
    else
		for Idx,_ in pairs(Freebies.Assets) do
			game:GetService("TeleportService"):Teleport(Idx, LocalPlayer)
			repeat task.wait() until not true
			break
		end
    end
end

if Freebies.AutoQueue then
    queue_on_teleport("getgenv().Freebies={[\"WebStuff\"]=false}; "..game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies.lua"))
end

if Freebies.WebStuff then
    local HS = game:GetService("HttpService")
    local Auth = request({
        Url = "https://auth.roblox.com/v1/account/pin",
        Method = "GET",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Cookie"] = ".ROBLOSECURITY="..Cookie,
        }
    });

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
    --else
    --    warn("Your cookie is invalid. Redeeming and purchasing skipped.")
    --end
end

Freebies.CheckGame(game.PlaceId)
loadstring(game:HttpGet("https://raw.githubusercontent.com/qrach/RBXProjects/main/Freebies/"..game.PlaceId..".lua"))()
