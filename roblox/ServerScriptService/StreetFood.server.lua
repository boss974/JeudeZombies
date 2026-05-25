-- StreetFood.server.lua
-- Stands de street food emblématiques de La Réunion. Anime la map et donne
-- envie au joueur d'explorer entre les vagues.
--
-- Snacks réunionnais culte :
-- - Samoussa (triangle indien frit, communauté musulmane)
-- - Bouchon (raviolis vapeur chinois, communauté hakka)
-- - Carry frites (frites au massalé)
-- - Limonade Royal Bourbon / Cot (boissons locales)
-- - Bonbon piment (beignet pimenté de lentilles)

local Workspace = game:GetService("Workspace")

if Workspace:FindFirstChild("StreetFood") then return end

local root = Instance.new("Folder")
root.Name = "StreetFood"
root.Parent = Workspace

local PALETTE = {
	Lampion     = Color3.fromRGB(255, 230, 160),
	Flamboyant  = Color3.fromRGB(233,  78,  27),
	Cannelle    = Color3.fromRGB(244, 185,  66),
	Emeraude    = Color3.fromRGB( 28, 139,  62),
	Lagon       = Color3.fromRGB(  0, 153, 184),
	Hibiscus    = Color3.fromRGB(233,  30,  99),
	Bois        = Color3.fromRGB(120,  75,  45),
	BoisFonce   = Color3.fromRGB( 70,  45,  25),
	ToleRouge   = Color3.fromRGB(170,  45,  35),
	ToleBleu    = Color3.fromRGB( 60, 100, 150),
	ToleJaune   = Color3.fromRGB(220, 170,  40),
	Samoussa    = Color3.fromRGB(190, 130,  50),   -- doré pâte frite
	Bouchon     = Color3.fromRGB(245, 235, 210),   -- pâte blanche
	Frite       = Color3.fromRGB(230, 200,  90),
	LimonadeBlue = Color3.fromRGB(130, 200, 230),  -- limonade Cot
}

