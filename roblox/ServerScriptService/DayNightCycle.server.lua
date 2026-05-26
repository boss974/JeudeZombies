-- DayNightCycle.server.lua
-- Cycle jour/nuit dynamique : 6 minutes = 24h en jeu.
-- Module-clé pour l'ambiance : zombies plus dangereux la nuit.
-- - 06h-18h : jour (ClockTime augmente, fog clair)
-- - 18h-22h : crépuscule (fog orange, brightness baisse)
-- - 22h-06h : nuit (fog sombre, brightness minimal, ambiance lugubre)

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

if Workspace:GetAttribute("DayNightActive") then return end
Workspace:SetAttribute("DayNightActive", true)

-- Durée totale d'un cycle en secondes (1 jour réel = 6 minutes virtuelles)
local CYCLE_SECONDS = 360
local SECONDS_PER_HOUR = CYCLE_SECONDS / 24

-- Heure de démarrage (5h30, l'aube apocalyptique de l'intro)
Lighting.ClockTime = 5.5
local lastUpdate = tick()

-- Atmosphere (déjà créée par ReunionMap, on la réutilise / met à jour)
local atmo = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmo.Parent = Lighting

-- Couleurs par phase (sur cycle 24h)
local function colorForHour(h)
	-- 0-5 : nuit profonde
	-- 5-7 : aube
	-- 7-17 : plein jour
	-- 17-19 : crépuscule
	-- 19-24 : nuit
	if h < 5 then
		return {
			fog = Color3.fromRGB(20, 15, 25),
			ambient = Color3.fromRGB(30, 25, 35),
			outdoor = Color3.fromRGB(60, 50, 70),
			haze = 3.0,
		}
	elseif h < 7 then
		-- aube (5→7) : orange volcanique
		local t = (h - 5) / 2
		return {
			fog = Color3.fromRGB(20 + 180 * t, 15 + 80 * t, 25 + 60 * t),
			ambient = Color3.fromRGB(30 + 90 * t, 25 + 70 * t, 35 + 60 * t),
			outdoor = Color3.fromRGB(60 + 160 * t, 50 + 110 * t, 70 + 70 * t),
			haze = 3.0 - 2 * t,
		}
	elseif h < 17 then
		-- jour : ciel clair, atmosphère légère
		return {
			fog = Color3.fromRGB(200, 220, 235),
			ambient = Color3.fromRGB(130, 130, 140),
			outdoor = Color3.fromRGB(220, 215, 200),
			haze = 0.8,
		}
	elseif h < 19 then
		-- crépuscule (17→19) : couché de soleil orange
		local t = (h - 17) / 2
		return {
			fog = Color3.fromRGB(200 - 80 * t, 220 - 130 * t, 235 - 180 * t),
			ambient = Color3.fromRGB(130 - 60 * t, 130 - 70 * t, 140 - 80 * t),
			outdoor = Color3.fromRGB(220 + 20 * t, 215 - 65 * t, 200 - 110 * t),
			haze = 0.8 + 0.8 * t,
		}
	else
		-- nuit : 19→24
		local t = (h - 19) / 5
		return {
			fog = Color3.fromRGB(120 - 100 * t, 90 - 75 * t, 55 - 30 * t),
			ambient = Color3.fromRGB(70 - 40 * t, 60 - 35 * t, 60 - 25 * t),
			outdoor = Color3.fromRGB(240 - 180 * t, 150 - 100 * t, 90 - 30 * t),
			haze = 1.6 + 1.4 * t,
		}
	end
end

-- Boucle d'update via Heartbeat
RunService.Heartbeat:Connect(function()
	local now = tick()
	local dt = now - lastUpdate
	lastUpdate = now

	-- Avance d'heure proportionnelle au temps réel
	local hoursPerSec = 24 / CYCLE_SECONDS
	Lighting.ClockTime = (Lighting.ClockTime + hoursPerSec * dt) % 24

	-- Mise à jour couleurs (échantillon léger, pas chaque frame critique)
	local h = Lighting.ClockTime
	local c = colorForHour(h)
	Lighting.FogColor = c.fog
	Lighting.Ambient = c.ambient
	Lighting.OutdoorAmbient = c.outdoor
	atmo.Haze = c.haze

	-- Brightness baisse la nuit
	if h < 5 or h > 20 then
		Lighting.Brightness = 0.5
	elseif h > 17 then
		Lighting.Brightness = 1.5
	else
		Lighting.Brightness = 2.0
	end
end)

-- Multiplicateur de zombies la nuit (consommé par WaveService si présent)
task.spawn(function()
	while true do
		local h = Lighting.ClockTime
		local isNight = (h < 6 or h > 19)
		Workspace:SetAttribute("IsNight", isNight)
		task.wait(2)
	end
end)

print("[DayNightCycle] Cycle 24h sur " .. CYCLE_SECONDS .. "s. Demarrage a 5h30 (aube apocalyptique).")
