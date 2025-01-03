require "scripts.util"
local Class = require "scripts.meta.class"
local DebugCommand = require "scripts.debug.debug_command"
local enemies = require "data.enemies"
local utf8 = require 'utf8'
local cutscenes = require 'data.cutscenes'
local upgrades  = require 'data.upgrades'

local DebugCommandManager = Class:inherit()

function DebugCommandManager:init()
    self.commands = {}
    self.commands["help"] = DebugCommand:new {
        name = "help",
        description = "Prints help",
        args = {},
        run = function()
            for i, command_name in pairs(self.all_commands) do
                local command = self.commands[command_name]
                self:add_message(string.format("- %s: %s", command.signature, command.description))
            end
        end
    }

    local enemies_keys = table_keys(enemies)
    local cutscenes_keys = table_keys(cutscenes)
    local upgrades_keys = table_keys(upgrades)
    table.sort(enemies_keys)
    self.commands["upgrade"] = DebugCommand:new {
        name = "upgrade",
        description = "Applies an upgrade",
        args = {
            { "name:string", values = upgrades_keys },
        },
        run = function(name, x, y)
            local upgrade_class = upgrades[name]
            if not upgrade_class then
                return false, "Upgrade '" .. name .. "' not found"
            end

            local upgrade = upgrade_class:new()
            game:apply_upgrade(upgrade)
            self:add_message("Applied upgrade '"..name.."'")

            return true
        end,
    }
    self.commands["spawn"] = DebugCommand:new {
        name = "spawn",
        description = "Spawns an enemy",
        args = {
            { "name:string", values = enemies_keys },
            { "x:number",    default = CANVAS_WIDTH / 2 },
            { "y:number",    default = CANVAS_HEIGHT / 2 }
        },
        run = function(name, x, y)
            local enemy_class = enemies[name]
            if not enemy_class then
                return false, "Enemy '" .. name .. "' not found"
            end

            local enemy = enemy_class:new(x, y)
            game:new_actor(enemy)
            self:add_message("Spawned '"..name.."'")

            return true
        end,
    }
    self.commands["cutscene"] = DebugCommand:new {
        name = "cutscene",
        description = "Plays a cutscene",
        args = {
            { "name:string", values = cutscenes_keys },
        },
        run = function(name, x, y)
            local cutscene = cutscenes[name]
            if not cutscene then
                return false, "Cutscene '" .. name .. "' not found"
            end

            game:play_cutscene(cutscene)
            self:add_message("Played cutscene '"..name.."'")

            return true
        end,
    }
    self.commands["kill"] = DebugCommand:new {
        name = "kill",
        description = "Kills a player",
        args = {
            { "player_n:number", default = 1 },
        },
        run = function(player_n)
            local player = game.players[player_n]
            if not player then
                return false, "Player "..tostring(player_n).." doesn't exist"
            end 
            
            player:kill()
            return true
        end,
    }
    self.commands["say"] = DebugCommand:new {
        name = "say",
        description = "Send a message in the chat",
        args = {
            { "message:string" },
        },
        run = function(message)
            self:add_message(message)
            return true
        end,
    }
    self.commands["print"] = DebugCommand:new {
        name = "print",
        description = "Prints text to the console",
        args = {
            { "text:string" },
        },
        run = function(text)
            return true
        end,
    }
    self.commands["_spawn_upgrades"] = DebugCommand:new {
        name = "_spawn_upgrades",
        description = "Spawns a bunch of upgrades",
        args = {
        },
        run = function(text)
            local upgrades_copy = copy_table_shallow(upgrades)
            table.sort(upgrades_copy)
            local i = 0
            for name, upgrade in pairs(upgrades_copy) do
                local a = enemies.UpgradeDisplay:new(128 + i*42, 300)
                game:new_actor(a)
                a:assign_upgrade(upgrade:new())
                i = i + 1
            end
            return true
        end,
    }

    self.messages = {}
    self.max_messages = 18

    self.all_commands = table_keys(self.commands)
    table.sort(self.all_commands)
end

function DebugCommandManager:filter_argument_completion(argument, possible_values)
    if argument == nil then
        return possible_values
    end

    local output = {}
    for i = 1, #possible_values do
        local command = possible_values[i]
        if utf8.sub(argument, 1, #argument) == utf8.sub(command, 1, #argument) then
            table.insert(output, command)
        end
    end
    return output
end

function DebugCommandManager:get_autocomplete(input)
    local function get_autocomplete_unsorted()
        local args = split_str(input, " ", true)
        -- local last_arg_index = #args - 1

        if #args == 0 then
            return self.all_commands
        end

        local last_arg = args[#args]
        local len_args = #args

        if len_args == 1 then
            return self:filter_argument_completion(last_arg, self.all_commands)
        elseif len_args >= 2 then
            local command = self.commands[args[1]]
            if not command then return {} end
            local arg = command.args[len_args - 1] --TODO this won't work with subcommands

            if not arg then return {} end
            if not arg.values then return {} end
            return self:filter_argument_completion(last_arg, arg.values)
        end

        return {}
    end

    local compl = copy_table_shallow(get_autocomplete_unsorted())
    table.sort(compl)
    return compl
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
            return false, "Command " .. command_name .. " doesn't exist"
        end

        local success, err_message = command:run(...)
        return success, err_message
    end

    local success, err_message = run_command(...)
    if not success then
        self:add_message({ color = COL_LIGHT_RED, content = err_message })
    end
end

return DebugCommandManager:new()
