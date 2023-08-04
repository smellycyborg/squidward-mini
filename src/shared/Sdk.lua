local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Common = ReplicatedStorage.Common
local Packages = ReplicatedStorage.Packages

local Squidward = require(Common.SquidwardClass)
local Timer = require(Packages.timer)
local Comm = require(Packages.comm)
local Promise = require(Packages.promise)

local serverComm = Comm.ServerComm.new(ReplicatedStorage, "MainComm")

local ROUND_TIME = 6
local INTERMISSION_TIME = 2
local TIMER_INTERVAL = 1
local MAX_BURGERS = 5
local KILLS_TO_ACTIVATE_NEXT_WAVE = 4
local MAX_SQUIDWARDS = 6
local REJECT_MESSAGE = "You has max burgers.  Try throwing some!"
local RESOLVE_MESSAGE = "You have filled up your burgers.  Throw them at squidward or eat them for health!"

local roundTimeLeft = ROUND_TIME
local intermissionTimeLeft = INTERMISSION_TIME
local timeElapsed = 0

local isFindingPaths = false
local noMoreSquidwards = false

local Sdk = {
    gameWave = 1,
    killsDuringRound = 0,
    gameState = "INTERMISSION",
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
    local killsDuringRound = Sdk.killsDuringRound

    print("Timer:  The game state is current " .. gameState .. ".")

    local isIntermission = gameState == "INTERMISSION"
    local isRoundInProgress = gameState == "ROUND_IN_PROGESS"

    if killsDuringRound >= KILLS_TO_ACTIVATE_NEXT_WAVE then
        noMoreSquidwards = true
    end

    if noMoreSquidwards and Sdk.gameState ~= "INTERMISSION" then
        Sdk:changeGameState("INTERMISSION")

        noMoreSquidwards = false

        -- Todo something for saying player has won the current wave or game
    end

    if isIntermission then
        intermissionTimeLeft -= 1
        updateCountdownUi:FireAll(intermissionTimeLeft, gameState)

        if intermissionTimeLeft <= 0 then
            Sdk:changeGameState("ROUND_IN_PROGESS")
            intermissionTimeLeft = INTERMISSION_TIME
        end

    elseif isRoundInProgress then
        roundTimeLeft -= 1
        updateCountdownUi:FireAll(roundTimeLeft, gameState)

        local workspaceSquidswardsFolder = workspace.Squidwards
        local squidwardsInTheWorkspace = #workspaceSquidswardsFolder:GetChildren()
        if squidwardsInTheWorkspace >= MAX_SQUIDWARDS then
            return 
        end

        local function onSquidwardHealthChanged()
        end

        local function onSquidwardHasDied()
            Sdk:addToKills()
        end

        local newSquidward = Squidward.new()
        newSquidward.healthChanged:Connect(onSquidwardHealthChanged)
        newSquidward.hasDied:Connect(onSquidwardHasDied)
        
        table.insert(Sdk.squidwardInstances, newSquidward)

        newSquidward:spawn()

        if roundTimeLeft <= 0 then
            Sdk:changeGameState("INTERMISSION")
            roundTimeLeft = ROUND_TIME

            Sdk:clearSquidwardInstances()

            -- Todo something for saying player has lost the game
        end
    end
end

local function onPrompButtonHoldEnded(prompt, player)
    local isBurgersPrompt = prompt.Parent.Name == "BurgersPrompt"
    if isBurgersPrompt then
        local function addBurgersToPlayerPromise()
            return Promise.new(function(resolve, reject, onCancel)
                local playerBurgers = Sdk.burgersPerPlayer[player]

                if playerBurgers >= MAX_BURGERS then
                    reject(REJECT_MESSAGE)
                elseif playerBurgers < MAX_BURGERS then
                    resolve(RESOLVE_MESSAGE)
                end
            end)
        end

        local function onReject(message)
            sendNotifictionToPlayer:Fire(player, message)
        end

        local function onResolve(message)
            sendNotifictionToPlayer:Fire(player, message)
        end

        addBurgersToPlayerPromise()
        :andThen(onResolve)
        :catch(onReject)
    end
end

local function onHeartbeat(deltaTime)
    timeElapsed += deltaTime

    if not isFindingPaths then
        isFindingPaths = true

        for _, squidward in ipairs(Sdk.squidwardInstances) do
            local hasSpawned = squidward:getWorkspaceModel()
            if not hasSpawned then
                continue
            end
            
            squidward:findPath()
        end

        isFindingPaths = false
    end
end

function Sdk.init()
    updateCountdownUi = serverComm:CreateSignal("UpdateCountdownUi")
    updateBurgersUi = serverComm:CreateSignal("UpdateBurgersUi")
    sendNotifictionToPlayer = serverComm:CreateSignal("SendNotificationToPlayer")

    local timer = Timer.new(TIMER_INTERVAL)
    timer.Tick:Connect(onTimerTick)
    timer:Start()

    -- if any players have already loaded in and server code has been run (edge case)
    for _, player in ipairs(Players:GetChildren()) do
        task.spawn(onPlayerAdded, player)
    end

    -- bindings
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
    ProximityPromptService.PromptButtonHoldEnded:Connect(onPrompButtonHoldEnded)
    RunService.Heartbeat:Connect(onHeartbeat)
end

function Sdk:changeGameState(newState)
    Sdk.gameState = newState
end

function Sdk:clearSquidwardInstances()
    for _, squidward in Sdk.squidwardInstances do
        squidward:destroy()
    end

    table.clear(Sdk.squidwardInstances)
end

function Sdk:addToKills()
    Sdk.killsDuringRound += 1
end

return Sdk