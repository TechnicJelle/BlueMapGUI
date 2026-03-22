# Usage Guide
This page will guide you through setting up and using BlueMap GUI.
Please feel free to use the Table of Contents to skip to the parts that you're interested in.

## 1. Setting up Java
When you first open the program, you will need to choose which Java installation you want to use.  
Go to the `Settings` tab in the sidebar on the left to select whether you want to:
- Use the Java installation on your system.
- Automatically download a suitable installation of Java for your system.
- Pick a Java installation manually. Useful if you don't have Java installed system-wide or if it's too old.  
  Also useful if your system isn't supported by the automatic downloader.

## 2. Creating a project
Once you've supplied a working Java version, go back to the `Projects` tab in the sidebar.  
You can create a new BlueMap project with the `(+)` button in the bottom right.  
Clicking this button opens a dialog where you can name your project.  
You can also choose a different place on your computer to store the project in, if you like.

Once you're happy with these settings, click the blue `Create` button.  
Your new BlueMap project is now in the projects list!  
Click on it to open it.

Opening will take a bit longer the first time, because it needs to download the BlueMap file.

You can return to the main menu by closing the project with the close button in the top right corner.

## 3. Setting up BlueMap
### 3.a Accepting the download
You can now try to start BlueMap by clicking the `▶ Start` button.

But this first time, it will not work yet.
You will see instructions in yellow to accept a download in the Core config.

> This is because BlueMap needs to download some files from Mojang to work properly,
> and according to the Mojang EULA, you have to manually confirm this download.

Luckily, you can do this very simply, by clicking on `Core` config tab in the left sidebar.  
Find the **Accept Download** option, and enable it by ticking the checkbox.

### 3.b Configuring your maps
Now, you have to configure your maps.

Click the `+ New map` button in the sidebar.  
A dialog will open up where you need to choose a template (overworld, nether, or end)
and type in a unique ID for the map. This can be anything you like.  
Once you're happy with these settings, click the blue `Create` button.

You will now see the ID you typed in the sidebar, under the **Maps** section.

The options page for this map should then be visible, but if it isn't,
you can click the newly created map tab in the sidebar to open it.

You now need to tell BlueMap where on your computer your world is,
so click the `Pick world folder` button in the top right,
use the file picker to navigate to where your world is, and select it.

### 3.c (OPTIONAL) Setting up resource-packs & data-packs
To make BlueMap use your preferred resource-packs and data-packs,
click the `Open in file manager` button in the top right.

In the file manager window that now opened, go into the `config` folder, and then `packs`.
Copy&paste all resource-packs/data-packs you want to use here.
You do not need to unpack them.

You can read more about how to set these up [on the BlueMap wiki](https://bluemap.bluecolored.de/wiki/customization/ResourcePacks.html).

_Managing resource-packs and data-packs will be made nicer [in the future](https://github.com/TechnicJelle/BlueMapGUI/issues/13)._

### 3.d (OPTIONAL) Setting up mods
To make modded blocks show up correctly, BlueMap needs to know which mods you're using.

To tell BlueMap about your mods, go to the `Startup` config tab in the sidebar,
click the `Pick world folder` button in the top right,
use the file picker to navigate to where your mods folder is, and select it.

BlueMap does not support all blocks from all mods, but most things will likely work.
You can read more about BlueMap's mod support [on the BlueMap wiki](https://bluemap.bluecolored.de/wiki/customization/Mods.html).

If you already started BlueMap before setting this up, you may see purple/black blocks in your map.  
To fix this, you need to re-render the map with the new settings:  
Click on your maps in the sidebar, scroll all the way down to the **Danger Zone**, and click the `Re-Render` button.
Do this for every map that you have.  
Once you have done that, go back to the `Control Panel` tab in the sidebar, and click the `▶ Start` button again.  
BlueMap will now re-render the map with the new settings.

Note that this option applies to all maps in this project,
so you should only add maps of worlds that all use the same mods in each project.  
You can make new projects for different modpacks.

### 3.e (OPTIONAL) Minecraft version
If your world is not on the latest version of Minecraft,
you can set the **Minecraft Version** option in the `Startup` config tab in the sidebar.

Note that this option applies to all maps in this project,
so you should only add maps of worlds that all use the same Minecraft Version in each project.  
You can make new projects for different versions.

## 4. Starting BlueMap
Once you've set up all the maps you want to render,
you can go back to the `Control Panel` tab in the sidebar,
and click the `▶ Start` button to finally start BlueMap!

You can view the progress and status in the console output,
and you can open the map by clicking the `⬆ Open` button.

## Support
To get help with this program, join the [BlueMap Discord server](https://bluecolo.red/map-discord)
and ask your questions in [#3rd-party-support](https://discord.com/channels/665868367416131594/863844716047106068).
You're welcome to ping me, @TechnicJelle.
