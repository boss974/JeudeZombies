-- StoryUI.client.lua
-- Construit l'écran d'intro + le HUD de dialogue narratif.
-- Reste léger : pas de framework, juste Instance.new.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Story = require(Shared:WaitForChild("Story"))
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- ============================================================================
-- INTRO SCREEN
-- ============================================================================
local function buildIntro()
	local screen = Instance.new("ScreenGui")
	screen.Name = "IntroScreen"
	screen.IgnoreGuiInset = true
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 100
	screen.Parent = pg

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(10, 8, 14)
	bg.BorderSizePixel = 0
	bg.Parent = screen

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(40, 15, 10)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 8, 14)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(5, 5, 8)),
	}
	grad.Rotation = 90
	grad.Parent = bg

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.12, 0)
	title.Position = UDim2.new(0, 0, 0.12, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(255, 100, 60)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Text = Story.Title
	title.Parent = bg

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, 0, 0.04, 0)
	subtitle.Position = UDim2.new(0, 0, 0.25, 0)
	subtitle.BackgroundTransparency = 1
	subtitle.TextColor3 = Color3.fromRGB(220, 220, 220)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextScaled = true
	subtitle.Text = Story.Subtitle
	subtitle.Parent = bg

	local lore = Instance.new("TextLabel")
	lore.Size = UDim2.new(0.7, 0, 0.45, 0)
	lore.Position = UDim2.new(0.15, 0, 0.32, 0)
	lore.BackgroundTransparency = 1
	lore.TextColor3 = Color3.fromRGB(230, 220, 200)
	lore.Font = Enum.Font.Gotham
	lore.TextWrapped = true
	lore.TextSize = 22
	lore.TextYAlignment = Enum.TextYAlignment.Top
	lore.Text = table.concat(Story.Intro, "\n")
	lore.Parent = bg

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 220, 0, 50)
	btn.Position = UDim2.new(0.5, -110, 0.85, 0)
	btn.BackgroundColor3 = Color3.fromRGB(220, 80, 50)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 22
	btn.Text = "Commencer"
	btn.Parent = bg
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		TweenService:Create(bg, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(title, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		TweenService:Create(subtitle, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		TweenService:Create(lore, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
		btn:Destroy()
		task.wait(0.9)
		screen:Destroy()
	end)
end

buildIntro()

-- ============================================================================
-- DIALOG HUD (lignes courtes au-dessus du HUD)
-- ============================================================================
local dialogScreen = Instance.new("ScreenGui")
dialogScreen.Name = "StoryDialogs"
dialogScreen.ResetOnSpawn = false
dialogScreen.Parent = pg

local dialogFrame = Instance.new("Frame")
dialogFrame.Size = UDim2.new(0.6, 0, 0, 70)
dialogFrame.Position = UDim2.new(0.2, 0, 0.78, 0)
dialogFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
dialogFrame.BackgroundTransparency = 0.4
dialogFrame.BorderSizePixel = 0
dialogFrame.Visible = false
dialogFrame.Parent = dialogScreen

local dCorner = Instance.new("UICorner")
dCorner.CornerRadius = UDim.new(0, 8)
dCorner.Parent = dialogFrame

local dStroke = Instance.new("UIStroke")
dStroke.Color = Color3.fromRGB(200, 80, 40)
dStroke.Thickness = 2
dStroke.Parent = dialogFrame

local dialogText = Instance.new("TextLabel")
dialogText.Size = UDim2.new(1, -24, 1, -16)
dialogText.Position = UDim2.new(0, 12, 0, 8)
dialogText.BackgroundTransparency = 1
dialogText.TextColor3 = Color3.fromRGB(255, 230, 160)
dialogText.Font = Enum.Font.GothamMedium
dialogText.TextSize = 22
dialogText.TextWrapped = true
dialogText.TextXAlignment = Enum.TextXAlignment.Center
dialogText.Text = ""
dialogText.Parent = dialogFrame

local function showDialog(text, kind)
	dialogText.Text = text
	if kind == "bossWarning" then
		dStroke.Color = Color3.fromRGB(255, 30, 30)
	elseif kind == "cityCleared" or kind == "waveCleared" then
		dStroke.Color = Color3.fromRGB(80, 200, 90)
	else
		dStroke.Color = Color3.fromRGB(200, 80, 40)
	end
	dialogFrame.Visible = true
	dialogFrame.BackgroundTransparency = 1
	dialogText.TextTransparency = 1
	TweenService:Create(dialogFrame, TweenInfo.new(0.3), { BackgroundTransparency = 0.4 }):Play()
	TweenService:Create(dialogText,  TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
	task.delay(4, function()
		TweenService:Create(dialogFrame, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(dialogText,  TweenInfo.new(0.5), { TextTransparency = 1 }):Play()
		task.wait(0.6)
		if dialogText.Text == text then dialogFrame.Visible = false end
	end)
end

local waveR = Remotes.Get(Constants.RemoteName.WaveUpdate)
if waveR then
	waveR.OnClientEvent:Connect(function(arg1, arg2)
		-- Backward compat : WaveService envoie (wave, status); StoryService envoie (text, kind)
		if typeof(arg1) == "string" then
			showDialog(arg1, arg2)
		end
	end)
end
