require "scripts.meta.constants"

love.graphics.oldShader = function(...)
    return {sendColor = function(...) end, send = function(...) end, }
end
love.graphics.setShader = function(...)
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
	// Configuration de la précision (obligatoire en OpenGL ES pour les floats)
	precision mediump float;

	// Les entrées (passées par le programme CPU)
	uniform vec4 fillColor;      // Ta couleur personnalisée
	uniform sampler2D u_texture; // L'image (équivalent de Image/texture)

	// Les données venant du Vertex Shader
	varying vec2 v_texCoords;    // Équivalent de textureCoords
	varying vec4 v_color;        // Équivalent de color (souvent la couleur des sommets)

	void main() {
		// Texel() devient texture2D() en ES 2.0 ou texture() en ES 3.0
		vec4 texColor = texture2D(u_texture, v_texCoords);
		
		// On construit le vecteur final : RGB de fillColor + Alpha de la texture
		vec4 finalColor = vec4(fillColor.rgb, texColor.a) * v_color;
		
		// En OpenGL ES, on ne "return" pas, on écrit dans gl_FragColor
		gl_FragColor = finalColor;
	}
	uniform vec4 fillColor;

	// vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
	// 	return vec4(fillColor.r, fillColor.g, fillColor.b, Texel(texture, textureCoords).a) * color;
	// }
]])

--------

shaders.white_shader = love.graphics.oldShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return vec4(1, 1, 1, Texel(texture, textureCoords).a);
	}
]]

shaders.dark_blue_shader = love.graphics.oldShader(string.format([[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return vec4(%f, %f, %f, Texel(texture, textureCoords).a);
	}
]], COL_BLACK_BLUE[1]/255, COL_BLACK_BLUE[2]/255, COL_BLACK_BLUE[3]/255))

shaders.multiply_color = love.graphics.oldShader[[
	uniform vec4 multColor;
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return Texel(texture, textureCoords) * multColor;
	}
]]

shaders.lighten = love.graphics.oldShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		return Texel(texture, textureCoords) * vec4(1.8, 1.8, 1.8, 0.3);
	}
]]

shaders.smoke_shader = love.graphics.oldShader[[
	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		number v = Texel(texture, vec2(textureCoords.x, textureCoords.y+0.02)).a;
		return Texel(texture, textureCoords) * vec4(v, v, v, 1);
	}
]]

shaders.achievement_locked = love.graphics.oldShader[[
	uniform float uDarkenFactor = 0.7;

	vec4 effect(vec4 color, Image texture, vec2 textureCoords, vec2 screenCoords){
		vec3 palette[7];
		palette[0] = vec3(0.094, 0.078, 0.145); // #181425 (Darkest)
		palette[1] = vec3(0.149, 0.168, 0.266); // #262b44
		palette[2] = vec3(0.227, 0.266, 0.400); // #3a4466
		palette[3] = vec3(0.353, 0.412, 0.533); // #5a6988
		palette[4] = vec3(0.545, 0.608, 0.706); // #8b9bb4
		palette[5] = vec3(0.753, 0.796, 0.863); // #c0cbdc
		palette[6] = vec3(1.000, 1.000, 1.000); // #ffffff (Brightest)

		vec4 textureColor = Texel(texture, textureCoords);
		float gray = clamp(dot(textureColor.rgb, vec3(0.2126, 0.7152, 0.0722)), 0.0, 1.0);

		int step = int(gray * 6.0);
		vec3 finalColor = palette[step];
		
		return vec4(vec3(finalColor), textureColor.a);
	}
]]

-- https://stackoverflow.com/questions/64837705/opengl-blurring
shaders.blur_shader = love.graphics.oldShader[[
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
