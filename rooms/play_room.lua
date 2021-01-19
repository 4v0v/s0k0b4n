Play_room = Room:extend('Play_room')

function Play_room:new(id)
	Play_room.super.new(@, id)

	@.earth  = g3d.Model('assets/obj/sphere.obj', 'assets/images/earth.png' , {0, 0, 4}, _, { 1,  1,  1})
	@.moon   = g3d.Model('assets/obj/sphere.obj', 'assets/images/moon.png'  , {5, 0, 4}, _, {.5, .5, .5})
	@.cube   = g3d.Model('assets/obj/cube.obj'  , _                         , {4, 0, 0}, _, {.5, .5, .5})
	@.cube2  = g3d.Model('assets/obj/cube.obj'  , _                         , {5, 0, 0}, _, {.5, .5, .5})
	@.cube3  = g3d.Model('assets/obj/cube.obj'  , _                         , {6, 0, 0}, _, {.5, .5, .5})
	@.canvas = lg.newCanvas()

	@.t = 0

	@.pos = 1
	@:every_immediate(2, fn() 
		@:tween(1, @, {pos = 4}, 'in-out-cubic', _ , fn() 
			@:tween(1, @, {pos = 1}, 'in-out-cubic')
		end)
	end)

end

function Play_room:enter()
	love.mouse.setRelativeMode(true)
end

function Play_room:update(dt)
	Play_room.super.update(@, dt)

	if down('q')      then g3d.Camera:firstPersonMovement(dt, 'left')     end
	if down('d')      then g3d.Camera:firstPersonMovement(dt, 'right')    end
	if down('lshift') || down('space') then g3d.Camera:firstPersonMovement(dt, 'up')       end
	if down('lctrl')  then g3d.Camera:firstPersonMovement(dt, 'down')     end
	if down('z')      then g3d.Camera:firstPersonMovement(dt, 'forward')  end
	if down('s')      then g3d.Camera:firstPersonMovement(dt, 'backward') end

	if pressed('left') then @.cube:translateX(1) end

	@.t += dt
	@.moon:setTranslation(math.cos(@.t)*5, 0, math.sin(@.t)*5 +4)
	@.moon:setYRotation(-1*@.t)

	@.cube:setYTranslation(@.pos)
end

function Play_room:draw_outside_camera_fg()
	lg.setCanvas({@.canvas, depth=true})
	lg.clear()
		@.earth:draw()
		@.moon:draw()

		lg.setColor(1, 0, 0)
		@.cube:draw()

		lg.setColor(0, 1, 1)
		@.cube2:draw()

		lg.setColor(0, 1, 0)
		@.cube3:draw()

		lg.setColor(1, 1, 1)
	lg.setCanvas()

	lg.draw(@.canvas, 0, 0)
end

function Play_room:mousemoved(x,y, dx,dy)
	g3d.Camera:firstPersonLook(dx,dy)
end
