Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@.earth  = g3d.Model('assets/obj/sphere.obj', _ , {5, 5, 0}, _, { .3,  .3,  .3})
	@.moon   = g3d.Model('assets/obj/sphere.obj', 'assets/images/moon.png'  , {-500, -6, 15}, _, {100, 100, 100})
	@.magica = g3d.Model('assets/obj/magica.obj', 'assets/images/magica.png', {25, 5, 5}, _, {1, 1, 1})
	@.eye   = g3d.Model('assets/obj/eye.obj', 'assets/images/eye.png'  , {5, 5, 5}, _, {.5, .5, .5})

	@.cube   = g3d.Model('assets/obj/cube.obj'  , _                         , {2, 5,10}, _, {.5, .5, .5})
	@.cube1  = g3d.Model('assets/obj/cube.obj'  , _                         , {4, 0, 8}, _, {.5, .5, .5})
	@.cube2  = g3d.Model('assets/obj/cube.obj'  , _                         , {6, 0, 8}, _, {.5, .5, .5})
	@.cube3  = g3d.Model('assets/obj/cube.obj'  , _                         , {8, 0, 8}, _, {.5, .5, .5})
	@.canvas = lg.newCanvas()

	@.grid = Grid(21, 14, { 
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		_, 1, _, 1, _, 1, 1, 1, _, 1, _, _, _, 1, _, _, _, 1, 1, 1, _,
		_, 1, _, 1, _, 1, _, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1, _,
		_, 1, 1, 1, _, 1, 1, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1, _,
		_, 1, _, 1, _, 1, _, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1, _,
		_, 1, _, 1, _, 1, 1, 1, _, 1, 1, 1, _, 1, 1, 1, _, 1, 1, 1, _,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		_, 1, _, 1, _, 1, 1, 1, _, 1, 1, 1, _, 1, _, _, _, 1, 1, _, _,
		_, 1, _, 1, _, 1, _, 1, _, 1, _, 1, _, 1, _, _, _, 1, _, 1, _,
		_, 1, _, 1, _, 1, _, 1, _, 1, 1, _, _, 1, _, _, _, 1, _, 1, _,
		_, 1, 1, 1, _, 1, _, 1, _, 1, _, 1, _, 1, _, _, _, 1, _, 1, _,
		_, 1, _, 1, _, 1, 1, 1, _, 1, _, 1, _, 1, 1, 1, _, 1, 1, _, _,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
	})
	@.cubes = {}

	@.grid:foreach(fn(grid, i, j)
		local value = grid:get(i, j)
		if !value then return end
		table.insert(@.cubes, { 
			value = value, 
			cube = g3d.Model('assets/obj/cube.obj', _ , {i, -j, 5}, _, {.5, .5, .5})
		})
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

	if pressed('escape') then game:change_scene_with_transition('menu') end
	if down('q')      then g3d.Camera:update(dt, 'left')     end
	if down('d')      then g3d.Camera:update(dt, 'right')    end
	if down('lshift') then g3d.Camera:update(dt, 'up')       end
	if down('lctrl')  then g3d.Camera:update(dt, 'down')     end
	if down('z')      then g3d.Camera:update(dt, 'toward')   end
	if down('s')      then g3d.Camera:update(dt, 'back') end

	if pressed('left')  then @.cube2:move_x(-1) end
	if pressed('right') then @.cube2:move_x(1)  end
	if pressed('up')    then @.cube2:move_y(1)  end
	if pressed('down')  then @.cube2:move_y(-1) end

	@.moon:rotate(_,@.moon.ry + dt,_)
	@.cube1:rotate(@.cube1.rx+ 2*dt, _, _)
	@.cube2:rotate(_, @.cube2.ry+ 2*dt, _)
	@.cube3:rotate(_, _, @.cube3.rz+ 2*dt)

	@.cube:move(_,@.cube_tween:get(),_)
end

function Play_scene:draw_outside_camera_fg()
	lg.setCanvas({@.canvas, depth=true})
	lg.clear()
		@.earth:draw()
		@.moon:draw()

		lg.setColor(1, 0, 0)
		@.cube:draw()
		@.cube1:draw()

		lg.setColor(0, 1, 1)
		@.cube2:draw()

		lg.setColor(0, 1, 0)
		@.cube3:draw()

		lg.setColor(1, 1, 1)
		@.magica:draw()
		@.eye:draw()

		ifor @.cubes do
			if it.value == 1 then lg.setColor(1, 0, 1) end
			if it.value == 2 then lg.setColor(0, 1, 0) end
			if it.value == 3 then lg.setColor(0, 0, 1) end
			it.cube:draw()
		end

		lg.setColor(1, 1, 1)

	lg.setCanvas()

	lg.draw(@.canvas, 0, 0)
	lg.print(
		'x     = ' .. rounded(g3d.Camera.x    , 2) .. '\n' ..
		'y     = ' .. rounded(g3d.Camera.y    , 2) .. '\n' ..
		'z     = ' .. rounded(g3d.Camera.z    , 2) .. '\n\n' ..
		'tx    = ' .. rounded(g3d.Camera.tx   , 2) .. '\n' ..
		'ty    = ' .. rounded(g3d.Camera.ty   , 2) .. '\n' ..
		'tz    = ' .. rounded(g3d.Camera.tz   , 2) .. '\n\n' ..
		'yaw   = ' .. rounded(g3d.Camera.yaw  , 2) .. '\n' ..
		'pitch = ' .. rounded(g3d.Camera.pitch, 2)
	)

	local cx, cy = lg.getWidth()/2, lg.getHeight()/2
	lg.circle('line', cx, cy, 10)
	lg.line(cx, cy - 10, cx, cy + 10)
	lg.line(cx - 10, cy, cx + 10, cy)
end

function Play_scene:mousemoved(x,y, dx,dy)
	g3d.Camera:mousemoved(dx,dy)
end
