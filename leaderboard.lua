require "util"
local Class = require "class"
local images = require "data.images"
local http = require "socket.http"
local ltn12 = require "ltn12"

local LeaderboardManager = Class:inherit()

function LeaderboardManager:init()
	--
end

function LeaderboardManager:update(dt)
	--
end

function LeaderboardManager:draw()
	--
end

function LeaderboardManager:submit()
    -- if true then return end
    local body = {}

    -- Thanks to https://onelinerhub.com/lua/making-http-post-request 
	local data = "{\"score\": 1000}"
    local res, code, headers, status = http.request {
		method = "POST",
		url = "https://api.lootlocker.io/server/leaderboards/6715/submit",
		source = ltn12.source.string(data),
		headers = {
			["content-type"] = "application/json",
			["content-length"] = tostring(#data)
		},
		sink = ltn12.sink.table(body)
	}

    print(res, code, headers, status)
    local response = table.concat(body)
    print(table_to_str(response))

end

return LeaderboardManager