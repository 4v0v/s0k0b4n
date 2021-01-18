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

g3d.Model  = require(G3D_PATH .. "/model")
g3d.Camera = require(G3D_PATH .. "/camera")
g3d.Camera:updateProjectionMatrix()

love.graphics.setDepthMode("lequal", true)
G3D_PATH = nil

return g3d
