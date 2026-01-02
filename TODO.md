Playtest avec alexandre & esteban
[x] = done
[~] = partially done
[?] = cannot reproduced
[-] = abandonned

Bugs
- [ ] BUG deco reco casque
- [ ] CEO office cutscene should not take "background speed" param into account 
- [ ] (mineur) maintenir gauche ou droit fait baisser le HUD de quelques pixels 
- [ ] (mineur) ghost parfois quand tu tournes puis change de direction ça tourne pas entièrement 
- [ ] (mineur) elevator background in cafeteria should change w world
- [ ] (mineur) BUG hign DPI diagonal artifact
- [ ] bug: you can jump super high on larva when holding jump for some reason

Visu
- [ ] (mineur) effet de miel pas beau 

Musique
- [ ] bug: ground floor music can be heard quickly when quick restarting
- [ ] musique incorrecte se joue au RDC quand tu restart une game 
- [ ] (mineur) transition musique café après avoir pris une upgrade t'en a pas c'est pas ouf
- [x] musique devrait pas reprendre du début après une cafétéria
- [x] intros de musique

Menus
- [ ] option to invert buttons for ui_confirm and ui_back

Ennemis/boss
- [ ] revoir le dynamisme de l'entrée du boss du monde 2 revoir le timing, ça fait bizarre quand la lumière s'éteint et direct après que tu tues le dernier ennemi
- [ ] football miel a un cool down trop grand
- [ ] chipper devrait avoir plus de cues visuelles pour l'accessibilité sourd

Multi
- [ ] il faut un son et un effet très très remarquable quand tu respawn

Gun
- [ ] le pollen burst est nul
- [ ] mushroom cannon est bof
- [ ] effet visuel bizarre quand tu aim vers le haut avec le big berry (tu tiens pas le gun dans ta main)
- [ ] aligner correctement les mains et le gun

Autre
- [ ] Options de manette devraient être par manette et pas par num de joeur
- [ ] équilibrer mieux les coeurs
- [ ] problème librairie de collision quand il y a beaucoup de collision qui s'intersectent notamment fumée
- [ ] porte finale devrait que s'ouvrir si t'es à côté 
- [ ] idée upgrade : truc qui te fait respawn avec un coeur quand tu meurs 
- [ ] fixer le problème avec les config files... allez courage...
- [ ] stats !!
- [ ] jcrois que la musique de cafeteria empty se joue pas correctement
- [ ] faire l'animation correcte de porte pour le M2
- [ ] ajouter autres portes pour encourager à bouger 
- [ ] pouvoir rejoindre le jeu même après le début d'une partie
- [ ] skip cutsene option

Son 
- [ ] mettre les contant_sound en spatial audio (e.g. les buzz de mouche)
- [ ] Son de stack de feuilles devrait être plus musical 
- [ ] son pas de stamina trop aigu
- [ ] son de mouche il préfère avant
- [ ] son glass footstep est bizarrew on dirait que tu marches sur des morceaux 

-----------

PlayerSorbonne playtest

- [ ] rajouter plus de trucs dans les cafets
- [ ] effet plus pompesque quand tu revive
- [ ] effet de particules quand tu prends un cœur ?
- [ ] enseigner aux joueurs ce que fait le fantôme ptêtre ?
- [ ] rendre les joueurs fantôme plus utiles 
- [ ] quand tu mets en pause dans le noir, les persos sont pas noirs
- [ ] vague avec les chippers pour le boss du M3 est trop dur
- [ ] y decrait pas y avoir de screenshake sur l'écran de pause
- [ ] pas intuitif que tu peux pas stomp les larves du flying spawner

Playtest lins
- [ ] Pour certaines armes le rocket jump emmène directement tout en haut c'est dur de jauger.


## ideas
- plus d'interactions entre les joueurs (utiliser le nv bouton ?)
- différentes chaînes (🔗) pour les mondes après le monde 1

pas autoriser les joueurs à mettre le mm bouton pour back et confirmer


## ? / remarques
- il y a 2 barres lors de boss pas fou
- barre du furie est distrayante
- "interact" icon looks like a middle finger 
- à 4 joueurs c'est le bordel, ça serait bien d'utiliser tout l'écran 
- les joueurs comprennent pas comment démarrer le jeu (ils vont à droite)
- en fantôme tu sais pas si tu fais des dégâts 

-----------

Playtest "Lins" (linscd)

L'espace est petit et ça devient rapidement encombré. 
 Les ennemis qui m'ont fait perdre le plus de cœurs: 
- les ruches 
- Les petits vers (invoqué par la ruche ou par défaut). Trop petits pour être touchés par certaines armes
- Ceux qui foncent puis qui explosent : j'ai l'impression que l'explosion est grande + ça cache l'écran et ça rajoute au bordel quand il y a beaucoup de mobs  
- les araignées en essayant de me mettre au dessus au moment du spawn mais ça c'est moi qui suit con. D'ailleurs on dirait pas trop des araignées, il manque des pattes non ? 
- coquilles avec un ver dedans, leur sauter dessus est dangereux avec l'invocation

