Editor_scene = Scene:extend('Editor_scene')

function Editor_scene:new(id)
	Editor_scene.super.new(@, id)

end

function Editor_scene:update(dt)
	Editor_scene.super.update(@, dt)

	if pressed('escape') then change_scene_with_transition('menu') end


end
