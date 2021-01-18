-- written by groverbuger for g3d
-- january 2021
-- MIT license

local vectors     = require(G3D_PATH .. "/vectors")
local matrices    = require(G3D_PATH .. "/matrices")
local loadObjFile = require(G3D_PATH .. "/objloader")

local Model = {}

Model.vertexFormat = {
	{"VertexPosition", "float", 3},
	{"VertexTexCoord", "float", 2},
	{"VertexNormal"  , "float", 3},
	{"VertexColor"   , "byte" , 4},
}

Model.shader = require(G3D_PATH .. "/shader")

function Model:new(given, texture, translation, rotation, scale)
    local obj = setmetatable({}, {__index = Model})

		if type(given)   == "string" then given   = loadObjFile(given) end
		if type(texture) == "string" then texture = love.graphics.newImage(texture) end

		obj.verts   = given
		obj.texture = texture
		obj.mesh    = love.graphics.newMesh(obj.vertexFormat, obj.verts, "triangles")
		
		obj.mesh:setTexture(obj.texture)
		obj:setTransform(translation, rotation, scale)

    return obj
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

function Model:setTransform(translation, rotation, scale)
	self.translation = translation or {0,0,0}
	self.rotation    = rotation    or {0,0,0}
	self.scale       = scale       or {1,1,1}
	self:updateMatrix()
end

function Model:setTranslation(x, y, z)
	self.translation[1] = x
	self.translation[2] = y
	self.translation[3] = z
	self:updateMatrix()
end

function Model:setRotation(x, y, z)
	self.rotation[1] = x
	self.rotation[2] = y
	self.rotation[3] = z
	self:updateMatrix()
end

function Model:setScale(x, y, z)
	self.scale[1] = x
	self.scale[2] = y or x
	self.scale[3] = z or x
	self:updateMatrix()
end

function Model:setXTranslation(x) self:setTranslation(x, _, _) end
function Model:setYTranslation(y) self:setTranslation(_, y, _) end
function Model:setZTranslation(z) self:setTranslation(_, _, z) end

function Model:setXRotation(x) self:setRotation(x, _, _) end
function Model:setYRotation(y) self:setRotation(_, y, _) end
function Model:setZRotation(z) self:setRotation(_, _, z) end

function Model:setXScale(x) self:setScale(x, _, _) end
function Model:setYScale(y) self:setScale(_, y, _) end
function Model:setZScale(z) self:setScale(_, _, z) end

function Model:updateMatrix()
	self.matrix = matrices.getTransformationMatrix(self.translation, self.rotation, self.scale)
end

function Model:draw()
	love.graphics.setShader(self.shader)
	self.shader:send("modelMatrix", self.matrix)
	love.graphics.draw(self.mesh)
	love.graphics.setShader()
end

return setmetatable({}, {__call = Model.new})
