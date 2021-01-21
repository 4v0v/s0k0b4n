Tweenable = Class:extend('Tweenable')

function Tweenable:new(value)
		@.val = value
		@.target = value
end

function Tweenable:update(dt)

end

function Tweenable:value() 
	return @.val
end

function Tweenable:tween(time, target, method)

end
