-- WaveService.lua
-- Gère la séquence des vagues, le rythme de spawn et les boss.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config    = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))
local Remotes   = require(Shared:WaitForChild("Remotes"))

local ZombieService = require(script.Parent:WaitForChild("ZombieService"))

local WaveService = {}
WaveService.Running = false
WaveService.Wave = 0
local callbacks = {}

local function pickType(wave)
	local r = math.random()
	if wave >= Config.Wave.HeavyUnlockAt and r < 0.2 then return Constants.ZombieType.Heavy end
	if wave >= Config.Wave.FastUnlockAt  and r < 0.5 then return Constants.ZombieType.Fast end
	return Constants.ZombieType.Normal
end

local function broadcastWave(wave, status)
	local r = Remotes.Get(Constants.RemoteName.WaveUpdate)
	if r then r:FireAllClients(wave, status) end
end

function WaveService.Init(cbs)
	callbacks = cbs or {}
	ZombieService.OnKilled = function(player, zombieType)
		if callbacks.OnZombieKilled then callbacks.OnZombieKilled(player, zombieType) end
	end
end

function WaveService.Start()
	if WaveService.Running then return end
	WaveService.Running = true
	WaveService.Wave = 0

	task.spawn(function()
		while WaveService.Running do
			WaveService.Wave += 1
			local n = WaveService.Wave
			local count = Config.Wave.BaseEnemies + Config.Wave.EnemiesPerWave * (n - 1)

			local isBoss = (n % Config.Wave.BossEveryN == 0)
			local isMini = (not isBoss) and (n % Config.Wave.MiniBossEveryN == 0)
			broadcastWave(n, "start")
			if callbacks.OnWaveStart then callbacks.OnWaveStart(n) end
			if isBoss and callbacks.OnBossWave then callbacks.OnBossWave() end

			-- Boss/mini en premier spawn
			if isBoss then
				ZombieService.Spawn(Constants.ZombieType.Boss)
				count -= 1
			elseif isMini then
				ZombieService.Spawn(Constants.ZombieType.MiniBoss)
				count -= 1
			end

			for _ = 1, count do
				while ZombieService.GetActiveCount() >= Config.Wave.MaxActive do
					task.wait(0.2)
				end
				ZombieService.Spawn(pickType(n))
				task.wait(Config.Wave.SpawnInterval)
			end

			-- Attend que la vague soit nettoyée
			while ZombieService.GetActiveCount() > 0 do
				task.wait(0.3)
			end

			broadcastWave(n, "cleared")
			if callbacks.OnWaveCleared then callbacks.OnWaveCleared(n) end
			task.wait(Config.Wave.InterWaveDelay)
		end
	end)
end

function WaveService.Stop()
	WaveService.Running = false
end

return WaveService
