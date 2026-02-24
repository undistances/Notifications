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
	local paddingX, paddingY = 16, 16
	local width = 320
	local height = 80
	local viewport = Camera.ViewportSize
	local startX = viewport.X + 50
	local endX = viewport.X - width - 50
	local exitX = viewport.X + width + 100
	local baseY = viewport.Y - 140 - (#Active * (height + 16))

	local outline = Drawing.new("Square")
	outline.Size = Vector2.new(width + 2, height + 2)
	outline.Position = Vector2.new(0,0)
	outline.Color = Color3.new(1,1,1)
	outline.Filled = false
	outline.Thickness = 2
	outline.Transparency = 1
	outline.Visible = true

	local panel = Drawing.new("Square")
	panel.Size = Vector2.new(width, height)
	panel.Color = Color3.fromRGB(25,25,35)
	panel.Filled = true
	panel.Transparency = 1
	panel.Visible = true

	local accent = Drawing.new("Square")
	accent.Size = Vector2.new(6, height)
	accent.Color = Color3.fromHSV(math.random(),1,1)
	accent.Filled = true
	accent.Transparency = 1
	accent.Visible = true

	local titleText = Drawing.new("Text")
	titleText.Size = 22
	titleText.Font = 2
	titleText.Color = Color3.fromRGB(255,255,255)
	titleText.Text = title
	titleText.Transparency = 1 
	titleText.Center = false
	titleText.Visible = true

	local descText = Drawing.new("Text")
	descText.Size = 16
	descText.Font = 2
	descText.Color = Color3.fromRGB(200,200,210)
	descText.Text = description
	descText.Transparency = 1 
	descText.Center = false
	descText.Visible = true

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
		accent = accent,
		titleText = titleText,
		descText = descText,
		paddingX = paddingX,
		paddingY = paddingY
	}

	function notif:setPosition(x,y)
		outline.Position = Vector2.new(x - 1, y - 1)
		panel.Position = Vector2.new(x, y)
		titleText.Position = Vector2.new(x + paddingX, y + paddingY)
		descText.Position = Vector2.new(x + paddingX, y + paddingY + 32)
	end

	function notif:setAlpha(a)
		panel.Transparency = a
		titleText.Transparency = a
		descText.Transparency = a
		accent.Transparency = a
		outline.Transparency = a
	end

	function notif:destroy()
		panel:Remove()
		accent:Remove()
		titleText:Remove()
		descText:Remove()
		outline:Remove()
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

	task.delay(duration,function()
		notif.state = "exit"
		notif.progress = 0
	end)
end
