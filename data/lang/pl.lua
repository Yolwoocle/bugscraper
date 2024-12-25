return {
	language = {
		-- These should be kept untranslated in their original language ("english", "français", "中文", etc)
		en = "English",
		es = "Español",
		fr = "Français",
		zh = "简体中文",
		pl = "Polski",
		br = "Português Brasileiro",
	},
	steam = {
		--[[TODO]]
		short_description =
		[[Witaj w bugscraper. Wznieś się na szyt tej wypełnionej szkodnikami wieży w tej dwuymiarowej srzelance 2D i walcz z falami wrogów na każdym piętrze, którzy przybywają po Twoją skórę (a raczej egzoszkielet).]],
		description =
		[[Witaj w bugscraper, to tutaj zbierają się szkodniki z całego świata. Twoja misja: powstrzymać zanim będzie już za późno!🐜W tej platformowej strzelance wcielasz się w Mio, odważną mrówkę, próbującą powstrzymać pracowników pełnego robaków drapacza chmur przed zepsuciem świata śmiercionośnym grzybem.🐛Będziesz walczyć z falami wrogów w windzie, którzy przybywają po Twoją skórę (a raczej egzoszkielet) na każdym piętrze.🐝Korzystając z szerokiej gamy broni i ulepszeń, wyeliminuj ich i przygotuj się do walki o następne piętro!🐞Graj solo lub z maksymalnie 4 znajomymi w lokalnym trybie kooperacji wieloosobowej.]]
	},
	discord = { -- Text used for Discord rich presence
		state = {
			solo = "Gra jednoosobowa",
			local_multiplayer = "Lokalna gra wieloosobowa",
		},
		details = {
			waiting = "W lobby",
			playing = "W grze (piętro %d/%d)",
			dying = "Umiera (piętro %d/%d)",
			win = "Ekran zwycięstwa",
		},
	},
	game = {
		demo = "DEMO", -- Chip added to the game logo to indicate that this version is a demo
		fps = "%d FPS",
		congratulations = "GRATULACJE!",
		win_thanks = "Dziękujemy za zagranie w werje demo",
		win_wishlist = "Dodaj grę do listy życzeń na Steam :)", -- "Wishlist" is a verb
		win_prompt = "[Pauza aby kontynuować]",
		warning_web_controller = "Niektóre przeglądarki mogą mieć niepełne wsparcie dla kontrolerów",

	},
	level = {
		world_prefix = "Dział %s",

		-- World names
		world_1 = "Insekty w plikach",
		world_2 = "Maszyna do kopiowania",
		world_3 = "Serwerowy piekielnik",
		world_4 = "Wielki szef",
	},
	gun = {
		-- Gun names
		machinegun = "Grosznik",       -- hard to translate to english, kinda a mix beween pea and gun
		triple = "Paprypak",           -- it's a mix of two words pepper and pack the idea is that peppers are commonly sold in packs so it's a pack of peppers
		burst = "Seriopyłek",          -- mix between pollen and burst
		shotgun = "Malinada",          -- mix of raspberry and lemonade
		minigun = "Pestkotron",        -- not even sure how to translate it to english :D it's a word made up that mixes the 'seed' (pestka) into the name
		ring = "Jagodynator",          -- hard to translate it's a made up word that mixes berry(jagody) and word nator which I'm not even sure how to translate back to what it would mean in english
		mushroom_cannon = "Grzybomor", -- hard to translate it back to english, in polish it's just a person who is very much into collecting mushrooms :P
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
		abbreviation = "G%d", -- Short appreviation to denote players by their number. Example: in english, "P1" means "Player 1", in french "J1" means "Joueur 1".
	},
	enemy = {
		dung = "Pan Odchodek",
		bee_boss = "The Queen",        -- ADDED
		motherboard = "The Webmaster", -- ADDED
	},
	upgrade = {
		tea = {
			title = "Zielona Herbata",
			description = "+2 tymczasowe ❤",
		},
		espresso = {
			title = "Espresso",
			description = "x2 prędkość strzelania przez minute",
		},
		milk = {
			title = "Mleko",
			description = "+1 permamentne ❤",
		},
		boba = {
			title = "Orzeszek", -- CHANGED: Boba
			description = "x2 maks amunicji",
		},
		energy_drink = {
			title = "Napój Energetyczny",
			description = "Pasek furii zanika wolniej",
		},
		soda = {
			title = "Cola",
			description = "+1 skok w powietrzu",
		},
		fizzy_lemonade = { -- ADDED
			title = "Fizzy Lemonade",
			description = "Hold jump to glide",
		},
	},
	input = {
		prompts = {
			move = "Poruszanie",
			left = "Lewo",
			right = "Prawo",
			up = "Góra",
			down = "Dół",
			jump = "Skok",
			shoot = "Strzał",
			leave_game = "Wyjdź",

			ui_left = "Lewo (Menu)",
			ui_right = "Prawo (Menu)",
			ui_up = "Góra (Menu)",
			ui_down = "Dół (Menu)",
			ui_select = "Zatwierdź",
			ui_back = "Wstecz",
			pause = "Pauza",

			join = "Dołącz",
			split_keyboard = "Podziel klawiature",
			unsplit_keyboard = "Połącz klawiature",

			jetpack = "Jetpack",
		},
	},
	menu = {
		see_more = "zobacz wiecej...",
		yes = "TAK",
		no = "NIE",
		quit = {
			description = "Czy aby napewno chcesz wyjść?"
		},
		pause = {
			title = "PAUZA",
			resume = "WZNÓW",
			retry = "SPRÓBUJ PONOWNIE",
			options = "OPCJE",
			credits = "TWÓRCY",
			feedback = "ZOSTAW OPINIE",
			quit = "WYJDŹ",
			website = "OFICJALNA STRONA",
			discord = "DOŁĄCZ NA DISCORDZIE",
			twitter = "ZAOBSERWUJ NA TWITTERZE (𝕏)",
		},
		options = {
			title = "OPCJE",

			input = {
				title = "Sterowanie",
				input = "USTAWIENIA STEROWANIA...",
			},
			input_submenu = {
				title = "USTAWIENIA STEROWANIA",
				reset_controls = "ZRESETUJ STEROWANIE",
				controller_button_style = "STYL PRZYCISKÓW",
				controller_button_style_value = {
					detect = "wykryj",
					switch = "Switch",
					playstation4 = "PlayStation 4",
					playstation5 = "PlayStation 5",
					xbox = "Xbox",
				},
				deadzone = "MARTWA STREFA JOYSTICKA",
				vibration = "WIBRACJE",
				low_deadzone_warning = "Niskie wartości mogą powodować problemy",
				note_deadzone = "Ustawienia martwej strefy zostaną zastosowane po opuszczeniu tego menu",

				gameplay = "Rozgrywka",
				interface = "Interfejs",
				global = "Globalne",
				note_ui_min_button = "Co najmniej jedno przypisanie wymagane",
				note_global_keyboard = "Te przypisania sa takie same dla wszystkich klawiatur",
				note_global_controller = "Te przypisania sa takie same dla wszystkich kontrolerów",
				subtitle_no_player = "[⚠ BRAK GRACZA %d]",
				subtitle_no_controller = "[⚠ BRAK PODŁĄCZONEGO KONTROLERA]",
				no_buttons = "[BRAK PRZYCISKÓW]",
				press_button = "[WCIŚNIJ PRZYCISK]",
				press_again_to_remove = "Naciśnij już przypisany przycisk, aby go usunąć",

				keyboard = "Klawiatura",
				keyboard_solo = "KLAWIATURA (Standard)",
				keyboard_p1 = "KLAWIATURA (Podział 1)",
				keyboard_p2 = "KLAWIATURA (Podział 2)",

				controller = "Kontroler",
				controller_p1 = "KONTROLER (Gracz 1)",
				controller_p2 = "KONTROLER (Gracz 2)",
				controller_p3 = "KONTROLER (Gracz 3)",
				controller_p4 = "KONTROLER (Gracz 4)",
			},
			audio = {
				title = "Dźwięk",
				sound = "DŹWIĘK",
				volume = "GŁOŚNOŚĆ",
				music_volume = "GŁOŚNOŚĆ MUZYKI",
				music_pause_menu = "MUZYKA W MENU PAUZY",
			},
			visuals = {
				title = "Elementy wizualne",
				fullscreen = "PEŁEN EKRAN",
				pixel_scale = "SKALA PIXELI",
				pixel_scale_value = {
					auto = "automatyczna",
					max_whole = "maksymalnie cała",
				},
				vsync = "VSYNC",
				menu_blur = "ROZMYCIE TŁA MENU",
				background_speed = "PRĘDKOŚĆ TŁA",
				bullet_lightness = "BULLET BRIGHTNESS", -- ADDED
			},
			game = {
				title = "Gra",
				language = "JĘZYK...",
				timer = "LICZNIK CZASU",
				mouse_visible = "POKAŻ KURSOR",
				pause_on_unfocus = "PAUZA PRZY UTRACIE OKNA",
				screenshake = "TRZĘSIENIE EKRANU",
				skip_boss_intros = "SKIP BOSS INTROS", -- ADDED
				show_fps_warning = "OSTRZEŻENIE O NISKIEJ LICZBIE FPS",

			},
			language = {
				title = "JĘZYK",
			},
			confirm_language = {
				description = "Czy uruchomić grę ponownie, aby zastosować nowy język?",
			},
		},
		feedback = {
			title = "ZOSTAW OPINIE",
			bugs = "ZGŁOŚ BŁĄD 🔗",
			features = "ZGŁOŚ PROPOZYCJE 🔗",
		},
		game_over = {
			title = "KONIEC GRY!",
			kills = "Zabici wrogowie",
			time = "Czas",
			floor = "Piętro",
			-- max_combo = "Maks combo",
			continue = "KONTYNUUJ",
		},
		win = {
			title = "GRATULACJE!",
			wishlist = "DODAJ DO LISTY ŻYCZEŃ NA STEAM", -- "wishlist" is a verb
			continue = "KONTYNUUJ",
		},
		joystick_removed = {
			title = "KONTROLER ODŁĄCZONY",
			description = "Podłącz następujące kontrolery:",
			continue = "IGNORUJ",
			item = "Gracz %d (%s)",
		},
		credits = {
			title = "TWÓRCY",
			game_by = "Gra autorstwa",
			game_by_template = "Léo Bernard & przyjaciele", -- Used on the title screen.
			music_and_sound_design = "Muzyka i projektowanie dźwięku",
			localization = "Lokalizacja",
			playtesting = "Testowanie gry",
			special_thanks = "Specjalne podziękowania",
			asset_creators = "Autorzy zasobów",
			licenses = "Licencje na zasoby i biblioteki",

			asset_item = "%s stworone przez %s / %s", -- "ASSET_NAME by CREATOR / LICENCE". Used to credit assets such as sound effects
		},
		open_source = {
			title = "Biblioteki otwartoźródłowe",
		},
	},
}