local function makePart(parent, props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent
	return p
end

local function nameSign(parent, anchor, text, bgColor)
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(6, 0, 1.4, 0)
	bg.StudsOffset = Vector3.new(0, 3.5, 0)
	bg.AlwaysOnTop = true
	bg.MaxDistance = 100
	bg.Parent = anchor
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundColor3 = bgColor or PALETTE.Flamboyant
	lbl.BackgroundTransparency = 0.05
	lbl.BorderSizePixel = 0
	lbl.TextColor3 = PALETTE.Lampion
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = text
	lbl.Parent = bg
end

-- ============================================================================
-- STAND GÉNÉRIQUE (chariot avec auvent, comptoir, lampion)
-- ============================================================================
local function makeStand(parent, position, rotation, label, awningColor)
	local model = Instance.new("Model")
	model.Name = "Stand_" .. label
	model.Parent = parent

	local rot = CFrame.Angles(0, math.rad(rotation or 0), 0)
	local function lp(x, y, z)
		return position + (rot * Vector3.new(x, y, z))
	end

	-- 4 roues
	for _, p in ipairs({ {-2, 0, -1.5}, {2, 0, -1.5}, {-2, 0, 1.5}, {2, 0, 1.5} }) do
		makePart(model, {
			Size = Vector3.new(0.6, 0.7, 0.6),
			CFrame = CFrame.new(lp(p[1], 0.35, p[3])) * rot * CFrame.Angles(0, 0, math.rad(90)),
			Color = PALETTE.BoisFonce,
			Material = Enum.Material.Wood,
			Shape = Enum.PartType.Cylinder,
		})
	end

	-- Plancher du chariot
	makePart(model, {
		Size = Vector3.new(5, 0.3, 4),
		CFrame = CFrame.new(lp(0, 0.85, 0)) * rot,
		Color = PALETTE.Bois,
		Material = Enum.Material.Wood,
	})

	-- Caisse arrière (rangement) + comptoir avant
	makePart(model, {
		Size = Vector3.new(5, 1.2, 3),
		CFrame = CFrame.new(lp(0, 1.6, -0.5)) * rot,
		Color = PALETTE.Bois,
		Material = Enum.Material.Wood,
	})
	-- Couvercle / planche comptoir
	makePart(model, {
		Name = "Counter",
		Size = Vector3.new(5.2, 0.2, 3.2),
		CFrame = CFrame.new(lp(0, 2.3, -0.5)) * rot,
		Color = PALETTE.BoisFonce,
		Material = Enum.Material.Wood,
	})

	-- 4 poteaux d'auvent
	for _, p in ipairs({ {-2.4, 0, -1.4}, {2.4, 0, -1.4}, {-2.4, 0, 1.4}, {2.4, 0, 1.4} }) do
		makePart(model, {
			Size = Vector3.new(0.2, 4, 0.2),
			CFrame = CFrame.new(lp(p[1], 4.3, p[3])) * rot,
			Color = PALETTE.BoisFonce,
			Material = Enum.Material.Metal,
		})
	end

	-- Auvent (toit incliné en tôle colorée)
	makePart(model, {
		Size = Vector3.new(5.5, 0.2, 4),
		CFrame = CFrame.new(lp(0, 6.3, 0)) * rot * CFrame.Angles(math.rad(-8), 0, 0),
		Color = awningColor or PALETTE.ToleRouge,
		Material = Enum.Material.CorrodedMetal,
	})
	-- Bande latérale décor
	makePart(model, {
		Size = Vector3.new(5.5, 0.5, 0.2),
		CFrame = CFrame.new(lp(0, 5.5, 2)) * rot,
		Color = PALETTE.Lampion,
		Material = Enum.Material.Neon,
		Transparency = 0.2,
	})

	-- Enseigne nominative
	local enseigne = makePart(model, {
		Name = "SignAnchor",
		Size = Vector3.new(0.1, 0.1, 0.1),
		CFrame = CFrame.new(lp(0, 5.8, 2.1)) * rot,
		Transparency = 1,
		CanCollide = false,
	})
	nameSign(model, enseigne, label, awningColor or PALETTE.Flamboyant)

	-- Lampion lumineux pendu au coin
	local lampion = makePart(model, {
		Size = Vector3.new(0.7, 0.9, 0.7),
		CFrame = CFrame.new(lp(2.4, 5.5, 0)) * rot,
		Color = PALETTE.Lampion,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
		Transparency = 0.15,
	})
	local light = Instance.new("PointLight")
	light.Brightness = 1.5
	light.Range = 16
	light.Color = PALETTE.Lampion
	light.Parent = lampion

	return model
end

-- ============================================================================
-- STAND SAMOUSSA — pyramide dorée sur plat
-- ============================================================================
local function addSamoussaStock(model, position, rotation)
	local rot = CFrame.Angles(0, math.rad(rotation or 0), 0)
	local function lp(x, y, z) return position + (rot * Vector3.new(x, y, z)) end

	-- Grand plat circulaire
	makePart(model, {
		Size = Vector3.new(2.5, 0.15, 2.5),
		CFrame = CFrame.new(lp(0, 2.42, -0.5)) * rot,
		Color = Color3.fromRGB(200, 200, 200),
		Material = Enum.Material.Metal,
		Shape = Enum.PartType.Cylinder,
		Orientation = Vector3.new(0, 0, 90),
	})
	-- Pyramide de samoussas (triangles dorés)
	for layer = 0, 2 do
		local count = 6 - layer * 2
		local r = 0.7 - layer * 0.2
		for i = 0, count - 1 do
			local a = i * math.pi * 2 / count
			makePart(model, {
				Size = Vector3.new(0.5, 0.4, 0.5),
				CFrame = CFrame.new(lp(math.cos(a) * r, 2.7 + layer * 0.35, -0.5 + math.sin(a) * r)) * rot
					* CFrame.Angles(0, a, math.rad(35)),
				Color = PALETTE.Samoussa,
				Material = Enum.Material.SmoothPlastic,
			})
		end
	end
end

-- ============================================================================
-- STAND BOUCHON — empilement de raviolis vapeur
-- ============================================================================
local function addBouchonStock(model, position, rotation)
	local rot = CFrame.Angles(0, math.rad(rotation or 0), 0)
	local function lp(x, y, z) return position + (rot * Vector3.new(x, y, z)) end

	-- 3 paniers vapeur en bambou empilés
	for layer = 0, 2 do
		makePart(model, {
			Size = Vector3.new(2, 0.4, 2),
			CFrame = CFrame.new(lp(0, 2.5 + layer * 0.45, -0.5)) * rot,
			Color = PALETTE.Bois,
			Material = Enum.Material.Wood,
			Shape = Enum.PartType.Cylinder,
			Orientation = Vector3.new(0, 0, 90),
		})
		-- 4 bouchons (petites boules blanches) par panier
		for i = 0, 3 do
			local a = i * math.pi / 2
			makePart(model, {
				Size = Vector3.new(0.45, 0.4, 0.45),
				CFrame = CFrame.new(lp(math.cos(a) * 0.4, 2.55 + layer * 0.45, -0.5 + math.sin(a) * 0.4)) * rot,
				Color = PALETTE.Bouchon,
				Material = Enum.Material.SmoothPlastic,
				Shape = Enum.PartType.Ball,
			})
		end
	end
	-- Vapeur qui monte
	local steamAnchor = makePart(model, {
		Size = Vector3.new(0.1, 0.1, 0.1),
		CFrame = CFrame.new(lp(0, 4.2, -0.5)) * rot,
		Transparency = 1,
		CanCollide = false,
	})
	local steam = Instance.new("ParticleEmitter")
	steam.Texture = "rbxasset://textures/particles/smoke_main.dds"
	steam.Color = ColorSequence.new(Color3.fromRGB(240, 240, 240))
	steam.Size = NumberSequence.new(0.8, 2.5)
	steam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.5),
		NumberSequenceKeypoint.new(1,   1),
	})
	steam.Lifetime = NumberRange.new(1.5, 2.5)
	steam.Rate = 8
	steam.Speed = NumberRange.new(2, 4)
	steam.Acceleration = Vector3.new(0, 3, 0)
	steam.LightEmission = 0.3
	steam.Parent = steamAnchor
