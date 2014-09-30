love.filesystem.load("CollisionMath.lua")()
love.filesystem.load("Object.lua")()
love.filesystem.load("CollisionMath.lua")()

SpaceObject = Object:extend({
	x = 0,
	y = 0,
	r = 0,
	
	rMin = 3,
	rMax = 20,
	rScaler = 500,
	
	fuelBonus = 30,
	
	mass = 500
})

function SpaceObject:randomLocation()
	self.x = math.random() * width
	self.y = (math.random() * (height - (15 + self.r))) + self.r
end

function SpaceObject:scaleSizeToScore(s)
	local rOffset = self.rMax - self.rMin
	self.r = ((rOffset * self.rScaler) / (s + self.rScaler)) + self.rMin
end

function SpaceObject:applyGravitation(otherObject)
	local distanceSqrd = dist2({x = otherObject.x, y = otherObject.y}, {x = self.x, y = self.y})
	local x, y = otherObject.x, otherObject.y
	
	local vx = self.x - x
	local vy = self.y - y
	
	local vecLength = vector2Length(vx, vy)
	
	local vxNorm = vx / vecLength
	local vyNorm = vy / vecLength
	
	local gravConst = 1000
	local otherMass = otherObject.mass
	local thisMass = self.mass
	
	local gravForce = gravConst * ((otherMass * thisMass) / distanceSqrd)
	
	local thisAccelerationVector = {
		ax = (gravForce / thisMass) * vxNorm * -1,
		ay = (gravForce / thisMass) * vyNorm * -1
	}
	
	local otherAccelerationVector = {
		ax = (gravForce / otherMass) * vxNorm,
		ay = (gravForce / otherMass) * vyNorm
	}
	
	
	otherObject:addVector(otherAccelerationVector.ax, otherAccelerationVector.ay);
	
end
