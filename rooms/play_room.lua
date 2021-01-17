Play_room = Room:extend('Play_room')

function Play_room:new(id)
	Play_room.super.new(@, id)
end

function Play_room:update(dt)
	Play_room.super.update(@, dt)
end
