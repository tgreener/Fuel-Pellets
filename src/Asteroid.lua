
love.filesystem.load("SpaceObject.lua")()

Asteroid = SpaceObject:extend({
	mass = 50000,
	resourceDensity = 2,
	resourceCount = 500
})

function Asteroid:randomLocation()
	self.x = math.random() * width
	self.y = (math.random() * (height - (15 + self.r))) + self.r
end

function Asteroid:randomVelocity()
	self.vx = math.random() * 20
	self.vy = math.random() * 20
end

