-- Monetization.lua
-- Catalogue central. Remplacer les ProductId/GamePassId par les vrais IDs
-- Roblox apres creation dans Creator Dashboard.

local Monetization = {}

Monetization.DevProducts = {
	TiCoins = {
		ProductId = 0,
		Label = "Ti Pack Coins",
		Coins = 250,
	},
	GrosCoins = {
		ProductId = 0,
		Label = "Gros Pack Coins",
		Coins = 1200,
	},
	Revive = {
		ProductId = 0,
		Label = "Relance Marmaille",
		Revive = true,
	},
	BoostCoins15 = {
		ProductId = 0,
		Label = "Boost Fournaise",
		CoinMultiplier = 2,
		DurationSeconds = 15 * 60,
	},
}

Monetization.GamePasses = {
	VipPei = {
		GamePassId = 0,
		Label = "VIP Pei",
		Badge = "VIP Pei",
		DailyBonusCoins = 100,
	},
	CouleursReunion = {
		GamePassId = 0,
		Label = "Pack Couleurs Reunion",
		Skins = { "BleuLagon", "Fournaise", "Hibiscus", "VertTropical" },
	},
}

Monetization.Subscriptions = {
	SupporterFournaise = {
		SubscriptionId = "",
		Label = "Supporter Fournaise",
		DailyBonusCoins = 150,
		MonthlySkin = true,
	},
}

Monetization.AdPlacements = {
	{
		Name = "LobbyCamionBar",
		Position = Vector3.new(18, 5, -12),
		Size = Vector3.new(10, 6, 1),
		Label = "Espace partenaire peï",
	},
	{
		Name = "MarcheSaintBenoit",
		Position = Vector3.new(-22, 5, 16),
		Size = Vector3.new(10, 6, 1),
		Label = "Pub volontaire : gagne des coins",
	},
}

function Monetization.FindDevProductById(productId)
	for key, product in pairs(Monetization.DevProducts) do
		if product.ProductId == productId and productId ~= 0 then
			return key, product
		end
	end
	return nil
end

return Monetization
