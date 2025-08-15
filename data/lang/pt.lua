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
    discord = { -- Text used for Discord rich presence
        state = {
            solo = "Jogando solo",
            local_multiplayer = "Multiplayer local",
        },
        details = {
            waiting = "No lobby",
            playing = "Em jogo (andar %d/%d)",
            dying = "Derrotado(a) (andar %d/%d)",
            win = "Tela de vitória",
        },
    },
    game = {
        demo = "DEMO", -- Chip added to the game logo to indicate that this version is a demo
        fps = "%d FPS",
        congratulations = "PARABÉNS!",
        win_thanks = "Obrigado por jogar o demo",
        win_wishlist = "Adicione esse jogo à lista de desejos :)", -- "Wishlist" is a verb
        win_prompt = "[Pause para continuar]",
        warning_web_controller = "Alguns browsers podem não ser compatíveis com controles",

    },
    level = {
        world_prefix = "Departamento %s",

        -- World names
        world_1 = "Recursos Insetos",
        world_2 = "A Fábrica",
        world_3 = "A Sala de Server",
		world_4 = "The Gardens", -- ADDED
        world_5 = "Executivo",
    },
    gun = {
        -- Gun names
        machinegun = "Atirador de Ervilha",
        triple = "Pimentripla",
        burst = "Explosão de Pólen",
        shotgun = "Lança-Amora",
        minigun = "Metralhadora de Semente",
        ring = "Bagonazona",
        mushroom_cannon = "Canhão de Cogumelo",
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
            nob = "Nob", 
            rico = "Rico",
            leo = "Leo",
        },
        abbreviation = "J%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    enemy = {
        dung = "Sr. Esterco",
        bee_boss = "The Queen",        -- ADDED
        motherboard = "The Webmaster", -- ADDED
    },
    upgrade = {
        tea = {
            title = "Chá Verde",
            description = "+%d ❤ temporários",
        },
        espresso = {
            title = "Expresso",
            description = "x%d velocidade de tiro por 1 minuto", -- CHANGED
        },
        milk = {
            title = "Leite",
            description = "+%d ❤ permanente", -- CHANGED: "+1 maximum ❤"
        },
        boba = {
            title = "Amendoim", -- CHANGED: Boba
            description = "x%d munição máxima",
        },
        soda = {
            title = "Refri",
            description = "+%d pulo no ar",
        },
        fizzy_lemonade = { -- ADDED
            title = "Fizzy Lemonade",
            description = "Hold jump to glide",
        },
        apple_juice = { -- ADDED
            title = "Apple Juice",
            description = "Heal +%d ❤",
        },
        hot_sauce = { -- ADDED
            title = "Hot Sauce",
            description = "Deal x%d damage but use x%d ammo", -- First "%d" is the damage, second "%d" is ammo 
        },
        coconut_water = { -- ADDED
            title = "Coconut Water",
            description = "Stomping enemies gives back %d%% ammo",
        },
        hot_chocolate = { -- ADDED
            title = "Hot Chocolate",
            description = "x%d reloading speed", -- -- CHANGED
        },
        energy_drink = {
            title = "Energy Drink", -- ADDED
            description = "Combo meter decreases more slowly", -- ADDED
        },
    },
    input = {
        prompts = {
            move = "Mover",
            left = "Esquerda",
            right = "Direita",
            up = "Cima",
            down = "Baixo",
            jump = "Pular",
            shoot = "Atirar",
            leave_game = "Sair",

            ui_left = "Esquerda (menu)",
            ui_right = "Direita (menu)",
            ui_up = "Cima (menu)",
            ui_down = "Baixo (menu)",
            ui_select = "Confirmar",
            ui_back = "Voltar",
            pause = "Pausar",

            join = "Entrar",
            split_keyboard = "Dividir teclado", -- Try to keep short

            jetpack = "Usar jetpack",           -- Refers to "jetpackking", a move in the game, so this is an infinitive verb
        },
    },
    menu = {
        see_more = "ver mais...",
        yes = "SIM",
        no = "NÃO",
        quit = {
            description = "Tem certeza que quer sair?"
        },
        confirm_retry = {
            -- Here refers to going back to the main menu to try another run, NOT restarting the game
            description = "Retry?", -- ADDED
        },
        pause = {
            title = "PAUSA",
            resume = "RETOMAR",
            retry = "TENTAR DE NOVO",
            return_to_ground_floor = "RETURN TO GROUND FLOOR", --ADDED
            options = "OPÇÕES",
            credits = "CRÉDITOS",
            feedback = "FEEDBACK",
            quit = "SAIR",
            website = "WEBSITE OFICIAL",
            discord = "DISCORD",
        },
        options = {
            title = "OPÇÕES",

            input = {
                title = "Controles",
                input = "CONFIGURAÇÃO DOS CONTROLES...",
            },
            input_submenu = {
                title = "CONFIGURAÇÃO DOS CONTROLES",
                reset_controls = "RESETAR CONTROLES",
                controller_button_style = "ESTILO DOS BOTÕES",
                controller_button_style_value = {
                    detect = "detectar",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "DEADZONE DO JOYSTICK",
                vibration = "VIBRAÇÃO",
                low_deadzone_warning = "Valores baixos podem dar problema", -- Warning displayed when the deadzone is very small
                note_deadzone = "Opções de deadzone vão ser aplicadas após sair desse menu",

                gameplay = "Gameplay",
                interface = "Interface",
                global = "Global",
                note_ui_min_button = "É necessário pelo menos 1 vínculo",
                note_global_keyboard = "Esses vínculos são iguais para todos os jogadores com teclado",
                note_global_controller = "Esses vínculos são iguais para todos os controles",
                subtitle_no_player = "[⚠ SEM JOGADOR %d]",
                subtitle_no_controller = "[⚠ SEM CONTROLE CONECTADO]",
                no_buttons = "[SEM BOTÕES]",
                press_button = "[APERTE O BOTÃO]", -- Try to keep it short
                press_again_to_remove = "Aperte um botão já vinculado para remover",

                keyboard = "Teclado",
                keyboard_solo = "TECLADO (Padrão)",
                keyboard_p1 = "TECLADO (Parte 1)",
                keyboard_p2 = "TECLADO (Parte 2)",

                controller = "CONTROLE",
                controller_p1 = "CONTROLE (Jogador 1)",
                controller_p2 = "CONTROLE (Jogador 2)",
                controller_p3 = "CONTROLE (Jogador 3)",
                controller_p4 = "CONTROLE (Jogador 4)",
            },
            audio = {
                title = "Audio",
                sound = "SOM",
                volume = "VOLUME",
                sfx_volume = "VOLUME DOS EFEITOS SONOROS", -- ADDED
                music_volume = "VOLUME DA MÚSICA",
                music_pause_menu = "MÚSICA NO MENU DE PAUSA",
            },
            visuals = {
                title = "Visuais",
                fullscreen = "TELA CHEIA",
                pixel_scale = "ESCALA DE PIXEL",
                pixel_scale_value = {
                    auto = "auto",
                    max_whole = "máximo inteiro",
                },
                vsync = "SINCRONIZAÇÃO VERTICAL",
                menu_blur = "DESFOQUE DO FUNDO DO MENU",
                background_speed = "VELOCIDADE DO FUNDO",
                bullet_lightness = "BULLET BRIGHTNESS", -- ADDED
            },
            game = {
                title = "Jogo",
                language = "IDIOMA...",
                timer = "CRONÔMETRO",
                mouse_visible = "MOSTRAR PONTEIRO DO MOUSE",
                pause_on_unfocus = "PAUSAR QUANDO SEM FOCO",
                screenshake = "VIBRAÇÃO DA TELA",
                skip_boss_intros = "SKIP BOSS INTROS", -- ADDED
                show_fps_warning = "MOSTRAR AVISO DE FPS BAIXO",

            },
            language = {
                title = "IDIOMA",
            },
            confirm_language = {
                description = "Reiniciar o jogo para aplicar o idioma?",
            },
        },
        feedback = {
            title = "FEEDBACK",
            bugs = "DENUNCIAR ERRO",
            features = "SUGERIR UMA FUNCIONALIDADE",
        },
        game_over = {
            title = "FIM DE JOGO!",
            kills = "Abates", -- CHANGED: enemies killed
            time = "Tempo",
            floor = "Andar",
            continue = "CONTINUAR",
            quick_restart = "QUICK RESTART", --ADDED
        },
        win = {
            title = "PARABÉNS!",
            wishlist = "ADICIONE À LISTA DE DESEJOS NA STEAM", -- "wishlist" is a verb
            continue = "CONTINUAR",
        },
        joystick_removed = {
            title = "CONTROLE DISCONECTADO",
            description = "Favor conectar os seguintes controles:",
            continue = "CONTINUAR MESMO ASSIM",
            item = "Jogador %d (%s)", -- e.g. "Player 2 (Xbox Controller)"
        },
        credits = {
            title = "CRÉDITOS",
            game_by = "Um jogo por",
            game_by_template = "Por Léo Bernard & amigos", -- Used on the title screen.
            music = "Música",
            sound_design = "Design de som",
            localization = "Localização",
            playtesting = "Playtest",
            special_thanks = "Agradecimentos especiais",
            asset_creators = "Criadores de recursos",
            tv_slideshow = "TV slideshow contributors", -- ADDED // Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            tv_slideshow_submit = "Submit yours...", -- ADDED // Leads to a web page where people can submit their own slides
            licenses = "Licensas de bibliotecas & recursos",

            x_by_y =     "%s por %s", -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s por %s / %s", -- "ASSET_NAME by CREATOR / LICENCE". Used to credit assets such as sound effects
        },
        open_source = {
            title = "Bibliotecas open source",
        },
    },
}
