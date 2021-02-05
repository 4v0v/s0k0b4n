Editor_scene = Scene:extend('Editor_scene')

function Editor_scene:new(id)
	Editor_scene.super.new(@, id)

	@.grid = Grid(30, 20)


	@.current_cell_pos = {0, 0}
	@.cell_size = 25

	@.camera:set_position(400, 300)
	@:zoom(1)
end

function Editor_scene:update(dt)
	Editor_scene.super.update(@, dt)

	if pressed('escape') then change_scene_with_transition('menu') end
	if pressed('c') then @.grid:fill(0) end

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
		@.grid:set(@.current_cell_pos[1], @.current_cell_pos[2], 0)
	end
end

function Editor_scene:draw_inside_camera_fg()
	lg.setLineWidth(2)

	@.grid:foreach(fn(grid, i, j, value)
		if   value == 0 then
			lg.setColor(.2, .2, .2)
			lg.rectangle('line', i * @.cell_size, j * @.cell_size, @.cell_size, @.cell_size)
	
		elif value == 'w' then
			lg.setColor(.5, .5, .5)
			lg.rectangle('fill', i * @.cell_size, j * @.cell_size, @.cell_size, @.cell_size)

		elif value == 'u' then
			lg.setColor(1, 0, 0)
			lg.rectangle('line', i * @.cell_size, j * @.cell_size, @.cell_size, @.cell_size)

		elif value == 'p' then
			lg.setColor(1, 1, 0)
			lg.rectangle('fill', i * @.cell_size, j * @.cell_size, @.cell_size, @.cell_size)

		elif value == 'b' then
			lg.setColor(.6, .8, .5)
			lg.rectangle('fill', i * @.cell_size, j * @.cell_size, @.cell_size, @.cell_size)
		end
	end)

	if !@.grid:is_oob(@.current_cell_pos) then
		lg.setColor(1, 1, 1)
		lg.rectangle('line', @.current_cell_pos[1] * @.cell_size, @.current_cell_pos[2] * @.cell_size, @.cell_size, @.cell_size)
	end

	lg.setColor(1, 1, 1)
	lg.setLineWidth(1)
end

function Editor_scene:mousemoved(x, y, dx, dy)
	if down('m_3') then 
		@.camera:move(-dx, -dy)
	end
end