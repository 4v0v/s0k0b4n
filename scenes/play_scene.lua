Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@.levels = {
		Grid(10, 10, {
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
		Grid(10, 10, {
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
		Grid(19, 15, {
			'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _, 'p',   _, 'b', 'w',   _, 'u',   _, 'w',   _,   _,   _, 'b', 'w',   _, 'u',   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _, 'b',   _,   _, 'u',   _, 'w',   _,   _,   _, 'b',   _,   _, 'u',   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _,  _,    _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',   _,   _,   _,   _, 'w',   _,   _,   _, 'w',
			'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w', 'w',
		}),
	}

	@.level_idx = 1
	@.level     = {}
	@.player    = {}
	@.boxes     = {}
	@.walls     = {}
	@.pads      = {}

	@.camera:set_position(400, 300)
	@:construct_level()
end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	if pressed('escape') then game:change_scene_with_transition('menu') end

	if pressed('q') || pressed('left')  then @:move('left')  end
	if pressed('d') || pressed('right') then @:move('right') end
	if pressed('z') || pressed('up')    then @:move('up')    end
	if pressed('s') || pressed('down')  then @:move('down')  end
	if pressed('r')                     then @:construct_level() end -- reset level
end

function Play_scene:draw_inside_camera_fg()
	@.level:foreach(fn(grid, i, j, value) 
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
			lg.setColor(.6, .8, .5)
			lg.rectangle('fill', i*20, j*20, 20, 20)
			lg.setColor(.8, .2, .2)
			lg.rectangle('line', i*20, j*20, 20, 20)
		elif value == 'P' then
			lg.setColor(1, 1, 0)
			lg.rectangle('fill', i*20, j*20, 20, 20)
			lg.setColor(.8, .2, .2)
			lg.rectangle('line', i*20, j*20, 20, 20)
		end

		lg.setColor(1, 1, 1)

	end)
end

function Play_scene:construct_level()
	@.player = {}
	@.boxes  = {}
	@.walls  = {}
	@.pads   = {}

	@.level  = @.levels[@.level_idx]:clone()

	@.level:foreach(fn(grid, i, j, value) 
		if   value == 'w' then
			insert(@.walls, {i, j})
			
		elif value == 'p' then
			@.player = {i, j}

		elif value == 'b' then
			insert(@.boxes, {i, j})

		elif value == 'u' then
			insert(@.pads, {i, j})

		elif value == 'o' then
			insert(@.boxes, {i, j})
			insert(@.pads, {i, j})

		elif value == 'P' then
			@.player = {i, j}
			insert(@.pads, {i, j})
		end
	end)
end

function Play_scene:update_level()
	@.level:fill(nil)

	@.level:set(@.player[1], @.player[2], 'p')

	for @.walls do 
		@.level:set(it[1], it[2], 'w')
	end

	for @.boxes do
		@.level:set(it[1], it[2], 'b')
	end

	for @.pads do 
		if @.level:get(it[1], it[2]) == 'b' then 
			@.level:set(it[1], it[2], 'o')
		elif @.level:get(it[1], it[2]) == 'p' then
			@.level:set(it[1], it[2], 'P')
		else
			@.level:set(it[1], it[2], 'u')
		end
	end

	local empty_pads = #@.pads
	for box in @.boxes do 
		for pad in @.pads do 
			if box[1] == pad[1] && box[2] == pad[2] then 
				empty_pads -= 1 
			end
		end
	end

	if empty_pads == 0 then 
		@.level_idx += 1
		@:shake(10)
		@:construct_level()
	end
end

function Play_scene:move(dir)
	local target
	local target_block
	local target_next
	local target_next_block

	if   dir == 'left'  then 
		target      = {@.player[1] - 1, @.player[2]}
		target_next = {@.player[1] - 2, @.player[2]}

	elif dir == 'right' then 
		target      = {@.player[1] + 1, @.player[2]}
		target_next = {@.player[1] + 2, @.player[2]}

	elif dir == 'up'    then
		target      = {@.player[1], @.player[2] - 1}
		target_next = {@.player[1], @.player[2] - 2}

	elif dir == 'down'  then 
		target      = {@.player[1], @.player[2] + 1}
		target_next = {@.player[1], @.player[2] + 2}
	end

	target_block      = @.level:get(target[1], target[2])
	target_next_block = @.level:get(target_next[1], target_next[2])

	-- empty space || empty pad
	if   target_block == nil || target_block == 'u' then 
		@.player[1] = target[1]
		@.player[2] = target[2]

	-- wall
	elif target_block == 'w' then
		-- can't move

	-- box || pad w/ box
	elif target_block == 'o' || target_block == 'b' then
		local box = (fn() for @.boxes do if it[1] == target[1] && it[2] == target[2] then return it end end end)()

		if target_next_block == nil || target_next_block == 'u' then 
			box[1]      = target_next[1]
			box[2]      = target_next[2]
			@.player[1] = target[1]
			@.player[2] = target[2]
		end
	end
	
	@:update_level()
end
