local ReplicatedStorage = game:GetService("ReplicatedStorage")

local squidward = {}
local squidwardPrototype = {}
local squidwardPrivate = {}

function squidward.new()
    local self = {}
    local private = {}

    private.health = 100
    private.workspaceModel = nil

    squidwardPrivate[self] = private

    return setmetatable(self, squidwardPrototype)
end

function squidwardPrototype:addHealth(amount)
    local private = squidwardPrivate[self]

    private.health += amount
end

function squidwardPrototype:subtractHealth(amount)
    local private = squidwardPrivate[self]

    private.health -= amount
end

function squidwardPrototype:destroy()

end

squidwardPrototype.__index = squidwardPrototype

return squidward