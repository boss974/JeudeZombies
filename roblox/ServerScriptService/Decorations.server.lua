-- Decorations.server.lua
-- Ajoute la vie tropicale de La Réunion sur l'île : palmiers côtiers,
-- flamboyants intérieurs, hibiscus aux portails, lampions, drapeaux,
-- cendres volcaniques. Palette officielle Réunion (cf. GAME_KNOWLEDGE.md §3).

local Workspace = game:GetService("Workspace")

if Workspace:FindFirstChild("Decorations") then return end

-- ============================================================================
-- PALETTE RÉUNION (Color3) — référence canonique
-- ============================================================================
local PALETTE = {
	Fournaise   = Color3.fromRGB(255, 107, 53),   -- Orange volcan
	Flamboyant  = Color3.fromRGB(233,  78, 27),   -- Rouge drapeau
	Cannelle    = Color3.fromRGB(244, 185, 66),   -- Jaune drapeau / soleil
	Lagon       = Color3.fromRGB(  0, 153, 184),  -- Bleu drapeau / océan
	Emeraude    = Color3.fromRGB( 28, 139, 62),   -- Vert tropical
	Hibiscus    = Color3.fromRGB(233,  30, 99),   -- Rose hibiscus
	Lampion     = Color3.fromRGB(255, 230, 160),  -- Or chaud
	SableNoir   = Color3.fromRGB( 45,  45, 45),   -- Plage volcanique
	-- Bois et organique
	Tronc       = Color3.fromRGB( 78,  52, 32),   -- Brun palmier
	Feuilles    = Color3.fromRGB( 50, 130, 50),   -- Vert feuille
	FeuillesC   = Color3.fromRGB( 80, 160, 60),   -- Vert clair
}

local root = Instance.new("Folder")
root.Name = "Decorations"
root.Parent = Workspace

