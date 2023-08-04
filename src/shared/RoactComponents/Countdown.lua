local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Roact = require(Packages.ReplicatedStorage)

local COUNTDOWN_MESSAGE = "Countdown:  "

return function(props)
    local countdownTime = props.countdownTime

    local text = COUNTDOWN_MESSAGE .. countdownTime

    return Roact.createElement("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Color3.fromRGB(35, 71, 215),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.fromScale(0.2, 0.1),
        Text = text,
        TextScaled = true,
    }, {
        UICorner = Roact.createElement("UICorner", {
            CornerRaidus = UDim.new(0.1, 0),
        })
    })
end