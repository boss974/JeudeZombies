-- MissionService.lua
-- Gère l'état des objectifs séquentiels par joueur pour la mission en cours.
-- Valide les actions :
--   - touch_poi : joueur < 8 studs d'un POI
--   - photo    : joueur touche E à proximité d'un POI
--   - wave     : WaveService a atteint le numéro cible
--   - boss     : un boss a été tué (compteur)
--   - collect  : compte les pickups d'un type (à brancher)
--
-- Push l'état au client via MissionUpdate (liste { id, done }).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes   = require(Shared:WaitForChild("Remotes"))
local Story     = require(Shared:WaitForChild("Story"))

local MissionService = {}

-- État par joueur : [player] = {
--   missionIndex = 1..7,
--   objectives   = { [objId] = true/false },
--   bossKilled   = 0,
-- }
local state = {}
local POI_DETECT_DIST = 10   -- studs

local function getState(player)
	if not state[player] then
		state[player] = {
			missionIndex = 1,
			objectives = {},
			bossKilled = 0,
		}
	end
	return state[player]
end

local function pushUpdate(player)
	local s = getState(player)
	local r = Remotes.Get(Constants.RemoteName.MissionUpdate)
	if r then
		r:FireClient(player, s.missionIndex, s.objectives)
	end
end

local function markDone(player, objId)
	local s = getState(player)
	if not s.objectives[objId] then
		s.objectives[objId] = true
		pushUpdate(player)
		print(("[MissionService] %s : objectif '%s' valide"):format(player.Name, objId))
	end
end

-- Vérifie la complétion globale (tous les objectifs done) → avance mission
local function checkComplete(player)
	local s = getState(player)
	local mission = Story.Missions[s.missionIndex]
	if not mission or not mission.objectives then return end
	local allDone = true
	for _, obj in ipairs(mission.objectives) do
		if not s.objectives[obj.id] then allDone = false; break end
	end
	if allDone then
		-- Avance à la mission suivante
		if s.missionIndex < #Story.Missions then
			s.missionIndex += 1
			s.objectives = {}
			pushUpdate(player)
			print(("[MissionService] %s : mission %d completee, passe a la %d"):format(
				player.Name, s.missionIndex - 1, s.missionIndex))
		end
	end
end

-- ============================================================================
-- API publique
-- ============================================================================

-- Appelé par WaveService quand une vague est nettoyée
function MissionService.OnWaveCleared(waveNumber)
	for player, _ in pairs(state) do
		local mission = Story.Missions[getState(player).missionIndex]
		if mission and mission.objectives then
			for _, obj in ipairs(mission.objectives) do
				if obj.type == "wave" and waveNumber >= obj.target then
					markDone(player, obj.id)
				end
			end
			checkComplete(player)
		end
	end
end

-- Appelé par WaveService quand un boss est tué
function MissionService.OnBossKilled()
	for player, _ in pairs(state) do
		local s = getState(player)
		s.bossKilled = s.bossKilled + 1
		local mission = Story.Missions[s.missionIndex]
		if mission and mission.objectives then
			for _, obj in ipairs(mission.objectives) do
				if obj.type == "boss" and s.bossKilled >= (obj.target or 1) then
					markDone(player, obj.id)
				end
			end
			checkComplete(player)
		end
	end
end

-- Appelé périodiquement pour valider les touch_poi (proximité)
local function checkPoiProximity()
	for _, player in ipairs(Players:GetPlayers()) do
		local char = player.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			local s = getState(player)
			local mission = Story.Missions[s.missionIndex]
			if mission and mission.poi and mission.objectives then
				for _, obj in ipairs(mission.objectives) do
					if obj.type == "touch_poi" and not s.objectives[obj.id] then
						-- Trouve le POI par id
						for _, poi in ipairs(mission.poi) do
							if poi.id == obj.target then
								if (root.Position - poi.pos).Magnitude < POI_DETECT_DIST then
									markDone(player, obj.id)
								end
								break
							end
						end
					end
				end
				checkComplete(player)
			end
		end
	end
end

-- Reçoit une demande client (photo près d'un POI)
local function onClientAction(player, actionType, poiId)
	if actionType ~= "photo" then return end
	local s = getState(player)
	local mission = Story.Missions[s.missionIndex]
	if not mission or not mission.objectives then return end

	-- Vérifie que le joueur est bien près du POI
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local targetPoi
	for _, poi in ipairs(mission.poi or {}) do
		if poi.id == poiId then targetPoi = poi; break end
	end
	if not targetPoi then return end
	if (root.Position - targetPoi.pos).Magnitude > POI_DETECT_DIST + 2 then
		return  -- trop loin, anti-cheat
	end

	-- Marque l'objectif photo correspondant
	for _, obj in ipairs(mission.objectives) do
		if obj.type == "photo" and obj.target == poiId then
			markDone(player, obj.id)
		end
	end
	checkComplete(player)
end

function MissionService.GetCurrentMissionIndex(player)
	return getState(player).missionIndex
end

function MissionService.Init()
	-- Crée Remotes
	local folder = ReplicatedStorage:WaitForChild("Remotes", 10)
	for _, name in ipairs({
		Constants.RemoteName.MissionUpdate,
		Constants.RemoteName.MissionAction,
	}) do
		if not folder:FindFirstChild(name) then
			local r = Instance.new("RemoteEvent")
			r.Name = name
			r.Parent = folder
		end
	end

	-- Écoute des actions client (photo)
	local actionR = folder:WaitForChild(Constants.RemoteName.MissionAction)
	actionR.OnServerEvent:Connect(function(player, actionType, poiId)
		if typeof(actionType) == "string" and typeof(poiId) == "string" then
			onClientAction(player, actionType, poiId)
		end
	end)

	-- Push initial à la connexion
	Players.PlayerAdded:Connect(function(player)
		task.wait(3)  -- laisse le temps au client de se charger
		pushUpdate(player)
	end)
	for _, p in ipairs(Players:GetPlayers()) do
		task.spawn(function() task.wait(2); pushUpdate(p) end)
	end
	Players.PlayerRemoving:Connect(function(player)
		state[player] = nil
	end)

	-- Boucle de proximité (toutes les 0.5s)
	task.spawn(function()
		while true do
			task.wait(0.5)
			checkPoiProximity()
		end
	end)

	print("[MissionService] Pret. Surveille " .. #Story.Missions .. " missions.")
end

return MissionService
