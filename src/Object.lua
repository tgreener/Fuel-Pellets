
Object = {}

function Object:new()
	local obj = {}
	setmetatable(obj, {__index = self})
		
	return obj
end

function Object:extend(obj)
	local o = obj
	setmetatable(o, {__index = self})
	
	return o
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
