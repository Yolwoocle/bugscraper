require "scripts.util"
local AchievementManager = require "scripts.meta.achievement_manager"
local achievements = require "data.achievements"

local AchievementManagerSteam = AchievementManager:inherit()

function AchievementManagerSteam:init()
    AchievementManagerSteam.super.init(self)
end

function AchievementManagerSteam:grant_api(achievement_name)
    -- TODO
end

function AchievementManagerSteam:revoke_api(achievement_name)
    -- TODO
end

function AchievementManagerSteam:revoke_all_api()
    -- TODO
end