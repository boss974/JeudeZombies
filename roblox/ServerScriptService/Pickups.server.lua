-- Pickups.server.lua
-- Système de loot et de récupération :
-- - Spawne 30 caisses dispersées sur l'île au démarrage (food + ammo)
-- - Quand un zombie meurt, 60% chance de dropper un mini-pickup à sa position
-- - Au contact avec le joueur (HumanoidRootPart < 4 studs) → ramassage automatique
--
-- Types de pickup :
-- - "food"   : restaure +25 HP au joueur (sphere verte)
-- - "ammo"   : pas d'arme avancée pour l'instant, déclenche un buff dégâts +50%
--              pendant 8s (sphere bleue)
-- - "coin"   : ajoute des coins au joueur (sphere dorée)
--
-- Ramassage par scan périodique (économique pour 6 joueurs max coop).

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

local Services = ServerScriptService:WaitForChild("Services")
local PlayerDataService = require(Services:WaitForChild("PlayerDataService"))

if Workspace:FindFirstChild("Pickups") then return end

local root = Instance.new("Folder")
root.Name = "Pickups"
root.Parent = Workspace

-- ============================================================================
-- Mini-pickups (sphère Neon flottante, rotative)
-- ============================================================================
local KIND_DATA = {
	food  = { color = Color3.fromRGB( 80, 220,  90), label = "+25 HP",   defaultValue = 25 },
	ammo  = { color = Color3.fromRGB( 60, 180, 250), label = "BUFF x1.5", defaultValue = 8 },
	coin  = { color = Color3.fromRGB(255, 200,  60), label = "+5 coins", defaultValue = 5 },
}

local function makePickup(pos, kind, value)
	local cfg = KIND_DATA[kind] or KIND_DATA.coin
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Size = Vector3.new(1.8, 1.8, 1.8)
	p.Position = pos + Vector3.new(0, 2, 0)
	p.Material = Enum.Material.Neon
	p.Shape = Enum.PartType.Ball
	p.Color = cfg.color
	p.Transparency = 0.1
	p.Name = "Pickup_" .. kind
	p:SetAttribute("PickupKind", kind)
	p:SetAttribute("PickupValue", value or cfg.defaultValue)
	p.Parent = root

	-- Lumière de signalement
	local light = Instance.new("PointLight")
	light.Brightness = 1.4
	light.Range = 10
	light.Color = cfg.color
	light.Parent = p

	-- Animation rotation + bobbing
	task.spawn(function()
		local startY = p.Position.Y
		local t = 0
		while p.Parent do
			t = t + 0.05
			p.CFrame = CFrame.new(p.Position.X, startY + math.sin(t * 2) * 0.3, p.Position.Z)
				* CFrame.Angles(0, t, 0)
			task.wait(0.05)
		end
	end)

	-- Auto-destroy après 45s
	Debris:AddItem(p, 45)
	return p
end

-- ============================================================================
-- Ramassage : scan toutes les 0.2s
-- ============================================================================
-- Buffs actifs (dégâts temporaires)
local damageBuffs = {}  -- [player] = expiresAt

local function applyPickup(player, kind, value)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	if kind == "food" then
		hum.Health = math.min(hum.MaxHealth, hum.Health + value)
	elseif kind == "ammo" then
		damageBuffs[player] = tick() + (value or 8)
	elseif kind == "coin" then
		local data = PlayerDataService.Get(player)
		if data then data.Coins = (data.Coins or 0) + (value or 5) end
	end
end

task.spawn(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local char = player.Character
			local prRoot = char and char:FindFirstChild("HumanoidRootPart")
			if prRoot then
				for _, item in ipairs(root:GetChildren()) do
					if item:IsA("BasePart") and item.Name:sub(1, 7) == "Pickup_" then
						if (item.Position - prRoot.Position).Magnitude < 4 then
							local kind  = item:GetAttribute("PickupKind") or "food"
							local value = item:GetAttribute("PickupValue") or 0
							applyPickup(player, kind, value)
							-- Petit effet flash blanc
							local flash = Instance.new("Part")
							flash.Anchored = true; flash.CanCollide = false
							flash.Size = Vector3.new(3, 3, 3)
							flash.Position = item.Position
							flash.Material = Enum.Material.Neon
							flash.Color = Color3.new(1, 1, 1)
							flash.Shape = Enum.PartType.Ball
							flash.Transparency = 0.5
							flash.Parent = Workspace
							Debris:AddItem(flash, 0.2)
							item:Destroy()
						end
					end
				end
			end
		end
		task.wait(0.2)
	end
end)

-- ============================================================================
-- Spawn initial : 30 caisses sur l'île aux positions aléatoires
-- ============================================================================
math.randomseed(os.time())
for _ = 1, 30 do
	local x = (math.random() - 0.5) * 700
	local z = (math.random() - 0.5) * 560
	local kind = ({"food", "ammo", "coin", "food", "coin"})[math.random(1, 5)]
	makePickup(Vector3.new(x, 12, z), kind)
end

-- ============================================================================
-- API : drop quand un zombie meurt (hook depuis ZombieService ou WaveService)
-- ============================================================================
local Pickups = {}
function Pickups.DropAt(pos, kind, value)
	makePickup(pos, kind, value)
end
function Pickups.GetDamageBuff(player)
	local exp = damageBuffs[player]
	if exp and exp > tick() then return 1.5 end
	return 1.0
end

-- Expose globalement pour qu'autres scripts puissent dropper
_G.Pickups = Pickups

print("[Pickups] 30 caisses dispersees + boucle de ramassage active (food/ammo/coin).")
