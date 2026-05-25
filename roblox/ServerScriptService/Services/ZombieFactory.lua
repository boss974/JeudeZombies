-- ZombieFactory.lua
-- Fabrique des rigs de zombies stylisés cartoon, prêts à parenter au Workspace.
-- Aucun asset externe : tout est généré via Instance.new + BrickColor + Material.
-- L'API publique reste minimale : ZombieFactory.Build(zombieType) -> Model.
-- Le ZombieService est chargé de l'IA, des dégâts, du nettoyage. Ici on ne fait
-- que de la géométrie + une animation d'oscillation cosmétique.
--
-- Style : silhouette cubique/sphérique, palette définie par Config.Zombie.
-- Aucune blessure visible, aucun sang, aucun cri (respect du framework safety).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local ZombieFactory = {}

-- ---------------------------------------------------------------------------
-- Palette par type (cartoon, non-gore). Les couleurs viennent de BrickColor
-- pour garantir compatibilité Studio + cohérence avec le reste du projet.
-- ---------------------------------------------------------------------------
local PALETTE = {
	Normal = {
		Skin       = BrickColor.new("Bright green"),     -- vert moyen
		SkinAccent = BrickColor.new("Camo"),             -- vert un peu plus sombre
		Cloth      = BrickColor.new("Reddish brown"),    -- haillons marron
		EyeGlow    = Color3.fromRGB(255, 60, 60),
		Glow       = nil,                                -- pas de lueur
		Spikes     = false,
	},
	Fast = {
		Skin       = BrickColor.new("Br. yellowish green"),
		SkinAccent = BrickColor.new("New Yeller"),       -- accent jaune (course)
		Cloth      = BrickColor.new("Cool yellow"),
		EyeGlow    = Color3.fromRGB(255, 80, 80),
		Glow       = nil,
		Spikes     = false,
	},
	Heavy = {
		Skin       = BrickColor.new("Earth green"),      -- vert très foncé
		SkinAccent = BrickColor.new("Dark green"),
		Cloth      = BrickColor.new("Dark stone grey"),
		EyeGlow    = Color3.fromRGB(255, 70, 70),
		Glow       = nil,
		Spikes     = false,
		Scale      = 1.35,                               -- carrure plus massive
	},
	MiniBoss = {
		Skin       = BrickColor.new("Bright red"),
		SkinAccent = BrickColor.new("Crimson"),
		Cloth      = BrickColor.new("Really black"),
		EyeGlow    = Color3.fromRGB(255, 220, 80),       -- yeux jaune-orangés
		Glow       = nil,
		Spikes     = true,                               -- couronne d'épines
		Scale      = 1.15,
	},
	Boss = {
		Skin       = BrickColor.new("Really red"),
		SkinAccent = BrickColor.new("Bright orange"),
		Cloth      = BrickColor.new("Really black"),
		EyeGlow    = Color3.fromRGB(255, 240, 120),
		Glow       = Color3.fromRGB(255, 130, 40),       -- lueur orange (PointLight)
		Spikes     = true,
		Scale      = 1.5,
	},
}

