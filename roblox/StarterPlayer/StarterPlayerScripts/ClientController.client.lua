-- ClientController.client.lua
-- Écoute les Remotes serveur et met à jour l'UI.
-- Le client n'a aucune autorité : il affiche, c'est tout.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes   = require(Shared:WaitForChild("Remotes"))

local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GameUI", 5)

local function setText(name, value)
	if not gui then return end
	local lbl = gui:FindFirstChild(name, true)
	if lbl and lbl:IsA("TextLabel") then lbl.Text = tostring(value) end
end

local waveR  = Remotes.Get(Constants.RemoteName.WaveUpdate)
local scoreR = Remotes.Get(Constants.RemoteName.ScoreUpdate)
local overR  = Remotes.Get(Constants.RemoteName.GameOver)
local shootR = Remotes.Get(Constants.RemoteName.ShootWeapon)
local placeR = Remotes.Get(Constants.RemoteName.PlaceDefense)
local selectedDefense = "Turret"

if waveR then
	waveR.OnClientEvent:Connect(function(wave, status)
		setText("WaveLabel", "Vague " .. wave)
		print(("[Client] Wave %d - %s"):format(wave, status))
	end)
end

if scoreR then
	scoreR.OnClientEvent:Connect(function(score, coins, best)
		setText("ScoreLabel", "Score : " .. score)
		setText("CoinsLabel", "Coins : " .. coins)
		setText("BestLabel",  "Best : "  .. best)
	end)
end

if overR then
	overR.OnClientEvent:Connect(function(payload)
		local panel = gui and gui:FindFirstChild("GameOverPanel", true)
		if panel then panel.Visible = true end
		print("[Client] Game over", payload)
	end)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.One then
		selectedDefense = "Turret"
		print("[Client] Defense selectionnee: Turret")
	elseif input.KeyCode == Enum.KeyCode.Two then
		selectedDefense = "Barricade"
		print("[Client] Defense selectionnee: Barricade")
	end
end)

local mouse = player:GetMouse()
mouse.Button1Down:Connect(function()
	if shootR then shootR:FireServer(mouse.Hit.Position) end
end)

mouse.Button2Down:Connect(function()
	if placeR then placeR:FireServer(selectedDefense, mouse.Hit.Position) end
end)
