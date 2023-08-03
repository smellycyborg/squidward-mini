local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Common = ReplicatedStorage.Common
local Packages = ReplicatedStorage.Packages

local Squidward = require(Common.SquidwardClass)
local Timer = require(Packages.timer)
local Comm = require(Packages.Comm)

local serverComm = Comm.ServerComm.new(ReplicatedStorage, "MainComm")

local ROUND_TIME = 60
local INTERMISSION_TIME = 15
local TIMER_INTERVAL = 1

local roundTimeLeft = ROUND_TIME
local intermissionTimeLeft = INTERMISSION_TIME

local Sdk = {
    gameState = "START",
    gameWave = 1,
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

local function onTimerTick()
    local gameState = Sdk.gameState
    local squidwards = Sdk.squidwardInstances

    local isIntermission = gameState == "INTERMISSION"
    local isRoundInProgress = gameState == "ROUND_IN_PROGRESS"

    if isIntermission then
        intermissionTimeLeft -= 1
        updateCountdownUi:FireAll(intermissionTimeLeft)

        if intermissionTimeLeft <= 0 then
            Sdk:changeGameState("ROUND_IN_PROGESS")
            intermissionTimeLeft = INTERMISSION_TIME
        end
    elseif isRoundInProgress then
        roundTimeLeft -= 1
        updateCountdownUi:FireAll(roundTimeLeft)

        -- Todo spawn squidwards, have squidwards track player position

        if roundTimeLeft <= 0 then
            Sdk:changeGameState("INTERMISSION")
            roundTimeLeft = ROUND_TIME
        end
    end

    if #squidwards <= 0 and Sdk.gameState ~= "INTERMISSION" then
        Sdk:changeGameState("INTERMISSION")
    end
end

function Sdk.init()
    updateCountdownUi = serverComm:CreateSignal("UpdateCountdownUi")

    local timer = Timer.new(TIMER_INTERVAL)
    timer.Tick:Connect(onTimerTick)

    for _, player in ipairs(Players:GetChildren()) do
        task.spawn(onPlayerAdded, player)
    end
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

function Sdk:changeGameState(newState)
    Sdk.gameState = newState
end

return Sdk