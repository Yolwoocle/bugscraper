local MusicDisk    = require "scripts.audio.music_disk"
local MusicDiskWeb = require "scripts.audio.music_disk_web"
local sounds       = require "data.sounds"

local disk_class   = ternary(OPERATING_SYSTEM == "Web", MusicDiskWeb, MusicDisk)

return {
    ["cafeteria"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.amb_pad_cafeteria_lp.source,
    }, { volume = 0.3 }),

    ["lobby"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.amb_pad_lobby_lp.source,
    }, { volume = 0.3 }),

    ["tutorial"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.amb_pad_tutorial_lp.source,
    }, { volume = 0.3 }),

    ["w1"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.amb_pad_world1_lp.source,
    }, { volume = 0.3 }),

    ["w2"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.amb_pad_world2_lp.source,
    }, { volume = 0.3 }),

    ["w3"] = disk_class:new({
        [MUSIC_MODE_INGAME] = sounds.amb_pad_world3_lp.source,
    }, { volume = 0.3 }),

}
