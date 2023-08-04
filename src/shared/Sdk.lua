local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Common = ReplicatedStorage.Common
local Packages = ReplicatedStorage.Packages
local Items = ReplicatedStorage.Items

local Squidward = require(Common.SquidwardClass)
local Timer = require(Packages.timer)
local Comm = require(Packages.comm)
local Promise = require(Packages.promise)

local serverComm = Comm.ServerComm.new(ReplicatedStorage, "MainComm")

local ROUND_TIME = 6
local INTERMISSION_TIME = 2
local TIMER_INTERVAL = 1
local MAX_BURGERS = 6
local KILLS_TO_ACTIVATE_NEXT_WAVE = 4
local MAX_SQUIDWARDS = 6
local MAX_BURGERS_MESSAGE = "You has max burgers.  Try throwing some!"
local FILLED_BURGERS_MESSAGE = "You have filled up your burgers.  Throw them at squidward or eat them for health!"
local NO_BURGERS_MESSAGE = "You have no more burgers.  Go to the stove and get more!"

local roundTimeLeft = ROUND_TIME
local intermissionTimeLeft = INTERMISSION_TIME
local timeElapsed = 0

local isFindingPaths = false
local noMoreSquidwards = false

local burgersPerPlayer = {}
local statePerPlayer = {}

local burgerModel = Items.Burger

local Sdk = {
    gameWave = 1,
    killsDuringRound = 0,
    gameState = "INTERMISSION",
    squidwardInstances = {},
}

local function onPlayerAdded(player)
    burgersPerPlayer[player] = 0
    statePerPlayer[player] = "NONE"
end

local function onPlayerRemoving(player)
    burgersPerPlayer[player] = nil
    statePerPlayer[player] = nil 
end

local function onTimerTick()
    local gameState = Sdk.gameState
    local killsDuringRound = Sdk.killsDuringRound

    local isIntermission = gameState == "INTERMISSION"
    local isRoundInProgress = gameState == "ROUND_IN_PROGESS"

    if killsDuringRound >= KILLS_TO_ACTIVATE_NEXT_WAVE then
        noMoreSquidwards = true
    end

    if noMoreSquidwards and gameState ~= "INTERMISSION" then
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
    local playerBurgers = burgersPerPlayer[player]

    local isBurgersPrompt = prompt.Parent.Name == "BurgersPrompt"

    if isBurgersPrompt then

        local function givePlayerBurgersPromise()   
            return Promise.new(function(resolve, reject, onCancel)
                if playerBurgers >= MAX_BURGERS then
                    reject(MAX_BURGERS_MESSAGE)
                elseif playerBurgers < MAX_BURGERS then
        
                    burgersPerPlayer[player] = 6
        
                    resolve(FILLED_BURGERS_MESSAGE)
                end
            end)
        end

        local function onResolve(message)
            sendNotifictionToPlayer:Fire(player, message)
            updateBurgersUi:Fire(player, burgersPerPlayer[player])
        end

        local function onReject(message)
            sendNotifictionToPlayer:Fire(player, message)
        end

        givePlayerBurgersPromise()
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

local function onThrowBurger(player)
    local playerBurgers = burgersPerPlayer[player]

    if playerBurgers <= 0 then
        sendNotifictionToPlayer:Fire(player, NO_BURGERS_MESSAGE)

        return
    end

    local character = player.Character
    if not character then
        return
    end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then
        return
    end

    local characterPosition = humanoidRootPart.Position

    local burgerClone = burgerModel:Clone()
    burgerClone.Position = characterPosition
    burgerClone.Parent = workspace.Burgers

    playerBurgers -= 1
    updateBurgersUi:Fire(player, playerBurgers)
end

function Sdk.init()
    updateCountdownUi = serverComm:CreateSignal("UpdateCountdownUi")
    updateBurgersUi = serverComm:CreateSignal("UpdateBurgersUi")
    sendNotifictionToPlayer = serverComm:CreateSignal("SendNotificationToPlayer")
    local throwBurger = serverComm:CreateSignal("ThrowBurger")

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
    ProximityPromptService.PromptTriggered:Connect(onPrompButtonHoldEnded)
    RunService.Heartbeat:Connect(onHeartbeat)
    throwBurger:Connect(onThrowBurger)
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