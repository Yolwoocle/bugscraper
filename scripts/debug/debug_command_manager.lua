require "scripts.util"
local Class = require "scripts.meta.class"
local DebugCommand = require "scripts.debug.debug_command"
local enemies = require "data.enemies"

local DebugCommandManager = Class:inherit()

function DebugCommandManager:init()
    self.commands = {
        ["help"] = DebugCommand:new {
            name = "help",
            description = "Prints help",
            args = {},
            run = function()
                local commands = table_keys(self.commands)
                table.sort(commands)
                for i, command_name in pairs(commands) do
                    local command = self.commands[command_name]
                    self:add_message(string.format("- %s: %s", command.signature, command.description))
                end
            end
        },
        ["spawn"] = DebugCommand:new {
            name = "spawn",
            description = "Spawns an enemy",
            args = {
                { "name:string" },
                { "x:number", CANVAS_WIDTH / 2 },
                { "y:number", CANVAS_HEIGHT / 2 }
            },
            run = function(name, x, y)
                local enemy_class = enemies[name]
                if not enemy_class then
                    return false, "Enemy '" .. name .. "' not found"
                end

                local enemy = enemy_class:new(x, y)
                game:new_actor(enemy)
                
                return true
            end,
        },
        ["say"] = DebugCommand:new {
            name = "say",
            description = "Send a message in the chat",
            args = {
                { "message:string" },
            },
            run = function(message)
                self:add_message(message)
                return true
            end,
        },
        ["print"] = DebugCommand:new {
            name = "print",
            description = "Prints text to the console",
            args = {
                { "text:string" },
            },
            run = function(text)
                print_debug(text)
                return true
            end,
        }
    }

    self.messages = {}
    self.max_messages = 18  
end


function DebugCommandManager:get_autocomplete(input)
    local args = split_str(input, " ")
    -- local last_arg_index 
end

function DebugCommandManager:add_message(message)
    local message_tab = {}
    if type(message) == "string" then
        message_tab = {
            color = COL_WHITE,
            content = message,
        }
    elseif type(message) == "table" then
        message_tab.color = message.color or COL_WHITE
        message_tab.content = message.content or ""
    end

    table.insert(self.messages, message_tab)

    if #self.messages > self.max_messages then
        table.remove(self.messages, 1)
    end
end


function DebugCommandManager:run(command_name, ...)
    local function run_command(...)
        if not command_name then
            return false, "No command name was given."
        end 
    
        local command = self.commands[command_name]
        if not command then
            return false, "Command "..command_name.." doesn't exist"
        end
    
        local success, err_message = command:run(...)
        return success, err_message
    end

    local success, err_message = run_command(...)
    if not success then
        self:add_message({color = COL_LIGHT_RED, content = err_message})
    end
end

return DebugCommandManager:new()
