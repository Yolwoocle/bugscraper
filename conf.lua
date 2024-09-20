require "bugscraper_config"

function love.conf(t)
    t.identity = "bugscraper"
    t.version = "11.5"

    t.window.title = "Bugscraper - v"..BUGSCRAPER_VERSION --TODO add "demo" (in translated languages) if demo build
    t.window.icon = "icon.png"

    t.window.width = 1200
    t.window.height = 800
end