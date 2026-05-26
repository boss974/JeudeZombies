-- CollectionService.lua
-- Service unifié pour les éléments collectionnables :
--   - Souvenirs (reward_item de chaque mission completée)
--   - Photos (chaque touch E sur POI)
--   - Achievements (succès débloqués selon Stats)
--
-- Validation serveur stricte. Persistance via PlayerDataService.Save.
-- Push au client via CollectionUpdate + notification AchievementUnlocked.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants    = require(Shared:WaitForChild("Constants"))
local Remotes      = require(Shared:WaitForChild("Remotes"))
local Story        = require(Shared:WaitForChild("Story"))
local Achievements = require(Shared:WaitForChild("Achievements"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local CollectionService = {}

-- ============================================================================
-- Helpers
-- ============================================================================
local function getData(player)
	return PlayerDataService.Get(player)
end

local function pushUpdate(player)
	local data = getData(player)
	if not data then return end
	local r = Remotes.Get(Constants.RemoteName.CollectionUpdate)
	if r then
		r:FireClient(player, {
			Souvenirs    = data.Souvenirs,
			Photos       = data.Photos,
			Achievements = data.Achievements,
			Stats        = data.Stats,
		})
	end
end

local function notifyAchievement(player, ach)
	local r = Remotes.Get(Constants.RemoteName.AchievementUnlocked)
	if r then r:FireClient(player, ach) end
end

-- ============================================================================
-- Vérification des achievements après chaque action
-- ============================================================================
local function checkAchievements(player)
	local data = getData(player)
	if not data then return end
	local stats = data.Stats

	for id, ach in pairs(Achievements.List) do
		if not data.Achievements[id] then
			local triggered = false
			if ach.trigger == "kill_count"     then triggered = (stats.ZombieKills    >= ach.target)
			elseif ach.trigger == "photo_count"    then triggered = (stats.PhotoCount     >= ach.target)
			elseif ach.trigger == "city_complete"  then triggered = (stats.CityComplete   >= ach.target)
			elseif ach.trigger == "pickup_count"   then triggered = (stats.PickupCount    >= ach.target)
			elseif ach.trigger == "boss_killed"    then triggered = (stats.BossKilled     >= ach.target)
			elseif ach.trigger == "mega_jump"      then triggered = (stats.MegaJumpCount  >= ach.target)
			elseif ach.trigger == "portal_use"     then triggered = (stats.PortalUseCount >= ach.target)
			elseif ach.trigger == "got_hit"        then triggered = (stats.GotHitCount    >= ach.target)
			elseif ach.trigger == "adult_mode_on"  then triggered = data.Settings.AdultModeEnabled == true
			end

			if triggered then
				data.Achievements[id] = true
				notifyAchievement(player, ach)
				print(("[Achievements] %s a debloque '%s' (%s)"):format(
					player.Name, ach.title, ach.tier))
			end
		end
	end

	pushUpdate(player)
	PlayerDataService.Save(player)
end

-- ============================================================================
-- API publique : appelée par d'autres services à chaque action joueur
-- ============================================================================
function CollectionService.OnZombieKilled(player)
	local data = getData(player); if not data then return end
	data.Stats.ZombieKills = data.Stats.ZombieKills + 1
	checkAchievements(player)
end

function CollectionService.OnPhotoTaken(player, poiId, missionId)
	local data = getData(player); if not data then return end
	-- Anti-doublon : on accepte une photo par POI par mission
	local key = (missionId or "?") .. ":" .. poiId
	for _, p in ipairs(data.Photos) do
		if (p.poiId == poiId and p.missionId == missionId) then return end
	end
	table.insert(data.Photos, {
		poiId = poiId,
		missionId = missionId,
		timestamp = os.time(),
	})
	data.Stats.PhotoCount = data.Stats.PhotoCount + 1
	checkAchievements(player)
end

function CollectionService.OnCityComplete(player, missionId)
	local data = getData(player); if not data then return end
	-- Récupère le reward_item depuis Story
	local mission
	for _, m in ipairs(Story.Missions) do
		if m.id == missionId then mission = m; break end
	end
	if not mission then return end

	if mission.reward_item and not data.Souvenirs[mission.reward_item] then
		data.Souvenirs[mission.reward_item] = true
		print(("[CollectionService] %s a gagne '%s'"):format(
			player.Name, mission.reward_item))
	end
	data.Stats.CityComplete = data.Stats.CityComplete + 1
	checkAchievements(player)
end

function CollectionService.OnPickup(player)
	local data = getData(player); if not data then return end
	data.Stats.PickupCount = data.Stats.PickupCount + 1
	checkAchievements(player)
end

function CollectionService.OnBossKilled(player)
	local data = getData(player); if not data then return end
	data.Stats.BossKilled = data.Stats.BossKilled + 1
	checkAchievements(player)
end

function CollectionService.OnMegaJump(player)
	local data = getData(player); if not data then return end
	data.Stats.MegaJumpCount = data.Stats.MegaJumpCount + 1
	checkAchievements(player)
end

function CollectionService.OnPortalUse(player)
	local data = getData(player); if not data then return end
	data.Stats.PortalUseCount = data.Stats.PortalUseCount + 1
	checkAchievements(player)
end

function CollectionService.OnGotHit(player)
	local data = getData(player); if not data then return end
	data.Stats.GotHitCount = data.Stats.GotHitCount + 1
	checkAchievements(player)
end

function CollectionService.OnAdultModeChanged(player)
	-- Trigge le check pour l'achievement "adult_mode"
	checkAchievements(player)
end

function CollectionService.GetSnapshot(player)
	local data = getData(player)
	if not data then return nil end
	return {
		Souvenirs    = data.Souvenirs,
		Photos       = data.Photos,
		Achievements = data.Achievements,
		Stats        = data.Stats,
	}
end

function CollectionService.Init()
	-- Crée Remotes
	local folder = ReplicatedStorage:WaitForChild("Remotes", 10)
	for _, name in ipairs({
		Constants.RemoteName.CollectionUpdate,
		Constants.RemoteName.AchievementUnlocked,
	}) do
		if not folder:FindFirstChild(name) then
			local r = Instance.new("RemoteEvent"); r.Name = name; r.Parent = folder
		end
	end

	-- Push initial à la connexion
	Players.PlayerAdded:Connect(function(player)
		task.wait(4)
		checkAchievements(player)
		pushUpdate(player)
	end)
	for _, p in ipairs(Players:GetPlayers()) do
		task.spawn(function() task.wait(3); checkAchievements(p); pushUpdate(p) end)
	end

	print("[CollectionService] Pret. " .. #Achievements.AllIds() .. " achievements suivis.")
end

return CollectionService
