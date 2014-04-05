run = love.filesystem.load("runLoop.lua")

run()


function startGame()
	score = 0
	gameOver = false
	paused = true

	comboTimerMax = 4.3
	comboTimer = comboTimerMax
	comboCounter = 0
	
	theDot:randomLocation()
	
	theDot.r = 0
	
	snakeHead = snakeObj:new()
end

function love.load()
	love.window.setTitle("Fuel Pellets")
	width, height = love.window.getDimensions()
	showStart = true
	
	collisions = love.filesystem.load("collisionMath.lua")
	snake = love.filesystem.load("snakeObj.lua")
	love.filesystem.load("timedText.lua")()
	
	collisions()
	snake()
	
	fuelColor = {r = 50, g = 255, b = 50, a = 255}
	scoreColor = {r = 255, g = 255, b = 50, a = 255}
	
	theDot = {
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
	
	startGame()
end

function love.update(dt)
	if not gameOver and not paused and not showStart then
		snakeHead:update(dt)
		timedText:update(dt)
		
		score = score + dt
		comboTimer = comboTimer - dt
	
		if snakeHead:collidesWith(theDot) then
			comboTimer = comboTimerMax
			comboCounter = comboCounter + 1
			
			snakeHead:addFuel(theDot.fuelBonus + comboCounter)
			timedText:add("+" .. (theDot.fuelBonus + comboCounter), 
			   			  snakeHead.x + 10, snakeHead.y, 0.4,
						  fuelColor)
			
			score = score + (5 * comboCounter)
			timedText:add("+" .. (5 * comboCounter), 
						  snakeHead.x + 10, snakeHead.y + 15, 0.4, 
						  scoreColor)

			theDot:randomLocation()
		end
	
		theDot:scaleSizeToScore(score)
	
		if math.ceil(comboTimer) <= 0 then
			comboCounter = 0
			comboTimer = comboTimerMax
			theDot:randomLocation()
		end
	
		if math.ceil(snakeHead.fuel) == 0 then
			gameOver = true
		end
	end
end

function drawThrottle()
	local throttleBot = height / 4
	local throttleHeight = 30
	local throttleSteps = 10
	
	love.graphics.setColor(255, 50, 50, 255)
	love.graphics.rectangle("fill", 12, throttleBot, 8, (throttleHeight - throttleBot) * (snakeHead.throttle / throttleSteps))

	love.graphics.setColor(255, 255, 255, 255)	
	for i = 0, throttleSteps, 1 do
		love.graphics.rectangle("fill", 10, throttleBot - i * ((throttleBot - throttleHeight) / throttleSteps), 12, 1)
	end
end

function love.draw()
	if not showStart then
		local r, g, b, a = love.graphics.getColor()
		local l = snakeHead.sideLength
		local halfL = snakeHead.sideLength / 2
		love.graphics.rectangle("fill", snakeHead.x - halfL, snakeHead.y - halfL, l, l)
		love.graphics.circle("fill", theDot.x, theDot.y, theDot.r, 15)
		drawThrottle()
		timedText:printAll()
	
		love.graphics.setColor(scoreColor.r, scoreColor.g, scoreColor.b, scoreColor.a)
		love.graphics.printf("Score: " .. math.floor(score), 0, 10, width, "right")
		
		love.graphics.setColor(fuelColor.r, fuelColor.g, fuelColor.b, fuelColor.a)
		love.graphics.printf("Fuel: " .. math.ceil(snakeHead.fuel), 0, 10, width, "center")
		
		love.graphics.setColor(r, g, b, a)
		love.graphics.print("Combo: " .. comboCounter, 10, 10)
		
		love.graphics.rectangle("fill", 10, height - 15, (width - 10) * (comboTimer / comboTimerMax), 10)
	
		if paused then
			love.graphics.printf("Paused\nPress space to continue", 0, (height / 2) - 50, width, "center")
		end
	
		if gameOver then
			love.graphics.printf("Game Over\nPress space to restart", 0, (height / 2) - 50, width, "center")
		end
		
	else
		instructions = "Instructions:\n"
		instructions = instructions .. "\nCollect Fuel Pellets\n"
		instructions = instructions .. "\nUse arrow keys to fire thrusters\n"
		instructions = instructions .. "\nUse number keys to set your throttle\n"
		instructions = instructions .. "\nPress space to start\n"
		
		love.graphics.printf(instructions, 0, height / 3, width, "center")
		love.graphics.printf("Fuel Pellets", 0, (height / 3) - 55, width, "center")
	end
end

function love.keypressed(key)
	if showStart then
		if key == " " then
			showStart = false
		end
	else
		if gameOver and key == " " then
			startGame()
			return
		end
		
		if key == "up" then
			snakeHead.yBurn = snakeHead.yBurn - 1
		elseif key == "down" then
			snakeHead.yBurn = snakeHead.yBurn + 1
		elseif key == "left" then
			snakeHead.xBurn = snakeHead.xBurn - 1
		elseif key == "right" then
			snakeHead.xBurn = snakeHead.xBurn + 1
		elseif key == " " then
			paused = not paused
		end
	end
end

function love.keyreleased(key)
	if not showStart and not gameOver then
		if key == "up" then
			snakeHead.yBurn = snakeHead.yBurn + 1
		elseif key == "down" then
			snakeHead.yBurn = snakeHead.yBurn - 1
		elseif key == "left" then
			snakeHead.xBurn = snakeHead.xBurn + 1
		elseif key == "right" then
			snakeHead.xBurn = snakeHead.xBurn - 1
		end
	
		if key == "1" then
			snakeHead.throttle = 1
		elseif key == "2" then
			snakeHead.throttle = 2
		elseif key == "3" then
			snakeHead.throttle = 3
		elseif key == "4" then
			snakeHead.throttle = 4
		elseif key == "5" then
			snakeHead.throttle = 5
		elseif key == "6" then
			snakeHead.throttle = 6
		elseif key == "7" then
			snakeHead.throttle = 7
		elseif key == "8" then
			snakeHead.throttle = 8
		elseif key == "9" then
			snakeHead.throttle = 9
		elseif key == "0" then
			snakeHead.throttle = 10
		end
	end
end
