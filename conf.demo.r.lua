require "bugscraper_config"

function love.conf(t)
    t.identity = "bugscraper"
    t.version = "11.5"
    
    t.window.title = "Bugscraper Demo - v"..BUGSCRAPER_VERSION
    t.window.icon = "icon.png"
    
    t.usedpiscale = false
    t.window.width = 480*2
    t.window.height = 270*2
end