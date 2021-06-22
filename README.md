# Liblast
Libre Multiplayer FPS Game built with Godot game engine and a fully FOSS toolchain.

![Screenshot 03](https://github.com/unfa/liblast/raw/main/Screenshots/01.jpg)

## Rewrite Status

The game is currently being rewritten from scratch in Godot 4.
The legacy branch contains the initial, Godot 3-based version of the game. This version of the game has served well as a prototype and a testbed to help us figure out what we want to do. We've also learned some important lessons on our mistakes.

We wanted to take advantage of the improved performance, features and workflow of Godot 4 and since the GDScript syntax is changing significantly - we've decided we'll take this opportunity to rebuild the game from scratch and improve our design.

Hence - if you'd like to contribute to the project, please get in touch first, as things are very much in flux right now, and we'd hate to have any effort wasted!

**DISCLAIMER: THE GAME IS IN VERY EARLY STAGES OF DEVELOPMENT.
DO NOT EXPECT MUCH, AND DON'T BE SURPRISED IF IT DOES NOT WORK AT ALL

PLEASE DO NOT REPORT ISSUES OR PROPOSE FEATURES AT THIS POINT IN TIME
- IF YOU WANT TO HELP, GET IN TOUCH FIRST!**

## How to run the game

### GNU/Linux

1. Make sure you have `git` and `git-lfs` installed.

1. Clone the Git repository:
```
git clone git://github.com/unfa/liblast
```

1. Enter thr cloned repository:
```
cd liblast
```

1. Initialize Git-LFS:
```
git lfs install
```

1. Pull the large files (if any):
```
git pull
```

1. Extract the godot editor binary:
```
tar -xvf ./Godot/godot-v4.0.dev.calinou.94c31ba30.Linux-x64.tar.gz
```

1. Run the Godot editor binary and load the project:
```
./godot-v4.0.dev.calinou.94c31ba30.Linux-x64 ./Game/project.godot
```

Once Godot editor loads the project, hit `F5` to start the game

## Get in touch

If you want to talk to the devs and discuss the game in an instant manner, go here:
https://chat.unfa.xyz/channel/liblast

## Controls

- WASD to walk around
- mouse too look around
- mouse 1 to shoot
- space bar to jump
- T to write to your team mates (not complete yet)
- Y to write to all players on the server (not complete yet)

Because of Godot 4's unstable nature, thing may not work. The gmae is being developed using the `v4.0.dev.calinou.94c31ba30` build of the engine.
You can clone the Godot source code of the specified commit and it should work, though sometimes the project just won't load. That's the price of using unfinished software for production :D Once Godot 4 alpha is out, the development should be able to continue on a bit more smoothly.

# What's with the name?

`Libre` + `Blast` = `Liblast`
No, it's not a library ;)
---

# Stuff below applies only to the legacy branch

![Screenshot 01](https://github.com/unfa/liblast/raw/legacy/Screenshots/01.png)
![Screenshot 02](https://github.com/unfa/liblast/raw/legacy/Screenshots/02.png)

## Controls

Standard FPS stuff:
- W,A,S,D to move
- Mouse to look around
- Left mouse button to shoot
- Space to jump
- R to reload

Less standard:
- Shift to use jetpack (you have 1 second of jetpack, and it recharges for 5 seconds - ther's not HUD fro this and it's broken, also balance changes will most likely ensue, you can use it to get to that high platform on the DM1 level)
- Tab to show a list of currently connected players

## Features in 0.1 pre-alpha release

The game currently has:

- ~~a public online server at unfa.xyz (accessible via Quick Connect)~~ only deployed on demand for now
- a deathmach level for 2-4 people (DM1)
- simple but exciting gameplay
- one weapon (a handgun)
- a very basic HUD with health and ammo indication
- some particle effects
- mouth-made sound effects for various things and some better SFX here and there
- bullet fly-by sound effects!
- gun animation, bouncing shell casings and smoke effects
- sentient fridge stacking in multiplayer

A livestream where I've made a couple of new sound effects for the game:
https://youtu.be/aUtSLNzvqvI

Video of a version of the game not long before 0.1 release:
https://youtu.be/g3KvNeu4X54 (quite outdated as of 2021-02)

