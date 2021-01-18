Play_room = Room:extend('Play_room')

function Play_room:new(id)
	Play_room.super.new(@, id)

	@.earth      = g3d.Model("assets/obj/sphere.obj", "assets/images/earth.png",     {0,0,4}, nil, {-1,1,1})
	@.moon       = g3d.Model("assets/obj/sphere.obj", "assets/images/moon.png",      {5,0,4}, nil, {-0.5,0.5,0.5})
	@.bg = g3d.Model("assets/obj/sphere.obj", "assets/images/starfield.png", {0,0,0}, nil, {500,500,500})

	@.Canvas = lg.newCanvas()
end

function Play_room:enter()
	love.mouse.setRelativeMode(true)
end

function Play_room:update(dt)
	Play_room.super.update(@, dt)

	-- @.moon:setTranslation(math.cos(Timer)*5, 0, math.sin(Timer)*5 +4)
	-- @.moon:setRotation(0,-1*Timer,0)
	if down('q')      then g3d.Camera:firstPersonMovement(dt, "left")     end
	if down('d')      then g3d.Camera:firstPersonMovement(dt, "right")    end
	if down('lshift') then g3d.Camera:firstPersonMovement(dt, "up")       end
	if down('lctrl')  then g3d.Camera:firstPersonMovement(dt, "down")     end
	if down('z')      then g3d.Camera:firstPersonMovement(dt, "forward")  end
	if down('s')      then g3d.Camera:firstPersonMovement(dt, "backward") end
end

function Play_room:draw_outside_camera_fg()
	lg.setCanvas({@.Canvas, depth=true})
	lg.clear()
	@.earth:draw()
	@.moon:draw()
	@.bg:draw()
	lg.setCanvas()

	lg.draw(@.Canvas, 0, 0)
end

function Play_room:mousemoved(x,y, dx,dy)
	g3d.Camera:firstPersonLook(dx,dy)
end
