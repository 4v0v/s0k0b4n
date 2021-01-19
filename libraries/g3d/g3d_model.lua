-- written by groverbuger for g3d
-- january 2021
-- MIT license

local vectors     = require(G3D_PATH .. "/g3d_vectors")
local matrices    = require(G3D_PATH .. "/g3d_matrices")
local loadObjFile = require(G3D_PATH .. "/g3d_objloader")

local Model = {}

Model.vertexFormat = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexNormal"  , "float", 3},
	{"VertexColor"   , "byte" , 4},
}

Model.shader = require(G3D_PATH .. "/g3d_shader")

function Model:new(given, texture, translation, rotation, scale)
	local model = setmetatable({}, {__index = Model})

	if type(given)   == "string" then given   = loadObjFile(given) end
	if type(texture) == "string" then texture = love.graphics.newImage(texture) end

	model.verts   = given
	model.texture = texture
	model.mesh    = love.graphics.newMesh(model.vertexFormat, model.verts, "triangles")
	
	model.mesh:setTexture(model.texture)
	model:set_transform(translation, rotation, scale)

	return model
end

function Model:makeNormals(flipped)
	for i=1, #self.verts, 3 do
		local vp = self.verts[i]
		local v  = self.verts[i+1]
		local vn = self.verts[i+2]

		local vec1     = {v[1]-vp[1], v[2]-vp[2], v[3]-vp[3]}
		local vec2     = {vn[1]-v[1], vn[2]-v[2], vn[3]-v[3]}
		local normal   = vectors.normalize(vectors.crossProduct(vec1,vec2))
		local flippage = flipped and -1 or 1

		vp[6] = normal[1] * flippage
		vp[7] = normal[2] * flippage
		vp[8] = normal[3] * flippage
		v[6]  = normal[1] * flippage
		v[7]  = normal[2] * flippage
		v[8]  = normal[3] * flippage
		vn[6] = normal[1] * flippage
		vn[7] = normal[2] * flippage
		vn[8] = normal[3] * flippage
	end
end

function Model:set_transform(translation, rotation, scale)
	self.translation = translation or {0,0,0}
	self.rotation    = rotation    or {0,0,0}
	self.scale       = scale       or {1,1,1}
	self:update_matrix()
end

function Model:set_translation(x, y, z)
	self.translation[1] = x or self.translation[1]
	self.translation[2] = y or self.translation[2]
	self.translation[3] = z or self.translation[3]
	self:update_matrix()
end

function Model:set_rotation(x, y, z)
	self.rotation[1] = x or self.rotation[1]
	self.rotation[2] = y or self.rotation[2]
	self.rotation[3] = z or self.rotation[3]
	self:update_matrix()
end

function Model:set_scale(x, y, z)
	self.scale[1] = x or self.scale[1]
	self.scale[2] = y or self.scale[2]
	self.scale[3] = z or self.scale[3]
	self:update_matrix()
end

function Model:set_x(x) self:set_translation(x, _, _) end
function Model:set_y(y) self:set_translation(_, y, _) end
function Model:set_z(z) self:set_translation(_, _, z) end

function Model:move_x(x) self:set_translation(self.translation[1] + x, _, _) end
function Model:move_y(y) self:set_translation(_, self.translation[2] + y, _) end
function Model:move_z(z) self:set_translation(_, _, self.translation[3] + z) end

function Model:set_rx(x) self:set_rotation(x, _, _) end
function Model:set_ry(y) self:set_rotation(_, y, _) end
function Model:set_rz(z) self:set_rotation(_, _, z) end

function Model:rotate_x(x) self:set_rotation(self.rotation[1] + x, _, _) end
function Model:rotate_y(y) self:set_rotation(_, self.rotation[2] + y, _) end
function Model:rotate_z(z) self:set_rotation(_, _, self.rotation[3] + z) end

function Model:set_s(s)  self:set_scale(s, s, s) end
function Model:set_sx(x) self:set_scale(x, _, _) end
function Model:set_sy(y) self:set_scale(_, y, _) end
function Model:set_sz(z) self:set_scale(_, _, z) end

function Model:scale(s)   self:set_scale(self.scale[1] + s, self.scale[2] + s, self.scale[3] + s) end
function Model:scale_x(x) self:set_scale(self.scale[1] + x, _, _) end
function Model:scale_y(y) self:set_scale(_, self.scale[2] + y, _) end
function Model:scale_z(z) self:set_scale(_, _, self.scale[3] + z) end


function Model:update_matrix()
	self.matrix = matrices.get_transformation(self.translation, self.rotation, self.scale)
end

function Model:draw()
	love.graphics.setShader(self.shader)
	self.shader:send("modelMatrix", self.matrix)
	love.graphics.draw(self.mesh)
	love.graphics.setShader()
end

return setmetatable({}, {__call = Model.new})
