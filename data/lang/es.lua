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
            solo = "Jugando solo",
            local_multiplayer = "Multijugador local",
        },
        details = {
            -- Yolwoocle note:
            -- I should have mentionned, but if you can please avoid english video gamy terms ("checkpoint", etc),
            -- except if they are the normal word for saying the thing;
            -- this is because this game might be played by non-gamers especially in local co-op
            waiting = "En el vestíbulo", -- *sigh* The europeans. (no one uses vestibulo on latam but better play it safe)
            playing = "Jugando (Piso %d/%d)",
            dying = "Derrotado (Piso %d/%d)",
            win = "Pantalla de victoria",
        },
    },
    game = {
        -- There's `demostración` but we can get away with just demo as is
        demo = "DEMO", -- Chip added to the game logo to indicate that this version is a demo
        fps = "%d FPS",
        congratulations = "FELICITACIONES!",
        win_thanks = "Gracias por jugar esta demo",
        win_wishlist = "Agregalo a tu lista de deseados en Steam :)", -- "Wishlist" is a verb
        win_prompt = "[Pausa para continuar]",
        warning_web_controller = "Algunos navegadores no tienen el soporte de mandos necesario",

    },
    level = {
        world_prefix = "Departmento %s",

        -- World names
        world_1 = "Recursos de Depuracionces", -- The pun is lost (Debugging resources)
        world_2 = "La fabrica",
        world_3 = "La sala de servidores",
        world_4 = "Ejecutivo",
    },
    gun = {
        -- Gun names
        machinegun = "Pistola de guisantes",
        triple = "Pimienta triple",
        burst = "Golpe de polen",
        shotgun = "Escopeta de frambuesa",
        minigun = "Ametralladora de semillas",
        ring = "Baya grande",
        mushroom_cannon = "Cañón de champiñones",
    },
    player = {
        name = {
            -- Player names
            -- No reason to change these during translation, except if:
            --  * it's more appropriate to use a transliteration, or to use the script of the concerned language (e.g. Leo -> Léo in French)
            --  * they clash with something specific to the language/culture (please notify me if it is the case)
            mio = "Mino", -- `Mío` = `mine`; mino = means nothing
            cap = "Cap",
            zia = "Zia",
            tok = "Tok",
            nel = "Nel",
            rico = "Rico",
            leo = "Leo",
        },
        abbreviation = "J%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
    },
    enemy = {
        dung = "Sr. estiércol", -- keeping the format but people pick up less onto the abbreviation of sir (Señor)
        bee_boss = "Su majestad",
        motherboard = "El maestro de redes",
    },
    upgrade = {
        tea = {
            title = "Té verde",
            description = "+2 ❤ temporales",
        },
        espresso = {
            title = "Espresso", -- Foreign word that is used as is here
            description = "Multiplica x2 la velocidad de disparo durante un minuto",
        },
        milk = {
            title = "Leche", -- Dad? you came back?
            description = "+1 ❤ permanente",
        },
        boba = {
            title = "Té de Boba",
            description = "Multiplica x2 el maximo de munición",
        },
        soda = {
            title = "Gaseosa", -- Cola works too but this is more specific.
            description = "+1 salto en el aire",
        },
        fizzy_lemonade = {
            title = "Limonada efervescente", -- Avoided the use of gaseosa as might be confusing.
            description = "Mantén saltar para bajar suavemente",
        },
    },
    input = {
        prompts = {
            -- All of these may be shown as button prompts (i.e., "[Arrow keys] Move", "[C] Jump", etc)
            move = "Mover",
            left = "Izquierda",
            right = "Derecha",
            up = "Arriba",
            down = "Abajo",
            jump = "Saltar",
            shoot = "Disparar",
            leave_game = "Salir",

            ui_left = "Izquierda (menu)",
            ui_right = "Derecha (menu)",
            ui_up = "Arriba (menu)",
            ui_down = "Abajo (menu)",
            ui_select = "Confirmar",
            ui_back = "Atrás",
            pause = "Pausar",

            join = "Unirse",
            -- Split sounds weird, share keyboard makes more sense
            split_keyboard = "Compartir teclado", -- Verb, as in "Press [key] to split the keyboard". Shown on the title screen when one keyboard player has joined. Try to keep short since space is limited there.

            -- Keep as is, there's no good way to use a word here
            jetpack = "Jetpack", -- Refers to "jetpackking", a move in the game
        },
    },
    menu = {
        see_more = "ver maś...",
        yes = "SÍ",
        no = "NO", -- The same thing here hehe
        quit = {
            description = "¿Seguro que quieres salir?"
        },
        confirm_retry = {
            -- Here refers to going back to the main menu to try another run, NOT restarting the game
            description = "Retry?", -- ADDED
        },
        pause = {
            title = "PAUSAR",
            resume = "CONTINUAR",
            retry = "REITENTAR",
            options = "OPCIONES",
            credits = "CREDITOS",
            feedback = "COMENTARIOS",
            quit = "SALIR",
            website = "SITIO OFICIAL",
            discord = "UNIRSE AL DISCORD",
        },
        options = {
            title = "OPCIONES",

            input = {
                title = "Entrada",
                input = "Configuración de entrada...",
            },
            input_submenu = {
                title = "CONFIGURACIÓN DE ENTRADA",
                reset_controls = "REINICIAR CONTROLES",
                controller_button_style = "ESTILO DE BOTONES",
                controller_button_style_value = {
                    detect = "detectar",
                    switch = "Switch", -- A bit of context
                    playstation4 = "PlayStation 4", -- works as is
                    playstation5 = "PlayStation 5", -- works as is
                    xbox = "Xbox",   -- works as is
                },
                deadzone = "ZONA MUERTA DE LA PALANCA",
                vibration = "VIBRACIÓN",
                low_deadzone_warning = "Tolerancias de zona muerta baja pueden causar problemas", -- Warning displayed when the deadzone is very small
                note_deadzone = "Ajustes de zona muerta tomarán efecto al salir de este menu",

                gameplay = "Jugabilidad",
                interface = "Interfaz",
                global = "Global", -- works as is
                note_ui_min_button = "Al menos una configuración es requerida",
                note_global_keyboard = "Estas configuraciones son las mismas para todos los jugadores de teclado",
                note_global_controller = "Estas configuraciones son las mismas para todos los controladores",
                subtitle_no_player = "[⚠ NO HAY JUGADOR %d]", -- Shown when navigating to player "%d"'s controller settings while no player of this number has joined yet.
                subtitle_no_controller = "[⚠ NO HAY MANDO CONECTADO]", -- Shown in the controller settings while no controller is connected
                no_buttons = "[NO HAY BOTÓN]",
                press_button = "[PRESIONE BOTÓN]", -- Try to keep it short
                press_again_to_remove = "Presione una tecla ya vinculada para removerla",

                keyboard = "Teclado",
                keyboard_solo = "TECLADO (Por defecto)",
                keyboard_p1 = "TECLADO (Mitad 1)", -- Split is an adjective here; as in, "the 1st split keyboard user"
                keyboard_p2 = "TECLADO (Mitad 2)", -- Half works better than split however it still sounds weird.

                controller = "MANDO",
                controller_p1 = "MANDO (Jugador 1)",
                controller_p2 = "MANDO (Jugador 2)",
                controller_p3 = "MANDO (Jugador 3)",
                controller_p4 = "MANDO (Jugador 4)",
            },
            audio = {
                title = "Audio", -- works as is
                sound = "SONIDO",
                volume = "VOLUMEN",
                music_volume = "VOLUMEN DE LA MÚSICA",
                music_pause_menu = "REPRODUCIR MÚSICA DURANTE EL MENU DE PAUSA", -- Whether music should play on the pause menu
            },
            visuals = {
                title = "Gráficos",
                fullscreen = "PANTALLA COMPLETA",
                pixel_scale = "ESCALA DE LOS PIXELES", -- How big should every pixel be displayed on-screen
                pixel_scale_value = {
                    auto = "automática",
                    -- max_whole = "Escala máxima entera", -- Max integer scale
					max_whole = "maximo entero",
                },
                vsync = "VSYNC",         -- Sincronización vertical; if you want to be fancy but nobody really does that tbh
                menu_blur = "DIFUMINAR FONDO DEL MENU",
                background_speed = "VELOCIDAD DEL FONDO",
                bullet_lightness = "BRILLO DE BALAS",
            },
            game = {
                title = "Juego",
                language = "IDIOMA...",
                timer = "TEMPORIZADOR DE PARTIDA", -- round timer; timer as is sounds weird with no context
                mouse_visible = "MOSTRAR PUNTERO DEL RATÓN", -- /!\ GOTCHA /!\: latam uses `mouse` but the goddamn europeans use `rat`
                pause_on_unfocus = "PAUSAR AL PERDER EL FOCO", -- whether the game should pause when the window loses focus
                screenshake = "SACUDIDO DE PATALLA", -- Same gotcha latam uses the foreign word
                skip_boss_intros = "OMITIR INTRODUCCIÓN DE JEFES",
                -- `Warn about low performance`
                show_fps_warning = "AVISAR DE BAJO RENDIMIENTO", -- Whether the game should show a warning when its framerate is low

            },
            language = {
                title = "IDIOMA",
            },
            confirm_language = {
                description = "¿Desea reiniciar el juego para aplicar el nuevo idioma?",
            },
        },
        feedback = {
            title = "COMENTARIOS", -- comments
            bugs = "REPORTAR UN PROBLEMA 🔗",
            features = "PROPONER UNA IDEA 🔗",
        },
        game_over = {
            title = "JUEGO TERMINADO!", -- *sigh* Europeans use `fin de la partida` but the latam version `game over` (literally 1:1) fits better
            kills = "Enemigos matados", -- The amount of enemies the player has killed
            time = "Tiempo transcurrido", -- The time that the player took to complete the level
            floor = "Piso",      -- Which storey the player was on when they died
            continue = "CONTINUAR",
            quick_restart = "QUICK RESTART", --ADDED
        },
        win = {
            title = "FELICITACIONES!",
            wishlist = "Agregalo a tu lista de deseados en Steam", -- "wishlist" is a verb
            continue = "CONTINUAR",
        },
        joystick_removed = {
            title = "MANDO DESCONECTADO",
            description = "Por favor conecte los siguientes mandos:",
            continue = "CONTINUAR DE TODAS FORMAS",
            item = "Jugador %d (%s)", -- e.g. "Player 2 (Xbox Controller)"
        },
        credits = {
            -- not all people understand the symbol `&` I would like to get away with it
            -- but better play it safe, if you desire you can replace `y` for `&`and get away with it
            title = "CREDITOS",
            game_by = "Un juego por",
            game_by_template = "By Léo Bernard y sus amigos", -- Used on the title screen.
            music_and_sound_design = "Musica y diseño auditivo", -- auditive design because sound design sounds weird
            localization = "Localización",
            playtesting = "Probadores de Jugabilidad",
            special_thanks = "Agradecimentos especiales",
            asset_creators = "Creadores de recursos",
            tv_slideshow = "TV slideshow contributors", -- ADDED // Refers to the powerpoint TV slideshow on the title screen, which was contributed by a variety of people 
            tv_slideshow_submit = "Submit yours...", -- ADDED // Leads to a web page where people can submit their own slides
            licenses = "Recursos y Lisencias de librerías",

            x_by_y =     "%s por %s", -- "ASSET_NAME by CREATOR". Used to credit assets such as sound effects
            asset_item = "%s por %s / %s", -- "ASSET_NAME by CREATOR / LICENCE". Used to credit assets such as sound effects
        },
        open_source = {
            title = "Licencias de código abierto",
        },
    },
}
