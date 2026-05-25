-- DefenseService.lua
-- Placement serveur des barricades et tourelles. Les coins sont debites cote
-- serveur, puis les tourelles cherchent automatiquement les zombies proches.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local ZombieService = require(script.Parent:WaitForChild("ZombieService"))

local DefenseService = {}
local defensesFolder

local function pushScore(player)
	local data = PlayerDataService.Get(player)
	local r = Remotes.Get(Constants.RemoteName.ScoreUpdate)
	if r and data then r:FireClient(player, data.Score, data.Coins, data.BestScore) end
end

local function ensureFolder()
	defensesFolder = workspace:FindFirstChild("Defenses")
	if not defensesFolder then
		defensesFolder = Instance.new("Folder")
		defensesFolder.Name = "Defenses"
		defensesFolder.Parent = workspace
	end
	return defensesFolder
end

local function canPlace(player, defenseType, position)
	if typeof(defenseType) ~= "string" or typeof(position) ~= "Vector3" then return false end
	local cfg = Config.Defense[defenseType]
	if not cfg then return false end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	if (root.Position - position).Magnitude > 80 then return false end

	local data = PlayerDataService.Get(player)
	if not data or data.Coins < cfg.Cost then return false end
	data.Coins -= cfg.Cost
	pushScore(player)
	return true, cfg
end

local function buildDefense(defenseType, position, cfg)
	local model = Instance.new("Model")
	model.Name = defenseType
	model:SetAttribute("DefenseType", defenseType)

	local base = Instance.new("Part")
	base.Name = "Base"
	base.Anchored = true
	base.CanCollide = true
	base.Material = defenseType == "Turret" and Enum.Material.Metal or Enum.Material.Wood
	base.Color = defenseType == "Turret" and Color3.fromRGB(244, 185, 66) or Color3.fromRGB(120, 75, 35)
	base.Size = defenseType == "Turret" and Vector3.new(3, 2, 3) or Vector3.new(7, 4, 1.5)
	base.CFrame = CFrame.new(position + Vector3.new(0, base.Size.Y * 0.5, 0))
	base.Parent = model
	model.PrimaryPart = base

	local hum = Instance.new("Humanoid")
	hum.MaxHealth = cfg.Health
	hum.Health = cfg.Health
	hum.DisplayDistanceType = Enum.HumanoidDisplayType.None
	hum.Parent = model

	model.Parent = ensureFolder()
	return model
end

local function startTurret(model, owner)
	local cfg = Config.Defense.Turret
	local elapsed = 0
	local conn
	conn = RunService.Heartbeat:Connect(function(dt)
		if not model.Parent then conn:Disconnect() return end
		elapsed += dt
		if elapsed < cfg.FireRate then return end
		elapsed = 0

		local base = model.PrimaryPart
		if not base then return end
		local target, best = nil, cfg.Range
		for _, zombie in ipairs(ZombieService.GetActiveZombies()) do
			local root = zombie.PrimaryPart
			local hum = zombie:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local dist = (root.Position - base.Position).Magnitude
				if dist < best then
					target, best = zombie, dist
				end
			end
		end
		if target then
			target:SetAttribute("LastDamageBy", owner.Name)
			local hum = target:FindFirstChildOfClass("Humanoid")
			if hum then hum:TakeDamage(cfg.Damage) end
		end
	end)
end

local function placeDefense(player, defenseType, position)
	local ok, cfg = canPlace(player, defenseType, position)
	if not ok then return end
	local model = buildDefense(defenseType, position, cfg)
	if defenseType == "Turret" then startTurret(model, player) end
end

function DefenseService.Init()
	ensureFolder()
	local r = Remotes.Get(Constants.RemoteName.PlaceDefense)
	if not r then return end
	r.OnServerEvent:Connect(placeDefense)
end

return DefenseService
