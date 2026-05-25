-- TerrainBuilder.server.lua
-- Construit le RELIEF de l'île via Roblox Terrain (heightmap voxel).
-- S'exécute AVANT ReunionMap (qui pose les portails de ville par-dessus).
--
-- Échelle : 1 stud ≈ 80 m. L'île fait 800x640 studs.
-- Les pitons et les cirques sont positionnés à leurs coords GPS approchés.

local Workspace = game:GetService("Workspace")
local terrain = Workspace.Terrain

-- Évite la double exécution si le terrain est déjà sculpté
if Workspace:GetAttribute("ReunionTerrainBuilt") then return end

local Material = Enum.Material

local function fillCylinder(cf, height, radius, material)
	terrain:FillCylinder(cf, height, radius, material)
end

local function fillBlock(cf, size, material)
	terrain:FillBlock(cf, size, material)
end

local function fillBall(center, radius, material)
	terrain:FillBall(center, radius, material)
end

-- ============================================================================
-- 1. MER (énorme bloc d'eau autour de l'île)
-- ============================================================================
fillBlock(
	CFrame.new(0, -5, 0),
	Vector3.new(2400, 12, 1800),
	Material.Water
)

-- ============================================================================
-- 2. PLATEAU DE BASE de l'île (ovale)
-- Astuce : on superpose deux Cylindres orientés pour faire un ovale.
-- Hauteur centrale faible (6 studs) pour laisser la place aux pitons.
-- ============================================================================
local islandLevel = 4  -- altitude du plateau côtier
local islandCenter = Vector3.new(0, islandLevel, 0)

-- Cylindre E-W : 800 long, 480 large
fillCylinder(
	CFrame.new(islandCenter) * CFrame.Angles(0, 0, math.rad(90)),
	800,    -- "height" du cylindre = sa longueur quand couché
	240,    -- rayon (= moitié de la largeur)
	Material.Grass
)
-- Cylindre N-S : 640 long, 600 large, pour arrondir le contour
fillCylinder(
	CFrame.new(islandCenter) * CFrame.Angles(math.rad(90), 0, math.rad(90)),
	640,
	300,
	Material.Grass
)

-- Plage de sable sur le pourtour (anneau abaissé)
fillCylinder(
	CFrame.new(0, islandLevel - 0.5, 0) * CFrame.Angles(0, 0, math.rad(90)),
	820,
	260,
	Material.Sand
)
-- Re-couvre l'intérieur d'herbe : la plage ne reste qu'à la périphérie
fillCylinder(
	CFrame.new(0, islandLevel, 0) * CFrame.Angles(0, 0, math.rad(90)),
	720,
	220,
	Material.Grass
)

-- ============================================================================
-- 3. PITON DES NEIGES (centre, point culminant)
-- ============================================================================
local neigesPos = Vector3.new(-40, 40, -40)
fillBall(neigesPos, 70, Material.Rock)
fillBall(neigesPos + Vector3.new(0, 10, 0), 50, Material.Rock)
fillBall(neigesPos + Vector3.new(0, 20, 0), 35, Material.Snow)
fillBall(neigesPos + Vector3.new(0, 28, 0), 20, Material.Glacier)

-- ============================================================================
-- 4. PITON DE LA FOURNAISE (volcan actif, est)
-- ============================================================================
local fournaisePos = Vector3.new(180, 30, -20)
fillBall(fournaisePos, 60, Material.Basalt)
fillBall(fournaisePos + Vector3.new(0, 8, 0), 45, Material.Basalt)
fillBall(fournaisePos + Vector3.new(0, 16, 0), 30, Material.Rock)
fillBall(fournaisePos + Vector3.new(0, 22, 0), 18, Material.CrackedLava)
-- Cratère : extraction d'un cylindre étroit au sommet
fillCylinder(
	CFrame.new(fournaisePos + Vector3.new(0, 28, 0)) * CFrame.Angles(math.rad(90), 0, 0),
	8,
	8,
	Material.Air
)
-- Coulée de lave dans le cratère (Neon n'existe pas en terrain → on utilise CrackedLava)
fillCylinder(
	CFrame.new(fournaisePos + Vector3.new(0, 22, 0)) * CFrame.Angles(math.rad(90), 0, 0),
	2,
	7,
	Material.CrackedLava
)

-- ============================================================================
-- 5. CIRQUES (creux dans le relief central, accessibles)
-- Mafate, Salazie, Cilaos — extractions d'air dans la montagne centrale
-- ============================================================================
local function carveCirque(pos, radius, depth)
	-- Extrait un dôme inversé : creuse en haut
	fillBall(pos + Vector3.new(0, depth, 0), radius, Material.Air)
	fillBall(pos + Vector3.new(0, depth - 2, 0), radius * 0.7, Material.Air)
	-- Plancher du cirque : herbe humide
	fillCylinder(
		CFrame.new(pos) * CFrame.Angles(0, 0, math.rad(90)),
		2,
		radius * 0.8,
		Material.LeafyGrass
	)
end

carveCirque(Vector3.new( -50, 30,  -10), 28, 18)  -- Cilaos
carveCirque(Vector3.new(   0, 30,  -90), 25, 16)  -- Salazie
carveCirque(Vector3.new(-120, 32,  -70), 22, 14)  -- Mafate

-- ============================================================================
-- 6. ROUTES — légère élévation asphalt sur le pourtour côtier
-- (Décoratif : les portails de ville posent leurs propres routes en Parts)
-- ============================================================================
-- (skip : ReunionMap.server.lua pose déjà les routes en Part par-dessus)

-- ============================================================================
-- 7. FORET sur les plaines (entre les villes)
-- Quelques touches de Material.LeafyGrass pour suggérer les bois
-- ============================================================================
local plaineCafres = Vector3.new(40, islandLevel + 2, 120)
local plainePalmistes = Vector3.new(140, islandLevel + 2, 0)
fillCylinder(
	CFrame.new(plaineCafres) * CFrame.Angles(0, 0, math.rad(90)),
	4,
	35,
	Material.LeafyGrass
)
fillCylinder(
	CFrame.new(plainePalmistes) * CFrame.Angles(0, 0, math.rad(90)),
	4,
	30,
	Material.LeafyGrass
)

-- ============================================================================
-- 8. ATMOSPHÈRE / EAU
-- ============================================================================
terrain.WaterColor = Color3.fromRGB(45, 110, 160)
terrain.WaterTransparency = 0.25
terrain.WaterWaveSize = 0.2
terrain.WaterWaveSpeed = 12

Workspace:SetAttribute("ReunionTerrainBuilt", true)
print("[TerrainBuilder] Relief de l'île construit : mer, plateau, plages, 2 pitons, 3 cirques, plaines.")
