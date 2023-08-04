local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Common = ReplicatedStorage:WaitForChild("Common")

local Roact = require(Packages:WaitForChild("roact"))
local MainContainer = require(Common:WaitForChild("MainContainer"))
local Comm = require(Packages.comm)

local clientComm = Comm.ClientComm.new(ReplicatedStorage, false, "MainComm")
local updateCountdownUi = clientComm:GetSignal("UpdateCountdownUi")
local sendNotifictionToPlayer = clientComm:GetSignal("SendNotificationToPlayer")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local countdownTime = 0
local notificationMessage = ""

local handle

local view = Roact.createElement(MainContainer, {
    countdownTime = countdownTime,
    notificationMessage = notificationMessage,
})

local function updateHandle()
    Roact.update(handle, Roact.createElement(MainContainer, {
        countdownTime = countdownTime,
        notificationMessage = notificationMessage,
    }), playerGui, "MainContainer")
end

handle = Roact.mount(view, playerGui, "MainContainer")

local function onUpdateCountdownUi(timeLeft)
    countdownTime = timeLeft

    updateHandle()

    return countdownTime
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
sendNotifictionToPlayer:Connect(onSendNotificationToPlayer)