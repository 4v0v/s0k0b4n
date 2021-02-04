Entity = Class:extend('Entity')

function Entity:new(opts)
	@.trigger = Trigger()
	@.dead    = false
	@.scene   = {}
	@.id      = ''
	@.types   = get(opts, 'types', {})
	@.pos     = Vec2(get(opts, 'x', 0), get(opts, 'y', 0))
	@.dir     = Vec2(0, 1)
	@.z       = get(opts, 'z', 0)
	@.state   = get(opts, 'state', 'default')
	@.outside_camera = get(opts, 'outside_camera', false)
end

function Entity:draw() 
end

function Entity:update(dt) 
	@.trigger:update(dt) 
end

function Entity:is_type(...) 
	local types = {...}

	ifor type in types do
		ifor entity_type in @.types do 
			if type == entity_type then return true end
		end
	end

	return false
end

function Entity:kill()
	@.trigger:destroy()
	@.dead  = true
	@.scene = nil
end

function Entity:set_state(state)
	@.state = state
end

function Entity:is_state(...)
	ifor {...} do
		if @.state == it then return true end
	end
	return false
end

function Entity:get_state()
	return @.state
end

function Entity:after(...)
	@.trigger:after(...)
end

function Entity:tween(...)
	@.trigger:tween(...)
end

function Entity:every(...)
	@.trigger:every(...)
end

function Entity:after_true(...)
	@.trigger:after_true(...)
end

function Entity:every_true(...)
	@.trigger:every_true(...)
end

function Entity:during_true(...)
	@.trigger:during_true(...)
end

function Entity:every_immediate(...)
	@.trigger:every_immediate(...)
end

function Entity:during(...)
	@.trigger:during(...)
end

function Entity:once(...)
	@.trigger:once(...)
end

function Entity:always(...)
	@.trigger:always(...)
end

function Entity:lerp_to(target, speed)
	self.pos = self.pos:lerp(Vec2(target), speed)
end

function Entity:move_to(target)
	self.pos = Vec2(target)
end
