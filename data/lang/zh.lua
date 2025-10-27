--[[
    TO TRANSLATORS:
    * Reference document for all enemies, players, levels, etc: 
      https://docs.google.com/document/d/13UntpWqoTXgYnBm5HL0pZmjBDwMStIN8YB1IPdi7hlA
    * Even though my target audience is people who already play games, since the game supports 
      local co-op and has very simple, accessible controls, it's not absurd to think that more 
      occasional gamers would try their hand at the game, so try to avoid english gamer terms like 
      "kills", "checkpoint", etc, except if it's already the established term for the word.
    * It is very easy for me to add more glyphs if needed, just tell me and I'll do it.
    * Please notify me if there are any special technical requirements. (e.g. text rendering specifics, etc) 
]]

return {
    language = {
        en = "English",
        es = "Español",
        fr = "Français",
        zh = "简体中文",
        pl = "Polski",
        pt = "Português Brasileiro",
    },
    discord = {
        state = {
            solo = "单人游戏",
            local_multiplayer = "本地多人",
        },
        details = {
            waiting = "在大厅中",
            playing = "游戏中（第 %d/%d 层）",
            dying = "已被击败（第 %d/%d 层）",
            win = "胜利画面",
        },
    },
    game = {
        demo = "试玩版",
        fps = "%d 帧率",
        congratulations = "恭喜通关！",
        win_thanks = "感谢游玩试玩版",
        win_wishlist = "请在 Steam 上加入愿望单 :)", 
        win_prompt = "[按暂停继续]",
        warning_web_controller = "某些浏览器可能不支持手柄",

        combo = "连击 %d",
    },
    level = {
        world_prefix = "部门 %s", 

        world_1 = "虫虫资源部",
        world_2 = "蜜蜂工厂",
        world_3 = "服务器机房",
        world_4 = "花园",
        world_5 = "高管区",

        world_0 = "Basement",
    },
    gun = {
        machinegun = "豌豆枪",
        triple = "三重辣椒",
        burst = "花粉爆发",
        shotgun = "树莓霰弹枪",
        minigun = "种子机枪",
        ring = "大浆果",
        mushroom_cannon = "蘑菇炮",

        resignation_letter = "辞职信",
    },
    player = {
        name = {
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
        abbreviation = "%dP",
    },
    enemy = {
        dung = "屎先生",
        bee_boss = "蜂后陛下", 
        motherboard = "网络主宰",
    },
    upgrade = {
        tea = {
            title = "绿茶",
            description = "+%d 临时 ❤",
        },
        espresso = {
            title = "浓缩咖啡",
            description = "射速 x%d，持续 %d 层", 
        },
        milk = {
            title = "牛奶",
            description = "+%d 最大 ❤",
        },
        boba = {
            title = "珍珠奶茶",
            description = "最大弹药 x%d",
        },
        soda = {
            title = "汽水",
            description = "+%d 次空中跳跃",
        },
        fizzy_lemonade = {
            title = "气泡柠檬水",
            description = "长按跳跃滑翔",
        },
        apple_juice = {
            title = "苹果汁",
            description = "回复 +%d ❤",
        },
        hot_sauce = {
            title = "辣椒酱",
            description = "造成 x%d 伤害，但消耗 x%d 弹药", 
        },
        coconut_water = {
            title = "椰子水",
            description = "踩敌人可返还 %d%% 弹药",
        },
        hot_chocolate = {
            title = "热巧克力",
            description = "更快的装填速度",
        },
        pomegranate_juice = {
            title = "石榴汁",
            description = "受伤时产生爆炸",
        },
        energy_drink = {
            title = "能量饮料",
            description = "连击槽下降更慢",
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
            interact = "互动",
            leave_game = "退出", 
            open = "打开",
            collect = "收集",

            ui_left =  "左（菜单）",
            ui_right = "右（菜单）",
            ui_up =    "上（菜单）",
            ui_down =  "下（菜单）",
            ui_select = "确认",
            ui_back = "返回",
            pause = "暂停",

            join = "加入",
            split_keyboard = "分割键盘",

            wall_jump = "墙跳",
            jetpack = "喷气背包", 
        },
    },
    dialogue = {
        npc = {
        },
    },
    menu = {
        see_more = "查看更多...",
        yes = "是",
        no = "否",
        leave_menu = "要离开菜单吗？",
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
            return_to_ground_floor = "返回第 0 层",
            options = "选项",
            credits = "制作人员",
            feedback = "反馈",
            quit = "退出",
            website = "官方网站",
            discord = "Discord",
            github = "GitHub",
        },
        options = {
            title = "选项",

            input = {
                title = "输入",
                input = "输入设置...",
            },
            input_submenu = {
                title = "输入设置",
                reset_controls = "重置按键",
                controller_button_style = "按键样式",
                controller_button_style_value = {
                    detect = "自动检测",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "摇杆死区",
                vibration = "震动",
                low_deadzone_warning = "数值过低可能导致问题",
                note_deadzone = "离开菜单后生效",

                gameplay = "玩法",
                interface = "界面",
                global = "全局",
                note_ui_min_button = "至少需要一个绑定",
                note_global_keyboard = "这些绑定对所有键盘玩家通用",
                note_global_controller = "这些绑定对所有手柄通用",
                subtitle_no_player = "[⚠ 没有玩家 %d]",
                subtitle_no_controller = "[⚠ 未连接手柄]",
                no_buttons = "[无按键]",
                press_button = "[请按键]",
                press_again_to_remove = "再次按下已绑定的键来移除",
                
                keyboard = "键盘",
                keyboard_solo = "键盘（默认）",
                keyboard_p1 = "键盘（分割 1）",
                keyboard_p2 = "键盘（分割 2）",

                controller = "手柄",
                controller_p1 = "手柄（玩家 1）",
                controller_p2 = "手柄（玩家 2）",
                controller_p3 = "手柄（玩家 3）",
                controller_p4 = "手柄（玩家 4）",
            },
            audio = {
                title = "音频",
                sound = "音效",
                volume = "音量",
                sfx_volume = "音效音量",
                music_volume = "音乐音量",
                music_pause_menu = "暂停菜单音乐",
            },
            visuals = {
                title = "画面",
                fullscreen = "全屏",
                pixel_scale = "像素缩放",
                pixel_scale_value = {
                    auto = "自动",
                    max_whole = "最大整数",
                },
                vsync = "垂直同步",
                menu_blur = "菜单背景模糊", 
                background_speed = "背景速度",
                bullet_lightness = "子弹亮度",
            },
            game = {
                title = "游戏",
                tutorial = "教程...",
                language = "语言...",
                timer = "计时器",
                mouse_visible = "显示鼠标指针",
                pause_on_unfocus = "失焦时暂停",
                screenshake = "屏幕震动",
                skip_boss_intros = "跳过 Boss 开场",
                show_fps_warning = "显示低帧率警告",

            },
            language = {
                title = "语言",
            },
            confirm_language = {
                description = "重启游戏以应用新语言？",
            },
        },
        feedback = {
            title = "反馈",
            bugs = "报告漏洞",
            features = "提出建议",
        },
        game_over = {
            title = "游戏结束！",
            kills = "击败敌人数量",
            time = "时间",
            floor = "层数",
            score = "得分",
            max_combo = "Max combo", -- ADDED
            
            continue = "继续",
            quick_restart = "快速重开",
        },
        new_reward = {
            new_skin = "新角色！",
            new_upgrade = "新升级！",
        },
        win = {
            title = "恭喜通关！",
            wishlist = "加入 Steam 愿望单",
            continue = "继续",
        },
        joystick_removed = {
            title = "手柄已断开",
            description = "请插入以下手柄：",
            continue = "仍然继续",
            item = "玩家 %d（%s）",
        },
        credits = {
            title = "制作人员",
            ninesliced_presents = "Ninesliced 出品",
            game_by = "制作人",
            leo_bernard = "曹宇 Léo Bernard",
            music = "音乐",
            sound_design = "音效设计",
            localization = "本地化",
            additional_art = "额外美术",
            playtesting = "测试",
            special_thanks = "特别感谢",
            trailer = "预告片",
            asset_creators = "素材作者",
            tv_slideshow = "电视幻灯片贡献者",
            tv_slideshow_submit = "提交你的作品...",
            licenses = "素材与库授权",
            more = "以及更多...", 

            x_by_y =     "%s 作者：%s",
            asset_item = "%s 作者：%s / %s",
        },
        open_source = {
            title = "开源库",
        },
    },
}
