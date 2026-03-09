return (function()

local Library = {}
local Notifications = {}

local Width = 300
local Height = 70
local Padding = 8

local Accent = Color3.fromRGB(170,120,255)

local function UpdateStack()

    local cam = workspace.CurrentCamera
    if not cam then return end

    local size = cam.ViewportSize

    for i,v in ipairs(Notifications) do

        local offset = (Height + Padding) * (i-1)

        local x = size.X - Width - 20
        local y = size.Y - Height - 20 - offset

        v.Base.Position = Vector2.new(x,y)
        v.Accent.Position = Vector2.new(x,y)
        v.Title.Position = Vector2.new(x + 12, y + 8)
        v.Text.Position = Vector2.new(x + 12, y + 30)
        v.Progress.Position = Vector2.new(x, y + Height - 3)

    end

end

function Library:Notify(title,text,time)

    time = time or 4

    local Base = Drawing.new("Square")
    Base.Filled = true
    Base.Color = Color3.fromRGB(28,28,32)
    Base.Size = Vector2.new(Width,Height)
    Base.Transparency = 1

    local AccentBar = Drawing.new("Square")
    AccentBar.Filled = true
    AccentBar.Color = Accent
    AccentBar.Size = Vector2.new(3,Height)
    AccentBar.Transparency = 1

    local Title = Drawing.new("Text")
    Title.Text = title
    Title.Size = 18
    Title.Font = 2
    Title.Color = Color3.fromRGB(235,235,235)
    Title.Outline = true

    local Text = Drawing.new("Text")
    Text.Text = text
    Text.Size = 16
    Text.Font = 2
    Text.Color = Color3.fromRGB(190,190,190)
    Text.Outline = true

    local Progress = Drawing.new("Square")
    Progress.Filled = true
    Progress.Color = Accent
    Progress.Size = Vector2.new(Width,3)

    local Notif = {
        Base = Base,
        Accent = AccentBar,
        Title = Title,
        Text = Text,
        Progress = Progress
    }

    table.insert(Notifications,Notif)

    UpdateStack()

    local start = tick()

    task.spawn(function()

        while tick() - start < time do

            local ratio = 1 - ((tick()-start)/time)
            Progress.Size = Vector2.new(Width * ratio,3)

            task.wait()
        end

        for i,v in ipairs(Notifications) do
            if v == Notif then
                table.remove(Notifications,i)
                break
            end
        end

        Base:Remove()
        AccentBar:Remove()
        Title:Remove()
        Text:Remove()
        Progress:Remove()

        UpdateStack()

    end)

end

return Library

end)()
