require "scripts.util"
local Class = require "scripts.meta.class"
local skins = require "data.skins"
local skin_name_to_id = require "data.skin_name_to_id"

local MetaprogressionManager = Class:inherit()

function MetaprogressionManager:init()
    self.default_data = {
        xp = 0,
        xp_level = 0,
        skins = { 1, 2, 3, 4 }
    }

    self.levels = {
        [1] = { threshold = 100, rewards = { { type = "skin", skin = "nel" } } },
        [2] = { threshold = 2000, rewards = { { type = "skin", skin = "leo" } } },
    }

    self:read_progress()
end

function MetaprogressionManager:add_xp(value)
    local new_xp = self:get_xp() + value 
    local new_level = self:get_xp_level()

    while new_xp >= self:get_xp_level_threshold(new_level + 1) do
        new_level = new_level + 1
        new_xp = new_xp - self:get_xp_level_threshold(new_level)
        self:grant_level_rewards(new_level)

        print((self:get_xp_level_info(new_level) or {}).threshold or math.huge)
    end

    self:set_xp(new_xp)
    self:set_xp_level(new_level)
end

function MetaprogressionManager:grant_level_rewards(xp_level)
    print_debug("granting level rews call", xp_level)
    local level_info = self:get_xp_level_info(xp_level)

    if not level_info then
        return
    end

    print_debug("granting level rews", xp_level)
    for _, reward in pairs(level_info.rewards) do
        self:grant_reward(reward)
    end
end

function MetaprogressionManager:grant_reward(reward)
    print_debug("granting ")
    if reward.type == "skin" then
        print_debug("granting skin")
        self:unlock_skin(skin_name_to_id[reward.skin])
    end
end
    
function MetaprogressionManager:get_xp()
    return self:get("xp")
end

function MetaprogressionManager:set_xp(value)
    self:set("xp", value)
end

function MetaprogressionManager:get_xp_level()
    return self:get("xp_level")
end

function MetaprogressionManager:set_xp_level(value)
    self:set("xp_level", value)
end

function MetaprogressionManager:get_xp_level_threshold(level)
    return (self:get_xp_level_info(level) or {}).threshold or math.huge
end

function MetaprogressionManager:get_xp_level_info(level)
    return self.levels[level or self:get_xp_level()]
end

function MetaprogressionManager:unlock_skin(skin_id)
    local s = self:get("skins")
    table.insert(s, skin_id)
    self:save_progress()
end

-----------------------------------------------------

function MetaprogressionManager:get(name)
    return self.data[name]
end

function MetaprogressionManager:set(name, value, do_not_save)
    self.data[name] = value
    if not do_not_save then
        self:save_progress()
    end
end

function MetaprogressionManager:reset()
    self.data = copy_table_shallow(self.default_data)
    self:save_progress()
end

function MetaprogressionManager:read_progress()
    self.data = Files:read_config_file("progress.txt", self.default_data)
end

function MetaprogressionManager:save_progress()
    Files:write_config_file("progress.txt", self.data)
end


return MetaprogressionManager
