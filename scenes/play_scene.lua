Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@.earth  = g3d.Model('assets/obj/sphere.obj', 'assets/images/earth.png' , {0, 0, 4}, _, { 1,  1,  1})
	@.moon   = g3d.Model('assets/obj/sphere.obj', 'assets/images/moon.png'  , {5, 0, 4}, _, {.5, .5, .5})
	@.cube   = g3d.Model('assets/obj/cube.obj'  , _                         , {4, 0, 0}, _, {.5, .5, .5})
	@.cube2  = g3d.Model('assets/obj/cube.obj'  , _                         , {5, 0, 0}, _, {.5, .5, .5})
	@.cube3  = g3d.Model('assets/obj/cube.obj'  , _                         , {6, 0, 0}, _, {.5, .5, .5})
	@.magica = g3d.Model('assets/obj/magica_voxel.obj', 'assets/images/magica_voxel.png', {8, 2, 1}, _, {.5, .5, .5})
	@.canvas = lg.newCanvas()

	@.t = 0
	@.pos = 1
	@:every_immediate(2, fn() 
		@:tween(1, @, {pos = 4}, 'in-out-cubic', _ , fn() 
			@:tween(1, @, {pos = 1}, 'in-out-cubic')
		end)
	end)

end

function Play_scene:enter()
	love.mouse.setRelativeMode(true)
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	if down('q')        then g3d.Camera:first_person_movement(dt, 'left')     end
	if down('d')        then g3d.Camera:first_person_movement(dt, 'right')    end
	if down('lshift') || down('space') then g3d.Camera:first_person_movement(dt, 'up') end
	if down('lctrl')    then g3d.Camera:first_person_movement(dt, 'down')     end
	if down('z')        then g3d.Camera:first_person_movement(dt, 'forward')  end
	if down('s')        then g3d.Camera:first_person_movement(dt, 'backward') end
	if pressed('left')  then @.cube2:move_x(-1) end
	if pressed('right') then @.cube2:move_x(1)  end
	if pressed('up')    then @.cube2:move_y(1)  end
	if pressed('down')  then @.cube2:move_y(-1) end

	@.t += dt
	@.moon:set_translation(math.cos(@.t)*5, 0, math.sin(@.t)*5 +4)
	@.moon:set_ry(-1*@.t) 

	@.cube:set_y(@.pos)
end

function Play_scene:draw_outside_camera_fg()
	lg.setCanvas({@.canvas, depth=true})
	lg.clear()
		@.earth:draw()
		@.moon:draw()

		lg.setColor(1, 0, 0)
		@.cube:draw()

		lg.setColor(0, 1, 1)
		@.cube2:draw()

		lg.setColor(0, 1, 0)
		@.cube3:draw()

		lg.setColor(1, 1, 1)
		@.magica:draw()

	lg.setCanvas()

	lg.draw(@.canvas, 0, 0)
	lg.print('x = ' .. g3d.Camera.pos[1] , 0, 0 )
	lg.print('y = ' .. g3d.Camera.pos[2] , 0, 15 )
	lg.print('z = ' .. g3d.Camera.pos[3] , 0, 30 )
end

function Play_scene:mousemoved(x,y, dx,dy)
	g3d.Camera:first_person_look(dx,dy)
end
