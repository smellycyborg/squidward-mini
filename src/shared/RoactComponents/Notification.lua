local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Roact = require(Packages.roact)

return function(props)
    local notificationMessage = props.notificationMessage

    return Roact.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 0.6,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.fromScale(0.75, 0.5),
        Size = UDim2.fromScale(0.2, 0.1),
        Text = notificationMessage,
        TextScaled = true,
        TextColor3 = Color3.fromRGB(156, 41, 232),
        TextStrokeTransparency = 0.6,
    })
end