love.filesystem.load("collisionMath.lua")()

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

previousObj = {}

snakeObj = {
	x = width / 2,
	y = height / 2,
	
	vx = 0, 
	vy = 0,
	maxV = 750,
	ax = 0, 
	ay = 0,
	
	thrust = 30,
	throttle = 5,
	sideLength = 10,
	
	fuel = 400,
	xBurn = 0,
	yBurn = 0,
	burnRate = 1,
	depletionRate = 5
}
	
function snakeObj:new()
	local obj = {}
	setmetatable(obj, {__index = self})
	__index = self
		
	return obj
end

function snakeObj:updatePhys(dt)
	self.ax = self.xBurn * (self.thrust * self.throttle)
	self.ay = self.yBurn * (self.thrust * self.throttle)
	
	self:depleteFuel(dt)
	
	if self.xBurn ~= 0 then
		self:burnFuel(dt)
	end
	
	if self.yBurn ~= 0 then
		self:burnFuel(dt)
	end
	
	self.vx = self.vx + (self.ax * dt)
	self.vy = self.vy + (self.ay * dt)
	
	if self.vx > self.maxV then
		self.vx = self.maxV
	end
	
	if self.vy > self.maxV then
		self.vy = self.maxV
	end
	
	self.x = (self.x + (self.vx * dt)) % width
	self.y = (self.y + (self.vy * dt)) % height
end

function snakeObj:update(dt)
	previousObj = deepcopy(self)
	self:updatePhys(dt)
end

function snakeObj:burnFuel(dt)
	self.fuel = self.fuel - ((self.burnRate * self.throttle) * dt)
end

function snakeObj:depleteFuel(dt)
	self.fuel = self.fuel - (self.depletionRate * dt)
end

function snakeObj:addFuel(amount)
	self.fuel = self.fuel + amount
end

function snakeObj:collidesWith(aDot)
	local r = sqr(aDot.r)
	
	local corners = self:getCorners()
	local predictedCorners = previousObj:getCorners()
	
	local distToTop = distToSegment2(aDot, corners[0], corners[1])
	local predDistToTop = distToSegment2(aDot, predictedCorners[0], predictedCorners[1])
	
	local distToRight = distToSegment2(aDot, corners[2], corners[1])
	local predDistToRight = distToSegment2(aDot, predictedCorners[2], predictedCorners[1])
	
	local distToBot = distToSegment2(aDot, corners[2], corners[3])
	local predDistToBot = distToSegment2(aDot, predictedCorners[2], predictedCorners[3])
	
	local distToLeft = distToSegment2(aDot, corners[0], corners[3])
	local predDistToLeft = distToSegment2(aDot, predictedCorners[0], predictedCorners[3])
	
	local topT = (r - distToTop) / (predDistToTop - distToTop)
	local rightT = (r - distToRight) / (predDistToRight - distToRight)
	local bottomT = (r - distToBot) / (predDistToBot - distToBot)
	local leftT = (r - distToLeft) / (predDistToLeft - distToLeft)
	
	local collidesTop = topT < 1 and topT > 0
	local collidesRight = rightT < 1 and rightT > 0
	local collidesBottom = bottomT < 1 and bottomT > 0
	local collidesLeft = leftT < 1 and leftT > 0
	
	return collidesTop or collidesRight or collidesBottom or collidesLeft
end

function snakeObj:getCorners()
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
