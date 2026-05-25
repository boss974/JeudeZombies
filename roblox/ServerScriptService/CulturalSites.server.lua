-- CulturalSites.server.lua
-- Patrimoine architectural et culturel de La Réunion :
-- - Cases créoles (varangue, toits en pente, lambrequins, couleurs vives)
-- - Boutiques mythiques ("boutik" de quartier en tôle peinte)
-- - Lieux de culte : église catholique, mosquée, temple tamoul (kovil)
-- Les 3 cultures cohabitent à La Réunion : catholique majoritaire,
-- musulmane (~5%), tamoule (~25% de la population a des origines tamoules).
--
-- Style cartoon non-gore (cf. SAFETY_LEGAL_FRAMEWORK.md).

local Workspace = game:GetService("Workspace")

if Workspace:FindFirstChild("CulturalSites") then return end

local root = Instance.new("Folder")
root.Name = "CulturalSites"
root.Parent = Workspace

-- Palette (cf. GAME_KNOWLEDGE §3)
local PALETTE = {
	Fournaise   = Color3.fromRGB(255, 107, 53),
	Flamboyant  = Color3.fromRGB(233,  78, 27),
	Cannelle    = Color3.fromRGB(244, 185, 66),
	Lagon       = Color3.fromRGB(  0, 153, 184),
	Emeraude    = Color3.fromRGB( 28, 139, 62),
	Hibiscus    = Color3.fromRGB(233,  30, 99),
	Lampion     = Color3.fromRGB(255, 230, 160),
	-- Architecture créole
	MurBlanc    = Color3.fromRGB(245, 240, 225),  -- crépi blanc cassé
	MurJaune    = Color3.fromRGB(240, 210, 130),  -- case jaune doré
	MurBleu     = Color3.fromRGB(135, 195, 220),  -- case bleu pastel
	MurVert     = Color3.fromRGB(160, 200, 130),  -- case vert tendre
	MurRose     = Color3.fromRGB(240, 175, 165),  -- case rose pâle
	ToleRouge   = Color3.fromRGB(170,  45,  35),  -- tôle rouille
	ToleBleu    = Color3.fromRGB( 60, 100, 150),  -- tôle bleue
	Bois        = Color3.fromRGB(120,  75,  45),  -- bois clair varangue
	BoisFonce   = Color3.fromRGB( 70,  45,  25),
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

local function makeNameSign(parent, text, anchor, color)
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(8, 0, 1.6, 0)
	bg.StudsOffset = Vector3.new(0, 4, 0)
	bg.AlwaysOnTop = true
	bg.MaxDistance = 200
	bg.Parent = anchor
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundColor3 = color or Color3.fromRGB(40, 25, 20)
	lbl.BackgroundTransparency = 0.2
	lbl.BorderSizePixel = 0
	lbl.TextColor3 = PALETTE.Lampion
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = text
	lbl.Parent = bg
end

-- ============================================================================
-- CASE CRÉOLE — architecture traditionnelle réunionnaise
-- ============================================================================
-- Caractéristiques :
-- - Plan rectangulaire, élevée sur petits pilotis
-- - Toit en pente (2 ou 4 pans) couvert de tôle
-- - Varangue (véranda couverte) à l'avant avec colonnettes en bois
-- - Lambrequins (bandeaux décoratifs dentelés) sous le bord du toit
-- - Couleurs vives sur les murs (jaune, bleu, rose, vert pâle)
-- - Petites fenêtres à persiennes
local function makeCaseCreole(parent, position, rotation, wallColor, roofColor)
	local model = Instance.new("Model")
	model.Name = "CaseCreole"
	model.Parent = parent

	local rot = CFrame.Angles(0, math.rad(rotation or 0), 0)
	local function localPos(x, y, z)
		return position + (rot * Vector3.new(x, y, z))
	end

	-- Pilotis (4 cubes courts)
	for _, p in ipairs({ {-5, 0, -3.5}, {5, 0, -3.5}, {-5, 0, 3.5}, {5, 0, 3.5} }) do
		makePart(model, {
			Name = "Pilotis",
			Size = Vector3.new(0.7, 1.2, 0.7),
			CFrame = CFrame.new(localPos(p[1], 0.6, p[3])) * rot,
			Color = PALETTE.BoisFonce,
			Material = Enum.Material.Wood,
		})
	end

	-- Plancher
	makePart(model, {
		Name = "Floor",
		Size = Vector3.new(12, 0.3, 8),
		CFrame = CFrame.new(localPos(0, 1.35, 0)) * rot,
		Color = PALETTE.Bois,
		Material = Enum.Material.Wood,
	})

	-- 4 murs
	-- Arrière
	makePart(model, {
		Name = "WallBack",
		Size = Vector3.new(12, 4, 0.4),
		CFrame = CFrame.new(localPos(0, 3.5, -3.8)) * rot,
		Color = wallColor,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Avant (au fond de la varangue)
	makePart(model, {
		Name = "WallFront",
		Size = Vector3.new(12, 4, 0.4),
		CFrame = CFrame.new(localPos(0, 3.5, 1.5)) * rot,
		Color = wallColor,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Côté gauche
	makePart(model, {
		Name = "WallLeft",
		Size = Vector3.new(0.4, 4, 8),
		CFrame = CFrame.new(localPos(-6, 3.5, -1.1)) * rot,
		Color = wallColor,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Côté droit
	makePart(model, {
		Name = "WallRight",
		Size = Vector3.new(0.4, 4, 8),
		CFrame = CFrame.new(localPos(6, 3.5, -1.1)) * rot,
		Color = wallColor,
		Material = Enum.Material.SmoothPlastic,
	})

	-- Porte d'entrée (au milieu du mur avant)
	makePart(model, {
		Name = "Door",
		Size = Vector3.new(1.6, 3, 0.5),
		CFrame = CFrame.new(localPos(0, 3, 1.5)) * rot,
		Color = PALETTE.BoisFonce,
		Material = Enum.Material.Wood,
	})

	-- 2 fenêtres à persiennes
	for _, p in ipairs({ {-3, 3.8, 1.3}, {3, 3.8, 1.3} }) do
		makePart(model, {
			Size = Vector3.new(1.5, 1.4, 0.2),
			CFrame = CFrame.new(localPos(p[1], p[2], p[3])) * rot,
			Color = PALETTE.Bois,
			Material = Enum.Material.Wood,
		})
	end

	-- VARANGUE (véranda couverte avant)
	-- Plancher de varangue
	makePart(model, {
		Size = Vector3.new(12, 0.2, 3),
		CFrame = CFrame.new(localPos(0, 1.5, 3)) * rot,
		Color = PALETTE.Bois,
		Material = Enum.Material.Wood,
	})
	-- 4 colonnettes
	for _, p in ipairs({ {-5, 0, 4.3}, {-1.7, 0, 4.3}, {1.7, 0, 4.3}, {5, 0, 4.3} }) do
		makePart(model, {
			Size = Vector3.new(0.4, 4, 0.4),
			CFrame = CFrame.new(localPos(p[1], 3.5, p[3])) * rot,
			Color = PALETTE.Bois,
			Material = Enum.Material.Wood,
		})
	end
	-- Lambrequins (dentelle décorative sous le toit) : suite de petits cubes
	for i = -5, 5, 1 do
		makePart(model, {
			Size = Vector3.new(0.7, 0.7, 0.15),
			CFrame = CFrame.new(localPos(i, 5.4, 4.5)) * rot,
			Color = PALETTE.MurBlanc,
			Material = Enum.Material.SmoothPlastic,
		})
	end

	-- TOIT (2 pans en tôle)
	-- Pan avant (couvre la varangue + l'avant de la case)
	makePart(model, {
		Name = "RoofFront",
		Size = Vector3.new(13, 0.3, 6.5),
		CFrame = CFrame.new(localPos(0, 6.4, 1)) * rot * CFrame.Angles(math.rad(20), 0, 0),
		Color = roofColor,
		Material = Enum.Material.CorrodedMetal,
	})
	-- Pan arrière
	makePart(model, {
		Name = "RoofBack",
		Size = Vector3.new(13, 0.3, 5),
		CFrame = CFrame.new(localPos(0, 6.4, -2)) * rot * CFrame.Angles(math.rad(-20), 0, 0),
		Color = roofColor,
		Material = Enum.Material.CorrodedMetal,
	})
	-- Faîte (sommet du toit)
	makePart(model, {
		Size = Vector3.new(13, 0.3, 0.6),
		CFrame = CFrame.new(localPos(0, 7.2, -0.5)) * rot,
		Color = PALETTE.BoisFonce,
		Material = Enum.Material.Metal,
	})

	return model
end

-- ============================================================================
-- BOUTIK MYTHIQUE (petit commerce de quartier)
-- ============================================================================
-- Caractéristiques :
-- - Petite construction en parpaing avec tôle ondulée colorée
-- - Façade rectangulaire avec grande fenêtre (le comptoir)
-- - Peinte d'une couleur vive
-- - Enseigne peinte à la main au-dessus de la porte
-- - Cageots de fruits/légumes devant
local function makeBoutik(parent, position, name, wallColor, signColor)
	local model = Instance.new("Model")
	model.Name = "Boutik_" .. name
	model.Parent = parent

	-- Structure principale
	makePart(model, {
		Name = "Shop",
		Size = Vector3.new(7, 4.5, 5),
		Position = position + Vector3.new(0, 2.25, 0),
		Color = wallColor,
		Material = Enum.Material.SmoothPlastic,
	})

	-- Toit en tôle ondulée
	makePart(model, {
		Name = "Roof",
		Size = Vector3.new(7.5, 0.25, 5.5),
		Position = position + Vector3.new(0, 4.6, 0),
		Color = PALETTE.ToleRouge,
		Material = Enum.Material.CorrodedMetal,
	})
	-- Avancée du toit pour faire l'auvent
	makePart(model, {
		Size = Vector3.new(7.5, 0.2, 2),
		Position = position + Vector3.new(0, 4.4, 3.3),
		Color = PALETTE.ToleRouge,
		Material = Enum.Material.CorrodedMetal,
		Orientation = Vector3.new(-15, 0, 0),
	})

	-- Grande ouverture-comptoir (l'avant)
	makePart(model, {
		Name = "Counter",
		Size = Vector3.new(5, 1.5, 0.6),
		Position = position + Vector3.new(0, 2.5, 2.7),
		Color = PALETTE.Bois,
		Material = Enum.Material.Wood,
	})
	-- Porte à gauche
	makePart(model, {
		Name = "Door",
		Size = Vector3.new(1.4, 3, 0.4),
		Position = position + Vector3.new(-2.5, 1.5, 2.5),
		Color = PALETTE.BoisFonce,
		Material = Enum.Material.Wood,
	})

	-- Enseigne peinte à la main
	local enseigne = makePart(model, {
		Name = "Sign",
		Size = Vector3.new(6, 1.3, 0.3),
		Position = position + Vector3.new(0, 4.1, 2.55),
		Color = signColor or PALETTE.Cannelle,
		Material = Enum.Material.SmoothPlastic,
	})
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(6, 0, 1.2, 0)
	bg.StudsOffset = Vector3.new(0, 0, 0)
	bg.LightInfluence = 0
	bg.AlwaysOnTop = false
	bg.MaxDistance = 80
	bg.Parent = enseigne
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = PALETTE.BoisFonce
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = name
	lbl.Parent = bg

	-- 3 cageots de fruits devant
	for i = -1, 1 do
		makePart(model, {
			Size = Vector3.new(1.4, 0.8, 1.4),
			Position = position + Vector3.new(i * 1.8, 0.4, 3.8),
			Color = PALETTE.Bois,
			Material = Enum.Material.Wood,
		})
		-- "Fruits" (sphère orange/jaune)
		makePart(model, {
			Size = Vector3.new(1.2, 0.5, 1.2),
			Position = position + Vector3.new(i * 1.8, 0.95, 3.8),
			Color = i == 0 and PALETTE.Fournaise or (i < 0 and PALETTE.Cannelle or PALETTE.Flamboyant),
			Material = Enum.Material.SmoothPlastic,
			Shape = Enum.PartType.Ball,
		})
	end

	-- Petit lampion suspendu à l'auvent
	local lampion = makePart(model, {
		Size = Vector3.new(0.8, 1, 0.8),
		Position = position + Vector3.new(2.5, 3.7, 3.2),
		Color = PALETTE.Lampion,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
		Transparency = 0.15,
	})
	local light = Instance.new("PointLight")
	light.Brightness = 1.2
	light.Range = 12
	light.Color = PALETTE.Lampion
	light.Parent = lampion

	return model
end

-- ============================================================================
-- ÉGLISE catholique (clocher + nef + croix)
-- ============================================================================
local function makeEglise(parent, position)
	local model = Instance.new("Model")
	model.Name = "Eglise"
	model.Parent = parent

	-- Nef principale
	makePart(model, {
		Name = "Nave",
		Size = Vector3.new(10, 6, 16),
		Position = position + Vector3.new(0, 3, 0),
		Color = PALETTE.MurBlanc,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Toit deux pans
	makePart(model, {
		Size = Vector3.new(11, 0.3, 9),
		Position = position + Vector3.new(0, 6.7, 4),
		Orientation = Vector3.new(20, 0, 0),
		Color = PALETTE.ToleRouge,
		Material = Enum.Material.CorrodedMetal,
	})
	makePart(model, {
		Size = Vector3.new(11, 0.3, 9),
		Position = position + Vector3.new(0, 6.7, -4),
		Orientation = Vector3.new(-20, 0, 0),
		Color = PALETTE.ToleRouge,
		Material = Enum.Material.CorrodedMetal,
	})

	-- Clocher (tour à l'avant)
	makePart(model, {
		Name = "Bell_Tower",
		Size = Vector3.new(4, 14, 4),
		Position = position + Vector3.new(0, 7, 9),
		Color = PALETTE.MurBlanc,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Toit pyramidal du clocher (4 parts inclinés)
	for i = 0, 3 do
		makePart(model, {
			Size = Vector3.new(3.5, 0.3, 3.5),
			Position = position + Vector3.new(0, 14.3 + i * 0.4, 9),
			Orientation = Vector3.new(0, i * 90, 0),
			Color = PALETTE.ToleRouge,
			Material = Enum.Material.CorrodedMetal,
			Shape = Enum.PartType.Wedge,
		})
	end
	-- Croix sommitale
	makePart(model, {
		Size = Vector3.new(0.3, 3, 0.3),
		Position = position + Vector3.new(0, 17.2, 9),
		Color = PALETTE.Bois,
		Material = Enum.Material.Wood,
	})
	makePart(model, {
		Size = Vector3.new(1.8, 0.3, 0.3),
		Position = position + Vector3.new(0, 17.3, 9),
		Color = PALETTE.Bois,
		Material = Enum.Material.Wood,
	})

	-- Porte d'entrée
	makePart(model, {
		Size = Vector3.new(2.5, 4, 0.4),
		Position = position + Vector3.new(0, 2, 11),
		Color = PALETTE.BoisFonce,
		Material = Enum.Material.Wood,
	})

	-- 3 vitraux colorés (Neon)
	for i = -1, 1 do
		makePart(model, {
			Size = Vector3.new(0.3, 2.5, 1.2),
			Position = position + Vector3.new(5.1, 4, i * 4),
			Color = i == 0 and PALETTE.Flamboyant or (i < 0 and PALETTE.Lagon or PALETTE.Cannelle),
			Material = Enum.Material.Neon,
			Transparency = 0.2,
		})
		makePart(model, {
			Size = Vector3.new(0.3, 2.5, 1.2),
			Position = position + Vector3.new(-5.1, 4, i * 4),
			Color = i == 0 and PALETTE.Flamboyant or (i < 0 and PALETTE.Lagon or PALETTE.Cannelle),
			Material = Enum.Material.Neon,
			Transparency = 0.2,
		})
	end

	-- Cloche
	makePart(model, {
		Size = Vector3.new(1.5, 1.5, 1.5),
		Position = position + Vector3.new(0, 12, 9),
		Color = Color3.fromRGB(150, 100, 30),
		Material = Enum.Material.Metal,
		Shape = Enum.PartType.Ball,
	})

	-- Panneau nominatif
	makeNameSign(parent, "Église Saint-Denis",
		makePart(parent, {
			Size = Vector3.new(0.1, 0.1, 0.1),
			Position = position + Vector3.new(0, 20, 9),
			Transparency = 1,
			CanCollide = false,
		}),
		PALETTE.Lagon
	)

	return model
end

-- ============================================================================
-- MOSQUÉE (dôme + minaret) — inspirée de Noor-e-Islam à Saint-Denis
-- ============================================================================
local function makeMosquee(parent, position)
	local model = Instance.new("Model")
	model.Name = "Mosquee"
	model.Parent = parent

	-- Salle de prière principale (carré)
	makePart(model, {
		Name = "Hall",
		Size = Vector3.new(14, 6, 14),
		Position = position + Vector3.new(0, 3, 0),
		Color = PALETTE.MurBlanc,
		Material = Enum.Material.SmoothPlastic,
	})

	-- Dôme central (sphère verte)
	makePart(model, {
		Name = "Dome",
		Size = Vector3.new(10, 10, 10),
		Position = position + Vector3.new(0, 8, 0),
		Color = PALETTE.Emeraude,
		Material = Enum.Material.SmoothPlastic,
		Shape = Enum.PartType.Ball,
	})
	-- Crescent (croissant) sur le dôme
	makePart(model, {
		Size = Vector3.new(0.3, 2.5, 0.3),
		Position = position + Vector3.new(0, 14, 0),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
	})
	makePart(model, {
		Size = Vector3.new(1.2, 1.2, 0.4),
		Position = position + Vector3.new(0, 15.5, 0),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Cylinder,
		Orientation = Vector3.new(0, 0, 0),
	})

	-- Minaret (tour mince à droite)
	makePart(model, {
		Name = "Minaret",
		Size = Vector3.new(2.5, 18, 2.5),
		Position = position + Vector3.new(9, 9, 0),
		Color = PALETTE.MurBlanc,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Balcon du muezzin
	makePart(model, {
		Size = Vector3.new(3.5, 0.5, 3.5),
		Position = position + Vector3.new(9, 15, 0),
		Color = PALETTE.MurBlanc,
		Material = Enum.Material.SmoothPlastic,
	})
	-- Petit dôme sommital du minaret
	makePart(model, {
		Size = Vector3.new(2.8, 2.8, 2.8),
		Position = position + Vector3.new(9, 19.5, 0),
		Color = PALETTE.Emeraude,
		Material = Enum.Material.SmoothPlastic,
		Shape = Enum.PartType.Ball,
	})
	-- Crescent du minaret
	makePart(model, {
		Size = Vector3.new(0.25, 1.5, 0.25),
		Position = position + Vector3.new(9, 21.5, 0),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
	})

	-- Porte d'entrée en arche (3 parts)
	makePart(model, {
		Size = Vector3.new(3, 4, 0.4),
		Position = position + Vector3.new(0, 2, 7.2),
		Color = PALETTE.BoisFonce,
		Material = Enum.Material.Wood,
	})
	-- Arc au-dessus de la porte
	makePart(model, {
		Size = Vector3.new(3.6, 0.4, 0.5),
		Position = position + Vector3.new(0, 4.4, 7.2),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
	})

	-- Panneau
	makeNameSign(parent, "Mosquée Noor-e-Islam",
		makePart(parent, {
			Size = Vector3.new(0.1, 0.1, 0.1),
			Position = position + Vector3.new(0, 22, 7),
			Transparency = 1,
			CanCollide = false,
		}),
		PALETTE.Emeraude
	)

	return model
end

-- ============================================================================
-- TEMPLE TAMOUL (Kovil) — inspiré des kovils du Colosse à Saint-André
-- ============================================================================
-- Le gopuram (tour pyramidale) est très coloré, avec étages de statues.
-- On simplifie en 5 étages de cubes colorés.
local function makeTempleTamoul(parent, position)
	local model = Instance.new("Model")
	model.Name = "TempleTamoul"
	model.Parent = parent

	-- Mur d'enceinte (4 segments)
	for _, p in ipairs({
		{0, 0, -10, 24, 0.4, 4},   -- arrière
		{0, 0, 10,  24, 0.4, 4},   -- avant
		{-12, 0, 0, 4, 0.4, 24},   -- gauche
		{12, 0, 0,  4, 0.4, 24},   -- droite
	}) do
		makePart(model, {
			Size = Vector3.new(p[4], 4, p[6]),
			Position = position + Vector3.new(p[1], 2, p[3]),
			Color = PALETTE.MurBlanc,
			Material = Enum.Material.SmoothPlastic,
		})
	end

	-- GOPURAM (tour d'entrée pyramidale)
	-- 5 étages, plus en plus petits, alternant les couleurs vives
	local colors = {
		PALETTE.Flamboyant,   -- rouge
		PALETTE.Cannelle,     -- jaune
		PALETTE.Emeraude,     -- vert
		PALETTE.Lagon,        -- bleu
		PALETTE.Hibiscus,     -- rose
	}
	local gopuramBase = position + Vector3.new(0, 4, 10)
	for i = 0, 4 do
		local size = 7 - i * 1.1
		makePart(model, {
			Size = Vector3.new(size, 2, size * 0.8),
			Position = gopuramBase + Vector3.new(0, i * 2.2, 0),
			Color = colors[(i % #colors) + 1],
			Material = Enum.Material.SmoothPlastic,
		})
		-- Petites "statues" stylisées sur chaque étage (4 boules de la couleur opposée)
		local sx = size * 0.35
		for _, off in ipairs({ {-sx, -sx * 0.8}, {sx, -sx * 0.8}, {-sx, sx * 0.8}, {sx, sx * 0.8} }) do
			makePart(model, {
				Size = Vector3.new(0.8, 1.2, 0.8),
				Position = gopuramBase + Vector3.new(off[1], i * 2.2 + 1.5, off[2]),
				Color = colors[((i + 2) % #colors) + 1],
				Material = Enum.Material.SmoothPlastic,
				Shape = Enum.PartType.Ball,
			})
		end
	end
	-- Couronnement (kalasham) doré
	makePart(model, {
		Size = Vector3.new(1, 3, 1),
		Position = gopuramBase + Vector3.new(0, 13, 0),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
	})
	makePart(model, {
		Size = Vector3.new(2, 1, 2),
		Position = gopuramBase + Vector3.new(0, 15, 0),
		Color = PALETTE.Cannelle,
		Material = Enum.Material.Neon,
		Shape = Enum.PartType.Ball,
	})

	-- Sanctuaire central (petite tour avec dôme blanc)
	makePart(model, {
		Size = Vector3.new(7, 5, 7),
		Position = position + Vector3.new(0, 2.5, -2),
		Color = PALETTE.MurBlanc,
		Material = Enum.Material.SmoothPlastic,
	})
	makePart(model, {
		Size = Vector3.new(5, 5, 5),
		Position = position + Vector3.new(0, 6, -2),
		Color = PALETTE.MurBlanc,
		Material = Enum.Material.SmoothPlastic,
		Shape = Enum.PartType.Ball,
	})

	-- Drapeaux multicolores sur des mâts (typique des temples tamouls)
	for i = -1, 1, 2 do
		makePart(model, {
			Size = Vector3.new(0.2, 8, 0.2),
			Position = position + Vector3.new(i * 5, 4, 5),
			Color = PALETTE.Bois,
			Material = Enum.Material.Wood,
		})
		for j = 0, 3 do
			makePart(model, {
				Size = Vector3.new(0.1, 0.8, 1.2),
				Position = position + Vector3.new(i * 5 + 0.7, 6.5 + j * 0.5, 5),
				Color = colors[(j % #colors) + 1],
				Material = Enum.Material.SmoothPlastic,
			})
		end
	end

	-- Panneau
	makeNameSign(parent, "Temple Tamoul",
		makePart(parent, {
			Size = Vector3.new(0.1, 0.1, 0.1),
			Position = position + Vector3.new(0, 18, 10),
			Transparency = 1,
			CanCollide = false,
		}),
		PALETTE.Flamboyant
	)

	return model
end

-- ============================================================================
-- DÉPLOIEMENT — par ville (cases créoles + boutik) + grandes constructions
-- ============================================================================
local island = Workspace:WaitForChild("ReunionIsland", 10)
if not island then
	warn("[CulturalSites] ReunionIsland introuvable, abandon")
	return
end
local cities = island:FindFirstChild("Cities")
if not cities then
	warn("[CulturalSites] Cities introuvable, abandon")
	return
end

-- Couleurs de cases créoles à varier
local CASE_PALETTES = {
	{ wall = PALETTE.MurJaune, roof = PALETTE.ToleRouge },
	{ wall = PALETTE.MurBleu,  roof = PALETTE.ToleRouge },
	{ wall = PALETTE.MurRose,  roof = PALETTE.ToleBleu },
	{ wall = PALETTE.MurVert,  roof = PALETTE.ToleRouge },
	{ wall = PALETTE.MurBlanc, roof = PALETTE.ToleBleu },
}

-- Noms de boutiks emblématiques (génériques, créatifs)
local BOUTIK_NAMES = {
	"Chez Tantine", "Boutik Aglae", "Lo Marche", "Chez Eli",
	"Boutik Tilamb", "Boutik Mickael", "Chez Mémé", "Aux Pitons",
}

local idx = 0
for _, city in ipairs(cities:GetChildren()) do
	local entrance = city:FindFirstChild("Entrance")
	if entrance then
		idx = idx + 1
		local cityPos = entrance.Position

		-- 2 cases créoles autour de la place (devant et derrière, écartées)
		local p1 = CASE_PALETTES[((idx - 1) % #CASE_PALETTES) + 1]
		local p2 = CASE_PALETTES[(idx % #CASE_PALETTES) + 1]
		makeCaseCreole(root, cityPos + Vector3.new(-18, 0, -15),  20, p1.wall, p1.roof)
		makeCaseCreole(root, cityPos + Vector3.new( 22, 0,  18), -160, p2.wall, p2.roof)

		-- 1 boutik à droite du portail
		local boutikName = BOUTIK_NAMES[((idx - 1) % #BOUTIK_NAMES) + 1]
		local signColor = (idx % 3 == 0) and PALETTE.Hibiscus
			or (idx % 3 == 1) and PALETTE.Cannelle
			or PALETTE.Lagon
		makeBoutik(root, cityPos + Vector3.new(20, 0, -8), boutikName, p1.wall, signColor)
	end
end

-- Grandes constructions : église à Saint-Denis, mosquée à Saint-Denis (Noor-e-Islam),
-- temple tamoul à Saint-André (Le Colosse)
local stDenisCity = cities:FindFirstChild("Saint-Denis")
if stDenisCity and stDenisCity:FindFirstChild("Entrance") then
	makeEglise(root,  stDenisCity.Entrance.Position + Vector3.new(-35, 0,  15))
	makeMosquee(root, stDenisCity.Entrance.Position + Vector3.new( 35, 0,  20))
end

local stAndreCity = cities:FindFirstChild("Saint-Andre")
if stAndreCity and stAndreCity:FindFirstChild("Entrance") then
	makeTempleTamoul(root, stAndreCity.Entrance.Position + Vector3.new(-25, 0, 18))
end

print("[CulturalSites] Patrimoine déployé : cases créoles + boutiks par ville + Église/Mosquée à Saint-Denis + Temple tamoul à Saint-André.")
