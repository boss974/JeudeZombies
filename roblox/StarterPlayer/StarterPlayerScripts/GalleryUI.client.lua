-- GalleryUI.client.lua
-- Galerie du joueur : 3 onglets
--   📸 PHOTOS    — photos prises (POI visités)
--   🎁 SOUVENIRS — items thématiques gagnés par ville
--   🏆 SUCCÈS    — achievements débloqués
--
-- Touche G pour ouvrir/fermer. Données synchronisées via CollectionUpdate.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Story        = require(Shared:WaitForChild("Story"))
local Achievements = require(Shared:WaitForChild("Achievements"))
local Constants    = require(Shared:WaitForChild("Constants"))

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local updateR = Remotes:WaitForChild(Constants.RemoteName.CollectionUpdate)
local unlockR = Remotes:WaitForChild(Constants.RemoteName.AchievementUnlocked)

-- État local
local snapshot = {
	Souvenirs    = {},
	Photos       = {},
	Achievements = {},
	Stats        = {},
}
local screen
local currentTab = "photos"

-- ============================================================================
-- Helpers UI
-- ============================================================================
local function clear(parent)
	for _, c in ipairs(parent:GetChildren()) do
		if c:IsA("GuiObject") then c:Destroy() end
	end
end

local function makeCard(parent, idx, icon, title, subtitle, color)
	local row = idx - 1
	local col = (row % 3)
	local line = math.floor(row / 3)

	local card = Instance.new("Frame")
	card.Size = UDim2.new(0, 220, 0, 86)
	card.Position = UDim2.new(0, 14 + col * 232, 0, line * 96)
	card.BackgroundColor3 = Color3.fromRGB(35, 22, 16)
	card.BorderSizePixel = 0
	card.Parent = parent
	local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = card
	local cs = Instance.new("UIStroke"); cs.Color = color or Color3.fromRGB(184, 144, 44); cs.Thickness = 1.5; cs.Parent = card

	local ico = Instance.new("TextLabel")
	ico.Size = UDim2.new(0, 60, 1, 0)
	ico.BackgroundTransparency = 1
	ico.Text = icon
	ico.TextScaled = true
	ico.Font = Enum.Font.GothamBold
	ico.Parent = card

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -72, 0, 26)
	t.Position = UDim2.new(0, 68, 0, 8)
	t.BackgroundTransparency = 1
	t.Text = title
	t.TextColor3 = color or Color3.fromRGB(255, 230, 100)
	t.Font = Enum.Font.GothamBold
	t.TextSize = 13
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextTruncate = Enum.TextTruncate.AtEnd
	t.Parent = card

	local st = Instance.new("TextLabel")
	st.Size = UDim2.new(1, -72, 1, -34)
	st.Position = UDim2.new(0, 68, 0, 32)
	st.BackgroundTransparency = 1
	st.Text = subtitle or ""
	st.TextColor3 = Color3.fromRGB(200, 180, 150)
	st.Font = Enum.Font.Gotham
	st.TextSize = 11
	st.TextXAlignment = Enum.TextXAlignment.Left
	st.TextYAlignment = Enum.TextYAlignment.Top
	st.TextWrapped = true
	st.Parent = card

	return card
end

