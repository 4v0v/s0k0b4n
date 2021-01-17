Play_room = Room:extend('Play_room')

function Play_room:new(id)
	Play_room.super.new(@, id)

	@:add('r1', Rectangle(0, 0, 100, 100, { mode = 'line', lw = 3, centered = true, color = cmyk(1, 0, 0, 0)}))
	@:add('r2', Rectangle(200, 200, 100, 100, {z = -1, mode = 'line', lw = 3, centered = true, color = cmyk(0, 1, 0, 0)}))
	@:add('r3', Rectangle(200, 200, 100, 100, {z = -1, mode = 'line', lw = 3, centered = true, color = cmyk(0, 0, 1, 0)}))
end

function Play_room:update(dt)
	Play_room.super.update(@, dt)

	local mouse_pos = @:get_mouse_position_inside_camera()
	local r1 = @:get('r1')
	local r2 = @:get('r2')
	local r3 = @:get('r3')

	r1:lerp_to(mouse_pos, 10*dt)
	r2:lerp_to(r1.pos, 10*dt)
	r3:lerp_to(r2.pos, 10*dt)
end
