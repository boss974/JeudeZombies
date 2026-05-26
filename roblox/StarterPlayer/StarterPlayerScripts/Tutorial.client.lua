-- Tutorial.client.lua
-- Tutoriel séquentiel au premier lancement.
-- 6 bulles affichées les unes après les autres, le joueur passe avec Espace
-- ou tap sur la bulle. Une fois fini, sauvegardé en localStorage Roblox
-- (StarterGui.PlayerGui attribute) pour ne plus réapparaître.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- Détection : déjà vu ?
local KEY = "TutorialSeen_v1"
if player:GetAttribute(KEY) then return end

-- Détecte si mobile pour adapter les libellés
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local STEPS = isMobile and {
	{
		title = "Bienvenue !",
		text = "Tu es à Saint-Denis. Ta mission : protéger les 24 communes de La Réunion.\nLes zombies arrivent depuis la mer.",
		anchor = "center",
	},
	{
		title = "Déplacement",
		text = "Utilise le JOYSTICK en bas à gauche pour te déplacer.\nLe SAUT est à droite (bouton bleu Roblox).",
		anchor = "bottom-left",
	},
	{
		title = "Tirer",
		text = "Maintiens le bouton rouge 🔥 TIR en bas à droite.\nLa visée est automatique sur le zombie le plus proche.",
		anchor = "bottom-right",
	},
	{
		title = "Saut géant",
		text = "Tape ⬆ BOND pour faire un saut x3.\nUtile pour fuir une nuée ou atteindre un endroit haut.",
		anchor = "right",
	},
	{
		title = "Pickups",
		text = "Marche sur les sphères au sol :\n🟢 Vert = +25 HP\n🔵 Bleu = buff dégâts\n🟡 Or = coins permanents",
		anchor = "center",
	},
	{
		title = "C'est parti !",
		text = "Survis aux 3 vagues de Saint-Denis pour libérer la ville et débloquer Saint-Paul.\n\nBonne chance, tilamb !",
		anchor = "center",
	},
} or {
	{
		title = "Bienvenue !",
		text = "Tu es à Saint-Denis. Ta mission : protéger les 24 communes de La Réunion.\nLes zombies arrivent depuis la mer.",
		anchor = "center",
	},
	{
		title = "Déplacement",
		text = "WASD ou ZQSD pour bouger.\nEspace pour sauter.\nSHIFT pour le saut géant.",
		anchor = "bottom-left",
	},
	{
		title = "Tirer",
		text = "Clic gauche pour tirer (maintien = rafale).\nVise avec la souris.",
		anchor = "center",
	},
	{
		title = "Défenses",
		text = "Clic droit ou E pour poser une défense.\nTouches 1 / 2 pour switch tourelle / barricade.",
		anchor = "right",
	},
	{
		title = "Pickups & touches",
		text = "Marche sur les sphères pour ramasser : 🟢 HP, 🔵 buff, 🟡 coins.\n\nTAB = liste touches\nF1 = paramètres",
		anchor = "center",
	},
	{
		title = "C'est parti !",
		text = "Survis aux 3 vagues de Saint-Denis pour libérer la ville et débloquer Saint-Paul.\n\nBonne chance, tilamb !",
		anchor = "center",
	},
}

-- ============================================================================
-- Construction UI
-- ============================================================================
local screen = Instance.new("ScreenGui")
screen.Name = "TutorialScreen"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 80
screen.Parent = pg

-- Overlay semi-transparent (sombre)
local overlay = Instance.new("Frame")
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = Color3.new(0, 0, 0)
overlay.BackgroundTransparency = 0.65
overlay.BorderSizePixel = 0
overlay.Parent = screen

-- Bulle centrale
local bubble = Instance.new("Frame")
bubble.Size = UDim2.new(0, 480, 0, 220)
bubble.AnchorPoint = Vector2.new(0.5, 0.5)
bubble.Position = UDim2.new(0.5, 0, 0.5, 0)
bubble.BackgroundColor3 = Color3.fromRGB(30, 18, 12)
bubble.BorderSizePixel = 0
bubble.Parent = screen

local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 10); bc.Parent = bubble
local bs = Instance.new("UIStroke"); bs.Color = Color3.fromRGB(255, 230, 100); bs.Thickness = 2.5; bs.Parent = bubble

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -32, 0, 40)
titleLabel.Position = UDim2.new(0, 16, 0, 14)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 107, 53)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = ""
titleLabel.Parent = bubble

