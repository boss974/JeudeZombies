-- ReunionMap.server.lua
-- Construit une carte stylisée de l'île de La Réunion à l'échelle Roblox.
-- Échelle : 1 stud = ~80 m. L'île fait ~63 km E-W => ~800 studs.
-- Style : cartoon apocalypse, non-gore (cf. SAFETY_LEGAL_FRAMEWORK.md).

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Story = require(Shared:WaitForChild("Story"))

-- Empêche la double exécution si ArenaBuilder existe déjà
if Workspace:FindFirstChild("ReunionIsland") then return end

local function makePart(parent, name, props)
	local p = Instance.new("Part")
	p.Name = name
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent
	return p
end

local function nameSign(parent, name, lore, height)
	-- Panneau flottant avec nom + lore au-dessus
	local bg = Instance.new("BillboardGui")
	bg.Name = "NameTag"
	bg.Size = UDim2.new(14, 0, 3.2, 0)
	bg.StudsOffset = Vector3.new(0, height or 12, 0)
	bg.AlwaysOnTop = true
	bg.MaxDistance = 350
	bg.Parent = parent

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 0.25
	container.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	container.BorderSizePixel = 0
	container.Parent = bg
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 6); corner.Parent = container
	local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(180, 90, 50); stroke.Thickness = 1; stroke.Parent = container

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -8, 0.45, 0)
	nameLbl.Position = UDim2.new(0, 4, 0, 2)
	nameLbl.BackgroundTransparency = 1
	nameLbl.TextColor3 = Color3.fromRGB(255, 235, 100)
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextScaled = true
	nameLbl.Text = name
	nameLbl.Parent = container

	if lore then
		local loreLbl = Instance.new("TextLabel")
		loreLbl.Size = UDim2.new(1, -8, 0.55, -4)
		loreLbl.Position = UDim2.new(0, 4, 0.45, 0)
		loreLbl.BackgroundTransparency = 1
		loreLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
		loreLbl.Font = Enum.Font.Gotham
		loreLbl.TextWrapped = true
		loreLbl.TextSize = 14
		loreLbl.TextYAlignment = Enum.TextYAlignment.Top
		loreLbl.Text = lore
		loreLbl.Parent = container
	end
end

-- ============================================================================
-- ROOT
-- ============================================================================
local root = Instance.new("Folder")
root.Name = "ReunionIsland"
root.Parent = Workspace

-- NOTE : la mer, l'île, les pitons et les cirques sont sculptés en
-- Roblox Terrain par TerrainBuilder.server.lua qui s'exécute en parallèle.
-- Ce script ne pose plus que les éléments "objet" (portails, panneaux,
-- routes, lumières).

