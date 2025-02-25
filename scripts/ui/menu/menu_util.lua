local menu_util = {}

menu_util.DEFAULT_MENU_BG_COLOR = {38/255, 43/255, 68/255, 0.8}

menu_util.empty_func = function() end

function menu_util.func_set_menu(menu)
    return function()
        game.menu_manager:set_menu(menu)
    end
end

function menu_util.func_url(url)
    return function()
        love.system.openURL(url)
    end
end

menu_util.PROMPTS_NORMAL = {
    { { "ui_select" }, "input.prompts.ui_select" },
    { { "ui_back" },   "input.prompts.ui_back" },
}

menu_util.PROMPTS_GAME_OVER = {
    { { "ui_select" }, "input.prompts.ui_select" },
    {},
}

menu_util.PROMPTS_CONTROLS = {
    { { "ui_select" }, "input.prompts.ui_select" },
    { { "ui_back" },   "input.prompts.ui_back" },
}

function menu_util.draw_elevator_progress()
    local pad_x = 40
    local pad_y = 50
    local x1, y1 = CANVAS_WIDTH - pad_x, pad_y
    local x2, y2 = CANVAS_WIDTH - pad_x, CANVAS_HEIGHT - pad_y

    local end_w = 5
    love.graphics.rectangle("fill", x1 - end_w / 2, y1 - end_w, end_w, end_w)
    love.graphics.rectangle("fill", x2 - end_w / 2, y2, end_w, end_w)
    love.graphics.line(x1, y1, x2, y2)

    local n_floors = game.level.max_floor
    local sep_w = 3
    local h = y2 - y1
    for i = 1, n_floors - 1 do
        local y = y2 - (i / n_floors) * h
        local sep_x = x1 - sep_w / 2
        local sep_y = round(y - sep_w / 2)
        if i % 10 == 0 then
            love.graphics.rectangle("fill", sep_x, sep_y, sep_w, sep_w)
        end
        if i == game:get_floor() then
            love.graphics.rectangle("line", sep_x - 2, sep_y - 1, sep_w + 3, sep_w + 3)
        end
    end

    local text = concat(game:get_floor(), "/", game.level.max_floor)
    local text_y = clamp(y2 - (game:get_floor() / n_floors) * h, y1, y2)
    love.graphics.flrprint(text, x1 - get_text_width(text) - 5, text_y - get_text_height(text) / 2 - 2)
end

return menu_util