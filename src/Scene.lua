
love.filesystem.load("Object.lua")()
love.filesystem.load("TimedText.lua")()

Scene = Object:extend({
	timedText = TimedText:new()
})

function Scene:update(dt)
	self.timedText:update(dt)
end

function Scene:addTimedText(text, x, y, time, color)
	self.timedText:add(text, x, y, time, color)
end

function Scene:draw()
	self.timedText:printAll()
end

function Scene:keyPressed(key, repeats)
end

function Scene:keyReleased(key)	
end

function Scene:enter()
end