-- Glow lumineux au cratère du Piton de la Fournaise (le terrain CrackedLava
-- ne suffit pas à donner l'effet néon orange)
makePart(root, "FournaiseGlow", {
	Size = Vector3.new(14, 2, 14),
	Position = Vector3.new(180, 58, -20),
	Anchored = true,
	CanCollide = false,
	BrickColor = BrickColor.new("Neon orange"),
	Material = Enum.Material.Neon,
	Shape = Enum.PartType.Cylinder,
	Orientation = Vector3.new(0, 0, 90),
	Transparency = 0.2,
})
-- PointLight au cratère (lumière + son volcan plus tard)
do
	local light = Instance.new("PointLight")
	light.Brightness = 5
	light.Range = 60
	light.Color = Color3.fromRGB(255, 120, 40)
	light.Parent = root.FournaiseGlow
end

-- ============================================================================
-- VILLES (24 communes) — coords approximatives selon position GPS réelle
-- Conversion : centre île = (0,0), x positif = Est, z positif = Sud
-- ============================================================================
local CITIES = {
	-- Nord
	{ name = "Saint-Denis",        pos = Vector3.new(  20, 8, -260), color = "Bright yellow" },
	{ name = "Sainte-Marie",       pos = Vector3.new(  70, 8, -250), color = "Bright yellow" },
	{ name = "Sainte-Suzanne",     pos = Vector3.new( 130, 8, -230), color = "Bright yellow" },
	-- Est
	{ name = "Saint-Andre",        pos = Vector3.new( 190, 8, -180), color = "Bright orange" },
	{ name = "Bras-Panon",         pos = Vector3.new( 230, 8, -130), color = "Bright orange" },
	{ name = "Saint-Benoit",       pos = Vector3.new( 280, 8,  -80), color = "Bright orange" },
	{ name = "Sainte-Rose",        pos = Vector3.new( 300, 8,   40), color = "Bright orange" },
	-- Sud-Est et sud
	{ name = "Saint-Philippe",     pos = Vector3.new( 230, 8,  170), color = "Bright red" },
	{ name = "Saint-Joseph",       pos = Vector3.new( 130, 8,  230), color = "Bright red" },
	{ name = "Petite-Ile",         pos = Vector3.new(  70, 8,  240), color = "Bright red" },
	{ name = "Saint-Pierre",       pos = Vector3.new(   0, 8,  240), color = "Bright red" },
	{ name = "Le Tampon",          pos = Vector3.new( -10, 8,  170), color = "Bright red" },
	{ name = "Entre-Deux",         pos = Vector3.new( -70, 8,  130), color = "Bright red" },
	{ name = "Saint-Louis",        pos = Vector3.new( -90, 8,  210), color = "Bright red" },
	-- Sud-Ouest
	{ name = "L'Etang-Sale",       pos = Vector3.new(-160, 8,  170), color = "Lavender" },
	{ name = "Les Avirons",        pos = Vector3.new(-210, 8,  130), color = "Lavender" },
	-- Ouest
	{ name = "Saint-Leu",          pos = Vector3.new(-270, 8,   60), color = "Pastel blue" },
	{ name = "Trois-Bassins",      pos = Vector3.new(-260, 8,    0), color = "Pastel blue" },
	{ name = "Saint-Paul",         pos = Vector3.new(-260, 8,  -90), color = "Pastel blue" },
	{ name = "La Possession",      pos = Vector3.new(-180, 8, -190), color = "Pastel blue" },
	{ name = "Le Port",            pos = Vector3.new(-150, 8, -220), color = "Pastel blue" },
	-- Cirques (intérieur, en altitude)
	{ name = "Cilaos",             pos = Vector3.new( -50, 38,  -10), color = "White" },
	{ name = "Salazie",            pos = Vector3.new(   0, 38,  -90), color = "White" },
	{ name = "Mafate",             pos = Vector3.new(-120, 38,  -70), color = "White" },
	-- Plaines (axe Nord-Sud central)
	{ name = "Plaine-des-Cafres",  pos = Vector3.new(  40, 28,  120), color = "Cool yellow" },
	{ name = "Plaine-des-Palmistes", pos = Vector3.new(140, 28,    0), color = "Cool yellow" },
}

local citiesFolder = Instance.new("Folder")
citiesFolder.Name = "Cities"
citiesFolder.Parent = root

for _, city in ipairs(CITIES) do
	local cityModel = Instance.new("Model")
	cityModel.Name = city.name
	cityModel.Parent = citiesFolder

	-- Plateforme d'entrée
	local base = makePart(cityModel, "Entrance", {
		Size = Vector3.new(14, 1, 14),
		Position = city.pos,
		Anchored = true,
		BrickColor = BrickColor.new(city.color),
		Material = Enum.Material.SmoothPlastic,
		TopSurface = Enum.SurfaceType.Smooth,
	})

	-- Portail (2 piliers + linteau)
	local pillarSize = Vector3.new(1.5, 6, 1.5)
	makePart(cityModel, "PillarL", {
		Size = pillarSize,
		Position = city.pos + Vector3.new(-4, 3, 0),
		Anchored = true,
		BrickColor = BrickColor.new("Dark stone grey"),
		Material = Enum.Material.Marble,
	})
	makePart(cityModel, "PillarR", {
		Size = pillarSize,
		Position = city.pos + Vector3.new( 4, 3, 0),
		Anchored = true,
		BrickColor = BrickColor.new("Dark stone grey"),
		Material = Enum.Material.Marble,
	})
	makePart(cityModel, "Lintel", {
		Size = Vector3.new(10, 1, 1.5),
		Position = city.pos + Vector3.new(0, 6.5, 0),
		Anchored = true,
		BrickColor = BrickColor.new(city.color),
		Material = Enum.Material.Neon,
	})

	-- Lumière la nuit
	local light = Instance.new("PointLight")
	light.Brightness = 2
	light.Range = 25
	light.Color = Color3.fromRGB(255, 230, 140)
	light.Parent = base

	-- Panneau nominatif + lore
	nameSign(base, city.name, Story.CityLore[city.name], 8)

	-- Marqueur pour les services
	cityModel:SetAttribute("CityName", city.name)
end

-- ============================================================================
-- ROUTES (axes principaux : RN1 côtière + RN3 cirques)
-- ============================================================================
local roadsFolder = Instance.new("Folder")
roadsFolder.Name = "Roads"
roadsFolder.Parent = root

local function makeRoad(name, p1, p2, width)
	local dx = p2.X - p1.X
	local dz = p2.Z - p1.Z
	local length = math.sqrt(dx*dx + dz*dz)
	local mid = (p1 + p2) / 2
	local angle = math.deg(math.atan2(dx, dz))
	makePart(roadsFolder, name, {
		Size = Vector3.new(width or 6, 0.3, length),
		Position = Vector3.new(mid.X, 7.2, mid.Z),
		Orientation = Vector3.new(0, angle, 0),
		Anchored = true,
		BrickColor = BrickColor.new("Dark stone grey"),
		Material = Enum.Material.Asphalt,
		TopSurface = Enum.SurfaceType.Smooth,
	})
end

-- Route du littoral (RN1 + RN2) : suit les villes côtières
local coastalLoop = {
	Vector3.new(  20, 0, -260), Vector3.new( 130, 0, -230), Vector3.new( 280, 0, -80),
	Vector3.new( 300, 0,  40),  Vector3.new( 230, 0, 170),  Vector3.new( 130, 0, 230),
	Vector3.new(   0, 0, 240),  Vector3.new( -90, 0, 210),  Vector3.new(-210, 0, 130),
	Vector3.new(-270, 0,  60),  Vector3.new(-260, 0, -90),  Vector3.new(-150, 0, -220),
	Vector3.new(  20, 0, -260),
}
for i = 1, #coastalLoop - 1 do
	makeRoad("Coastal_" .. i, coastalLoop[i], coastalLoop[i + 1], 6)
end

-- ============================================================================
-- SPAWN JOUEUR (Saint-Denis, préfecture - point de départ de l'histoire)
-- ============================================================================
local playerSpawn = Instance.new("SpawnLocation")
playerSpawn.Name = "PlayerSpawn"
playerSpawn.Size = Vector3.new(10, 1, 10)
playerSpawn.Position = Vector3.new(20, 8.5, -260)
playerSpawn.Anchored = true
playerSpawn.BrickColor = BrickColor.new("Bright blue")
playerSpawn.Material = Enum.Material.Neon
playerSpawn.TopSurface = Enum.SurfaceType.Smooth
playerSpawn.Parent = Workspace

-- ============================================================================
-- ZOMBIE SPAWN POINTS (côtes - les zombies arrivent de la mer)
-- ============================================================================
local arena = Workspace:FindFirstChild("Arena") or Instance.new("Folder")
arena.Name = "Arena"
arena.Parent = Workspace

local zombieSpawns = arena:FindFirstChild("ZombieSpawns") or Instance.new("Folder")
zombieSpawns.Name = "ZombieSpawns"
zombieSpawns.Parent = arena

-- Cleanup anciens spawns (du builder précédent)
for _, c in ipairs(zombieSpawns:GetChildren()) do c:Destroy() end

-- 16 points côtiers répartis SUR LA PLAGE (sable, Y=10).
-- Avant : Y=5 et X/Z trop loin → zombies tombaient dans la mer.
-- Maintenant : sur le sable (Y=10 > terrain sand à Y=3.5), à l'intérieur
-- du périmètre île (rayon ~280-300 studs) pour qu'ils marchent réellement.
local coastalSpawns = {
	-- Nord (côte de Saint-Denis / Sainte-Marie)
	Vector3.new(  20, 10, -295),
	Vector3.new( 120, 10, -285),
	Vector3.new(-100, 10, -280),
	-- Est (côte Saint-Benoît / Sainte-Rose)
	Vector3.new( 340, 10, -130),
	Vector3.new( 360, 10,   30),
	Vector3.new( 320, 10,  150),
	-- Sud (Saint-Pierre / Saint-Joseph)
	Vector3.new( 130, 10,  275),
	Vector3.new(   0, 10,  290),
	Vector3.new(-130, 10,  270),
	-- Ouest (Saint-Leu / Saint-Paul)
	Vector3.new(-310, 10,  130),
	Vector3.new(-360, 10,    0),
	Vector3.new(-330, 10, -130),
	-- Nord-Ouest (Le Port / La Possession)
	Vector3.new(-200, 10, -260),
}

for i, pos in ipairs(coastalSpawns) do
	makePart(zombieSpawns, "CoastSpawn" .. i, {
		Size = Vector3.new(4, 0.5, 4),
		Position = pos,
		Anchored = true,
		CanCollide = false,
		Transparency = 0.5,
		BrickColor = BrickColor.new("Really red"),
		Material = Enum.Material.Neon,
	})
end

-- ============================================================================
-- AMBIANCE
-- ============================================================================
local lighting = game:GetService("Lighting")
lighting.ClockTime = 5.5         -- Aube apocalyptique
lighting.FogColor = Color3.fromRGB(180, 100, 80)
lighting.FogStart = 200
lighting.FogEnd = 800
lighting.Ambient = Color3.fromRGB(80, 60, 70)
lighting.OutdoorAmbient = Color3.fromRGB(120, 90, 80)

-- Atmosphère post-apocalyptique
local atmo = lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmo.Density = 0.4
atmo.Offset = 0.25
atmo.Color = Color3.fromRGB(200, 170, 150)
atmo.Decay = Color3.fromRGB(106, 112, 125)
atmo.Glare = 0
atmo.Haze = 1.5
atmo.Parent = lighting

print(("[ReunionMap] Carte construite : %d villes, %d spawns côtiers, 2 pitons, 1 océan"):format(#CITIES, #coastalSpawns))
