--[[
    TO TRANSLATORS:
    * Reference document for all enemies, players, levels, etc: (can be outdated)
      https://docs.google.com/document/d/13UntpWqoTXgYnBm5HL0pZmjBDwMStIN8YB1IPdi7hlA
    * To search for added or changed strings, you can use this regex in the search functionality 
      of your text editor: (Ctrl+F then Alt+R on VS Code)
      \[\[((ADDED)|(REMOVED))
    * It is very easy for me to add more glyphs if needed, just tell me and I'll do it.
    * Please notify me if there are any special technical requirements. (e.g. text rendering specifics, etc)
]]

return {
    __meta = {
        -- Do not touch this section.
        menu_padding = 0.18,
        large_mini_font = false,
    },
    language = {
        -- These should be kept untranslated in their original language ("English", "Français", "简体中文", etc)
        en = "English",
        es = "Español",
        fr = "Français",
        pl = "Polski",
        pt_BR = "Português Brasileiro",
        zh_Hans = "简体中文",
        ja = "日本語",
    },
    game = {
        demo = "DEMO", -- Chip added to the game logo to indicate that this version is a demo
        fps = "%d FPS",
        congratulations = "恭喜! ",
        win_thanks = "感谢您游玩本试玩版",
        win_wishlist = "请在 Steam 上将本作加入愿望单 :)", -- "Wishlist" is a verb
        warning_web_controller = "部分浏览器可能无法完全支持手柄",

        combo = "连击 %d", 
    },
    level = {
        world_prefix = "第 %s 部门",

        -- Department names
        -- I chose to not use articles in english (so instead of "The Factory", it's just "Factory")

        -- Dept 1: This can be any vaguely office-y name (I just chose this in english because of the word play), 
        -- because this department just represents a generic office department.
        world_1 = "虫力资源部", 
        -- Dept 2: This department is a factory themed after bees, with grungy metallic environment
        world_2 = "工厂",
        -- Dept 3: This is a moody, dark and mysterious room filled with endless racks of servers 
        world_3 = "机房",
        -- Dept 4: This is the highest department of the bugscraper, filled with lofty gardens and clean, white, modern architecture
        world_4 = "花园",

        -- Dept 0: This is an underground secret department below the bugscraper. It contains a huge hangar with a large rocket. 
        world_0 = "地下室",
    },
    gun = {
        -- Gun names
        -- You can be more creative with these, you don't have to stay close to the originals.
        -- Look at google doc for image references
        machinegun = "豌豆枪",
        triple = "三发胡椒枪",
        burst = "花粉爆裂",
        shotgun = "树莓霰弹枪",
        minigun = "种子加特林",
        ring = "大浆果",
        mushroom_cannon = "蘑菇加农炮",

        resignation_letter = "辞职信",
    },
    player = {
        name = {
            -- Player names
            -- If the native name clashes with something specific to the language/culture, please notify me.
            -- You can also use translitations into the language if needed (e.g. Mio -> ミオ)
            mio = "米奥",
            cap = "卡普",
            zia = "齐亚",
            tok = "托克",
            nel = "内尔",
            nob = "诺布",
            amb = "安布",

            -- These are guest characters from other games so please stay close to the original.
            rico = "里科", -- From 'The Bullet Hopper'
            yv = "Y.V.", -- From 'Nuclear Throne' / See localized names here: https://docs.google.com/spreadsheets/d/18N1CNxIzSUm4CkIWUw0nbRnlxzAgoRbHpGyX8649Gjw/edit?usp=sharing
            leo = "里奥",
            dodu = "多多", 
        },
        abbreviation = "P%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    enemy = {
        -- These are the boss names. Please look at the Gdocs for reference.
        -- Feel free to pick interesting names, and you don't have to base them off the english name.

        -- (for example, the french name for "Mr. Dung" is "J. De Bouse", which is a 
        -- play on words with the french word for 'dung' and a famous french humorist. 
        -- "The Webmaster" is a play on words between the theme of the area and spider webs)

        -- A somewhat witty and clownesque exectutive based off a Dung Beetle. 
        boss_1 = "屎壳郎先生",

        -- The queen of the Factory, who's also a metal/rock singer.  
        boss_2 = "女王陛下", 

        -- The guardian of the Server Room, whose design is based off a motherboard and spiders.
        boss_3 = "盘丝网管",

        -- A very large green cabbage-like, boulder-like, rolling enemy from the Garden area.   
        -- You're free to be more creative with this one. 
        -- (example: in French, I chose "Grobroco", "gros" (large) + "broco" (diminutive of broccoli))
        boss_4 = "滚地巨菜",

        -- The CEO of the company, and the final boss. Its name is somewhat ominous-sounding.
        -- Try to avoid ambiguity with the term "boss", which could be confused with the generic term for a video game boss.
        boss_5 = "首席执行官",
    },
    upgrade = {
        tea = {
            title = "绿茶",
            description = "额外 +%d ❤",
        },
        espresso = {
            title = "浓缩咖啡",
            description = "连击时射速 x%d",
        },
        milk = {
            title = "牛奶",
            description = "最大生命值 +%d ❤",
        },
        boba = {
            title = "珍珠奶茶",
            description = "最大弹药量 x%d",
        },
        soda = {
            title = "苏打水", -- As in Coca-cola/Pepsi style soda.
            description = "空中跳跃次数 +%d",
        },
        fizzy_lemonade = {
            title = "气泡柠檬水",
            description = "长按跳跃键滑翔",
        },
        apple_juice = {
            title = "苹果汁",
            description = "恢复 +%d ❤",
        },
        hot_sauce = {
            title = "辣酱",
            description = "造成 x%d 伤害，但弹药消耗 x%d", -- First "%d" is the damage, second "%d" is ammo
        },
        coconut_water = {
            title = "椰子水",
            description = "踩踏敌人可恢复 %d%% 弹药",
        },
        hot_chocolate = {
            title = "热巧克力",
            description = "加快装填速度",
        },
        pomegranate_juice = {
            title = "石榴汁",
            description = "受到伤害时引发爆炸",
        },
        energy_drink = {
            title = "能量饮料",
            description = "连击条衰减速度变慢",
        },
        gazpacho = {
            title = "西班牙冷汤",
            description = "受伤后，迅速反击可恢复 1 ❤",
        },
    },
    input = {
        prompts = {
            -- All of these are infinitive verbs and may be shown as button prompts 
            -- (i.e., "[X] Shoot", "[C] Jump", etc)

            -- Gameplay Actions
            move = "移动", 
            left = "左",
            right = "右",
            up = "上",
            down = "下",
            jump = "跳跃",
            shoot = "射击",
            interact = "互动",
            leave_game = "离开",
            open = "打开",        -- As in, "open menu", and NOT for, say, opening chests.
            collect = "收集",   -- As in, "collect item", "collect gun", etc

            -- UI Actions
            ui_left =  "左 (菜单) ",
            ui_right = "右 (菜单) ",
            ui_up = "上 (菜单) ",
            ui_down = "下 (菜单) ",
            ui_select = "确认",
            ui_back = "返回",
            pause = "暂停",
            join = "加入", -- As, in joining the game, adding a new player to the game.
            -- As in, "Press [key] to split the keyboard". 
            -- Shown on the title screen when one keyboard player has joined. 
            -- Try to keep it as short as possible since space is limited there.
            split_keyboard = "拆分键盘", 

            wall_jump = "蹬墙跳",
            jetpack = "喷气背包", -- Refers to "jetpacking", a move in the game performed by shooting downwards with a gun.
        },
    },
    menu = {
        see_more = "查看更多...",
        yes = "是",
        no = "否",
        leave_menu = "离开菜单？", -- Generic "leave menu?"
        quit = {
            description = "确定要退出吗？"
        },
        confirm_retry = {
            description = "重试？",
        },
        pause = {
            title = "暂停",
            resume = "继续",
            retry = "重试",

            -- This correspons to floor 0 in the game. To different cultures, the "ground floor" 
            -- might usually mean "floor 1", so please make sure to avoid ambiguity when translating. 
            -- (You can also translate as "main lobby" or something like it.)   
            return_to_ground_floor = "返回大厅", 
            options = "选项",
            credits = "制作人员名单",
            feedback = "提供反馈",
            quit = "退出",
            website = "官方网站",
            discord = "DISCORD",
            github = "GITHUB",
        },
        options = {
            title = "选项",

            input = {
                title = "输入",
                input = "输入设置...",
            },
            input_submenu = {
                title = "输入设置",
                reset_controls = "重置控制",
                controller_button_style = "按键样式", -- The style of the buttons shown in-game. As in, PS4 style buttons, Xbox style buttons...
                controller_button_style_value = {
                    detect = "自动检测",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "摇杆死区",
                vibration = "震动",
                low_deadzone_warning = "值过低可能会导致问题", -- Warning displayed when the joystick deadzone is very small
                note_deadzone = "死区设置将在离开此菜单后生效",

                gameplay = "游戏",
                interface = "界面",
                global = "全局",
                note_ui_min_button = "至少需要绑定一个按键",
                note_global_keyboard = "所有使用键盘的玩家共享这些按键绑定",
                note_global_controller = "所有手柄共享这些按键绑定",
                -- Shown when navigating to player "%d"'s controller settings while no player of this number has joined yet.
                subtitle_no_player = "[⚠ 玩家 %d 未加入]", 
                -- Shown in the controller settings while no controller is connected
                subtitle_no_controller = "[⚠ 未连接手柄]", 
                no_buttons = "[未绑定按键]",
                press_button = "[请按键]", -- Try to keep it as short as possible
                -- When assigning buttons, if the user presses a button that is already bound, it will instead
                -- remove that button.
                press_again_to_remove = "按下已绑定的按键即可解除绑定", 
                
                keyboard = "键盘",
                keyboard_solo = "键盘 (默认) ",
                -- "Split" as in, "the 1st split keyboard user"
                keyboard_p1 = "键盘 (拆分 1) ", 
                keyboard_p2 = "键盘 (拆分 2) ",

                controller = "手柄",
                controller_p1 = "手柄 (玩家 1) ",
                controller_p2 = "手柄 (玩家 2) ",
                controller_p3 = "手柄 (玩家 3) ",
                controller_p4 = "手柄 (玩家 4) ",
            },
            audio = {
                title = "音频",
                sound = "声音", -- Toggle (on or off)
                volume = "主音量", -- Slider (0% to 100%)
                sfx_volume = "音效音量", -- Slider (0% to 100%)
                music_volume = "音乐音量", -- Slider (0% to 100%)
                music_pause_menu = "暂停菜单音乐", -- Whether music should play on the pause menu
                ambience = "环境音效",
            },
            visuals = {
                title = "视觉",
                fullscreen = "全屏",
                pixel_scale = "像素缩放", -- How big should every pixel be displayed on-screen (x1, x2, ...)
                pixel_scale_value = {
                    auto = "自动", -- Biggest number possible, whole or not
                    max_whole = "最大整数倍", -- Biggest whole number possible
                },
                vsync = "垂直同步",
                menu_blur = "菜单背景模糊", -- Whether to apply the blurring effect in menu backgrounds
                background_speed = "背景滚动速度", -- How quickly the background scrolls 
                bullet_lightness = "子弹亮度", -- How brightly bullets are rendered
            },
            game = {
                title = "游戏",
                tutorial = "教程...",
                language = "语言...",
                timer = "计时器",
                mouse_visible = "显示鼠标指针",
                pause_on_unfocus = "失去焦点时暂停", -- whether the game should pause when the window loses focus
                screenshake = "屏幕震动",
                skip_boss_intros = "跳过 Boss 出场动画", -- Whether the game should skip the boss intro animations 
                show_fps_warning = "显示低帧率警告", -- Whether the game should show a warning when its framerate is low

            },
            language = {
                title = "语言",
            },
            confirm_language = {
                description = "重启游戏以应用新语言？",
            },
        },
        achievements = {
            title = "成就",
        },
        feedback = {
            title = "提供反馈",
            bugs = "报告 Bug",
            features = "建议新功能",
        },
        game_over = {
            title = "GAME OVER!",
            kills = "击杀敌人", -- The amount of enemies the player has killed
            deaths = "死亡次数",
            time = "耗时",            -- The time that the player took to complete the level
            floor = "层数",          -- Which storey the player was on when they died
            score = "分数",
            max_combo = "最大连击",

            continue = "继续",
            quick_restart = "快速重开",
        },
        stats = {
            title = "统计",

            time_total = "游玩总时长",
            time_ingame = "局内游玩时长",
            runs = "游玩局数",
            best_run = "到达最高波数", -- The biggest wave number reached on any run
        },
        new_reward = {
            new_skin = "新角色! ",
            new_upgrade = "新升级! ",
        },
        win = {
            title = "恭喜! ",
            wishlist = "在 STEAM 加入愿望单", -- "wishlist" is a verb
            continue = "继续",
        },
        joystick_removed = {
            title = "手柄已断开连接",
            description = "请重新连接以下手柄：",
            continue = "仍然继续",
            item = "玩家 %d (%s)", -- e.g. "Player 2 (Xbox Controller)"
        },
        credits = {
            title = "制作人员名单",
            ninesliced_presents = "Ninesliced 呈现",
            game_by = "游戏制作", 
            leo_bernard = "Léo Bernard", -- Please do not touch this
            music = "音乐",
            sound_design = "音效设计",
            localization = "本地化",
            additional_art = "补充美术",
            playtesting = "游戏测试",
            special_thanks = "特别鸣谢",
            trailer = "宣传片",
            asset_creators = "素材创作者",
            tv_slideshow = "电视幻灯片贡献者", -- Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            licenses = "素材与库许可证",
            more = "以及更多成员...",                        -- For the people that I might have forgotten in the special thanks section
            thank_you_for_playing = "感谢您的游玩! ", -- Shown at the end of the credits

            x_by_y = "%s - %s",                               -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s - %s / %s",                     -- "ASSET_NAME by CREATOR / LICENCE"
        },
        open_source = {
            title = "开源库",
        },
    },
    achievements = {
        ach_complete_w1 = {
            name = "虫力资源部",
            description = "完成第 1 部门",
        },
        ach_complete_w2 = {
            name = "工厂",
            description = "完成第 2 部门",
        },
        ach_complete_w3 = {
            name = "机房",
            description = "完成第 3 部门",
        },
        ach_complete_w4 = {
            name = "花园",
            description = "完成第 4 部门",
        },
        ach_complete_end = {
            name = "假期",
            description = "通关游戏",
        },
        ach_death = {
            name = "百折不挠",
            description = "死亡 50 次",
        },
        ach_all_upgrades = {
            name = "狂怒鸡尾酒",
            description = "解锁所有升级",
        },
        ach_all_skins = {
            name = "团队领袖",
            description = "解锁所有角色",
        },
        ach_max_hearts = {
            name = "博爱之心",
            description = "获得 7 ❤",
        },
        ach_no_damage_easy = {
            name = "钢铁之虫",
            description = "连续 20 层不受伤害",
        },
        ach_no_damage_full = {
            name = "黄金之虫",
            description = "全程不受伤害通关",
        },
        ach_no_floor = {
            name = "地板是岩浆",
            description = "连续 10 层不接触地面",
        },
        ach_big_combo = {
            name = "暴怒",
            description = "达成 100 连击",
        },
        ach_smash_easter_egg = {
            name = "GAME! ", -- This is a reference to what the announcer says at the end of a match in Smash Bros.
            description = "触发隐藏的退场动画", 
        },
    },
    discord = { -- Text used for Discord rich presence
        state = {
            solo = "单人游玩",
            local_multiplayer = "本地多人游玩",
        },
        details = {
            waiting = "在大厅中",
            playing = "游戏中 (第 %d/%d 层)",
            dying = "被击败 (第 %d/%d 层)",
            win = "胜利界面",
        },
    },
}