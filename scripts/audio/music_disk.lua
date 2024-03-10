require "scripts.util"
local sounds = require "data.sounds"
local Class = require "scripts.meta.class"

local MusicDisk = Class:inherit()

function MusicDisk:init(music_player, music_ingame, music_pause)
    self.music_player = music_player
    self.sources = {
        [MUSIC_MODE_INGAME] = music_ingame,
        [MUSIC_MODE_PAUSE] = music_pause,
    }

    self.music_mode = MUSIC_MODE_OFF
    self.current_source = self.sources[MUSIC_MODE_INGAME]
end

function MusicDisk:pause()
    if self.current_source ~= nil then
        self.current_source:pause()
    end
end

function MusicDisk:play()
    if self.current_source ~= nil then    
        self.current_source:play()   
    end
end

function MusicDisk:stop()
    if self.current_source ~= nil then    self.current_source:stop()    end
end

function MusicDisk:set_mode(mode)
	self.music_mode = mode

    if mode == MUSIC_MODE_OFF then
        self:stop()

    elseif self.current_source ~= nil then
        local new_source = self.sources[mode]
        local time = self.current_source:tell()
        if self.current_source ~= new_source then
            self.current_source:stop()
            self.current_source = new_source
            self.current_source:play()
            self.current_source:seek(time)
        end
    end
end

function MusicDisk:set_volume(vol)
    for _, source in pairs(self.sources) do
        source:setVolume(vol)
    end
end

return MusicDisk