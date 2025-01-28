require "scripts.util"
local Class = require "scripts.meta.class"
local DebugCommand = require "scripts.debug.debug_command"
local enemies = require "data.enemies"
local utf8 = require 'utf8'
local cutscenes = require 'data.cutscenes'
local upgrades  = require 'data.upgrades'
local skins = require "data.skins"
local skin_name_to_id = require "data.skin_name_to_id"

local a, b = require "scripts.test"
print_debug("a, b", a, b)

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
            print(text)
            return true
        end,
    }

    self.commands["score"] = DebugCommand:new {
        name = "score",
        description = "Grants some amount of score",
        args = {
            { "number:number" },
        },
        run = function(number)
            if not number then
                return false, "Invalid number"
            end
            game.score = game.score + number
            self:add_message(concat("Added ", number, " to the score"))
            return true
        end,
    }

    self.commands["xp"] = DebugCommand:new {
        name = "xp",
        description = "Grants some amount of xp",
        args = {
            { "number:number" },
        },
        run = function(number)
            if not number then
                return false, "Invalid number"
            end
            Metaprogression:add_xp(number)
            self:add_message(concat("Added ", number, " to the xp"))
            return true
        end,
    }

    self.commands["menu"] = DebugCommand:new {
        name = "menu",
        description = "Sets the menu",
        args = {
            { "name:string" }, -- Menu keys can't be set since the menus are loaded at the same time as the debug menu... to fix later
        },
        run = function(name)
            local success, err = game.menu_manager:set_menu(name)
            if not success then
                return false, err
            end
            
            game.menu_manager:set_menu(name)
            self:add_message(concat("Set menu to '", name, "'"))
            return true
        end,
    }

    local skin_names = table_keys(skin_name_to_id)
    self.commands["unlock_skin"] = DebugCommand:new {
        name = "unlock_skin",
        description = "Unlocks a skin",
        args = {
            { "skin_name:string", values = skin_names },
        },
        run = function(skin_name)
            if not skin_name then
                return false, "No skin given"
            end
            local skin_id = skin_name_to_id[skin_name]
            if not skin_id then
                return false, concat("Skin '", skin_name, "' doesn't exit")
            end

            Metaprogression:unlock_skin(skin_id)
            self:add_message(concat("Unlocked skin '", skin_name, "'"))
            return true
        end,
    }

    self.commands["fury"] = DebugCommand:new {
        name = "fury",
        description = "Enables fury",
        args = {
        },
        run = function()
            game.level.fury_bar = game.level.fury_max
            self:add_message(concat("Enabled fury"))
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
    self.commands["_weaken_all"] = DebugCommand:new {
        name = "_weaken_all",
        description = "Sets life of all enemies to 1 HP",
        args = {
        },
        run = function()
            for _, actor in pairs(game.actors) do
                if actor.is_enemy and actor.life then
                    actor.life = 1
                end
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
