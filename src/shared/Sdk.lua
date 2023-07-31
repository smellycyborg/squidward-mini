local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage.Common
local Packages = ReplicatedStorage.Packages

local Squidward = require(Common.SquidwardClass)
local Timer = require(Packages.timer)

local Sdk = {
    gameState = "START",
    squidwardInstances = {},
    statePerPlayer = {},
    burgersPerPlayer = {},
}

local function onPlayerAdded(player)
    Sdk.statePerPlayer[player] = "NONE"
    Sdk.burgersPerPlayer[player] = 0
end

local function onPlayerRemoving(player)
    Sdk.statePerPlayer[player] = nil 
    Sdk.burgersPerPlayer[player] = nil
end

function Sdk.init()
    for _, player in ipairs(Players:GetChildren()) do
        task.spawn(onPlayerAdded, player)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return Sdk