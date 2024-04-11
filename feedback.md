Feedback with @NerdOfGamers on Twitter

# UX 
- [ ] Better signposting
  - Struggled to start first level. Needed some prompting to check. Once she figured out the trick to various things/actions quickly adapted but lack of signposting or indication was possible meant she was lost for a little while.
  - Okay, so this is a hard problem. There are two components that are clashing:
    - I want the game to be easy to pick up, so I like the idea that you can immediately start the game on the title screen, no tutorial, no excessive amount of text, no fuss. 
    - But at the same time I want it to be accessible, so it's why I really want to keep the 3-button scheme and I try to make things as intuitive as I can. I'll have to see what I need to do, maybe I'll sacrifice some of the "easy-to-pickup-ness" and add a simple tutorial. Dunno.  

# Player
- [ ] Stomping can feel confusing visually, the mechanics appear to be if player is falling down then you kill enemy even if inside their hitbox but if you have any upwards movement then you take damage. If going for a series of drops, especially against the grasshoppers can be really hard to avoid taking damage.
- [ ] It's not clear that you can stomp enemies: need to be taught in a better way
- [ ] Feels like optimal strategy is to avoid guns and just jump on enemies. Get good at that and you kill everything faster than a good ever could
  - see [2] 
  
# Multiplayer
- [ ] Multiplayer is too easy, even in 2P // I suspect the game doesnt scale well with more players
  - Favored standing in corner for most of the time. Found it considerably easier with a better gun. We mostly kept to thi strategy as with two players was very effective. She commented that the grasshoppers didnt seem to go into the corners so was just naturally just the safest place to be.
  - Didnt engage with stomping except when forced as two player guns were too effective (far cry from single player). Didnt do any wall jumped except maybe by accident.
    - Consider with solo that is too hard


# Gun
- [ ] Monsters might feel like bullet sponges given starting gun has 25 bullets. 
- [ ] Berry gun (circular arc gun) is hard to use, esp against snails
- [ ] Wish there was a way to switch weapons
- [ ] Gun variability is not always predictable.
- [ ] Got some kind of shotgun in round 2 and bullets were same size but maybe felt like the had increased damage? Cant tell visually. (Rapsberry shotgun and pea shooter)
- [ ] Can jump and shoot with pea gun at same time to get super boost to ceiling which i havent yet managed to do with the minigun or triple shooter.
- [ ] Guns feel inferior to stomping, esp in solo

# Loot
- [ ] Wish you didn't accidentally collect guns: fix: when collecting a gun it swaps with the current item (and the item is a bit quicker to dissapear)
- [ ] Drops feel random and not for any sense of achievement (might be wrong here, just feels like random chance so doesnt matter if I am doing well or poorly)