-- ============================================================================
-- Build UI
-- ============================================================================
local function buildUI()
	screen = Instance.new("ScreenGui")
	screen.Name = "GalleryScreen"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 95
	screen.Parent = pg

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(8, 6, 8)
	bg.BackgroundTransparency = 0.15
	bg.BorderSizePixel = 0
	bg.Parent = screen

	-- Titre
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 48)
	title.Position = UDim2.new(0, 0, 0, 22)
	title.BackgroundTransparency = 1
	title.Text = "🗃 MA COLLECTION"
	title.TextColor3 = Color3.fromRGB(255, 107, 53)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 32
	title.Parent = bg

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 80, 0, 36)
	closeBtn.AnchorPoint = Vector2.new(1, 0)
	closeBtn.Position = UDim2.new(1, -20, 0, 24)
	closeBtn.BackgroundColor3 = Color3.fromRGB(60, 35, 25)
	closeBtn.Text = "✕ Fermer (G)"
	closeBtn.TextColor3 = Color3.fromRGB(220, 200, 170)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 13
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = bg
	local cbc = Instance.new("UICorner"); cbc.CornerRadius = UDim.new(0, 6); cbc.Parent = closeBtn

	-- Tabs
	local tabsFrame = Instance.new("Frame")
	tabsFrame.Size = UDim2.new(0, 540, 0, 36)
	tabsFrame.AnchorPoint = Vector2.new(0.5, 0)
	tabsFrame.Position = UDim2.new(0.5, 0, 0, 78)
	tabsFrame.BackgroundTransparency = 1
	tabsFrame.Parent = bg

	local content = Instance.new("ScrollingFrame")
	content.Size = UDim2.new(0, 720, 1, -150)
	content.AnchorPoint = Vector2.new(0.5, 0)
	content.Position = UDim2.new(0.5, 0, 0, 128)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 6
	content.ScrollBarImageColor3 = Color3.fromRGB(184, 144, 44)
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.Parent = bg

	local TABS = {
		{ id="photos",       icon="📸", label="Photos" },
		{ id="souvenirs",    icon="🎁", label="Souvenirs" },
		{ id="achievements", icon="🏆", label="Succès" },
	}

	local function renderContent()
		clear(content)
		if currentTab == "photos" then
			if #snapshot.Photos == 0 then
				local empty = Instance.new("TextLabel")
				empty.Size = UDim2.new(1, 0, 0, 120)
				empty.BackgroundTransparency = 1
				empty.Text = "Aucune photo encore.\nVa près d'un POI (pilier néon) et appuie E."
				empty.TextColor3 = Color3.fromRGB(160, 140, 110)
				empty.Font = Enum.Font.Gotham
				empty.TextSize = 16
				empty.TextWrapped = true
				empty.Parent = content
				return
			end
			for i, photo in ipairs(snapshot.Photos) do
				-- Cherche le nom du POI dans Story
				local poiName, poiIcon = photo.poiId, "📸"
				for _, m in ipairs(Story.Missions) do
					for _, p in ipairs(m.poi or {}) do
						if p.id == photo.poiId then
							poiName = p.name; poiIcon = p.icon or "📸"
							break
						end
					end
				end
				makeCard(content, i, poiIcon, poiName,
					"Mission : " .. (photo.missionId or "?"),
					Color3.fromRGB(0, 153, 184))
			end
			local lines = math.ceil(#snapshot.Photos / 3)
			content.CanvasSize = UDim2.new(0, 0, 0, lines * 96 + 20)

		elseif currentTab == "souvenirs" then
			local items = {}
			for name in pairs(snapshot.Souvenirs) do table.insert(items, name) end
			if #items == 0 then
				local empty = Instance.new("TextLabel")
				empty.Size = UDim2.new(1, 0, 0, 120)
				empty.BackgroundTransparency = 1
				empty.Text = "Aucun souvenir encore.\nLibère une ville pour gagner son objet emblématique."
				empty.TextColor3 = Color3.fromRGB(160, 140, 110)
				empty.Font = Enum.Font.Gotham
				empty.TextSize = 16
				empty.TextWrapped = true
				empty.Parent = content
				return
			end
			for i, name in ipairs(items) do
				makeCard(content, i, "🎁", name, "",
					Color3.fromRGB(244, 185, 66))
			end
			local lines = math.ceil(#items / 3)
			content.CanvasSize = UDim2.new(0, 0, 0, lines * 96 + 20)

		elseif currentTab == "achievements" then
			local idx = 0
			for id, ach in pairs(Achievements.List) do
				idx = idx + 1
				local unlocked = snapshot.Achievements[id]
				local color = Color3.fromRGB(160, 140, 110)
				if unlocked then
					if ach.tier == "platinum" then color = Color3.fromRGB(200, 200, 255)
					elseif ach.tier == "gold"   then color = Color3.fromRGB(255, 200,  80)
					elseif ach.tier == "silver" then color = Color3.fromRGB(200, 200, 210)
					else                              color = Color3.fromRGB(180, 130,  80)
					end
				end
				local title = (unlocked and "" or "🔒 ") .. ach.title
				makeCard(content, idx, ach.icon, title, ach.desc, color)
			end
			local lines = math.ceil(idx / 3)
			content.CanvasSize = UDim2.new(0, 0, 0, lines * 96 + 20)
		end
	end

	for i, tab in ipairs(TABS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 170, 1, 0)
		btn.Position = UDim2.new(0, (i - 1) * 180, 0, 0)
		btn.BackgroundColor3 = (currentTab == tab.id)
			and Color3.fromRGB(255, 107, 53)
			or Color3.fromRGB(40, 25, 18)
		btn.Text = tab.icon .. " " .. tab.label
		btn.TextColor3 = (currentTab == tab.id)
			and Color3.fromRGB(15, 10, 8)
			or Color3.fromRGB(220, 200, 170)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.BorderSizePixel = 0
		btn.Parent = tabsFrame
		local bbc = Instance.new("UICorner"); bbc.CornerRadius = UDim.new(0, 6); bbc.Parent = btn

		btn.MouseButton1Click:Connect(function()
			currentTab = tab.id
			-- Re-render tabs
			for _, c in ipairs(tabsFrame:GetChildren()) do c:Destroy() end
			-- (refresh)
			-- Plus simple : on rebuild les tabs en redéclarant
			for j, t in ipairs(TABS) do
				local b2 = Instance.new("TextButton")
				b2.Size = UDim2.new(0, 170, 1, 0)
				b2.Position = UDim2.new(0, (j - 1) * 180, 0, 0)
				b2.BackgroundColor3 = (currentTab == t.id)
					and Color3.fromRGB(255, 107, 53)
					or Color3.fromRGB(40, 25, 18)
				b2.Text = t.icon .. " " .. t.label
				b2.TextColor3 = (currentTab == t.id)
					and Color3.fromRGB(15, 10, 8)
					or Color3.fromRGB(220, 200, 170)
				b2.Font = Enum.Font.GothamBold
				b2.TextSize = 14
				b2.BorderSizePixel = 0
				b2.Parent = tabsFrame
				local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 6); bc.Parent = b2
				b2.MouseButton1Click:Connect(function()
					currentTab = t.id
					renderContent()
				end)
			end
			renderContent()
		end)
	end

	closeBtn.MouseButton1Click:Connect(function()
		if screen then screen:Destroy(); screen = nil end
	end)

	renderContent()
end

local function toggle()
	if screen then
		screen:Destroy(); screen = nil
	else
		buildUI()
	end
end

-- ============================================================================
-- Achievement unlock notification (toast en haut centre)
-- ============================================================================
local function showAchievementToast(ach)
	local toast = Instance.new("ScreenGui")
	toast.Name = "AchievementToast"
	toast.ResetOnSpawn = false
	toast.IgnoreGuiInset = true
	toast.DisplayOrder = 200
	toast.Parent = pg

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 380, 0, 70)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.new(0.5, 0, 0, -80)
	frame.BackgroundColor3 = Color3.fromRGB(35, 22, 16)
	frame.BorderSizePixel = 0
	frame.Parent = toast
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = frame
	local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(255, 200, 80); s.Thickness = 2; s.Parent = frame

	local ico = Instance.new("TextLabel")
	ico.Size = UDim2.new(0, 60, 1, 0)
	ico.Position = UDim2.new(0, 8, 0, 0)
	ico.BackgroundTransparency = 1
	ico.Text = ach.icon
	ico.TextScaled = true
	ico.Font = Enum.Font.GothamBold
	ico.Parent = frame

	local lbl1 = Instance.new("TextLabel")
	lbl1.Size = UDim2.new(1, -76, 0, 22)
	lbl1.Position = UDim2.new(0, 70, 0, 8)
	lbl1.BackgroundTransparency = 1
	lbl1.Text = "🏆 SUCCÈS DÉBLOQUÉ"
	lbl1.TextColor3 = Color3.fromRGB(255, 200, 80)
	lbl1.Font = Enum.Font.GothamBold
	lbl1.TextSize = 12
	lbl1.TextXAlignment = Enum.TextXAlignment.Left
	lbl1.Parent = frame

	local lbl2 = Instance.new("TextLabel")
	lbl2.Size = UDim2.new(1, -76, 0, 28)
	lbl2.Position = UDim2.new(0, 70, 0, 30)
	lbl2.BackgroundTransparency = 1
	lbl2.Text = ach.title
	lbl2.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl2.Font = Enum.Font.GothamBold
	lbl2.TextSize = 15
	lbl2.TextXAlignment = Enum.TextXAlignment.Left
	lbl2.TextTruncate = Enum.TextTruncate.AtEnd
	lbl2.Parent = frame

	-- Anim entrée
	TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, 0, 0, 30) }):Play()

	-- Son
	local snd = Instance.new("Sound")
	snd.SoundId = "rbxasset://sounds/button.wav"
	snd.Volume = 0.6
	snd.PlaybackSpeed = 1.2
	snd.Parent = toast
	snd:Play()

	task.delay(4, function()
		TweenService:Create(frame, TweenInfo.new(0.5),
			{ Position = UDim2.new(0.5, 0, 0, -80) }):Play()
		task.wait(0.6)
		toast:Destroy()
	end)
end

-- ============================================================================
-- Bindings
-- ============================================================================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.G then
		toggle()
	end
end)

updateR.OnClientEvent:Connect(function(snap)
	if typeof(snap) == "table" then
		snapshot = snap
		-- Si UI ouverte, re-render
		if screen then
			screen:Destroy(); screen = nil
			buildUI()
		end
	end
end)

unlockR.OnClientEvent:Connect(function(ach)
	if typeof(ach) == "table" and ach.title then
		showAchievementToast(ach)
	end
end)

_G.ToggleGallery = toggle

print("[GalleryUI] Pret. Touche G pour ouvrir.")
