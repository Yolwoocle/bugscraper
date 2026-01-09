# Bugscraper changelog

### 0.9
(*2026-01-09*)

I added a "⭐" emoji next to highlights to make this changelog easier to read.

#### Gameplay 
- ⭐ **Added**: New character, Amb! She's a shy harworking bug, usually messing around in the Server Room.
- ⭐ **Added**: New enemy, the 'Dropper' (placeholder name): spawns in dept. 4, flies around randomly and drops down as soon as it is damaged, spawning 4 projectiles when hitting the floor  
- ⭐ **Added**: New Boss for dept 4! Please not that this is still a WIP
- ⭐ **Added**: Last area for the game, including the final boss. I will not spoil it... Please not that this is still a WIP
- ⭐ **Changed**: Heart loot probability now depends on the health of the player with the least health: they depend linearly (full health = x0 probability, half health = x1, low health = close to x2)
- ⭐ **Added**: Added NPCs in cafeterias! They don't do anything, they're just here to chill.
- **Changed**: Ajusted the difficulty of dept. 3
- **Changed**: Slightly buffed ghosts' puff attack
- **Changed**: Made bullets' hitboxes slightly bigger
- **Changed**: Guns are now instantly collected when you press the 'interact' button

#### Visuals
- **Changed**: Improved & polished Webmaster boss
- **Added**: New "Buglatro" TV slide by 8lueskii 
- **Added**: Added warning signs before spikes in dept. 2 appear
- **Changed**: Various polishes to the tutorial 
- **Changed**: Various improvements to the ||post wave 80 rocket section||
- **Changed**: Visual improvements to ||the CEO's office and its associated cutscene||
- **Changed**: Various polishes to Her Majesty, including a new crowd that reacts to the fight  
- **Changed**: Minor graphical improvements to cafeterias
- **Changed**: Larva projectiles coming from flying spawners (placeholder name) are now visually spiky  
- **Changed**: Minor graphical improvement to the title that plays when you enter a new department
- **Changed**: Added a particle to Rollopods when they notice you
- **Changed**: Grahpical changes to dept. 4's visuals
- **Changed**: Grahpical changes to poison and stink bugs, which are now yellow, to make them more consistent 
- **Changed**: Small change to the ground floor sprite

#### UI
- **Changed**: Moved upgrades UI position to the top right
- **Changed**: Changed the UI layout of upgrades to be vertical
- **Changed**: The timer now display in front of the UI when paused
- **Changed**: Added 'Max combo' stat to the Game Over screen
- **Changed**: Removed credits from pause menu (for now)
- **Changed**: Slight tweaks to various UI elements
- **Removed**: Removed convention mode from options

#### Sound
- ⭐ **Added**: New music! Including pause music for dept 2 and bosses, and various changes to the music of the game (Including Dept. 1 & Dept. 3). Courtesy of OLX.
- ⭐ **Added/Changed**: New sounds! Courtesy of Martin Domergue
    - Various enemy sounds including honeypot ants & grasshoppers
    - Weapon pick up sounds
    - Improved gun sounds
    - Mr Dung sounds
    - Her Majesty sounds
    - Spike sounds
    - New upgrade sounds
    - Various cutscene sounds
    - Many more other sound improvements and additions 
- ⭐ **Added**: Spatial audio! I recommend using headphones to fully enjoy it.
- ⭐**Added**: Ambiance sounds! Can be disabled in options.
- **Added**: Added intros to music loops: music will now have an intro before their main loop
- **Changed**: Music will now play back to its previous point when exiting a cafeteria

#### Fixes
- **Fixed**: Fixed issue where you could spawn multiple players
- **Fixed**: Fixed issue where the Pea Gun could duplicate in the tutorial
- **Fixed**: Fixed issue where player could slightly clip through the elevator door when exiting cafeterias 
- **Fixed**: Fixed issue where Bulb Buddies would sometimes spawn outside of the elevator door
- **Fixed**: Fixed issue where Rollopods could sometimes be pushed around after rolling
- **Fixed**: Wall jumping to ||the rocket cutscene|| would not remove the low stamina beep
- **Fixed**: Fixed bug related to the music not fading in correctly when quick restarting the game
- **Fixed**: Removing an action from "join game" with a certain input type (i.e. keyboard or controller) would remove actions from all other input types 
- **Fixed**: Fixed issue where you could assign 0 buttons to "join game"
- **Fixed**: Fixed padding issue with Spanish 
- **Fixed**: Fixed bug where vines weren't removed after wave 80
- **Fixed**: Fixed minor graphical issue with dept. 3's falling grid animation

