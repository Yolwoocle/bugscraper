require "scripts.util"
local Class = require "scripts.meta.class"

local Animal = Class:inherit()

function Animal:init(name)
    self.name = name
end

function Animal:scream()
    print(concat("hello, generic animal called", self.name))
end

return Animal