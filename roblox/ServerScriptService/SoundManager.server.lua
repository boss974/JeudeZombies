-- SoundManager.server.lua
-- Couche audio serveur : crée les Sounds dans SoundService.GameSounds,
-- expose une API globale `_G.SoundManager.Play(name)` et anime un fond sonore
-- avec des grognements zombie périodiques.
--
-- Aucune dépendance d'asset uploadé : que des `rbxasset://sounds/*` builtin.
-- Idempotent : ne recrée pas le dossier ni les sons s'ils existent déjà.

local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

-- ============================================================================
-- CONFIGURATION DES SONS
-- ============================================================================
-- Chaque entrée décrit un Sound à créer dans SoundService.GameSounds.
-- `Looped = true` veut dire ambiance, joué au démarrage.
-- `Looped = false` veut dire effet ponctuel, joué via _G.SoundManager.Play().
local SOUND_DEFS = {
	-- Ambiance loopée
	Cascade = {
		Asset       = "rbxasset://sounds/impact_water.mp3",
		Volume      = 0.4,
		Looped      = true,
		PlayOnStart = true,
	},
	VolcanoRumble = {
		Asset         = "rbxasset://sounds/uuhhh.mp3",
		Volume        = 0.3,
		Looped        = true,
		PlaybackSpeed = 0.4, -- pitché bas → grondement sourd
		PlayOnStart   = true,
	},

	-- Effets one-shot
	ZombieGroan = {
		Asset  = "rbxasset://sounds/uuhhh.mp3",
		Volume = 0.5,
	},
	WaterSplash = {
		Asset  = "rbxasset://sounds/short_falling_into_water.mp3",
		Volume = 0.6,
	},
	Click = {
		Asset  = "rbxasset://sounds/electronicpingshort.wav",
		Volume = 0.3,
	},
	WaveStart = {
		Asset  = "rbxasset://sounds/snap.mp3",
		Volume = 0.5,
	},
	Victory = {
		Asset  = "rbxasset://sounds/action_jump.mp3",
		Volume = 0.7,
	},
}

-- ============================================================================
-- CRÉATION DU DOSSIER ET DES SOUNDS (idempotent)
-- ============================================================================
local function getOrCreateFolder()
	local folder = SoundService:FindFirstChild("GameSounds")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "GameSounds"
		folder.Parent = SoundService
	end
	return folder
end

local soundsFolder = getOrCreateFolder()

local function buildSound(name, def)
	local existing = soundsFolder:FindFirstChild(name)
	if existing then return existing end -- idempotent

	local s = Instance.new("Sound")
	s.Name = name
	s.SoundId = def.Asset
	s.Volume = def.Volume or 0.5
	s.Looped = def.Looped == true
	if def.PlaybackSpeed then
		s.PlaybackSpeed = def.PlaybackSpeed
	end
	s.Parent = soundsFolder
	return s
end

local sounds = {}
for name, def in pairs(SOUND_DEFS) do
	sounds[name] = buildSound(name, def)
end

-- Démarre les loops d'ambiance
for name, def in pairs(SOUND_DEFS) do
	if def.PlayOnStart and not sounds[name].IsPlaying then
		sounds[name]:Play()
	end
end

-- ============================================================================
-- API GLOBALE _G.SoundManager
-- ============================================================================
-- `Play(name)` : joue un one-shot dans SoundService (global, 2D, sans position).
-- `PlayAt(name, position)` : clone le son et le joue à une position monde (3D).
_G.SoundManager = _G.SoundManager or {}

function _G.SoundManager.Play(name)
	local s = sounds[name]
	if not s then
		warn(("[SoundManager] Son inconnu : %s"):format(tostring(name)))
		return
	end
	if s.Looped then
		-- Pour les loopés on ne fait que relancer si jamais arrêté
		if not s.IsPlaying then s:Play() end
	else
		-- One-shot : on relance depuis le début
		s.TimePosition = 0
		s:Play()
	end
end

function _G.SoundManager.PlayAt(name, position)
	local def = SOUND_DEFS[name]
	if not def then
		warn(("[SoundManager] Son inconnu : %s"):format(tostring(name)))
		return
	end
	-- Sound 3D : attaché à une Part invisible temporaire pour avoir l'atténuation
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Transparency = 1
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = position
	part.Parent = Workspace

	local s = Instance.new("Sound")
	s.SoundId = def.Asset
	s.Volume = def.Volume or 0.5
	s.RollOffMode = Enum.RollOffMode.Linear
	s.RollOffMinDistance = 20
	s.RollOffMaxDistance = 200
	s.Parent = part
	s:Play()

	-- Auto-cleanup une fois le son terminé
	s.Ended:Connect(function()
		part:Destroy()
	end)
	-- Sécurité : si Ended ne firé pas, nettoyer après 10s
	task.delay(10, function()
		if part.Parent then part:Destroy() end
	end)
end

-- ============================================================================
-- AMBIANCE ZOMBIE : grognements périodiques sur des zombies vivants
-- ============================================================================
-- Toutes les 5-10 sec, on prend un zombie aléatoire vivant et on joue un
-- ZombieGroan à sa position. Identifie les zombies via l'attribut `ZombieType`.
local function findLivingZombies()
	local zombies = {}
	for _, inst in ipairs(Workspace:GetChildren()) do
		if inst:GetAttribute("ZombieType") then
			local hum = inst:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 and inst.PrimaryPart then
				table.insert(zombies, inst)
			end
		end
	end
	return zombies
end

task.spawn(function()
	while true do
		task.wait(math.random(5, 10))
		local zombies = findLivingZombies()
		if #zombies > 0 then
			local z = zombies[math.random(1, #zombies)]
			_G.SoundManager.PlayAt("ZombieGroan", z.PrimaryPart.Position)
		end
	end
end)

print("[SoundManager] Initialisé. Sons disponibles : "
	.. table.concat({"Cascade","VolcanoRumble","ZombieGroan","WaterSplash","Click","WaveStart","Victory"}, ", "))
