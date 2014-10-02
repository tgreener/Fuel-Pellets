love.filesystem.load("CollisionMath.lua")()
love.filesystem.load("SpaceObject.lua")()
love.filesystem.load("Laser.lua")()

local previousObj = {}

local playerLaser = Laser:new()

Player = SpaceObject:extend({
	x = width / 2,
	y = height / 2,
	
	thrust = 30,
	throttle = 5,
	sideLength = 10,
	
	fuel = 400,
	xBurn = 0,
	yBurn = 0,
	burnRate = 1,
	depletionRate = 5,
	
	mass = 1,
	laser = playerLaser
})

function Player:objectIsInRange(target)
	return dist2(self, target) < sqr(self.laser.range)
end

function Player:setTarget(target)
	self.laser.target = target
end

function Player:addBurnAcceleration()
	local totalThrust = self.thrust * self.throttle
	local vecX = self.xBurn * totalThrust
	local vecY = self.yBurn * totalThrust
	
 	self:addVector(vecX, vecY)
end

function Player:burnY(yDir)
	self.yBurn = self.yBurn + yDir
end

function Player:burnX(xDir)
	self.xBurn = self.xBurn + xDir
end

function Player:fireTopThruster()
	self:burnY(1)
end

function Player:stopTopThruster()
	self:fireBottomThruster()
end

function Player:fireBottomThruster() 
	self:burnY(-1)
end

function Player:stopBottomThruster()
	self:fireTopThruster()
end

function Player:fireRightThruster()
	self:burnX(-1)
end

function Player:stopRightThruster()
	self:fireLeftThruster()
end

function Player:fireLeftThruster()
	self:burnX(1)
end

function Player:stopLeftThruster()
	self:fireRightThruster()
end

function Player:onStartUpdate(dt)
	self.ax = 0
	self.ay = 0
	
	self:burnFuel(dt)
end

function Player:onEndUpdate(dt)
	if self:objectIsInRange(self.laser.target) then
		self.laser:startFiring()
	else
		self.laser:stopFiring()
	end
end

function Player:update(dt)
	previousObj = deepcopy(self)
	self:addBurnAcceleration()
	self:updatePhys(dt)
	self.laser:update(dt)
end

function Player:burnFuel(dt)
	if self.yBurn ~= 0 or self.xBurn ~= 0 then
		self.fuel = self.fuel - ((self.burnRate * self.throttle) * dt)
	end
	
	if self.laser.firing then
		self.fuel = self.fuel - (self.laser.fuelCost * dt)
	end
end

function Player:setMiningCallback(cb)
	self.laser:setMineCycleCallback(function (fuelMined)
		self.fuel = self.fuel + fuelMined
		cb(fuelMined)
	end)
end

function Player:addFuel(amount)
	self.fuel = self.fuel + amount
end

function Player:collidesWith(asteroid)
	local r = sqr(asteroid.r)
	
	local corners = self:getCorners()
	local predictedCorners = previousObj:getCorners()
	
	local distToTop = distToSegment2(asteroid, corners[0], corners[1])
	local predDistToTop = distToSegment2(asteroid, predictedCorners[0], predictedCorners[1])
	
	local distToRight = distToSegment2(asteroid, corners[2], corners[1])
	local predDistToRight = distToSegment2(asteroid, predictedCorners[2], predictedCorners[1])
	
	local distToBot = distToSegment2(asteroid, corners[2], corners[3])
	local predDistToBot = distToSegment2(asteroid, predictedCorners[2], predictedCorners[3])
	
	local distToLeft = distToSegment2(asteroid, corners[0], corners[3])
	local predDistToLeft = distToSegment2(asteroid, predictedCorners[0], predictedCorners[3])
	
	local rightT = (r - distToRight) / (predDistToRight - distToRight)
	local bottomT = (r - distToBot) / (predDistToBot - distToBot)
	local leftT = (r - distToLeft) / (predDistToLeft - distToLeft)
	local topT  = (r - distToTop) / (predDistToTop - distToTop)
	
	local collidesTop = topT < 1 and topT > 0
	local collidesRight = rightT < 1 and rightT > 0
	local collidesBottom = bottomT < 1 and bottomT > 0
	local collidesLeft = leftT < 1 and leftT > 0
	
	return collidesTop or collidesRight or collidesBottom or collidesLeft
end

function Player:getCorners()
	local corners = {}
	corners[0] = {
		x = self.x - (self.sideLength / 2),
		y = self.y - (self.sideLength / 2)
	}
	
	corners[1] = {
		x = self.x + (self.sideLength / 2),
		y = self.y - (self.sideLength / 2)
	}
	
	corners[2] = {
		x = self.x + (self.sideLength / 2),
		y = self.y + (self.sideLength / 2)
	}
	
	corners[3] = {
		x = self.x - (self.sideLength / 2),
		y = self.y + (self.sideLength / 2)
	}
	
	return corners
end
