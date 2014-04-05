love.filesystem.load("Scene.lua")()

GameScene = Scene:extend({
})

local fuelColor = {r = 50, g = 255, b = 50, a = 255}
local scoreColor = {r = 255, g = 255, b = 50, a = 255}
local timedTextTime = 0.4

local function drawThrottle()
	local throttleBot = height / 4
	local throttleHeight = 30
	local throttleSteps = 10
	
	love.graphics.setColor(255, 50, 50, 255)
	love.graphics.rectangle("fill", 12, throttleBot, 8, (throttleHeight - throttleBot) * (player.throttle / throttleSteps))

	love.graphics.setColor(255, 255, 255, 255)	
	for i = 0, throttleSteps, 1 do
		love.graphics.rectangle("fill", 10, throttleBot - i * ((throttleBot - throttleHeight) / throttleSteps), 12, 1)
	end
end

function GameScene:setFuelGained(text, x, y)
	self:addTimedText(text, x, y, timedTextTime, fuelColor)
end

function GameScene:setScoreGained(text, x, y)
	self:addTimedText(text, x, y, timedTextTime, scoreColor)
end

function GameScene:draw()
	self.timedText:printAll()
	
	local r, g, b, a = love.graphics.getColor()
	local l = player.sideLength
	local halfL = player.sideLength / 2
	love.graphics.rectangle("fill", player.x - halfL, player.y - halfL, l, l)
	love.graphics.circle("fill", theDot.x, theDot.y, theDot.r, 15)
	drawThrottle()

	love.graphics.setColor(scoreColor.r, scoreColor.g, scoreColor.b, scoreColor.a)
	love.graphics.printf("Score: " .. math.floor(score), 0, 10, width, "right")

	love.graphics.setColor(fuelColor.r, fuelColor.g, fuelColor.b, fuelColor.a)
	love.graphics.printf("Fuel: " .. math.ceil(player.fuel), 0, 10, width, "center")

	love.graphics.setColor(r, g, b, a)
	love.graphics.print("Combo: " .. comboCounter, 10, 10)

	love.graphics.rectangle("fill", 10, height - 15, (width - 10) * (comboTimer / comboTimerMax), 10)

	if paused then
		love.graphics.printf("Paused\nPress space to continue", 0, (height / 2) - 50, width, "center")
	end

	if gameOver then
		love.graphics.printf("Game Over\nPress space to restart", 0, (height / 2) - 50, width, "center")
	end
end
