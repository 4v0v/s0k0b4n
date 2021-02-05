Editor_scene = Scene:extend('Editor_scene')

function Editor_scene:new(id)
	Editor_scene.super.new(@, id)

	@.grid = Grid(30, 20)


	@.current_cell_pos = {0, 0}


	@.camera:set_position(400, 300)
	@:zoom(1)
end

function Editor_scene:update(dt)
	Editor_scene.super.update(@, dt)

	if pressed('escape') then change_scene_with_transition('menu') end

	local mouse_pos = @:get_mouse_position_inside_camera()

	@.current_cell_pos[1] = math.floor(mouse_pos[1] / 25)
	@.current_cell_pos[2] = math.floor(mouse_pos[2] / 25)


	if down('m_1') && !@.grid:is_oob(@.current_cell_pos[1], @.current_cell_pos[2]) then 
		@.grid:set(@.current_cell_pos[1], @.current_cell_pos[2], 1)
	end

	if down('m_2') && !@.grid:is_oob(@.current_cell_pos[1], @.current_cell_pos[2]) then 
		@.grid:set(@.current_cell_pos[1], @.current_cell_pos[2], 0)
	end
end

function Editor_scene:draw_inside_camera_fg()
	lg.setLineWidth(2)

	@.grid:foreach(fn(grid, i, j, value)

		if   value == 0 then
			lg.setColor(.5, .5, .5)
			lg.rectangle('line', i * 25, j * 25, 25, 25)
	
		elif value == 1 then
		lg.setColor(1, 1, 1)
			lg.rectangle('fill', i * 25, j * 25, 25, 25)
		end

		if i == @.current_cell_pos[1] && j == @.current_cell_pos[2] then
			lg.setColor(1, 1, 0)
			lg.rectangle('fill', i * 25, j * 25, 25, 25)
			lg.setColor(.5, .5, .5)
		end
	end)

	lg.setColor(1, 1, 1)
	lg.setLineWidth(1)
end