--// SelectionBox 1.0

local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Active = {}

local function newBox(part, color)
	color = color or Color3.fromRGB(0,255,0)

	local lines = {}
	for i = 1,12 do
		local l = Drawing.new("Line")
		l.Color = color
		l.Thickness = 2
		l.Transparency = 1
		l.Visible = true
		lines[i] = l
	end

	local pulse = 0

	local box = {
		part = part,
		lines = lines,
		pulse = pulse
	}

	function box:update(dt)
		if not self.part or not self.part.Parent then
			self:destroy()
			return
		end

		self.pulse += dt * 2
		local wave = (math.sin(self.pulse) + 1) / 2

		for _,l in ipairs(self.lines) do
			l.Transparency = 0.6 + (wave * 0.4)
			l.Thickness = 2 + (wave * 0.8)
		end

		local cf = self.part.CFrame
		local s = self.part.Size * 0.5

		local corners = {
			cf * Vector3.new(-s.X,-s.Y,-s.Z),
			cf * Vector3.new(-s.X,-s.Y, s.Z),
			cf * Vector3.new(-s.X, s.Y,-s.Z),
			cf * Vector3.new(-s.X, s.Y, s.Z),
			cf * Vector3.new( s.X,-s.Y,-s.Z),
			cf * Vector3.new( s.X,-s.Y, s.Z),
			cf * Vector3.new( s.X, s.Y,-s.Z),
			cf * Vector3.new( s.X, s.Y, s.Z),
		}

		local function project(v)
			local p, vis = Camera:WorldToViewportPoint(v)
			return Vector2.new(p.X,p.Y), vis
		end

		local edges = {
			{1,2},{1,3},{1,5},
			{2,4},{2,6},
			{3,4},{3,7},
			{4,8},
			{5,6},{5,7},
			{6,8},
			{7,8}
		}

		for i,e in ipairs(edges) do
			local a,b = corners[e[1]], corners[e[2]]
			local p1,v1 = project(a)
			local p2,v2 = project(b)
			local line = self.lines[i]

			if v1 and v2 then
				line.From = p1
				line.To = p2
				line.Visible = true
			else
				line.Visible = false
			end
		end
	end

	function box:destroy()
		for _,l in ipairs(self.lines) do
			l:Remove()
		end
		for i,v in ipairs(Active) do
			if v == self then
				table.remove(Active,i)
				break
			end
		end
	end

	table.insert(Active, box)
	return box
end

RunService.RenderStepped:Connect(function(dt)
	for _,b in ipairs(Active) do
		b:update(dt)
	end
end)

return newBox
