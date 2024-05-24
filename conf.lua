require "bugscraper_config"

function love.conf(t)
    t.identity = "bugscraper"

    t.window.title = "Bugscraper - v"..BUGSCRAPER_VERSION --TODO add "demo" (in translated languages) if demo build
    t.window.icon = "icon.png"
end