local skins = require "data.skins"

local skin_name_to_id = {}
for id, skin_name in pairs(skins) do
	skin_name_to_id[skin_name.text_key] = id
end

return skin_name_to_id