require "scripts.util"
local Class = require "scripts.meta.class"
local Animal = require "scripts.game.removeme_animal"

local Cat = Animal:inherit()

function Cat:init(name, cat_name)
    self.super:init(name)
    
    self.cat_name = cat_name
end

function Cat:scream()
    self.super:scream()
    print(concat("> hello, i am cat called ", self.name, ", cat ", self.cat_name))
end

return Cat