-- ArenaBuilder.server.lua
-- Construit l'arène minimale au lancement : baseplate, spawn joueur,
-- et 4 spawn points pour zombies. Évite la dépendance à un place file
-- pré-construit en Studio.

local Workspace = game:GetService("Workspace")

local function makePart(name, parent, props)
	local p = Instance.new("Part")
	p.Name = name
	for k, v in pairs(props) do p[k] = v end
	p.Parent = parent
	return p
end

-- Baseplate
if not Workspace:FindFirstChild("Baseplate") then
	makePart("Baseplate", Workspace, {
		Size = Vector3.new(200, 1, 200),
		Position = Vector3.new(0, 0, 0),
		Anchored = true,
		BrickColor = BrickColor.new("Dark green"),
		Material = Enum.Material.Grass,
		TopSurface = Enum.SurfaceType.Smooth,
	})
end

-- Mur invisible pour empêcher le joueur de tomber
local function makeWall(name, size, pos)
	if Workspace:FindFirstChild(name) then return end
	makePart(name, Workspace, {
		Size = size,
		Position = pos,
		Anchored = true,
		Transparency = 0.85,
		BrickColor = BrickColor.new("Mid gray"),
		Material = Enum.Material.SmoothPlastic,
	})
end
makeWall("WallN", Vector3.new(200, 12, 1), Vector3.new(0, 6, -100))
makeWall("WallS", Vector3.new(200, 12, 1), Vector3.new(0, 6,  100))
makeWall("WallE", Vector3.new(1, 12, 200), Vector3.new( 100, 6, 0))
makeWall("WallW", Vector3.new(1, 12, 200), Vector3.new(-100, 6, 0))

-- Spawn joueur
if not Workspace:FindFirstChild("PlayerSpawn") then
	local sl = Instance.new("SpawnLocation")
	sl.Name = "PlayerSpawn"
	sl.Size = Vector3.new(6, 1, 6)
	sl.Position = Vector3.new(0, 1, 0)
	sl.Anchored = true
	sl.BrickColor = BrickColor.new("Bright blue")
	sl.TopSurface = Enum.SurfaceType.Smooth
	sl.Parent = Workspace
end

-- Arena folder + ZombieSpawns
local arena = Workspace:FindFirstChild("Arena") or Instance.new("Folder")
arena.Name = "Arena"
arena.Parent = Workspace

local spawns = arena:FindFirstChild("ZombieSpawns") or Instance.new("Folder")
spawns.Name = "ZombieSpawns"
spawns.Parent = arena

local positions = {
	Vector3.new( 40, 2,  0),
	Vector3.new(-40, 2,  0),
	Vector3.new(  0, 2,  40),
	Vector3.new(  0, 2, -40),
	Vector3.new( 30, 2,  30),
	Vector3.new(-30, 2, -30),
}
for i, pos in ipairs(positions) do
	local name = "Spawn" .. i
	if not spawns:FindFirstChild(name) then
		makePart(name, spawns, {
			Size = Vector3.new(2, 2, 2),
			Position = pos,
			Anchored = true,
			CanCollide = false,
			Transparency = 0.5,
			BrickColor = BrickColor.new("Bright red"),
			Material = Enum.Material.Neon,
		})
	end
end

print("[ArenaBuilder] Arène prête : baseplate + 6 spawn points")
