-- | saviour

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
			notif.sweepPos += dt * 300
			if notif.sweepPos > notif.width then
				notif.sweepPos = 0
			end
			notif:updateParticles(dt)
			notif.accent.Position = Vector2.new(notif.panel.Position.X + notif.sweepPos, notif.panel.Position.Y)
			local floatOffset = math.sin(tick()*2) * 2
			notif.panel.Position = Vector2.new(notif.panel.Position.X, notif.targetY + floatOffset)
			notif.titleText.Position = Vector2.new(notif.panel.Position.X + notif.paddingX, notif.panel.Position.Y + notif.paddingY + floatOffset)
			notif.descText.Position = Vector2.new(notif.panel.Position.X + notif.paddingX, notif.panel.Position.Y + notif.paddingY + 32 + floatOffset)
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

	local panel = Drawing.new("Square")
	panel.Size = Vector2.new(width, height)
	panel.Color = Color3.fromRGB(25,25,35)
	panel.Filled = true
	panel.Transparency = 1
	panel.Visible = true

	local titleText = Drawing.new("Text")
	titleText.Size = 22
	titleText.Font = 2
	titleText.Color = Color3.fromRGB(255,255,255)
	titleText.Text = title
	titleText.Transparency = 0
	titleText.Center = false
	titleText.Visible = true

	local descText = Drawing.new("Text")
	descText.Size = 16
	descText.Font = 2
	descText.Color = Color3.fromRGB(200,200,210)
	descText.Text = description
	descText.Transparency = 0
	descText.Center = false
	descText.Visible = true

	local particles = {}
	for i=1,8 do
		local p = Drawing.new("Square")
		p.Size = Vector2.new(4,4)
		p.Color = Color3.fromHSV(math.random(),1,1)
		p.Filled = true
		p.Transparency = 0.8
		p.Visible = true
		table.insert(particles,p)
	end

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
		accent = accent,
		titleText = titleText,
		descText = descText,
		particles = particles,
		sweepPos = 0,
		paddingX = paddingX,
		paddingY = paddingY
	}

	function notif:setPosition(x,y)
		panel.Position = Vector2.new(x,y)
	end

	function notif:setAlpha(a)
		panel.Transparency = a
		titleText.Transparency = a
		descText.Transparency = a
		accent.Transparency = a
		for _,p in ipairs(particles) do
			p.Transparency = 0.3 + a*0.5
		end
	end

	function notif:updateParticles(dt)
		for _,p in ipairs(self.particles) do
			local offsetX = math.random()*self.width - self.width/2
			local offsetY = math.random()*self.height - self.height/2
			p.Position = Vector2.new(self.panel.Position.X + offsetX, self.panel.Position.Y + offsetY)
		end
	end

	function notif:destroy()
		panel:Remove()
		accent:Remove()
		titleText:Remove()
		descText:Remove()
		for _,p in ipairs(particles) do
			p:Remove()
		end
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
