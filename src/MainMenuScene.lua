love.filesystem.load("Scene.lua")()

MainMenuScene = Scene:extend({
})

function MainMenuScene:draw()
	self.timedText:printAll()
	
	instructions = "Instructions:\n"
	instructions = instructions .. "\nCollect Fuel Pellets\n"
	instructions = instructions .. "\nUse arrow keys to fire thrusters\n"
	instructions = instructions .. "\nUse number keys to set your throttle\n"
	instructions = instructions .. "\nPress space to start\n"

	love.graphics.printf(instructions, 0, height / 3, width, "center")
	love.graphics.printf("Fuel Pellets", 0, (height / 3) - 55, width, "center")
end

function MainMenuScene:keyReleased(key)
	if key == " " then
		sceneManager:setScene(GameScene:new())
	end	
end

