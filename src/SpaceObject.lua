love.filesystem.load("CollisionMath.lua")()
love.filesystem.load("Object.lua")()
love.filesystem.load("CollisionMath.lua")()

SpaceObject = Object:extend({
	x = 0,
	y = 0,
	
	fuelBonus = 30,
	
	mass = 0,
	
	vx = 0, 
	vy = 0,
	ax = 0, 
	ay = 0,
})



function SpaceObject:addVector(ax, ay)
	self.ax = self.ax + ax
	self.ay = self.ay + ay
end

function SpaceObject:onStartUpdate(dt)
	self.ax = 0
	self.ay = 0
end

function SpaceObject:updatePhys(dt)
	self.vx = self.vx + (self.ax * dt)
	self.vy = self.vy + (self.ay * dt)
	
	self.x = (self.x + (self.vx * dt))
	self.y = (self.y + (self.vy * dt))
end

function SpaceObject:applyGravitation(otherObject)
	local distanceSqrd = dist2({x = otherObject.x, y = otherObject.y}, {x = self.x, y = self.y})
	local vec = otherObject:getVectorTo(self)
	
	local vecxNorm = vec.x
	local vecyNorm = vec.y
	
	local gravConst = 0.1
	local otherMass = otherObject.mass
	local thisMass = self.mass
	
	local gravForce = gravConst * ((otherMass * thisMass) / distanceSqrd)

	local otherAccelerationVector = {
		ax = (gravForce / otherMass) * vecxNorm,
		ay = (gravForce / otherMass) * vecyNorm
	}
	
	otherObject:addVector(otherAccelerationVector.ax, otherAccelerationVector.ay);
	
end

function SpaceObject:getVectorTo(spaceObject)
	local vx = spaceObject.x - self.x
	local vy =  spaceObject.y - self.y
	
	local vecLength = vector2Length(vx, vy)
	
	vx = vx / vecLength
	vy = vy / vecLength
	
	return { x = vx, y = vy }
end
