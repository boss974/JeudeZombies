-- MissionHUD.client.lua
-- Panneau d'objectifs de la mission en cours, ancré en haut à droite
-- sous le HUD ZOMBIES DEBUG. Affiche les 5-6 objectifs séquentiels avec
-- coche verte (✓) quand validé.
--
-- Lit la mission depuis Story.lua et l'état des objectifs depuis un Remote
-- (ObjectiveUpdate envoyé par MissionService côté serveur — sera ajouté).
-- En attendant ce service, on affiche tous les objectifs avec coche
-- automatique sur la vague en cours.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Story = require(Shared:WaitForChild("Story"))

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- ============================================================================
-- UI
-- ============================================================================
local screen = Instance.new("ScreenGui")
screen.Name = "MissionHUD"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 280)
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -20, 0, 180)
frame.BackgroundColor3 = Color3.fromRGB(20, 15, 12)
frame.BackgroundTransparency = 0.18
frame.BorderSizePixel = 0
frame.Parent = screen
local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = frame
local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(184, 144, 44); s.Thickness = 2; s.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 26)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "🗺 MISSION"
title.TextColor3 = Color3.fromRGB(255, 230, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local cityLabel = Instance.new("TextLabel")
cityLabel.Size = UDim2.new(1, -16, 0, 22)
cityLabel.Position = UDim2.new(0, 8, 0, 30)
cityLabel.BackgroundTransparency = 1
cityLabel.Text = ""
cityLabel.TextColor3 = Color3.fromRGB(255, 107, 53)
cityLabel.Font = Enum.Font.GothamBold
cityLabel.TextSize = 16
cityLabel.TextXAlignment = Enum.TextXAlignment.Left
cityLabel.Parent = frame

local historyLabel = Instance.new("TextLabel")
historyLabel.Size = UDim2.new(1, -16, 0, 42)
historyLabel.Position = UDim2.new(0, 8, 0, 52)
historyLabel.BackgroundTransparency = 1
historyLabel.Text = ""
historyLabel.TextColor3 = Color3.fromRGB(190, 170, 140)
historyLabel.Font = Enum.Font.Gotham
historyLabel.TextSize = 11
historyLabel.TextWrapped = true
historyLabel.TextXAlignment = Enum.TextXAlignment.Left
historyLabel.TextYAlignment = Enum.TextYAlignment.Top
historyLabel.Parent = frame

local objectivesList = Instance.new("Frame")
objectivesList.Size = UDim2.new(1, -16, 1, -110)
objectivesList.Position = UDim2.new(0, 8, 0, 100)
objectivesList.BackgroundTransparency = 1
objectivesList.Parent = frame

-- ============================================================================
-- Render objectifs
-- ============================================================================
local currentMissionIdx = 1
local completedObjectives = {}  -- [objId] = true

local function renderObjectives()
	-- Clear existing
	for _, child in ipairs(objectivesList:GetChildren()) do child:Destroy() end

	local mission = Story.Missions[currentMissionIdx]
	if not mission then return end

	cityLabel.Text = mission.title
	historyLabel.Text = mission.history or mission.lore or ""

	local objs = mission.objectives or {}
	for i, obj in ipairs(objs) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.Position = UDim2.new(0, 0, 0, (i - 1) * 24)
		row.BackgroundTransparency = 1
		row.Parent = objectivesList

		local check = Instance.new("TextLabel")
		check.Size = UDim2.new(0, 18, 1, 0)
		check.Position = UDim2.new(0, 0, 0, 0)
		check.BackgroundTransparency = 1
		check.TextColor3 = completedObjectives[obj.id]
			and Color3.fromRGB(110, 220, 110)
			or Color3.fromRGB(80, 70, 60)
		check.Font = Enum.Font.GothamBold
		check.TextSize = 14
		check.TextXAlignment = Enum.TextXAlignment.Left
		check.Text = completedObjectives[obj.id] and "✓" or "○"
		check.Parent = row

		local txt = Instance.new("TextLabel")
		txt.Size = UDim2.new(1, -22, 1, 0)
		txt.Position = UDim2.new(0, 22, 0, 0)
		txt.BackgroundTransparency = 1
		txt.TextColor3 = completedObjectives[obj.id]
			and Color3.fromRGB(140, 200, 140)
			or Color3.fromRGB(220, 200, 170)
		txt.Font = completedObjectives[obj.id] and Enum.Font.Gotham or Enum.Font.GothamMedium
		txt.TextSize = 12
		txt.TextXAlignment = Enum.TextXAlignment.Left
		txt.TextTruncate = Enum.TextTruncate.AtEnd
		txt.Text = obj.text
		txt.Parent = row
	end
end

-- ============================================================================
-- Écoute des évènements (vagues, lieux visités, photos prises)
-- ============================================================================
-- Pour l'instant, validation auto par numéro de vague (les autres objectifs
-- type touch_poi/photo seront validés quand MissionService.lua sera créé).
local function checkWave(currentWave)
	local mission = Story.Missions[currentMissionIdx]
	if not mission or not mission.objectives then return end
	for _, obj in ipairs(mission.objectives) do
		if obj.type == "wave" and obj.target and currentWave >= obj.target then
			completedObjectives[obj.id] = true
		end
	end
	renderObjectives()
end

-- Écoute WaveUpdate (numérique)
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
if Remotes then
	local waveR = Remotes:FindFirstChild("WaveUpdate")
	if waveR then
		waveR.OnClientEvent:Connect(function(arg1, arg2)
			if typeof(arg1) == "number" then
				checkWave(arg1)
			end
		end)
	end

	-- Écoute MissionUpdate (état serveur des objectifs)
	local missionR = Remotes:FindFirstChild("MissionUpdate")
	if missionR then
		missionR.OnClientEvent:Connect(function(missionIdx, objectives)
			if typeof(missionIdx) == "number" then
				currentMissionIdx = missionIdx
			end
			if typeof(objectives) == "table" then
				completedObjectives = {}
				for id, done in pairs(objectives) do
					if done then completedObjectives[id] = true end
				end
			end
			renderObjectives()
		end)
	end
end

-- Toggle avec M (Mission)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.M then
		frame.Visible = not frame.Visible
	end
end)

-- Expose pour MobileControls
_G.ToggleMissionHUD = function()
	frame.Visible = not frame.Visible
end

-- Render initial après un délai (le temps que Story se charge)
task.wait(2)
renderObjectives()

print("[MissionHUD] Pret. Touche M pour toggle. Affiche les " ..
	#Story.Missions[1].objectives .. " objectifs de Saint-Denis.")
