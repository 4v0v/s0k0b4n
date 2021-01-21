local Vectors  = require(G3D_PATH .. "/g3d_vectors")
local Matrices = require(G3D_PATH .. "/g3d_matrices")
local load_obj = require(G3D_PATH .. "/g3d_objloader")

local Model = {}

Model.vertexFormat = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexNormal"  , "float", 3},
	{"VertexColor"   , "byte" , 4},
}
Model.shader = require(G3D_PATH .. "/g3d_shaderloader")

function Model:new(given, texture, pos, rot, sca)
	local model = setmetatable({}, {__index = Model})

	if type(given)   == "string" then given   = load_obj(given) end
	if type(texture) == "string" then texture = love.graphics.newImage(texture) end

	model.x       = pos and pos[1] or 0
	model.y       = pos and pos[2] or 0
	model.z       = pos and pos[3] or 0
	model.rx      = rot and rot[1] or 0
	model.ry      = rot and rot[2] or 0
	model.rz      = rot and rot[3] or 0
	model.sx      = sca and sca[1] or 1
	model.sy      = sca and sca[2] or 1
	model.sz      = sca and sca[3] or 1
	model.matrix  = {}
	model.verts   = given
	model.texture = texture
	model.mesh    = love.graphics.newMesh(model.vertexFormat, model.verts, "triangles")

	model.mesh:setTexture(texture)
	model:update_matrix()

	return model
end

function Model:update_matrix()
	self.matrix = Matrices.get_transformation(
		self.x , self.y , self.z ,
		self.rz, self.ry, self.rz,
		self.sx, self.sy, self.sz
	)
end

function Model:draw()
	love.graphics.setShader(self.shader)
	self.shader:send("model_matrix", self.matrix)
	love.graphics.draw(self.mesh)
	love.graphics.setShader()
end

function Model:make_normals(flipped)
	for i=1, #self.verts, 3 do
		local vp = self.verts[i]
		local v  = self.verts[i+1]
		local vn = self.verts[i+2]

		local vec1     = {v[1]-vp[1], v[2]-vp[2], v[3]-vp[3]}
		local vec2     = {vn[1]-v[1], vn[2]-v[2], vn[3]-v[3]}
		local normal   = Vectors.normalize(Vectors.cross_product(vec1,vec2))
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

	self:update_matrix()
end

function Model:position() return {self.x, self.y, self.z} end
function Model:get_position() return {self.x, self.y, self.z} end
function Model:get_rotation() return {self.rx, self.ry, self.rz} end
function Model:get_scale() return {self.sx, self.sy, self.sz} end

function Model:set_position(x, y, z) self:transform(x, y, z) end
function Model:set_rotation(rx, ry, rz) self:transform(_, _, _, rx, ry, rz) end
function Model:set_scale(sx, sy, sz) self:transform(_, _, _, _, _, _, sx, sy, sz) end

function Model:set_x(x) self:set_position(x, _, _) end
function Model:set_y(y) self:set_position(_, y, _) end
function Model:set_z(z) self:set_position(_, _, z) end
function Model:set_rx(rx) self:set_rotation(rx, _, _) end
function Model:set_ry(ry) self:set_rotation(_, ry, _) end
function Model:set_rz(rz) self:set_rotation(_, _, rz) end
function Model:set_s(s) self:set_scale(s, s, s) end
function Model:set_sx(sx) self:set_scale(sx, _, _) end
function Model:set_sy(sy) self:set_scale(_, sy, _) end
function Model:set_sz(sz) self:set_scale(_, _, sz) end

function Model:move_x(x) self:set_position(self.x + x, _, _) end
function Model:move_y(y) self:set_position(_, self.y + y, _) end
function Model:move_z(z) self:set_position(_, _, self.z + z) end
function Model:rotate_x(rx) self:set_rotation(self.rx + rx, _, _) end
function Model:rotate_y(ry) self:set_rotation(_, self.ry + ry, _) end
function Model:rotate_z(rz) self:set_rotation(_, _, self.rz + rz) end
function Model:scale(s) self:set_scale(self.sx + s, self.sy + s, self.sz + s) end
function Model:scale_x(sx) self:set_scale(self.sx + sx, _, _) end
function Model:scale_y(sy) self:set_scale(_, sy + sy, _) end
function Model:scale_z(sz) self:set_scale(_, _, sz + sz) end

return setmetatable({}, {__call = Model.new})
