-- LavaFlow.server.lua
-- Coulée de lave active du Piton de la Fournaise jusqu'à la mer.
-- Référence : éruption 2007 où la lave a atteint la mer près de Sainte-Rose.
-- Effets : tube de lave Neon orange, fumée blanche, particules braises,
-- son grondement, lumière chaleur.

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

if Workspace:FindFirstChild("LavaFlow") then return end

local root = Instance.new("Folder")
root.Name = "LavaFlow"
root.Parent = Workspace

-- Palette
local PALETTE = {
	LavaCore     = Color3.fromRGB(255, 220, 100),   -- cœur de la coulée (chaud)
	LavaOuter    = Color3.fromRGB(255, 100, 30),    -- bord refroidissant
	LavaCool     = Color3.fromRGB(120,  40,  20),   -- lave figée
	Smoke        = Color3.fromRGB(220, 220, 220),
}

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
-- TRAJET DE LA COULÉE
-- Du cratère Fournaise (180, 55, -20) jusqu'à la mer côté Sainte-Rose (300, 0, 40).
-- 8 points pour suivre les pentes du volcan.
-- ============================================================================
local flowPoints = {
	Vector3.new(180, 55, -20),   -- Cratère
	Vector3.new(195, 50,  -8),
	Vector3.new(215, 42,   4),
	Vector3.new(240, 32,  14),
	Vector3.new(265, 22,  22),
	Vector3.new(285, 12,  30),
	Vector3.new(298,  4,  37),
	Vector3.new(305,  0,  42),   -- Entrée dans la mer (avec vapeur)
}

-- ============================================================================
-- TUBE DE LAVE — segments de Part Neon entre chaque paire de points
-- ============================================================================
local function makeLavaSegment(p1, p2, idx)
	local dx = p2.X - p1.X
	local dy = p2.Y - p1.Y
	local dz = p2.Z - p1.Z
	local length = math.sqrt(dx * dx + dy * dy + dz * dz)
	local mid = (p1 + p2) / 2

	-- Calcul de l'orientation du segment
	local cf = CFrame.new(mid, p2)

	-- Cœur lumineux de la coulée
	local core = makePart(root, {
		Name = "LavaCore_" .. idx,
		Size = Vector3.new(3.5, 2, length),
		CFrame = cf,
		Color = PALETTE.LavaCore,
		Material = Enum.Material.Neon,
	})

	-- Halo extérieur plus orange
	makePart(root, {
		Name = "LavaOuter_" .. idx,
		Size = Vector3.new(5, 2.6, length + 1),
		CFrame = cf * CFrame.new(0, -0.3, 0),
		Color = PALETTE.LavaOuter,
		Material = Enum.Material.Neon,
		Transparency = 0.35,
	})

	-- Lumière le long de la coulée
	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range = 25
	light.Color = Color3.fromRGB(255, 130, 50)
	light.Parent = core

	-- Animation : transparence du cœur pulse pour simuler le bouillonnement
	local tweenIn = TweenService:Create(core,
		TweenInfo.new(1.2 + math.random() * 0.6, Enum.EasingStyle.Sine,
			Enum.EasingDirection.InOut, -1, true),
		{ Transparency = 0.18 }
	)
	tweenIn:Play()
end

for i = 1, #flowPoints - 1 do
	makeLavaSegment(flowPoints[i], flowPoints[i + 1], i)
end

-- ============================================================================
-- FUMÉE / ÉRUPTION au cratère
-- ============================================================================
local craterAnchor = makePart(root, {
	Name = "CraterAnchor",
	Size = Vector3.new(10, 1, 10),
	Position = Vector3.new(180, 58, -20),
	Transparency = 1,
})