#### Localization 
- **Changed**: Minor changes to some localized text
- **Changed**: The game now takes into account all user locales
- **Changed**: Added a menu padding parameter to locales
- **Changed**: Updated Spanish translations, courtesy of Alejandro Alzate Sánchez
- **Changed**: Some updates to Portugese Brazilian translations, courtesy of itzKiwiSky

#### Misc
- **Added**: Added a new CEO escape cutscene after dept. 3
- **Added**: Added some gamepad vibrations in menus
- **Changed**: The game will no longer boot if bugscraper.png is not present, courtesy of Alejandro Alzate Sánchez

And many other various optimizations, improvements and fixes.


### 0.8.1
(*2025-10-01*)

- **Fix**: Fixed issue where vines (placeholder name) would not deal any damage 
- **Fix**: Fixed issue where Chippers would not play their telegraph sound  

### 0.8
(*2025-09-27*)

#### Highlights
- 🔊 **Sound design** has been completely reworked from scratch, thanks to the work of the new sound designer in the team, Martin Domergue!! Please note that this is still a work in progress, and do not hesitate to send feedback and criticism, it is highly appreciated.
- 🪴 **New 4th department!** The Gardens are the Bugscraper's highest area, a luxurious place where reside the company's highest ranked executives. Please note that it is still a work in progress and a lot of things are still placeholders.
- 🔘 **New "interact" button!** This button is used to open up the new cafeteria interface, to exit the game, or to collect guns. Unfortunately this will reset your custom remappings, I'm sorry :(

#### Gameplay
- **Change**: Sound design has been completely reworked from scratch, thanks to the work of the new sound designer in the team, Martin Domergue
- **Added**: New department 4. The Gardens are the Bugscraper's highest area, a luxurious place where reside the company's highest ranked executives. Please note that it is still a work in progress and a lot of things are still placeholders.
- **Added**: Added a "interact" button, mapped by default to "Z" on keyboard and the right action button (Nintendo A, Xbox B, Playstation circle) on controllers. This addition also changes the default mappings and removes the "exit game" action. Unfortunately this will reset any custom remappings you might have had. 
- **Change**: The exit sign now uses the interact button
- **Change**: You now need to use the interact button to collect guns
- **Added**: A new interface for the cafeteria upgrades has been added, and the previous upgrade jars have been removed.
- **Added**: Added two small animations on floors 20, 40. I'll let you discover them... 
- **Added**: Boss bars!
- **Change**: Various changes to combos. They are easier to start and keep, and the visuals have received a glow-up
- **Change**: In co-op, respawn cocoons now appear at every cafeteria
- **Change**: Camera now pans to the left after opening the door
- **Change**: Slight adjustments to dept. 2 waves to make them feel less punishing 
- **Change**: Slightly increased wall sliding stamina limit
- **Change**: Minor tweaks to Her Majesty boss
- **Change**: Made guns slightly more pleasant to use by making bullets spawn from the base of guns
- **Added**: Added a new easter egg 👀 

#### Graphics
- **Change**: Weapons and hearts will now always render in front of enemies
- **Change**: Added visual effect to ghosts' spinning
- **Change**: Minor tweak to splash screen graphic
- **Change**: Slight improvements to some backgrounds
- **Change**: The city background display lower down the higher up you are 
- **Change**: The currently active user is shown in menus in co-op 
- **Added**: Added a few TV slides
- Various other minor graphical changes 

#### Menus
- **Added**: Added "SFX Volume" option
- **Change**: You can now use keyboard inputs to navigate menus even if no keyboard player joined the game
- **Added**: Added simplified chinese localisation. Right now it's all machine-translated but I do plan on adding manual translations later on.
- **Change**: Renamed "retry" to "return to ground floor"
- **Change**: Changed feedback menu
- **Change**: Buttons are no longer selectable during the game over animation

