<img align="left" width="100px" src="assets/icon_1024.png">

[![GitHub Total Downloads](https://img.shields.io/github/downloads/TechnicJelle/BlueMapGUI/total?label=Downloads&color=success")](https://github.com/TechnicJelle/BlueMapGUI/releases/latest)
![Platform: Linux](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux&logoColor=white)
![Platform: Linux](https://img.shields.io/badge/Platform-Windows-2887E9?logo=windows&logoColor=white)
[![Build Flutter Desktop](https://github.com/TechnicJelle/BlueMapGUI/actions/workflows/build.yml/badge.svg)](https://github.com/TechnicJelle/BlueMapGUI/actions/workflows/build.yml)

# BlueMap GUI

A GUI wrapper around the BlueMap CLI, mainly to make using BlueMap easier for single player worlds.

![screenshot](.github/readme_assets/bmgui.png)

## Requirements
Make sure you have **Java 16** or higher installed and on your PATH!

## Usage
When you first open the program, it asks you to select a project directory.
I recommend making a new folder somewhere and using that one.

It will then download the BlueMap CLI tool into that folder,
and verify that it's the exact correct one, to prevent any suspicious files from being run.

Lastly, it'll generate all the default configs for you, and show them in the left sidebar.

You can then click the Start button to start BlueMap!

The first time, you will be instructed to accept the download in the core.conf file.
You can edit that very simply, inside BlueMap GUI by clicking the Core button in the left sidebar.

From there on, you have to configure your maps. I'll make a better workflow for that later.
For the time being, you have to copy the path to your world folder into the map config manually.
You can edit the map config in the built-in config editor, too.
