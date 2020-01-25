local prototypes = require '__rusty-locale__.prototypes'
local recipes = require '__rusty-locale__.recipes'


local _M = {}


function _M.of_generic(prototype)
--- Get icons for the given prototype, assuming it's in the generic format.
	if prototype.icons then
		local icons = {}
		for i, icon in pairs(prototype.icons) do
			if icon.icon_size then icons[i] = icon
			else
				local new = {}
				for k, v in pairs(icon) do new[k] = v; end
				new.icon_size = prototype.icon_size
				icons[i] = new
			end
		end
		return icons
	end
	if prototype.icon then return {{icon = prototype.icon, icon_size = prototype.icon_size}}; end
	return nil;
end

function _M.of_recipe(prototype)
--- Get icons for the given recipe prototype.
	local icons = _M.of_generic(prototype)
	if icons then return icons; end
	
	local product
	if prototype.normal ~= nil then product = recipes.partial.get_main_product(prototype.normal)
	else product = recipes.partial.get_main_product(prototype); end
	
	return product and _M.of(prototypes.find(product.name, product.type))
end


function _M.of(prototype, type)
--- Get the icons of the given prototype.
	if type ~= nil then prototype = prototypes.find(prototype, type); end
	if prototypes.inherits(prototype.type, 'recipe') then return _M.of_recipe(prototype)
	else return _M.of_generic(prototype); end
end


return _M
