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

--------

shaders.draw_in_color = love.graphics.newShader([[
	uniform vec4 fillColor;
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return vec4(fillColor.r, fillColor.g, fillColor.b, Texel(texture, textureCoords).a) * color;
	}
]])

--------

shaders.white_shader = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return vec4(1, 1, 1, Texel(texture, textureCoords).a);
	}
]]

shaders.dark_blue_shader = love.graphics.newShader(string.format([[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return vec4(%f, %f, %f, Texel(texture, textureCoords).a);
	}
]], COL_BLACK_BLUE[1]/255, COL_BLACK_BLUE[2]/255, COL_BLACK_BLUE[3]/255))

shaders.lighten = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return Texel(texture, textureCoords) * vec4(1.8, 1.8, 1.8, 0.5);
	}
]]

shaders.smoke_shader = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		number v = Texel(texture, vec2(textureCoords.x, textureCoords.y+0.02)).a;
		return Texel(texture, textureCoords) * vec4(v, v, v, 1);
	}
]]

return shaders