local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage.Packages
local Characters = ReplicatedStorage.Characters
local Items = ReplicatedStorage.Items

local Signal = require(Packages.signal)

local SquidwardModel = Characters.Squidward

local squidward = {}
local squidwardPrototype = {}
local squidwardPrivate = {}

local function _getClosestCharacter(modelPosition)
    local distances = {}

    
    local burgersInTheWorkspace = workspace.Burgers:GetChildren()
    local burgersExist = next(burgersInTheWorkspace) ~= nil
    if burgersExist then
        return burgersInTheWorkspace[math.random(1, #burgersInTheWorkspace)] -- get random burger
    end

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if not character then
			continue
		end
		
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then
			continue
		end
		
		if humanoid.Health <= 0 then
			continue
		end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            continue
        end

        local characterPosition = humanoidRootPart.Position

        local distanceBetweenZombieAndPlayer = (modelPosition - characterPosition).Magnitude
        distances[character] = distanceBetweenZombieAndPlayer
	end

    local sortedKeys = {}
	for key in pairs(distances) do
		table.insert(sortedKeys, key)
	end

	table.sort(sortedKeys, function(a, b)
		return distances[a] < distances[b]
	end)

    local closestCharacter = sortedKeys[1]

    return closestCharacter
end

function squidward.new()
    local instance = {}
    local private = {}

    instance.healthChanged = Signal.Fast.new()
    instance.hasDied = Signal.Fast.new()

    private.health = 100
    private.workspaceModel = nil

    squidwardPrivate[instance] = private

    return setmetatable(instance, squidwardPrototype)
end

function squidwardPrototype:spawn()
    local private = squidwardPrivate[self]

    local squidwardClone = SquidwardModel:Clone()
    squidwardClone.Parent = workspace.Squidwards

    private.workspaceModel = squidwardClone
end

function squidwardPrototype:findPath()
    local private = squidwardPrivate[self]

    local workspaceModel = private.workspaceModel
    local modelPrimaryPart = workspaceModel.PrimaryPart
    if not modelPrimaryPart then
        return
    end

    local modelPosition = modelPrimaryPart.Position

    local closestCharacter = _getClosestCharacter(modelPosition)
    if not closestCharacter then
        return
    end

    local moveToPosition
    if closestCharacter.Name == "Burger" then
        moveToPosition = closestCharacter.Position
    else
        local closestCharacterRootPart = closestCharacter:FindFirstChild("HumanoidRootPart")
        if not closestCharacterRootPart then
            return warn("Attempt to index nil with root part.")
        end

        moveToPosition = closestCharacterRootPart.Position
    end

    workspaceModel:MoveTo(moveToPosition)
end

function squidwardPrototype:addHealth(amount)
    local private = squidwardPrivate[self]

    private.health += amount
    self.healthChanged:Fire(private.health)
end

function squidwardPrototype:subtractHealth(amount)
    local private = squidwardPrivate[self]

    private.health -= amount
    self.healthChanged:Fire(private.health)
end

function squidwardPrototype:getWorkspaceModel()
    local private = squidwardPrivate[self]

    return private.workspaceModel
end

function squidwardPrototype:destroy()
    local private = squidwardPrivate[self]

    private.workspaceModel:Destroy()

    self.healthChanged:Destroy()
    self = nil
end

squidwardPrototype.__index = squidwardPrototype
squidwardPrototype.__metatable = "This metatable is locked."
squidwardPrototype.__newindex = function(_, _, _)
    error("This metatable is locked.")
end

return squidward