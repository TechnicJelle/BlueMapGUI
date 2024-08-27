# BlueMap GUI
A GUI wrapper around the BlueMap CLI, mainly to make using BlueMap easier for single player worlds.

![screenshot](.github/readme_assets/bmgui.png)

## TODO
- check downloaded jar with hardcoded hash
- allow users to select their own project directory, instead of hardcoding one on my own computer
- make the console better
  - add a scroll down button (only visible if you scroll up)
  - fix the random line breaks (probably due to the stream)
- make the start/stop buttons a single button
- make it not lose the process (orphan) as easily
	- when going to a config file without stopping the bluemap process, it loses it and you have to restart it
	- when closing the program, it loses it
- add gui for the (main) config options
	- accept download
	- adding & removing map configs
		- world path
		- map name
		- dimension key
