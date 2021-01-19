local matrices = require(G3D_PATH .. '/g3d_matrices')

local Camera = {}

function Camera:new()
	local cam = setmetatable({}, {__index = Camera})

	cam.fov          = math.pi/3
	cam.near_clip    = 0.01
	cam.far_clip     = 1000
	cam.shader       = require(G3D_PATH .. "/g3d_shader")
	cam.aspect_ratio = love.graphics.getWidth()/love.graphics.getHeight()
	cam.pos          = {0,  0, 0}
	cam.target       = {0,  0, 0}
	cam.down         = {0, -1, 0}
	cam.fps_dir      = 0
	cam.fps_pitch    = 0

	cam:update_projection_matrix()
	cam:look_in_dir()

	return cam
end

-- give the camera a point to look from and a point to look towards
function Camera:look_at(x, y, z, xAt, yAt, zAt)
	self.pos[1]    = x
	self.pos[2]    = y
	self.pos[3]    = z
	self.target[1] = xAt
	self.target[2] = yAt
	self.target[3] = zAt

	-- TODO: update self.fps's dir and pitch here

	-- update the camera in the shader
	self:update_view_matrix()
end

-- move and rotate the camera, given a point and a dir and a pitch (vertical dir)
function Camera:look_in_dir(x, y, z, dirTowards, pitchTowards)
	self.pos[1]    = x            or self.pos[1]
	self.pos[2]    = y            or self.pos[2]
	self.pos[3]    = z            or self.pos[3]
	self.fps_dir   = dirTowards   or self.fps_dir
	self.fps_pitch = pitchTowards or self.fps_pitch

	-- convert the dir and pitch into a target point
	local sign = math.cos(self.fps_pitch)
	if     sign > 0 then sign =  1
	elseif sign < 0 then sign = -1
	else                 sign =  0 end
	
	local cosPitch = sign * math.max(math.abs(math.cos(self.fps_pitch)), 0.001)
	self.target[1] = self.pos[1] + math.sin(self.fps_dir) * cosPitch
	self.target[2] = self.pos[2] - math.sin(self.fps_pitch)
	self.target[3] = self.pos[3] + math.cos(self.fps_dir) * cosPitch

	self:update_view_matrix()
end

-- recreate the camera's view matrix from its current values
-- and send the matrix to the shader specified, or the default shader
function Camera:update_view_matrix(shaderGiven)
	(shaderGiven or self.shader):send('viewMatrix', matrices.get_view(self.pos, self.target, self.down))
end

-- recreate the camera's projection matrix from its current values
-- and send the matrix to the shader specified, or the default shader
function Camera:update_projection_matrix(shaderGiven)
	(shaderGiven or self.shader):send('projectionMatrix', matrices.get_projection(self.fov, self.near_clip, self.far_clip, self.aspect_ratio))
end

-- recreate the camera's orthographic projection matrix from its current values
-- and send the matrix to the shader specified, or the default shader
function Camera:update_orthographic_matrix(size, shaderGiven)
	(shaderGiven or self.shader):send('projectionMatrix', matrices.get_orthographic(self.fov, size or 5, self.near_clip, self.far_clip, self.aspect_ratio))
end

-- simple first person camera movement with WASD
-- put this local function in your love.update to use, passing in dt
function Camera:first_person_movement(dt, direction)
	local move_x    = 0
	local move_y    = 0
	local cam_moved = false
	
	if 		 direction == 'left'     then 
		move_x = move_x - 1
	elseif direction == 'right'    then 
		move_x = move_x + 1
	elseif direction == 'forward'  then 
		move_y = move_y - 1
	elseif direction == 'backward' then 
		move_y = move_y + 1
	elseif direction == 'down'     then 
		self.pos[2] = self.pos[2] - .15 * dt * 60 
		cam_moved = true
	elseif direction == 'up'       then 
		self.pos[2] = self.pos[2] + .15 * dt * 60 
		cam_moved = true 
	end

	-- do some trigonometry on the inputs to make movement relative to camera's dir
	-- also to make the player not move faster in diagonal dirs
	if move_x ~= 0 or move_y ~= 0 then
		local angle = math.atan2(move_y,move_x)
		local speed = 9
		local dir_x = math.cos(self.fps_dir + angle)*speed*dt
		local dir_z = math.sin(self.fps_dir + angle + math.pi)*speed*dt

		self.pos[1] = self.pos[1] + dir_x
		self.pos[3] = self.pos[3] + dir_z
		cam_moved = true
	end

	-- update the camera's in the shader
	-- only if the camera moved, for a slight performance benefit
	if cam_moved then
		self:look_in_dir(self.pos[1],self.pos[2],self.pos[3], self.fps_dir,self.fps_pitch)
	end
end

-- use this in your love.mousemoved function, passing in the movements
function Camera:first_person_look(dx,dy)
	local sensitivity = 1/300
	self.fps_dir    = self.fps_dir + dx*sensitivity
	self.fps_pitch  = math.max(
		math.min(self.fps_pitch - dy * sensitivity, math.pi * 0.5), 
		math.pi*-0.5
	)
	self:look_in_dir(self.pos[1], self.pos[2], self.pos[3], self.fps_dir, self.fps_pitch)
end

return Camera:new()
