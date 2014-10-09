
love.filesystem.load("Object.lua")()

Laser = Object:extend({
	range = 100,
	firing = false,
	target = nil,
	fuelCost = 1,
	miningRate = 2,
	miningCapacity = 3,
	miningTime = 0,
	mineCycleCallback = nil
})

function Laser:setTarget(targetObj)
	self.target = targetObj
end

function Laser:startFiring() 
	self.firing = true
end

function Laser:stopFiring()
	self.firing = false
end

function Laser:update(dt)
	if self.firing then
		self.miningTime = self.miningTime + dt
		
		if self.miningTime >= self.miningRate then
			self.miningTime = 0
			self.mineCycleCallback()
		end
	end
end

function Laser:setMineCycleCallback(cb)
	self.mineCycleCallback = function()
		local amountMined = 0
		if self.target.resourceCount > 0 then
			amountMined =  self.miningCapacity * self.target.resourceDensity
			self.target.resourceCount = self.target.resourceCount - amountMined
		end
		
		cb(amountMined)
	end
end

