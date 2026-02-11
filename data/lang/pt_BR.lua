--[[
    TO TRANSLATORS:
    * Reference document for all enemies, players, levels, etc:
      https://docs.google.com/document/d/13UntpWqoTXgYnBm5HL0pZmjBDwMStIN8YB1IPdi7hlA
    * My target audience is people who already play some games.
    * It is very easy for me to add more glyphs if needed, just tell me and I'll do it.
    * Please notify me if there are any special technical requirements. (e.g. text rendering specifics, etc)
]]

return {
    __meta = {
        -- Do not touch this section.
        menu_padding = 0.18
    },
    language = {
        -- These should be kept untranslated in their original language ("English", "Français", "简体中文", etc)
        en = "English",
        es = "Español",
        fr = "Français",
        zh = "简体中文",
        pl = "Polski",
        pt_BR = "Português Brasileiro",
    },
    game = {
        demo = "DEMO", -- Chip added to the game logo to indicate that this version is a demo
        fps = "%d FPS",
        congratulations = "PARABÉNS!",
        win_thanks = "Obrigado por jogar o demo",
        win_wishlist = "Adicione esse jogo à lista de desejos :)", -- "Wishlist" is a verb
        warning_web_controller = "Some browsers may not have proper controller support",

        combo = "[[ADDED / COMBO %d]]",
    },
    level = {
        world_prefix = "Departamento %s",

        -- Department names
        -- I chose to not use articles in english (so instead of "The Factory", it's just "Factory")

        -- Dept 1: This can be any vaguely office-y name (I just chose this in english because of the word play), 
        -- because this department just represents a generic office department.
        world_1 = "Recursos Insetos",
        -- Dept 2: This deptartment is a factory themed after bees, with grungy metallic environment
        world_2 = "A Fábrica[[CHANGED / old:'The Factory' / new:'Factory']]",
        -- Dept 3: This is a moody, dark and mysterious room filled with endless racks of servers 
        world_3 = "A Sala do Servidor[[CHANGED / old:'The Server Room' / new:'Server Room']]",
        -- Dept 4: This is the highest department of the bugscraper, filled with lofty gardens and clean, white, modern architecture
        world_4 = "O Jardim[[CHANGED / old:'Executive' / new:'Gardens']]",

        -- Dept 0: This is an underground secret department below the bugscraper. It contains a huge hangar with a large rocket. 
        world_0 = "[[ADDED / Basement]]",
    },
    gun = {
        -- Gun names
        -- You can stay close to the original, but please feel free to have a more creative interpretation if you wish!
        -- Look at google doc for image references
        machinegun = "Atirador de Ervilha",
        triple = "Pimentripla",
        burst = "Explosão de Pólen",
        shotgun = "Lança-Amora",
        minigun = "Metralhadora de Semente",
        ring = "Bagonazona",
        mushroom_cannon = "Canhão de Cogumelo",

        resignation_letter = "Carta de demissão",
    },
    player = {
        name = {
            -- Player names
            -- If the native name clashes with something specific to the language/culture, please notify me.
            -- You can also use translitations into the language if needed (e.g. Mio -> ミオ)
            mio = "Mio",
            cap = "Cap",
            zia = "Zia",
            tok = "Tok",
            nel = "Nel",
            nob = "Nob",
            amb = "Amb",

            -- These are guest characters from other games so please stay close to the original.
            rico = "Rico", -- From 'The Bullet Hopper'
            yv = "Y.V.", -- From 'Nuclear Throne' / See localized names here: https://docs.google.com/spreadsheets/d/18N1CNxIzSUm4CkIWUw0nbRnlxzAgoRbHpGyX8649Gjw/edit?usp=sharing
            leo = "Leo",
            dodu = "Dodu",
        },
        abbreviation = "J%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    enemy = {
        -- These are the boss names. Please look at the Gdocs for reference.
        -- Feel free to pick interesting names, and you don't have to base them off the english name.

        -- (for example, the french name for "Mr. Dung" is "J. De Bouse", which is a 
        -- play on words with the french word for 'dung' and a famous french humorist. 
        -- "The Webmaster" is a play on words between the theme of the area and spider webs)

        -- A somewhat witty and clownesque exectutive based off a Dung Beetle. 
        boss_1 = "Sr. Esterco",

        -- The queen of the Factory, who's also a metal/rock singer.  
        boss_2 = "[[ADDED / Her Majesty]]",

        -- The guardian of the Server Room, whose design is based off a motherboard and spiders.
        boss_3 = "[[ADDED / Webmaster]]",

        -- A very large green cabbage-like, boulder-like, rolling enemy from the Garden area.   
        -- You're free to be more creative with this one.
        boss_4 = "[[ADDED / Rollossus]]",

        -- The CEO of the company, and the final boss. Its name is somewhat ominous-sounding.
        -- Try to avoid ambiguity with the term "boss", which could be confused with the generic term for a video game boss.
        boss_5 = "[[ADDED / CEO]]",
    },
    upgrade = {
        tea = {
            title = "Chá Verde",
            description = "+%d ❤ temporários[[CHANGED / old:'+2 temporary ❤' / new:'+%d extra ❤']]",
        },
        espresso = {
            title = "Expresso",
            description = "x%d velocidade de tiro por 1 minuto[[CHANGED / old:'x2 shooting speed for a minute' / new:'x%d shooting speed for %d floors']]",
        },
        milk = {
            title = "Leite",
            description = "+%d ❤ permanente[[CHANGED / old:'+1 permanent ❤' / new:'+%d maximum ❤']]",
        },
        boba = {
            title = "[[ADDED / Boba]]",
            description = "[[ADDED / x%d maximum ammo]]",
        },
        soda = {
            title = "Refri", -- As in Coca-cola/Pepsi style soda.
            description = "+%d pulo no ar[[CHANGED / old:'+1 midair jump' / new:'+%d midair jump']]",
        },
        fizzy_lemonade = {
            title = "Limonada Fizzy",
            description = "Aperte o pulo para planar",
        },
        apple_juice = {
            title = "Suco de Maçã",
            description = "Recupera +%d ❤",
        },
        hot_sauce = {
            title = "Molho de Pimenta",
            description = "Da x%d de dano, mas usando x%d balas", -- First "%d" is the damage, second "%d" is ammo
        },
        coconut_water = {
            title = "Agua de Coco",
            description = "Pistear nos inimigos da %d%% de munição",
        },
        hot_chocolate = {
            title = "Chocolate Quente",
            description = "Melhora em x%d a velocidade de recarga",
        },
        pomegranate_juice = {
            title = "[[ADDED / Pomegranate Juice]]",
            description = "[[ADDED / Create an explosion when taking damage]]",
        },
        energy_drink = {
            title = "Energetico",
            description = "Contador de combo diminui lentamente",
        },
    },
    input = {
        prompts = {
            -- All of these are infinitive verbs and may be shown as button prompts 
            -- (i.e., "[X] Shoot", "[C] Jump", etc)

            -- Gameplay Actions
            move = "Mover",
            left = "Esquerda",
            right = "Direita",
            up = "Cima",
            down = "Baixo",
            jump = "Pular",
            shoot = "Atirar",
            interact = "Interagir",
            leave_game = "Sair",
            open = "Abrir", -- As in, "open menu", and NOT for, say, opening chests.
            collect = "Coletar", -- As in, "collect item", "collect gun", etc

            -- UI Actions
            ui_left = "Esquerda (menu)",
            ui_right = "Direita (menu)",
            ui_up = "Cima (menu)",
            ui_down = "Baixo (menu)",
            ui_select = "Confirmar",
            ui_back = "Voltar",
            pause = "Pausar",
            join = "Entrar", -- As, in joining the game, adding a new player to the game.
            -- As in, "Press [key] to split the keyboard". 
            -- Shown on the title screen when one keyboard player has joined. 
            -- Try to keep it as short as possible since space is limited there.
            split_keyboard = "Dividir teclado",

            wall_jump = "[[ADDED / Wall jump]]",
            jetpack = "Usar jetpack", -- Refers to "jetpacking", a move in the game performed by shooting downwards with a gun.
        },
    },
    menu = {
        see_more = "ver mais...",
        yes = "SIM",
        no = "NÃO",
        leave_menu = "[[ADDED / Leave menu?]]", -- Generic "leave menu?"
        quit = {
            description = "Are you sure you want to quit?"
        },
        confirm_retry = {
            description = "Tentar de novo?",
        },
        pause = {
            title = "PAUSA",
            resume = "RETOMAR",
            retry = "TENTAR DE NOVO",

            -- This correspons to floor 0 in the game. To different cultures, the "ground floor" 
            -- might usually mean "floor 1", so please make sure to avoid ambiguity when translating. 
            -- (You can also translate as "main lobby" or something like it.)   
            return_to_ground_floor = "RETORNAR AO TERREO",
            options = "OPÇÕES",
            credits = "CRÉDITOS",
            feedback = "FEEDBACK",
            quit = "SAIR",
            website = "WEBSITE OFICIAL",
            discord = "DISCORD", 
            github = "GITHUB",
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
                controller_button_style = "ESTILO DOS BOTÕES", -- The style of the buttons shown in-game. As in, PS4 style buttons, Xbox style buttons...
                controller_button_style_value = {
                    detect = "detectar",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "DEADZONE DO JOYSTICK",
                vibration = "VIBRAÇÃO",
                low_deadzone_warning = "Valores baixos podem dar problema", -- Warning displayed when the joystick deadzone is very small
                note_deadzone = "Opções de deadzone vão ser aplicadas após sair desse menu",

                gameplay = "Gameplay",
                interface = "Interface",
                global = "Global",
                note_ui_min_button = "É necessário pelo menos 1 vínculo",
                note_global_keyboard = "Esses vínculos são iguais para todos os jogadores com teclado",
                note_global_controller = "Esses vínculos são iguais para todos os controles",
                -- Shown when navigating to player "%d"'s controller settings while no player of this number has joined yet.
                subtitle_no_player = "[⚠ SEM JOGADOR %d]",
                -- Shown in the controller settings while no controller is connected
                subtitle_no_controller = "[⚠ SEM CONTROLE CONECTADO]",
                no_buttons = "[SEM BOTÕES]",
                press_button = "[APERTE O BOTÃO]", -- Try to keep it as short as possible
                -- When assigning buttons, if the user presses a button that is already bound, it will instead
                -- remove that button.
                press_again_to_remove = "Aperte um botão já vinculado para remover",
                
                keyboard = "Teclado",
                keyboard_solo = "TECLADO (Padrão)",
                -- "Split" as in, "the 1st split keyboard user"
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
                sfx_volume = "[[ADDED / SOUND EFFECT VOLUME]]", -- Can also be translated as "effects volume" or "SFX volume"
                music_volume = "VOLUME DA MÚSICA",
                music_pause_menu = "MÚSICA NO MENU DE PAUSA", -- Whether music should play on the pause menu
                ambience = "SONS AMBIENTE",
            },
            visuals = {
                title = "Visuais",
                fullscreen = "TELA CHEIA",
                pixel_scale = "ESCALA DE PIXEL", -- How big should every pixel be displayed on-screen (x1, x2, ...)
                pixel_scale_value = {
                    auto = "auto",
                    max_whole = "máximo inteiro", -- Biggest whole number possible
                },
                vsync = "SINCRONIZAÇÃO VERTICAL",
                menu_blur = "DESFOQUE DO FUNDO DO MENU", -- Whether to apply the blurring effect in menu backgrounds
                background_speed = "VELOCIDADE DO FUNDO", -- How quickly the background scrolls 
                bullet_lightness = "BRILHO DOS PROJETEIS", -- How brightly bullets are rendered
            },
            game = {
                title = "Jogo",
                tutorial = "[[ADDED / TUTORIAL...]]",
                language = "IDIOMA...",
                timer = "CRONÔMETRO",
                mouse_visible = "MOSTRAR PONTEIRO DO MOUSE",
                pause_on_unfocus = "PAUSAR QUANDO SEM FOCO", -- whether the game should pause when the window loses focus
                screenshake = "VIBRAÇÃO DA TELA",
                skip_boss_intros = "[[ADDED / SKIP BOSS INTROS]]", -- Whether the game should skip the boss intro animations 
                show_fps_warning = "MOSTRAR AVISO DE FPS BAIXO", -- Whether the game should show a warning when its framerate is low

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
            kills = "Abates[[CHANGED / old:'Kills' / new:'Enemies killed']]", -- The amount of enemies the player has killed
            time = "Tempo", -- The time that the player took to complete the level
            floor = "Andar", -- Which storey the player was on when they died
            score = "[[ADDED / Score]]", 
            max_combo = "Combo Máximo", 

            continue = "CONTINUAR",
            quick_restart = "REINICIO RÁPIDO",
        },
        new_reward = {
            new_skin = "[[ADDED / New character!]]",
            new_upgrade = "[[ADDED / New upgrade!]]",
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
            ninesliced_presents = "[[ADDED / Ninesliced presents]]", -- Written EXCATLY "Ninesliced"
            game_by = "Um jogo por", -- As in, "A game by [newline] John". If it is not possible to have the name *after* this, one idea could be to translate as "Creator" (as in, "Creator [newline] John")
            leo_bernard = "[[ADDED / Léo Bernard]]", -- Please do not touch this
            music = "[[ADDED / Music]]",
            sound_design = "[[ADDED / Sound design]]",
            localization = "[[ADDED / Localization]]",
            additional_art = "[[ADDED / Additional art]]",
            playtesting = "Playtest",
            special_thanks = "Agradecimentos especiais",
            trailer = "[[ADDED / Trailer]]",
            asset_creators = "Criadores de recursos",
            tv_slideshow = "[[ADDED / TV slideshow contributors]]", -- Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            licenses = "Licensas de bibliotecas & recursos",
            more = "[[ADDED / And many more...]]", -- For the people that I might have forgotten in the special thanks section
            thank_you_for_playing = "[[ADDED / Thank you for playing!]]", -- Shown at the end of the credits

            x_by_y = "[[ADDED / %s by %s]]", -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s por %s / %s", -- "ASSET_NAME by CREATOR / LICENCE"
        },
        open_source = {
            title = "Bibliotecas open source",
        },
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
}
