-- Weather.server.lua
-- Météo LOCALE sur la carte de La Réunion.
-- À La Réunion, l'Est est "au vent" (alizés humides venus de l'océan), il y pleut
-- beaucoup plus que dans l'Ouest "sous le vent" (qui est sec et ensoleillé).
-- Saint-Benoît, Saint-Philippe, Bras-Panon, Sainte-Rose, Sainte-Suzanne sont
-- réputées pour leur pluie quasi-quotidienne.
--
-- Cohérent avec Story.Missions[4] "Acte IV — L'Est sous la Pluie".

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

if Workspace:FindFirstChild("Weather") then return end

local root = Instance.new("Folder")
root.Name = "Weather"
root.Parent = Workspace

local function makePart(parent, props)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent
	return p
end

-- ============================================================================
-- ZONES DE PLUIE — chaque zone est un Part invisible avec un ParticleEmitter
-- pluie ancré au sommet. Les particules retombent grâce à l'accélération.
-- ============================================================================
local RAIN_ZONES = {
	-- Saint-Benoît (cœur de la zone humide)
	{ name = "Rain_StBenoit",     pos = Vector3.new( 280, 60,  -80), radius = 60, intensity = 1.0 },
	-- Bras-Panon
	{ name = "Rain_BrasPanon",    pos = Vector3.new( 230, 55, -130), radius = 50, intensity = 0.8 },
	-- Sainte-Rose (au pied de la Fournaise)
	{ name = "Rain_StRose",       pos = Vector3.new( 300, 55,   40), radius = 55, intensity = 0.9 },
	-- Saint-Philippe (extrême sud-est)
	{ name = "Rain_StPhilippe",   pos = Vector3.new( 230, 55,  170), radius = 50, intensity = 0.7 },
	-- Plaine-des-Palmistes (intérieur très humide)
	{ name = "Rain_PdPalmistes",  pos = Vector3.new( 140, 60,    0), radius = 55, intensity = 0.85 },
	-- Sainte-Suzanne (Cascade Niagara : il pleut souvent)
	{ name = "Rain_StSuzanne",    pos = Vector3.new( 130, 55, -230), radius = 45, intensity = 0.6 },
}

-- Texture de "rideau de pluie" — on utilise smoke_main avec couleur bleu pâle
-- + size très allongé pour simuler des gouttes filantes.
local RAIN_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"

local function makeRainZone(zone)
	local anchor = makePart(root, {
		Name = zone.name,
		Size = Vector3.new(zone.radius * 2, 2, zone.radius * 2),
		Position = zone.pos,
	})

	-- 1) GOUTTES — particules filantes verticales
	local rain = Instance.new("ParticleEmitter")
	rain.Name = "Rain"
	rain.Texture = RAIN_TEXTURE
	rain.Color = ColorSequence.new(Color3.fromRGB(170, 200, 220))
	rain.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 0.6),
	})
	rain.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.4),
		NumberSequenceKeypoint.new(0.6, 0.5),
		NumberSequenceKeypoint.new(1,   1),
	})
	rain.Lifetime = NumberRange.new(0.6, 1.0)
	rain.Rate = 200 * zone.intensity
	rain.Speed = NumberRange.new(80, 110)
	rain.SpreadAngle = Vector2.new(5, 5)
	rain.Acceleration = Vector3.new(-3, -50, 0)   -- vent E->W léger + gravité
	rain.LightEmission = 0
	rain.LightInfluence = 0.6
	rain.Rotation = NumberRange.new(0, 0)
	rain.EmissionDirection = Enum.NormalId.Bottom
	rain.Parent = anchor

	-- 2) BRUME basse — sprite gris très transparent qui flotte
	local mistAnchor = makePart(root, {
		Name = zone.name .. "_Mist",
		Size = Vector3.new(zone.radius * 2, 1, zone.radius * 2),
		Position = zone.pos + Vector3.new(0, -52, 0),
	})
	local mist = Instance.new("ParticleEmitter")
	mist.Name = "Mist"
	mist.Texture = "rbxasset://textures/particles/smoke_main.dds"
	mist.Color = ColorSequence.new(Color3.fromRGB(200, 210, 220))
	mist.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 8),
		NumberSequenceKeypoint.new(1, 18),
	})
	mist.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.7),
		NumberSequenceKeypoint.new(1,   1),
	})
	mist.Lifetime = NumberRange.new(4, 7)
	mist.Rate = 6 * zone.intensity
	mist.Speed = NumberRange.new(2, 5)
	mist.SpreadAngle = Vector2.new(25, 25)
	mist.Acceleration = Vector3.new(-2, 1, 0)
	mist.LightEmission = 0.2
	mist.Rotation = NumberRange.new(0, 360)
	mist.RotSpeed = NumberRange.new(-15, 15)
	mist.Parent = mistAnchor

	-- 3) SON pluie en boucle, 3D atténué
	local sound = Instance.new("Sound")
	sound.Name = "RainSound"
	sound.SoundId = "rbxasset://sounds/impact_water.mp3"
	sound.Looped = true
	sound.Volume = 0.5 * zone.intensity
	sound.PlaybackSpeed = 1.4   -- plus aigu pour évoquer la pluie
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = 20
	sound.RollOffMaxDistance = zone.radius + 30
	sound.Parent = anchor
	sound:Play()

	-- 4) LUMIÈRE plus sombre dans la zone : un Part noir transparent en plafond
	-- (simulation d'ombre des gros nuages)
	makePart(root, {
		Name = zone.name .. "_CloudShade",
		Size = Vector3.new(zone.radius * 2.2, 4, zone.radius * 2.2),
		Position = zone.pos + Vector3.new(0, 35, 0),
		Color = Color3.fromRGB(60, 70, 85),
		Material = Enum.Material.SmoothPlastic,
		Transparency = 0.55,
	})
end

for _, zone in ipairs(RAIN_ZONES) do
	makeRainZone(zone)
end

-- ============================================================================
-- ARC-EN-CIEL bonus — à la lisière de la zone de pluie, côté ouest
-- Symbole d'espoir cohérent avec le pilier émotionnel du jeu
-- ("Chaque ville libérée illumine l'île un peu plus").
-- ============================================================================
local rainbowColors = {
	Color3.fromRGB(233,  78,  27),   -- rouge flamboyant
	Color3.fromRGB(255, 140,  60),   -- orange
	Color3.fromRGB(244, 185,  66),   -- jaune cannelle
	Color3.fromRGB( 28, 139,  62),   -- vert émeraude
	Color3.fromRGB(  0, 153, 184),   -- bleu lagon
	Color3.fromRGB( 60,  85, 165),   -- indigo
	Color3.fromRGB(120,  60, 165),   -- violet
}
local rainbowAnchor = Vector3.new(200, 70, -40)
for i, color in ipairs(rainbowColors) do
	-- Arc fait de 7 anneaux torique (cylindres incurvés par scale)
	makePart(root, {
		Name = "Rainbow_" .. i,
		Size = Vector3.new(160 - (i - 1) * 4, 1.5, 1.5),
		Position = rainbowAnchor + Vector3.new(0, (7 - i) * 1.6, 0),
		Color = color,
		Material = Enum.Material.Neon,
		Transparency = 0.5,
		Shape = Enum.PartType.Cylinder,
		Orientation = Vector3.new(0, 0, 0),
	})
end

print(("[Weather] Pluie deployee sur %d zones de l'est (St-Benoit, Bras-Panon, " ..
	"Ste-Rose, St-Philippe, Plaine-des-Palmistes, Ste-Suzanne) + arc-en-ciel symbolique."):format(#RAIN_ZONES))
