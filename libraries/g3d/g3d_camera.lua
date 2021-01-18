local shader   = require(G3D_PATH .. '/g3d_shader')
local matrices = require(G3D_PATH .. '/g3d_matrices')

local Camera = {
	fov         = math.pi/2,
	nearClip    = 0.01,
	farClip     = 1000,
	aspectRatio = love.graphics.getWidth()/love.graphics.getHeight(),
	position    = {0,  0, 0},
	target      = {0,  0, 0},
	down        = {0, -1, 0},
	fps = {
		direction = 0,
		pitch     = 0
	}
}

-- give the camera a point to look from and a point to look towards
function Camera:lookAt(x,y,z, xAt,yAt,zAt)
    self.position[1] = x
    self.position[2] = y
    self.position[3] = z
    self.target[1]   = xAt
    self.target[2]   = yAt
    self.target[3]   = zAt

    -- TODO: update self.fps's direction and pitch here

    -- update the camera in the shader
    self:updateViewMatrix()
end

-- move and rotate the camera, given a point and a direction and a pitch (vertical direction)
function Camera:lookInDirection(x,y,z, directionTowards,pitchTowards)
    self.position[1] = x
    self.position[2] = y
    self.position[3] = z

    self.fps.direction = directionTowards or self.fps.direction
    self.fps.pitch     = pitchTowards     or self.fps.pitch

    -- convert the direction and pitch into a target point
    local sign = math.cos(self.fps.pitch)
    if sign > 0 then sign = 1
    elseif sign < 0 then sign = -1
		else sign = 0 end
		
    local cosPitch = sign * math.max(math.abs(math.cos(self.fps.pitch)), 0.001)
    self.target[1] = self.position[1] + math.sin(self.fps.direction) * cosPitch
    self.target[2] = self.position[2] - math.sin(self.fps.pitch)
    self.target[3] = self.position[3] + math.cos(self.fps.direction) * cosPitch

    -- update the camera in the shader
    self:updateViewMatrix()
end

-- recreate the camera's view matrix from its current values
-- and send the matrix to the shader specified, or the default shader
function Camera:updateViewMatrix(shaderGiven)
    (shaderGiven or shader):send('viewMatrix', matrices.get_view(self.position, self.target, self.down))
end

-- recreate the camera's projection matrix from its current values
-- and send the matrix to the shader specified, or the default shader
function Camera:updateProjectionMatrix(shaderGiven)
    (shaderGiven or shader):send('projectionMatrix', matrices.get_projection(self.fov, self.nearClip, self.farClip, self.aspectRatio))
end

-- recreate the camera's orthographic projection matrix from its current values
-- and send the matrix to the shader specified, or the default shader
function Camera:updateOrthographicMatrix(size, shaderGiven)
    (shaderGiven or shader):send('projectionMatrix', matrices.get_orthographic(self.fov, size or 5, self.nearClip, self.farClip, self.aspectRatio))
end

-- simple first person camera movement with WASD
-- put this local function in your love.update to use, passing in dt
function Camera:firstPersonMovement(dt, direction)
	local moveX = 0
	local moveY = 0
	local cameraMoved = false
	
	if 		 direction == 'left'     then 
		moveX = moveX - 1
	elseif direction == 'right'    then 
		moveX = moveX + 1
	elseif direction == 'forward'  then 
		moveY = moveY - 1
	elseif direction == 'backward' then 
		moveY = moveY + 1
	elseif direction == 'down'     then 
		self.position[2] = self.position[2] - 0.15*dt*60 
		cameraMoved = true
	elseif direction == 'up'       then 
		self.position[2] = self.position[2] + 0.15*dt*60 
		cameraMoved = true 
	end

	-- do some trigonometry on the inputs to make movement relative to camera's direction
	-- also to make the player not move faster in diagonal directions
	if moveX ~= 0 or moveY ~= 0 then
		local angle = math.atan2(moveY,moveX)
		local speed = 9
		local dir_x = math.cos(self.fps.direction + angle)*speed*dt
		local dir_z = math.sin(self.fps.direction + angle + math.pi)*speed*dt

		self.position[1] = self.position[1] + dir_x
		self.position[3] = self.position[3] + dir_z
		cameraMoved = true
	end

	-- update the camera's in the shader
	-- only if the camera moved, for a slight performance benefit
	if cameraMoved then
		self:lookInDirection(self.position[1],self.position[2],self.position[3], self.fps.direction,self.fps.pitch)
	end
end

-- use this in your love.mousemoved function, passing in the movements
function Camera:firstPersonLook(dx,dy)
    local sensitivity = 1/300
    self.fps.direction = self.fps.direction + dx*sensitivity
    self.fps.pitch     = math.max(math.min(self.fps.pitch - dy*sensitivity, math.pi*0.5), math.pi*-0.5)

    self:lookInDirection(self.position[1],self.position[2],self.position[3], self.fps.direction,self.fps.pitch)
end

return Camera
