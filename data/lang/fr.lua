return {
    steam = {
        short_description = [[Bienvenue dans le bugscraper. Gravissez les étages de cette tour remplie de parasites dans ce jeu de plateforme et de tir 2D, et combattez des vagues d'ennemis à chaque étage alors qu'ils viennent pour votre peau (ou plutôt votre exosquelette).]],
        description = [[Bienvenue dans le bugscraper. Ici, des parasites du monde entier viennent se rassembler. Votre mission : les arrêter avant qu'il ne soit trop tard ! 🐜 Dans ce jeu de tir et de plateforme, vous incarnez Mio, une fourmi courageuse, essayant d'empêcher les employés d'un gratte-ciel rempli de parasites de corrompre le monde avec un champignon mortel. 🐛 Vous affronterez des vagues d'ennemis dans un ascenseur, alors qu'ils cherchent à atteindre votre peau (ou plutôt votre exosquelette) à chaque étage. 🐝 Utilisez une grande variété d'armes et d'améliorations pour les éliminer et préparez-vous à combattre pour l'étage suivant ! 🐞 Jouez en solo ou avec jusqu'à 4 amis en coopération locale.]]
    },
    discord = { -- Text utilisé pour la présence enrichie Discord
        state = {
            solo = "Joue en solo",
            local_multiplayer = "Multijoueur local",
        },
        details = {
            waiting = "Dans le lobby",
            playing = "En jeu (étage %d/%d)",
            dying = "Vaincu (étage %d/%d)",
            win = "Écran de victoire",
        },
    },
    game = {
        demo = "DÉMO", -- Mention ajoutée au logo du jeu pour indiquer que cette version est une démo
        fps = "%d FPS",
        congratulations = "FÉLICITATIONS !",
        win_thanks = "Merci d'avoir joué à la démo",
        win_wishlist = "Ajoutez le jeu à votre liste de souhaits sur Steam :)",
        win_prompt = "[Pause pour continuer]",
        warning_web_controller = "Certains navigateurs peuvent ne pas prendre en charge correctement les manettes",
    },
    level = {
        world_prefix = "Service %s", 

        -- Noms des mondes
        world_1 = "Ressources parasitaires",
        world_2 = "L'usine",
        world_3 = "La salle des serveurs",
        world_4 = "Direction",
    },
    gun = {
        -- Noms des armes
        machinegun = "pistolet à pois",
        triple = "triple piment",
        burst = "éclat de pollen",
        shotgun = "fusil à framboises",
        minigun = "minigun à graines",
        ring = "grosse baie",
        mushroom_cannon = "canon à champignons",
    },
    player = {
        name = {
            -- Noms des joueurs
            mio = "Mio",
            cap = "Cap",
            zia = "Zia",
            tok = "Tok",
            nel = "Nel",
            rico = "Rico",
            leo = "Leo",
        },
        abbreviation = "J%d", -- Abréviation pour désigner les joueurs par leur numéro. Exemple : en français, "J1" signifie "Joueur 1".
    },
    enemy = {
        dung = "M. Dung",
    },
    upgrade = {
        tea = {
            title = "Thé Vert",
            description = "+2 ❤ temporaires",
        },
        espresso = {
            title = "Espresso",
            description = "x2 vitesse de tir pendant une minute",
        },
        milk = {
            title = "Lait",
            description = "+1 ❤ permanent",
        },
        peanut = {
            title = "Cacahuète",
            description = "x2 munitions maximales",
        },
        energy_drink = {
            title = "Boisson Énergisante",
            description = "La barre de furie se vide plus lentement",
        },
        soda = {
            title = "Soda",
            description = "+1 saut en l'air",
        },
    },
    input = {
        prompts = {
            move = "Se déplacer",
            left = "Gauche",
            right = "Droite",
            up = "Haut",
            down = "Bas",
            jump = "Sauter",
            shoot = "Tirer",
            leave_game = "Quitter",

            ui_left = "Menu gauche",
            ui_right = "Menu droite",
            ui_up = "Menu haut",
            ui_down = "Menu bas",
            ui_select = "Confirmer",
            ui_back = "Retour",
            pause = "Pause",

            join = "Rejoindre",
            split_keyboard = "Clavier partagé",
            unsplit_keyboard = "Clavier non partagé",

            jetpack = "Jetpack",
        },
    },
    menu = {
        see_more = "voir plus...",
        yes = "OUI",
        no = "NON",
        quit = {
            description = "Êtes-vous sûr de vouloir quitter ?"
        },
        pause = {
            title = "PAUSE",
            resume = "REPRENDRE",
            retry = "RECOMMENCER",
            options = "OPTIONS",
            credits = "CRÉDITS",
            feedback = "AVIS",
            quit = "QUITTER",
            website = "SITE OFFICIEL",
            discord = "REJOINDRE LE DISCORD",
            twitter = "SUIVRE SUR TWITTER (𝕏)",
        },
        options = {
            title = "OPTIONS",

            input = {
                title = "Contrôles",
                input = "PARAMÈTRES DES CONTRÔLES...",
            },
            input_submenu = {
                title = "Paramètres des contrôles",
                reset_controls = "RÉINITIALISER LES CONTRÔLES",
                controller_button_style = "STYLE DES BOUTONS",
                controller_button_style_value = {
                    detect = "détecter",
                    switch = "Switch",
                    playstation4 = "PlayStation 4",
                    playstation5 = "PlayStation 5",
                    xbox = "Xbox",
                },
                deadzone = "ZONE MORTE JOYSTICK",
                vibration = "VIBRATION",
                low_deadzone_warning = "Des valeurs faibles peuvent causer des problèmes",
                note_deadzone = "Les paramètres de la zone morte seront appliqués en quittant ce menu",

                gameplay = "Gameplay",
                interface = "Interface",
                global = "Global",
                note_ui_min_button = "Au moins une attribution est requise",
                note_global_keyboard = "Ces paramètres sont communs à tous les joueurs au clavier",
                note_global_controller = "Ces paramètres sont communs à toutes les manettes",
                subtitle_no_player = "[⚠ PAS DE JOUEUR %d]",
                subtitle_no_controller = "[⚠ AUCUNE MANETTE CONNECTÉE]",
                no_buttons = "[AUCUN BOUTON]",
                press_button = "[APPUYEZ SUR UN BOUTON]",
                press_again_to_remove = "Appuyez de nouveau sur un bouton attribué pour le supprimer",

                keyboard = "Clavier",
                keyboard_solo = "CLAVIER (Par défaut)",
                keyboard_p1 = "CLAVIER (Partagé 1)",
                keyboard_p2 = "CLAVIER (Partagé 2)",

                controller = "Manette",
                controller_p1 = "MANETTE (Joueur 1)",
                controller_p2 = "MANETTE (Joueur 2)",
                controller_p3 = "MANETTE (Joueur 3)",
                controller_p4 = "MANETTE (Joueur 4)",
            },
            audio = {
                title = "Audio",
                sound = "SON",
                volume = "VOLUME",
                music_volume = "VOLUME DE LA MUSIQUE",
                music_pause_menu = "MUSIQUE DANS LE MENU PAUSE",
                background_sounds = "SONS DE FOND",
            },
            visuals = {
                title = "Visuels",
                fullscreen = "PLEIN ÉCRAN",
                pixel_scale = "ÉCHELLE DES PIXELS",
                pixel_scale_value = {
                    auto = "auto",
                    max_whole = "max entier",
                },
                vsync = "SYNCHRONISATION VERTICALE",
                menu_blur = "FLUO MENU",
                background_speed = "VITESSE DU FOND",
            },
            game = {
                title = "Gameplay",
                timer = "TIMER",
                mouse_visible = "AFFICHER LE CURSEUR",
                pause_on_unfocus = "PAUSE EN CAS DE PERTE DE FOCUS",
                screenshake = "TREMBLEMENT D'ÉCRAN",
                show_fps_warning = "AFFICHER L'AVERTISSEMENT DE BAS FPS",
            }
        },
        feedback = {
            title = "AVIS",
            bugs = "SIGNALER UN BUG 🔗",
            features = "SUGGÉRER UNE FONCTIONNALITÉ 🔗",
        },
        game_over = {
            title = "GAME OVER!",
            kills = "Éliminations",
            time = "Temps",
            floor = "Étage",
            continue = "CONTINUER",
        },
        win = {
            title = "FÉLICITATIONS !",
            wishlist = "AJOUTER À LA LISTE DE SOUHAITS SUR STEAM",
            continue = "CONTINUER",
        },
        joystick_removed = {
            title = "MANETTE DÉCONNECTÉE",
            description = "Veuillez connecter les manettes suivantes :",
            continue = "CONTINUER QUAND MÊME",
            item = "Joueur %d (%s)",
        },
        credits = {
            title = "CRÉDITS",
            game_by = "Un jeu de",
            game_by_template = "Par Léo Bernard & ses amis", -- Utilisé sur l'écran titre
            music_and_sound_design = "Musique et conception sonore",
            playtesting = "Tests de jeu",
            special_thanks = "Remerciements spéciaux",
            asset_creators = "Créateurs d'assets",
            licenses = "Licences des assets & bibliothèques",

            asset_item = "%s par %s / %s", -- "ASSET_NAME par CREATOR / LICENCE". Utilisé pour créditer des assets comme les effets sonores
        },
        open_source = {
            title = "Bibliothèques open source",
        },
    },
}
