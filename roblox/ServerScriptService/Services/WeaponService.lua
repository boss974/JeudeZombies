-- WeaponService.lua
-- Tir serveur simple : le client envoie une cible, le serveur valide distance,
-- cooldown et raycast, puis applique les degats au zombie touche.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local WeaponService = {}
local lastShot = {}
local callbacks = {}

local function makeTracer(fromPos, toPos)
	local dir = toPos - fromPos
	local part = Instance.new("Part")
	part.Name = "ShotTracer"
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 210, 80)
	part.Size = Vector3.new(0.08, 0.08, math.max(0.1, dir.Magnitude))
	part.CFrame = CFrame.lookAt(fromPos + dir * 0.5, toPos)
	part.Parent = workspace
	Debris:AddItem(part, 0.08)
end

local function getDamage(player)
	local data = PlayerDataService.Get(player)
	local upgrade = data and data.Upgrades and data.Upgrades.Damage or 0
	return Config.Weapon.BaseDamage + upgrade * Config.Shop.DamageUpgrade.Amount
end

local function shoot(player, targetPos)
	if typeof(targetPos) ~= "Vector3" then return end
	local now = os.clock()
	if now - (lastShot[player] or 0) < Config.Weapon.Cooldown then return end
	lastShot[player] = now

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local origin = root.Position + Vector3.new(0, 1.4, 0)
	local delta = targetPos - origin
	if delta.Magnitude < 2 then return end
	local direction = delta.Unit * math.min(delta.Magnitude, Config.Weapon.Range)

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { char }
	local result = workspace:Raycast(origin, direction, params)
	local hitPos = result and result.Position or (origin + direction)
	makeTracer(origin, hitPos)

	if callbacks.OnPlayerShoot then callbacks.OnPlayerShoot(player) end

	if not result or not result.Instance then return end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	local hum = model and model:FindFirstChildOfClass("Humanoid")
	if hum and model:GetAttribute("ZombieType") then
		model:SetAttribute("LastDamageBy", player.Name)
		hum:TakeDamage(getDamage(player))
	end
end

function WeaponService.Init(cbs)
	callbacks = cbs or {}
	local r = Remotes.Get(Constants.RemoteName.ShootWeapon)
	if not r then return end
	r.OnServerEvent:Connect(shoot)
end

return WeaponService
