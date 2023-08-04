local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Roact = require(Packages.roact)

return function(props)
    local onBurgerButtonActivated = props.onBurgerButtonActivated

    return Roact.createElement("TextButton", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 0.6,
        BackgroundColor3 = Color3.fromRGB(18, 161, 32),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromScale(0.1, 0.1),
        Text = "Throw Burger!",
        TextScaled = true,
        TextColor3 = Color3.fromRGB(171, 132, 6),
        TextStrokeTransparency = 0.6,
        [Roact.Event.Activated] = onBurgerButtonActivated,
    })
end