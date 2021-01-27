Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@.moon    = g4d.add_model('assets/obj/sphere.obj', 'assets/images/moon.png', {-5, 5, 20}, _, {2, 2, 2})
	@.cube1   = g4d.add_model('assets/obj/cube.obj', _ , {-2, 0, 24}, _,  _, {0, 1, 1})
	@.cube2   = g4d.add_model('assets/obj/cube.obj', _ , {-6, 0, 24}, _,  _, {1, 0, 1})
	@.cube3   = g4d.add_model('assets/obj/cube.obj', _ , {-10, 0, 24}, _, _, {1, 1, 0})
	@.cube4   = g4d.add_model('assets/obj/cube.obj', _ , {-2, 0, 16}, _,  _, {1, 0, 0})
	@.cube5   = g4d.add_model('assets/obj/cube.obj', _ , {-6, 0, 16}, _,  _, {0, 1, 0})
	@.cube6   = g4d.add_model('assets/obj/cube.obj', _ , {-10, 0, 16}, _, _, {0, 0, 1})

	@.light1 = g4d.add_model('assets/obj/sphere.obj', _ , {5, 10, 16}, _, { .3, .3, .3}, {0, 1, 0}, true, .1, .6)
	@.light2 = g4d.add_model('assets/obj/sphere.obj', _ , {-5, 5, 5}, _, { .3, .3, .3}, {1, 1, 0}, true, .1, .6)

	@.f = Sinewave(0, 1, 10)
	@.g = Sinewave(0, 2, 20)
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	@.f:update(dt)
	@.g:update(dt)

	if pressed('escape') then game:change_scene_with_transition('menu') end
	if down('q')      then g4d.camera:update(dt, 'left')   end
	if down('d')      then g4d.camera:update(dt, 'right')  end
	if down('lshift') then g4d.camera:update(dt, 'up')     end
	if down('lctrl')  then g4d.camera:update(dt, 'down')   end
	if down('z')      then g4d.camera:update(dt, 'toward') end
	if down('s')      then g4d.camera:update(dt, 'back')   end

	
	@.light1:move(-5 + @.f:get_cos(), _, 20 +@.f:get_sin())
	@.light2:move(_, 5 +@.g:get_cos(), _)
	
	
	@.moon:rotate(@.moon.rx + dt)
	@.cube1:rotate(@.cube1.rx + dt)
	@.cube2:rotate(_, @.cube2.ry + dt)
	@.cube3:rotate(_, _, @.cube3.rz + dt)
	@.cube4:rotate(@.cube4.rx + dt)
	@.cube5:rotate(_, @.cube5.ry + dt)
	@.cube6:rotate(_, _, @.cube6.rz + dt)
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
