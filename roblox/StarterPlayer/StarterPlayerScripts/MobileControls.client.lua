-- MobileControls.client.lua
-- Boutons d'action tactiles pour mobile/tablette. S'active automatiquement
-- si `UserInputService.TouchEnabled` est true (Roblox détecte le device).
--
-- Roblox fournit déjà le joystick gauche + bouton Saut par défaut.
-- On AJOUTE :
--   - SAUT GÉANT (équivalent SHIFT)
--   - POSER DÉFENSE (équivalent clic droit / E)
--   - SWITCH ARME (équivalent 1/2)
--   - PARAMÈTRES (équivalent F1)
--   - TOUCHES (équivalent TAB)
--
-- Layout responsive : tous les boutons à droite de l'écran, taille pouce-friendly
-- (60x60 minimum), badges colorés pour distinguer.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- N'affiche pas sur PC/clavier
if not UserInputService.TouchEnabled then
	-- Affichage forcé en mode Studio "Mobile Device" (pour test)
	if not UserInputService.KeyboardEnabled then
		-- Pas de clavier = on est sur mobile
	else
		-- Console / desktop : on quitte
		return
	end
end

local screen = Instance.new("ScreenGui")
screen.Name = "MobileControls"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = pg

-- ============================================================================
-- Helper : crée un bouton d'action rond avec icône texte
-- ============================================================================
local function makeButton(label, position, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 64, 0, 64)
	btn.AnchorPoint = Vector2.new(1, 1)
	btn.Position = position
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.15
	btn.Text = label
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.TextWrapped = true
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = true
	btn.Parent = screen

	-- Rond avec UICorner
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = btn

	-- Stroke or
	local s = Instance.new("UIStroke")
	s.Color = Color3.fromRGB(255, 230, 100)
	s.Thickness = 2
	s.Parent = btn

	-- Ombre soft
	local sh = Instance.new("ImageLabel")
	sh.Size = UDim2.new(1, 8, 1, 8)
	sh.Position = UDim2.new(0, -4, 0, -2)
	sh.BackgroundTransparency = 1
	sh.Image = "rbxasset://textures/ui/Controls/Glass/RoundedRect.png"
	sh.ImageColor3 = Color3.new(0, 0, 0)
	sh.ImageTransparency = 0.55
	sh.ZIndex = btn.ZIndex - 1
	sh.Parent = btn

	btn.MouseButton1Click:Connect(callback)
	-- Sur mobile, on prend aussi Activated pour fiabilité
	btn.Activated:Connect(callback)
	return btn
end

-- ============================================================================
-- Layout : 5 boutons empilés à droite
-- Ordre (de bas en haut) : Saut géant, Poser défense, Switch arme, Touches, Settings
-- ============================================================================
local rightMargin = 24
local bottomMargin = 200       -- au-dessus du joystick natif Roblox
local spacing = 80             -- 64 + 16 gap

-- 1. SAUT GÉANT (équivalent SHIFT)
makeButton("⬆\nBOND", UDim2.new(1, -rightMargin, 1, -bottomMargin - spacing * 0),
	Color3.fromRGB(0, 153, 184),  -- bleu lagon
	function()
		-- Simule l'appui sur SHIFT via _G hook (MegaJump.client.lua a accroché)
		if _G.MegaJumpTrigger then _G.MegaJumpTrigger() end
	end
)

-- 2. POSER DÉFENSE (équivalent clic droit / E)
makeButton("⚔\nDÉF", UDim2.new(1, -rightMargin, 1, -bottomMargin - spacing * 1),
	Color3.fromRGB(28, 139, 62),  -- vert émeraude
	function()
		if _G.PlaceDefenseTrigger then _G.PlaceDefenseTrigger() end
	end
)

-- 3. SWITCH ARME (cycle entre tourelle / barricade)
local currentDefense = "turret"
makeButton("🔄\nARME", UDim2.new(1, -rightMargin, 1, -bottomMargin - spacing * 2),
	Color3.fromRGB(244, 185, 66),  -- jaune cannelle
	function()
		currentDefense = (currentDefense == "turret") and "barricade" or "turret"
		if _G.SelectDefense then _G.SelectDefense(currentDefense) end
	end
)

-- 4. TOUCHES (équivalent TAB)
makeButton("⌨\nINFO", UDim2.new(1, -rightMargin, 1, -bottomMargin - spacing * 3),
	Color3.fromRGB(120, 120, 130),
	function()
		if _G.ToggleKeybinds then _G.ToggleKeybinds() end
	end
)