Le canon champignon j'ai pas trouvé ça ouf, par contre le minigun pépin  et le tri-pistolet (je sais plus le nom) j'ai trouvé ça fort.

La jauge de combo super plaisante mais je pense qu'il y a un truc que j'ai pas compris. A 2 reprises j'ai tué des mobs alors que j'allais perdre mon combo (la jauge était basse) et ça s'est pas rempli. La première fois c'était en écrasant une punaise.

On se sent un peu victime de l'aléatoire pour les cœurs. Par exemple : Je n'ai pas l'impression d'avoir fait une bonne run si je ne me suis fait touché que 1-2 fois jusqu'à l'étage 50, je n'ai aucun avantage par rapport à une run ou je me suis fait touché 8 fois (sauf peut être le combo + le fait de ne pas prendre les cœurs temporaires).  Peut-être faire en sorte de pouvoir récupérer des cœurs en shop en alternative à une amélioration ? -> permet de récompenser les bonnes runs avec des amélios à chaque shop et permet de ne pas dépendre de l'aléatoire pour la récup de cœur. 


La barre de vie des boss est un peu petite. 



---------------------------------------

DONE

- [-] viser en analogue avec le joystick ? (Un peu d'autoaim à la limite ?)
- [-] la lettre de démission devrait être dans la second main
- [x] stink bug pas assez visible M3
- [-] lettre de démission devrait despawn quand tu la prends

- [x] bug: cannot bind "join game" keyboard binding
- [x] joueurs croient que tu peux stomp les larves volantes -> remplacer le sprite par un petit cocon piquant
- [x] petit avertissement avant que les Spike apparaissent au monde 2
- [x] Pour le shop : On peut sortir de l'ascenseur avant qu'il ne s'ouvre. On traverse un peu le mur, c'est pas super choquant. 
- [x] jump impact sound of mr dung plays when he STARTS jump
- [x] no gamepad vibration in mr dung jump
- [-] cam devrait pan à gauche apres cafet
- [?] c'est chiant quand il y a d'autres gens qui utilisent leur manette et que un joueur met en pause
- [?] bug: no flashing red when no stamina
- [x] bug: comball bullets hidden for first frames
- [x] J'aurais bien aimé voir le combo max sur l'écran de fin de run.
- [x] bug : gun dans tutoriel spawn un gun vide
- [x] BUG CRITIQUE: tu peux appuyer sur confirm et back en mm temps sur l'écran de sélection et ça crée plusieurs joueurs 
- [x] BUG CRITIQUE tu peux pas exit la cafet si ya deux joueurs fantôme (J1 FANTOME, J2 FANTOME, J3 ALIVE)
- [x] BUG tu peux pas démarrer la game s'il y a JUSTE un J3 dans la game
- [x] BUG le même gun est appliqué à tous les joueurs sur le tutoriel 
- [x] quand tu revive et que tu as de lait tu revives avec 4 coeurs
- [x] les shooter ennemis tirent des balles sombres quand l'option est activée
- [x] cinématique finale tu peux bouger si t'es fantôme
- [x] if you press "continue anyway", and go back to main menu, there's no way to do anything (softlock) -> solution: kick players without any connected controllers on the ground floor menu
- [x] w1 boss parfois prend pas des dégâts quand il se prend une boule
- [?] bug : parfois le combo affiche "combo %d"
- [~] tu peux pas sauter pendant un frame freeze (so tu appuies sur jump pdt un freeze ça te fait pas sauter à la fin d'un freeze) 
- [x] monde 3 éclair électrique de bulb buddy spawn à un endroit aléatoire et fait des dégâts 
- [x] rollopods shouldn't be pushable during their "rolling" phase
- [x] indicateur de joueur dans les menusprend pas en compte la couleur de texte (cf avec zia)
- [x] texte "J1", "J2" giga haut dans tuto
- [x] texte de combo pas très lisible
- [x] city devrait descendre de plus en plus plus tu montes 
- [x] text hover sur les upgrades en multi chiant
- [x] mettre les upgrades en haut à droite au lieu d'en bas
- [x] chiant de pas pouvoir viser à travers les semisolid 
- [x] la musique du lobby est chiante
- [x] derniere vague monde 4 pas fou
- [x] ça serait cool si tous les joueurs morts respawn aux cafétéria
- [x] effet visuel quand pas d'ammo
- [x] afficher le nom d'une arme quand tu hover dessus 
- [x] faire que tu peux swap avec ton ancienne arme
- [x] cafèt choisir upgrade avec un menu
- [x] "return to ground floor" should return to ground floor in tutorial
- [x] pan la caméra au centre quand 0 joueurs au rdc
- [x] feedback pour indiquer qu'il faut que les joueurs soient devant la porte
  - idée : outline, cercle, etc comme dans unrailed