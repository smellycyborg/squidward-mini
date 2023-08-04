local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Common = ReplicatedStorage.Common
local RoactComponents = Common.RoactComponents

local Roact = require(Packages.roact)
local Countdown = require(RoactComponents.Countdown)
local Burgers = require(RoactComponents.Burgers)
local Notification = require(RoactComponents.Notification)

local MainContainer = Roact.Component:extend("MainContainer")

function MainContainer:render()
    local countdownTime = self.props.countdownTime
    local burgersLeft = self.props.burgersLeft
    local notificationMessage = self.props.notificationMessage

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false,
    }, {
       Holder = Roact.createElement("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.8, 1),
        SizeConstraint = Enum.SizeConstraint.RelativeXX,
       }, {
            Countdown = Roact.createElement(Countdown, {
                countdownTime = countdownTime,
            }),
            Burgers = Roact.createElement(Burgers, {
                burgersLeft = burgersLeft,
            }),
            Notification = Roact.createElement(Notification, {
                notificationMessage = notificationMessage,
            }),
       })
    })
end

return MainContainer