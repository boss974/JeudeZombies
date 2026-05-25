-- AdPlacementService.lua
-- Cree des panneaux de pub en zones calmes. En Studio, un fallback visuel est
-- affiche; en production, remplacer/activer les AdGui selon les regles Roblox.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Monetization = require(Shared:WaitForChild("Monetization"))

local AdPlacementService = {}

local function createFallbackSurface(part, label)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "FallbackAdSurface"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 45
	gui.Parent = part

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(0, 153, 184)
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(244, 185, 66)),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(0, 153, 184)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(233, 78, 27)),
	}
	grad.Rotation = 20
	grad.Parent = frame

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(0.92, 0.8)
	text.Position = UDim2.fromScale(0.04, 0.1)
	text.BackgroundTransparency = 1
	text.Text = label
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.TextWrapped = true
	text.Parent = frame
end

local function createPlacement(placement)
	local folder = workspace:FindFirstChild("AdPlacements")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "AdPlacements"
		folder.Parent = workspace
	end

	local board = Instance.new("Part")
	board.Name = placement.Name
	board.Anchored = true
	board.CanCollide = false
	board.Size = placement.Size
	board.Position = placement.Position
	board.Material = Enum.Material.SmoothPlastic
	board.Color = Color3.fromRGB(45, 45, 45)
	board.Parent = folder

	createFallbackSurface(board, placement.Label)

	local ok, adGui = pcall(function()
		return Instance.new("AdGui")
	end)
	if ok and adGui then
		adGui.Name = "RobloxImmersiveAd"
		adGui.Parent = board
	end
end

function AdPlacementService.Init()
	for _, placement in ipairs(Monetization.AdPlacements) do
		createPlacement(placement)
	end
end

return AdPlacementService
