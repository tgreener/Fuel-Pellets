
function sqr(x)
	return math.pow(x, 2)
end

function dist2(a, b)
	return sqr(a.x - b.x) + sqr(a.y - b.y)
end

function distToSegment2(p, a, b)
	local lengthSqr = dist2(a, b)
	
	if lengthSqr == 0 then
		dist2(p, a)
	end
	
	local t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / lengthSqr
	
	if t < 0 then return dist2(p, a) end
	if t > 1 then return dist2(p, b) end
	
	local closestPoint = {
		x = a.x + t * (b.x - a.x),
		y = a.y + t * (b.y - a.y)
	}
	
	return dist2(p, closestPoint)
end

function distToSegment(p, a, b)
	return math.sqrt(distToSegment2(p, a, b))
end