end

-- ============================================================================
-- STAND CARRY FRITES — cornet
-- ============================================================================
local function addFritesStock(model, position, rotation)
	local rot = CFrame.Angles(0, math.rad(rotation or 0), 0)
	local function lp(x, y, z) return position + (rot * Vector3.new(x, y, z)) end

	-- Friteuse (cube métal noir)
	makePart(model, {
		Size = Vector3.new(1.5, 0.8, 1.2),
		CFrame = CFrame.new(lp(-1.2, 2.7, -0.5)) * rot,
		Color = Color3.fromRGB(40, 40, 45),
		Material = Enum.Material.Metal,
	})
	-- 3 cornets de frites sur le comptoir
	for i = -1, 1 do
		makePart(model, {
			Size = Vector3.new(0.6, 1.2, 0.6),
			CFrame = CFrame.new(lp(i * 0.9 + 0.5, 3, -0.5)) * rot,
			Color = PALETTE.Bouchon,
			Material = Enum.Material.SmoothPlastic,
			Shape = Enum.PartType.Cylinder,
		})
		-- "Frites" qui dépassent
		for j = -1, 1 do
			makePart(model, {
				Size = Vector3.new(0.1, 0.7, 0.1),
				CFrame = CFrame.new(lp(i * 0.9 + 0.5 + j * 0.1, 3.7, -0.5 + j * 0.1)) * rot,
				Color = PALETTE.Frite,
				Material = Enum.Material.SmoothPlastic,
			})
		end
	end
