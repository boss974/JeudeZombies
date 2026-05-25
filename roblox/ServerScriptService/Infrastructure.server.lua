-- Infrastructure.server.lua
-- Patrimoine routier emblématique de La Réunion :
-- - Ancienne Route du Littoral (sous la falaise de la Montagne, fermée en 2022)
-- - Nouvelle Route du Littoral (NRL) : viaduc en mer entre St-Denis et La Possession,
--   ouvert en 2022, ~12 km, l'une des routes les plus chères au monde.
-- Échelle : 1 stud ≈ 80 m. Le tracé fait ~150 studs entre les 2 villes.

local Workspace = game:GetService("Workspace")

if Workspace:FindFirstChild("Infrastructure") then return end

local root = Instance.new("Folder")
root.Name = "Infrastructure"
root.Parent = Workspace

-- Palette (cf. GAME_KNOWLEDGE §3)
local PALETTE = {
	Asphalt    = Color3.fromRGB( 35,  35,  40),
	Concrete   = Color3.fromRGB(190, 185, 175),
	ConcreteD  = Color3.fromRGB(140, 135, 125),
	RoadLine   = Color3.fromRGB(245, 230, 130),
	Lagon      = Color3.fromRGB(  0, 153, 184),
	Falaise    = Color3.fromRGB( 90,  75,  60),
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

-- ============================================================================
-- POINTS DE REPÈRE (positions des villes côtières concernées)
-- ============================================================================
-- Saint-Denis : (20, 8, -260)
-- Le Port     : (-150, 8, -220)
-- La Possession : (-180, 8, -190)

local stDenis = Vector3.new(20, 8, -260)
local possession = Vector3.new(-180, 8, -190)
local lePort = Vector3.new(-150, 8, -220)

-- ============================================================================
-- 1) ANCIENNE ROUTE DU LITTORAL (RN1) — passe SOUS la falaise, à terre
-- ============================================================================
-- 6 segments légèrement courbés pour suivre la côte
local oldRouteFolder = Instance.new("Folder")
oldRouteFolder.Name = "AncienneRouteDuLittoral"
oldRouteFolder.Parent = root

local oldRoutePoints = {
	stDenis + Vector3.new(0, 0, 6),
	Vector3.new(-30, 8, -262),
	Vector3.new(-70, 8, -255),
	Vector3.new(-110, 8, -242),
	Vector3.new(-140, 8, -230),
	lePort + Vector3.new(5, 0, 0),
}

local function makeRoadSegment(parent, p1, p2, width, name, color)
	local dx = p2.X - p1.X
	local dz = p2.Z - p1.Z
	local length = math.sqrt(dx*dx + dz*dz)
	local mid = (p1 + p2) / 2
	local angle = math.deg(math.atan2(dx, dz))
	-- Tablier
	makePart(parent, {
		Name = name,
		Size = Vector3.new(width or 8, 0.4, length),
		Position = Vector3.new(mid.X, p1.Y - 1, mid.Z),
		Orientation = Vector3.new(0, angle, 0),
		Color = color or PALETTE.Asphalt,
		Material = Enum.Material.Asphalt,
	})
	-- Bande blanche centrale (ligne médiane)
	makePart(parent, {
		Name = name .. "_Line",
		Size = Vector3.new(0.4, 0.45, length * 0.85),
		Position = Vector3.new(mid.X, p1.Y - 0.95, mid.Z),
		Orientation = Vector3.new(0, angle, 0),
		Color = PALETTE.RoadLine,
		Material = Enum.Material.Neon,
		Transparency = 0.3,
	})
end

for i = 1, #oldRoutePoints - 1 do
	makeRoadSegment(oldRouteFolder, oldRoutePoints[i], oldRoutePoints[i + 1], 7,
		"AncienneRN1_" .. i, Color3.fromRGB(50, 50, 55))
end

-- Falaise au sud de l'ancienne route (la "Montagne" de Saint-Denis qui surplombe)
local falaiseFolder = Instance.new("Folder")
falaiseFolder.Name = "FalaiseMontagne"
falaiseFolder.Parent = root
for i, pt in ipairs(oldRoutePoints) do
	makePart(falaiseFolder, {
		Size = Vector3.new(18, 32, 18),
		Position = pt + Vector3.new(0, 14, -16),  -- au sud de la route
		Color = PALETTE.Falaise,
		Material = Enum.Material.Rock,
	})
end

-- Pancarte "Route fermée — chutes de pierres" sur l'ancienne route
do
	local panneau = makePart(oldRouteFolder, {
		Name = "PanneauAncienneRoute",
		Size = Vector3.new(0.5, 4, 4),
		Position = Vector3.new(-50, 11, -252),
		Color = PALETTE.RoadLine,
		Material = Enum.Material.SmoothPlastic,
	})
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(6, 0, 1.5, 0)
	bg.StudsOffset = Vector3.new(0, 3, 0)
	bg.AlwaysOnTop = true
	bg.MaxDistance = 250
	bg.Parent = panneau
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundColor3 = Color3.fromRGB(240, 60, 50)
	lbl.BackgroundTransparency = 0.1
	lbl.BorderSizePixel = 0
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = "ANCIENNE RN1\nChutes de pierres"
	lbl.Parent = bg
