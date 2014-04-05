love.filesystem.load("RunLoop.lua")()

function love.load()
	love.window.setTitle("Fuel Pellets")
	width, height = love.window.getDimensions()	
	love.filesystem.load("SceneManager.lua")()
	
	sceneManager = SceneManager:new()
end

function love.update(dt)
	sceneManager.currentScene:update(dt)
end

function love.draw()
	sceneManager.currentScene:draw()
end

function love.keypressed(key)
	sceneManager.currentScene:keyPressed(key)
end

function love.keyreleased(key)
	sceneManager.currentScene:keyReleased(key)
end
