local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Active = {}

local function easeOutCubic(t)
	return 1 - (1 - t)^3
end

local function recalcPositions()
	for i, notif in ipairs(Active) do
		local targetY = Camera.ViewportSize.Y - 140 - ((i - 1) * (notif.height + 16))
		notif.targetY = targetY
	end
end

RunService.RenderStepped:Connect(function(dt)
	for _, notif in ipairs(Active) do
		if notif.state == "enter" then
			notif.progress = math.min(notif.progress + dt * 3, 1)
			local eased = easeOutCubic(notif.progress)
			local x = notif.startX + (notif.endX - notif.startX) * eased
			notif:setPosition(x, notif.targetY)
			notif:setAlpha(eased)
			if notif.progress >= 1 then
				notif.state = "idle"
				notif.progress = 0
			end
		elseif notif.state == "exit" then
			notif.progress = math.min(notif.progress + dt * 3, 1)
			local eased = easeOutCubic(notif.progress)
			local x = notif.endX + (notif.exitX - notif.endX) * eased
			notif:setPosition(x, notif.targetY)
			notif:setAlpha(1 - eased)
			if notif.progress >= 1 then
				notif:destroy()
			end
		elseif notif.state == "idle" then
			notif:setPosition(notif.panel.Position.X, notif.targetY)
			notif:setAlpha(1)
		end
	end
end)

return function(title, description, duration)
	duration = duration or 3
	local width, height = 320, 80
	local startX = Camera.ViewportSize.X + 50
	local endX = Camera.ViewportSize.X - width - 50
	local exitX = Camera.ViewportSize.X + width + 100
	local baseY = Camera.ViewportSize.Y - 140 - (#Active * (height + 16))

	-- outline
	local outline = Drawing.new("Square")
	outline.Size = Vector2.new(width + 2, height + 2)
	outline.Filled = false
	outline.Color = Color3.new(1,1,1)
	outline.Thickness = 2
	outline.Transparency = 1
	outline.Visible = true

	-- panel
	local panel = Drawing.new("Square")
	panel.Size = Vector2.new(width, height)
	panel.Color = Color3.fromRGB(25,25,35)
	panel.Filled = true
	panel.Transparency = 1
	panel.Visible = true

	-- title
	local titleText = Drawing.new("Text")
	titleText.Size = 22
	titleText.Font = 2
	titleText.Color = Color3.fromRGB(255,255,255)
	titleText.Text = title
	titleText.Transparency = 1
	titleText.Visible = true
	titleText.Center = false

	-- description
	local descText = Drawing.new("Text")
	descText.Size = 16
	descText.Font = 2
	descText.Color = Color3.fromRGB(200,200,210)
	descText.Text = description
	descText.Transparency = 1
	descText.Visible = true
	descText.Center = false

	local notif = {
		state = "enter",
		progress = 0,
		startX = startX,
		endX = endX,
		exitX = exitX,
		targetY = baseY,
		width = width,
		height = height,
		panel = panel,
		outline = outline,
		titleText = titleText,
		descText = descText
	}

	function notif:setPosition(x,y)
		outline.Position = Vector2.new(x - 1, y - 1)
		panel.Position = Vector2.new(x, y)
		titleText.Position = Vector2.new(x + 16, y + 16)
		descText.Position = Vector2.new(x + 16, y + 48)
	end

	function notif:setAlpha(a)
		panel.Transparency = a
		titleText.Transparency = a
		descText.Transparency = a
		outline.Transparency = a
	end

	function notif:destroy()
		panel:Remove()
		outline:Remove()
		titleText:Remove()
		descText:Remove()
		for i,v in ipairs(Active) do
			if v == self then
				table.remove(Active,i)
				break
			end
		end
		recalcPositions()
	end

	notif:setPosition(startX, baseY)
	table.insert(Active, notif)
	recalcPositions()

	task.delay(duration, function()
		notif.state = "exit"
		notif.progress = 0
	end)
end
