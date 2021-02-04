AnimationFrames = Class:extend('AnimationFrames')

function AnimationFrames:new(image, frame_w, frame_h, ox, oy, frames_list)
	if type(image) == 'string' then 
		image = lg.newImage(image)
	end

	if type(frames_list) == 'string' then 
		frames_list = @:convert_frames_string(frames_list)
	end

  @.image    = image
	@.frame_w  = frame_w
	@.frame_h  = frame_h
	@.ox       = ox or 0
	@.oy       = oy or 0
	@.frames   = map(frames_list, fn(frame)
		return lg.newQuad(
			(frame[1]-1) * @.frame_w + @.ox, 
			(frame[2]-1) * @.frame_h + @.oy, 
			@.frame_w, @.frame_h, 
			@.image:getWidth(), @.image:getHeight()
		)
	end)
end

function AnimationFrames:draw(frame, x, y, r, sx, sy, ox, oy)
  lg.draw(
		@.image, 
		@.frames[frame], 
		x, y, r or 0, sx or 1, sy or sx or 1, 
		@.frame_w/2 + (ox or 0), 
		@.frame_h/2 + (oy or 0)
	)
end

function AnimationFrames:convert_frames_string(str)
	local tbl = {}

	str:gsub("([%d]+)-([%d]+)", fn(x, y) 
		insert(tbl, {tonumber(x), tonumber(y)}) 
	end)

	return tbl
end

Animation =  Class:extend('Animation')

function Animation:new(delay, frames, mode, actions)
  @.delay   = delay
  @.anim_frames  = frames
  @.size    = #frames.frames
  @.mode    = mode or 'loop'
  @.actions = actions
	@.pause   = false
  @.timer   = 0
  @.current_frame = 1
  @.dir     = 1
end

function Animation:update(dt)
	if @.pause then return end
	@.timer += dt
	
  local delay = @.delay
	if type(@.delay) == 'table' then delay = @.delay[@.current_frame] end
	
	if @.timer > delay then
		local action = get(@, {'actions', @.current_frame})

    @.current_frame += @.dir
		if @.current_frame > @.size || @.current_frame < 1 then
      if   @.mode == 'once' then
        @.current_frame = @.size
				@.pause = true

      elif @.mode == 'loop' then
				@.current_frame = 1

      elif @.mode == 'bounce' then
        @.dir = -@.dir
        @.current_frame += 2 * @.dir
			end
		end
		if action then action() end
		
		@.timer -= delay
  end
end

function Animation:draw(x, y, r, sx, sy, ox, oy)
	@.anim_frames:draw(@.current_frame, x, y, r, sx, sy, ox, oy)
end

function Animation:reset()
	@.current_frame = 1
	@.timer = 0
	@.dir   = 1
	@.pause = false
end

function Animation:set_frame(frame)
	@.current_frame = frame
	@.timer = 0
end

function Animation:set_actions(actions)
	@.actions = actions
end

function Animation:set_delay(delay)
	@.delay = delay
end

function Animation:clone()
	return Animation(@.delay, @.frames, @.mode, @.actions)
end