end

-- ============================================================================
-- 2) NRL — Nouvelle Route du Littoral (viaduc en mer)
-- Parallèle à l'ancienne route, mais ~10 studs au nord (côté mer).
-- Viaduc surélevé sur piles béton, ~2 voies par sens.
-- ============================================================================
local nrlFolder = Instance.new("Folder")
nrlFolder.Name = "NouvelleRouteDuLittoral"
nrlFolder.Parent = root

local nrlPoints = {
	stDenis + Vector3.new(-5, 0, -10),     -- entrée St-Denis côté mer
	Vector3.new(-30, 8, -275),
	Vector3.new(-70, 8, -270),
	Vector3.new(-110, 8, -260),
	Vector3.new(-140, 8, -245),
	lePort + Vector3.new(0, 0, -10),       -- arrivée Le Port
}

-- Tablier surélevé (Y=11, soit ~3 studs au-dessus du sol)
for i = 1, #nrlPoints - 1 do
	local p1 = nrlPoints[i] + Vector3.new(0, 3, 0)
	local p2 = nrlPoints[i + 1] + Vector3.new(0, 3, 0)
	makeRoadSegment(nrlFolder, p1, p2, 12, "NRL_" .. i, PALETTE.Asphalt)

	-- Glissières béton (parapet) de chaque côté
	local dx = p2.X - p1.X
	local dz = p2.Z - p1.Z
	local length = math.sqrt(dx*dx + dz*dz)
	local mid = (p1 + p2) / 2
	local angle = math.deg(math.atan2(dx, dz))
	-- Côté nord
	makePart(nrlFolder, {
		Name = "NRL_RailN_" .. i,
		Size = Vector3.new(0.8, 1.2, length * 0.95),
		CFrame = CFrame.new(mid + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, math.rad(angle), 0)
			* CFrame.new(6.4, 0, 0),
		Color = PALETTE.Concrete,
		Material = Enum.Material.Concrete,
	})
	-- Côté sud
	makePart(nrlFolder, {
		Name = "NRL_RailS_" .. i,
		Size = Vector3.new(0.8, 1.2, length * 0.95),
		CFrame = CFrame.new(mid + Vector3.new(0, 0.6, 0)) * CFrame.Angles(0, math.rad(angle), 0)
			* CFrame.new(-6.4, 0, 0),
		Color = PALETTE.Concrete,
		Material = Enum.Material.Concrete,
	})
end

-- Piles du viaduc (tous les ~25 studs, plongées dans la mer)
local function makePile(pos, height)
	-- Fût octogonal approché par cylindre élargi
	makePart(nrlFolder, {
		Name = "NRL_Pile",
		Size = Vector3.new(3, height, 3),
		Position = pos,
		Color = PALETTE.ConcreteD,
		Material = Enum.Material.Concrete,
		Shape = Enum.PartType.Cylinder,
		Orientation = Vector3.new(0, 0, 90),
	})
	-- Chevêtre en tête de pile (poutre transversale)
	makePart(nrlFolder, {
		Name = "NRL_PileHead",
		Size = Vector3.new(12, 1.2, 4),
		Position = pos + Vector3.new(0, height / 2 + 0.6, 0),
		Color = PALETTE.Concrete,
		Material = Enum.Material.Concrete,
	})
end

-- Place une pile tous les 25 studs le long du tracé NRL
local function distanceXZ(a, b)
	local dx = a.X - b.X
	local dz = a.Z - b.Z
	return math.sqrt(dx*dx + dz*dz)
end

for i = 1, #nrlPoints - 1 do
	local p1 = nrlPoints[i]
	local p2 = nrlPoints[i + 1]
	local d = distanceXZ(p1, p2)
	local pileCount = math.max(1, math.floor(d / 25))
	for j = 1, pileCount do
		local t = j / (pileCount + 1)
		local pilePos = p1:Lerp(p2, t)
		-- Pile plonge jusque sous le niveau de la mer (Y=-3)
		local pileHeight = pilePos.Y + 3 + 3   -- depuis Y=-3 jusqu'à Y=tablier-1
		makePile(Vector3.new(pilePos.X, (pilePos.Y - 3) / 2, pilePos.Z), pileHeight)
	end
end

-- Pancarte verte autoroutière "NRL — La Possession 5km"
do
	local panneau = makePart(nrlFolder, {
		Name = "PanneauNRL",
		Size = Vector3.new(0.5, 4, 6),
		Position = Vector3.new(-25, 14, -275),
		Color = PALETTE.Concrete,
		Material = Enum.Material.SmoothPlastic,
	})
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(8, 0, 2, 0)
	bg.StudsOffset = Vector3.new(0, 3, 0)
	bg.AlwaysOnTop = true
	bg.MaxDistance = 300
	bg.Parent = panneau
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 1, 0)
	lbl.BackgroundColor3 = Color3.fromRGB(28, 95, 50)
	lbl.BackgroundTransparency = 0.05
	lbl.BorderSizePixel = 0
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = "NRL → La Possession\n← Saint-Denis"
	lbl.Parent = bg
end

print("[Infrastructure] Ancienne RN1 (route littorale) + NRL (viaduc en mer) construites entre Saint-Denis et Le Port/La Possession.")
