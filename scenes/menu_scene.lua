Menu_scene = Scene:extend('Menu_scene')

function Menu_scene:new(id)
	Menu_scene.super.new(@, id)


	@:add('play_btn', Text(lg.getWidth()/2, lg.getHeight()/2 - 25, "Play \x21", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)
	
	@:add('quit_btn', Text(lg.getWidth()/2, lg.getHeight()/2 + 25, "Quit :(", 
		{
			font           = lg.newFont('assets/fonts/fixedsystem.ttf', 32),
			centered       = true,
			outside_camera = true,
		})
	)

	@.x = Lerpable(0)
	@.y = Lerpable(0)
end

function Menu_scene:update(dt)
	Menu_scene.super.update(@, dt)
	@.x:update(dt)
	@.y:update(dt)

	@.x:lerp(lm.getX())
	@.y:lerp(lm.getY())

	if pressed('escape') then love.event.quit() end

	local play_btn = @:get('play_btn')
	local quit_btn = @:get('quit_btn')

	if point_rect_collision({lm:getX(), lm:getY()}, play_btn:aabb()) then
		@:once(fn() play_btn.scale_spring:change(1.5) end, 'is_inside_play')
		if pressed('m_1') then game:change_scene_with_transition('play') end
	else 
		if @.timer:remove('is_inside_play') then play_btn.scale_spring:change(1) end
	end

	if point_rect_collision({lm:getX(), lm:getY()}, quit_btn:aabb()) then
		@:once(fn() quit_btn.scale_spring:change(1.5) end, 'is_inside_quit')
		if pressed('m_1') then love.event.quit() end
	else 
		if @.timer:remove('is_inside_quit') then quit_btn.scale_spring:change(1) end
	end
end


function Menu_scene:draw_outside_camera_fg()
	lg.line(0, 0, @.x:value(), @.y:value())
end