local function lerp(a, b, x, dt) 
	return a + (b - a) * (1.0 - math.exp(-x * dt)) 
end

local function random(x) 
	return love.math.noise(love.math.random()) - 0.5 
end

Camera = Class:extend('Camera')

function Camera:new(x, y, w, h, s)
	@.x = x or 0
	@.y = y or 0
	@.w = w or lg.getWidth()
	@.h = h or lg.getHeight()
	@.cam = { x = 0, y = 0, s = s or 1, target_x = 0, target_y = 0, target_s = s or 1, sv = 10, ssv = 10 }
	@.shk = { tick = 1/60, trigger = 0, s = 0, xrs = 0, yrs = 0}
end

function Camera:update(dt)
	@.cam.x = lerp(@.cam.x, @.cam.target_x, @.cam.sv, dt)
	@.cam.y = lerp(@.cam.y, @.cam.target_y, @.cam.sv, dt)
	@.cam.s = lerp(@.cam.s, @.cam.target_s, @.cam.ssv, dt)

	@.shk.trigger = @.shk.trigger + dt
	if @.shk.trigger > @.shk.tick then 
		if @.shk.s ~= 0 then @.shk.xrs, @.shk.yrs = random()*@.shk.s, random()*@.shk.s else @.shk.xrs, @.shk.yrs = 0, 0 end
		@.shk.trigger = @.shk.trigger - @.shk.tick
	end
	if math.abs(@.shk.s) > 5 then @.shk.s = lerp(@.shk.s, 0, 5, dt) else if @.shk.s ~= 0 then @.shk.s = 0 end end
end

function Camera:draw(func)
	lg.push()
	lg.translate(@.x + @.w/2, @.y + @.h/2)
	lg.scale(@.cam.s)
	lg.translate(-@.cam.x + @.shk.xrs, -@.cam.y + @.shk.yrs)
	func()
	lg.pop()
end

function Camera:follow(x, y)
	if type(x) == 'table' then
		if x.x then 
			x, y = x.x, x.y
		else
			x, y = x[1], x[2]
		end
	end

	@.cam.target_x = x or @.cam.target_x
	@.cam.target_y = y or @.cam.target_y
end

function Camera:move(x, y)
	if type(x) == 'table' then
		if x.x then 
			x, y = x.x, x.y
		else
			x, y = x[1], x[2]
		end
	end

	@.cam.target_x = @.cam.target_x + x or 0
	@.cam.target_y = @.cam.target_y + y or 0
end

function Camera:zoom(s) 
	@.cam.target_s = s 
end

function Camera:shake(s) 
	@.shk.s = s or 0
end

function Camera:get_position() 
	return @.cam.x, @.cam.y, @.cam.target_x, @.cam.target_y 
end

function Camera:get_zoom() 
	return @.cam.s, @.cam.target_s 
end

function Camera:set_lerpness(sv) 
	@.cam.sv = sv 
end

function Camera:set_zoomlerpness(sv) 
	@.cam.ssv = ssv 
end

function Camera:set_zoom(s) 
	@.cam.s, @.cam.target_s = s, s 
end

function Camera:set_position(x, y) 
	@.cam.x, @.cam.target_x = x or @.cam.x, x or @.cam.target_x
	@.cam.y, @.cam.target_y = y or @.cam.y, y or @.cam.target_y
end

function Camera:cam_to_screen(x, y)
	x, y = x - @.cam.x, y - @.cam.y
	x, y = x * @.cam.s, y * @.cam.s
	x, y = x + @.w / 2 + @.x, y + @.h / 2 + @.y
	return x, y
end

function Camera:screen_to_cam(x, y)
	x, y = x - @.w / 2 - @.x, y - @.h / 2 - @.y
	x, y = x / @.cam.s, y / @.cam.s
	x, y = x + @.cam.x, y + @.cam.y
	return x, y
end

function Camera:get_mouse_position() return
	@:screen_to_cam(love.mouse.getPosition()) 
end
