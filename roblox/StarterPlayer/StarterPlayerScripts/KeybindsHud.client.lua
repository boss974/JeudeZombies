-- KeybindsHud.client.lua
-- Petit panneau rappel des touches.
-- - Visible 12 secondes après le spawn
-- - TAB toggle on/off
-- - Style "panneau créole" sombre + or

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local screen = Instance.new("ScreenGui")
screen.Name = "KeybindsHud"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = pg

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 360)
frame.AnchorPoint = Vector2.new(1, 0.5)
frame.Position = UDim2.new(1, -20, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(28, 18, 14)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = screen
local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 8); c.Parent = frame
local s = Instance.new("UIStroke"); s.Color = Color3.fromRGB(184, 144, 44); s.Thickness = 1.5; s.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -16, 0, 26)
title.Position = UDim2.new(0, 8, 0, 6)
title.BackgroundTransparency = 1
title.Text = "⌨ TOUCHES (TAB pour cacher)"
title.TextColor3 = Color3.fromRGB(255, 230, 100)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local KEYBINDS = {
	{ "WASD/ZQSD", "Se déplacer" },
	{ "Espace",    "Sauter" },
	{ "SHIFT",     "Saut géant" },
	{ "Clic G",    "Tirer (maintien=rafale)" },
	{ "Clic D",    "Poser défense" },
	{ "1 / 2",     "Tourelle / Barricade" },
	{ "E",         "Interagir" },
	{ "Marche →",  "Ramasser pickup" },
	{ "Portail →", "Téléporter ville" },
	{ "TAB",       "Afficher / cacher ceci" },
	{ "/",         "Chat Roblox" },
}

for i, kb in ipairs(KEYBINDS) do
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -16, 0, 26)
	row.Position = UDim2.new(0, 8, 0, 36 + (i - 1) * 28)
	row.BackgroundTransparency = (i % 2 == 0) and 0.9 or 1
	row.BackgroundColor3 = Color3.fromRGB(50, 35, 25)
	row.BorderSizePixel = 0
	row.Parent = frame

	local k = Instance.new("TextLabel")
	k.Size = UDim2.new(0, 110, 1, 0)
	k.Position = UDim2.new(0, 6, 0, 0)
	k.BackgroundTransparency = 1
	k.Text = kb[1]
	k.TextColor3 = Color3.fromRGB(255, 220, 100)
	k.Font = Enum.Font.GothamBold
	k.TextSize = 12
	k.TextXAlignment = Enum.TextXAlignment.Left
	k.Parent = row

	local v = Instance.new("TextLabel")
	v.Size = UDim2.new(1, -120, 1, 0)
	v.Position = UDim2.new(0, 120, 0, 0)
	v.BackgroundTransparency = 1
	v.Text = kb[2]
	v.TextColor3 = Color3.fromRGB(220, 200, 180)
	v.TextSize = 12
	v.TextXAlignment = Enum.TextXAlignment.Left
	v.Parent = row
end

-- Apparition automatique au spawn pendant 12s
task.spawn(function()
	task.wait(2)
	frame.Visible = true
	frame.BackgroundTransparency = 1
	TweenService:Create(frame, TweenInfo.new(0.4), { BackgroundTransparency = 0.15 }):Play()
	task.wait(12)
	TweenService:Create(frame, TweenInfo.new(0.6), { BackgroundTransparency = 1 }):Play()
	task.wait(0.7)
	frame.Visible = false
end)

-- Toggle TAB
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Tab then
		frame.Visible = not frame.Visible
		frame.BackgroundTransparency = 0.15
	end
end)
