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


	@.grid = Grid(19, 10, { 
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		1, _, 1, _, 1, 1, 1, _, 1, _, _, _, 1, _, _, _, 1, 1, 1,
		1, _, 1, _, 1, _, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1,
		1, 1, 1, _, 1, 1, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1,
		1, _, 1, _, 1, _, _, _, 1, _, _, _, 1, _, _, _, 1, _, 1,
		1, _, 1, _, 1, 1, 1, _, 1, 1, 1, _, 1, 1, 1, _, 1, 1, 1,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
		_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,
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

	@.t = 0
	@.pos = 1
	@:every_immediate(2, fn() 
		@:tween(1, @, {pos = 4}, 'in-out-cubic', _ , fn() 
			@:tween(1, @, {pos = 1}, 'in-out-cubic')
		end)
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
	if down('q')        then g3d.Camera:first_person_movement(dt, 'left')     end
	if down('d')        then g3d.Camera:first_person_movement(dt, 'right')    end
	if down('lshift') || down('space') then g3d.Camera:first_person_movement(dt, 'up') end
	if down('lctrl')    then g3d.Camera:first_person_movement(dt, 'down')     end
	if down('z')        then g3d.Camera:first_person_movement(dt, 'forward')  end
	if down('s')        then g3d.Camera:first_person_movement(dt, 'backward') end
	if down('g')        then g3d.Camera:look_at(0, 0, 0, 1, 0, 0) end
	if pressed('left')  then @.cube2:move_x(-1) end
	if pressed('right') then @.cube2:move_x(1)  end
	if pressed('up')    then @.cube2:move_y(1)  end
	if pressed('down')  then @.cube2:move_y(-1) end

	@.t += dt
	@.moon:set_position(math.cos(@.t)*5, 0, math.sin(@.t)*5 +4)
	@.moon:set_ry(@.t)

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
		'z     = ' .. rounded(g3d.Camera.z    , 2) .. '\n' ..
		'dir   = ' .. rounded(g3d.Camera.dir  , 2) .. '\n' ..
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
