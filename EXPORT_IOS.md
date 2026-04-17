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
