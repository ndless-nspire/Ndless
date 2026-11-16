Ndless r2023 for TI-Nspire OS <= v6.4.0.74
===========================================

Ndless lets TI-Nspire calculators run third-party C, C++ and assembly programs.
This repository contains the executable loader, OS-specific installers, and
the SDK used to build calculator applications.

To install Ndless, find the instructions for your calculator model and exact OS
version in the quick guide below. The supported combinations are listed
individually; the version range in the title does not mean every intermediate
OS release is supported.

To develop an application or work on Ndless itself, start with the
[repository overview and build guide](docs/overview.md).

| Path | Contents |
| --- | --- |
| [`ndless/src/resources/`](ndless/src/resources/) | Loader, installation support, OS hooks, and runtime resources |
| [`ndless/src/`](ndless/src/) | Installers for each supported OS family and persistent installation |
| [`ndless-sdk/`](ndless-sdk/) | Libraries, headers, compiler wrappers, tools, and sample applications |
| [`ndless-sdk/toolchain/`](ndless-sdk/toolchain/) | Script and patches for building the ARM compiler toolchain |
| [`.github/workflows/`](.github/workflows/) | Build, distribution, and SDK package automation |
| [`Formula/`](Formula/) and [`ports/`](ports/) | Homebrew and MacPorts package definitions |

Project resources:

