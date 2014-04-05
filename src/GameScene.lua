love.filesystem.load("Scene.lua")()
love.filesystem.load("Player.lua")()

GameScene = Scene:extend({
})

local fuelColor = {r = 50, g = 255, b = 50, a = 255}
local scoreColor = {r = 255, g = 255, b = 50, a = 255}
local timedTextTime = 0.4

local player = 0
local gameOver = false
local paused = true

local comboTimerMax = 4.3
local comboTimer = comboTimerMax
local comboCounter = 0

local theDot = {
	x = 0,
	y = 0,
	r = 0,
	
	rMin = 3,
	rMax = 20,
	rScaler = 500,
	
	fuelBonus = 30
}

function theDot:randomLocation()
	self.x = math.random() * width
	self.y = (math.random() * (height - (15 + self.r))) + self.r
end

function theDot:scaleSizeToScore(s)
	local rOffset = self.rMax - self.rMin
	
	self.r = ((rOffset * self.rScaler) / (s + self.rScaler)) + self.rMin
end

local function startGame()
	score = 0
	gameOver = false
	paused = true

	comboTimerMax = 4.3
	comboTimer = comboTimerMax
	comboCounter = 0
	
	theDot:randomLocation()
	
	theDot.r = 0
	
	player = Player:new()
end

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

function GameScene:enter()	
	startGame()
end

function GameScene:update(dt)
	if paused or gameOver then return end
	
	self.timedText:update(dt)
	player:update(dt)
	
	score = score + dt
	comboTimer = comboTimer - dt

	if player:collidesWith(theDot) then
		comboTimer = comboTimerMax
		comboCounter = comboCounter + 1
		
		player:addFuel(theDot.fuelBonus + comboCounter)
		sceneManager.currentScene:setFuelGained("+" .. (theDot.fuelBonus + comboCounter), player.x + 10, player.y)
		
		score = score + (5 * comboCounter)
		sceneManager.currentScene:setScoreGained("+" .. (5 * comboCounter), player.x + 10, player.y + 15)

		theDot:randomLocation()
	end

	theDot:scaleSizeToScore(score)

	if math.ceil(comboTimer) <= 0 then
		comboCounter = 0
		comboTimer = comboTimerMax
		theDot:randomLocation()
	end

	if math.ceil(player.fuel) == 0 then
		gameOver = true
	end	
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
	love.graphics.printf("Fuel: " .. math.abs(math.ceil(player.fuel)), 0, 10, width, "center")

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

function GameScene:keyPressed(key, repeats)
	if gameOver and key == " " then
		startGame()
		return
	end
	
	if key == "up" then
		player.yBurn = player.yBurn - 1
	elseif key == "down" then
		player.yBurn = player.yBurn + 1
	elseif key == "left" then
		player.xBurn = player.xBurn - 1
	elseif key == "right" then
		player.xBurn = player.xBurn + 1
	elseif key == " " then
		paused = not paused
	end
end

function GameScene:keyReleased(key)	
	if gameOver then return end
	
	if key == "up" then
		player.yBurn = player.yBurn + 1
	elseif key == "down" then
		player.yBurn = player.yBurn - 1
	elseif key == "left" then
		player.xBurn = player.xBurn + 1
	elseif key == "right" then
		player.xBurn = player.xBurn - 1
	end

	if key == "1" then
		player.throttle = 1
	elseif key == "2" then
		player.throttle = 2
	elseif key == "3" then
		player.throttle = 3
	elseif key == "4" then
		player.throttle = 4
	elseif key == "5" then
		player.throttle = 5
	elseif key == "6" then
		player.throttle = 6
	elseif key == "7" then
		player.throttle = 7
	elseif key == "8" then
		player.throttle = 8
	elseif key == "9" then
		player.throttle = 9
	elseif key == "0" then
		player.throttle = 10
	end
end
