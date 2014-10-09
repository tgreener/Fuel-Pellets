love.filesystem.load("Scene.lua")()
love.filesystem.load("Player.lua")()
love.filesystem.load("Asteroid.lua")()

GameScene = Scene:extend({
})

local fuelColor = {r = 50, g = 255, b = 50, a = 255}
local scoreColor = {r = 255, g = 255, b = 50, a = 255}
local laserColor = {r = 255, g = 50, b = 50, a = 255}
local depletedColor = {r = 156, g = 136, b = 100, a = 255}
local timedTextTime = 0.4

local FIELD_SIZE = 10000

local asteroidField = { xMax = FIELD_SIZE, yMax = FIELD_SIZE, xMin = 0, yMin = 0 }
local numFields = 0

local player = 0
local gameOver = false
local paused = true

local burnAnimationDuration = 0.2
local burnAnimationTime = 0

local asteroids = {}
local asteroidCount = 3

local function moreAsteroids()
	asteroidField.xMax = asteroidField.xMax + (FIELD_SIZE * numFields)
	asteroidField.yMax = asteroidField.yMax + (FIELD_SIZE * numFields)
	
	asteroidField.xMin = asteroidField.xMin + (FIELD_SIZE * numFields)
	asteroidField.yMin = asteroidField.yMin + (FIELD_SIZE * numFields)
	
	local index = numFields * asteroidCount
	
	for i = index, index + asteroidCount - 1, 1 do
		asteroids[i] = Asteroid:new()
		asteroids[i]:randomLocation(asteroidField, asteroids)
		asteroids[i].tag = i
	end
	
	numFields = numFields + 1
end

local function startGame()
	numFields = 0
	asteroidField = { xMax = 1000, yMax = 1000, xMin = 0, yMin = 0 }
	asteroids = {}
	
	score = 0
	gameOver = false
	paused = true

	comboTimerMax = 4.3
	comboTimer = comboTimerMax
	comboCounter = 0
	
	moreAsteroids()
	
	player = Player:new()
	player:targetNearest(asteroids)
	player:setMiningCallback(function (fuelMined)
		GameScene:setFuelGained("+" .. fuelMined, player.x + 10, player.y - 10)
		
		local target = player.laser.target
		local needMoreAsteroids = true
		
		for i = 0, table.getn(asteroids), 1 do
			needMoreAsteroids = needMoreAsteroids and asteroids[i].resourceCount <= 0
		end
		
		if needMoreAsteroids then
			moreAsteroids()
		end
	end)
end

local function drawThrottle()
	local throttleBot = height / 4
	local throttleHeight = 10
	local throttleSteps = 10
	
	love.graphics.setColor(255, 50, 50, 255)
	love.graphics.rectangle("fill", 12, throttleBot, 8, (throttleHeight - throttleBot) * (player.throttle / throttleSteps))

	love.graphics.setColor(255, 255, 255, 255)	
	for i = 0, throttleSteps, 1 do
		love.graphics.rectangle("fill", 10, throttleBot - i * ((throttleBot - throttleHeight) / throttleSteps), 12, 1)
	end
end

local function drawThrusters()
	if paused then return end
	
	if burnAnimationTime < burnAnimationDuration / 2 then
		if player.yBurn ~= 0 then
			love.graphics.rectangle("fill", player.x, player.y + (player.yBurn * player.sideLength * -1), 1, (player.throttle * player.yBurn) * -1)
		end
	
		if player.xBurn ~= 0 then
			love.graphics.rectangle("fill", player.x + (player.xBurn * player.sideLength * -1), player.y, (player.throttle * player.xBurn) * -1, 1)
		end
	elseif burnAnimationTime > burnAnimationDuration then
		burnAnimationTime = 0	
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
	
	player:onStartUpdate(dt)

	for i = 0, table.getn(asteroids), 1 do
		asteroids[i]:onStartUpdate(dt)
	end

	for i = 0, table.getn(asteroids), 1 do
		asteroids[i]:applyGravitation(player)
		player:applyGravitation(asteroids[i])
	end
	
	player:update(dt)
	self.timedText:update(dt)
	
	score = score + dt
	burnAnimationTime = burnAnimationTime + dt
	
	player:onEndUpdate(dt)

	local playerCollides = false
	for i = 0, asteroidCount - 1, 1 do
		playerCollides = playerCollides or player:collidesWith(asteroids[i])
	end
	
	gameOver = playerCollides or math.ceil(player.fuel) == 0
