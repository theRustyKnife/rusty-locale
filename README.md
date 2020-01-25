# Reporting bugs #
Please report bugs on [GitHub](https://github.com/theRustyKnife/rusty-locale/issues).


# Why does this exist? #
Because understanding where exactly do recipes take their locale from took me several days of trial and error (and harassing Bilka on discord). I certainly don't wish anyone to go through that again, so I packaged all of the pain into this convenient little library.

For real though, I need to generate virtual signals to represent recipes in [Crafting Combinator](https://mods.factorio.com/mod/crafting_combinator) and for a long time I used a half-assed approach of figuring out the locale that completely ignored ~90% of the mechanism. This (obviously) didn't work for many recipes, so I decided to bite the bullet and do it properly. Since several people seemed interested in my work, I decided to polish it a bit and make it into this lib.

There are also several things that are prone to require updates with changes to the base game. This way only the library needs to be updated, rather than each mod individually.


# What can it do? #
The main purpose of the library is to find the correct `localised_name` and `localised_description` of prototypes. This of course includes recipes (which are by far the most complicated), but it works for any other prototype too.

It can also give you proper `icons` for any prototype. This was added because recipes can inherit `icons` from their products (though differently than locale), but is also useful to parse the various formats an icon can be defined in.

Apart from that, there's a bunch of random utilities that the lib uses itself, but I thought I'd expose them, since they could be useful on their own as well. Notably, there's a prototype type inheritance tree and a couple utilities around that.


# How to #
First of all you need to add the lib to your dependencies in `info.json` - something like:
```json
{
	"name": "moddy-mc-modface",
	"version": "4.2.0",
	...
	"dependencies": [..., "rusty-locale"]
}
```
should do the trick.

Next, import the modules you want to use with something like:
```lua
local rusty_locale = require '__rusty-locale__.locale'
```
and call functions on them like:
```lua
local locale = rusty_locale.of(some_recipe_prototype)
```
This is for the locale module, for icons you'd replace `locale` with `icons`, and so on... You can find the available modules and the functions in them in the reference bellow.


# Reference #

# **`locale`** #
All the functions in this module return a special object that has two properties: `name` and `description`, which return the localised name and description, respectively. The properties are resolved lazily, so don't worry if you only need to use one of them.

## _`of(prototype)`_ ##
Get a locale object for the given prototype. The type of the prototype is determined automatically and the proper algorithm is used to resolve the locale. This is the preferred way to use the module as it is future-proof in case some prototype is changed to require a special algorithm.

As this is the "smart" function, it does more work than the specific ones, so it can be slower. This shouldn't be much of a concern, but if you really care about data stage performance for whatever reason and you know the type of the prototype in advance, you can save some time by calling the specific function for that type directly.

## _`of(name, type)`_ ##
Shorthand for `locale.of(prototypes.find(name, type))`.

## _`of_recipe(prototype)`_ ##
Get a locale object for the given prototype, assuming it's a recipe.

## _`of_item(prototype)`_ ##
Get a locale object for the given prototype, assuming it's an item.

## _`of_generic(prototype)`_ ##
Get a locale object for the given prototype, assuming it doesn't use any of the special formats.

## _`localised_types`_ ##
This is a table mapping the prototype types that support localisation to `true` for easy lookup.


# **`icons`** #
All the icons in this module are returned in the `icons`-only format. This means that it is safe to use the results in a prototype just by setting them to `icons`.

## _`of(prototype)`_ ##
Get the icons for the given prototype. The type of the prototype is determined automatically and the proper algorithm is used to resolve the icons. This is the preferred way to use the module as it is future-proof in case some prototype is changed to require a special algorithm.

The same disclaimer applies as for `locale.of()`.

## _`of(name, type)`_ ##
Shorthand for `icons.of(prototypes.find(name, type))`.

## _`of_recipe(prototype)`_ ##
Get the icons for the given prototype, assuming it's a recipe.

## _`of_generic(prototype)`_ ##
Get the icons for the given prototype, assuming it doesn't use any special format.


# **`prototypes`** #
These are utilties to work with the prototype inheritance tree.

## _`find(name, type)`_ ##
Find a prototype with the given name, whose type inherits from the given type.

This is particularly useful for finding prototypes of recipe products where you may only know the name and that it's an item/fluid, not the exact type. For example:
```lua
prototypes.of('firearm-magazine', 'item')
```
would give you the prototype for `firearm-magazine`, eventhough the actual type is `ammo`, not `item`.

## _`inherits(type, base)`_ ##
Check if the given type is a descendant of the given base. If it does, the name of the base is returned, or `nil` if it doesn't.

You can also pass a table to `base` that maps base type names to `true`. The function will then check if the type inherits from _any_ of the bases, **not** all of them. The returned base is the one that matched first.

## _`descendants(type)`_ ##
Get the tree of descendants, rooted at the given type, or `nil` if the type doesn't exist. The tree is represented as a nested table mapping type names to their respective descendant subtrees.


# **`recipes`** #
The `partial` functions only operate on the given table as if it was the full recipe spec. This means normal/expensive specs are ignored when passing the whole recipe, but can be passed to the function themselves instead.

## _`parse_product(product)`_ #
Get the given product in the `{name = ..., type = ..., ...}` format.

## _`get_main_product(recipe)`_ ##
Get the main product of the given recipe, correctly handling normal+expensive definitions. This means that the main product is only returned if it's the same for both normal and expensive.

The main product is returned in the `{name = ..., type =..., ...}` format. `nil` will be returned if there is no main product.

## _`partial.get_main_product(recipe)`_ ##
Get the main product of the given recipe part.

## _`partial.find_product(recipe, name)`_ ##
Get the full product definition for a product with the given name from the recipe part. This is mainly useful for main products.