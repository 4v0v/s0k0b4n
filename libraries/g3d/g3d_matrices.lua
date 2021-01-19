local Vectors = require(G3D_PATH .. "/g3d_vectors")
local Matrices = {}

function Matrices.get_transformation(translation, rotation, scale)
	local matrix = Matrices.get_identity()

	-- translations
	matrix[4]  = translation[1]
	matrix[8]  = translation[2]
	matrix[12] = translation[3]

	-- rotations
	-- x
	local rx = Matrices.get_identity()
	rx[6]  = math.cos(rotation[1])
	rx[7]  = -1*math.sin(rotation[1])
	rx[10] = math.sin(rotation[1])
	rx[11] = math.cos(rotation[1])
	matrix = Matrices.multiply(matrix, rx)

	-- y
	local ry = Matrices.get_identity()
	ry[1]  = math.cos(rotation[2])
	ry[3]  = math.sin(rotation[2])
	ry[9]  = -1*math.sin(rotation[2])
	ry[11] = math.cos(rotation[2])
	matrix = Matrices.multiply(matrix, ry)

	-- z
	local rz = Matrices.get_identity()
	rz[1] = math.cos(rotation[3])
	rz[2] = -1*math.sin(rotation[3])
	rz[5] = math.sin(rotation[3])
	rz[6] = math.cos(rotation[3])
	matrix = Matrices.multiply(matrix, rz)

	-- scale
	local sm = Matrices.get_identity()
	sm[1]  = scale[1]
	sm[6]  = scale[2]
	sm[11] = scale[3]
	matrix = Matrices.multiply(matrix, sm)

	return matrix
end

function Matrices.get_projection(fov, near, far, aspectRatio)
	local top    = near * math.tan(fov/2)
	local bottom = -1*top
	local right  = top * aspectRatio
	local left   = -1*right

	return {
		2*near/(right-left), 0, (right+left)/(right-left), 0,
		0, 2*near/(top-bottom), (top+bottom)/(top-bottom), 0,
		0, 0, -1*(far+near)/(far-near), -2*far*near/(far-near),
		0, 0, -1, 0
	}
end

function Matrices.get_orthographic(fov, size, near, far, aspectRatio)
	local top    = size * math.tan(fov/2)
	local bottom = -1*top
	local right  = top * aspectRatio
	local left   = -1*right

	return {
		2/(right-left), 0, 0, -1*(right+left)/(right-left),
		0, 2/(top-bottom), 0, -1*(top+bottom)/(top-bottom),
		0, 0, -2/(far-near), -(far+near)/(far-near),
		0, 0, 0, 1
	}
end

function Matrices.get_view(eye, target, down)
	local z = Vectors.normalize({eye[1] - target[1], eye[2] - target[2], eye[3] - target[3]})
	local x = Vectors.normalize(Vectors.crossProduct(down, z))
	local y = Vectors.crossProduct(z, x)

	return {
		x[1], x[2], x[3], -1 * Vectors.dotProduct(x, eye),
		y[1], y[2], y[3], -1 * Vectors.dotProduct(y, eye),
		z[1], z[2], z[3], -1 * Vectors.dotProduct(z, eye),
		0, 0, 0, 1,
	}
end

function Matrices.get_identity()
	return {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
end

function Matrices.get_value_at(matrix, x,y)
	return matrix[x + (y-1)*4]
end

function Matrices.multiply(a,b)
	local matrix = {0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0}

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