end

function GameScene:applyTransformations()
	
	local target = player.laser.target
	
	local distanceX = player.x - target.x
	local distanceY = player.y - target.y
	
	local translationX = target.x - (width / 2)
	local translationY = target.y - (height / 2)
	
	if distanceX > (width / 4) or distanceX < -(width / 4) then
		local difference = 0
		if distanceX > 0 then
			difference = distanceX - (width / 4)
		else
			difference = distanceX + (width / 4)
		end
		translationX = translationX + difference
	end
	if distanceY > (height / 4) or distanceY < -(height / 4) then
		local difference = 0
		if distanceY > 0 then
			difference = distanceY - (height / 4)
		else
			difference = distanceY + (height / 4)
		end
		translationY = translationY + difference
	end
	
	love.graphics.translate(-translationX, -translationY)
end

function GameScene:drawUI()
	local r, g, b, a = love.graphics.getColor()
	love.graphics.origin()
	
	drawThrottle()

	love.graphics.setColor(scoreColor.r, scoreColor.g, scoreColor.b, scoreColor.a)
	love.graphics.printf("Score: " .. math.floor(score), 0, 10, width, "right")

	love.graphics.setColor(fuelColor.r, fuelColor.g, fuelColor.b, fuelColor.a)
	love.graphics.printf("Fuel: " .. math.abs(math.ceil(player.fuel)), 0, 10, width, "center")

	love.graphics.setColor(r, g, b, a)

	if paused then
		love.graphics.printf("Paused\nPress space to continue", 0, (height / 2) - 50, width, "center")
	end

	if gameOver then
		love.graphics.printf("Game Over\nPress space to restart", 0, (height / 2) - 50, width, "center")
	end
end

function GameScene:draw()
	self:applyTransformations()
	
	self.timedText:printAll()
	
	local r, g, b, a = love.graphics.getColor()
	local l = player.sideLength
	local halfL = player.sideLength / 2
	
	for i = 0, table.getn(asteroids), 1 do
		if asteroids[i].resourceCount <= 0 then
			love.graphics.setColor(depletedColor.r, depletedColor.g, depletedColor.b, depletedColor.a)
		end
		
		love.graphics.circle("fill", asteroids[i].x, asteroids[i].y, asteroids[i].r, 15)
		love.graphics.setColor(r,g,b,a)
	end
	
	if player.laser.firing then
		love.graphics.setColor(laserColor.r, laserColor.g, laserColor.b, laserColor.a)
		love.graphics.line(player.x, player.y, player.laser.target.x, player.laser.target.y)
		love.graphics.setColor(r,g,b,a)
	end
	
	love.graphics.rectangle("fill", player.x - halfL, player.y - halfL, l, l)
	drawThrusters()
	
	self:drawUI()
end

function GameScene:keyPressed(key, repeats)
	if gameOver and key == " " then
		startGame()
		return
	end
	
	if key == "up" then
		player:fireBottomThruster()
	elseif key == "down" then
		player:fireTopThruster();
	elseif key == "left" then
		player:fireRightThruster()
	elseif key == "right" then
		player:fireLeftThruster()
	elseif key == " " then
		paused = not paused
	elseif key == "tab" then
		player:targetNearest(asteroids)
	end
end

function GameScene:keyReleased(key)	
	if gameOver then return end
	
	if key == "up" then
		player:stopBottomThruster()
	elseif key == "down" then
		player:stopTopThruster()
	elseif key == "left" then
		player:stopRightThruster()
	elseif key == "right" then
		player:stopLeftThruster();
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