-- ---------------------------------------------------------------------------
-- Helpers de construction (toutes les parts sont des Part cartoon : SmoothPlastic,
-- surfaces lisses, anchored = false pour suivre l'Humanoid).
-- ---------------------------------------------------------------------------
local function newPart(name, size, color, material)
	local p = Instance.new("Part")
	p.Name         = name
	p.Size         = size
	p.BrickColor   = color or BrickColor.new("Medium green")
	p.Material     = material or Enum.Material.SmoothPlastic
	p.TopSurface   = Enum.SurfaceType.Smooth
	p.BottomSurface= Enum.SurfaceType.Smooth
	p.CanCollide   = false                                -- on laisse le HRP gérer
	p.CastShadow   = true
	return p
end

-- Soude une part secondaire à une part de référence via Motor6D nommé.
-- Le Motor6D permet d'animer (oscillation bras/jambes) côté serveur.
local function newMotor(name, p0, p1, c0, c1)
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = p0
	m.Part1 = p1
	m.C0 = c0 or CFrame.new()
	m.C1 = c1 or CFrame.new()
	m.Parent = p0
	return m
end

-- Soudure rigide (pour les éléments cosmétiques : yeux, épines, etc.)
local function weldRigid(p0, p1, c0, c1)
	local w = Instance.new("Weld")
	w.Part0 = p0
	w.Part1 = p1
	w.C0 = c0 or CFrame.new()
	w.C1 = c1 or CFrame.new()
	w.Parent = p0
	return w
end

-- ---------------------------------------------------------------------------
-- Construction d'un rig.
-- Convention : HRP centré à Y=0, sol au pied Y = -2.5*scale environ.
-- ZombieService positionne ensuite via PivotTo(CFrame.new(pos)).
-- ---------------------------------------------------------------------------
local function buildRig(zombieType, palette)
	local scale = palette.Scale or 1.0

	local rig = Instance.new("Model")
	rig.Name = "Zombie_" .. zombieType

	-- HumanoidRootPart : pièce invisible servant de pivot et de hitbox
	-- Taille standard R6 (2,2,1) légèrement scalable. CanCollide = true pour
	-- éviter de tomber à travers le terrain.
	local hrp = newPart("HumanoidRootPart",
		Vector3.new(2 * scale, 2 * scale, 1 * scale),
		palette.Skin, Enum.Material.SmoothPlastic)
	hrp.Transparency = 1                                 -- invisible (pivot)
	hrp.CanCollide   = true
	hrp.Parent = rig
	rig.PrimaryPart = hrp

	-- Torse (cube principal, légèrement plus large que haut)
	local torso = newPart("Torso",
		Vector3.new(2 * scale, 2 * scale, 1 * scale),
		palette.Cloth, Enum.Material.Fabric)
	torso.Parent = rig
	newMotor("RootJoint", hrp, torso)                    -- soudure HRP <-> Torso

	-- Tête (sphère légèrement aplatie pour cartoon)
	local head = newPart("Head",
		Vector3.new(1.2 * scale, 1.2 * scale, 1.2 * scale),
		palette.Skin, Enum.Material.SmoothPlastic)
	head.Shape = Enum.PartType.Ball
	head.Parent = rig
	newMotor("Neck", torso, head,
		CFrame.new(0, 1 * scale + 0.6 * scale, 0),
		CFrame.new(0, -0.6 * scale, 0))

	-- Yeux : deux sphères Neon rouges. Soudées rigide à la tête.
	for i = -1, 1, 2 do
		local eye = newPart("Eye",
			Vector3.new(0.25 * scale, 0.25 * scale, 0.25 * scale),
			BrickColor.new("Really red"), Enum.Material.Neon)
		eye.Shape = Enum.PartType.Ball
		eye.Color = palette.EyeGlow
		eye.Parent = rig
		weldRigid(head, eye,
			CFrame.new(0.3 * scale * i, 0.05 * scale, -0.55 * scale),
			CFrame.new())
	end

	-- Bras gauche + droit (cylindres pour silhouette plus douce)
	local function buildArm(side)
		local sign = (side == "Left") and -1 or 1
		local arm = newPart(side .. "Arm",
			Vector3.new(0.7 * scale, 1.8 * scale, 0.7 * scale),
			palette.Skin, Enum.Material.SmoothPlastic)
		arm.Parent = rig
		-- Motor6D nommé pour permettre l'oscillation (cf. animateRig)
		newMotor(side .. "Shoulder", torso, arm,
			CFrame.new(1.05 * scale * sign, 0.6 * scale, 0),
			CFrame.new(0, 0.9 * scale, 0))
		return arm
	end
	local armL = buildArm("Left")
	local armR = buildArm("Right")

	-- Jambes
	local function buildLeg(side)
		local sign = (side == "Left") and -1 or 1
		local leg = newPart(side .. "Leg",
			Vector3.new(0.8 * scale, 1.8 * scale, 0.8 * scale),
			palette.SkinAccent, Enum.Material.SmoothPlastic)
		leg.Parent = rig
		newMotor(side .. "Hip", torso, leg,
			CFrame.new(0.4 * scale * sign, -1 * scale, 0),
			CFrame.new(0, 0.9 * scale, 0))
		return leg
	end
	local legL = buildLeg("Left")
	local legR = buildLeg("Right")

	-- Détails optionnels selon le type ----------------------------------------

	-- Couronne d'épines (MiniBoss / Boss) : 6 cônes/pyramides simples autour du crâne
	if palette.Spikes then
		for i = 1, 6 do
			local angle = (i - 1) * (math.pi * 2 / 6)
			local spike = newPart("Spike",
				Vector3.new(0.18 * scale, 0.55 * scale, 0.18 * scale),
				palette.SkinAccent, Enum.Material.SmoothPlastic)
			spike.Parent = rig
			local r = 0.65 * scale
			weldRigid(head, spike,
				CFrame.new(math.cos(angle) * r, 0.55 * scale, math.sin(angle) * r),
				CFrame.new())
		end
	end

	-- Lueur orange faible (Boss uniquement) : PointLight sur le torse
	if palette.Glow then
		local light = Instance.new("PointLight")
		light.Color      = palette.Glow
		light.Brightness = 1.2
		light.Range      = 10
		light.Shadows    = false
		light.Parent     = torso
	end

	-- Humanoid : HP/Speed seront écrasés par ZombieService.Spawn, on met des
	-- valeurs par défaut pour que l'objet soit fonctionnel hors contexte.
	local stats = Config.Zombie[zombieType] or Config.Zombie.Normal
	local hum = Instance.new("Humanoid")
	hum.MaxHealth = stats.Health
	hum.Health    = stats.Health
	hum.WalkSpeed = stats.Speed
	-- Cacher la barre de HP au-dessus du zombie pour garder l'ambiance cartoon
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	hum.DisplayDistanceType = Enum.HumanoidDisplayType.None
	hum.NameDisplayDistance = 0
	hum.Parent = rig

	return rig, { armL = armL, armR = armR, legL = legL, legR = legR }
end

-- ---------------------------------------------------------------------------
-- Animation cosmétique : oscillation bras + démarche traînante.
-- On évite Animator/Animation (besoin d'asset) : on pilote directement les
-- Motor6D.C0 via RunService.Heartbeat. Connexion auto-coupée à la destruction
-- du rig grâce à AncestryChanged.
-- ---------------------------------------------------------------------------
local function animateRig(rig, joints)
	local torso = rig:FindFirstChild("Torso")
	if not torso then return end

	local shoulderL = torso:FindFirstChild("LeftShoulder")
	local shoulderR = torso:FindFirstChild("RightShoulder")
	local hipL      = torso:FindFirstChild("LeftHip")
	local hipR      = torso:FindFirstChild("RightHip")
	if not (shoulderL and shoulderR and hipL and hipR) then return end

	-- C0 d'origine pour pouvoir revenir au repos
	local c0_sL, c0_sR = shoulderL.C0, shoulderR.C0
	local c0_hL, c0_hR = hipL.C0, hipR.C0

	local conn
	local start = tick()
	conn = RunService.Heartbeat:Connect(function()
		if not rig.Parent then
			conn:Disconnect()
			return
		end
		local t = tick() - start
		-- Démarche zombie : oscillation lente (1.6 Hz), amplitude réduite (~12°)
		local sway = math.sin(t * 3.2) * 0.21                  -- ~12° en radians
		shoulderL.C0 = c0_sL * CFrame.Angles(sway, 0, 0)
		shoulderR.C0 = c0_sR * CFrame.Angles(-sway, 0, 0)
		hipL.C0      = c0_hL * CFrame.Angles(-sway * 0.7, 0, 0)
		hipR.C0      = c0_hR * CFrame.Angles(sway * 0.7, 0, 0)
	end)

	-- Sécurité : si on retire le rig du DataModel, on déconnecte.
	rig.AncestryChanged:Connect(function(_, parent)
		if not parent then
			conn:Disconnect()
		end
	end)
end

-- ---------------------------------------------------------------------------
-- API publique
-- ---------------------------------------------------------------------------
function ZombieFactory.Build(zombieType)
	-- Validation simple : palette inconnue -> fallback Normal pour ne jamais
	-- planter (le ZombieService doit pouvoir continuer à spawn).
	local palette = PALETTE[zombieType] or PALETTE.Normal

	local rig, joints = buildRig(zombieType, palette)
	animateRig(rig, joints)
	return rig
end

return ZombieFactory
