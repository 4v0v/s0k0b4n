local Vectors = require(G4D_PATH .. "/g4d_vectors")
local cos, sin, tan = math.cos, math.sin, math.tan

local Matrices = {}

function Matrices.get_transformation(x, y, z, rx, ry, rz, sx, sy, sz)
	local matrix    = Matrices.get_identity_matrix()

	-- translations
	matrix[4]       = x
	matrix[8]       = y
	matrix[12]      = z

	-- rotations
	local rx_matrix = Matrices.get_identity_matrix()
	rx_matrix[6]    = cos(rx)
	rx_matrix[7]    = -sin(rx)
	rx_matrix[10]   = sin(rx)
	rx_matrix[11]   = cos(rx)
	matrix          = Matrices.multiply(matrix, rx_matrix)

	local ry_matrix = Matrices.get_identity_matrix()
	ry_matrix[1]    = cos(ry)
	ry_matrix[3]    = sin(ry)
	ry_matrix[9]    = -sin(ry)
	ry_matrix[11]   = cos(ry)
	matrix          = Matrices.multiply(matrix, ry_matrix)

	local rz_matrix = Matrices.get_identity_matrix()
	rz_matrix[1]    = cos(rz)
	rz_matrix[2]    = -sin(rz)
	rz_matrix[5]    = sin(rz)
	rz_matrix[6]    = cos(rz)
	matrix          = Matrices.multiply(matrix, rz_matrix)

	-- scale
	local s_matrix  = Matrices.get_identity_matrix()
	s_matrix[1]     = sx
	s_matrix[6]     = sy
	s_matrix[11]    = sz
	matrix          = Matrices.multiply(matrix, s_matrix)

	return matrix
end

function Matrices.get_projection_matrix(fov, near, far, aspect_ration)
	local top    = near * tan(fov/2)
	local bottom = -1   * top
	local right  = top  * aspect_ration
	local left   = -1   * right

	return {
		2*near/(right-left), 0, (right+left)/(right-left), 0,
		0, 2*near/(top-bottom), (top+bottom)/(top-bottom), 0,
		0, 0, -1*(far+near)/(far-near), -2*far*near/(far-near),
		0, 0, -1, 0
	}
end

function Matrices.get_orthographic_matrix(fov, size, near, far, aspect_ration)
	local top    = size * tan(fov/2)
	local bottom = -1   * top
	local right  = top  * aspect_ration
	local left   = -1   * right

	return {
		2/(right-left), 0, 0, -1*(right+left)/(right-left),
		0, 2/(top-bottom), 0, -1*(top+bottom)/(top-bottom),
		0, 0, -2/(far-near), -(far+near)/(far-near),
		0, 0, 0, 1
	}
end

function Matrices.get_view_matrix(eye, target, down)
	local z = Vectors.normalize({eye[1] - target[1], eye[2] - target[2], eye[3] - target[3]})
	local x = Vectors.normalize(Vectors.cross_product(down, z))
	local y = Vectors.cross_product(z, x)

	return {
		x[1], x[2], x[3], -1 * Vectors.dot_product(x, eye),
		y[1], y[2], y[3], -1 * Vectors.dot_product(y, eye),
		z[1], z[2], z[3], -1 * Vectors.dot_product(z, eye),
		0, 0, 0, 1,
	}
end

function Matrices.get_identity_matrix()
	return {
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}
end

function Matrices.get_value_at(matrix, x,y)
	return matrix[x + (y-1)*4]
end

function Matrices.multiply(a,b)
	local matrix = {
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
	}

	local i = 1
	for y = 1, 4 do
		for x = 1, 4 do
			matrix[i] = matrix[i] + Matrices.get_value_at(a, 1, y) * Matrices.get_value_at(b, x, 1)
			matrix[i] = matrix[i] + Matrices.get_value_at(a, 2, y) * Matrices.get_value_at(b, x, 2)
			matrix[i] = matrix[i] + Matrices.get_value_at(a, 3, y) * Matrices.get_value_at(b, x, 3)
			matrix[i] = matrix[i] + Matrices.get_value_at(a, 4, y) * Matrices.get_value_at(b, x, 4)
			i = i + 1
		end
	end
	return matrix
end

return Matrices
