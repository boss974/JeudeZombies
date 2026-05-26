-- MegaJump.client.lua
-- Touche LEFT SHIFT pendant qu'on saute → bond x3 (mega jump).
-- Cooldown 4 secondes pour éviter le spam.
-- Effet : particules au pied + son.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local JUMP_MULTIPLIER = 3
local COOLDOWN = 4
local lastUsed = 0

local function getCharacterParts()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid", 5)
	local root = char:WaitForChild("HumanoidRootPart", 5)
	return char, hum, root
end

local function megaJump()
	if tick() - lastUsed < COOLDOWN then return end
	local char, hum, root = getCharacterParts()
	if not hum or not root then return end
	if hum:GetState() == Enum.HumanoidStateType.Dead then return end

	lastUsed = tick()

	-- Impulsion verticale : ajoute une BodyVelocity courte
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(0, math.huge, 0)
	bv.Velocity = Vector3.new(0, 120, 0)
	bv.Parent = root
	game:GetService("Debris"):AddItem(bv, 0.25)

	-- Particules au pied (poussière)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(244, 185, 66))
	emitter.Size = NumberSequence.new(2, 5)
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.3),
		NumberSequenceKeypoint.new(1,   1),
	})
	emitter.Lifetime = NumberRange.new(0.4, 0.7)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(6, 14)
	emitter.SpreadAngle = Vector2.new(80, 80)
	emitter.EmissionDirection = Enum.NormalId.Bottom
	emitter.Parent = root
	emitter:Emit(20)
	game:GetService("Debris"):AddItem(emitter, 1)

	-- Son
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxasset://sounds/action_jump.mp3"
	sound.Volume = 0.6
	sound.PlaybackSpeed = 0.8
	sound.Parent = root
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 1.5)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.LeftShift then
		megaJump()
	end
end)

-- Expose pour MobileControls (bouton tactile)
_G.MegaJumpTrigger = megaJump

-- HUD discret : indicateur de cooldown en bas gauche
local pg = player:WaitForChild("PlayerGui")
local screen = Instance.new("ScreenGui")
screen.Name = "MegaJumpHud"
screen.ResetOnSpawn = false
screen.Parent = pg

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 180, 0, 22)
label.AnchorPoint = Vector2.new(0, 1)
label.Position = UDim2.new(0, 20, 1, -20)
label.BackgroundTransparency = 0.4
label.BackgroundColor3 = Color3.fromRGB(20, 18, 12)
label.BorderSizePixel = 0
label.Text = "SHIFT : Saut géant"
label.TextColor3 = Color3.fromRGB(244, 185, 66)
label.Font = Enum.Font.GothamBold
label.TextSize = 13
label.Parent = screen
local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = label

task.spawn(function()
	while screen.Parent do
		local remaining = COOLDOWN - (tick() - lastUsed)
		if remaining > 0 then
			label.Text = string.format("SHIFT : prêt dans %.1fs", remaining)
			label.TextColor3 = Color3.fromRGB(150, 100, 80)
		else
			label.Text = "SHIFT : Saut géant"
			label.TextColor3 = Color3.fromRGB(244, 185, 66)
		end
		task.wait(0.1)
	end
end)

print("[MegaJump] SHIFT = saut geant x3 (cooldown 4s).")
