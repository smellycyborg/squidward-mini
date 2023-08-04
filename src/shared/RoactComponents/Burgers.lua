local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Roact = require(Packages.roact)

return function(props)
    local burgersLeft = props.burgersLeft

    return Roact.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromScale(0.1, 0.1),
        Text = burgersLeft,
        TextScaled = true,
        TextColor3 = Color3.fromRGB(171, 132, 6),
        TextStrokeTransparency = 0.6,
    })
end