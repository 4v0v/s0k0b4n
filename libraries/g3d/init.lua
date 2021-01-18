-- written by groverbuger for g3d
-- january 2021
-- MIT license

--[[
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

local g3d = {}

G3D_PATH = ...

g3d.Model  = require(G3D_PATH .. "/g3d_model")
g3d.Camera = require(G3D_PATH .. "/g3d_camera")

love.graphics.setDepthMode("lequal", true)
g3d.Camera:updateProjectionMatrix()
g3d.Camera:lookInDirection(
	g3d.Camera.position[1],
	g3d.Camera.position[2],
	g3d.Camera.position[3],
	g3d.Camera.fps.direction,
	g3d.Camera.fps.pitch
)
G3D_PATH = nil

return g3d
