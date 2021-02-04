Menu_scene = Scene:extend('Menu_scene')

function Menu_scene:new(id)
	Menu_scene.super.new(@, id)

	@:add('play_btn', Text(lg.getWidth()/2, lg.getHeight()/2 - 50, "Play \x21", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)

	@:add('editor_btn', Text(lg.getWidth()/2, lg.getHeight()/2, "Editor", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)
	
	@:add('quit_btn', Text(lg.getWidth()/2, lg.getHeight()/2 + 50, "Quit :(", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)
end

function Menu_scene:update(dt)
	Menu_scene.super.update(@, dt)

	if pressed('escape') then love.event.quit() end

	local play_btn = @:get('play_btn')
	local editor_btn = @:get('editor_btn')
	local quit_btn = @:get('quit_btn')

	if point_rect_collision({lm:getX(), lm:getY()}, play_btn:aabb()) then
		@:once(fn() play_btn.scale_spring:change(1.5) end, 'is_inside_play')
		if pressed('m_1') then change_scene_with_transition('play') end
	else 
		if @.trigger:remove('is_inside_play') then play_btn.scale_spring:change(1) end
	end

	if point_rect_collision({lm:getX(), lm:getY()}, editor_btn:aabb()) then
		@:once(fn() editor_btn.scale_spring:change(1.5) end, 'is_inside_editor')
		if pressed('m_1') then change_scene_with_transition('editor') end
	else 
		if @.trigger:remove('is_inside_editor') then editor_btn.scale_spring:change(1) end
	end

	if point_rect_collision({lm:getX(), lm:getY()}, quit_btn:aabb()) then
		@:once(fn() quit_btn.scale_spring:change(1.5) end, 'is_inside_quit')
		if pressed('m_1') then love.event.quit() end
	else 
		if @.trigger:remove('is_inside_quit') then quit_btn.scale_spring:change(1) end
	end
end
