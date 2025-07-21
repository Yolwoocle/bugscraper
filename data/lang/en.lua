--[[
    TO TRANSLATORS:
    * Reference document for all enemies, players, levels, etc: 
      https://docs.google.com/document/d/13UntpWqoTXgYnBm5HL0pZmjBDwMStIN8YB1IPdi7hlA
    * Even though my target audience is people who already play games, since the game supports 
      local co-op and has very simple, accessible controls, it's not absurd to think that more 
      occasional gamers would try their hand at the game, so try to avoid english gamer terms like 
      "kills", "checkpoint", etc, except if it's the normal established term for the word (e.g. "jetpack", etc). 
    * It is very easy for me to add more characters if needed, just tell me and I'll do it.
]]

return {
    __test_DONOTTRANSLATE = [[  Welcome to the bugscraper. Rise to the top of this pest-filled tower in this roguelike shooter and battle waves of enemies at every floor on your way to your boss's office. Welcome to the bugscraper. 🐜 In this roguelike shooter, you play as Mio and his friends, employees of a bug-filled skyscraper, who are fed up with their jobs. 🐛 On your way to your boss's office, you'll have to face waves of enemies on each floor in a tight elevator. 🐝 With a wide variety of weapons and upgrades, eliminate them and prepare to battle for the next floor!🐞 Play solo, or with up to 4 friends in local co-op multiplayer.]],
    language = {
        -- These should be kept untranslated in their original language ("English", "Français", "简体中文", etc)
        en = "English",
        es = "Español",
        fr = "Français",
        zh = "简体中文",
        pl = "Polski",
        pt = "Português Brasileiro",
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

        combo = "COMBO %d", -- ADDED 
    },
    level = {
        world_prefix = "Department %s", 

        -- World names
        world_1 = "Bug Resources",
        world_2 = "The Factory",
        world_3 = "The Server Room",
        world_4 = "The Gardens",
        world_5 = "Executive",
    },
    gun = {
        -- Gun names
        -- You can stay close to the original, but please feel free to have a more creative interpretation if you wish!
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
            -- If the native name clashes with something specific to the language/culture, please notify me.
            -- You can also use translitations into the script of the language if needed (i.e. Leo -> Léo)
            mio = "Mio",
            cap = "Cap",
            zia = "Zia",
            tok = "Tok",
            nel = "Nel",
            nob = "Nob",
            rico = "Rico",
            leo = "Leo",
            dodu = "Dodu",
            yv = "Y.V.",
        },
        abbreviation = "P%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    enemy = {
        dung = "Mr. Dung",
        bee_boss = "Her Majesty", 
        motherboard = "The Webmaster",
    },
    upgrade = {
        tea = {
            title = "Green Tea",
            description = "+%d temporary ❤",
        },
        espresso = {
            title = "Espresso",
            description = "x%d shooting speed for %d floors", 
        },
        milk = {
            title = "Milk",
            description = "+%d maximum ❤",
        },
        boba = {
            title = "Boba",
            description = "x%d maximum ammo",
        },
        soda = {
            title = "Soda",
            description = "+%d midair jump",
        },
        fizzy_lemonade = {
            title = "Fizzy Lemonade",
            description = "Hold jump to glide",
        },
        apple_juice = {
            title = "Apple Juice",
            description = "Heal +%d ❤",
        },
        hot_sauce = {
            title = "Hot Sauce",
            description = "Deal x%d damage but use x%d ammo", -- First "%d" is the damage, second "%d" is ammo 
        },
        coconut_water = {
            title = "Coconut Water",
            description = "Stomping enemies gives back %d%% ammo",
        },
        hot_chocolate = {
            title = "Hot Chocolate",
            description = "Faster reloading speed",
        },
        pomegranate_juice = {
            title = "Pomegranate Juice",
            description = "Create an explosion when taking damage",
        },
        energy_drink = {
            title = "Energy Drink", -- ADDED
            description = "Combo meter decreases more slowly", -- ADDED
        },
    },
    input = {
        prompts = {
            -- All of these may be shown as button prompts (i.e., "[X] Shoot", "[C] Jump", etc)
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
            split_keyboard = "Split keyboard", -- Verb, as in "Press [key] to split the keyboard". Shown on the title screen when one keyboard player has joined. Try to keep short since space is limited there.

            wall_jump = "Wall jump",
            jetpack = "Jetpack", -- Refers to "jetpacking", a move in the game. 
        },
    },
    dialogue = {
        npc = {
            hornet = "I'm still waiting for my sister...",
            brown = "This is probably not healthy.",
            noba = "zerzer",
        },
    },
    menu = {
        see_more = "see more...",
        yes = "YES",
        no = "NO",
        leave_menu = "Leave menu?", -- Generic "leave menu?"
        quit = {
            description = "Are you sure you want to quit?"
        },
        confirm_retry = {
            -- Here refers to going back to the main menu to try another run, NOT restarting the game
            description = "Retry?", 
        },
        pause = {
            title = "PAUSE",
            resume = "RESUME",
            retry = "RETRY",
            return_to_ground_floor = "RETURN TO GROUND FLOOR", --ADDED
            options = "OPTIONS",
            credits = "CREDITS",
            feedback = "FEEDBACK",
            quit = "QUIT",
            website = "OFFICIAL WEBSITE",
            discord = "DISCORD",
            github = "GITHUB", -- ADDED
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
                subtitle_no_player = "[⚠ NO PLAYER %d]", -- Shown when navigating to player "%d"'s controller settings while no player of this number has joined yet.
                subtitle_no_controller = "[⚠ NO CONTROLLER CONNECTED]", -- Shown in the controller settings while no controller is connected
                no_buttons = "[NO BUTTONS]",
                press_button = "[PRESS BUTTON]", -- Try to keep it short
                press_again_to_remove = "Press an already bound button to remove it",
                
                keyboard = "Keyboard",
                keyboard_solo = "KEYBOARD (Default)",
                keyboard_p1 = "KEYBOARD (Split 1)", -- Split is an adjective here; as in, "the 1st split keyboard user"
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
                music_pause_menu = "MUSIC ON PAUSE MENU", -- Whether music should play on the pause menu
            },
            visuals = {
                title = "Visuals",
                fullscreen = "FULLSCREEN",
                pixel_scale = "PIXEL SCALE", -- How big should every pixel be displayed on-screen
                pixel_scale_value = {
                    auto = "auto",
                    max_whole = "max whole",
                },
                vsync = "VSYNC",
                menu_blur = "MENU BACKGROUND BLUR", 
                background_speed = "BACKGROUND SPEED",
                bullet_lightness = "BULLET BRIGHTNESS",
            },
            game = {
                title = "Game",
                tutorial = "TUTORIAL...",
                language = "LANGUAGE...",
                timer = "TIMER",
                mouse_visible = "SHOW MOUSE CURSOR",
                pause_on_unfocus = "PAUSE ON LOST FOCUS", -- whether the game should pause when the window loses focus
                screenshake = "SCREENSHAKE",
                skip_boss_intros = "SKIP BOSS INTROS",
                show_fps_warning = "SHOW LOW FRAMERATE WARNING", -- Whether the game should show a warning when its framerate is low

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
            bugs = "REPORT A BUG",
            features = "SUGGEST A FEATURE",
        },
        game_over = {
            title = "GAME OVER!",
            kills = "Enemies killed", -- The amount of enemies the player has killed
            time = "Time", -- The time that the player took to complete the level
            floor = "Floor", -- Which storey the player was on when they died
            score = "Score", -- ADDED
            
            continue = "CONTINUE",
            quick_restart = "QUICK RESTART", --ADDED
        },
        new_reward = {
            new_skin = "New character!", -- ADDED
            new_upgrade = "New upgrade!", -- ADDED
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
            music = "Music",
            sound_design = "Sound design",
            published_by = "Published by",
            localization = "Localization",
            additional_art = "Additional art",
            playtesting = "Playtesting",
            special_thanks = "Special thanks",
            asset_creators = "Asset creators",
            tv_slideshow = "TV slideshow contributors", -- ADDED // Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            tv_slideshow_submit = "Submit yours...", -- ADDED // Leads to a web page where people can submit their own slides
            licenses = "Asset & library licenses",
            more = "And many more...", -- ADDED // For the people that I might have forgotten in the special thanks section

            x_by_y =     "%s by %s", -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s by %s / %s", -- "ASSET_NAME by CREATOR / LICENCE"
        },
        open_source = {
            title = "Open source libraries",
        },
    },
}