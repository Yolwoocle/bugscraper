require "scripts.meta.constants"

love.graphics.oldShader = function (...) 
	return love.graphics.newShader([[
		vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
			return Texel(texture, textureCoords) * color;
		}
	]])
end

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
	extern vec4 fillColor;

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

shaders.multiply_color = love.graphics.newShader[[
	extern vec4 multColor;
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return Texel(texture, textureCoords) * multColor;
	}
]]

shaders.lighten = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return Texel(texture, textureCoords) * vec4(1.8, 1.8, 1.8, 0.3);
	}
]]

shaders.smoke_shader = love.graphics.newShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		number v = Texel(texture, vec2(textureCoords.x, textureCoords.y+0.02)).a;
		return Texel(texture, textureCoords) * vec4(v, v, v, 1);
	}
]]

shaders.achievement_locked = love.graphics.oldShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		vec4 textureColor = Texel(texture, textureCoords);
		float gray = clamp(dot(textureColor.rgb, vec3(0.2126, 0.7152, 0.0722)), 0.0, 1.0);

		int step = gray * 6.0;
		
		vec3 finalColor = vec3(0.094, 0.078, 0.145);
		if (step >= 1.0) finalColor = vec3(0.149, 0.168, 0.266);
		if (step >= 2.0) finalColor = vec3(0.227, 0.266, 0.400);
		if (step >= 3.0) finalColor = vec3(0.353, 0.412, 0.533);
		if (step >= 4.0) finalColor = vec3(0.545, 0.608, 0.706);
		if (step >= 5.0) finalColor = vec3(0.753, 0.796, 0.863);
		if (step >= 6.0) finalColor = vec3(1.000, 1.000, 1.000);
		
		return vec4(vec3(finalColor), textureColor.a);
	}
]]

-- https://stackoverflow.com/questions/64837705/opengl-blurring
shaders.blur_shader = love.graphics.oldShader[[
	extern float r;

	local xs = 480.0; // texture resolution
	local ys = 270.0; // texture resolution

	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		float x, y, xx, yy, rr = r*r, dx, dy, w, w0;
		w0 = 0.3780 / pow(r,1.975);
		vec2 p;
		vec4 col = vec4(0.0,0.0,0.0,0.0);
		for (dx=1.0/xs,x=-r, p.x = (textureCoords.x)+(x*dx);x<=r;x++,p.x+=dx){ 
			xx=x*x;
			for (dy=1.0/ys, y=-r, p.y = (textureCoords.y)+(y*dy); y<=r; y++, p.y += dy){ 
				yy=y*y;
				if (xx+yy<=rr){
					w = w0 * exp((-xx-yy)/(2.0*rr));
					col += Texel(texture, p) * w;
				}
			}
		}
		return col;
			
	}
]]

shaders.dither = love.graphics.oldShader([[
    vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
		float m = mod(floor(screenCoords.x) + floor(screenCoords.y), 2.0);
		if (m < 1) {
			return Texel(texture, textureCoords) * color;
		} else {
			return vec4(1, 1, 1, 0);
		}
    }
]])

return shaders
