-- TerrainBuilder.server.lua
-- Construit le RELIEF de l'île de La Réunion via Roblox Terrain (voxels).
-- S'exécute AVANT ReunionMap (qui pose les portails de ville par-dessus).
--
-- Échelle : 1 stud ≈ 80 m. L'île fait 800x640 studs.
-- Géographie réelle référencée :
-- - 2 pitons centraux (Neiges 3070m, Fournaise 2632m)
-- - 3 cirques (Mafate, Salazie, Cilaos)
-- - 4 rivières principales (Mât, Marsouins, Galets, Saint-Étienne)
-- - Embouchures larges + ravines profondes

local Workspace = game:GetService("Workspace")
local terrain = Workspace.Terrain

if Workspace:GetAttribute("ReunionTerrainBuilt") then return end

-- Nettoie l'ancien terrain pour repartir propre
terrain:Clear()

local Material = Enum.Material

-- ============================================================================
-- 1. MER (énorme bloc d'eau qui couvre TOUTE la zone de jeu)
-- Pas de "vide" possible : on remplit large.
-- ============================================================================
terrain:FillBlock(
	CFrame.new(0, -8, 0),
	Vector3.new(3200, 16, 2400),
	Material.Water
)

-- ============================================================================
-- 2. ÎLE — un seul gros bloc + arrondis aux coins pour éviter les angles secs
-- Position centrée à (0, 0, 0). Hauteur du sol : Y=0 à Y=8.
-- ============================================================================
local islandY = 4
local islandSize = Vector3.new(780, 8, 620)
terrain:FillBlock(
	CFrame.new(0, islandY, 0),
	islandSize,
	Material.Grass
)

-- Arrondis aux 4 coins (boules de Grass qui dépassent légèrement)
local cornerRadius = 90
for _, pos in ipairs({
	Vector3.new( 380, islandY, -300),
	Vector3.new( 380, islandY,  300),
	Vector3.new(-380, islandY, -300),
	Vector3.new(-380, islandY,  300),
}) do
	terrain:FillBall(pos, cornerRadius, Material.Grass)
end

-- Pourtour côtier en sable (anneau de Sand sur 30 studs d'épaisseur)
local function ringSand(cf, sizeX, sizeZ)
	-- 4 bandes Sand qui forment un cadre
	terrain:FillBlock(cf * CFrame.new(0, 0, sizeZ / 2 - 15), Vector3.new(sizeX, 9, 30), Material.Sand)
	terrain:FillBlock(cf * CFrame.new(0, 0, -sizeZ / 2 + 15), Vector3.new(sizeX, 9, 30), Material.Sand)
	terrain:FillBlock(cf * CFrame.new( sizeX / 2 - 15, 0, 0), Vector3.new(30, 9, sizeZ), Material.Sand)
	terrain:FillBlock(cf * CFrame.new(-sizeX / 2 + 15, 0, 0), Vector3.new(30, 9, sizeZ), Material.Sand)
end
ringSand(CFrame.new(0, islandY, 0), 800, 640)

-- ============================================================================
-- 3. PITON DES NEIGES (centre, 3070 m, éteint, recouvert de neige au sommet)
-- ============================================================================
local neigesPos = Vector3.new(-40, 30, -40)
terrain:FillBall(neigesPos, 75, Material.Rock)
terrain:FillBall(neigesPos + Vector3.new(0,  8, 0), 60, Material.Rock)
terrain:FillBall(neigesPos + Vector3.new(0, 16, 0), 45, Material.Rock)
terrain:FillBall(neigesPos + Vector3.new(0, 24, 0), 32, Material.Snow)
terrain:FillBall(neigesPos + Vector3.new(0, 32, 0), 20, Material.Glacier)

-- ============================================================================
-- 4. PITON DE LA FOURNAISE (volcan actif, 2632 m, côté est)
-- ============================================================================
local fournaisePos = Vector3.new(180, 25, -20)
terrain:FillBall(fournaisePos, 65, Material.Basalt)
terrain:FillBall(fournaisePos + Vector3.new(0,  8, 0), 50, Material.Basalt)
terrain:FillBall(fournaisePos + Vector3.new(0, 16, 0), 36, Material.Rock)
terrain:FillBall(fournaisePos + Vector3.new(0, 22, 0), 22, Material.CrackedLava)
-- Cratère : extraction d'air au sommet
terrain:FillCylinder(
	CFrame.new(fournaisePos + Vector3.new(0, 28, 0)),
	14, 12, Material.Air
)
-- Plancher du cratère en lave
terrain:FillCylinder(
	CFrame.new(fournaisePos + Vector3.new(0, 22, 0)),
	2, 11, Material.CrackedLava
)

-- ============================================================================
-- 5. CIRQUES (3 creux profonds dans la montagne centrale)
-- ============================================================================
local function carveCirque(pos, radius, depth)
	-- Creuse une demi-sphère vers le haut (le cirque est ouvert sur le ciel)
	terrain:FillBall(pos + Vector3.new(0, depth * 0.6, 0), radius, Material.Air)
	-- Plancher du cirque (LeafyGrass = vert humide)
	terrain:FillCylinder(
		CFrame.new(pos + Vector3.new(0, depth * 0.2, 0)),
		3, radius * 0.8, Material.LeafyGrass
	)
end

local cirques = {
	{ name = "Cilaos",  pos = Vector3.new( -50, 28,  -10), radius = 32, depth = 20 },
	{ name = "Salazie", pos = Vector3.new(   0, 28,  -90), radius = 28, depth = 18 },
	{ name = "Mafate",  pos = Vector3.new(-120, 30,  -70), radius = 26, depth = 16 },
}
for _, c in ipairs(cirques) do carveCirque(c.pos, c.radius, c.depth) end

-- ============================================================================
-- 6. RIVIÈRES — gravures sinueuses depuis les pitons jusqu'à la mer
-- Les 4 principales de La Réunion :
-- - Rivière du Mât (Salazie → Saint-André, côte est-nord)
-- - Rivière des Marsouins (Plaine-des-Palmistes → Saint-Benoît, est)
-- - Rivière des Galets (Mafate → Le Port, ouest-nord)
-- - Rivière Saint-Étienne (Cilaos → Saint-Louis, sud)
-- Méthode : segments courts de FillCylinder Air pour creuser + Water
-- pour remplir le fond.
-- ============================================================================
local function carveRiver(points, width)
	for i = 1, #points - 1 do
		local p1 = points[i]
		local p2 = points[i + 1]
		local mid = (p1 + p2) / 2
		local dx = p2.X - p1.X
		local dz = p2.Z - p1.Z
		local length = math.sqrt(dx * dx + dz * dz)
		local angle = math.atan2(dx, dz)
		-- Creuse l'air (canyon)
		terrain:FillBlock(
			CFrame.new(mid + Vector3.new(0, 2, 0)) * CFrame.Angles(0, angle, 0),
			Vector3.new(width, 10, length + 2),
			Material.Air
		)
		-- Remplit d'eau au fond
		terrain:FillBlock(
			CFrame.new(mid + Vector3.new(0, -1, 0)) * CFrame.Angles(0, angle, 0),
			Vector3.new(width * 0.7, 4, length + 2),
			Material.Water
		)
		-- Berges sablo-rocheuses
		terrain:FillBlock(
			CFrame.new(mid + Vector3.new(0, 1, 0)) * CFrame.Angles(0, angle, 0),
			Vector3.new(width + 4, 2, length + 2),
			Material.Sandstone
		)
	end
end

-- Rivière du Mât (Salazie → Saint-André) — direction NE depuis le cirque
carveRiver({
	Vector3.new(   0, 6, -90),
	Vector3.new(  60, 6, -120),
	Vector3.new( 120, 6, -150),
	Vector3.new( 180, 6, -190),  -- embouchure
}, 12)

-- Rivière des Marsouins (Plaine-des-Palmistes → Saint-Benoît) — direction E
carveRiver({
	Vector3.new(  140, 6,   0),
	Vector3.new(  200, 6, -30),
	Vector3.new(  260, 6, -60),
	Vector3.new(  300, 6, -85),  -- embouchure
}, 10)

-- Rivière des Galets (Mafate → Le Port) — direction NW
carveRiver({
	Vector3.new(-120, 6,  -70),
	Vector3.new(-150, 6, -120),
	Vector3.new(-160, 6, -170),
	Vector3.new(-160, 6, -220),  -- embouchure Le Port
}, 14)

-- Rivière Saint-Étienne (Cilaos → Saint-Louis) — direction S
carveRiver({
	Vector3.new( -50, 6,  -10),
	Vector3.new( -70, 6,   50),
	Vector3.new( -85, 6,  120),
	Vector3.new(-100, 6,  200),  -- embouchure Saint-Louis
}, 13)

-- ============================================================================
-- 7. EMBOUCHURES — élargissement à la côte (lagunes triangulaires Water)
-- ============================================================================
local function makeEmbouchure(pos, radius)
	terrain:FillBall(pos, radius, Material.Air)
	terrain:FillBall(pos - Vector3.new(0, radius - 4, 0), radius * 0.8, Material.Water)
end
makeEmbouchure(Vector3.new( 180, 5, -200), 18)  -- St-André (Mât)
makeEmbouchure(Vector3.new( 300, 5,  -85), 16)  -- St-Benoît (Marsouins)
makeEmbouchure(Vector3.new(-160, 5, -230), 18)  -- Le Port (Galets)
makeEmbouchure(Vector3.new(-100, 5,  210), 16)  -- St-Louis (Saint-Étienne)

-- ============================================================================
-- 8. FORÊT — touches de LeafyGrass sur plaines centrales
-- ============================================================================
local plaineCafres    = Vector3.new( 40, islandY + 2, 120)
local plainePalmistes = Vector3.new(140, islandY + 2,   0)
terrain:FillBall(plaineCafres,    40, Material.LeafyGrass)
terrain:FillBall(plainePalmistes, 35, Material.LeafyGrass)

-- ============================================================================
-- 9. EAU — paramètres visuels océan
-- ============================================================================
terrain.WaterColor = Color3.fromRGB(45, 110, 160)
terrain.WaterTransparency = 0.25
terrain.WaterWaveSize = 0.25
terrain.WaterWaveSpeed = 12

Workspace:SetAttribute("ReunionTerrainBuilt", true)
print("[TerrainBuilder] Île reconstruite : mer continue 3200x2400, île 780x620, 2 pitons, 3 cirques, 4 rivières (Mât, Marsouins, Galets, St-Étienne), 4 embouchures, plages sable continue.")
