Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	local level1 = require('assets/levels/1')
	local level2 = require('assets/levels/2')
	local level3 = require('assets/levels/3')

	@.levels = {
		Grid(level1[1], level1[2], level1[3]),
		Grid(level2[1], level2[2], level2[3]),
		Grid(level3[1], level3[2], level3[3]),
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

	if pressed('escape') then change_scene_with_transition('menu') end

	if pressed('q') || pressed('left')  then @:move('left')  end
	if pressed('d') || pressed('right') then @:move('right') end
	if pressed('z') || pressed('up')    then @:move('up')    end
	if pressed('s') || pressed('down')  then @:move('down')  end
	if pressed('r')                     then @:construct_level() end -- reset level


	--visual lerp
	if @.player[3] != @.player[1] then 
		@.player[3] = lerp(@.player[3], @.player[1], 20 *dt)
	end
	if @.player[4] != @.player[2] then 
		@.player[4] = lerp(@.player[4], @.player[2], 20 *dt)
	end

	for @.boxes do
		if it[3] != it[1] then 
			it[3] = lerp(it[3], it[1], 20 * dt)
		end
			
		if it[4] != it[2] then 
			it[4] = lerp(it[4], it[2], 20 * dt)
		end
	end
end

function Play_scene:draw_inside_camera_fg()
	for @.walls do 
		lg.setColor(.5, .5, .5)
		lg.rectangle('fill', it[1]*20, it[2]*20, 20, 20)
	end

	for @.boxes do 
		lg.setColor(.6, .8, .5)
		lg.rectangle('fill', it[3]*20, it[4]*20, 20, 20)
	end

	lg.setColor(1, 1, 0)
	lg.rectangle('fill', @.player[3]*20, @.player[4]*20, 20, 20)

	for @.pads do 
		lg.setColor(1, 0, 0)
		lg.rectangle('line', it[1]*20, it[2]*20, 20, 20)
	end

	lg.setColor(1, 1, 1)
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
			@.player = {i, j, i, j}

		elif value == 'b' then
			insert(@.boxes, {i, j, i, j})

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
	if @.trigger:get('move_player') ||
		@.trigger:get('box_player_x')  ||
		@.trigger:get('box_player_y') then 
		return 
	end

	local target
	local target_next
	local target_block
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
		@.player[3] = target[1]
		@.player[4] = target[2]

	-- box || pad w/ box
	elif target_block == 'o' || target_block == 'b' then
		local box = (fn() for @.boxes do if it[1] == target[1] && it[2] == target[2] then return it end end end)()

		if target_next_block == nil || target_next_block == 'u' then 
			@.player[1] = target[1]
			@.player[2] = target[2]
			box[1]      = target_next[1]
			box[2]      = target_next[2]
		else
			@.player[3] = target[1]
			@.player[4] = target[2]
		end
	end
	
	@:update_level()
end