# Enemies
- [ ] Need to introduce snails later, should have a stomp-only enemy very early on to introduce stomping
- [ ] Grasshoppers are really hard esp for new players and with their off-cycle jumps and given that wall jumping is the only way to really avoid them (standard gun doesn't have neough kb or damage to handle them)
- [ ] Spider are hard to kill 
  - With the spiders, when they become active they very very quickly move to the ceiling before latching on making it hard, but not impossible, to do stomping attacks on them. 
  - Theire movement pattern then 'felt' like it was confined to the center 1/3 of the lift, avoiding either of the two side walls. This meant setting up opportunities for wall jumping on top of them were limited. 
  - I could push them over using weapon knockback over to the side to reposition them but by the time I've done then it's often quicker to just keep attacking them with a gun.

# Combo
- [ ] Imporove combos, see [1]

# Level
- [ ] The battle arena (the lift) did feel a little barren after a while as it doesnt change or adapt and provides no additional strategies (as only two side walls to jump off).
  - IDEA: bits of the level fall to create platforms

# UI
- [ ] And minor thing on pause menu, when tapping down to select options felt like o was doing same distance but wasnt wuite causing menu to go down so felt sticky and unresponsive sometimes.

# Ideas
- [ ] IDEA: after death the retry button takes you to main screen where you have to smash the button again to start again. Maybe two options for wuick restart then the main menu screen, if you want to do some rapid levels back-toback.
- [ ] IDEA: Having enemies fade in when they're still in the door

# Bugs
- [ ] BUG: Slugs rapidly flipping left & right feels unnatural
- [ ] BUG: pollen gun might have a bug so you end up firing extra shots when rapidly clicking. Meant of the 30 shots, would end up with 1 or 2 bullets left in chamber, i would fire and then the last shot or two would fire and reloading. It also seems to have a period of sometimes halting so squeezing trigger would not fire.
- [ ] BUG: And one game crash, went to credits and pressed confirm while on Louie Chapman and game froze.
  - [ ] BUG: Max_combo at end screen has underscore in it (using variable name)
- [ ] BUG: Timer doesn't stop when you win, keeps ticking up. 

------------------------------------------------------------------------
[1]:

**NOG**: Combos dont carry over due to timer on it, feels harsh when doing clean sweep on a level of killing enemies without taking a hit and even timing them becoming active from the lift and jumping on all the next ones. Would feel nicer maybe if combo counter was maybe just kills without damage? Or preserves over level for a short while to incentivise fast killing strats.

**Y**: I'm not sure that I understand what you mean, could you expand on this point? Combos aren't tied to time, but rather they stop when you touch the floor, so it's possible that this mechanic isn't communicated properly. What do you feel like is unsatisfying about the combo system?

**NOG**: Ok, so what I mean is there is a limited window in which the combo counter can increase. If you wait too long between killing on enemy and the next (or maybe it's when you shoot/hit the ground as I don't know the exact mechanics yet) then the combo counter is reset. With guns it feels impossible to ever really build up a counter (though I haven't extensively tested it with all guns as they do have different firing patterns and bullet amounts). The other part of it was, should I be able to kill all the remaining enemies by falling/drop killing them then the game displays the combo message (how many you killed in a row). When the next floor starts that combo is reset, meaning I have to start from one again.

In many games featuring combo counters you might get between say 1-5 seconds to carry out another kill (allowing guns in this case to contribute to a combo counter) or they might only reset when you take damage. It felts a little saddening that I was able to kill about say 15 enemies in a row by falling/drop killing them, but as they were over 3 floors it displayed 3 seperate combo messages saying I got to about 5-7 each time (depending on how many spawned). If you want to keep the timer aspect then I would maybe pause the timer between floors to give the player a chance to preserve their combo streak to make them feel more powerful or as a reward for quick/good gameplay, might make it feel more impactful and a way for them to track their own skill level.

**Y**: This is very interesting. I don't know if you figured out the jetpack mechanic, where shooting down makes you fly upwards. I originally made combos to encourage players to use this mechanic more. The way combos work is that it increments every time you stomp on an enemy, and end when and only when you touch the ground, they are not tied to time in any way. So to keep the chain going you need to stick on walls. I didn't realize that it's not very clear that's how it works, and I'm not sure it's the most fun way to implement it. Perhaps a better way to have a combo mechanic would be to have it tied to kills regardless of how you kill enemies (stomping or gun) and have the combo end after some time or when you take damage, but this timer could be frozen between floors. This way it's easier to understand but stomping enemies and cleverly utilizing the jetpack is still the most effective way to chain a combo and the most fun way to play.

------------------------------------------------------------------------
[2]:

NOG: Try 10, feels like optimal strategy is to avoid guns and just jump on enemies. Get good at that and you kill everything faster than a good ever could ...

Y: Do you feel like this should be changed? Do you think that stomping on enemies is not the best way that the game should be enjoyed?

NOG: It's not that I don't enjoy stomping on the enemies, it's just that the guns feel so inferior in comparison in inflicting damage, even some of the bigger meater ones. Stomping is single hit kill, where could take multiple bullets. And if I'm challenging myself to speedrun through the game then stomping feels like it's the only optimal way to play. I would say from my perspective the guns either need a damage boost, or monsters have health dropped a bit, or maybe something done with the patterns. Not exactly sure what would work best right now, just that they need something to boost them a bit to feel like less of an inferior play option.

If they intent of the game was to primarily designed around stomping and the guns were a later addition, maybe swap out the guns for different powerups to preserve the original intent. Kinda all depends on what your design goals were.
s
Y: Noted. Perhaps I can try buffing guns or making enemies weaker.

------------------------------------------------------------------------


[4/8, 6:52 PM] Kieron: The "leave" sign is triggered by left stick up not left trigger
[4/8, 6:53 PM] Kieron: (Right stick)
> Can't reproduce. Did you accidentally remap the controls?