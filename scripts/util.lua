local utf8 = require "utf8"
require "scripts.meta.constants"
local shaders = require "data.shaders"

abs = math.abs
exp = math.exp
max = math.max
min = math.min
floor = math.floor
ceil = math.ceil
cos = math.cos
sin = math.sin
tan = math.tan
atan2 = math.atan2
sqrt = math.sqrt

gfx = love.graphics

pi = math.pi
pi2 = 2*math.pi
inf = math.huge

-- scotch 
local old_print = love.graphics.print
function love.graphics.print(text, x, y, ...)
	return old_print(text, math.floor(x), math.floor(y), ...)
end

-- scotch: gigantic hack for love.js canvas compatibility
-- https://github.com/Davidobot/love.js/issues/92
local old_newCanvas = love.graphics.newCanvas
function love.graphics.newCanvas(width, height, settings)
	settings = settings or {}

    if not settings.format then
        -- Fallback chain for supported image formats
        local supportedCanvasFormats = love.graphics.getCanvasFormats()
        local fallbackChain = {
            -- It's possible to include other formats if necessary, as long as they have 4 components: 
            -- https://love2d.org/wiki/PixelFormat
            -- I don't know much about the specifics of these formats, please adapt to what works best for you.  
            -- Note that this does not take into account if `t.gammacorrect = true` is set in `love.conf`, please implement it yourself if needed.
            "rgba8",
            "srgba8",
            "rgb10a2",
            "rgb5a1",
            "rgba4",
            "normal"
        }
        local format = fallbackChain[1]
        local i = 1
        while i <= #fallbackChain and not supportedCanvasFormats[format] do
            i = i + 1
            format = fallbackChain[i]
        end
        if i == #fallbackChain + 1 then
            error("No valid canvas format is supported by the system")
        end

        settings.format = format
    end

	return old_newCanvas(width, height, settings)
end

function param(value, def_value)
	if value == nil then
		return def_value
	end
	return value
end

function mod_plus_1(val, mod)
	-- i hate lua
	return ((val-1) % mod)+1
end

function normalize_vect(x, y)
	if x==0 and y==0 then  return 1,0  end
	local d = sqrt(x*x + y*y)
	return x/d, y/d
end
normalise_vect = normalize_vect

function vector_dot(ax, ay, bx, by)
	return ax*bx + ay*by
end

function bounce_vector_cardinal(incoming_x, incoming_y, normal_x, normal_y)
	-- thanks to https://gamedev.stackexchange.com/questions/23672/determine-resulting-angle-of-wall-collision
	-- If n is a normalized vector, and v is the incoming direction, then what you want is −(2(n · v) n − v)
	if normal_x ~= 0 then    return sign(normal_x) * abs(incoming_x), incoming_y    end
	if normal_y ~= 0 then    return incoming_x, sign(normal_y) * abs(incoming_y)    end
end

function bounce_vector(incoming_x, incoming_y, normal_x, normal_y)
	-- thanks to https://math.stackexchange.com/questions/13261/how-to-get-a-reflection-vector
	-- r = d−2(d⋅n)n
	local dot = vector_dot(incoming_x, incoming_y, normal_x, normal_y)
	local vx, vy = 2*dot*normal_x, 2*dot*normal_y 	
	return incoming_x - vx, incoming_y - vy
end


function color(hex)
	-- thanks to chatgpt :saluting_face:
	if not hex then  return {1, 1, 1}  end
	assert(type(hex) == "number", "incorrect type for 'hex' ("..type(hex).."), argument given should be number")

	local r = math.floor(hex / 65536) % 256
	local g = math.floor(hex / 256) % 256 
	local b = hex % 256
	return {r/255, g/255, b/255, 1.0}
end

function round(num, num_dec)
	-- http://lua-users.org/wiki/SimpleRound
	local mult = 10^(num_dec or 0)
	return math.floor(num * mult + 0.5) / mult
end


function round_if_near_zero(val, thr)
	thr = thr or 0.1
	if math.abs(val) < thr then
		return 0
	end
	return thr
end

function is_point_in_rect(px, py, rect)
	return (rect.ax <= px and px <= rect.bx) and (rect.ay <= py and py <= rect.by)
end

-- function copy_table(tab)
-- 	local newtab = {}
-- 	for k,v in pairs(tab) do
-- 		newtab[k] = v
-- 	end
-- 	return newtab
-- end

