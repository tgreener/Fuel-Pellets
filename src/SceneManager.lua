love.filesystem.load("Object.lua")
love.filesystem.load("MainMenuScene.lua")()
love.filesystem.load("GameScene.lua")()

SceneManager = Object:extend({
	currentScene = MainMenuScene:new()
})

