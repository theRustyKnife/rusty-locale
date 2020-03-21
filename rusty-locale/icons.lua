local prototypes = require '__rusty-locale__.prototypes'
local recipes = require '__rusty-locale__.recipes'


local _M = {}


function _M.of_generic(prototype, silent)
--- Get icons for the given prototype, assuming it's in the generic format.
	if prototype.icons then
		local icons = {}
		for i, icon in pairs(prototype.icons) do
			if icon.icon_size then icons[i] = icon
			else
				if not prototype.icon_size then
					if silent then return nil; end
					error(("%s/%s doesn't specify icon_size correctly"):format(prototype.type, prototype.name))
				end
				
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

function _M.of_recipe(prototype, silent)
--- Get icons for the given recipe prototype.
	local icons = _M.of_generic(prototype, silent)
	if icons then return icons; end
	
	local product
	if prototype.normal ~= nil then product = recipes.partial.get_main_product(prototype.normal)
	else product = recipes.partial.get_main_product(prototype); end
	
	return product and _M.of(product.name, product.type, silent)
end


function _M.of(prototype, type, silent)
--- Get the icons of the given prototype.
	if type ~= nil then prototype = prototypes.find(prototype, type); end
	if prototypes.inherits(prototype.type, 'recipe') then return _M.of_recipe(prototype, silent)
	else return _M.of_generic(prototype, silent); end
end


return _M
