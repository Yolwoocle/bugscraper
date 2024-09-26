require "scripts.util"
local Class = require "scripts.meta.class"
local images= require "data.images"

local Upgrade = Class:inherit()

function Upgrade:init()
    self:init_upgrade()
end
function Upgrade:init_upgrade()
    self.name = self.name or "upgrade"
    self.type = UPGRADE_TYPE_INSTANT

    self.sprite = images.upgrade_coffee

    self.title       = Text:text("upgrade."..tostring(self.name)..".title")
    self.description = Text:text("upgrade."..tostring(self.name)..".description")
    self.color = COL_WHITE
end

function Upgrade:update(dt)
    self:update_upgrade(dt)
end

function Upgrade:update_upgrade(dt)
end

function Upgrade:apply(player, is_revive)
    self:apply_permanent(player, is_revive)
    if not is_revive then
        self:apply_instant(player)
        self:play_effects(player)
    end
end

function Upgrade:apply_permanent(player, is_revive)
end

function Upgrade:apply_instant(player)
end

function Upgrade:play_effects(player)
end

function Upgrade:on_finish(player)
end

function Upgrade:draw(x, y, s)
    self:draw_upgrade(x, y, s)
end
function Upgrade:draw_upgrade(x, y, s)
    draw_centered(self.sprite, x, y, 0, s, s)
end

function Upgrade:get_title()
    return self.title
end

function Upgrade:get_description()
    return self.description
end

return Upgrade