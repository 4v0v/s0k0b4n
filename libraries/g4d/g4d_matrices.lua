local Vectors = require(G4D_PATH .. "/g4d_vectors")
local cos, sin, tan = math.cos, math.sin, math.tan

local Matrices = {}

function Matrices:get_transformation_matrix(x, y, z, rx, ry, rz, sx, sy, sz)
	local matrix    = self:get_identity_matrix()
	local t_matrix  = self:get_translation_matrix(x, y, z)
	local rx_matrix = self:get_x_rotation_matrix(rx)
	local ry_matrix = self:get_y_rotation_matrix(ry)
	local rz_matrix = self:get_z_rotation_matrix(rz)
	local s_matrix  = self:get_scale_matrix(sx, sy, sz)

	matrix = self:multiply(matrix, t_matrix)
	matrix = self:multiply(matrix, rx_matrix)
	matrix = self:multiply(matrix, ry_matrix)
	matrix = self:multiply(matrix, rz_matrix)
	matrix = self:multiply(matrix, s_matrix)

	return matrix
end

function Matrices:get_identity_matrix()
	return {
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}
end

function Matrices:get_translation_matrix(x, y, z)
	return {
		1, 0, 0, x,
		0, 1, 0, y,
		0, 0, 1, z,
		0, 0, 0, 1,
	}
end

function Matrices:get_x_rotation_matrix(rx)
	return {
		1, 0,       0,        0,
		0, cos(rx), -sin(rx), 0,
		0, sin(rx), cos(rx),  0,
		0, 0,       0,        1,
	}
end

function Matrices:get_y_rotation_matrix(ry)
	return {
		cos(ry),  0, sin(ry), 0,
		0,        1, 0,       0,
		-sin(ry), 0, cos(ry), 0,
		0,        0, 0,       1,
	}
end

function Matrices:get_z_rotation_matrix(rz)
	return {
		cos(rz), -sin(rz), 0, 0,
		sin(rz), cos(rz),  0, 0,
		0,       0,        1, 0,
		0,       0,        0, 1,
	}
end

function Matrices:get_scale_matrix(sx, sy, sz)
	return {
		sx, 0,  0,  0,
		0,  sy, 0,  0,
		0,  0,  sz, 0,
		0,  0,  0,  1,
	}
end

function Matrices:get_projection_matrix(fov, near, far, aspect_ration)
	local t = near * tan(fov/2)
	local b = -1   * t
	local r = t    * aspect_ration
	local l = -1   * r

	return {
		2*near/(r-l), 0,            (r+l)/(r-l),              0,
		0,            2*near/(t-b), (t+b)/(t-b),              0,
		0,            0,            -1*(far+near)/(far-near), -2*far*near/(far-near),
		0,            0,            -1,                       0
	}
end

function Matrices:get_orthographic_matrix(fov, size, near, far, aspect_ration)
	local t = size * tan(fov/2)
	local b = -1   * t
	local r = t    * aspect_ration
	local l = -1   * r

	return {
		2/(r-l), 0,       0,             -1*(r+l)/(r-l),
		0,       2/(t-b), 0,             -1*(t+b)/(t-b),
		0,       0,       -2/(far-near), -(far+near)/(far-near),
		0,       0,       0,             1
	}
end

function Matrices:get_view_matrix(eye, target, down)
	local z = Vectors:normalize({eye[1] - target[1], eye[2] - target[2], eye[3] - target[3]})
	local x = Vectors:normalize(Vectors:cross_product(down, z))
	local y = Vectors:cross_product(z, x)

	return {
		x[1], x[2], x[3], -1 * Vectors:dot_product(x, eye),
		y[1], y[2], y[3], -1 * Vectors:dot_product(y, eye),
		z[1], z[2], z[3], -1 * Vectors:dot_product(z, eye),
		0,    0,    0,    1,
	}
end

function Matrices:multiply(a, b)
	local matrix = {
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
	}

	local i = 1
	for y = 1, 4 do
		for x = 1, 4 do
			matrix[i] = matrix[i] + self:get_value_at(a, 1, y) * self:get_value_at(b, x, 1)
			matrix[i] = matrix[i] + self:get_value_at(a, 2, y) * self:get_value_at(b, x, 2)
			matrix[i] = matrix[i] + self:get_value_at(a, 3, y) * self:get_value_at(b, x, 3)
			matrix[i] = matrix[i] + self:get_value_at(a, 4, y) * self:get_value_at(b, x, 4)
			i = i + 1
		end
	end
	return matrix
end

function Matrices:get_value_at(matrix, x,y)
	return matrix[x + (y-1)*4]
end

return Matrices