function copy_table(orig)
	-- http://lua-users.org/wiki/CopyTable
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[copy_table(orig_key)] = copy_table(orig_value)
        end
        setmetatable(copy, copy_table(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function duplicate_table(tab, n)
	local ntab = {}
	-- assert(type(n) == "number", "duplicate_table argument 'n' must be a number, not "..type(n))

	for i=1, n do
		table.insert(ntab, tab)
	end
	return ntab
end	

function is_in_table(tab, val)
	for _,v in pairs(tab) do
		if val == v then
			return true
		end
	end
	return false
end

function append_table(tab1,tab2)
	for i,v in pairs(tab2) do
		table.insert(tab1,v)
	end
	return tab1
end

function table.clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function shuffle_table(t, rng)
	--Fisher–Yates shuffle: https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
	for i=#t, 1, -1 do
		local j 
		if rng then
			j = rng:random(i)
		else
			j = love.math.random(i)
		end
		t[j], t[i] = t[i], t[j]
	end
end


function is_between(v, a, b)
	return a <= v and v <= b
end

function lighten_color(col, v)
	local ncol = {}
	for i,ch in pairs(col) do
		table.insert(ncol, ch+v)
	end
	return ncol
end

function rgb(r,g,b)
	return {r/255, g/255, b/255, 1}
end

function ternary(cond, t, f)
	if cond then return t end
	return f
end

function exec_on_canvas(canvas, func)
	local old_canvas = love.graphics.getCanvas()
	love.graphics.setCanvas(canvas)
	func()
	love.graphics.setCanvas(old_canvas)
end

function exec_with_color(col, func) 
	local old_col = {love.graphics.getColor()}
	love.graphics.setColor(col)
	func()
	love.graphics.setColor(old_col)
end

function rect_color_centered(col, mode, x, y, w, h)
	rect_color(col, mode, x - w/2, y - h/2, w, h)
end

function draw_with_selected_outline(spr, x, y, r, sx, sy)
	love.graphics.setShader(shaders.draw_in_highlight_color)
	local offset = 1

	love.graphics.draw(spr, x, y, r, sx, sy, offset , 0)
	love.graphics.draw(spr, x, y, r, sx, sy, -offset, 0)
	love.graphics.draw(spr, x, y, r, sx, sy, 0,       offset)
	love.graphics.draw(spr, x, y, r, sx, sy, 0,      -offset)

	love.graphics.draw(spr, x, y, r, sx, sy, offset , offset)
	love.graphics.draw(spr, x, y, r, sx, sy,-offset , offset)
	love.graphics.draw(spr, x, y, r, sx, sy, offset ,-offset)
	love.graphics.draw(spr, x, y, r, sx, sy,-offset ,-offset)
	
	love.graphics.setShader()
	love.graphics.draw(spr, x, y, r, sx, sy)
end

function draw_with_outline(outline_color, outline_type, spr, x, y, r, sx, sy, ox, oy)
	outline_type = outline_type or "round"
	ox = ox or 0
	oy = oy or 0

	exec_with_color(COL_WHITE, function()
		shaders.draw_in_color:sendColor("fillColor", outline_color)
		love.graphics.setShader(shaders.draw_in_color)
		local offset = 1
	
		love.graphics.draw(spr, x, y, r, sx, sy, ox+offset, oy)
		love.graphics.draw(spr, x, y, r, sx, sy, ox-offset, oy)
		love.graphics.draw(spr, x, y, r, sx, sy, ox,       oy+offset)
		love.graphics.draw(spr, x, y, r, sx, sy, ox,       oy-offset)
	
		if outline_type == "square" then
			love.graphics.draw(spr, x, y, r, sx, sy, ox+offset, oy+offset)
			love.graphics.draw(spr, x, y, r, sx, sy, ox-offset, oy+offset)
			love.graphics.draw(spr, x, y, r, sx, sy, ox+offset, oy-offset)
			love.graphics.draw(spr, x, y, r, sx, sy, ox-offset, oy-offset)
		end
		
		love.graphics.setShader()
		love.graphics.draw(spr, x, y, r, sx, sy, ox, oy)
	end)
end

function draw_centered(spr, x, y, r, sx, sy)
	love.graphics.draw(spr, math.floor(x), math.floor(y), r, sx, sy, math.floor(spr:getWidth()/2), math.floor(spr:getHeight()/2))
end

function draw_centered_text(text, rect_x, rect_y, rect_w, rect_h, rot, sx, sy, font)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local deffont = love.graphics.getFont()
	local font   = font or love.graphics.getFont()
	local text_w = font:getWidth(text)
	local text_h = font:getHeight(text)
	local x = math.floor(rect_x+rect_w/2)
	local y = math.floor(rect_y+rect_h/2)

	love.graphics.setFont(font)
	love.graphics.print(text, x, y, rot, sx, sy, math.floor(text_w/2), math.floor(text_h/2))
	love.graphics.setFont(deffont)
end

function draw_stretched_spr(x1,y1,x2,y2,spr,scale)
	-- Draws a sprite from (x1, y1) to (x2, y2)
	xmidd = x2-x1
	ymidd = y2-y1
	local rota = math.atan2(ymidd,xmidd)
	local dist = dist(x1,y1,x2,y2)
	love.graphics.draw(spr, x1,y1 , rota-pi/2 , scale , dist , spr:getWidth()/2)
end

function print_centered(text, x, y, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_w = font:getWidth(text)
	local text_h = font:getHeight()
	love.graphics.print(text, x-text_w/2, y-text_h/2, rot, sx, sy, ...)
end

function print_ycentered(text, x, y, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_h = font:getHeight()
	love.graphics.print(text, x, y-text_h/2, rot, sx, sy, ...)
end

-- Thanks to steVeRoll: https://www.reddit.com/r/love2d/comments/h84gwo/how_to_make_a_colored_sprite_white/
function draw_white(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	-- drawable, x, y, r, sx, sy, ox, oy, kx, ky
	local old_shader = love.graphics.getShader()
	love.graphics.setShader(shaders.white_shader)
	love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	love.graphics.setShader(old_shader)
end

function exec_using_shader(shader, func)
	local old_shader = love.graphics.getShader()
	love.graphics.setShader(shader)
	func()
	love.graphics.setShader(old_shader)
end

function draw_using_shader(drawable, shader, x, y, r, sx, sy, ox, oy, kx, ky)
	-- drawable, x, y, r, sx, sy, ox, oy, kx, ky
	local old_shader = love.graphics.getShader()
	love.graphics.setShader(shader)
	love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
	love.graphics.setShader(old_shader)
end

function print_centered_outline(col_in, col_out, text, x, y, thick, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_w = font:getWidth(text) * sx
	local text_h = font:getHeight() * sy
	print_outline(col_in, col_out, text, x-text_w/2, y-text_h/2, thick, rot, sx, sy, ...)
end

function print_ycentered_outline(col_in, col_out, text, x, y, thick, rot, sx, sy, ...)
	rot = rot or 0
	sx = sx or 1
	sy = sy or sx
	local font   = love.graphics.getFont()
	local text_h = font:getHeight()
	print_outline(col_in, col_out, text, x, y-text_h/2, thick, rot, sx, sy, ...)
end

function get_text_width(text, font)
	local text = text or ' '
	local font = font or love.graphics.getFont()
	return font:getWidth(text)
end

function get_text_height(text, font)
	local font = font or love.graphics.getFont()
	return font:getHeight(text)
end

function print_justify_right(text, x, y)
	local w = get_text_width(text)
	love.graphics.print(text, x-w, y)
	return x-w, y
end

function concat(...)
	local args = {...}
	for i = 1, #args do
		local val = args[i]
		local val_str = tostring(val)
		if type(val) == "nil" then  
			val_str = "nil"
		-- elseif type(val) == "table" then 
		-- 	val_str = table_to_str(val)
		end

		args[i] = val_str
	end
	return table.concat(args)
end

function concatsep(tab, sep)
	sep = sep or " "
	local s = tostring(tab[1] or "")
	for i=2,#tab do
		s = s..sep..tostring(tab[i])
	end
	return s
end

function concat_keys(tab, sep)
	sep = sep or " "
	local s = ""
	for k,v in pairs(tab) do
		s = s..sep..tostring(k)
	end
	return utf8.sub(s, 2, -1)
end

function bool_to_int(b)
	if b then
		return 1
	end
	return 0
end

--- func desc
---@param b boolean The boolean
---@return direction 1 if b s true, else -1
function bool_to_dir(b)
	if type(b) ~= "boolean" then   return b   end
	if b then    return 1    end
	return -1
end

function clamp(val, lower, upper)
	assert(val and lower and upper, "One of the clamp values is not defined")
	if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
	return math.max(lower, math.min(upper, val))
end

function sign(n)
	if n < 0 then
		return -1
	end
	return 1
end

function sign0(n)
	if n < 0 then
		return -1
	elseif n == 0 then
		return 0
	end
	return 1
end

function smooth_circle(type, x, y, r, col)
	love.graphics.setColor(col)
	love.graphics.setPointSize(r)
	love.graphics.setPointStyle("smooth")
	love.graphics.points(x,y)
	love.graphics.setColor(1,1,1)
end

function get_rank_color(rank, defcol)
	if rank == 1 then
		return rgb(255,206,33)
	elseif rank == 2 then
		return rgb(120,163,193)
	elseif rank == 3 then
		return rgb(218,75,29)
	else
		return defcol
	end
end

function split_str(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function print_debug(...)
	print(concat("[DEBUG] ", concatsep({...}, " ")))
end

--- func desc
---@param node table
---@return string
function table_to_str(node)
	if node == nil then
		return "[nil]"
	end
	if type(node) ~= "table" then
		return "[print_table: not a table]"
	end

	-- https://www.grepper.com/answers/167958/print+table+lua?ucard=1
	local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    return (output_str)
end

function print_table(node)
	print(table_to_str(node))
end


function table_2d(w,h,val)
	local t = {}
	for i=1,h do
		t[i] = {}
		for j=1,w do
			t[i][j] = val
		end
	end
	return t
end

function table_2d_0(w,h,val)
	local t = {}
	for i=0,h-1 do
		t[i] = {}
		for j=0,w-1 do
			t[i][j] = val
		end
	end
	return t
end

function strtobool(str)
	return str ~= "false" -- Anything other than "false" returns as true
end

--- Returns a number in the range ]-n, n[. (-n and n excluded)
---@param n any
function random_neighbor(n)
	return love.math.random()*2*n - n
end

--- Returns an INTEGER between in the range [a, b[. (a included, b excluded)
---@param a number
---@param b number
function random_range_int(a, b)
	return love.math.random(a, b)
end

--- Returns a FLOAT between in the range [a, b[. (a included, b excluded)
---@param a number
---@param b number
function random_range(a,b)
	return love.math.random()*(b-a) + a
end

--- Returns a random element of the given table.
---@param t table
function random_sample(t)
	return t[love.math.random(1,#t)]
end

function random_str(a, b)
	return tostring(love.math.random(a,b))
end

--- Selects a random element from a weighted list.
--- 
--- This function takes a list of elements where each element is a table containing a value and its corresponding weight.
--- It returns a randomly selected element based on its weight, using the provided random number generator (RNG) if given,
--- otherwise using the default RNG.
---
--- @param li table A list of tables where each table contains two elements: the value and its weight (e.g., {{value1, weight1}, {value2, weight2}, ...}).
--- @param rng? userdata (optional) A random number generator object. If not provided, the default random number generator is used.
--- 
--- @return any, table, number value The randomly selected value, the selected table, and the index of the selected element in the original list.
--- 
--- @raise If the random selection is out of range, an assertion error is raised.
--- 
--- @example
--- ```
--- local li = {{'a', 10}, {'b', 30}, {'c', 60}}
--- local value, element, index = random_weighted(li)
--- print(value)  -- might print 'a', 'b', or 'c' based on their weights
--- print(element)  -- prints the selected table, e.g., {'b', 30}
--- print(index)  -- prints the index of the selected element, e.g., 2
--- ```
function random_weighted(li, rng)
	local sum_w = 0
	for _,e in ipairs(li) do
		sum_w = sum_w + e[2]
	end

	local rnd 
	if rng then 
		rnd = rng:random(0, sum_w-1)
	else 
		rnd = love.math.random(0, sum_w-1)
	end
	
	for i=1, #li do
		if rnd < li[i][2] then
			return li[i][1], li[i], i
		end
		rnd = rnd - li[i][2]
	end
	assert("Random_weighted out of range. This is NOT supposed to happen: something has definitely gone wrong and your code sucks!")
end

function random_polar(rad)
	local rnd_ang = love.math.random() * pi2
	local rnd_rad = love.math.random() * rad
	local x = math.cos(rnd_ang) * rnd_rad
	local y = math.sin(rnd_ang) * rnd_rad
	return x, y
end

--[[
function utf8.sub(str, i, j)
	local offseti = utf8.offset(str, i or 1)
	local offsetj = utf8.offset(str, j+1 or 0)-1
	if offseti and (offsetj or not j) then
		return str:sub(offseti, j and offsetj)
	end
	return str
end
function utf8.sub(str, i, j)
	if utf8.len(str) == 0 then  return ""  end
  local ii = utf8.offset(str, i)
  local jj = utf8.offset(str, j)-1
	return string.sub(str, ii, jj)
end

function utf8.sub(str, i, j)
	str = str or ""
	str = tostring(str)
	i = i or 1
	j = j or 1
	--if i < 0 then   i = uft8.len(str)-i+1   end
	--if j < 0 then   j = uft8.len(str)-j+1   end
	local len = utf8.len(str)
	if i > len then   i = len   end
	if j > len then   j = len   end
	if utf8.len(str) == 0 then  return ""  end
	print(str,i, j, len)
	local ii = utf8.offset(str, i)
  local jj = utf8.offset(str, j)+1
	return string.sub(ii, jj)
end
--]]

-- Thanks to "index five" on Discord
local utf8pos, utf8len = utf8.offset, utf8.len
local sub = string.sub
local max, min = math.max, math.min

function posrelat(pos, len)
	if pos >= 0 then return pos end
	if -pos > len then return 0 end
	return pos + len + 1
end

function utf8.sub(str, i, j)
	local len = utf8len(str)
	i, j = max(posrelat(i, len), 1), j and min(posrelat(j, len), len) or len
	if i <= j  then
		return sub(str, utf8pos(str, i), utf8pos(str, j + 1) - 1)
	end
	return ""
end


function print_color(col, text, x, y, r, s)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.print(text, x, y, r, s, s)
	love.graphics.setColor(1,1,1,1)
end

function print_outline(col_in, col_out, text, x, y, radius, r, s)
	col_in = param(col_in, COL_WHITE)
	col_out = param(col_out, COL_BLACK_BLUE)
	radius = param(radius, 1)
	r = param(r, 0)
	s = param(s, 1)

	for ix=-radius, radius do
		for iy=-radius, radius do
			if not (ix == 0 and iy == 0) then 
				print_color(col_out, text, x+ix, y+iy, r, s)
			end
		end
	end
	print_color(col_in, text, x, y, r, s)
end

function print_label(text, x, y, col_txt, col_label)
	col_txt, col_label = COL_WHITE or col_txt, {0,0,0,0.5} or col_label 
	local w = get_text_width(text)
	local h = get_text_height(text)
	rect_color(col_label, "fill", x, y, w, h)
	print_color(col_txt, text, x, y)
end

function exec_color(col, func, ...)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	func(...)
	love.graphics.setColor(1,1,1,1)
end

function rect_color(col, mode, x, y, w, h, ...)
	assert(col, "color not defined")
	assert(mode, "rect mode not defined ('line' or 'fill')")
	assert(x, "rect x not defined")
	assert(y, "rect y not defined")
	assert(w, "rect width not defined")
	assert(h, "rect height not defined")
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.rectangle(mode, floor(x)+0.5, floor(y)+0.5, floor(w), floor(h), ...)
	love.graphics.setColor(1,1,1,1)
end

function circle_color(col, mode, x, y, r)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.circle(mode, floor(x)+0.5, floor(y)+0.5, r)
	love.graphics.setColor(1,1,1,1)
end

function line_color(col, ax, ay, bx, by, ...)
	col = col or {1,1,1,1}
	love.graphics.setColor(col)
	love.graphics.line(floor(ax), floor(ay), floor(bx), floor(by), ...)
	love.graphics.setColor(1,1,1,1)
end

function arrow_color_radial(col, x, y, a, r)
	arrow_color_relative(col, x, y, math.cos(a) * r, math.sin(a) * r)
end

function arrow_color_relative(col, x, y, dx, dy)
	arrow_color(col, x, y, x + dx, y + dy)
end

function arrow_color(col, ax, ay, bx, by)
	line_color(col, ax, ay, bx, by)
	local a = atan2(by - ay, bx - ax)
	local a_arrow1 = a + pi + pi/4
	local a_arrow2 = a + pi - pi/4
	local r = 4
	line_color(col, bx, by, bx + math.cos(a_arrow1)*r, by + math.sin(a_arrow1)*r)
	line_color(col, bx, by, bx + math.cos(a_arrow2)*r, by + math.sin(a_arrow2)*r)
end

function noise(...)
	local v = love.math.noise(...)
	return v*2 - 1
end

function noise01(...)
	local v = love.math.noise(...)
	return v
end

function sqr(a)
	return a*a
end

function distsqr(ax, ay, bx, by)
	bx = bx or 0
	by = by or 0
	return sqr(bx - ax) + sqr(by - ay)
end

function dist(ax, ay, bx, by)
	return sqrt(distsqr(ax, ay, bx, by))
end

function actor_distance(actor1, actor2)
	return dist(actor1.x, actor1.y, actor2.x, actor2.y)
end

function actor_mid_distance(actor1, actor2)
	return dist(actor1.mid_x, actor1.mid_y, actor2.mid_x, actor2.mid_y)
end

function cerp(a,b,t)
	-- "constant" interpolation?
	-- 2024 leo here: wtf is this shit
	if math.abs(a-b) <= t then
		return b
	end
	return a + sign0(b-a)*t
end

function move_toward(from, to, delta)
    if math.abs(to - from) <= delta then
        return to
    end
	return from + sign(to - from) * delta
end

function move_toward_color(a, b, t)
	local c = {
		move_toward(a[1], b[1], t),
		move_toward(a[2], b[2], t),
		move_toward(a[3], b[3], t),
		move_toward(a[4] or 1, b[4] or 1, t),
	}
	return c
end

function move_toward_color_radial(a, b, t)
	a[4] = a[4] or 1
	b[4] = b[4] or 1
	local a_hsv = rgb_to_hsv(unpack(a))
	local b_hsv = rgb_to_hsv(unpack(b))
	return hsv_to_rgb(
		move_toward_angle(a_hsv[1]*pi2, b_hsv[1]*pi2, t) / pi2,
		move_toward(a_hsv[2], b_hsv[2], t),
		move_toward(a_hsv[3], b_hsv[3], t),
		move_toward(a_hsv[4], b_hsv[4], t)
	)
end

function move_toward_angle(a, b, t)
	local epsilon = 0.01
	a = a % (math.pi*2)
	b = b % (math.pi*2)
	if math.abs(b - a) <= t then
		return b
	else
		return a + sign0(shortest_angle_dist(a, b))*t
	end
end

function lerp(a,b,t)
	return a + (b - a) * t
end

function lerp_color(a,b,t)
	local c = {
		lerp(a[1], b[1], t),
		lerp(a[2], b[2], t),
		lerp(a[3], b[3], t),
		lerp(a[4] or 1, b[4] or 1, t),
	}
	return c
end

function lerp_color_radial(a,b,t)
	a[4] = a[4] or 1
	b[4] = b[4] or 1
	local a_hsv = rgb_to_hsv(unpack(a))
	local b_hsv = rgb_to_hsv(unpack(b))
	return hsv_to_rgb(
		lerp_angle(a_hsv[1]*pi2, b_hsv[1]*pi2, t)/pi2,
		lerp      (a_hsv[2], b_hsv[2], t),
		lerp      (a_hsv[3], b_hsv[3], t),
		lerp      (a_hsv[4], b_hsv[4], t)
	)
end

-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--[[
   * Converts an RGB color value to HSV. Conversion formula
   * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
   * Assumes r, g, and b are contained in the set [0, 1] and
   * returns h, s, and v in the set [0, 1].
   *
   * @param   Number  r       The red color value
   * @param   Number  g       The green color value
   * @param   Number  b       The blue color value
   * @return  Array           The HSV representation
]]
function rgb_to_hsv(r, g, b, a)
    local max_, min_ = math.max(r, g, b), math.min(r, g, b)
    local h, s, v
    v = max_
  
    local d = max_ - min_
    if max_ == 0 then s = 0 else s = d / max_ end
  
    if max_ == min_ then
		h = 0 -- achromatic
    else
		if max_ == r then
		h = (g - b) / d
		if g < b then h = h + 6 end
		elseif max_ == g then h = (b - r) / d + 2
		elseif max_ == b then h = (r - g) / d + 4
		end
		h = h / 6
    end
  
    return {h, s, v, a}
end
  
-- http://axonflux.com/handy-rgb-to-hsl-and-rgb-to-hsv-color-model-c
--[[
   * Converts an HSV color value to RGB. Conversion formula
   * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
   * Assumes h, s, and v are contained in the set [0, 1] and
   * returns r, g, and b in the set [0, 1].
   *
   * @param   Number  h       The hue
   * @param   Number  s       The saturation
   * @param   Number  v       The value
   * @return  Array           The RGB representation
]]
function hsv_to_rgb(h, s, v, a)
	local r, g, b

	local i = math.floor(h * 6);
	local f = h * 6 - i;
	local p = v * (1 - s);
	local q = v * (1 - f * s);
	local t = v * (1 - (1 - f) * s);

	i = i % 6

	if i == 0 then r, g, b = v, t, p
	elseif i == 1 then r, g, b = q, v, p
	elseif i == 2 then r, g, b = p, v, t
	elseif i == 3 then r, g, b = p, q, v
	elseif i == 4 then r, g, b = t, p, v
	elseif i == 5 then r, g, b = v, p, q
	end

	return {r, g, b, a}
end



function wrap_to_pi(a)
	return (a + math.pi) % (math.pi*2) - math.pi
end

function shortest_angle_dist(a, b)
	local max = 2*math.pi
	local diff = (b - a) % max
	return (2*diff) % max - diff
end

function lerp_angle(a, b, t)
	local epsilon = 0.01
	if abs(b - a) > epsilon then
		a = a % (math.pi*2)
		return a + shortest_angle_dist(a, b)*t
	else
		return b
	end
end

function angle_in_range(alpha, lower, upper)
	-- https://stackoverflow.com/questions/66799475/how-to-elegantly-find-if-an-angle-is-between-a-range
	alpha = alpha % pi2
	lower = lower % pi2
	upper = upper % pi2
    return (alpha - lower) % pi2 <= (upper - lower) % pi2
end

function create_actor_centered(actor, x, y, ...)
	local a = actor:new(x, y, ...)
	local nx = floor(a.x - a.w/2)
	local ny = floor(a.y - a.h)
	a:set_pos(nx, ny)
	return a
end

function not_nil(x)
	return x ~= nil
end	

function range_table(a, b)
	local t = {}
	for i=a, b do
		table.insert(t, i)
	end
	return t
end


function time_to_string(time)
	local secs = round(time%60, 1)
	local mins = floor(time/60) % 60
	local hours = floor(time/3600)
	
	if secs == floor(secs) then
		secs = tostring(secs)..".0"	
	end
	local ss = utf8.sub( "00"..tostring(secs), -4, -1 )
	local mm = utf8.sub( "00"..tostring(mins), -2, -1 )
	local hh = utf8.sub( "00"..tostring(hours), -max(#tostring(hours), 2), -1 )
	
	if hours > 0 then 
		return concat(hh,":",mm,":",ss)
	end
	return concat(mm,":",ss)
end


function get_left_vec(x, y)
	return y, -x
end

function get_right_vec(x, y)
	return -y, x
end

function get_orthogonal(x, y, dir)
	dir = dir or 1
	if dir < 0 then
		return get_left_vec(x,y)
	else
		return get_right_vec(x,y)
	end
end

function vec_cross(ax, ay, az, bx, by, bz)
	return ay*bz - az*by, az*bx - ax*bz, ax*by - ay*bx
end

-- https://stackoverflow.com/questions/42892862/how-do-i-find-the-point-at-which-two-line-segments-are-intersecting-in-javascrip
function segment_intersect_point(seg1, seg2)
	local x1, y1, x2, y2 = seg1.ax, seg1.ay, seg1.bx, seg1.by 
	local x3, y3, x4, y4 = seg2.ax, seg2.ay, seg2.bx, seg2.by
    local a_dx = x2 - x1
    local a_dy = y2 - y1
    local b_dx = x4 - x3
    local b_dy = y4 - y3
    local s = (-a_dy * (x1 - x3) + a_dx * (y1 - y3)) / (-b_dx * a_dy + a_dx * b_dy)
    local t = ( b_dx * (y1 - y3) - b_dy * (x1 - x3)) / (-b_dx * a_dy + a_dx * b_dy)
    return ternary(
		(s >= 0 and s <= 1 and t >= 0 and t <= 1),
		{x = x1 + t * a_dx, y = y1 + t * a_dy}, 
		nil
	)
end

-- --- Returns a vector that forms `angle` with the 0° angle and goes from the center of the rect to its appropriate edge. 
-- function get_vector_in_rect_from_angle(angle, rect)
-- 	local center_x = (rect.bx + rect.ax) / 2
-- 	local center_y = (rect.by + rect.ay) / 2
-- 	local w = rect.w
-- 	local h = rect.h
-- 	local r = math.max(w, h)

-- 	local outx, outy = rectclamp(w, h, math.cos(angle)*r, math.sin(angle)*r)
-- 	return center_x, center_y, outx + center_x, outy + center_y
-- end

function clamp_segment_to_rectangle(seg, rect)
	local function segment(ax, ay, bx, by)
		return {
			ax = ax,
			ay = ay,
			bx = bx,
			by = by,
		}
	end

	local rect_edges = {
		segment(rect.ax, rect.ay, rect.bx, rect.ay),
		segment(rect.ax, rect.ay, rect.ax, rect.by),
		segment(rect.bx, rect.ay, rect.bx, rect.by),
		segment(rect.ax, rect.by, rect.bx, rect.by),
	}

	local points = {}
	for _, rect_edge in pairs(rect_edges) do
		local pt = segment_intersect_point(rect_edge, seg)
		if pt then
			table.insert(points, pt)
		end
	end
	
	local p1_in = is_point_in_rect(seg.ax, seg.ay, rect)
	local p2_in = is_point_in_rect(seg.bx, seg.by, rect)
	if p1_in and p2_in then
		return seg.ax, seg.ay, seg.bx, seg.by
	end

	if #points >= 2 then
		-- I don't know in what edge case there would be more than 2 points, but if it happens they're ignored 
		return points[1].x, points[1].y, points[2].x, points[2].y
	elseif #points == 1 then
		if not p1_in and not p2_in then
			return points[1].x, points[1].y, points[1].x, points[1].y
		elseif p1_in then
			return seg.ax, seg.ay, points[1].x, points[1].y
		elseif p2_in then
			return seg.bx, seg.by, points[1].x, points[1].y
		end
	elseif #points == 0 then		 
		return nil

	end
end

--- Returns a vector that forms `angle` with the 0° angle and goes from (x, y) to its appropriate edge. 
function get_vector_in_rect_from_angle(x, y, angle, rect)
	local r = math.max(rect.w, rect.h) + 100
	local function segment(ax, ay, bx, by)
		return {
			ax = ax,
			ay = ay,
			bx = bx,
			by = by,
		}
	end

	local seg = segment(x, y, x + math.cos(angle) * r, y + math.sin(angle) * r)
	return clamp_segment_to_rectangle(seg, rect)
end

-- https://easings.net/#easeOutBack
-- https://www.lexaloffle.com/bbs/?tid=40577

function ease_out_cubic(x)
	return 1 - math.pow(1 - x, 3)
end

function ease_out_back(x)
	local c1 = 1.70158;
	local c3 = c1 + 1;
	
	return 1 + c3 * math.pow(x - 1, 3) + c1 * math.pow(x - 1, 2)
end

function ease_out_elastic(x)
	return 1 - (2^(-10*x))*math.cos(2*x)
end


--- Return true if line segments intersect
--- https://stackoverflow.com/questions/3838329/how-can-i-check-if-two-segments-intersect 
function segment_intersect(seg1, seg2)
	local function ccw(ax, ay, bx, by, cx, cy)
		return (cy - ay) * (bx - ax) > (by - ay) * (cx - ax)
	end
    local bool1 = (ccw(seg1.ax, seg1.ay, seg2.ax, seg2.ay, seg2.bx, seg2.by) ~= ccw(seg1.bx, seg1.by, seg2.ax, seg2.ay, seg2.bx, seg2.by)) 
	local bool2 = (ccw(seg1.ax, seg1.ay, seg1.bx, seg1.by, seg2.ax, seg2.ay) ~= ccw(seg1.ax, seg1.ay, seg1.bx, seg1.by, seg2.bx, seg2.by))
	return bool1 and bool2
end

--- https://stackoverflow.com/questions/20677795/how-do-i-compute-the-intersection-point-of-two-lines
function line_intersection(line1, line2)
    -- xdiff = (line1[0][0] - line1[1][0], line2[0][0] - line2[1][0])
    -- ydiff = (line1[0][1] - line1[1][1], line2[0][1] - line2[1][1])
    local xdiff = {line1.ax - line1.bx, line2.ax - line2.bx}
    local ydiff = {line1.ay - line1.by, line2.ay - line2.by}

    local function det(a, b)
        return a[0] * b[1] - a[1] * b[0]
	end		

    local div = det(xdiff, ydiff)
    if div == 0 then
		return nil
       	-- raise Exception('lines do not intersect')
	end

    local d = {
		det({line1.ax, line1.ay}, {line1.bx, line1.by}), 
		det({line2.ax, line2.ay}, {line2.bx, line2.by})
	}
    local x = det(d, xdiff) / div
    local y = det(d, ydiff) / div
    return x, y
end

function get_direction_vector(ax, ay, bx, by)
	return normalize_vect(bx - ax, by - ay)
end

function get_direction_vector_between_actors(actor1, actor2)
	return normalize_vect(actor2.x - actor1.x, actor2.y - actor1.y)
end

function get_angle_between_actors(actor1, actor2, use_mid)
	if use_mid then
		return math.atan2(actor2.mid_y - actor1.mid_y, actor2.mid_x - actor1.mid_x)
	end 
	return math.atan2(actor2.y - actor1.y, actor2.x - actor1.x)
end

function save_canvas_as_file(canvas, filename, encoding_format)
	local imgdata = canvas:newImageData()
	local imgpng = imgdata:encode("png", filename)

	return imgdata, imgpng
end

function vec_approx_equal(vec1, vec2) 
	local epsilon = 0.00001
	return math.abs(vec1.x - vec2.x) < epsilon and math.abs(vec1.y - vec2.y) < epsilon
end