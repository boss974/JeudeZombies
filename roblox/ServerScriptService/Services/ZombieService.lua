-- ZombieService.lua
-- Spawn et gestion runtime des zombies. Côté serveur uniquement.

local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config    = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))

-- ZombieFactory : fabrique des rigs cartoon stylisés. Chargé en require relatif
-- pour rester cohérent avec le module qui est dans le même dossier Services/.
local ZombieFactory = require(script.Parent:WaitForChild("ZombieFactory"))

local ZombieService = {}
ZombieService.OnKilled = nil
local active = {}

local function getSpawnPoint()
	-- Trouve le folder Arena/Spawns, sinon utilise l'origine
	local arena = Workspace:FindFirstChild("Arena")
	if arena then
		local spawns = arena:FindFirstChild("ZombieSpawns")
		if spawns and #spawns:GetChildren() > 0 then
			local list = spawns:GetChildren()
			return list[math.random(1, #list)].Position
		end
	end
	-- Fallback : cercle autour du centre
	local angle = math.random() * math.pi * 2
	return Vector3.new(math.cos(angle) * 60, 5, math.sin(angle) * 60)
end

local function buildZombie(zombieType, stats)
	-- Build minimaliste : un rig simple R6 programmatique.
	-- Remplacer par un modèle dans ServerStorage.ZombieModels pour avoir un vrai look.
	local model = ServerStorage:FindFirstChild("ZombieModels")
	if model and model:FindFirstChild(zombieType) then
		return model[zombieType]:Clone()
	end

	-- Fallback procédural : block bonhomme
	local rig = Instance.new("Model")
	rig.Name = "Zombie_" .. zombieType
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 2, 1)
	hrp.BrickColor = BrickColor.new("Dark green")
	hrp.Material = Enum.Material.Slate
	hrp.TopSurface = Enum.SurfaceType.Smooth
	hrp.BottomSurface = Enum.SurfaceType.Smooth
	hrp.Parent = rig
	rig.PrimaryPart = hrp

	local hum = Instance.new("Humanoid")
	hum.MaxHealth = stats.Health
	hum.Health = stats.Health
	hum.WalkSpeed = stats.Speed
	hum.Parent = rig
	return rig
end

function ZombieService.Init()
	active = {}
end

function ZombieService.GetActiveCount()
	local n = 0
	for _ in pairs(active) do n += 1 end
	return n
end

function ZombieService.Spawn(zombieType)
	local stats = Config.Zombie[zombieType]
	if not stats then return end

	-- Essayer la factory cartoon en priorité, fallback procédural si erreur
	-- (évite de casser le run si ZombieFactory plante pour une raison X).
	local ok, rig = pcall(ZombieFactory.Build, zombieType)
	if not ok or not rig then
		warn("[ZombieService] ZombieFactory.Build a échoué : " .. tostring(rig) ..
			" → fallback procédural pour type " .. tostring(zombieType))
		rig = buildZombie(zombieType, stats)
	end
	rig:SetAttribute("ZombieType", zombieType)
	rig:SetAttribute("Damage", stats.Damage)

	local pos = getSpawnPoint()
	rig:PivotTo(CFrame.new(pos))
	rig.Parent = Workspace

	local hum = rig:FindFirstChildOfClass("Humanoid")
	hum.MaxHealth = stats.Health
	hum.Health = stats.Health
	hum.WalkSpeed = stats.Speed

	active[rig] = true

	-- IA : poursuit le joueur le plus proche
	task.spawn(function()
		while rig.Parent and hum.Health > 0 do
			local closest, closestDist = nil, math.huge
			for _, plr in ipairs(Players:GetPlayers()) do
				local char = plr.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					local d = (root.Position - rig.PrimaryPart.Position).Magnitude
					if d < closestDist then closest, closestDist = root, d end
				end
			end
			if closest then
				hum:MoveTo(closest.Position)
			end
			task.wait(0.5)
		end
	end)

	-- Dégâts au contact
	rig.PrimaryPart.Touched:Connect(function(hit)
		local hitHum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		local hitPlr = hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)
		if hitHum and hitPlr and tick() - (rig:GetAttribute("LastHitTime") or 0) > 0.6 then
			hitHum:TakeDamage(stats.Damage)
			rig:SetAttribute("LastHitTime", tick())
		end
	end)

	-- Récompense au kill
	hum.Died:Connect(function()
		local killer = rig:GetAttribute("LastDamageBy")
		local plr = killer and Players:FindFirstChild(killer)
		if plr and ZombieService.OnKilled then
			ZombieService.OnKilled(plr, zombieType)
		end
		active[rig] = nil
		task.wait(2)
		if rig then rig:Destroy() end
	end)

	return rig
end

return ZombieService
