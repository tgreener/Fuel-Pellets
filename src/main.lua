love.filesystem.load("RunLoop.lua")()

function startGame()
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

local currentScene

function love.load()
	love.window.setTitle("Fuel Pellets")
	width, height = love.window.getDimensions()
	
	love.filesystem.load("CollisionMath.lua")()
	love.filesystem.load("Player.lua")()
	love.filesystem.load("TimedText.lua")()
	love.filesystem.load("SceneManager.lua")()
	sceneManager = SceneManager:new()
	
	showStart = true
	
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
		player:update(dt)
		sceneManager.currentScene:update(dt)
		
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
end

function love.draw()
	sceneManager.currentScene:draw()
end

function love.keypressed(key)
	if showStart then
		if key == " " then
			showStart = false
			sceneManager.currentScene = GameScene:new()
		end
	else
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
end

function love.keyreleased(key)
	if not showStart and not gameOver then
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
end
