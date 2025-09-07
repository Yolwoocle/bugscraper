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

shaders.multiply_color = love.graphics.newShader[[
	uniform vec4 multColor;
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

-- https://stackoverflow.com/questions/64837705/opengl-blurring
shaders.blur_shader = love.graphics.newShader[[
	uniform float xs = 480.0; // texture resolution
	uniform float ys = 270.0; // texture resolution
	uniform float r;
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

shaders.dither = love.graphics.newShader([[
    vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords) {
		float m = mod(floor(screenCoords.x) + floor(screenCoords.y), 2.0);
		if (m < 1) {
			return Texel(texture, textureCoords) * color;
		} else {
			return vec4(1, 1, 1, 0);
		}
    }
]])

-----------------------------------------------------

-- Palette swap, thanks to Keyslam on the LÖVE discord server
local test = [[
uniform float palette_index;
uniform Image palette;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
    vec4 index = Texel(tex, texture_coords);

    if (index.a == 0)
      discard;

    vec4 pixel = Texel(palette, vec2(index.x, palette_index));
    
    return pixel;
}
]]


return shaders