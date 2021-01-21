Lerpable = Class:extend('Lerpable')
Lerpable.delta = .01

function Lerpable:new(value, speed)
	@.current = value
	@.target  = value
	@.speed   = speed or 20
end

function Lerpable:update(dt)
	if @.current == @.target then return end
	@.current += (@.target - @.current) * @.speed * dt

	if @.target - Lerpable.delta < @.current && @.target + Lerpable.delta > @.current then 
		@.current = @.target
	end
end

function Lerpable:value() 
	return @.current
end

function Lerpable:val() 
	return @.current
end

function Lerpable:lerp(target)
	@.target = target
end
