local Matrices = require(G3D_PATH .. '/g3d_matrices')

local Camera = {}

function Camera:new()
	local cam = setmetatable({}, {__index = Camera})

	cam.aspect_ratio = love.graphics.getWidth()/love.graphics.getHeight()
	cam.shader       = require(G3D_PATH .. "/g3d_shader")
	cam.fov          = math.pi/3
	cam.near_clip    = 0.01
	cam.far_clip     = 1000
	cam.sensitivity  = 1/300
	cam.speed        = 20
	cam.x            = 0
	cam.y            = 0
	cam.z            = 0
	cam.tx           = 0          -- target
	cam.ty           = 0          -- target
	cam.tz           = 0          -- target
	cam.down         = {0, -1, 0} -- 1: flip camera
	cam.dir          = 0
	cam.pitch        = 0

	cam:update_projection_matrix('projection')
	cam:look_in_dir()

	return cam
end

-- give the camera a point to look from and a point to look towards
function Camera:look_at(x, y, z, tx, ty, tz)
	self.x  = x  or self.x
	self.y  = y  or self.y
	self.z  = z  or self.z
	self.tx = tx or self.tx
	self.ty = ty or self.ty
	self.tz = ty or self.ty

	-- TODO: update self.fps's dir and pitch here

	-- update the camera in the shader
	self:update_view_matrix()
end

-- move and rotate the camera, given a point and a dir and a pitch (vertical dir)
function Camera:look_in_dir(x, y, z, dir, pitch)
	self.x      = x     or self.x
	self.y      = y     or self.y
	self.z      = z     or self.z
	self.dir    = dir   or self.dir
	self.pitch  = pitch or self.pitch

	-- convert the dir and pitch into a target point
	local sign = math.cos(self.pitch)
	if     sign > 0 then sign =  1
	elseif sign < 0 then sign = -1
	else                 sign =  0 end
	
	local cos_pitch = sign * math.max(math.abs(math.cos(self.pitch)), .001)
	self.tx = self.x + math.sin(self.dir) * cos_pitch
	self.ty = self.y - math.sin(self.pitch)
	self.tz = self.z + math.cos(self.dir) * cos_pitch

	self:update_view_matrix()
end

function Camera:update_view_matrix(shader)
	(shader or self.shader):send('viewMatrix', Matrices.get_view_matrix({self.x, self.y, self.z}, {self.tx, self.ty, self.tz}, self.down))
end

function Camera:update_projection_matrix(type, shader)
	if     type == 'projection'   then
		(shader or self.shader):send('projectionMatrix', Matrices.get_projection_matrix(self.fov, self.near_clip, self.far_clip, self.aspect_ratio))
	elseif type == 'orthographic' then
		(shader or self.shader):send('projectionMatrix', Matrices.get_orthographic_matrix(self.fov, size or 5, self.near_clip, self.far_clip, self.aspect_ratio))
	end
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

function Camera:mousemoved(dx,dy)
	self.dir    = self.dir + dx * self.sensitivity
	self.pitch  = math.max(math.min(self.pitch + dy * self.sensitivity, math.pi * .5), math.pi * -.5)
	self:look_in_dir()
end

return Camera:new()
