love.filesystem.load("Object.lua")()
love.filesystem.load("TimedText.lua")()
love.filesystem.load("Scene.lua")()
love.filesystem.load("MainMenuScene.lua")()
love.filesystem.load("GameScene.lua")()

Renderer = Object:extend({
})

local timedTextTime = 0.4
local timedText = TimedText:new()
local currentScene = MainMenuScene:new()


function Renderer:update(dt)
	if currentScene then
		currentScene:update(dt)
	end
end

function Renderer:setFuelGained(text, x, y)
	if currentScene then
		currentScene:addTimedText(text, x, y, timedTextTime, fuelColor)
	end
end

function Renderer:setScoreGained(text, x, y)
	if currentScene then
		currentScene:addTimedText(text, x, y, timedTextTime, scoreColor)
	end
end

function Renderer:changeToGameScene()
	currentScene = GameScene:new()
end

function Renderer:getCurrentScene()
	return currentScene
end

function Renderer:render()
	currentScene:draw()

	--[[
	if not showStart then
		local r, g, b, a = love.graphics.getColor()
		local l = player.sideLength
		local halfL = player.sideLength / 2
		love.graphics.rectangle("fill", player.x - halfL, player.y - halfL, l, l)
		love.graphics.circle("fill", theDot.x, theDot.y, theDot.r, 15)
		drawThrottle()
		timedText:printAll()

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
	
	else
		instructions = "Instructions:\n"
		instructions = instructions .. "\nCollect Fuel Pellets\n"
		instructions = instructions .. "\nUse arrow keys to fire thrusters\n"
		instructions = instructions .. "\nUse number keys to set your throttle\n"
		instructions = instructions .. "\nPress space to start\n"
	
		love.graphics.printf(instructions, 0, height / 3, width, "center")
		love.graphics.printf("Fuel Pellets", 0, (height / 3) - 55, width, "center")
	end
	]]--
end
