# RA2Snes

RA2Snes is a program built using Qt 6.7.3 in C++ and C that bridges the QUsb2Snes webserver & rcheevos client to allow unlocking Achievements on real Super Nintendo Hardware through the SD2Snes USB port.

## Installation 

Download the latest firmware for your [SD2Snes](https://sd2snes.de/blog/downloads).

Download the latest version of [QUsb2Snes](https://github.com/Skarsnik/QUsb2snes/releases).

Plug the SD2Snes into your computer (Linux users may need to allow Serial Port communications to enable communication between QUsb2Snes and SD2Snes).

Run both QUsb2Snes and RA2Snes.

---

## Usage

### Configuration Files

Once RA2Snes has been run for the first time, the settings.ini file is created in the same directory as RA2Snes. This file holds all program settings, including your saved login information.

### Currently Unsupported Games

SD2Snes cannot currently read the memory of Super Game Boy and games with certain [enhancement chips](https://en.wikipedia.org/wiki/List_of_Super_NES_enhancement_chips).
| Chip | Supported |
|------|-----------|
| Base |     Y     | 
| DSP  |     Y     |
| CX4  |     N     | 
| GSU  |     N     |
| OBC1 |     N     |
| SA1  |     N     |
| SDD1 |     N     |
| SGB  |     N     |

---

## Limitations and Issues

### RA2Snes won't load game or update SNES status

The SD2nes firmware may have crashed power cycling the SNES should fix the issue. Ensuring a good usb connection and booting QUsb2Snes and RA2Snes before powering on the SNES will mitigate any crashes.

### Preemptive Unlocks

Some achievements may activate without the requirement being met. This happens because a memory address is not overwritten before it is checked. All known instances occur due to achievement sets not being built with hardware accuracy in mind.

**When this happens click on the achievement title to go to its page on the RetroAchievements Website and reset that achievement!** (You will have to switch between hardcore<->softcore and back to refresh the achievements)

### Achievement Won't Trigger

Achievements might have a tight frame window. This may cause achievements not to activate because reading the memory of SD2Snes is not frame-perfect. 

I recommend unlocking more achievements before retrying an achievement as the fewer achievements there are to check the fewer memory values are needed to be read from SD2Snes.

If an achievement will not trigger at all please see my RetroAchievements [profile](https://retroachievements.org/user/Factor64) for the SNES games I have completed (all SNES games supported will be completed on RA2Snes).

If an achievement does not trigger and is not completed on my profile, you can send proof of meeting the requirements for an achievement in the Manual Unlocks thread in the RetroAchievements [Discord](https://discord.gg/dq2E4hE) and put in an [issue](https://github.com/Factor-64/ra2snes/issues) so I can look into it.

---

## Future Plans

See [FUTURE.md](FUTURE.md)

## Compiling

See [COMPILING.md](COMPILING.md)

## Credits & Thanks

* [Skarsnik](https://github.com/Skarsnik) for QUsb2Snes, usb2snes client, and helping with various implementations used in RA2Snes (Check out their sister project [TCheeve](https://github.com/Skarsnik/TCheeve)!)
* [rcheevos](https://github.com/RetroAchievements/rcheevos) and its [contributors](https://github.com/RetroAchievements/rcheevos/graphs/contributors)
* Many users in the RetroAchievements [Discord](https://discord.gg/dq2E4hE)'s coding channel for helping answer any questions I had.

### Icons

* [RetroAchievements Logo](https://retroachievements.org/)
* RetroAchievements SVG Icons
* Wikipedia's [Famicom SVG](https://en.wikipedia.org/wiki/File:Super_Famicom_logo.svg)
* Famicom Logo by Nintendo

---

## License

RA2Snes is available under the GPL V3 license.  Full text here: <http://www.gnu.org/licenses/gpl-3.0.en.html>

Copyright (C) 2024 Factor (Factor64)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
