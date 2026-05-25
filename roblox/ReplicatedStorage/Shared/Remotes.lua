-- Remotes.lua
-- Crée et expose les RemoteEvents partagés. Appelé par le serveur au démarrage.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Constants)

local Remotes = {}

function Remotes.Init()
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end

	for _, name in pairs(Constants.RemoteName) do
		if not folder:FindFirstChild(name) then
			local r = Instance.new("RemoteEvent")
			r.Name = name
			r.Parent = folder
		end
	end
	return folder
end

function Remotes.Get(name)
	local folder = ReplicatedStorage:WaitForChild("Remotes", 10)
	return folder and folder:WaitForChild(name, 10)
end

return Remotes
