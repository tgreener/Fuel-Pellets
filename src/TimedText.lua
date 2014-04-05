
TimedText = Object:extend({})

function TimedText:add(text, x, y, time, color)
	table.insert(self, {text = text, x = x, y = y, time = time, color = color})
end

function TimedText:update(dt)
	for index, text in ipairs(self) do
		text.time = text.time - dt
		
		if text.time < 0 then
			table.remove(self, index)
		end
	end
end

function TimedText:printAll()
	for i, t in ipairs(self) do
		local r, g, b, a = love.graphics.getColor()
		
		love.graphics.setColor(t.color.r, t.color.g, t.color.b, t.color.a)
		love.graphics.print(t.text, t.x, t.y)
		love.graphics.setColor(r, g, b, a)
	end
end