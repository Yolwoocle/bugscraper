require "scripts.meta.constants"

local shaders = {}

local shader_code = [[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return vec4(%f, %f, %f, Texel(texture, textureCoords).a) * color;
	}
]]
local draw_in_highlight_color = love.graphics.newShader(
    string.format(
        shader_code,
        SELECTED_HIGHLIGHT_COLOR[1], SELECTED_HIGHLIGHT_COLOR[2], SELECTED_HIGHLIGHT_COLOR[3]
    )
)
shaders.draw_in_highlight_color = draw_in_highlight_color

return shaders