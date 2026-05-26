-- Portals.server.lua
-- Portails néon qui téléportent entre les villes principales pour fluidifier
-- l'exploration. Chaque ville importante a un anneau coloré. Au contact, le
-- joueur est téléporté à la ville suivante dans l'ordre du scénario.

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

if Workspace:FindFirstChild("Portals") then return end

local root = Instance.new("Folder")
root.Name = "Portals"
root.Parent = Workspace

-- Ordre des destinations (boucle)
local PORTAL_CHAIN = {
	"Saint-Denis", "Saint-Paul", "Saint-Pierre", "Saint-Benoit",
	"Cilaos", "Plaine-des-Cafres", "Sainte-Rose",
}

local PORTAL_COLORS = {
	Color3.fromRGB(255, 107,  53),
	Color3.fromRGB(244, 185,  66),
	Color3.fromRGB(  0, 153, 184),
	Color3.fromRGB(233,  30,  99),
	Color3.fromRGB( 28, 139,  62),
	Color3.fromRGB(233,  78,  27),
	Color3.fromRGB(255, 230, 160),
}

local function makePortal(pos, color, nextPos, label)
	-- Anneau (un Cylinder vertical creux approximé par sphère + extraction)
	local ring = Instance.new("Part")
	ring.Name = "PortalRing"
	ring.Anchored = true
	ring.CanCollide = false
	ring.Size = Vector3.new(8, 8, 1)
	ring.Position = pos + Vector3.new(0, 4, 0)
	ring.Material = Enum.Material.Neon
	ring.Color = color
	ring.Shape = Enum.PartType.Cylinder
	ring.Orientation = Vector3.new(0, 0, 0)
	ring.Transparency = 0.3
	ring.Parent = root

	-- Intérieur (cylindre noir transparent pour creuser visuellement)
	local inner = Instance.new("Part")
	inner.Anchored = true
	inner.CanCollide = false
	inner.Size = Vector3.new(6, 6, 0.5)
	inner.Position = pos + Vector3.new(0, 4, 0)
	inner.Material = Enum.Material.ForceField
	inner.Color = color
	inner.Shape = Enum.PartType.Cylinder
	inner.Transparency = 0.4
	inner.Parent = root

	-- BillboardGui nom destination
	local lbl = Instance.new("BillboardGui")
	lbl.Size = UDim2.new(6, 0, 1.4, 0)
	lbl.StudsOffset = Vector3.new(0, 6, 0)
	lbl.AlwaysOnTop = true
	lbl.Parent = ring
	local txt = Instance.new("TextLabel")
	txt.Size = UDim2.new(1, 0, 1, 0)
	txt.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	txt.BackgroundTransparency = 0.2
	txt.BorderSizePixel = 0
	txt.TextColor3 = color
	txt.Font = Enum.Font.GothamBold
	txt.TextScaled = true
	txt.Text = "→ " .. label
	txt.Parent = lbl

	-- Pulse animation
	task.spawn(function()
		local t = 0
		while ring.Parent do
			t = t + 0.05
			ring.Transparency = 0.3 + math.sin(t * 3) * 0.1
			task.wait(0.05)
		end
	end)

	-- Detection contact (scan périodique)
	task.spawn(function()
		while ring.Parent do
			for _, player in ipairs(Players:GetPlayers()) do
				local char = player.Character
				local prRoot = char and char:FindFirstChild("HumanoidRootPart")
				if prRoot and (prRoot.Position - ring.Position).Magnitude < 5 then
					-- Téléport vers nextPos
					if not player:GetAttribute("PortalCooldown") then
						player:SetAttribute("PortalCooldown", true)
						prRoot.CFrame = CFrame.new(nextPos + Vector3.new(0, 6, 0))
						-- Effet sonore (built-in)
						local s = Instance.new("Sound")
						s.SoundId = "rbxasset://sounds/electronicpingshort.wav"
						s.Volume = 0.6
						s.Parent = prRoot
						s:Play()
						Debris:AddItem(s, 1)
						task.delay(3, function()
							player:SetAttribute("PortalCooldown", false)
						end)
					end
				end
			end
			task.wait(0.2)
		end
	end)
end

-- Attendre la map
local island = Workspace:WaitForChild("ReunionIsland", 15)
if not island then return end
local cities = island:FindFirstChild("Cities")
if not cities then return end

for i, cityName in ipairs(PORTAL_CHAIN) do
	local city = cities:FindFirstChild(cityName)
	if city then
		local entrance = city:FindFirstChild("Entrance")
		if entrance then
			local nextIdx = (i % #PORTAL_CHAIN) + 1
			local nextCity = cities:FindFirstChild(PORTAL_CHAIN[nextIdx])
			local nextEntrance = nextCity and nextCity:FindFirstChild("Entrance")
			if nextEntrance then
				local color = PORTAL_COLORS[((i - 1) % #PORTAL_COLORS) + 1]
				-- Placer le portail à 15 studs sud du portail de ville
				makePortal(
					entrance.Position + Vector3.new(0, 0, 16),
					color,
					nextEntrance.Position,
					PORTAL_CHAIN[nextIdx]
				)
			end
		end
	end
end

print("[Portals] " .. #PORTAL_CHAIN .. " portails neon installes (chaine en boucle).")
