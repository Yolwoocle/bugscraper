```
zip -9 -r game.love . -x ".git/*" "_tools/*"
```

Test sur pc: 
```
open /Applications/love.app game.love --stdin err.txt --stdout err.txt --stderr err.txt && tail -f err
```

Missing things todo:
- Faire un truc beau
- Faire un truc ou genre l'ecran est split en 2, et genre ça fait les directions a gauche et actions a droite



### IOS TODO:

- Better controls with bautiful buttons (placement et icons)

- Fix: Queued join player creer un joystick inutile

EN vrai osef:
    - Options: change button placement and size
    - Default only one player
        - And if controller / keyboard is detected add more
    - Menu controls with mouse (or direcional)
    - Desactiver le bouton interagir si il sert a rien
    - Si on rejoint avec 4 joueurs, y'a moyen qu'on puisse encore ajouter le touch_input mais en vrai jsp c'est un cas de bord a tester
    - Pas de touch input => pas de escape =>
    - Add: Vibrations


TODO LIST LEO: One player only


DONE:
- Menu avec fleche directionelle et joystick pour le in game
- Fix: Si tu fais un back il faut supprimer le touch is loaded
- Fix: Pk ca crash quand on lance le clavier?
- Remove quit options (and other options)
    - fix link (Or remove link)
        - BUG IN CLIENT OF UIKIT: The caller of UIApplication.openURL(_:) needs to migrate to the non-deprecated UIApplication.open(_:options:completionHandler:). Force returning false (NO).
- Fix icons avec ? (Fin faut faire les images dans button/touch)
- menu_optiions.lua
- Fix: Y'a des bugs avec le touch input quand tu join et unjoin (LE fait qu'il soit encore la si tu fait un return to floor zero et des truc comme ca a fix)
- Fix: La cafertier les input c'est pas le bon draw
- Fix (je pense): Le is_on_menu d'un player n'est pas enlevé a la validation de ce menu
- Shaders