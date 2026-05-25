-- ShopService.lua
-- Achats d'améliorations en coins. Tout est validé serveur.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config    = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes   = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local ShopService = {}

local function applyUpgrade(player, upgradeName)
	local data = PlayerDataService.Get(player)
	if not data then return false end

	local cfg = Config.Shop[upgradeName .. "Upgrade"]
	if not cfg then return false end
	if data.Coins < cfg.Cost then return false end

	data.Coins -= cfg.Cost
	data.Upgrades[upgradeName] = (data.Upgrades[upgradeName] or 0) + 1

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if upgradeName == "Health" then
			hum.MaxHealth += cfg.Amount
			hum.Health += cfg.Amount
		elseif upgradeName == "Speed" then
			hum.WalkSpeed += cfg.Amount
		end
		-- Damage est appliqué dans le service d'arme (TODO)
	end

	return true
end

function ShopService.Init()
	local r = Remotes.Get(Constants.RemoteName.BuyUpgrade)
	if not r then return end
	r.OnServerEvent:Connect(function(player, upgradeName)
		if typeof(upgradeName) ~= "string" then return end
		applyUpgrade(player, upgradeName)
	end)
end

return ShopService
