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

G3D_PATH = ...
love.graphics.setDepthMode("lequal", true)

local g3d = {}

g3d.Model  = require(G3D_PATH .. "/g3d_model")
g3d.Camera = require(G3D_PATH .. "/g3d_camera")

G3D_PATH = nil

return g3d
