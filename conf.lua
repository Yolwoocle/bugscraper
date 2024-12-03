require "bugscraper_config"

function love.conf(t)
    t.identity = "bugscraper"
    t.version = "11.5"

    t.window.title = "Bugscraper - v"..BUGSCRAPER_VERSION --TODO add "demo" (in translated languages) if demo build
    t.window.icon = "icon.png"

    t.window.width = 480*2
    t.window.height = 270*2
end