Play_scene = Scene:extend('Play_scene')

function Play_scene:new(id)
	Play_scene.super.new(@, id)

	@:add('rect', Rectangle(0, 0, 100, 100, {type='line'}))

end

function Play_scene:update(dt)
	Play_scene.super.update(@, dt)

	if pressed('escape') then game:change_scene_with_transition('menu') end

end
