--[[
    MapPathService.lua

    Génère une base de map simple avec un chemin sinueux.
    Objectif : donner aux zombies un chemin clair à suivre sans faire une ligne droite.

    À placer dans ServerScriptService/Services ou synchroniser via Rojo plus tard.
]]

local MapPathService = {}

-- Waypoints volontairement non alignés.
-- Les zombies doivent suivre ces points dans l'ordre.
MapPathService.Waypoints = {
    Vector3.new(-80, 1, -70), -- Spawn zombies
    Vector3.new(-45, 1, -70),
    Vector3.new(-45, 1, -25),
    Vector3.new(-10, 1, -25),
    Vector3.new(-10, 1, 25),
    Vector3.new(35, 1, 25),
    Vector3.new(35, 1, -15),
    Vector3.new(70, 1, -15),
    Vector3.new(70, 1, 60), -- Base à défendre
}

local function createPart(name, size, position, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.Size = size
    part.Position = position
    part.Color = color
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

function MapPathService:CreatePrototypeMap()
    local mapFolder = Instance.new("Folder")
    mapFolder.Name = "PrototypeTowerDefenseMap"
    mapFolder.Parent = workspace

    createPart("Ground", Vector3.new(190, 1, 170), Vector3.new(0, 0, 0), Color3.fromRGB(90, 170, 90), mapFolder)

    -- Création visuelle du chemin entre les waypoints.
    for index = 1, #self.Waypoints - 1 do
        local a = self.Waypoints[index]
        local b = self.Waypoints[index + 1]
        local middle = (a + b) / 2
        local distance = (a - b).Magnitude
        local pathPart = createPart("PathSegment_" .. index, Vector3.new(10, 0.25, distance), middle, Color3.fromRGB(185, 155, 105), mapFolder)
        pathPart.CFrame = CFrame.lookAt(middle, b)
    end

    createPart("ZombieSpawn", Vector3.new(12, 2, 12), self.Waypoints[1], Color3.fromRGB(120, 70, 70), mapFolder)
    createPart("BaseToDefend", Vector3.new(18, 8, 18), self.Waypoints[#self.Waypoints] + Vector3.new(0, 4, 0), Color3.fromRGB(80, 120, 220), mapFolder)

    -- Décor simple : arbres et fontaine.
    createPart("LobbyFountain", Vector3.new(14, 2, 14), Vector3.new(0, 1, 65), Color3.fromRGB(80, 160, 220), mapFolder)

    for i = 1, 10 do
        local x = -85 + (i * 17)
        createPart("SimpleTree_" .. i, Vector3.new(4, 12, 4), Vector3.new(x, 6, 78), Color3.fromRGB(40, 120, 45), mapFolder)
    end

    return mapFolder
end

function MapPathService:GetWaypoints()
    return self.Waypoints
end

return MapPathService