- [Website](http://ndless.me) and [Discord](https://discord.gg/k3yjBdrx8P)
- [Upstream source and issues](https://github.com/ndless-nspire/Ndless)
- [User and installation guide](https://tiplanet.org/ndless)
- [Developer guide](https://ndlessly.wordpress.com/ndless-for-developers/)
- [Hackspire wiki](https://hackspire.org)

Pull requests and issues are welcome.

Quick guide
===========

OS 6.2.0.333 + 6.4.0.74 <img src="https://i.imgur.com/TxjLO71.gif" align="right">
--------

Prerequisites: OS 6.2.0.333 or 6.4.0.74 on CX II, CX II-T or CX II CAS. 

### Standard Installation
* Transfer `ndless_installer_4.5.5-6.2.0-6.4.0.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer, press any alphanumeric key and wait
* If it fails or reboots, try again until it works
* Have fun!

### Persistent Installation
A persistent installation means Ndless will automatically load when you turn on or reboot the calculator, removing the need to run the installer every time.

**Warning:** While this feature has been tested properly, the Ndless team is not responsible for any data loss, reboot-looped calculators, or any damage incurred to your Nspire.

* Ensure Ndless is not currently installed (reset your calculator first if it is).
* Transfer `persistent_6.2.0-6.4.0.tns` into the "`ndless`" folder
* Rename the file you just transferred to `persistent.tns`
* Transfer `ndless_resources.tns` into the same folder
* Open `persistent.tns` and wait for the automatic installation
* Have fun!
  * If you get stuck in a reboot loop, hold `[ESC]`. If that fails, format your filesystem via the maintenance menu.
  * By running the `ndless_resources.tns` file after installing, you can uninstall the loader as well.

OS 4.5.5.79 <img src="https://i.imgur.com/S09QO3e.gif" align="right">
--------

Prerequisites: OS 4.5.5.79 on CX or CX CAS

* Determine your "boot1" version (needed later).
  * Press `[Home]` > `[5]` (Settings) > `[4]` (Status) > About button.
  * Here is a YouTube [video](https://youtu.be/htr106_ggjg) for this.
* Transfer `ndless_installer_4.5.5-6.2.0-6.4.0.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer, press the corresponding key for your boot1 version and wait
* If it fails or reboots, try again until it works
* Have fun!


OS 5.2.0.771 + 5.3.0.564 <img src="https://i.imgur.com/kozAxpP.png" align="right">
--------

Prerequisites: OS 5.2.0.771 or 5.3.0.564 on CX II, CX II-T or CX II CAS

* Transfer `ndless_installer_5.2.0-5.3.0.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer and wait
* Have fun!

OS 4.5.3.14 + 4.5.4.48 <img src="https://i.imgur.com/uuO3ue9.png" align="right">
--------

Prerequisites: OS 4.5.3.14 or 4.5.4.48 on CX or CX CAS

* Transfer `ndless_installer_4.5.3-4.5.4.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer and wait
* Have fun!

OS 4.5.0 <img src="https://i.imgur.com/ZdWgSCq.png" align="right">
--------

Prerequisites: OS 4.5.0 on CX or CX CAS

* Transfer `ndless_installer_4.5.0.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer and wait
* Have fun!

OS 4.4.0 <img src="http://i.imgur.com/mDOg6JG.png" align="right">
--------

Prerequisites: OS 4.4.0 on CX or CX CAS

* Transfer `ndless_installer_4.4.0.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer
* Close the installer with Ctrl+W
* Have fun!

OS 4.2.0 <img src="http://i.imgur.com/GS2K9tS.png" align="right">
--------

Prerequisites: OS 4.2.0 on CX or CX CAS

* Transfer `ndless_installer_4.2.0_cx.tns` or `ndless_installer_4.2.0_cascx.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer
* Close the installer with Ctrl+W
* Have fun!

OS 4.0.3 <img src="https://i.imgur.com/oEsrtC2.png" align="right">
--------

Prerequisites: OS 4.0.3 on CX or CX CAS

* Transfer `ndless_installer_4.0.3_cx.tns` or `ndless_installer_4.0.3_cascx.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer
* Close the installer with Ctrl+W
* Have fun!

OS 3.9.1 <img src="https://i.imgur.com/rT8Ltmy.png" align="right">
--------

Prerequisites: OS 3.9.1 on CX and CX CAS

* Transfer the `ndless_installer_3.9.1.tns` file into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Disconnect your USB cable
* Open the installer
* If you get a message that says "Insufficient memory", reset your calculator and try again!
* Connect the handheld to your computer!
* Close the installer with Ctrl+W
* Have fun!


OS 3.9.0 <img src="https://i.imgur.com/V9U8RSc.png" align="right">
--------

Prerequisites: OS 3.9.0 on Clickpad (CAS/non-CAS) or Touchpad (CAS/non-CAS)

For CX and CX CAS please install 3.9.1.

* Transfer `ndless_installer_3.9.0_classic_new.tns` into a folder named "`ndless`" (top-level)
* Transfer `ndless_resources.tns` into the same folder
* Open the installer
* Close the installer with Ctrl+W
* Have fun!

OS 3.6 <img src="https://i.imgur.com/6cq8g7Z.png" align="right">
------

Prerequisites: OS 3.6

* Transfer `ndless_installer.tns` and `ndless_resources.tns` into a folder named "`ndless`" (top-level)
* Open the installer
* Press the menu button
* Have fun!

Uninstalling
------

To uninstall Ndless, simply run the `ndless_resources.tns` file and select "Yes", after which the device will reboot.

Development team
================

Lead maintainer:
  Fabian Vogt aka Vogtinator - < vogtinator at ritter dash vogt dot de >

Creators:
  Geoffrey Anneheim aka geogeo - < geoffrey dot anneheim at free dot fr >
  Olivier Armand aka ExtendeD  - < olivier dot calc at gmail dot com >

Contributors and testers: Adriweb, bsl, cherpixel, critor, delta, Excale, Goplat, hoffa, Jim Bauwens, Legimet, Levak, Lionel Debroux, lkj, sasdallas, satyamedh, tangrs, timmycraft, vailithree... and many others.  
More contributions can be seen on [the GitHub repo](https://github.com/ndless-nspire/Ndless/graphs/contributors).

Ndless is brought to you by https://codewalr.us, https://www.omnimaga.org and https://tiplanet.org

Legal stuff
===========

Most of the work is covered by the Mozilla Public License, version 1.1 (MPL). 
Please read the file [`Mozilla-Public-License-v1.1.html`](./Mozilla-Public-License-v1.1.html) carefully before distributing any part of Ndless, with or without modification.

Some parts are covered by other licenses. Others are in the public domain. These parts are identified by the files `LICENSE.txt` or `LICENSE.html` in the sub-directory.
