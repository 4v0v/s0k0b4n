
local _t = {
	out     = fn(f) return fn(x, ...) return 1 - f(1-x, ...) end end,
	chain   = fn(f1, f2) return fn(x, ...) return (x < 0.5 and f1(2*x, ...) or 1 + f2(2*x-1, ...))*0.5 end end,
	linear  = fn(x) return x end,
	quad    = fn(x) return x*x end,
	cubic   = fn(x) return x*x*x end,
	quart   = fn(x) return x*x*x*x end,
	quint   = fn(x) return x*x*x*x*x end,
	sine    = fn(x) return 1-math.cos(x*math.pi/2) end,
	expo    = fn(x) return 2^(10*(x-1)) end,
	circ    = fn(x) return 1-math.sqrt(1-x*x) end,
	back    = fn(x, b) b = b or 1.70158; return x*x*((b+1)*x - b) end, --bounciness
	bounce  = fn(x) local a, b = 7.5625, 1/2.75; return math.min(a*x^2, a*(x-1.5*b)^2 + 0.75, a*(x-2.25*b)^2 + 0.9375, a*(x-2.625*b)^2 + 0.984375) end,
	elastic = fn(x, a, p) a, p = a and math.max(1, a) or 1, p or 0.3; return (-a*math.sin(2*math.pi/p*(x-1) - math.asin(1/a)))*2^(10*(x-1)) end -- amp, period
}

local function _random_time(time) 
	if type(time) == 'table' then return time[1] + love.math.random() * (time[2] - time[1]) 
	else return time end 
end

local function _tween(f, ...)
	if   f:find('linear')    then return _t.linear(...)
	elif f:find('in%-out%-') then return _t.chain(_t[f:sub(8, -1)], _t.out(_t[f:sub(8, -1)]))(...) 
	elif f:find('in%-')      then return _t[f:sub(4, -1)](...)
	elif f:find('out%-')     then return _t.out(_t[f:sub(5, -1)])(...) end
end