-- 5. PARAMÈTRES (équivalent F1)
makeButton("⚙\nMENU", UDim2.new(1, -rightMargin, 1, -bottomMargin - spacing * 4),
	Color3.fromRGB(233, 78, 27),   -- rouge flamboyant
	function()
		if _G.ToggleSettings then _G.ToggleSettings() end
	end
)

-- ============================================================================
-- TIR : sur mobile, le tap sur le canvas du jeu = tir.
-- Le WeaponClient écoute déjà MouseButton1, donc le tap mobile fonctionne natif.
-- On ajoute juste un bouton "TIR" tenu pour faciliter le tir continu sans avoir
-- à viser ET maintenir le doigt sur la zone de jeu.
-- ============================================================================
local fireBtn = Instance.new("TextButton")
fireBtn.Size = UDim2.new(0, 90, 0, 90)
fireBtn.AnchorPoint = Vector2.new(1, 1)
fireBtn.Position = UDim2.new(1, -24, 1, -110)
fireBtn.BackgroundColor3 = Color3.fromRGB(233, 78, 27)
fireBtn.BackgroundTransparency = 0.1
fireBtn.Text = "🔥\nTIR"
fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fireBtn.Font = Enum.Font.GothamBold
fireBtn.TextSize = 18
fireBtn.BorderSizePixel = 0
fireBtn.AutoButtonColor = true
fireBtn.Parent = screen
local fc = Instance.new("UICorner"); fc.CornerRadius = UDim.new(1, 0); fc.Parent = fireBtn
local fs = Instance.new("UIStroke"); fs.Color = Color3.fromRGB(255, 230, 100); fs.Thickness = 3; fs.Parent = fireBtn

-- Tir continu tant que le bouton est enfoncé
local firing = false
fireBtn.MouseButton1Down:Connect(function()
	firing = true
end)
fireBtn.MouseButton1Up:Connect(function()
	firing = false
end)
-- Pour mobile : touch events
fireBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then firing = true end
end)
fireBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then firing = false end
end)

-- Helper : trouve le zombie le plus proche pour auto-aim (mobile sans souris)
local function findClosestZombie(playerPos)
	local Workspace = game:GetService("Workspace")
	local best, bestDist = nil, 80   -- range max de l'auto-aim
	for _, m in ipairs(Workspace:GetChildren()) do
		if m:IsA("Model") and m:GetAttribute("ZombieType") and m.PrimaryPart then
			local hum = m:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then
				local d = (m.PrimaryPart.Position - playerPos).Magnitude
				if d < bestDist then best, bestDist = m, d end
			end
		end
	end
	return best
end

-- Haptic feedback : Roblox HapticService → vibre sur tir/dégâts
local HapticService = game:GetService("HapticService")
local function pulse(intensity, duration)
	-- Sur mobile et certaines manettes Roblox supporte la vibration
	pcall(function()
		HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Large, intensity)
		task.delay(duration or 0.1, function()
			HapticService:SetMotor(Enum.UserInputType.Touch, Enum.VibrationMotor.Large, 0)
		end)
	end)
end

-- Boucle de tir : envoie au serveur tant que firing (avec AUTO-AIM mobile)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local shootR = Remotes:FindFirstChild("ShootRequest")
if shootR then
	task.spawn(function()
		while true do
			if firing then
				local char = player.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				if root then
					-- Auto-aim : cherche le zombie le plus proche dans un rayon de 80 studs
					local target
					local closest = findClosestZombie(root.Position)
					if closest then
						target = closest.PrimaryPart.Position
					else
						-- Pas de cible → tire vers l'avant
						target = root.Position + root.CFrame.LookVector * 50
					end
					shootR:FireServer(target)
					pulse(0.2, 0.05)  -- petite vibration à chaque tir
				end
			end
			task.wait(0.08)
		end
	end)
end

-- Vibration sur dégâts du joueur (écoute changement HP)
task.spawn(function()
	while true do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			local lastHp = hum.Health
			hum.HealthChanged:Connect(function(newHp)
				if newHp < lastHp then
					pulse(0.7, 0.15)   -- vibration plus forte sur dégât
				end
				lastHp = newHp
			end)
			break
		end
		task.wait(0.5)
	end
end)

print("[MobileControls] Boutons tactiles installes (saut, defense, arme, info, menu, tir).")
