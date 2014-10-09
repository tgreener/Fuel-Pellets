
love.filesystem.load("SpaceObject.lua")()
love.filesystem.load("CollisionMath.lua")()

Asteroid = SpaceObject:extend({
	r = 20,
	
	mass = 2500000,
	resourceDensity = 2,
	resourceCount = 150
})

function Asteroid:randomLocation(field, otherAsteroids)
	self.x = (math.random() * field.xMax) + field.xMin
	self.y = (math.random() * field.yMax) + field.yMin
end

function Asteroid:randomVelocity()
	self.vx = math.random() * 20
	self.vy = math.random() * 20
end

function Asteroid:collidesWithAsteroid(asteroid)
	local distanceBetweenCenters = dist2(self, asteroid)
	return distanceBetweenCenters < sqr(self.r + asteroid.r)
end

function Asteroid:collidesWithPlayer(player)
	return player:collidesWith(self)
end

function Asteroid:deflectFromAsteroid(asteroid)
	local distance = dist2(self, asteroid)
	local amountOverlap = (self.r + asteroid.r) - math.sqrt(distance)
	local deflectionDirection = self:getVectorTo(asteroid)
	
	if amountOverlap > 0 then
		asteroid.x = asteroid.x + amountOverlap * deflectionDirection.x
		asteroid.y = asteroid.y + amountOverlap * deflectionDirection.y
		
		local dt = 1 / 60 -- Assume ideal framerate
		
		local vx1 = self.vx
		local vy1 = self.vy
		
		local xDif = self.x - asteroid.x
		local yDif = self.y - asteroid.y
		
		local vx2 = asteroid.vx
		local vy2 = asteroid.vy
		
		local massCoefficient = (2 * asteroid.mass) / (self.mass + asteroid.mass)
		local scalarProductTerm = (((vx1 - vx2) * xDif) + ((vy1 - vy2) * yDif)) / distance
		
		local coefficient = massCoefficient * scalarProductTerm
		
		local vxPrime = vx1 - (coefficient * xDif)
		local vyPrime = vy1 - (coefficient * yDif)
		
		local dvx = vx1 - vxPrime
		local dvy = vy1 - vyPrime
		
		self.vx = vxPrime * 1.2
		self.vy = vyPrime * 1.2
	end
end

function Asteroid:interactWithAsteroid(asteroid)
	self:applyGravitation(asteroid)
	
	if self:collidesWithAsteroid(asteroid) then
		self:deflectFromAsteroid(asteroid)
	end
end
