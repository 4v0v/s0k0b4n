local Matrices = require(G3D_PATH .. '/g3d_matrices')

local Camera = {}

function Camera:new()
	local cam = setmetatable({}, {__index = Camera})

	cam.aspect_ratio = love.graphics.getWidth()/love.graphics.getHeight()
	cam.shader       = require(G3D_PATH .. "/g3d_shaderloader")
	cam.fov          = math.pi/3
	cam.near_clip    = .01
	cam.far_clip     = 1000
	cam.down         = {0, -1, 0} -- 1: flip camera
	cam.sensitivity  = .003
	cam.speed        = 20
	cam.x            = 0
	cam.y            = 0
	cam.z            = 0
	cam.tx           = 0
	cam.ty           = 0
	cam.tz           = 1
	cam.dir          = 0
	cam.pitch        = 0

	cam:update_projection_matrix('projection')
	cam:update_view_matrix()

	return cam
end

function Camera:move(x, y, z)
	if type(x) == 'table' then 
		self.x, self.y, self.z = x[1] or self.x, x[2] or self.y, x[3] or self.z
	else
		self.x, self.y, self.z = x or self.x, y or self.y, z or self.z
	end

	self:update_view_matrix()
end

function Camera:look_at(tx, ty, tz)
	if type(tx) == 'table' then 
		self.tx, self.ty, self.tz = tx[1] or self.tx, tx[2] or self.ty, tx[3] or self.tz
	else
		self.tx, self.ty, self.tz = tx or self.tx, ty or self.ty, tz or self.tz
	end

	self.dir   = -math.atan2(self.tz - self.z, self.tx - self.x) + math.pi/2
	self.pitch = -math.atan2(self.ty - self.y, self.tx - self.x)

	self:update_view_matrix()
end

function Camera:look_in_dir(dir, pitch)
	self.dir    = dir   or self.dir
	self.pitch  = pitch or self.pitch

	local sign = 0 
	if     math.cos(self.pitch) > 0 then sign =  1
	elseif math.cos(self.pitch) < 0 then sign = -1 end
	
	local cos_pitch = sign * math.max(math.abs(math.cos(self.pitch)), .001)
	self.tx = self.x + math.sin(self.dir) * cos_pitch
	self.ty = self.y - math.sin(self.pitch)
	self.tz = self.z + math.cos(self.dir) * cos_pitch

	self:update_view_matrix()
end

function Camera:update_view_matrix(shader)
	(shader or self.shader):send('view_matrix', Matrices.get_view_matrix({self.x, self.y, self.z}, {self.tx, self.ty, self.tz}, self.down))
end

function Camera:update_projection_matrix(type, shader)
	local matrix
	if     type == 'projection'   then
		matrix = Matrices.get_projection_matrix(self.fov, self.near_clip, self.far_clip, self.aspect_ratio)
	elseif type == 'orthographic' then
		matrix = Matrices.get_orthographic_matrix(self.fov, size or 5, self.near_clip, self.far_clip, self.aspect_ratio)
	end
	(shader or self.shader):send('projection_matrix', matrix)
end

function Camera:first_person_movement(dt, direction)
	local move_x    = 0
	local move_y    = 0

	if 		 direction == 'left'     then 
		move_x = move_x - 1
	elseif direction == 'right'    then 
		move_x = move_x + 1
	elseif direction == 'forward'  then 
		move_y = move_y - 1
	elseif direction == 'backward' then 
		move_y = move_y + 1
	elseif direction == 'down'     then 
		self.y = self.y - self.speed * dt
	elseif direction == 'up'       then 
		self.y = self.y + self.speed * dt
	end

	 -- TODO: elseif direction == 'forward_follow_pitch'  then 
	 -- TODO: elseif direction == 'backward_follow_pitch' then 


	-- do some trigonometry on the inputs to make movement relative to camera's dir
	-- also to make the player not move faster in diagonal dirs
	if move_x ~= 0 or move_y ~= 0 then
		local angle = math.atan2(move_y, move_x)
		local dir_x = math.cos(self.dir + angle)           * self.speed * dt
		local dir_z = math.sin(self.dir + angle + math.pi) * self.speed * dt

		self.x = self.x + dir_x
		self.z = self.z + dir_z
	end
	
	self:look_in_dir()
end

function Camera:mousemoved(dx, dy)
	local dir   = self.dir + dx * self.sensitivity
	local pitch = math.max(math.min(self.pitch + dy * self.sensitivity, math.pi * .5), math.pi * -.5)
	self:look_in_dir(dir, pitch)
end

return Camera:new()
