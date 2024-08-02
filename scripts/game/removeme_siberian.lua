require "scripts.util"
local Class = require "scripts.meta.class"
local Cat = require "scripts.game.removeme_cat"

local Siberian = Cat:inherit()

function Siberian:init(name, cat_name, sib_name)
    self.super:init(name, cat_name)
    
    self.siberian_name = sib_name
end

function Siberian:scream()
    self.super:scream()
    print(concat("> hello, i am cat called ", self.name, ", cat ", self.cat_name, ", sib ", self.siberian_name))
end

return Siberian