local Vectors  = require(G4D_PATH .. "/g4d_vectors")
local Matrices = require(G4D_PATH .. "/g4d_matrices")
local load_obj = require(G4D_PATH .. "/g4d_objloader")

local Model = {}

Model.vertex_format = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexNormal"  , "float", 3},
	{"VertexColor"   , "byte" , 4},
}
Model.shader = require(G4D_PATH .. "/g4d_shaderloader")

Model.models = {}

function Model:update_light_data()
	local light_data = {}
	for _, model in Model.models do 
		if model.is_light then 
			table.insert(light_data, {model.x, model.y, model.z}) -- abiant light 
		end
	end

	-- Model.shader:send(light_data)
end


function Model:new(id, vertices, texture, pos, rot, sca, color)
	local model = setmetatable({}, {__index = Model})

	if type(vertices) == "string" then vertices = load_obj(vertices)              end
	if type(texture)  == "string" then texture  = love.graphics.newImage(texture) end

	model.id       = id or 'id'

	model.is_light = false
	model.x        = pos and pos[1] or 0
	model.y        = pos and pos[2] or 0
	model.z        = pos and pos[3] or 0
	model.rx       = rot and rot[1] or 0
	model.ry       = rot and rot[2] or 0
	model.rz       = rot and rot[3] or 0
	model.sx       = sca and sca[1] or 1
	model.sy       = sca and sca[2] or 1
	model.sz       = sca and sca[3] or 1
	model.color    = color or {1, 1, 1}
	model.matrix   = {}
	model.vertices = vertices
	model.texture  = texture
	model.mesh     = love.graphics.newMesh(Model.vertex_format, model.vertices, "triangles")

	model.mesh:setTexture(texture)
	model:generate_normals()
	model:update_matrix()

	if model.is_light then 
		Model.update_light_data() 
	end

	table.insert(Model.models, model)

	return model
end

function Model:draw()
	local r,g,b,a = love.graphics.getColor()
	love.graphics.setColor(self.color)
	love.graphics.setShader(self.shader)
	self.shader:send("model_matrix", self.matrix)
	love.graphics.draw(self.mesh)
	love.graphics.setShader()
	love.graphics.setColor(r, g, b, a)
end

function Model:generate_normals(flipped)
	for i=1, #self.vertices, 3 do
		local vp = self.vertices[i]
		local v  = self.vertices[i+1]
		local vn = self.vertices[i+2]

		local vec1     = {v[1]-vp[1], v[2]-vp[2], v[3]-vp[3]}
		local vec2     = {vn[1]-v[1], vn[2]-v[2], vn[3]-v[3]}
		local normal   = Vectors:normalize(Vectors:cross_product(vec1,vec2))
		local flippage = flipped and -1 or 1

		vp[6] = normal[1] * flippage
		vp[7] = normal[2] * flippage
		vp[8] = normal[3] * flippage

		v[6] = normal[1] * flippage
		v[7] = normal[2] * flippage
		v[8] = normal[3] * flippage

		vn[6] = normal[1] * flippage
		vn[7] = normal[2] * flippage
		vn[8] = normal[3] * flippage
	end
end

function Model:transform(x, y, z, rx, ry, rz, sx, sy, sz)
	self.x  = x  or self.x 
	self.y  = y  or self.y 
	self.z  = z  or self.z 
	self.rx = rx or self.rx
	self.ry = ry or self.ry
	self.rz = rz or self.rz
	self.sx = sx or self.sx
	self.sy = sy or self.sy
	self.sz = sz or self.sz

	if self.is_light then 
		Model.update_light_data()
	end

	self:update_matrix()
end

function Model:update_matrix()
	self.matrix = Matrices:get_transformation_matrix(
		self.x,  self.y,  self.z,
		self.rx, self.ry, self.rz,
		self.sx, self.sy, self.sz
	)
end

function Model:move(x, y, z)
	if type(x) == 'table' then
		self:transform(x[1], x[2], x[3])
	else
		self:transform(x, y, z)
	end
end

function Model:rotate(rx, ry, rz)
	if type(rx) == 'table' then
		self:transform(rx[1], rx[2], rx[3])
	else
		self:transform(_, _, _, rx, ry, rz)
	end
end

function Model:scale(sx, sy, sz)
	if type(sx) == 'table' then
		self:transform(sx[1], sx[2], sx[3])
	else
		self:transform(_, _, _, _, _, _, sx, sy, sz) 
	end
end

function Model:scale_all(s)
	self:transform(_, _, _, _, _, _, s, s, s) 
end

function Model:position() 
	return {self.x, self.y, self.z} 
end

function Model:get_rotation() 
	return {self.rx, self.ry, self.rz} 
end

function Model:get_scale() 
	return {self.sx, self.sy, self.sz} 
end

return setmetatable(Model, {__call = Model.new})
