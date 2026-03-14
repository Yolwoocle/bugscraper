require "scripts.util"
local Class = require "scripts.meta.class"
local achievements = require "data.achievements"
local images       = require "data.images"

local AchievementManager = Class:inherit()

function AchievementManager:init()
    self.granted_achievements = self:get_granted_achievements()
    self:save_achievements() -- Save immediately to remove potential duplicates
    
    self:regrant_achievements()
end

-- This method makes sure that the locally saved granted achievements are updated on 
-- the distribution platform (e.g. Steam) on load, to take into account cases where the 
-- achievements were granted while offline
function AchievementManager:regrant_achievements()
    local t = Metaprogression:get("achievements")

    for i, ach in pairs(t) do
        -- NOTE: maybe only grant the achievement if they're not granted on remote?
        self:grant_api(ach)
    end

    if Input:action_pressed_any_player("interact") then
        local k = table_keys(achievements)
        self:grant(achievements[k[random_range_int(1, #k)]])
    end
end

function AchievementManager:achievement_exists(achievement_name)
    return achievements[achievement_name] ~= nil
end

function AchievementManager:get_granted_achievements()
    return table_to_set(Metaprogression:get("achievements") or {})
end

function AchievementManager:is_achievement_granted(achievement_name)
    return self.granted_achievements[achievement_name]
end

function AchievementManager:get_achievement(achievement_name)
    return achievements[achievement_name]
end

-- Grants an achievement
function AchievementManager:grant(achievement_name)
    self.granted_achievements[achievement_name] = true
    
    self:save_achievements()
    self:grant_api(achievement_name)

    if game and game.game_ui then
        local ach = self:get_achievement(achievement_name)
        game.game_ui:new_toast(
            images[ach.image],
			Text:text("achievements." .. ach.name .. ".name"),
			Text:text("achievements." .. ach.name .. ".description")
        )
    end
end

-- (Abstract) To be implemented by subclasses.
-- Actually grants the achievement through the appropriate API (Steam, Google Play, etc) 
function AchievementManager:grant_api(achievement_name)
    -- error("To be implemented")
end

-- Revokes the achievement
function AchievementManager:revoke(achievement_name)
    -- TODO
    self:revoke_api(achievement_name)
end

-- (Abstract) To be implemented by subclasses
-- Actually revokes the achievement through the appropriate API (Steam, Google Play, etc) 
function AchievementManager:revoke_api(achievement_name)
    -- error("To be implemented")
end

-- Revokes all the achievements
function AchievementManager:revoke_all()
    self.granted_achievements = {}
    self:save_achievements()
    self:revoke_all_api()
end

-- (Abstract) To be implemented by subclasses
-- Actually revokes all the achievements through the appropriate API (Steam, Google Play, etc) 
function AchievementManager:revoke_all_api()
    -- error("To be implemented")
end

function AchievementManager:save_achievements()
    Metaprogression:set("achievements", set_to_table(self.granted_achievements)) 
end


return AchievementManager