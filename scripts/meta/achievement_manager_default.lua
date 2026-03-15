require "scripts.util"
local AchievementManager = require "scripts.meta.achievement_manager"
local achievements = require "data.achievements"

local AchievementManagerDefault = AchievementManager:inherit()

function AchievementManagerDefault:init()
    AchievementManagerDefault.super.init(self)
end

function AchievementManagerDefault:grant_api(achievement_name)
end

function AchievementManagerDefault:revoke_api(achievement_name)
end

function AchievementManagerDefault:revoke_all_api()
end

return AchievementManagerDefault