#### Fixes
- **Fix**: Fixed bug where the 3D graphics of the Comball would not appear at the right location while in the elevator door
- **Fix**: Fixed minor visual artifact that sometimes happened when enemies spawn from the elevator door
- **Fix**: Fixed issue where splash screen would not be correctly cut if width of window is very large
- **Fix**: Fixed issue where the music would play for a single frame when starting the game if the music volume was set to 0 
- **Fix**: Fixed issue where the window could be completely dark if scaled down while pixel scale was set to "max whole" 
- **Fix**: Fixed issue where you could not start a game if there was no player 1
- **Fix**: Fixed issue where in co-op, you would not respawn with all your hearts if you had the milk upgrade
- **Fix**: Fixed issue where the "bullet lightness" option would affect non-player bullets
- **Fix**: Fixed issue where disconnecting your controller while in a game and pressing "continue anyway" could sometimes softlock you 
- **Fix**: Partially fixed issue where you could not press certain buttons during a time freeze 
- **Fix**: Fixed issue where "return to ground floor" would not return players to the ground floor in the tutorial
- **Fix**: Fixed issue where Mr. Dung couldn't be damaged when bunny hopping
- **Fix**: Fixed minor graphical issue where the timer & cinematic bar would clash sometimes


### 0.7.2
(*2025-07-04*)

- **Fix**: Fixed issue where a certain easter egg would crash the game
- **Fix**: Removed dept. 4 (planned for a future update) 
- **Fix**: Linux version is now correctly supported on Steam

### 0.7.1
(*2025-07-03*)

- **Fix**: Fixed issue where enemies would not drop any loot

## 0.7
(*2025-07-01*)

New update!!! Please report any issues you run into!

This is a small update with some of the content that I've been working on. From now on, I will limit the amount of new content I add (apart from the upcoming dept. 4) as I start heading towards the release of the game, hopefully towards the end of August (no guarantees, though). Sorry for the lack of news, I had a lot in my life and didn't want to rush things out. Please be patient, thank you for waiting. :)

I'm sorry to say that this update will reset your progress, I've made it so that it doesn't boot up the whole tutorial animation, but as I said last time I'll work on a more permanent solution in the future.

- **Added**: Wall climbing now uses a stamina system: jumping and sliding uses up stamina, and when you run out of it, you will fall 
- **Added**: Energy Drink upgrade: combo meter decreases more slowly
- **Added**: In co-op, you will now become a ghost after dying. Ghosts can shoot small bursts of bullets that deal a little damage. Players can be respawned from ghosts by breaking cocoons that will appear a few waves later
- **Added**: New sounds from the new sound designer in the team, Verbaudet! More sounds are to come in future updates!
- **Change**: Respawned players will now appear with full health, however cocoons appear more rarely  
- **Change**: Espresso now lasts for 20 floors (prev. 10)
- **Change**: Hot chocolate now affects natural recharging (the recharging that happens after waiting for a few seconds)
- **Change**: Beelets from dept. 2 no longer appear spiky when angered
- **Change**: Reskinned and polished the Stabee enemy, from dept. 2
- **Change**: Background fan in dept. 2 now spins 
- **Change**: Polished up dept. 3 cabin background
- **Change**: Added a cooldown for cloud storm enemy (temporary name)
- **Change**: Improvements in the player animations, in particular, the damage and invincibility animations
- **Fix**: Partial fix to an issue where some enemies like boomshrooms, stink bugs' clouds, and larvae spawned from projectiles, would clip into the ground and teleport. This might still happen, just hopefully to a lesser degree
- **Fix**: Fixed visual bugs related to TV presentation

## 0.6 
(*2025-03-22*)

First Steam beta release (after a year of development, never too late..!) If you had the game before, I'm sorry to say that this release will reset your progress (skins & upgrades). I'll work on a more permanent solution in the future but right now this the best way I found to avoid incompatibility bugs. Be expected for this to happen often in a game still in beta. :P

- **Added**: Option to replay the tutorial in the settings 
- **Added**: You can press down to go through platforms
- **Change**: Various improvements to the tutorial
- **Change**: Improved flying nests (temporary name): now only shoot in defined directions and will flash before exploding after being killed
- **Change**: You now have more upgrades when first starting the game to avoid cases where upgrade jars would spawn empty 
- **Change**: Honeypot footballs (temporary name) explode faster so it doesn't ruin your combo
- **Change**: You can no longer attack dept. 2 bee boss with bullets
- **Change**: Increased opacity for Stink bug poison cloud
- **Change**: Espresso upgrade now lasts for 10 floors instead of 1 minute
- **Fix**: Quick restarting no longer has that small “intro”
- **Fix**: Drill bees (temporary name) now give some fury when exploding
- **Fix**: Ground floor music no longer plays when reviving a player 

## Older versions
I didn't write changelogs for older versions, but you can probably access these versions at [yolwoocle.itch.io/bugscraper](https://yolwoocle.itch.io/bugscraper) and look for the changes yourself.