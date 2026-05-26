-- SettingsUI.client.lua
-- Écran de paramètres NON-BLOQUANT :
-- - Le jeu démarre en mode enfant par défaut (jamais d'écran qui bloque)
-- - Accessible à tout moment via la touche F1
-- - Si HasCompletedSetup=false ET que le joueur ouvre F1, le panneau apparaît
-- - Timeout 3s si le serveur ne répond pas → fermeture forcée
-- - Bouton "Passer (mode enfant)" pour skip sans envoyer au serveur

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local saveR = Remotes:WaitForChild(Constants.RemoteName.SaveSettings)
local updR  = Remotes:WaitForChild(Constants.RemoteName.SettingsUpdate)

-- ============================================================================
-- État local
-- ============================================================================
local settingsScreen
local fields = {}
local statusLabel
local currentSettings = {}

-- ============================================================================
-- Helpers UI
-- ============================================================================
local function makeFrame(parent, props)
	local f = Instance.new("Frame")
	for k, v in pairs(props) do f[k] = v end
	f.Parent = parent
	return f
end

local function makeText(parent, text, props)
	local lbl = Instance.new("TextLabel")
	lbl.Text = text
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.fromRGB(244, 220, 180)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	for k, v in pairs(props or {}) do lbl[k] = v end
	lbl.Parent = parent
	return lbl
end

local function makeInput(parent, placeholder, props)
	local box = Instance.new("TextBox")
	box.PlaceholderText = placeholder
	box.BackgroundColor3 = Color3.fromRGB(255, 245, 220)
	box.TextColor3 = Color3.fromRGB(30, 20, 15)
	box.Font = Enum.Font.GothamMedium
	box.TextSize = 16
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	for k, v in pairs(props or {}) do box[k] = v end
	box.Parent = parent
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = box
	local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(184, 144, 44); s.Thickness = 1; s.Parent = box
	return box
end

-- ============================================================================
-- Build UI
-- ============================================================================
local function buildUI()
	settingsScreen = Instance.new("ScreenGui")
	settingsScreen.Name = "SettingsScreen"
	settingsScreen.IgnoreGuiInset = true
	settingsScreen.ResetOnSpawn = false
	settingsScreen.DisplayOrder = 99
	settingsScreen.Parent = pg

	local bg = makeFrame(settingsScreen, {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(15, 10, 10),
	})

	-- Titre
	makeText(bg, "Avant de jouer...", {
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 40),
		TextColor3 = Color3.fromRGB(255, 107, 53),
		Font = Enum.Font.GothamBold,
		TextSize = 36,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	makeText(bg, "Renseigne tes paramètres pour personnaliser ton expérience.", {
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 0, 100),
		TextColor3 = Color3.fromRGB(200, 180, 150),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	-- Carte gauche : champs
	local left = makeFrame(bg, {
		Size = UDim2.new(0, 420, 0, 440),
		Position = UDim2.new(0.5, -440, 0.5, -180),
		BackgroundColor3 = Color3.fromRGB(35, 22, 18),
		BorderSizePixel = 0,
	})
	local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 10); c1.Parent = left
	local s1 = Instance.new("UIStroke"); s1.Color = Color3.fromRGB(184, 144, 44); s1.Thickness = 2; s1.Parent = left

	makeText(left, "🧑 Pseudo", {
		Size = UDim2.new(1, -32, 0, 24),
		Position = UDim2.new(0, 16, 0, 20),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(244, 185, 66),
	})
	fields.pseudo = makeInput(left, "ton pseudo (2-20 caractères)", {
		Size = UDim2.new(1, -32, 0, 40),
		Position = UDim2.new(0, 16, 0, 50),
		Text = player.Name,
	})

	makeText(left, "🎂 Date de naissance (JJ / MM / AAAA)", {
		Size = UDim2.new(1, -32, 0, 24),
		Position = UDim2.new(0, 16, 0, 110),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(244, 185, 66),
	})
	fields.day = makeInput(left, "JJ", {
		Size = UDim2.new(0, 70, 0, 40),
		Position = UDim2.new(0, 16, 0, 140),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	fields.month = makeInput(left, "MM", {
		Size = UDim2.new(0, 70, 0, 40),
		Position = UDim2.new(0, 96, 0, 140),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	fields.year = makeInput(left, "AAAA", {
		Size = UDim2.new(0, 100, 0, 40),
		Position = UDim2.new(0, 176, 0, 140),
		TextXAlignment = Enum.TextXAlignment.Center,
	})

	-- Indication mode
	makeText(left, "Mode de jeu", {
		Size = UDim2.new(1, -32, 0, 24),
		Position = UDim2.new(0, 16, 0, 200),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(244, 185, 66),
	})
	local modeInfo = makeText(left,
		"Par défaut : mode enfant (dialogues cartoon, sans gros mots).",
		{
			Size = UDim2.new(1, -32, 0, 36),
			Position = UDim2.new(0, 16, 0, 226),
			TextColor3 = Color3.fromRGB(200, 180, 150),
			TextSize = 13,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})

	-- Checkbox mode adulte
	local checkBg = makeFrame(left, {
		Size = UDim2.new(0, 24, 0, 24),
		Position = UDim2.new(0, 16, 0, 274),
		BackgroundColor3 = Color3.fromRGB(60, 40, 30),
	})
	local cb2 = Instance.new("UICorner"); cb2.CornerRadius = UDim.new(0, 4); cb2.Parent = checkBg
	local checkMark = makeText(checkBg, "", {
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		TextColor3 = Color3.fromRGB(255, 230, 100),
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
	})

	local cbBtn = Instance.new("TextButton")
	cbBtn.Size = UDim2.new(0, 24, 0, 24)
	cbBtn.Position = UDim2.new(0, 16, 0, 274)
	cbBtn.BackgroundTransparency = 1
	cbBtn.Text = ""
	cbBtn.Parent = left

	local adultLabel = makeText(left,
		"Mode adulte +18 (dialogues familiers, gros mots créoles)",
		{
			Size = UDim2.new(1, -56, 0, 24),
			Position = UDim2.new(0, 48, 0, 274),
			TextColor3 = Color3.fromRGB(120, 100, 90),
			TextSize = 14,
			TextWrapped = true,
		})

	local adultChecked = false
	cbBtn.MouseButton1Click:Connect(function()
		-- Vérifie d'abord l'âge dans les champs
		local d = tonumber(fields.day.Text)
		local m = tonumber(fields.month.Text)
		local y = tonumber(fields.year.Text)
		if not (d and m and y) then
			adultLabel.TextColor3 = Color3.fromRGB(255, 100, 80)
			adultLabel.Text = "Saisis ta date de naissance d'abord."
			return
		end
		local now = os.date("*t")
		local age = now.year - y
		if now.month < m or (now.month == m and now.day < d) then age = age - 1 end
		if age < 18 then
			adultLabel.TextColor3 = Color3.fromRGB(255, 100, 80)
			adultLabel.Text = string.format("Mode adulte verrouillé (tu as %d ans, il faut 18+).", age)
			return
		end
		adultChecked = not adultChecked
		checkMark.Text = adultChecked and "✓" or ""
		adultLabel.TextColor3 = Color3.fromRGB(244, 185, 66)
		adultLabel.Text = adultChecked
			and "Mode adulte ACTIVÉ : dialogues familiers, gros mots créoles."
			or "Mode adulte (+18) — dialogues familiers, gros mots créoles."
	end)

	-- Bouton valider
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -32, 0, 50)
	btn.Position = UDim2.new(0, 16, 1, -66)
	btn.BackgroundColor3 = Color3.fromRGB(233, 78, 27)
	btn.Text = "COMMENCER À JOUER"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.BorderSizePixel = 0
	btn.Parent = left
	local cb = Instance.new("UICorner"); cb.CornerRadius = UDim.new(0, 6); cb.Parent = btn

	statusLabel = makeText(left, "", {
		Size = UDim2.new(1, -32, 0, 36),
		Position = UDim2.new(0, 16, 0, 340),
		TextColor3 = Color3.fromRGB(255, 120, 80),
		TextSize = 13,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})

	btn.MouseButton1Click:Connect(function()
		local birthDate = string.format("%02d/%02d/%04d",
			tonumber(fields.day.Text)   or 0,
			tonumber(fields.month.Text) or 0,
			tonumber(fields.year.Text)  or 0)
		statusLabel.Text = "Envoi en cours..."
		saveR:FireServer({
			Pseudo            = fields.pseudo.Text,
			BirthDate         = birthDate,
			AdultModeEnabled  = adultChecked,
		})
		-- Timeout : si serveur ne répond pas en 3s, on ferme quand même
		-- (le serveur a peut-être déjà enregistré, l'UI ne doit pas bloquer)
		task.delay(3, function()
			if settingsScreen and statusLabel and statusLabel.Text == "Envoi en cours..." then
				statusLabel.Text = "Pas de réponse, fermeture automatique."
				task.wait(0.6)
				if settingsScreen then settingsScreen:Destroy(); settingsScreen = nil end
			end
		end)
	end)

	-- Bouton "Passer" : ferme l'UI sans envoyer au serveur (mode enfant par défaut)
	local skipBtn = Instance.new("TextButton")
	skipBtn.Size = UDim2.new(0, 180, 0, 30)
	skipBtn.Position = UDim2.new(0.5, -90, 1, -36)
	skipBtn.BackgroundColor3 = Color3.fromRGB(60, 50, 40)
	skipBtn.Text = "Passer (mode enfant)"
	skipBtn.TextColor3 = Color3.fromRGB(220, 200, 170)
	skipBtn.Font = Enum.Font.Gotham
	skipBtn.TextSize = 13
	skipBtn.BorderSizePixel = 0
	skipBtn.Parent = bg
	local sbc = Instance.new("UICorner"); sbc.CornerRadius = UDim.new(0, 4); sbc.Parent = skipBtn
	skipBtn.MouseButton1Click:Connect(function()
		if settingsScreen then settingsScreen:Destroy(); settingsScreen = nil end
	end)

	-- ========================================================================
	-- Carte droite : Touches du jeu
	-- ========================================================================
	local right = makeFrame(bg, {
		Size = UDim2.new(0, 380, 0, 440),
		Position = UDim2.new(0.5, 20, 0.5, -180),
		BackgroundColor3 = Color3.fromRGB(35, 22, 18),
		BorderSizePixel = 0,
	})
	local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 10); c2.Parent = right
	local s2 = Instance.new("UIStroke"); s2.Color = Color3.fromRGB(184, 144, 44); s2.Thickness = 2; s2.Parent = right

	makeText(right, "⌨ Touches du jeu", {
		Size = UDim2.new(1, -32, 0, 24),
		Position = UDim2.new(0, 16, 0, 20),
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(244, 185, 66),
	})

	local keybinds = {
		{ "WASD / ZQSD",    "Se déplacer" },
		{ "Espace",          "Sauter" },
		{ "SHIFT",           "Saut géant (cooldown 4s)" },
		{ "Clic gauche",     "Tirer (maintien = rafale)" },
		{ "Clic droit",      "Placer une défense (si dispo)" },
		{ "1 / 2",           "Choisir tourelle / barricade" },
		{ "E",               "Interagir / poser défense" },
		{ "TAB",             "Afficher/masquer la liste des touches" },
		{ "Marcher dessus",  "Ramasser un pickup (food, ammo, coin)" },
		{ "Entrer portail",  "Téléporter vers une autre ville" },
		{ "/",               "Chat Roblox (filtré)" },
	}

	for i, kb in ipairs(keybinds) do
		local row = makeFrame(right, {
			Size = UDim2.new(1, -32, 0, 28),
			Position = UDim2.new(0, 16, 0, 56 + (i - 1) * 30),
			BackgroundTransparency = (i % 2 == 0) and 0.85 or 1,
			BackgroundColor3 = Color3.fromRGB(50, 35, 25),
		})
		makeText(row, kb[1], {
			Size = UDim2.new(0, 140, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			TextColor3 = Color3.fromRGB(255, 230, 100),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
		})
		makeText(row, kb[2], {
			Size = UDim2.new(1, -160, 1, 0),
			Position = UDim2.new(0, 152, 0, 0),
			TextColor3 = Color3.fromRGB(220, 200, 180),
			TextSize = 13,
		})
	end
end

-- ============================================================================
-- Réception update settings
-- ============================================================================
updR.OnClientEvent:Connect(function(settings, ok, msg)
	currentSettings = settings or {}
	if ok and settings and settings.HasCompletedSetup then
		-- Si déjà setup, ferme l'UI
		if settingsScreen then
			TweenService:Create(settingsScreen:FindFirstChildOfClass("Frame"),
				TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
			task.wait(0.6)
			settingsScreen:Destroy()
			settingsScreen = nil
		end
	else
		-- Erreur ou pas setup : (re)affiche
		if not settingsScreen then buildUI() end
		if statusLabel then
			if ok == false then
				statusLabel.Text = "✗ " .. (msg or "Erreur")
				statusLabel.TextColor3 = Color3.fromRGB(255, 120, 80)
			elseif msg and msg ~= "init" and msg ~= "ok" then
				statusLabel.Text = msg
			end
		end
	end
end)

-- NE PAS afficher au démarrage : le jeu doit se lancer directement en mode
-- enfant par défaut. L'écran est accessible via la touche F1.
-- Cf. KeybindsHud : F1 = paramètres (au lieu de TAB qui ouvre la liste touches)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F1 then
		if settingsScreen then
			-- Toggle : si déjà ouvert, on ferme
			settingsScreen:Destroy()
			settingsScreen = nil
		else
			buildUI()
		end
	end
end)

-- Expose le mode adulte au client (pour Story côté client si besoin)
_G.IsAdultMode = function()
	return currentSettings and currentSettings.AdultModeEnabled == true
end
