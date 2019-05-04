# Aeon Garden

Aeon Garden is an attempt create a cool little artificial life "fish tank" using SpriteKit that'll run on macOS, iOS, and tvOS.

The creatures generated are meant to swim around, hunt for food, and mate. Their attributes can be passed on to offspring, so families will develop who have similar colors, shapes, and abilities.

There is no scientific basis for anything about this app, and it's does not use machine learning. It's meant to be a simple virtual tank full of little creatures, not a rigorous exploration of natural selection or evolution.

## Why?

Like [Numu Tracker](https://www.github.com/numutracker/numutracker_ios), Aeon Garden is both a learning project and a labor of love. I've always loved little artificial life simulations, no matter how rudimentary. Aeon Garden is also helping me learn more things: SpriteKit, GameKit, creating views and constraints programmatically, more elaborate view animations, better code organization, and cross-platform development.

## Video & Screenshots

Screenshots of Aeon Garden look a little boring, so be sure to watch this **[YouTube Video](https://www.youtube.com/watch?v=QHfABigM2Ik)**.

These screenshots are from the tvOS version.

![Aeon Garden Zoomed-Out View](/Design/Screenshots/tvos-zoomed-out.png?raw=true)

![Aeon Garden Zoomed View](/Design/Screenshots/tvos-zoomed-in.png?raw=true)

## Goals / What Aeon Is and Isn't

* Aeon Garden is meant to be a desktop toy (like running idly on an iPad on your desk) or as a screensaver on your Mac. It's not meant to be a "game".
* Aeon Garden should not just be pleasant to look at, but also pleasant to listen to. I haven't decided yet what this means, but I'd like it to essentially be an ambient music / sound generator. The ultimate goal would be for you to want to leave on the sounds, and maybe sleep to the sound of your tank running.
* Aeon Garden should encourage people to learn to program in some way, and ease them into it. For example, the save system will utilize JSON files saved to the user's iCloud folder if available, so that you can open them up on your device and "hack" your creatures to change them at will. After a user is comfortable modifying JSON files, they might want to checkout the repo from GitHub and do more direct "hacking" by modifying the source code. There will be hints in the app and articles on the website about how to do this, for extra encouragement.

# To Install

1. `git clone https://github.com/amiantos/aeongarden.git`
2. Open `Aeon Garden.xcworkspace`
3. Pick a target
3. Run
