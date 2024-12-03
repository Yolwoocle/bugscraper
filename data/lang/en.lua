return {
    steam = {
        short_desicription = [[
            Welcome to the bugscraper. Rise to the top of this pest-filled tower in this 2D shooter platformer and battle waves of enemies at every floor as they come for your skin (or rather, exoskeleton). 
        ]],
        description = [[
            Welcome to the bugscraper. Here, pests all around the world come to gather. Your mission: stopping them before it is too late!🐜In this platformer shooter, you take the role of Mio, a courageous ant, trying to stop the employees of a bug-filled skyscraper from corrupting the world with a deadly mushroom.🐛You will battle waves of enemies in an elevator as they come for your skin (or rather, exoskeleton) on every floor.🐝Using a wide variety of weapons and upgrades, eliminate them and prepare to battle for the next floor!🐞Play in solo, or with up to 4 friends in local co-op multiplayer.
        ]]
    },
    discord = { -- Text used for Discord rich presence
        state = {
            solo = "Playing solo",
            local_multiplayer = "Local multiplayer",
        },
        details = {
            waiting = "In lobby",
            playing = "In game (floor %d/%d)",
            dying = "Defeated (floor %d/%d)",
            win = "Victory screen",
        },
    },
    game = {
        demo = "DEMO", -- Chip added to the game logo to indicate that this version is a demo
        fps = "%d FPS",
        congratulations = "CONGRATULATIONS!",
        win_thanks = "Thank you for playing the demo",
        win_wishlist = "Wishlist the game on Steam :)", -- "Wishlist" is a verb
        win_prompt = "[Pause to continue]",
        warning_web_controller = "Some browsers may not have proper controller support",

    },
    level = {
        world_prefix = "Department %s", 

        -- World names
        world_1 = "Bug resources",
        world_2 = "Factory",
        world_3 = "Data center",
        world_4 = "Executive",
    },
    gun = {
        -- Gun names
        machinegun = "pea gun",
        triple = "triple pepper",
        burst = "pollen burst",
        shotgun = "raspberry shotgun",
        minigun = "seed minigun",
        ring = "big berry",
        mushroom_cannon = "mushroom cannon",
    },
    player = {
        name = {
            -- Player names
            -- No reason to change these during translation, except if:
            -- - it's more appropriate to use a transliteration, or to use the script of the concerned language 
            -- - they clash with something specific to the language/culture (notify me if it is the case)
            mio = "Mio",
            cap = "Cap",
            zia = "Zia",
            tok = "Tok",
            nel = "Nel",
            rico = "Rico",
            leo = "Leo",
        },
        abbreviation = "P%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    upgrade = {
        tea = {
            title = "Green Tea",
            description = "+2 temporary ❤",
        },
        espresso = {
            title = "Espresso",
            description = "x2 shooting speed for a minute", 
        },
        milk = {
            title = "Milk",
            description = "+1 permanent ❤",
        },
        peanut = {
            title = "Peanut",
            description = "x2 maximum ammo",
        },
        energy_drink = {
            title = "Energy Drink",
            description = "Fury bar decays slower",
        },
        soda = {
            title = "Soda",
            description = "+1 midair jump",
        },
    },
    input = {
        prompts = {
            move = "Move",
            left = "Left",
            right = "Right",
            up = "Up",
            down = "Down",
            jump = "Jump",
            shoot = "Shoot",
            leave_game = "Leave", 

            ui_left = "Menu left",
            ui_right = "Menu right",
            ui_up = "Menu up",
            ui_down = "Menu down",
            ui_select = "Confirm",
            ui_back = "Back",
            pause = "Pause",

            join = "Join",
            split_keyboard = "Split keyboard",
            unsplit_keyboard = "Unsplit keyboard",

            jetpack = "Jetpack",
        },
    },
    menu = {
        see_more = "see more...",
        yes = "YES",
        no = "NO",
        quit = {
            description = "Are you sure you want to quit?"
        },
        pause = {
            title = "PAUSE",
            resume = "RESUME",
            retry = "RETRY",
            options = "OPTIONS",
            credits = "CREDITS",
            feedback = "FEEDBACK",
            quit = "QUIT",
            website = "OFFICIAL WEBSITE",
            discord = "JOIN ON DISCORD",
            twitter = "FOLLOW ON TWITTER (𝕏)", --poop emoji visually shows as the "𝕏" logo in-game
        },
        options = {
            title = "OPTIONS",

            input = {
                title = "Input",
                input = "INPUT SETTINGS...",
            },
            input_submenu = {
                title = "Input settings",
                reset_controls = "RESET CONTROLS",
                controller_button_style = "BUTTON STYLE",
                controller_button_style_value = {
                    detect = "detect",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "JOYSTICK DEADZONE",
                vibration = "VIBRATION",
                low_deadzone_warning = "Low values may cause issues",
                note_deadzone = "Deadzone settings will be applied after leaving this menu",

                gameplay = "Gameplay",
                interface = "Interface",
                global = "Global",
                note_ui_min_button = "At least one binding is required",
                note_global_keyboard = "These bindings are the same for all keyboard players",
                note_global_controller = "These bindings are the same for all controllers",
                subtitle_no_player = "[⚠ NO PLAYER %d]",
                subtitle_no_controller = "[⚠ NO CONTROLLER CONNECTED]",
                no_buttons = "[NO BUTTONS]",
                press_button = "[PRESS BUTTON]",
                press_again_to_remove = "Press an already bound button to remove it",
                
                keyboard = "Keyboard",
                keyboard_solo = "KEYBOARD (Default)",
                keyboard_p1 = "KEYBOARD (Split 1)",
                keyboard_p2 = "KEYBOARD (Split 2)",

                controller = "Controller",
                controller_p1 = "CONTROLLER (Player 1)",
                controller_p2 = "CONTROLLER (Player 2)",
                controller_p3 = "CONTROLLER (Player 3)",
                controller_p4 = "CONTROLLER (Player 4)",
            },
            audio = {
                title = "Audio",
                sound = "SOUND",
                volume = "VOLUME",
                music_volume = "MUSIC VOLUME",
                music_pause_menu = "MUSIC ON PAUSE MENU",
                background_sounds = "BACKGROUND_SOUNDS",
            },
            visuals = {
                title = "Visuals",
                fullscreen = "FULLSCREEN",
                pixel_scale = "PIXEL SCALE",
                pixel_scale_value = {
                    auto = "auto",
                    max_whole = "max whole",
                },
                vsync = "VERTICAL SYNCHRONIZATION",
                menu_blur = "MENU BACKGROUND BLUR",
                background_speed = "BACKGROUND SPEED",
            },
            game = {
                title = "Gameplay",
                timer = "TIMER",
                mouse_visible = "SHOW MOUSE CURSOR",
                pause_on_unfocus = "PAUSE ON LOST FOCUS",
                screenshake = "SCREENSHAKE",
                show_fps_warning = "SHOW LOW FRAMERATE WARNING",

            }
        },
        feedback = {
            title = "FEEDBACK",
            bugs = "REPORT A BUG 🔗",
            features = "SUGGEST A FEATURE 🔗",
        },
        game_over = {
            title = "GAME OVER!",
            kills = "Kills",
            time = "Time",
            floor = "Floor",
            -- max_combo = "Max combo",
            continue = "CONTINUE",
        },
        win = {
            title = "CONGRATULATIONS!",
            wishlist = "WISHLIST ON STEAM", -- "wishlist" is a verb
            continue = "CONTINUE",
        },
        joystick_removed = {
            title = "CONTROLLER DISCONNECTED",
            description = "Please plug in the following controllers:",
            continue = "CONTINUE ANYWAY",
            item = "Player %d (%s)",
        },
        credits = {
            title = "CREDITS",
            game_by = "A game by",
            game_by_template = "A game by %s", -- Used on the title screen. 
            music_and_sound_design = "Music and sound design",
            playtesting = "Playtesting",
            special_thanks = "Special thanks",
            asset_creators = "Asset creators",
            licenses = "Asset & library licenses",

            asset_item = "%s by %s / %s", -- "ASSET_NAME by CREATOR / LICENCE". Used to credit assets such as sound effects
        },
        open_source = {
            title = "Open source libraries",
        },
    },
}