local function _calc_tween(subject, target, out)
	for k, v in pairs(target) do
		if type(v) == 'table' then _calc_tween(subject[k], v, out)
		else local ok, delta = pcall(function() return (v - subject[k])*1 end); out[#out+1] = {subject, k, delta} end
	end
	return out
end

Trigger = Class:extend('Trigger')

function Trigger:new()
	@.triggers = {}
end

function Trigger:update(dt)
  for tag, v in pairs(@.triggers) do
		if not v.active then goto continue end
		v.t = v.t + dt

		if v.type == 'after' then 
			if v.t >= v.total then 
				v.action()
				@:remove(tag)
			end

		elseif v.type == 'after_true' then
			if v.cond() then 
				v.action()
				@:remove(tag) 
			end

		elseif v.type == 'every_true' then
			if v.cond() and v.can_do_action  then 
				v.can_do_action = false
				v.action()
				v.c = v.c + 1
				if v.c == v.count then 
					v.after()
					@:remove(tag)
				end
			elseif not v.cond() and not v.can_do_action then
				v.can_do_action = true
			end

		elseif v.type == 'during_true' then
			if v.cond() then 
				if v.can_do_action then v.can_do_action = false end
				v.action()
			elseif not v.cond() and not v.can_do_action then
				v.after()
				@:remove(tag)
			end

		elseif v.type == 'during' then
			v.action()
			if v.t >= v.total then 
				v.after()
				@:remove(tag) 
			end

		elseif v.type == 'every' then  
			if v.t >= v.total then
				v.action()
				v.c = v.c + 1
				v.t = v.t - v.total
				v.total = _random_time(v.initial_time)
				if v.c == v.count then 
					v.after()
					@:remove(tag)
				end
			end

		elseif v.type == 'tween' then
			local s  = _tween(v.method, math.min(1, v.t/v.total))
			local ds = s - v.last_s
			v.last_s = s
			for _, info in ipairs(v.payload) do 
				local ref, key, delta = unpack(info)
				ref[key] = ref[key] + delta * ds 
			end
			if v.t >= v.total then 
				for _, info in ipairs(v.payload) do 
					local ref, key, _ = unpack(info)
					ref[key] = v.target[key] 
				end
				v.after()
				@:remove(tag)
			end
		end
		
		::continue::
	end
end

function Trigger:after(time, action, tag)
	local tag = tag or uid()
	if @.triggers[tag] then return false end
	@.triggers[tag] = {
		type   = 'after', 
		active = true,
		t      = 0, 
		total  = _random_time(time), 
		action = action,
	}
	return @.triggers[tag]
end

function Trigger:every_immediate(time, action, count, tag, after)
	local tag = tag or uid()
	if @.triggers[tag] then return false end
	local total = _random_time(time)
	@.triggers[tag] = {
		type      = 'every', 
		active    = true,
		total     = total, 
		initial_time = time, 
		t         = total,
		count     = count or -1, 
		c         = 0, 
		action    = action, 
		after     = after or function() end,
	}
	return @.triggers[tag]
end

function Trigger:every(time, action, count, tag, after)
	local tag = tag or uid()
	if @.triggers[tag] then return false end
	@.triggers[tag] = {
		type      = 'every', 
		active    = true,
		total     = _random_time(time), 
		initial_time = time, 
		t         = 0, 
		count     = count or -1, 
		c         = 0, 
		action    = action, 
		after     = after or function() end,
	}
	return @.triggers[tag]
end

function Trigger:during(time, action, tag, after)
	local tag = tag or uid()
  if @.triggers[tag] then return false end
	@.triggers[tag] = {
		type    = 'during', 
		active  = true,
		t       = 0,
		total   = _random_time(time), 
		action  = action, 
		after   = after or function() end,
	}
	return @.triggers[tag]
end

function Trigger:tween(time, subject, target, method, tag, after)
	local tag = tag or uid()
	if @.triggers[tag] then return false end
	@.triggers[tag] = { 
		type    = 'tween', 
		active  = true,
		t       = 0,
		total   = _random_time(time), 
		subject = subject, 
		target  = target, 
		method  = method, 
		last_s  = 0, 
		payload = _calc_tween(subject, target, {}),
		after   = after or function() end, 
	}
	return @.triggers[tag]
end

function Trigger:after_true(cond, action, tag)
	local tag = tag or uid()
	if @.triggers[tag] then return false end
	@.triggers[tag] = { 
		type   = 'after_true',
		t      = 0,
		active = true,
		cond   = cond,
		action = action,
	}
end

function Trigger:every_true(cond, action, count, tag, after)
	local tag = tag or uid()
	if @.triggers[tag] then return false end
	@.triggers[tag] = { 
		type   = 'every_true',
		t      = 0,
		active = true,
		count  = count or -1,
		c      = 0,
		can_do_action = true,
		cond   = cond,
		action = action,
		after  = after or function() end
	}
end

function Trigger:during_true(cond, action, tag, after)
	local tag = tag or uid()
	if @.triggers[tag] then return false end
	@.triggers[tag] = { 
		type   = 'during_true',
		t      = 0,
		active = true,
		can_do_action = true,
		cond   = cond,
		action = action,
		after  = after
	}
end

function Trigger:once(action, tag)
	return @:every_immediate(math.huge, action, _, tag) 
end

function Trigger:always(action, tag)
	return @:during(math.huge, action, tag) 
end

function Trigger:get(tag) 
	return @.triggers[tag] 
end

function Trigger:pause(tag) 
	@.triggers[tag].active = false
end

function Trigger:play(tag) 
	@.triggers[tag].active = true 
end

function Trigger:remove(tag)
	local result = not not @.triggers[tag]
	@.triggers[tag] = nil
	return result
end

function Trigger:destroy() 
	@.triggers = {} 
end
