local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Characters = ReplicatedStorage.Characters

local Signal = require(Packages.signal)

local SquidwardModel = require(Characters.Squidward)

local squidward = {}
local squidwardPrototype = {}
local squidwardPrivate = {}

function squidward.new()
    local self = {}
    local private = {}

    self.healthChanged = Signal.new()

    private.health = 100
    private.workspaceModel = nil

    squidwardPrivate[self] = private

    return setmetatable(self, squidwardPrototype)
end

function squidwardPrototype:spawn()
    local private = squidwardPrivate[self]

    local squidwardClone = SquidwardModel:Clone()
    squidwardClone.Parent = workspace

    private.workspaceModel = squidwardClone
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