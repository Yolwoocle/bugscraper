return {
    language = {
        -- These should be kept untranslated in their original language ("english", "français", "中文", etc)
        en = "English",
        fr = "Français",
        zh = "简体中文",
        pl = "Polski",
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
        world_1 = "Bug Resources",
        world_2 = "Production Chamber",
        world_3 = "Server Room",
        world_4 = "Executive",
    },
    gun = {
        -- Gun names
        machinegun = "Pea Gun",
        triple = "Triple Pepper",
        burst = "Pollen Burst",
        shotgun = "Raspberry Shotgun",
        minigun = "Seed Minigun",
        ring = "Big Berry",
        mushroom_cannon = "Mushroom Cannon",
    },
    player = {
        name = {
            -- Player names
            -- No reason to change these during translation, except if:
            --  * it's more appropriate to use a transliteration, or to use the script of the concerned language (e.g. Leo -> Léo in French)
            --  * they clash with something specific to the language/culture (please notify me if it is the case)
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
    enemy = {
        dung = "Mr. Dung",
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

            ui_left =  "Left (menu)",
            ui_right = "Right (menu)",
            ui_up =    "Up (menu)",
            ui_down =  "Down (menu)",
            ui_select = "Confirm",
            ui_back = "Back",
            pause = "Pause",

            join = "Join",
            split_keyboard = "Split keyboard", -- Try to keep short

            jetpack = "Jetpack", -- Refers to "jetpackking", a move in the game, so this is an infinitive verb 
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
        },
        options = {
            title = "OPTIONS",

            input = {
                title = "Input",
                input = "INPUT SETTINGS...",
            },
            input_submenu = {
                title = "INPUT SETTINGS",
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
                low_deadzone_warning = "Low values may cause issues", -- Warning displayed when the deadzone is very small
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
                press_button = "[PRESS BUTTON]", -- Try to keep it short
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
            },
            visuals = {
                title = "Visuals",
                fullscreen = "FULLSCREEN",
                pixel_scale = "PIXEL SCALE",
                pixel_scale_value = {
                    auto = "auto",
                    max_whole = "max whole",
                },
                vsync = "VSYNC",
                menu_blur = "MENU BACKGROUND BLUR",
                background_speed = "BACKGROUND SPEED",
            },
            game = {
                title = "Game",
                language = "LANGUAGE...",
                timer = "TIMER",
                mouse_visible = "SHOW MOUSE CURSOR",
                pause_on_unfocus = "PAUSE ON LOST FOCUS",
                screenshake = "SCREENSHAKE",
                show_fps_warning = "SHOW LOW FRAMERATE WARNING",

            },
            language = {
                title = "LANGUAGE",
            },
            confirm_language = {
                description = "Restart the game to apply new language?",
            },
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
            item = "Player %d (%s)", -- e.g. "Player 2 (Xbox Controller)"
        },
        credits = {
            title = "CREDITS",
            game_by = "A game by",
            game_by_template = "By Léo Bernard & friends", -- Used on the title screen. 
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