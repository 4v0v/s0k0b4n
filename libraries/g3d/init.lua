--[[
 based on groverbuger's g3d 
 https://github.com/groverburger/g3d
 MIT license
         __       __     
       /'__`\    /\ \    
   __ /\_\L\ \   \_\ \   
 /'_ `\/_/_\_<_  /'_` \  
/\ \L\ \/\ \L\ \/\ \L\ \ 
\ \____ \ \____/\ \___,_\
 \/___L\ \/___/  \/__,_ /
   /\____/               
   \_/__/                
--]]

love.graphics.setDepthMode("lequal", true)

G3D_PATH     = ...
local model  = require(G3D_PATH .. "/g3d_model")
local camera = require(G3D_PATH .. "/g3d_camera")
G3D_PATH     = nil

local G3d = {
	Model  = model,
	Camera = camera,
	Canvas = love.graphics.newCanvas(),
}

function G3d:attach() 
	love.graphics.setCanvas({self.Canvas, depth=true})
	love.graphics.clear()
end

function G3d:detach() 
	love.graphics.setCanvas()
end

function G3d:draw(x, y)
	love.graphics.draw(self.Canvas, x or 0, y or 0)
end

return G3d