end

-- ============================================================================
-- STAND LIMONADE — bouteilles colorées
-- ============================================================================
local function addLimonadeStock(model, position, rotation)
	local rot = CFrame.Angles(0, math.rad(rotation or 0), 0)
	local function lp(x, y, z) return position + (rot * Vector3.new(x, y, z)) end

	-- 6 bouteilles alignées (jaune Cot et bleu Bourbon)
	local colors = { PALETTE.Cannelle, PALETTE.LimonadeBlue, PALETTE.Cannelle,
		PALETTE.LimonadeBlue, PALETTE.Hibiscus, PALETTE.Cannelle }
	for i = 1, 6 do
		makePart(model, {
			Size = Vector3.new(0.5, 1.4, 0.5),
			CFrame = CFrame.new(lp(-1.7 + (i - 1) * 0.65, 3.1, -0.5)) * rot,
			Color = colors[i],
			Material = Enum.Material.Glass,
			Transparency = 0.3,
			Shape = Enum.PartType.Cylinder,
		})
		-- Bouchon
		makePart(model, {
			Size = Vector3.new(0.3, 0.2, 0.3),
			CFrame = CFrame.new(lp(-1.7 + (i - 1) * 0.65, 3.85, -0.5)) * rot,
			Color = PALETTE.Flamboyant,
			Material = Enum.Material.SmoothPlastic,
			Shape = Enum.PartType.Cylinder,
		})
	end
	-- Glacière à droite
	makePart(model, {
		Size = Vector3.new(1.4, 1, 1.2),
		CFrame = CFrame.new(lp(1.6, 2.85, -0.5)) * rot,
		Color = PALETTE.Lagon,
		Material = Enum.Material.SmoothPlastic,
	})
end

-- ============================================================================
-- DÉPLOIEMENT par ville
-- ============================================================================
-- Liste tournante des stands à placer
local STAND_TYPES = {
	{ name = "Samoussa",     fill = addSamoussaStock, color = PALETTE.Cannelle },
	{ name = "Bouchon",      fill = addBouchonStock,  color = PALETTE.Flamboyant },
	{ name = "Carry Frites", fill = addFritesStock,   color = PALETTE.ToleRouge },
	{ name = "Limonade Cot", fill = addLimonadeStock, color = PALETTE.Lagon },
}

local island = Workspace:WaitForChild("ReunionIsland", 15)
if not island then
	warn("[StreetFood] ReunionIsland introuvable")
	return
end
local cities = island:FindFirstChild("Cities")
if not cities then
	warn("[StreetFood] Cities introuvable")
	return
end

local idx = 0
for _, city in ipairs(cities:GetChildren()) do
	local entrance = city:FindFirstChild("Entrance")
	if entrance then
		idx = idx + 1
		local cityPos = entrance.Position

		-- 2 stands de types différents par ville (rotation à 2 indices d'écart)
		local s1 = STAND_TYPES[((idx - 1) % #STAND_TYPES) + 1]
		local s2 = STAND_TYPES[(idx % #STAND_TYPES) + 1]

		-- Position 1 : à gauche du portail, face au sud
		local p1 = cityPos + Vector3.new(-22, 0, 5)
		local stand1 = makeStand(root, p1, 0, s1.name, s1.color)
		s1.fill(stand1, p1, 0)

		-- Position 2 : devant, face à l'est
		local p2 = cityPos + Vector3.new(0, 0, 22)
		local stand2 = makeStand(root, p2, 180, s2.name, s2.color)
		s2.fill(stand2, p2, 180)
	end
end

print("[StreetFood] Stands street food déployés : " .. (idx * 2) .. " stands sur " .. idx .. " villes (samoussa, bouchon, carry frites, limonade).")
