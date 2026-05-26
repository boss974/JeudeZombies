-- WeaponClient.client.lua
-- - Clic gauche : envoie ShootRequest au serveur avec la position visée
-- - Maintien clic : tir continu (limité serveur)
-- - HUD ammo en bas droite
-- - Mouse hit utilise un Raycast 2D depuis la caméra

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Weapons = require(Shared:WaitForChild("Weapons"))

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local mouse = player:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local shootR = Remotes:WaitForChild("ShootRequest")
local snapR  = Remotes:WaitForChild("LoadoutSnapshot")

-- ============================================================================
-- HUD AMMO (bas droite)
-- ============================================================================
local ammoScreen = Instance.new("ScreenGui")
ammoScreen.Name = "AmmoHud"
ammoScreen.ResetOnSpawn = false
ammoScreen.Parent = pg

local ammoFrame = Instance.new("Frame")
ammoFrame.Size = UDim2.new(0, 220, 0, 60)
ammoFrame.AnchorPoint = Vector2.new(1, 1)
ammoFrame.Position = UDim2.new(1, -20, 1, -20)
ammoFrame.BackgroundColor3 = Color3.fromRGB(30, 18, 10)
ammoFrame.BackgroundTransparency = 0.2
ammoFrame.BorderSizePixel = 0
ammoFrame.Parent = ammoScreen
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = ammoFrame
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(184, 144, 44)
stroke.Thickness = 2
stroke.Parent = ammoFrame

local weaponName = Instance.new("TextLabel")
weaponName.Size = UDim2.new(1, -16, 0, 22)
weaponName.Position = UDim2.new(0, 8, 0, 4)
weaponName.BackgroundTransparency = 1
weaponName.Text = "Pistolet"
weaponName.TextColor3 = Color3.fromRGB(244, 185, 66)
weaponName.Font = Enum.Font.GothamBold
weaponName.TextSize = 16
weaponName.TextXAlignment = Enum.TextXAlignment.Left
weaponName.Parent = ammoFrame

local ammoLabel = Instance.new("TextLabel")
ammoLabel.Size = UDim2.new(1, -16, 0, 26)
ammoLabel.Position = UDim2.new(0, 8, 0, 26)
ammoLabel.BackgroundTransparency = 1
ammoLabel.Text = "∞"
ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ammoLabel.Font = Enum.Font.GothamBold
ammoLabel.TextSize = 26
ammoLabel.TextXAlignment = Enum.TextXAlignment.Left
ammoLabel.Parent = ammoFrame

snapR.OnClientEvent:Connect(function(currentId, ammo)
	local w = Weapons.List[currentId]
	if w then
		weaponName.Text = w.name
	end
	if currentId == "Pistol" then
		ammoLabel.Text = "∞"
	else
		ammoLabel.Text = tostring(ammo)
		if ammo <= 5 then
			ammoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		else
			ammoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
end)

-- ============================================================================
-- TIR : clic gauche
-- ============================================================================
local firing = false
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		firing = true
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		firing = false
	end
end)

-- Boucle de tir : envoie au serveur tant que clic
task.spawn(function()
	while true do
		if firing then
			local targetPos = mouse.Hit and mouse.Hit.Position
			if targetPos then
				shootR:FireServer(targetPos)
			end
		end
		task.wait(0.05)
	end
end)

print("[WeaponClient] Pret. Clic gauche = tir, maintien = rafale.")
