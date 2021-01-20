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

local g3d = {}

g3d.Model  = model
g3d.Camera = camera

return g3d
