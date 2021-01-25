Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@.moon    = g4d.add_model('assets/obj/sphere.obj', 'assets/images/moon.png', {-5, 5, 20}, _, {2, 2, 2})
	@.cube1   = g4d.add_model('assets/obj/cube.obj', _ , {-2, 0, 24}, _, {1, 1, 1}, {1, 0, 0})
	@.cube2   = g4d.add_model('assets/obj/cube.obj', _ , {-6, 0, 24}, _, {1, 1, 1}, {0, 1, 0})
	@.cube3   = g4d.add_model('assets/obj/cube.obj', _ , {-10, 0, 24}, _, {1, 1, 1}, {0, 0, 1})

	@.light1 = g4d.add_model('assets/obj/sphere.obj', _ , {5, 5, 16}, _, { .3, .3, .3}, {1, .5, .5}, true)
	-- @.light2 = g4d.add_model('assets/obj/sphere.obj', _ , {-5, 5, 0}, _, { .3, .3, .3}, {1, 1, 1}, true)

	@.f = Sinewave(0, 1, 5)
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	@.f:update(dt)

	if pressed('escape') then game:change_scene_with_transition('menu') end
	if down('q')      then g4d.camera:update(dt, 'left')   end
	if down('d')      then g4d.camera:update(dt, 'right')  end
	if down('lshift') then g4d.camera:update(dt, 'up')     end
	if down('lctrl')  then g4d.camera:update(dt, 'down')   end
	if down('z')      then g4d.camera:update(dt, 'toward') end
	if down('s')      then g4d.camera:update(dt, 'back')   end

	@.moon:rotate(@.moon.rx + dt)

	@.light1:move(-5 + @.f:get_cos(), _, 20 +@.f:get_sin())

	@.cube1:rotate(@.cube1.rx + dt)
	@.cube2:rotate(_, @.cube2.ry + dt)
	@.cube3:rotate(_, _, @.cube3.rz + dt)
end

function Play_scene:draw_outside_camera_fg()
	g4d:draw()
end

function Play_scene:enter()
	lm.setRelativeMode(true)
end

function Play_scene:exit()
	lm.setRelativeMode(false)
end

function Play_scene:mousemoved(x,y, dx,dy)
	g4d.camera:mousemoved(dx,dy)
end
