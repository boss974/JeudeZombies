-- SettingsService.lua
-- Gère les paramètres par joueur :
-- - Pseudo (string)
-- - Date de naissance (JJ/MM/AAAA)
-- - Mode adulte ENABLED par joueur (autorisé si âge >= 18)
-- Validation serveur : âge >= 13 obligatoire pour jouer.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes   = require(Shared:WaitForChild("Remotes"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))

local SettingsService = {}

local MIN_AGE_TO_PLAY  = 13
local MIN_AGE_ADULT    = 18

-- Parse "DD/MM/YYYY" → calculate age. Retourne age ou nil si invalide.
local function calcAge(birthDate)
	if type(birthDate) ~= "string" then return nil end
	local d, m, y = birthDate:match("^(%d%d?)/(%d%d?)/(%d%d%d%d)$")
	d = tonumber(d); m = tonumber(m); y = tonumber(y)
	if not d or not m or not y then return nil end
	if d < 1 or d > 31 or m < 1 or m > 12 then return nil end
	if y < 1920 or y > 2030 then return nil end

	-- Calcul âge à partir de la date actuelle
	local now = os.date("*t")
	local age = now.year - y
	if (now.month < m) or (now.month == m and now.day < d) then
		age = age - 1
	end
	if age < 0 then return nil end
	return age
end

-- Sanitize pseudo : 2-20 chars, alphanum + - _ espace
local function sanitizePseudo(s)
	if type(s) ~= "string" then return nil end
	s = s:gsub("^%s+", ""):gsub("%s+$", "")  -- trim
	if #s < 2 or #s > 20 then return nil end
	if not s:match("^[%w_%- ]+$") then return nil end
	return s
end

-- ============================================================================
-- API
-- ============================================================================
function SettingsService.Get(player)
	local data = PlayerDataService.Get(player)
	return data and data.Settings
end

function SettingsService.Save(player, payload)
	local data = PlayerDataService.Get(player)
	if not data then return false, "no data" end

	local pseudo = sanitizePseudo(payload.Pseudo or "")
	if not pseudo then return false, "Pseudo invalide (2-20 caractères, lettres/chiffres/-_ uniquement)" end

	local age = calcAge(payload.BirthDate)
	if not age then return false, "Date de naissance invalide (format JJ/MM/AAAA)" end
	if age < MIN_AGE_TO_PLAY then
		return false, string.format("Tu dois avoir %d ans ou plus pour jouer.", MIN_AGE_TO_PLAY)
	end

	-- Mode adulte : autorisé seulement si âge >= 18 ET joueur a coché
	local wantAdult = (payload.AdultModeEnabled == true)
	local adultAllowed = (age >= MIN_AGE_ADULT)
	local adultModeFinal = wantAdult and adultAllowed

	data.Settings.HasCompletedSetup = true
	data.Settings.Pseudo            = pseudo
	data.Settings.BirthDate         = payload.BirthDate
	data.Settings.Age               = age
	data.Settings.AdultModeEnabled  = adultModeFinal

	PlayerDataService.Save(player)

	-- Push back au client
	local r = Remotes.Get(Constants.RemoteName.SettingsUpdate)
	if r then r:FireClient(player, data.Settings) end

	return true, "Paramètres enregistrés", data.Settings
end

function SettingsService.IsAdultMode(player)
	local s = SettingsService.Get(player)
	return s and s.AdultModeEnabled == true
end

function SettingsService.Init()
	-- Crée les Remotes
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder"); folder.Name = "Remotes"; folder.Parent = ReplicatedStorage
	end
	for _, name in ipairs({
		Constants.RemoteName.SaveSettings,
		Constants.RemoteName.GetSettings,
		Constants.RemoteName.SettingsUpdate,
	}) do
		if not folder:FindFirstChild(name) then
			local r = Instance.new("RemoteEvent")
			r.Name = name
			r.Parent = folder
		end
	end

	local saveR = folder:FindFirstChild(Constants.RemoteName.SaveSettings)
	saveR.OnServerEvent:Connect(function(player, payload)
		if typeof(payload) ~= "table" then return end
		local ok, msg, settings = SettingsService.Save(player, payload)
		-- Réponse via SettingsUpdate (réutilise le même canal)
		local updR = folder:FindFirstChild(Constants.RemoteName.SettingsUpdate)
		if updR then updR:FireClient(player, settings or {}, ok, msg) end
	end)

	local getR = folder:FindFirstChild(Constants.RemoteName.GetSettings)
	getR.OnServerEvent:Connect(function(player)
		local s = SettingsService.Get(player) or {}
		local updR = folder:FindFirstChild(Constants.RemoteName.SettingsUpdate)
		if updR then updR:FireClient(player, s, true, "ok") end
	end)

	-- Au join : push automatique des settings courants
	Players.PlayerAdded:Connect(function(player)
		task.wait(2)
		local s = SettingsService.Get(player) or {}
		local updR = folder:FindFirstChild(Constants.RemoteName.SettingsUpdate)
		if updR then updR:FireClient(player, s, true, "init") end
	end)
end

return SettingsService
