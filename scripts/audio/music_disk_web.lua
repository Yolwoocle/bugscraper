require "scripts.util"
local sounds = require "data.sounds"
local Class = require "scripts.meta.class"

local MusicDiskWeb = Class:inherit()

--scotch: this whole class
function MusicDiskWeb:init(music_player, music_ingame, music_pause)
    self.music_player = music_player
    self.name = nil
    self.sources = {
        [MUSIC_MODE_INGAME] = music_ingame:clone(),
        [MUSIC_MODE_PAUSE] = music_pause:clone(),
    }

    self.volume = 1.0
    
    self.music_mode = MUSIC_MODE_OFF
    self.current_source = self.sources[MUSIC_MODE_INGAME]
end

function MusicDiskWeb:update(dt)
    for source_mode, source in pairs(self.sources) do
        if source_mode == self.music_mode then
            source:setVolume(self.volume)
        else
            source:setVolume(0.0)   
        end
    end
end

function MusicDiskWeb:set_name(name)
    self.name = name
end

function MusicDiskWeb:pause()
    for _, source in pairs(self.sources) do 
        source:pause()
    end
    -- if self.current_source ~= nil then;
    --     self.current_source:pause();
    -- end;
end

function MusicDiskWeb:play()
    for source_mode, source in pairs(self.sources) do 
        source:play()
        if source_mode == self.music_mode then
            source:setVolume(self.volume)
        else
            source:setVolume(0.0)
        end
    end
    self:update()
    -- if self.current_source ~= nil then    
    --     self.current_source:play()   
    -- end
end

function MusicDiskWeb:stop()
    for _, source in pairs(self.sources) do 
        source:stop()
    end
    -- if self.current_source ~= nil then
    --     self.current_source:stop()
    -- end
end

function MusicDiskWeb:set_mode(mode)
	self.music_mode = mode

    if mode == MUSIC_MODE_OFF then
        self:stop()

    elseif self.current_source ~= nil then
        for source_mode, source in pairs(self.sources) do 
            if source_mode == mode then
                source:setVolume(self.volume)   
            else
                source:setVolume(0.0)
            end
        end
        -- local new_source = self.sources[mode]
        -- local time = self.current_source:tell()
        -- if self.current_source ~= new_source then
        --     self.current_source:stop()
        --     self.current_source = new_source
        --     self.current_source:play()
        --     self.current_source:seek(time)
        -- end
    end
end

function MusicDiskWeb:set_volume(vol)
    self.volume = vol
    for source_mode, source in pairs(self.sources) do
        if source_mode == self.music_mode then
            source:setVolume(vol)   
        else
            source:setVolume(0.0)   
        end
    end
end

return MusicDiskWeb