require "bugscraper_config"

function love.conf(t)
    t.identity = "bugscraper"

    t.window.title = "Bugscraper - v"..BUGSCRAPER_VERSION
    t.window.icon = "icon.png"
end