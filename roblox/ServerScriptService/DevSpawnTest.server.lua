-- DevSpawnTest.server.lua
-- Script de DEBUG : spawn 5 zombies VISIBLES juste à côté du joueur dès qu'il
-- arrive, et affiche un HUD de diagnostic (vague courante, nb zombies actifs).
-- Utile quand WaveService est silencieux ou que les spawn points sont
-- mal positionnés.
--
-- Pour le désactiver : renommer ce fichier en *.server.disabled ou commenter
-- les `task.spawn` ci-dessous.

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Services = ServerScriptService:WaitForChild("Services")
local ZombieService = require(Services:WaitForChild("ZombieService"))
local WaveService   = require(Services:WaitForChild("WaveService"))

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

-- ============================================================================
-- 1) HUD DEBUG (visible à l'écran, top-right)
-- ============================================================================
local function buildDebugGui(player)
	local pg = player:WaitForChild("PlayerGui", 5)
	if not pg or pg:FindFirstChild("DevDebug") then return end

	local screen = Instance.new("ScreenGui")
	screen.Name = "DevDebug"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.Parent = pg

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 70)
	frame.Position = UDim2.new(1, -280, 0, 90)
	frame.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.Parent = screen
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 60, 30)
	stroke.Thickness = 2
	stroke.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 0, 22)
	title.Position = UDim2.new(0, 8, 0, 4)
	title.BackgroundTransparency = 1
	title.Text = "🧟 ZOMBIES DEBUG"
	title.TextColor3 = Color3.fromRGB(255, 200, 100)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local stats = Instance.new("TextLabel")
	stats.Name = "Stats"
	stats.Size = UDim2.new(1, -16, 0, 40)
	stats.Position = UDim2.new(0, 8, 0, 26)
	stats.BackgroundTransparency = 1
	stats.Text = "Vague : 0 | Actifs : 0"
	stats.TextColor3 = Color3.fromRGB(255, 255, 255)
	stats.Font = Enum.Font.GothamMedium
	stats.TextSize = 14
	stats.TextXAlignment = Enum.TextXAlignment.Left
	stats.TextYAlignment = Enum.TextYAlignment.Top
	stats.Parent = frame

	-- Boucle de mise à jour côté serveur via RemoteEvent
	-- (en serveur uniquement, on update via attribute)
	task.spawn(function()
		while screen.Parent and player.Parent do
			task.wait(0.5)
			stats.Text = string.format(
				"Vague : %d  |  Actifs : %d\nRunning : %s",
				WaveService.Wave or 0,
				ZombieService.GetActiveCount(),
				tostring(WaveService.Running)
			)
		end
	end)
end

-- ============================================================================
-- 2) SPAWN IMMÉDIAT à côté du joueur (5 zombies de test)
-- ============================================================================
local function spawnTestZombiesNear(player)
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart", 5)
	if not root then return end

	-- Crée 5 zombies en cercle autour du joueur, à 20 studs
	for i = 1, 5 do
		local angle = (i - 1) * (math.pi * 2 / 5)
		local offset = Vector3.new(math.cos(angle) * 20, 2, math.sin(angle) * 20)
		local pos = root.Position + offset

		-- Détourne temporairement Arena.ZombieSpawns pour forcer la position
		local arena = Workspace:FindFirstChild("Arena")
		if not arena then
			arena = Instance.new("Folder")
			arena.Name = "Arena"
			arena.Parent = Workspace
		end
		local spawns = arena:FindFirstChild("ZombieSpawns")
		if not spawns then
			spawns = Instance.new("Folder")
			spawns.Name = "ZombieSpawns"
			spawns.Parent = arena
		end
		local tempMarker = Instance.new("Part")
		tempMarker.Name = "TestMarker"
		tempMarker.Anchored = true
		tempMarker.CanCollide = false
		tempMarker.Transparency = 1
		tempMarker.Position = pos
		tempMarker.Parent = spawns

		-- Spawn
		ZombieService.Spawn(Constants.ZombieType.Normal)

		-- Retire le marker temporaire après usage
		task.delay(0.5, function()
			if tempMarker then tempMarker:Destroy() end
		end)

		task.wait(0.3)
	end
end

-- ============================================================================
-- 3) FORCER WaveService.Start (au cas où GameController est silencieux)
-- ============================================================================
Players.PlayerAdded:Connect(function(player)
	buildDebugGui(player)

	task.wait(3)  -- laisse le temps au character de spawn
	print("[DevSpawnTest] Spawn de 5 zombies de test près de " .. player.Name)
	spawnTestZombiesNear(player)

	-- Force démarrage des vagues si pas déjà parti
	if not WaveService.Running then
		print("[DevSpawnTest] WaveService.Start() forcé")
		WaveService.Start()
	end
end)

-- Aussi pour les joueurs déjà présents au lancement
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		buildDebugGui(p)
		task.wait(3)
		spawnTestZombiesNear(p)
		if not WaveService.Running then WaveService.Start() end
	end)
end

print("[DevSpawnTest] Pret. Les zombies vont apparaitre 3s apres l'arrivee du joueur.")
