local Cutscene      = require "scripts.game.cutscene"
local CutsceneScene = require "scripts.game.cutscene_scene"
local Light         = require "scripts.graphics.light"
local Rect          = require "scripts.math.rect"
local images        = require "data.images"
local guns          = require "data.guns"

return Cutscene:new("credits", {
    --[[
    CutsceneScene:new({
        description = "Start",

        duration = 0,
        enter = function(cutscene, data)
            game.game_ui:start_iris_transition(0, 0, 0, 0, 0)
        end,
    }),
    CutsceneScene:new({
        description = "Iris",

        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui:start_iris_transition(380, 220, 0.5, 0, 64)
        end,
    }),
    CutsceneScene:new({
        description = "Wait",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),
    CutsceneScene:new({
        description = "Iris",

        duration = 1.0,
        enter = function(cutscene, data)
            game.game_ui:start_iris_transition(380, 220, 1.0, 64, CANVAS_WIDTH)
        end,
        exit = function(cutscene, data)
            game.game_ui:set_iris(false)
        end
    }),
    CutsceneScene:new({
        description = "Wait",

        duration = 1.0,
        enter = function(cutscene, data)
        end,
    }),
    
    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("{menu.credits.ninesliced_presents}", "", "", 0.5, 5.0, 0.5)
        end,
    }),
    
    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("{menu.credits.leo_bernard}", "Yolwoocle", "{menu.credits.game_by}", 0.5, 5.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("Alexandre Mercier", "OLX", "{menu.credits.music}", 0.5, 5.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title("Martin Domergue", "Verbaudet", "{menu.credits.sound_design}", 0.5, 5.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Noam Goldfarb (Sslime7)",
                "Colin Roullé (OHX)",
            }, "", "{menu.credits.additional_art}", 0.5, 5.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Jakub Piłasiewicz",
                "Nicole Sanches (rhysuki)",
                "Alejandro Alzate Sánchez",
                "Polyglot Project"
            }, "", "{menu.credits.localization}", 0.5, 5.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "LinkyLorelei",
            }, "", "{menu.credits.trailer}", 0.5, 5.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "AnnaWorldEater",
                "Azuras03 (NicolasYT)",
                "Binary Sunrise",
                "Corentin Vaillant",
                "Guillaume Tran",
                "hades140701",
            }, "", "{menu.credits.playtesting}", 0.5, 5.0, 0.5)
        end,
    }),
    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Lars Loe (MadByte)",
                "Lucas Froehlinger 😎",
                "NerdOfGamers + partner",
                "Sylvain Fraresso",
                "Tom Le Ber",
                "{menu.credits.more}",
            }, "", "{menu.credits.playtesting}", 0.5, 5.0, 0.5)
        end,
    }),
    --]]

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            -- game.game_ui:start_title({
            --     Text:text("menu.credits.x_by_y", "'Graphs'", "Sslime7"),
            --     Text:text("menu.credits.x_by_y", "'Hot dogs'", "Alexis Belmonte"),
            --     Text:text("menu.credits.x_by_y", "'Mio rotate'", "Corentin Vaillant"),
            --     Text:text("menu.credits.x_by_y", "'Mio explode'", "Corentin Vaillant"),
            --     Text:text("menu.credits.x_by_y", "'Bugs With Guns'", "Yolwoocle"),
            --     Text:text("menu.credits.x_by_y", "'Löve, Öbey'", "ellraiser"),
            --     Text:text("menu.credits.x_by_y", "'Need your duck taped?'", "Joseph (Jedi)"),  
            --     Text:text("menu.credits.x_by_y", "'Starbugs Green Tea'", "Goyome"),
            --     Text:text("menu.credits.x_by_y", "'Binarion'", "Hector SK  (Nextop Games)"),    
            --     Text:text("menu.credits.x_by_y", "'Injured? Good'", "Hector SK  (Nextop Games)"),
            --     Text:text("menu.credits.x_by_y", "'Snail Ball Run'", "Hector SK  (Nextop Games)"),
            --     Text:text("menu.credits.x_by_y", "'Bluescreen'", "Hector SK  (Nextop Games)"),
            --     Text:text("menu.credits.x_by_y", "'Bluescreen (2)'", "418cat"),
            --     Text:text("menu.credits.x_by_y", "'No queen?'", "Behck"),
            --     Text:text("menu.credits.x_by_y", "'Splat'", "Sarcose"),
            --     Text:text("menu.credits.x_by_y", "'End toastal abuse'", "Clem"),
            --     Text:text("menu.credits.x_by_y", "'A-salt rifle'", "Clem"),
            --     Text:text("menu.credits.x_by_y", "'Beatleblock'", "Dimitri Sophinos (DPS2004)"),  
            --     Text:text("menu.credits.x_by_y", "'Bugscrapers aren't enough'", "pkhead"),
            --     Text:text("menu.credits.x_by_y", "'Optical Studio'", "pkhead"),
            --     Text:text("menu.credits.x_by_y", "'Soon (TM)'", "pixelbath"),
            --     Text:text("menu.credits.x_by_y", "'You are a bug'", "kiwisky"),
            -- }, "", "{menu.credits.playtesting}", 0.5, 5.0, 0.5)
            game.game_ui:start_title_tv({
                "slide_001",
                "slide_002",
                "slide_003",
                "slide_004",
                "slide_005",
                "slide_006",
                "slide_007",
                "slide_008",
            }, 0.5, 5.0, 0.5)
        end,
    }),

    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Alexis Belmonte",
                "Axel 'Vlad' Born",
                "Bettina Delaveaud",
                "Corentin Vaillant",
                "Fabien Delpiano",
                "Feishiko",
                "Gaspard Delpiano-Manfrini",
                "Guillaume Tran",
                "Herweins",
            }, "", "{menu.credits.special_thanks}", 0.5, 7.0, 0.5)
        end,
    }),
    
    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Indie Game Lyon",
                "Jan Willem Nijman",
                "Kaïs",
                "Léo Lanteri Thauvin",
                "Louie Chapman",
                "LÖVE contributors",
                "LÖVE Discord members",
                "Maman & Papa ❤",
                "Noba",
            }, "", "{menu.credits.special_thanks}", 0.5, 7.0, 0.5)
        end,
    }),
    
    CutsceneScene:new({
        description = "",

        duration = 6.0,
        enter = function(cutscene, data)
            game.game_ui:start_title({
                "Nolan Carlisi",
                "oat_addict",
                "Quentin Picault",
                "Raphytator",
                "Solluco",
                "Tahina Dombrowski",
                "Théodore Billotte",
                "Toulouse Game Dev",
            }, "", "{menu.credits.special_thanks}", 0.5, 7.0, 0.5)
        end,
    }),
})
