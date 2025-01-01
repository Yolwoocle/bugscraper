return {
    language = {
        -- These should be kept untranslated in their original language ("english", "français", "中文", etc)
        en = "English",
        es = "Español",
        fr = "Français",
        zh = "简体中文",
        pl = "Polski",
        pt = "Português Brasileiro",
    },
    steam = {
        short_description =
        [[Welcome to the bugscraper. Rise to the top of this pest-filled tower in this 2D shooter platformer and battle waves of enemies at every floor as they come for your skin (or rather, exoskeleton).]],
        description =
        [[Welcome to the bugscraper. Here, pests all around the world come to gather. Your mission: stopping them before it is too late!🐜In this platformer shooter, you take the role of Mio, a courageous ant, trying to stop the employees of a bug-filled skyscraper from corrupting the world with a deadly mushroom.🐛You will battle waves of enemies in an elevator as they come for your skin (or rather, exoskeleton) on every floor.🐝Using a wide variety of weapons and upgrades, eliminate them and prepare to battle for the next floor!🐞Play in solo, or with up to 4 friends in local co-op multiplayer.]],
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
        world_2 = "The factory",
        world_3 = "The server room",
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
            --  * it's more appropriate to use a transliteration, or to use the script of the concerned language (e.g. Using the Chinese script)
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
        bee_boss = "The Queen",        -- ADDED
        motherboard = "The Webmaster", -- ADDED
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
        boba = {
            title = "Boba",
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
        fizzy_lemonade = { -- ADDED
            title = "Fizzy Lemonade",
            description = "Hold jump to glide",
        },
    },
    input = {
        prompts = {
            move = "移动",
            left = "左",
            right = "右",
            up = "上",
            down = "下",
            jump = "跳跃",
            shoot = "射击",
            leave_game = "退出",

            ui_left = "Menu left",
            ui_right = "Menu right",
            ui_up = "Menu up",
            ui_down = "Menu down",
            ui_select = "确认",
            ui_back = "取消",
            pause = "Pause",

            join = "加入",
            split_keyboard = "共享键盘",
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
        confirm_retry = {
            -- Here refers to going back to the main menu to try another run, NOT restarting the game
            description = "Retry?", -- ADDED
        },
        pause = {
            title = "暂停",
            resume = "继续",
            retry = "重试",
            options = "设置",
            credits = "致谢",
            feedback = "反馈",
            quit = "退出",
            website = "OFFICIAL WEBSITE",
            discord = "加入 DISCORD",
            twitter = "FOLLOW ON TWITTER (𝕏)",
        },
        options = {
            title = "设置",

            input = {
                title = "输入",
                input = "输入设置...",
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
                title = "声音",
                sound = "声音",
                volume = "音量",
                music_volume = "音乐音量",
                music_pause_menu = "音乐暂停菜单",
            },
            visuals = {
                title = "视频",
                fullscreen = "全屏",
                pixel_scale = "像素比例尺",
                pixel_scale_value = {
                    auto = "自动",
                    max_whole = "最大整数值",
                },
                vsync = "垂直同步",
                menu_blur = "菜单背景模糊",
                background_speed = "背景速度",
                bullet_lightness = "BULLET BRIGHTNESS", -- ADDED
            },
            game = {
                title = "游戏",
                language = "语言...",
                timer = "计时器",
                mouse_visible = "显示鼠标指针",
                pause_on_unfocus = "失去焦点时暂停",
                screenshake = "屏幕震动",
                skip_boss_intros = "SKIP BOSS INTROS", -- ADDED
                show_fps_warning = "显示低帧率警告",

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
            kills = "Enemies killed",
            time = "Time",
            floor = "Floor",
            -- max_combo = "Max combo",
            continue = "CONTINUE",
            quick_restart = "QUICK RESTART", --ADDED
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
            game_by_template = "By Léo Bernard & friends", -- Used on the title screen.
            music_and_sound_design = "Music and sound design",
            localization = "本地化",
            playtesting = "Playtesting",
            special_thanks = "Special thanks",
            asset_creators = "Asset creators",
            tv_slideshow = "TV slideshow contributors", -- ADDED // Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            tv_slideshow_submit = "Submit yours...", -- ADDED // Leads to a web page where people can submit their own slides
            licenses = "Asset & library licenses",

            x_by_y =     "%s by %s", -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s by %s / %s", -- "ASSET_NAME by CREATOR / LICENCE". Used to credit assets such as sound effects
        },
        open_source = {
            title = "Open source libraries",
        },
    },
}
