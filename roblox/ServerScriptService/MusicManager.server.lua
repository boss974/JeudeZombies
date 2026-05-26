-- MusicManager.server.lua
-- Couche musicale 2D (non-3D) pour l'ambiance globale.
-- 2 tracks qui se croisent selon l'état :
-- - MusicAmbient : explorer, intermission entre vagues
-- - MusicCombat  : vague active, tension
--
-- Note : Roblox n'expose pas de musique libre via rbxasset://, donc on laisse
-- des SoundId vides ici. Pour avoir de la vraie musique :
-- 1) Upload une musique sur Roblox Creator Hub (audio.upload)
-- 2) Copier l'ID retourné (format rbxassetid://1234567890)
-- 3) Coller dans MUSIC_AMBIENT_ID / MUSIC_COMBAT_ID ci-dessous
--
-- En attendant, on peut tester avec des "audio bruitages" loopés
-- (rbxasset built-ins) — c'est moins beau mais ça marche pour la démo.

local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

-- À remplir avec de vrais assets audio uploadés
local MUSIC_AMBIENT_ID = ""    -- ex: "rbxassetid://9046863579"
local MUSIC_COMBAT_ID  = ""    -- ex: "rbxassetid://1846458016"

-- Fallback "ambient bruitage" : si pas d'asset uploadé, on superpose des
-- sons built-in à très bas volume pour avoir au moins du contenu sonore.
local FALLBACK_AMBIENT = "rbxasset://sounds/uuhhh.mp3"  -- pitch très bas = drone
local FALLBACK_COMBAT  = "rbxasset://sounds/snap.mp3"   -- claqué rythmé

if SoundService:FindFirstChild("MusicLayer") then return end

local container = Instance.new("Folder")
container.Name = "MusicLayer"
container.Parent = SoundService

local function makeMusic(name, assetId, fallback, volume, speed)
	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = (assetId ~= "" and assetId) or fallback
	s.Looped = true
	s.Volume = 0
	s.PlaybackSpeed = speed or 1
	s.Parent = container
	-- Tente de jouer ; si l'asset est invalide, le moteur log mais ça ne crash pas
	s:Play()
	-- Fade-in jusqu'au volume nominal
	TweenService:Create(s, TweenInfo.new(4), { Volume = volume }):Play()
	return s
end

local ambient = makeMusic("MusicAmbient", MUSIC_AMBIENT_ID, FALLBACK_AMBIENT, 0.18, 0.35)
local combat  = makeMusic("MusicCombat",  MUSIC_COMBAT_ID,  FALLBACK_COMBAT,  0.0,  0.8)

-- ============================================================================
-- Cross-fade selon l'état du WaveService
-- Si vague spawning → combat monte, ambient baisse
-- Si intermission → inverse
-- ============================================================================
task.spawn(function()
	local Services = ServerScriptService:WaitForChild("Services")
	local WaveService = require(Services:WaitForChild("WaveService"))
	while true do
		local inCombat = (WaveService.Running and Workspace:FindFirstChild("ReunionIsland")) ~= nil
			and #Workspace:GetDescendants() > 0  -- proxy : zombies présents
		-- Plus simplement : on vise une logique "vague spawning"
		local zombieCount = 0
		for _, c in ipairs(Workspace:GetChildren()) do
			if c:IsA("Model") and c:GetAttribute("ZombieType") then
				zombieCount = zombieCount + 1
			end
		end
		local targetAmbient = (zombieCount < 3) and 0.18 or 0.05
		local targetCombat  = (zombieCount >= 3) and 0.25 or 0
		TweenService:Create(ambient, TweenInfo.new(3), { Volume = targetAmbient }):Play()
		TweenService:Create(combat,  TweenInfo.new(3), { Volume = targetCombat  }):Play()
		task.wait(3)
	end
end)

print("[MusicManager] Tracks Ambient + Combat actives (fallback bruitage si pas d'asset musique uploade).")
