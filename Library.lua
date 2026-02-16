-- // Notifications

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Active = {}

local function easeOutCubic(t)
	return 1 - (1 - t)^3
end

local function recalcPositions()
	for i, notif in ipairs(Active) do
		local targetY = Camera.ViewportSize.Y - 120 - ((i - 1) * 75)
		notif.targetY = targetY
	end
end

RunService.RenderStepped:Connect(function(dt)
	for _, notif in ipairs(Active) do
		if notif.state == "enter" then
			notif.progress += dt * 2.8
			local t = math.clamp(notif.progress, 0, 1)
			local eased = easeOutCubic(t)

			local x = notif.startX + (notif.endX - notif.startX) * eased
			notif:setPosition(x, notif.targetY)

			if t >= 1 then
				notif.state = "idle"
				notif.progress = 0
			end

		elseif notif.state == "exit" then
			notif.progress += dt * 2.8
			local t = math.clamp(notif.progress, 0, 1)
			local eased = easeOutCubic(t)

			local x = notif.endX + (notif.exitX - notif.endX) * eased
			notif:setPosition(x, notif.targetY)

			notif.alpha = 1 - t
			notif:setTransparency(notif.alpha)

			if t >= 1 then
				notif:destroy()
			end
		end
	end
end)

return function(title, description, duration)
	duration = duration or 3

	local width = 280
	local height = 65

	local viewport = Camera.ViewportSize

	local startX = viewport.X + 40
	local endX = viewport.X - width - 30
	local exitX = viewport.X + width + 80

	local baseY = viewport.Y - 120 - (#Active * 75)

	local panel = Drawing.new("Square")
	panel.Size = Vector2.new(width, height)
	panel.Color = Color3.fromRGB(22,22,28)
	panel.Filled = true
	panel.Transparency = 1

	local accent = Drawing.new("Square")
	accent.Size = Vector2.new(4, height)
	accent.Color = Color3.fromRGB(
		math.random(100,255),
		math.random(100,255),
		math.random(100,255)
	)
	accent.Filled = true
	accent.Transparency = 1

	local titleText = Drawing.new("Text")
	titleText.Size = 18
	titleText.Font = 2
	titleText.Color = Color3.fromRGB(240,240,240)
	titleText.Center = false
	titleText.Outline = false
	titleText.Text = title
	titleText.Transparency = 1

	local descText = Drawing.new("Text")
	descText.Size = 16
	descText.Font = 2
	descText.Color = Color3.fromRGB(170,170,180)
	descText.Center = false
	descText.Outline = false
	descText.Text = description
	descText.Transparency = 1

	local notification = {
		state = "enter",
		progress = 0,
		startX = startX,
		endX = endX,
		exitX = exitX,
		targetY = baseY,
		alpha = 1
	}

	function notification:setPosition(x, y)
		panel.Position = Vector2.new(x, y)
		shadow.Position = Vector2.new(x - 3, y + 3)
		accent.Position = Vector2.new(x, y)

		titleText.Position = Vector2.new(x + 14, y + 12)
		descText.Position = Vector2.new(x + 14, y + 34)
	end

	function notification:setTransparency(mult)
		panel.Transparency = mult
		accent.Transparency = mult
		titleText.Transparency = mult
		descText.Transparency = mult
		shadow.Transparency = 0.6 * mult
	end

	function notification:destroy()
		panel:Remove()
		shadow:Remove()
		accent:Remove()
		titleText:Remove()
		descText:Remove()

		for i,v in ipairs(Active) do
			if v == self then
				table.remove(Active, i)
				break
			end
		end

		recalcPositions()
	end

	notification:setPosition(startX, baseY)
	table.insert(Active, notification)
	recalcPositions()

	task.spawn(function()
		while notification.state == "idle" do
			for i = 0, width - 4, 8 do
				accent.Position = Vector2.new(panel.Position.X + i, panel.Position.Y)
				task.wait(0.01)
			end
		end
	end)
  
	task.delay(duration, function()
		notification.state = "exit"
		notification.progress = 0
	end)
end
