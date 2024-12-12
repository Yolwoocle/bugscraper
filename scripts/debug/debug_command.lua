require "scripts.util"
local Class = require "scripts.meta.class"
local enemies = require "data.enemies"

local DebugCommand = Class:inherit()

local supported_types = {
    ["number"] = {
        build = function(input)
            return tonumber(input)
        end, 
        check = function(input)
            return tonumber(input) ~= nil
        end
    },
    ["string"] = {
        build = function(input)
            return input
        end,
        check = function(input)
            return #input > 0
        end
    },
    -- ["enum"] = true,
}

function DebugCommand:init(params)
    assert(params.args ~= nil)
    assert(params.run ~= nil)
    assert(params.name ~= nil)
    params.description = param(params.description, "[Description missing]")
    params.subcommand = param(params.subcommand, nil)

    self.name = params.name
    self.run_arg = params.run
    self.description = params.description
    self.subcommands = params.subcommands

    -- Load arguments
    self.args = {}
    for i, arg in pairs(params.args) do
        assert(#arg >= 1, "No argument name given")

        local name, type = arg[1]:match("([^:]+):([^:]+)")
        assert(name ~= nil, concat("No name given for argument ", i))
        assert(type ~= nil, concat("No name type for argument ", i, " ('", name, "')"))
        assert(supported_types[type] ~= nil, "Invalid type '"..type.."' for argument '"..name.."'")

        self.args[i] = {
            name = name,
            type = type,
            default = arg.default,
            values = arg.values,
        }
        -- TODO sanity check for optional arguments only after mandatory ones
    end
    
    self.signature = self:generate_signature()
end

function DebugCommand:generate_signature()
    local sig = self.name .. " "
    for i, arg in pairs(self.args) do
        local argname = ternary(arg.default ~= nil, "["..arg.name.."]", "<"..arg.name..">")
        sig = sig .. argname .. " "
    end
    return sig
end

function DebugCommand:run(...)
    local input_args = {...}
    for i = 1, #self.args do
        local arg_data = self.args[i]
        local arg_type = arg_data.type

        if input_args[i] == nil then
            input_args[i] = self.args[i].default
        end
        if input_args[i] == nil then
            return false, "No argument given for '"..tostring(self.args[i].name).."'"
        end
        
        if not supported_types[arg_type].check(input_args[i]) then
            return false, "Invalid format for type "..tostring(arg_type)..": '"..tostring(input_args[i]).."'"
        end

        input_args[i] = supported_types[arg_data.type].build(input_args[i])
    end

    local success, err = self.run_arg(unpack(input_args))
    if not success then
        return success, err
    end
    
    if self.subcommands then
        -- TODO subcommands
    end
    return success, err
end

return DebugCommand