-- Émetteur de fumée blanche (panache)
local smoke = Instance.new("ParticleEmitter")
smoke.Name = "EruptionSmoke"
smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
smoke.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 200, 100)),  -- doré sortie
	ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 120,  60)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 180, 180)),  -- gris haute alt
})
smoke.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 4),
	NumberSequenceKeypoint.new(0.6, 15),
	NumberSequenceKeypoint.new(1, 30),
})
smoke.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0,   0.4),
	NumberSequenceKeypoint.new(0.5, 0.6),
	NumberSequenceKeypoint.new(1,   1),
})
smoke.Lifetime = NumberRange.new(6, 10)
smoke.Rate = 35
smoke.Speed = NumberRange.new(15, 25)
smoke.SpreadAngle = Vector2.new(20, 20)
smoke.Acceleration = Vector3.new(3, 4, 1)
smoke.LightEmission = 0.5
smoke.Rotation = NumberRange.new(0, 360)
smoke.RotSpeed = NumberRange.new(-20, 20)
smoke.EmissionDirection = Enum.NormalId.Top
smoke.Parent = craterAnchor

-- Émetteur de braises orange (projection lumineuse rapide)
local embers = Instance.new("ParticleEmitter")
embers.Name = "EruptionEmbers"
embers.Texture = "rbxasset://textures/particles/sparkles_main.dds"
embers.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 150)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(220,  80,  30)),
})
embers.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1.5),
	NumberSequenceKeypoint.new(1, 0.4),
})
embers.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0,   0.1),
	NumberSequenceKeypoint.new(0.8, 0.4),
	NumberSequenceKeypoint.new(1,   1),
})
embers.Lifetime = NumberRange.new(2, 4)
embers.Rate = 50
embers.Speed = NumberRange.new(30, 50)
embers.SpreadAngle = Vector2.new(40, 40)
embers.Acceleration = Vector3.new(0, -15, 0)  -- retombent comme des projectiles
embers.LightEmission = 0.9
embers.LightInfluence = 0.1
embers.EmissionDirection = Enum.NormalId.Top
embers.Parent = craterAnchor

-- ============================================================================
-- VAPEUR à l'entrée mer (réaction lave + eau)
-- ============================================================================
local seaAnchor = makePart(root, {
	Name = "SeaSteamAnchor",
	Size = Vector3.new(8, 1, 8),
	Position = Vector3.new(308, 1, 44),
	Transparency = 1,
})

local steam = Instance.new("ParticleEmitter")
steam.Name = "LavaSeaSteam"
steam.Texture = "rbxasset://textures/particles/smoke_main.dds"
steam.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 220, 230)),
})
steam.Size = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 3),
	NumberSequenceKeypoint.new(1, 14),
})
steam.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0,   0.3),
	NumberSequenceKeypoint.new(1,   1),
})
steam.Lifetime = NumberRange.new(3, 6)
steam.Rate = 40
steam.Speed = NumberRange.new(8, 15)
steam.SpreadAngle = Vector2.new(30, 30)
steam.Acceleration = Vector3.new(2, 6, 0)
steam.LightEmission = 0.4
steam.Rotation = NumberRange.new(0, 360)
steam.EmissionDirection = Enum.NormalId.Top
steam.Parent = seaAnchor

-- Lueur orange sous la vapeur (lave qui refroidit)
makePart(root, {
	Name = "CoolingGlow",
	Size = Vector3.new(12, 1, 12),
	Position = Vector3.new(308, 0.5, 44),
	Color = PALETTE.LavaOuter,
	Material = Enum.Material.Neon,
	Transparency = 0.4,
	Shape = Enum.PartType.Cylinder,
	Orientation = Vector3.new(0, 0, 90),
})

-- ============================================================================
-- SON de grondement volcanique (loopé, 3D)
-- ============================================================================
local rumble = Instance.new("Sound")
rumble.Name = "VolcanoRumble"
rumble.SoundId = "rbxasset://sounds/uuhhh.mp3"
rumble.Looped = true
rumble.Volume = 0.45
rumble.PlaybackSpeed = 0.35  -- très grave
rumble.RollOffMode = Enum.RollOffMode.Linear
rumble.RollOffMinDistance = 40
rumble.RollOffMaxDistance = 250
rumble.Parent = craterAnchor
rumble:Play()

print("[LavaFlow] Coulée de lave active du Piton de la Fournaise (cratère) jusqu'à la mer côté Sainte-Rose. 7 segments, panache de fumée, braises, vapeur d'entrée mer, grondement loopé.")
