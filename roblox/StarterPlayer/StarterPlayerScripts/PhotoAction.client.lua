-- PhotoAction.client.lua
-- Touche E (ou bouton mobile DEF, déjà câblé sur PlaceDefenseTrigger) quand
-- le joueur est près d'un POI → action "photo" :
--   - Flash blanc plein écran (0.3s)
--   - Son obturateur (rbxasset built-in)
--   - Envoie MissionAction("photo", poiId) au serveur
--   - Affiche "📸 Photo prise : <nom POI>"

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local actionR = Remotes:WaitForChild("MissionAction", 10)

local PHOTO_RANGE = 12

-- ============================================================================
-- Flash + notification
-- ============================================================================
local flashScreen = Instance.new("ScreenGui")
flashScreen.Name = "PhotoFlash"
flashScreen.ResetOnSpawn = false
flashScreen.IgnoreGuiInset = true
flashScreen.DisplayOrder = 90
flashScreen.Parent = pg

local flash = Instance.new("Frame")
flash.Size = UDim2.new(1, 0, 1, 0)
flash.BackgroundColor3 = Color3.new(1, 1, 1)
flash.BackgroundTransparency = 1
flash.BorderSizePixel = 0
flash.Parent = flashScreen

local toast = Instance.new("TextLabel")
toast.Size = UDim2.new(0, 380, 0, 50)
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 80)
toast.BackgroundColor3 = Color3.fromRGB(20, 15, 12)
toast.BackgroundTransparency = 1
toast.BorderSizePixel = 0
toast.TextColor3 = Color3.fromRGB(255, 230, 100)
toast.Font = Enum.Font.GothamBold
toast.TextSize = 16
toast.Text = ""
toast.Parent = flashScreen
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 6); tc.Parent = toast
local ts = Instance.new("UIStroke"); ts.Color = Color3.fromRGB(184, 144, 44); ts.Thickness = 2; ts.Transparency = 1; ts.Parent = toast

local function flashAndToast(poiName)
	-- Flash blanc
	flash.BackgroundTransparency = 0
	TweenService:Create(flash, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()

	-- Toast
	toast.Text = "📸 Photo prise : " .. poiName
	toast.BackgroundTransparency = 0.15
	ts.Transparency = 0
	TweenService:Create(toast, TweenInfo.new(0.4), { BackgroundTransparency = 0.15 }):Play()
	task.delay(2.5, function()
		TweenService:Create(toast, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(ts, TweenInfo.new(0.6), { Transparency = 1 }):Play()
	end)

	-- Son obturateur (clickfast en pitch élevé)
	local s = Instance.new("Sound")
	s.SoundId = "rbxasset://sounds/clickfast.wav"
	s.Volume = 0.5
	s.PlaybackSpeed = 1.4
	s.Parent = flashScreen
	s:Play()
	game:GetService("Debris"):AddItem(s, 1)
end

-- ============================================================================
-- Détecte le POI le plus proche
-- ============================================================================
local function findNearestPoi()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end

	local poisFolder = Workspace:FindFirstChild("POIs")
	if not poisFolder then return nil end

	local best, bestDist
	for _, pillar in ipairs(poisFolder:GetChildren()) do
		if pillar:IsA("Part") and pillar:GetAttribute("PoiId") then
			local d = (pillar.Position - root.Position).Magnitude
			if d < PHOTO_RANGE and (not bestDist or d < bestDist) then
				best, bestDist = pillar, d
			end
		end
	end
	return best
end

local function takePhoto()
	local poi = findNearestPoi()
	if not poi then return end
	local poiId = poi:GetAttribute("PoiId")
	local poiName = poi:GetAttribute("PoiName") or poiId
	flashAndToast(poiName)
	actionR:FireServer("photo", poiId)
end

-- ============================================================================
-- Binding clavier (E) + bouton mobile (via _G)
-- ============================================================================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.E then
		takePhoto()
	end
end)

-- Expose pour MobileControls (bouton DEF/ARME peut aussi déclencher)
_G.TakePhoto = takePhoto

print("[PhotoAction] Pret. Touche E pres d'un POI pour prendre une photo.")
