**NOTE:** if you are just here to obtain a free copy of the game, fair enough, but please consider [supporting me](https://bugscraper.net) if you can, or sharing the game with other people. Thanks! 🙂
<br>
<div align="center">
  <h1>Bugscraper</h1>
</div>

[**Website**](https://bugscraper.net) ·
[**GitHub**](https://github.com/yolwoocle/bugscraper) ·
[**itch.io**](https://yolwoocle.itch.io/bugscraper) ·
[**Steam**](https://s.team/a/2957130)

Welcome to the bugscraper.
Here, pests all around the world come to gather.
Your mission: stopping them before it is too late!

Rise to the top of a bug-infested tower by fighting on an elevator. On each floor, waves of enemies will come for your skin (or rather, exoskeleton). With your trusty pea gun, eliminate them and prepare for the next floor!

<div align="center">
  🐞🐞🐞🐞🐞
</div>  


## Is this game open source?
**This game is _NOT_ [open source](https://en.wikipedia.org/wiki/Open-source_software)**, rather it is [source available](https://en.wikipedia.org/wiki/Source-available_software). Some of the assets I use are incompatible with a traditional open-source licence. **Not having a licence means that by default I reserve all original rights for the game, even if the code is public.**  

However, I am very lax with what you can do with the source code. Please feel free to reuse, modify, or remix the source code of the game for any non-commercial project, as long as you're not directly distributing the code, assets, or any executables.

If it does not fit that description please [contact me first](https://yolwoocle.com/about). I'll probably say yes! I don't bite :).   

<div align="center">
  🐛🐛🐛🐛🐛
</div>  

## Running
To run the game, please follow the instructions on the [LÖVE Getting started page](https://love2d.org/wiki/Getting_Started).   
To export the game, please look into [Makelove](https://github.com/pfirsich/makelove).   

<div align="center">
  🐜🐜🐜🐜🐜
</div>  

## Contributing

Please note that I was in highschool when I began this project. I am basically the only maintainer and I did not always plan for the future or make the best code design choices. The code is almost not documented and there are many, many, many things I would do differently if I were to start from scratch. You have been warned. 

For any questions you can [contact me](https://yolwoocle.com/about) (on Discord preferably).

<div align="center">
  🐝🐝🐝🐝🐝
</div>  


## Building 

There is some custom libraries to build if you want to use them (the game work fine without). To build it you need to have cargo, alsa and make, for the moment it compile and works on Linux (debian), but I don't know if it works on windows or mac (it should, but the test has not been made yet).  
If you have building issue, you can check on the midir rust crate instruction, or on the mlua crate building instrucion.  
On windows you need a lua5x.dll to build.

To build the windows target from linux or wsl you need to have the `x86_64-pc-windows-gnu` target and `gcc-mingw` installed, you can do install this with this command (on debian) :
```sh
rustup target add x86_64-pc-windows-gnu
sudo apt-get install gcc-mingw-w64-x86-64 
```

<div align="center">
  🪰🪰🪰🪰🪰
</div>  