local bodyLabel = Instance.new("TextLabel")
bodyLabel.Size = UDim2.new(1, -32, 1, -110)
bodyLabel.Position = UDim2.new(0, 16, 0, 58)
bodyLabel.BackgroundTransparency = 1
bodyLabel.TextColor3 = Color3.fromRGB(244, 220, 180)
bodyLabel.Font = Enum.Font.Gotham
bodyLabel.TextSize = 16
bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
bodyLabel.TextWrapped = true
bodyLabel.Text = ""
bodyLabel.Parent = bubble

local progressLabel = Instance.new("TextLabel")
progressLabel.Size = UDim2.new(0, 100, 0, 26)
progressLabel.Position = UDim2.new(0, 16, 1, -36)
progressLabel.BackgroundTransparency = 1
progressLabel.TextColor3 = Color3.fromRGB(160, 140, 110)
progressLabel.Font = Enum.Font.Gotham
progressLabel.TextSize = 13
progressLabel.TextXAlignment = Enum.TextXAlignment.Left
progressLabel.Text = "1/6"
progressLabel.Parent = bubble

local nextBtn = Instance.new("TextButton")
nextBtn.Size = UDim2.new(0, 140, 0, 36)
nextBtn.Position = UDim2.new(1, -156, 1, -46)
nextBtn.BackgroundColor3 = Color3.fromRGB(233, 78, 27)
nextBtn.Text = "Suivant ▶"
nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = 16
nextBtn.BorderSizePixel = 0
nextBtn.Parent = bubble
local nbc = Instance.new("UICorner"); nbc.CornerRadius = UDim.new(0, 6); nbc.Parent = nextBtn

local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(0, 100, 0, 26)
skipBtn.Position = UDim2.new(1, -116, 0, 14)
skipBtn.BackgroundTransparency = 0.6
skipBtn.BackgroundColor3 = Color3.new(0, 0, 0)
skipBtn.Text = "Passer"
skipBtn.TextColor3 = Color3.fromRGB(220, 200, 170)
skipBtn.Font = Enum.Font.Gotham
skipBtn.TextSize = 13
skipBtn.BorderSizePixel = 0
skipBtn.Parent = bubble
local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 4); sbc.Parent = skipBtn

-- ============================================================================
-- Logique séquentielle
-- ============================================================================
local currentStep = 1

local function applyAnchor(anchor)
	-- Positionne la bulle selon le hint d'ancrage
	local positions = {
		["center"]       = { UDim2.new(0.5, 0, 0.5, 0),   Vector2.new(0.5, 0.5) },
		["bottom-left"]  = { UDim2.new(0, 280, 1, -200),  Vector2.new(0, 1) },
		["bottom-right"] = { UDim2.new(1, -280, 1, -200), Vector2.new(1, 1) },
		["right"]        = { UDim2.new(1, -280, 0.5, 0),  Vector2.new(1, 0.5) },
	}
	local p = positions[anchor] or positions["center"]
	bubble.Position = p[1]
	bubble.AnchorPoint = p[2]
end

local function renderStep(i)
	local s = STEPS[i]
	if not s then return end
	titleLabel.Text = s.title
	bodyLabel.Text = s.text
	progressLabel.Text = string.format("%d/%d", i, #STEPS)
	if i == #STEPS then nextBtn.Text = "Jouer ✓" else nextBtn.Text = "Suivant ▶" end
	applyAnchor(s.anchor)
	-- Petite animation : flash de la bulle
	bubble.BackgroundColor3 = Color3.fromRGB(60, 35, 20)
	TweenService:Create(bubble, TweenInfo.new(0.4),
		{ BackgroundColor3 = Color3.fromRGB(30, 18, 12) }):Play()
end

local function endTutorial()
	player:SetAttribute(KEY, true)
	TweenService:Create(overlay, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(bubble, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	task.wait(0.6)
	screen:Destroy()
end

local function nextStep()
	if currentStep >= #STEPS then
		endTutorial()
		return
	end
	currentStep = currentStep + 1
	renderStep(currentStep)
end

nextBtn.MouseButton1Click:Connect(nextStep)
skipBtn.MouseButton1Click:Connect(endTutorial)

-- Espace pour avancer (PC)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.Return then
		nextStep()
	end
end)

-- Démarrage : attend que le joueur ait son personnage + 2s pour pas voler
-- l'attention de l'intro narrative
task.wait(4)
renderStep(1)
