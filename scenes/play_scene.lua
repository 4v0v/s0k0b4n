Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@.eye    = g4d.add_model(_,'assets/obj/eye.obj', 'assets/images/eye.png'  , {5, 5, 5}, _, {.5, .5, .5})
	@.magica = g4d.add_model(_,'assets/obj/magica.obj', 'assets/images/magica.png', {25, -20, -5}, _, {1, 1, 1})
	@.moon   = g4d.add_model(_,'assets/obj/sphere.obj', 'assets/images/moon.png'  , {-500, -6, 15}, _, {100, 100, 100})
	@.cube   = g4d.add_model(_,'assets/obj/cube.obj', _ , {2, 5,20}, _, {.5, .5, .5}, {1, 0, 0})
	@.cube1  = g4d.add_model(_,'assets/obj/cube.obj', _ , {4, 0, 8}, _, {.5, .5, .5}, {1, 0, 0})
	@.cube2  = g4d.add_model(_,'assets/obj/cube.obj', _ , {6, 0, 8}, _, {.5, .5, .5}, {0, 1, 0})
	@.cube3  = g4d.add_model(_,'assets/obj/cube.obj', _ , {8, 0, 8}, _, {.5, .5, .5}, {0, 0, 1})
	@.earth  = g4d.add_model(_,'assets/obj/sphere.obj', _ , {5, 5, 0}, _, { .3, .3, .3})
	@.plane  = g4d.add_model(_,
		{
			{  0,   0, 100,  1, 1,  _, _, _,  _, _, _, _}, 
			{  0, 100, 100,  1, 0,  _, _, _,  _, _, _, _}, 
			{100, 100, 100,  0, 0,  _, _, _,  _, _, _, _},

			{  0,   0, 100,  1, 1,  _, _, _,  _, _, _, _}, 
			{100,   0, 100,  0, 1,  _, _, _,  _, _, _, _},
			{100, 100, 100,  0, 0,  _, _, _,  _, _, _, _},
		},
		'assets/images/smiley.png'
	)
	@.floor = g4d.add_model(_, 'assets/obj/plane.obj', _, {_, -30, _}, {math.pi, _, _}, {50, 50, 50}, {.2, .2 ,.2})

	@.grid = Grid(21, 5, { 
		_, 1, _, 1, _, 1, 1, 1, _, 1, _, _, _, 1, _, _, _, 1, 1, 1, _,
		_, 1, _, 1, _, 1, _, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1, _,
		_, 1, 1, 1, _, 1, 1, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1, _,
		_, 1, _, 1, _, 1, _, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1, _,
		_, 1, _, 1, _, 1, 1, 1, _, 1, 1, 1, _, 1, 1, 1, _, 1, 1, 1, _,
	}):foreach(fn(grid, i, j)
		local value = grid:get(i, j)
		if !value then return end
		g4d.add_model(_, 'assets/obj/cube.obj', _ , {i, -j, 5}, _, {.5, .5, .5}, {1, 0, 1})
	end)

	@.cube_tween = Tween(1, 'in-out-cubic')
	@:every_immediate(2, fn()
		@.cube_tween:tween(4, 1)
		@:after(1, fn() @.cube_tween:tween(1, 1) end)
	end)
end

function Play_scene:enter()
	lm.setRelativeMode(true)
end

function Play_scene:exit()
	lm.setRelativeMode(false)
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	@.cube_tween:update(dt)

	if pressed('escape') then game:change_scene_with_transition('menu') end
	if down('q')      then g4d.camera:update(dt, 'left')   end
	if down('d')      then g4d.camera:update(dt, 'right')  end
	if down('lshift') then g4d.camera:update(dt, 'up')     end
	if down('lctrl')  then g4d.camera:update(dt, 'down')   end
	if down('z')      then g4d.camera:update(dt, 'toward') end
	if down('s')      then g4d.camera:update(dt, 'back')   end

	if pressed('left')  then @.cube2:move(-1,_,_) end
	if pressed('right') then @.cube2:move(1,_,_)  end
	if pressed('up')    then @.cube2:move(_,1,_)  end
	if pressed('down')  then @.cube2:move(_,-1,_) end

	@.moon:rotate(_,@.moon.ry + dt,_)
	@.cube:move(_,@.cube_tween:get(),_)
	@.cube1:rotate(@.cube1.rx+ 2*dt, _, _)
	@.cube2:rotate(_, @.cube2.ry+ 2*dt, _)
	@.cube3:rotate(_, _, @.cube3.rz+ 2*dt)

	-- g4d.camera:look_at(@.earth:position())
end

function Play_scene:draw_outside_camera_fg()
	g4d:draw()

	lg.print(
		'x     = ' .. rounded(g4d.camera.x    , 2) .. '\n' ..
		'y     = ' .. rounded(g4d.camera.y    , 2) .. '\n' ..
		'z     = ' .. rounded(g4d.camera.z    , 2) .. '\n\n' ..
		'tx    = ' .. rounded(g4d.camera.tx   , 2) .. '\n' ..
		'ty    = ' .. rounded(g4d.camera.ty   , 2) .. '\n' ..
		'tz    = ' .. rounded(g4d.camera.tz   , 2) .. '\n\n' ..
		'yaw   = ' .. rounded(g4d.camera.yaw  , 2) .. '\n' ..
		'pitch = ' .. rounded(g4d.camera.pitch, 2)
	)

	local cx, cy = lg.getWidth()/2, lg.getHeight()/2
	lg.circle('line', cx, cy, 10)
	lg.line(cx, cy - 10, cx, cy + 10)
	lg.line(cx - 10, cy, cx + 10, cy)
end

function Play_scene:mousemoved(x,y, dx,dy)
	g4d.camera:mousemoved(dx,dy)
end
