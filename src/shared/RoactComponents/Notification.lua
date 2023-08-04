local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Roact = require(Packages.ReplicatedStorage)

return function(props)
    local notificationMessage = props.notificationMessage

    return Roact.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.fromScale(0.2, 0.1),
        Text = notificationMessage,
    })
end