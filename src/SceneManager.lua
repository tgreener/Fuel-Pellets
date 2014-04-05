love.filesystem.load("Object.lua")
love.filesystem.load("MainMenuScene.lua")()
love.filesystem.load("GameScene.lua")()

SceneManager = Object:extend({
	currentScene = MainMenuScene:new()
})

function SceneManager:setScene(scene)
	self.currentScene = scene
	self.currentScene:enter()	
end