local function makePart(parent, props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent
	return p
end

-- ============================================================================
-- PALMIER (tronc + couronne de feuilles)
-- ============================================================================
local function makePalmTree(parent, position, scale)
	scale = scale or 1
	local model = Instance.new("Model")
	model.Name = "PalmTree"
	model.Parent = parent

	-- Tronc légèrement incliné (effet vent), 3 segments pour suggérer la courbe
	local height = 14 * scale
	local trunkRadius = 0.6 * scale
	for i = 1, 3 do
		local segH = height / 3
		local tilt = math.rad((i - 2) * 4)  -- légère inclinaison alternée
		makePart(model, {
			Name = "Trunk" .. i,
			Size = Vector3.new(trunkRadius * 2, segH, trunkRadius * 2),
			CFrame = CFrame.new(position + Vector3.new(0, segH * (i - 0.5), 0)) * CFrame.Angles(tilt, 0, tilt * 0.5),
			Color = PALETTE.Tronc,
			Material = Enum.Material.Wood,
			Shape = Enum.PartType.Cylinder,
			Orientation = Vector3.new(0, 0, 90),
		})
	end

	-- Couronne : sphère verte centrale + 6 "feuilles" cylindriques rayonnantes
	local topY = position.Y + height
	makePart(model, {
		Name = "Crown",
		Size = Vector3.new(2 * scale, 1.5 * scale, 2 * scale),
		Position = Vector3.new(position.X, topY, position.Z),
		Color = PALETTE.Feuilles,
		Material = Enum.Material.Grass,
		Shape = Enum.PartType.Ball,
	})
	for i = 1, 6 do
		local angle = (i - 1) * math.pi * 2 / 6
		local dx = math.cos(angle) * 2.5 * scale
		local dz = math.sin(angle) * 2.5 * scale
		makePart(model, {
			Name = "Leaf" .. i,
			Size = Vector3.new(5 * scale, 0.4 * scale, 1.6 * scale),
			CFrame = CFrame.new(position.X + dx, topY + 0.5 * scale, position.Z + dz)
				* CFrame.Angles(0, angle, math.rad(-15)),
			Color = i % 2 == 0 and PALETTE.Feuilles or PALETTE.FeuillesC,
			Material = Enum.Material.LeafyGrass,
		})
	end

	-- 3 cocos jaunes sous la couronne
	for i = 1, 3 do
		local angle = (i - 1) * math.pi * 2 / 3 + math.rad(30)
		makePart(model, {
			Name = "Coconut" .. i,
			Size = Vector3.new(0.9 * scale, 0.9 * scale, 0.9 * scale),
			Position = Vector3.new(
				position.X + math.cos(angle) * 0.8 * scale,
				topY - 0.4 * scale,
				position.Z + math.sin(angle) * 0.8 * scale
			),
			Color = PALETTE.Cannelle,
			Material = Enum.Material.Sand,
			Shape = Enum.PartType.Ball,
		})
	end

	return model
end

-- ============================================================================
-- FLAMBOYANT (arbre à fleurs rouges)
-- ============================================================================
local function makeFlamboyant(parent, position)
	local model = Instance.new("Model")
	model.Name = "Flamboyant"
	model.Parent = parent

	-- Tronc épais court
	makePart(model, {
		Name = "Trunk",
		Size = Vector3.new(1.6, 8, 1.6),
		Position = position + Vector3.new(0, 4, 0),
		Color = PALETTE.Tronc,
		Material = Enum.Material.Wood,
		Shape = Enum.PartType.Cylinder,
		Orientation = Vector3.new(0, 0, 90),
	})

	-- Couronne large étalée — 5 boules rouge orangé
	local topY = position.Y + 9
	local positions = {
		{ 0, 0.5, 0, 4.5 },
		{ 3, 0,   2, 3 },
		{-3, 0,   2, 3 },
		{ 2, 0,  -3, 3 },
		{-2, 0,  -2.5, 3 },
	}
	for _, p in ipairs(positions) do
		makePart(model, {
			Name = "Bloom",
			Size = Vector3.new(p[4], p[4], p[4]),
			Position = Vector3.new(position.X + p[1], topY + p[2], position.Z + p[3]),
			Color = PALETTE.Flamboyant,
			Material = Enum.Material.Neon,
			Shape = Enum.PartType.Ball,
			Transparency = 0.05,
		})
	end

	return model
end

-- ============================================================================
-- HIBISCUS (sphère rose)
-- ============================================================================
local function makeHibiscus(parent, position)
	local model = Instance.new("Model")
	model.Name = "Hibiscus"
	model.Parent = parent

	-- Tige courte verte
	makePart(model, {
		Size = Vector3.new(0.2, 1.5, 0.2),
		Position = position + Vector3.new(0, 0.75, 0),
		Color = PALETTE.Emeraude,
		Material = Enum.Material.Grass,
	})

	-- 5 pétales (sphères roses) en cercle
	for i = 1, 5 do
		local angle = (i - 1) * math.pi * 2 / 5
		makePart(model, {
			Size = Vector3.new(0.7, 0.4, 0.7),
			Position = Vector3.new(
				position.X + math.cos(angle) * 0.5,
				position.Y + 1.6,
				position.Z + math.sin(angle) * 0.5
			),
			Color = PALETTE.Hibiscus,
			Material = Enum.Material.Neon,
			Shape = Enum.PartType.Ball,
			Transparency = 0.1,
		})
	end

	-- Cœur jaune
	makePart(model, {
		Size = Vector3.new(0.4, 0.4, 0.4),
		Position = Vector3.new(position.X, position.Y + 1.7, position.Z),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
	})

	return model
end

-- ============================================================================
-- LAMPION (sphère lumineuse or chaud)
-- ============================================================================
local function makeLampion(parent, position)
	local lampion = makePart(parent, {
		Name = "Lampion",
		Size = Vector3.new(1.4, 1.6, 1.4),
		Position = position,
		Color = PALETTE.Lampion,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
		Transparency = 0.1,
	})
	-- Fil au-dessus
	makePart(parent, {
		Size = Vector3.new(0.1, 1, 0.1),
		Position = position + Vector3.new(0, 1.3, 0),
		Color = Color3.fromRGB(60, 60, 60),
		Material = Enum.Material.Metal,
	})
	local light = Instance.new("PointLight")
	light.Brightness = 1.5
	light.Range = 18
	light.Color = PALETTE.Lampion
	light.Parent = lampion
	return lampion
end

-- ============================================================================
-- DRAPEAU "Volcan rayonnant" (drapeau non officiel mais reconnu de La Réunion)
-- Composition stylisée : fond bleu lagon + triangles rouges sur côtés
-- + soleil jaune au centre
-- ============================================================================
local function makeFlag(parent, position, height)
	height = height or 7
	local model = Instance.new("Model")
	model.Name = "DrapeauReunion"
	model.Parent = parent

	-- Mât (gris)
	makePart(model, {
		Name = "Mast",
		Size = Vector3.new(0.25, height, 0.25),
		Position = position + Vector3.new(0, height / 2, 0),
		Color = Color3.fromRGB(80, 80, 80),
		Material = Enum.Material.Metal,
	})

	-- Drapeau : 1 Part fond bleu (5 wide x 3 tall x 0.15)
	local flagBase = makePart(model, {
		Name = "FlagBlue",
		Size = Vector3.new(0.15, 2.8, 4.5),
		Position = position + Vector3.new(0, height - 1.7, 2.3),
		Color = PALETTE.Lagon,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Triangles rouges (haut-gauche, haut-droit, bas-centre)
	makePart(model, {
		Size = Vector3.new(0.18, 1.3, 1.6),
		CFrame = CFrame.new(position.X, position.Y + height - 0.7, position.Z + 0.9)
			* CFrame.Angles(math.rad(20), 0, 0),
		Color = PALETTE.Flamboyant,
		Material = Enum.Material.SmoothPlastic,
	})
	makePart(model, {
		Size = Vector3.new(0.18, 1.3, 1.6),
		CFrame = CFrame.new(position.X, position.Y + height - 0.7, position.Z + 3.6)
			* CFrame.Angles(math.rad(-20), 0, 0),
		Color = PALETTE.Flamboyant,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Soleil jaune au centre (sphère)
	makePart(model, {
		Size = Vector3.new(0.3, 1.2, 1.2),
		Position = position + Vector3.new(0, height - 1.5, 2.3),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
	})

	return model
end

-- ============================================================================
-- DÉCORS AUX PORTAILS DE VILLE (lampions + hibiscus + drapeau)
-- ============================================================================
local function decorateCity(cityModel)
	local entrance = cityModel:FindFirstChild("Entrance")
	if not entrance then return end
	local pos = entrance.Position

	-- Drapeau à droite du portail
	makeFlag(root, pos + Vector3.new(8, 1, 0))

	-- 2 lampions de chaque côté
	makeLampion(root, pos + Vector3.new(-5, 8, -2))
	makeLampion(root, pos + Vector3.new( 5, 8, -2))

	-- Hibiscus aux 4 coins de la plateforme
	makeHibiscus(root, pos + Vector3.new(-6,  0.5,  6))
	makeHibiscus(root, pos + Vector3.new( 6,  0.5,  6))
	makeHibiscus(root, pos + Vector3.new(-6,  0.5, -6))
	makeHibiscus(root, pos + Vector3.new( 6,  0.5, -6))
end

-- Récupère les villes depuis ReunionIsland (créé par ReunionMap)
local island = Workspace:WaitForChild("ReunionIsland", 10)
if island then
	local cities = island:FindFirstChild("Cities")
	if cities then
		for _, city in ipairs(cities:GetChildren()) do
			decorateCity(city)
		end
	end
end

-- ============================================================================
-- PALMIERS sur le pourtour côtier (anneau)
-- ============================================================================
local palmCount = 40
for i = 1, palmCount do
	local angle = (i - 1) * math.pi * 2 / palmCount
	local rx = math.cos(angle) * 360  -- juste à l'intérieur de la plage
	local rz = math.sin(angle) * 280
	-- Skip si ça tombe sur une ville (heuristique : check distance approximative)
	local p = Vector3.new(rx, 6, rz)
	makePalmTree(root, p, 0.85 + math.random() * 0.3)
end

-- ============================================================================
-- FLAMBOYANTS dans l'intérieur de l'île (entre les villes)
-- ============================================================================
local flamboyantPositions = {
	Vector3.new( 100, 6,  -180),  -- entre St-André et St-Benoit
	Vector3.new( 220, 6,   80),   -- vers Plaine-des-Palmistes
	Vector3.new(  60, 6,  170),   -- entre Le Tampon et Plaine-des-Cafres
	Vector3.new(-100, 6,  120),   -- vers Entre-Deux
	Vector3.new(-180, 6,    0),   -- vers Trois-Bassins
	Vector3.new(-100, 6, -130),   -- vers Possession
	Vector3.new(  90, 6, -160),   -- entre St-André et Bras-Panon
	Vector3.new(   0, 6,   80),   -- centre île
	Vector3.new(  40, 6, -100),   -- vers Salazie
}
for _, pos in ipairs(flamboyantPositions) do
	makeFlamboyant(root, pos)
end

-- ============================================================================
-- PARTICULES CENDRE autour du Piton de la Fournaise
-- ============================================================================
local cinderAnchor = makePart(root, {
	Name = "CinderAnchor",
	Size = Vector3.new(40, 1, 40),
	Position = Vector3.new(180, 65, -20),
	Transparency = 1,
})

local cinder = Instance.new("ParticleEmitter")
cinder.Name = "VolcanoCinder"
cinder.Texture = "rbxasset://textures/particles/sparkles_main.dds"
cinder.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, PALETTE.Cannelle),
	ColorSequenceKeypoint.new(0.5, PALETTE.Fournaise),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 30, 30)),
})
cinder.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 2),
	NumberSequenceKeypoint.new(1, 0.4),
})
cinder.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.2),
	NumberSequenceKeypoint.new(0.7, 0.5),
	NumberSequenceKeypoint.new(1, 1),
})
cinder.Lifetime = NumberRange.new(4, 8)
cinder.Rate = 25
cinder.Speed = NumberRange.new(6, 12)
cinder.SpreadAngle = Vector2.new(180, 180)
cinder.Acceleration = Vector3.new(2, -2, 1)  -- léger vent vers l'est
cinder.LightEmission = 0.4
cinder.Rotation = NumberRange.new(0, 360)
cinder.RotSpeed = NumberRange.new(-30, 30)
cinder.Parent = cinderAnchor

-- ============================================================================
-- SOLEIL/LUNE — disque jaune en arrière-plan (effet de soleil rougeoyant)
-- Le Lighting.ClockTime gère déjà l'astre principal, on ajoute un halo statique
-- ============================================================================
makePart(root, {
	Name = "SunHalo",
	Size = Vector3.new(40, 40, 1),
	Position = Vector3.new(-400, 80, -300),
	Color = PALETTE.Fournaise,
	Material = Enum.Material.Neon,
	Shape = Enum.PartType.Ball,
	Transparency = 0.5,
})

print("[Decorations] Île tropicale habillée : " .. palmCount .. " palmiers, " ..
	#flamboyantPositions .. " flamboyants, lampions + drapeaux + hibiscus + cendre volcanique.")
