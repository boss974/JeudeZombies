-- MonetizationService.lua
-- Achats Roblox : developer products maintenant, passes/abonnements ensuite.
-- Les IDs 0 sont des placeholders pour eviter tout prompt avant publication.

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes = require(Shared:WaitForChild("Remotes"))
local Monetization = require(Shared:WaitForChild("Monetization"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local MonetizationService = {}

local function push(player)
	local data = PlayerDataService.Get(player)
	local scoreRemote = Remotes.Get(Constants.RemoteName.ScoreUpdate)
	if scoreRemote and data then scoreRemote:FireClient(player, data.Score, data.Coins, data.BestScore) end

	local monetizationRemote = Remotes.Get(Constants.RemoteName.MonetizationUpdate)
	if monetizationRemote and data then
		monetizationRemote:FireClient(player, data.Monetization or {})
	end
end

local function grantProduct(player, product)
	local data = PlayerDataService.Get(player)
	if not data then return false end

	if product.Coins then
		data.Coins += product.Coins
	end

	if product.CoinMultiplier then
		data.Monetization.CoinMultiplier = product.CoinMultiplier
		data.Monetization.CoinBoostEndsAt = os.time() + product.DurationSeconds
	end

	if product.Revive then
		data.Monetization.PendingRevives = (data.Monetization.PendingRevives or 0) + 1
	end

	push(player)
	return true
end

function MonetizationService.GetCoinMultiplier(player)
	local data = PlayerDataService.Get(player)
	local monetization = data and data.Monetization
	if not monetization then return 1 end
	if monetization.CoinBoostEndsAt and os.time() <= monetization.CoinBoostEndsAt then
		return monetization.CoinMultiplier or 1
	end
	monetization.CoinMultiplier = 1
	monetization.CoinBoostEndsAt = 0
	return 1
end

function MonetizationService.Init()
	local purchaseRemote = Remotes.Get(Constants.RemoteName.PurchaseProduct)
	if purchaseRemote then
		purchaseRemote.OnServerEvent:Connect(function(player, productKey)
			if typeof(productKey) ~= "string" then return end
			local product = Monetization.DevProducts[productKey]
			if not product or product.ProductId == 0 then return end
			MarketplaceService:PromptProductPurchase(player, product.ProductId)
		end)
	end

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

		local _, product = Monetization.FindDevProductById(receiptInfo.ProductId)
		if not product then return Enum.ProductPurchaseDecision.NotProcessedYet end

		if grantProduct(player, product) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

return MonetizationService
