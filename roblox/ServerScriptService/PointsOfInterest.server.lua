-- PointsOfInterest.server.lua
-- Pose des MARKERS PHYSIQUES sur la map pour chaque POI déclaré dans
-- Story.Missions[*].poi. Chaque marker = pilier néon coloré + halo lumineux
-- + BillboardGui avec nom et icône. Le marker reste visible en permanence
-- (utilisé par MissionService pour la détection de proximité).

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Story = require(Shared:WaitForChild("Story"))

if Workspace:FindFirstChild("POIs") then return end

local root = Instance.new("Folder")
root.Name = "POIs"
root.Parent = Workspace

-- Couleur par catégorie d'icône (cycle pour différencier les missions)
local MISSION_COLORS = {
	Color3.fromRGB(255, 107,  53),  -- I  : orange Fournaise
	Color3.fromRGB(  0, 153, 184),  -- II : bleu Lagon
	Color3.fromRGB(244, 185,  66),  -- III: jaune Cannelle
	Color3.fromRGB( 28, 139,  62),  -- IV : vert Émeraude
	Color3.fromRGB(255, 255, 255),  -- V  : blanc (Cilaos = neige)
	Color3.fromRGB(233,  78,  27),  -- VI : rouge Flamboyant
	Color3.fromRGB(255,  30,  30),  -- VII: néon Alerte (volcan)
}

local function makePoi(missionIdx, poi)
	local color = MISSION_COLORS[((missionIdx - 1) % #MISSION_COLORS) + 1]

	-- Pilier néon vertical (visible de loin)
	local pillar = Instance.new("Part")
	pillar.Name = "POI_" .. poi.id
	pillar.Anchored = true
	pillar.CanCollide = false
	pillar.Size = Vector3.new(1.5, 14, 1.5)
	pillar.Position = poi.pos + Vector3.new(0, 7, 0)
	pillar.Material = Enum.Material.Neon
	pillar.Color = color
	pillar.Transparency = 0.15
	pillar.Parent = root

	-- Sphère lumineuse au sommet
	local orb = Instance.new("Part")
	orb.Anchored = true
	orb.CanCollide = false
	orb.Size = Vector3.new(2.5, 2.5, 2.5)
	orb.Position = poi.pos + Vector3.new(0, 14.5, 0)
	orb.Material = Enum.Material.Neon
	orb.Color = color
	orb.Shape = Enum.PartType.Ball
	orb.Parent = pillar

	-- Light
	local light = Instance.new("PointLight")
	light.Brightness = 3
	light.Range = 25
	light.Color = color
	light.Parent = orb

	-- BillboardGui : nom + icône + lore court
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(0, 220, 0, 60)
	bg.StudsOffset = Vector3.new(0, 2.5, 0)
	bg.AlwaysOnTop = false
	bg.MaxDistance = 100
	bg.Parent = orb

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 15, 12)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0
	frame.Parent = bg
	local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(0, 6); fc.Parent = frame
	local fs = Instance.new("UIStroke"); fs.Color = color; fs.Thickness = 2; fs.Parent = frame

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -16, 0, 24)
	nameLbl.Position = UDim2.new(0, 8, 0, 4)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = (poi.icon or "📍") .. " " .. poi.name
	nameLbl.TextColor3 = color
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.TextSize = 14
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.Parent = frame

	local hintLbl = Instance.new("TextLabel")
	hintLbl.Size = UDim2.new(1, -16, 0, 28)
	hintLbl.Position = UDim2.new(0, 8, 0, 28)
	hintLbl.BackgroundTransparency = 1
	hintLbl.Text = "Touche E pour interagir"
	hintLbl.TextColor3 = Color3.fromRGB(180, 160, 130)
	hintLbl.Font = Enum.Font.Gotham
	hintLbl.TextSize = 11
	hintLbl.TextXAlignment = Enum.TextXAlignment.Left
	hintLbl.Parent = frame

	-- Pulse vertical
	task.spawn(function()
		while pillar.Parent do
			TweenService:Create(orb, TweenInfo.new(1.6, Enum.EasingStyle.Sine),
				{ Transparency = 0.4 }):Play()
			task.wait(1.6)
			TweenService:Create(orb, TweenInfo.new(1.6, Enum.EasingStyle.Sine),
				{ Transparency = 0 }):Play()
			task.wait(1.6)
		end
	end)

	-- Attribut pour que le client puisse identifier le POI sur l'input E
	pillar:SetAttribute("PoiId", poi.id)
	pillar:SetAttribute("PoiName", poi.name)
	pillar:SetAttribute("PoiPos", true)  -- flag pour scan client
	orb:SetAttribute("PoiId", poi.id)
end

-- Pose tous les POI de toutes les missions
local count = 0
for i, mission in ipairs(Story.Missions) do
	if mission.poi then
		for _, poi in ipairs(mission.poi) do
			makePoi(i, poi)
			count = count + 1
		end
	end
end

print(("[PointsOfInterest] %d POI poses sur la map (7 missions)."):format(count))
