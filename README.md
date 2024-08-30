# BlueMap GUI
A GUI wrapper around the BlueMap CLI, mainly to make using BlueMap easier for single player worlds.

![screenshot](.github/readme_assets/bmgui.png)

## Requirements
Make sure you have **Java 16** or higher installed and on your PATH!

## TODO
- make the console better
  - fix the scroll; when you scroll up, new logs should not move the view (but it does, rn)
  - add a scroll down button (only visible if you scroll up)
  - make the output global state (so it doesn't clear when you switch tabs)
    - add a clear output button? (do i really want to allow users to clear the output?)
- make it not lose the process (orphan) as easily
	- when closing the program, it loses it
- config editor: horizontal scroll bar
- add gui for the (main) config options
	- accept download
	- adding & removing map configs
		- world path
		- map name
		- dimension key
		- button for adding a save (adds map configs for all dimensions in that save)
		- button for adding a single dimension
- allow users to select which minecraft version the project is
