local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Common = ReplicatedStorage:WaitForChild("Common")
local RoactComponents = Common:WaitForChild("RoactComponents")

local Roact = require(Packages:WaitForChild("roact"))
local MainContainer = require(RoactComponents:WaitForChild("MainContainer"))
local Comm = require(Packages.comm)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local updateCountdownUi = clientComm:GetSignal("UpdateCountdownUi")
local updateBurgersUi = clientComm:GetSignal("UpdateBurgersUi")
local sendNotifictionToPlayer = clientComm:GetSignal("SendNotificationToPlayer")
local throwBurger = clientComm:GetSignal("ThrowBurger")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local countdownTime = 0
local burgersLeft = 0
local notificationMessage = ""
local gameState = ""

local handle

local view = Roact.createElement(MainContainer, {
    countdownTime = countdownTime,
    burgersLeft = burgersLeft,
    notificationMessage = notificationMessage,
    gameState = gameState,
    throwBurger = throwBurger,
})

local function updateHandle()
    Roact.update(handle, Roact.createElement(MainContainer, {
        countdownTime = countdownTime,
        burgersLeft = burgersLeft,
        notificationMessage = notificationMessage,
        gameState = gameState,
        throwBurger = throwBurger,
    }), playerGui, "MainContainer")
end

handle = Roact.mount(view, playerGui, "MainContainer")

local function onUpdateCountdownUi(timeLeft, newState)
    countdownTime = timeLeft
    gameState = newState

    updateHandle()

    return countdownTime
end

local function onUpdateBurgersUi(newAmount)
    burgersLeft = newAmount

    updateHandle()

    return burgersLeft
end

local function onSendNotificationToPlayer(message)
    notificationMessage = message

    updateHandle()

    task.delay(3.5, function()
        notificationMessage = ""
        updateHandle()
        return notificationMessage
    end)

    return notificationMessage
end

-- bindings
updateCountdownUi:Connect(onUpdateCountdownUi)
updateBurgersUi:Connect(onUpdateBurgersUi)
sendNotifictionToPlayer:Connect(onSendNotificationToPlayer)