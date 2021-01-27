Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@.levels = {
		Grid( 10, 10, {
			'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
			'w',   _,   _,   _,   _,   _,   _,   _,   _, 'w',
			'w',   _,   _,   _,   _,   _,   _,   _,   _, 'w',
			'w',   _, 'p',   _, 'b',   _,   _, 'u',   _, 'w',
			'w',   _,   _,   _,   _,   _,   _,   _,   _, 'w',
			'w',   _,   _,   _,   _,   _,   _,   _,   _, 'w',
			'w',   _,   _,   _, 'b',   _,   _, 'u',   _, 'w',
			'w',   _,   _,   _,   _,   _,   _,   _,   _, 'w',
			'w',   _,   _,   _,   _,   _,   _,   _,   _, 'w',
			'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
		}),
		Grid( 10, 10, {
			'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _, 'p',   _, 'b', 'w',   _, 'u',   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _, 'b',   _,   _, 'u',   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
		}),
	}
	@.current_level = 1
	@.player = {}
	@.bricks = {}
	@.walls  = {}
	@.pads   = {}


	@:construct_level()
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	if pressed('escape') then game:change_scene_with_transition('menu') end

	if pressed('q') || pressed('left')  then @:move_left()  end
	if pressed('d') || pressed('right') then @:move_right() end
	if pressed('z') || pressed('up')    then @:move_up()    end
	if pressed('s') || pressed('down')  then @:move_down()  end

end

function Play_scene:draw_inside_camera_fg()
	@.levels[@.current_level]:foreach(fn(grid, i, j, value) 
		if   value == 'w'then
			lg.setColor(.5, .5, .5)
			lg.rectangle('fill', i*20, j*20, 20, 20)
		elif value == 'p' then
			lg.setColor(1, 1, 0)
			lg.rectangle('fill', i*20, j*20, 20, 20)
		elif value == 'b' then
			lg.setColor(.6, .8, .5)
			lg.rectangle('fill', i*20, j*20, 20, 20)
		elif value == 'u' then
			lg.setColor(1, 0, 0)
			lg.rectangle('line', i*20, j*20, 20, 20)
		elif value == 'o' then
			lg.setColor(.8, .2, .2)
			lg.rectangle('line', i*20, j*20, 20, 20)
		end

		lg.setColor(1, 1, 1)

	end)
end

function Play_scene:construct_level()
	@.player = {}
	@.bricks = {}
	@.walls  = {}
	@.pads   = {}

	@.levels[@.current_level]:foreach(fn(grid, i, j, value) 
		if   value == 'w'  then
			table.insert(@.walls, {i, j})
			
		elif value == 'p' then
			@.player = {i, j}

		elif value == 'b' then
			table.insert(@.bricks, {i, j})

		elif value == 'u' then
			table.insert(@.pads, {i, j})

		elif value == 'o' then
			table.insert(@.bricks, {i, j})
			table.insert(@.pads, {i, j})
		end
	end)
end

function Play_scene:update_level()
	local lvl = @.levels[@.current_level]

	lvl:fill(nil)

	lvl:set(@.player[1], @.player[2], 'p')

	for @.walls  do 
		lvl:set(it[1], it[2], 'w')
	end

	for @.bricks do
		lvl:set(it[1], it[2], 'b')
	end

	for @.pads   do 
		if lvl:get(it[1], it[2]) == 'b' then 
			lvl:set(it[1], it[2], 'o')
		else
			lvl:set(it[1], it[2], 'u')
		end
	end
end

function Play_scene:move_left()
	local lvl = @.levels[@.current_level]
	local next = lvl:get(@.player[1] - 1, @.player[2])

	if next == nil then 
		@.player[1] -= 1
	elif next == 'w' then
		-- can't move
	elif next == 'b' then
		local box_next = lvl:get(@.player[1] - 2, @.player[2])

	elif next == 'u' then
		@.player[1] -= 1

	elif next == 'o' then
		@.player[1] -= 1

	end
	
	@:update_level()
end

function Play_scene:move_right()
	local lvl = @.levels[@.current_level]
	local next = lvl:get(@.player[1] + 1, @.player[2])

	if next == nil then 
		@.player[1] += 1

	elif next == 'w' then
	elif next == 'b' then
	elif next == 'o' then
	elif next == 'u' then
	end

	@:update_level()
end

function Play_scene:move_up()
	local lvl = @.levels[@.current_level]
	local next = lvl:get(@.player[1], @.player[2] - 1)

	if next == nil then 
		@.player[2] -= 1

	elif next == 'w' then
	elif next == 'b' then
	elif next == 'o' then
	elif next == 'u' then
	end

	@:update_level()
end

function Play_scene:move_down()
	local lvl = @.levels[@.current_level]
	local next = lvl:get(@.player[1], @.player[2] + 1)

	if next == nil then 
		@.player[2] += 1
	elif next == 'w' then
	elif next == 'b' then
	elif next == 'o' then
	elif next == 'u' then
	end

	@:update_level()
end
