local hierarchy = require '__rusty-locale__.type-hierarchy'


local _M = {}


function _M.descendants(type)
--- Get the tree of descendants, rooted at the given type, or nil if the type doesn't exist.
	if type == nil then return hierarchy.bottom_up; end
	return _M.descendants(hierarchy.top_down[type])[type]
end

local function inherits(type, bases)
	if type == nil then return nil; end
	if bases[type] then return type; end
	return inherits(hierarchy.top_down[type], bases)
end
function _M.inherits(t, bases)
--- Check if type is a descendant either a single base prototype or any of several prototypes provided as a table {string: boolean}.
--- This returns the type that matched, or nil of none did.
	if type(bases) ~= 'table' then return inherits(t, {[bases] = true})
	else return inherits(t, bases); end
end

function _M.find(name, type)
--- Find the prototype with the given name, whose type inherits from the given type, or nil if it doesn't exist.
	for t, prototypes in pairs(data.raw) do
		local prototype = prototypes[name]
		if prototype and _M.inherits(t, type) then return prototype; end
	end
	return nil
end


return _M
