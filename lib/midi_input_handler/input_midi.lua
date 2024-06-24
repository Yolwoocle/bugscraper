--[[* * * * * * * * * * * * * * * * * * * 
*                                       *
* Midi Input manager for bugscraper     *
* Using rust lib midir and midi-control *
*                                       *
* -- Corentin Vaillant                  *
* * * * * * * * * * * * * * * * * * * *]] 

--TODO  CACHE IMAGE CANVAS

require "scripts.util"

local libmidi
if pcall(require,"libmidi_input_handler") then
    print("compile mode unix !")
    libmidi = require("libmidi_input_handler")

elseif pcall(require,"midi_input_handler") then
    print("compile mode window !")
    libmidi = require("midi_input_handler")
elseif pcall(require,"lib.midi_input_handler.libmidi_input_handler") then
    print("interpreted mode !")
    libmidi = require("lib.midi_input_handler.libmidi_input_handler")
else
    print("/!\\could not load midi/!\\")
end


local Class = require "scripts.meta.class"

local input_buffer = {}

local midi = {}


function midi.update_input()

    local inputs = libmidi.get_inputs()
    if #inputs == 0 then
        return
    end

    for _, value in pairs(inputs) do
        if value.midi_type == "note"then    
            local key_name = concat("note_",tostring(value.note) ,"_", tostring(value.oct) ,"_", tostring(value.channel))
            --print(key_name)
            input_buffer[key_name] = value["velocity"]
        else
            local key_name = concat(value["midi_type"],"_",tostring(value.key),"_",tostring(value.channel))
            --print(key_name)
            input_buffer[key_name] = value["value"]
        end
    end
    --print_table(input_buffer)
end

function midi.init_midi()
    libmidi.init_midi()
end

function midi.is_down_from_key_name(key_name)
    if key_name == "any"then
        for _, value in pairs(input_buffer) do
            if value ~= 0 then
                return true
            end
        end
        return false
    else
        return input_buffer[key_name]~=nil and input_buffer[key_name] ~= 0
    end
end

function midi.is_midi_down(button)
    return midi.is_down_from_key_name(button.key_name)
end

function midi.current_down_buttons() 
    local result = {}
    for key_name,velocity in pairs(input_buffer) do
        if midi.is_down_from_key_name(key_name) then
            table.insert(result,key_name)
        end
    end
    return result
end

return midi

---🤓
--[[
Copyright © 2024 <Corentin Vaillant>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]