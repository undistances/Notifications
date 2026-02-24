local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Active = {}

local function newNotification(text)
    local background = Drawing.new("Square")
    background.Size = Vector2.new(200, 50)
    background.Position = Vector2.new(100, 100)
    background.Color = Color3.fromRGB(0,0,0)
    background.Transparency = 0.5
    background.Filled = true
    background.Visible = true

    local message = Drawing.new("Text")
    message.Text = text
    message.Position = Vector2.new(110, 110)
    message.Color = Color3.new(1,1,1)
    message.Center = false
    message.Size = 18
    message.Visible = true
    message.Outline = true

    local notification = {
        background = background,
        message = message
    }

    function notification:destroy()
        self.background:Remove()
        self.message:Remove()
        for i,v in ipairs(Active) do
            if v == self then
                table.remove(Active,i)
                break
            end
        end
    end

    table.insert(Active, notification)
    return notification
end

RunService.RenderStepped:Connect(function(dt)
end)

return newNotification
