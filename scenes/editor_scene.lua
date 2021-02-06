Editor_scene = Scene:extend('Editor_scene')

function Editor_scene:new(id)
	Editor_scene.super.new(@, id)

	@.grid             = Grid(30, 20)
	@.current_cell_pos = {0, 0}
	@.cell_size        = 25

	@.camera:set_position(400, 300)
	@:zoom(1)
end

function Editor_scene:update(dt)
	Editor_scene.super.update(@, dt)

	if pressed('escape') then change_scene_with_transition('menu') end
	if pressed('c')      then @.grid:fill(0)                       end

	local mouse_pos = @:get_mouse_position_inside_camera()

	@.current_cell_pos[1] = math.floor(mouse_pos[1] / @.cell_size)
	@.current_cell_pos[2] = math.floor(mouse_pos[2] / @.cell_size)

	if !@.grid:is_oob(@.current_cell_pos) then
		if pressed('w') then @:shake(10) end
		if   down('w') then 
			@.grid:set(@.current_cell_pos, 'w')
		elif down('p') then
			@.grid:set(@.current_cell_pos, 'p')
		elif down('u') then
			@.grid:set(@.current_cell_pos, 'u')
		elif down('b') then
			@.grid:set(@.current_cell_pos, 'b')
		end
	end

	if down('m_2') && !@.grid:is_oob(@.current_cell_pos) then 
		@.grid:set(@.current_cell_pos, 0)
	end
end

function Editor_scene:draw_inside_camera_fg()
	local walls   = @.grid:get_all_cells_with_value('w')
	local players = @.grid:get_all_cells_with_value('p')
	local pads    = @.grid:get_all_cells_with_value('u')
	local boxes   = @.grid:get_all_cells_with_value('b')

	lg.setColor(.2, .2, .2)
	@.grid:foreach(fn(grid, i, j, value)
		lg.rectangle('line', i * @.cell_size, j * @.cell_size, @.cell_size, @.cell_size)
	end)

	lg.setColor(.5, .5, .5)
	for walls do 
		lg.rectangle('fill', it[1] * @.cell_size, it[2] * @.cell_size, @.cell_size, @.cell_size)
	end

	lg.setColor(.6, .8, .5)
	for boxes do 
		lg.rectangle('fill', it[1] * @.cell_size, it[2] * @.cell_size, @.cell_size, @.cell_size)
	end

	lg.setColor(1, 1, 0)
	for players do 
		lg.rectangle('fill', it[1] * @.cell_size, it[2] * @.cell_size, @.cell_size, @.cell_size)
	end

	lg.setColor(1, 0, 0)
	for pads do 
		lg.rectangle('line', it[1] * @.cell_size, it[2] * @.cell_size, @.cell_size, @.cell_size)
	end

	if !@.grid:is_oob(@.current_cell_pos) then
		lg.setColor(1, 1, 1)
		lg.rectangle('line', @.current_cell_pos[1] * @.cell_size, @.current_cell_pos[2] * @.cell_size, @.cell_size, @.cell_size)
	end

	lg.setColor(1, 1, 1)
end

function Editor_scene:mousemoved(x, y, dx, dy)
	if down('m_3') then 
		@.camera:move(-dx, -dy)
	end
end