local MusicDisk    = require "scripts.audio.music_disk"
local MusicDiskWeb = require "scripts.audio.music_disk_web"
local sounds       = require "data.sounds"

local disk_class   = ternary(OPERATING_SYSTEM == "Web", MusicDiskWeb, MusicDisk)

return {
    ["ground_floor_empty"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_ground_floor_empty_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_ground_floor_empty_paused.source
    }, { volume = 0.75 }),
    ["ground_floor_players"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_ground_floor_players_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_ground_floor_players_paused.source,
    }, { volume = 0.75 }),

    ["w1"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w1_paused.source,
    }),
    ["w2"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w2_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w2_ingame.source,
    }),
    ["w3"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w3_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w3_paused.source,
    }),
    ["w4"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w1_paused.source,
    }),
    ["w5"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w1_paused.source,
    }),
    ["w0"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_w1_paused.source,
    }),

    ["game_over"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_game_over.source,
        [MUSIC_MODE_PAUSE] = sounds.music_game_over.source,
    }),
    ["cafeteria"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_cafeteria_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_cafeteria_paused.source,
    }),
    ["cafeteria_empty"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_cafeteria_empty_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_cafeteria_paused.source,
    }),
    ["miniboss"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.music_boss_w1_ingame.source,
        [MUSIC_MODE_PAUSE] = sounds.music_boss_w1_paused.source,
    }),
}
