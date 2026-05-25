-- SoundClient.client.lua
-- Configuration audio côté client : règles 3D globales et expose une API
-- locale pour jouer des sons UI sans réplication serveur inutile.
--
-- Sons UI = locaux : pas la peine de passer par un Remote.
-- Tous les sons utilisent uniquement `rbxasset://sounds/*` (builtin Roblox).

local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- ============================================================================
-- CONFIG 3D GLOBALE
-- ============================================================================
-- RollOff Linear avec atténuation entre 20 et 200 studs : les zombies au loin
-- restent audibles mais discrets ; les éléments proches dominent.
SoundService.RespectFilteringEnabled = true

-- ============================================================================
-- SONS UI LOCAUX
-- ============================================================================
local UI_SOUND_DEFS = {
	-- Validation de menu (clic "Commencer")
	Button = {
		Asset  = "rbxasset://sounds/button.wav",
		Volume = 0.4,
	},
	-- Apparition d'une ligne de dialogue
	DialogTick = {
		Asset  = "rbxasset://sounds/clickfast.wav",
		Volume = 0.25,
	},
	-- Petit ping notification
	Ping = {
		Asset  = "rbxasset://sounds/electronicpingshort.wav",
		Volume = 0.3,
	},
	-- Skip dialogue
	Skip = {
		Asset  = "rbxasset://sounds/action_jump.mp3",
		Volume = 0.4,
	},
}

-- On range les sons UI dans le PlayerGui pour qu'ils suivent le client
local pg = player:WaitForChild("PlayerGui")
local uiFolder = pg:FindFirstChild("UISounds")
if not uiFolder then
	uiFolder = Instance.new("Folder")
	uiFolder.Name = "UISounds"
	uiFolder.Parent = pg
end

local uiSounds = {}
for name, def in pairs(UI_SOUND_DEFS) do
	local existing = uiFolder:FindFirstChild(name)
	if existing then
		uiSounds[name] = existing
	else
		local s = Instance.new("Sound")
		s.Name = name
		s.SoundId = def.Asset
		s.Volume = def.Volume or 0.5
		s.Parent = uiFolder
		uiSounds[name] = s
	end
end

-- ============================================================================
-- API LOCALE _G.UISound — accessible aux autres LocalScripts (StoryUI, etc.)
-- ============================================================================
-- On expose une API locale pour que StoryUI.client.lua puisse jouer le clic
-- du bouton "Commencer" et le tick des dialogues sans recharger sa propre
-- liste de sons.
_G.UISound = _G.UISound or {}

function _G.UISound.Play(name)
	local s = uiSounds[name]
	if not s then
		warn(("[SoundClient] Son UI inconnu : %s"):format(tostring(name)))
		return
	end
	s.TimePosition = 0
	s:Play()
end

print("[SoundClient] UI sounds initialisés : "
	.. table.concat({"Button","DialogTick","Ping","Skip"}, ", "))
