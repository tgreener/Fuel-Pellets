
love.filesystem.load("Object.lua")()

Laser = Object:extend({
	range = 100,
	firing = false,
	target = nil
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

