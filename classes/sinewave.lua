Sinewave = Class:extend('Sinewave')

function Sinewave:new(value, speed, amplitude)
	@.current = value     or 0
	@.v       = value     or 0
	@.speed   = speed     or 1
	@.amp     = amplitude or 1
	@.time    = 0
	@.sine    = 0
	@.playing = true
end

function Sinewave:update(dt)
	if !@.playing then return end
	@.time += dt
	@.sine     = @.amp * math.sin(@.time * @.speed)
	@.current  = @.v + @.sine
end

function Sinewave:stop()
	@.playing = false
end

function Sinewave:play()
	@.playing = true
end

function Sinewave:get() 
	return @.current
end

function Sinewave:set(value)
	@.current = value
	@.v       = value 
end
