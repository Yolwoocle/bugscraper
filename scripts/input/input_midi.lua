--[[* * * * * * * * * * * * * * * * * * * 
*                                       *
* Midi Input manager for bugscraper     *
* Using rust lib midir and midi-control *
*                                       *
* -- Corentin Vaillant                  *
* * * * * * * * * * * * * * * * * * * *]] 

require "scripts.util"
local r_MidiHandler = require "lib.midi_input_handler.lib"
local Class = require "scripts.meta.class"

function init_midi()
    r_MidiHandler.innit_midi()
end

