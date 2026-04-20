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

- Remove quit options (and other options)
    - fix link (Or remove link)
        - BUG IN CLIENT OF UIKIT: The caller of UIApplication.openURL(_:) needs to migrate to the non-deprecated UIApplication.open(_:options:completionHandler:). Force returning false (NO).

- Fix icons avec ?

- Better controls with bautiful buttons



EN vrai osef:
    change button placement and size
    - Default only one player
        - And if controller / keyboard is detected add more

    - Menu controls with mouse (or direcional)
    - Desactiver le bouton interagir si il sert a rien

TODO better:
- menu_optiions.lua


Fix: Pk ca crash quand on lance le clavier?

Pas de touch input => pas de escape =>


DONE:
- Menu avec fleche directionelle et joystick pour le in game
- Fix: Si tu fais un back il faut supprimer le touch is loaded