require "scripts.util"
local AchievementManager = require "scripts.meta.achievement_manager"
local achievements = require "data.achievements"

local AchievementManagerSteam = AchievementManager:inherit()

function AchievementManagerSteam:init()
    AchievementManagerSteam.super.init(self)
end

function AchievementManagerSteam:grant_api(achievement_name)
    print_debug("AchievementManagerSteam: granting ", achievement_name)
    Steamworks:set_achievement(achievement_name)
end

function AchievementManagerSteam:revoke_api(achievement_name)
    print_debug("AchievementManagerSteam: revoking ", achievement_name)
    Steamworks:clear_achievement(achievement_name)
end

function AchievementManagerSteam:revoke_all_api()
    print_debug("AchievementManagerSteam: revoking all")
    Steamworks:reset_all_stats(true)
end

return AchievementManagerSteam