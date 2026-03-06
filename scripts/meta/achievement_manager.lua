require "scripts.util"
local Class = require "scripts.meta.class"
local achievements = require "data.achievements"

local AchievementManager = Class:inherit()

function AchievementManager:init()
    self.granted_achievements = self:get_granted_achievements()

    self:regrant_achievements()
end

function AchievementManager:regrant_achievements()
    for _, ach in pairs(self.granted_achievements) do
        self:grant(ach)
    end
end


function AchievementManager:achievement_exists(achievement_name)
    return achievements[achievement_name] ~= nil
end

function AchievementManager:get_granted_achievements()
    return Metaprogression:get("achievements") or {}
end

function AchievementManager:is_achievement_granted(achievement_name)
    return (self:get_granted_achievements())[achievement_name]
end

function AchievementManager:get_achievement(achievement_name)
    return achievements[achievement_name]
end

function AchievementManager:grant(achievement_name)
    
end

function AchievementManager:revoke(achievement_name)
end

function AchievementManager:revoke_all()
end

function AchievementManager:load_achievements(achievements_to_load)
end

function AchievementManager:_save_achievement(achievement_name)
end


return AchievementManager:new()