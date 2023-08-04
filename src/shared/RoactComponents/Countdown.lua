local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Roact = require(Packages.roact)

return function(props)
    local countdownTime = props.countdownTime
    local gameState = props.gameState

    local text = gameState .. " : " .. countdownTime

    return Roact.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(35, 71, 215),
        Position = UDim2.fromScale(0.5, 0.35),
        Size = UDim2.fromScale(0.2, 0.075),
        Text = text,
        TextScaled = true,
    }, {
        UICorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0.1, 0),
        })
    })
end