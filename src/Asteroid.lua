
love.filesystem.load("SpaceObject.lua")()

Asteroid = SpaceObject:extend({
	resourceDensity = 1
})

function Asteroid:randomLocation()
	self.x = math.random() * width
	self.y = (math.random() * (height - (15 + self.r))) + self.r
end

