-- Waterfalls.server.lua
-- 3 cascades aux 3 cirques (Cilaos, Salazie, Mafate).
-- Combine ParticleEmitter (eau qui tombe + brume au sol) + PointLight humide
-- + Sound loopé (rbxasset built-in). Idempotent.

local Workspace = game:GetService("Workspace")

if Workspace:FindFirstChild("Waterfalls") then return end

local root = Instance.new("Folder")
root.Name = "Waterfalls"
root.Parent = Workspace

-- Texture standard de particule eau Roblox (rbxasset built-in)
local WATER_DROP_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"
local MIST_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"

local function makeAnchoredPart(parent, name, props)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	for k, v in pairs(props or {}) do p[k] = v end
	p.Parent = parent
	return p
end

local function buildWaterfall(name, topPos, height)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = root

	-- Mur d'eau (Part bleu transparent vertical pour suggérer la veine d'eau)
	local sheet = Instance.new("Part")
	sheet.Name = "WaterSheet"
	sheet.Anchored = true
	sheet.CanCollide = false
	sheet.Size = Vector3.new(6, height, 1.5)
	sheet.Position = topPos - Vector3.new(0, height / 2, 0)
	sheet.Transparency = 0.4
	sheet.BrickColor = BrickColor.new("Pastel blue")
	sheet.Material = Enum.Material.Glass
	sheet.Parent = folder

	-- Émetteur eau qui chute (au top)
	local emitter = makeAnchoredPart(folder, "DropEmitter", {
		Size = Vector3.new(6, 1, 1.5),
		Position = topPos + Vector3.new(0, 0.5, 0),
	})
	local water = Instance.new("ParticleEmitter")
	water.Name = "Water"
	water.Texture = WATER_DROP_TEXTURE
	water.Color = ColorSequence.new(Color3.fromRGB(200, 230, 255))
	water.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1.2),
		NumberSequenceKeypoint.new(1, 0.4),
	})
	water.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.8, 0.4),
		NumberSequenceKeypoint.new(1, 1),
	})
	water.Lifetime = NumberRange.new(0.6, 1.0)
	water.Rate = 60
	water.Speed = NumberRange.new(20, 28)
	water.SpreadAngle = Vector2.new(5, 5)
	water.Acceleration = Vector3.new(0, -80, 0)
	water.LightEmission = 0.4
	water.LightInfluence = 0.6
	water.Rotation = NumberRange.new(0, 360)
	water.EmissionDirection = Enum.NormalId.Bottom
	water.Parent = emitter

	-- Brume au sol (sprite blanc transparent longue vie)
	local mistAnchor = makeAnchoredPart(folder, "MistEmitter", {
		Size = Vector3.new(8, 1, 4),
		Position = topPos - Vector3.new(0, height + 0.5, 0),
	})
	local mist = Instance.new("ParticleEmitter")
	mist.Name = "Mist"
	mist.Texture = MIST_TEXTURE
	mist.Color = ColorSequence.new(Color3.fromRGB(220, 230, 240))
	mist.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(1, 5),
	})
	mist.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.6),
		NumberSequenceKeypoint.new(1, 1),
	})
	mist.Lifetime = NumberRange.new(2.5, 4)
	mist.Rate = 8
	mist.Speed = NumberRange.new(1, 2)
	mist.SpreadAngle = Vector2.new(45, 45)
	mist.LightEmission = 0.3
	mist.Rotation = NumberRange.new(0, 360)
	mist.RotSpeed = NumberRange.new(-10, 10)
	mist.Parent = mistAnchor

	-- Lumière humide
	local light = Instance.new("PointLight")
	light.Name = "DampLight"
	light.Brightness = 1.2
	light.Range = 30
	light.Color = Color3.fromRGB(180, 220, 255)
	light.Parent = mistAnchor

	-- Son (loop, faible volume, range 3D)
	local sound = Instance.new("Sound")
	sound.Name = "WaterSound"
	sound.SoundId = "rbxasset://sounds/impact_water.mp3"
	sound.Looped = true
	sound.Volume = 0.35
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = 15
	sound.RollOffMaxDistance = 80
	sound.Parent = mistAnchor
	sound:Play()

	return folder
end

-- ============================================================================
-- Les 3 cascades — positions au-dessus des cirques (Y plus haut que le plancher)
-- Le sommet de la chute = bord du rempart, la chute s'écoule vers le bas.
-- ============================================================================

-- Cilaos : cirque à (-50, 30, -10), chute depuis Y=52, hauteur 20
buildWaterfall("CascadeBrasRouge",   Vector3.new(-50, 52, -25), 22)

-- Salazie : cirque à (0, 30, -90), chute "Voile de la Mariée" depuis Y=55
buildWaterfall("VoileDeLaMariee",    Vector3.new(  0, 55, -105), 26)

-- Mafate : cirque à (-120, 32, -70), cascades multiples (cirque sauvage)
buildWaterfall("CascadeMafate",      Vector3.new(-120, 50, -82), 20)

print("[Waterfalls] 3 cascades créées (Cilaos, Salazie, Mafate) avec particules + son + lumière.")
