# ![GoLogger.svg](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/GoLogger.svg) GoLogger
A basic lightweight logging system for game events in into an external .log file for Godot 4.<br>
 
https://github.com/user-attachments/assets/f8b55481-cd32-4be3-9e06-df4368d1183c

<br><br>
## Introduction
Have you ever found yourself working on multiple new features or a large system involving numerous scripts, adding countless print statements to debug? This can clutter the output, making the information difficult to decipher and even harder to manage. Or perhaps you want your game to record events to help debug issues that your players encounter, especially when you can’t access their instance. In that case, creating a logging system to record game events could provide a snapshot of the events leading up to a bug or crash.

This plugin is a basic logging system designed to serve as a foundation for you to build upon. As such, it is intentionally minimalistic, making it flexible and scalable. With a few small adjustments, you can modify it to categorize events into separate files. The system logs any game event or data to a .log file, but it won’t automatically generate log entries once installed. However, using this plugin is as simple as writing a print() statement:
	
 	Log.entry("Your log entry message.")	# Result: [2024-04-04 14:04:44] Your log entry message.

**Note: This system is only as comprehensive and detailed as you make it.** But it also works as a simple standalone logging system as is.<br><br><br>

## .log files
The system in it's current state doesn't support multiple file handling. It will use one file at any time but there's an option of two directory locations of the file. The file is truncated between sessions and you can easily stop and start new sessions at runtime(see "How to use" section). 
 * DEVFILE - Located in the project directory at `res://GameLog/game.log`, this is intended for use during development. Since it's stored within the project files, it’s easily accessible.
 * FILE - Located in the User Data folder at "user://logs/game.log" alongside other log files generated by Godot. This should be used for release versions, as the DEVFILE will not be accessible once the project is built. The idea is that if a player encounters a bug or crash and reports it, you, as the developer, can ask them to include the log file with their bug report to gain insights into the chain of events leading to the issue.
 * To specify the log file location in your project, find the `Log.gd` file in the addon folder and modify this line:
	`const DEVFILE = "res://addons/GoLogger/game.log"`

This system can be further built upon to add additional files or create separate log files for different events. For instance, in my personal version of this system. I create "player.log" for player events, "ui.log" for UI events and "game.log" for universal game events.<br><br><br>

## Installation and setup:
The system requires an autoload to manage a signal and a few variables. To simplify and automate the installation process, a separate autoload (GoLogger.gd) is provided, containing just 8 lines of code. However, it is **highly** recommended that you incorporate this code into one of your existing autoloads instead. Steps for this is detailed in **Elaborate Setup**.

###**Installation:**
* Download the plugin from either GitHub(!https://github.com/Burloe/GoLogger) or the Asset Library. If you download the .zip from GitHub, extract the addons folder to your PC then place it in your project's root directory. The folder structure should look like `res://addons/GoLogger`. 
* Navigate to `Project > Project Settings > Plugins`, where you should see "GoLogger" as an unchecked entry in the list of installed plugins. Check it to activate the plugin.
* Go to `Project > Project Settings > Globals > Autoload` and ensure that the GoLogger autoload has been added correctly. If not, you can manually add it by clicking the folder icon, locating GoLogger.gd, and restarting Godot.

### **Simple setup** - For a basic, standalone logging system:
1. To switch between saving logs in the project folder and the User Data folder, open GoLogger.gd. Set `log_in_devfile` to false to save logs in the User Data folder or true to save them in your project folder.
2. You can also change the location of the game.log file by changing the path for the constants. For example if you want to save the DEVFILE in a folder of the root: `const DEVFILE = "res://logs/game.log"`.

	
### **Elaborate setup** - For those intending to further improve and customize the system:
In order for static functions to have access to variables and signals, an autoload script is required and as such, one was added to the plugin called `GoLogger.gd`. This autoload is only 8 lines of code which can and **should** be be merged into one of your existing autoloads. 
1. Copy the code below and put it into any of your existing autoload scripts. Then delete GoLogger.gd:

*It is REQUIRED to be an autoload! If your existing autoload already has a _ready() function declared, simply add the two _ready() lines from the code below inside your existing function.*

	signal session_status_changed(status : bool) ## Session Status is changed whenever a session is started or stopped.
	var session_status: bool = false ## Flags whether a log session is in progress or not. 
	var log_in_devfile : bool = true ## Flags whether or not logs are saved using the [param FILE](false) or [param DEVFILE](true).
	
	func _ready() -> void:
		session_status_changed.connect(_on_session_status_changed) 
		Log.start_session() # Begins the logging seesion
	
	func _on_session_status_changed(status : bool) -> void:
		session_status = status
  
3. In Log.gd, use "Find and Replace" to update any code referencing the deleted `GoLogger` autoload with your own updated one.
	Note: The example scene script also references the GoLogger.gd script, so this will break the example scene. However, you can fix this by using "Find and Replace" in the example script "main.gd" as well. This doesn't affect the logging system itself, but if you try to open scene "main.tscn" after completing these steps, you may encounter a series of errors.
**4. Optional:** At this point, you can delete plugin.gd and plugin.cfg and use the scripts as your own. Building upon this plugin and making it your own is not only encouraged, it was made for it.<br><br><br>


https://github.com/user-attachments/assets/24a0c8d2-d4ea-49f2-89fc-a2fc675c42c1



##How to use:
**Creating log entries:**<br>
Simply installing this plugin won't automatically generate log entries when you run your game. You still need to manually add log entries and specify the data each entry should display (if necessary). Fortunately, adding entries is as easy as writing `print()` calls, done with a single line of code:

	Log.entry("Your entry string here")
You can call this from any script in your project. The string message can contain almost any data, but you may need to convert that data into a string format using str(). For example:
	
 	Log.entry(str("Picked up item[", item_name, "] x", item_amount, "."))
Godot allows you to format the strings in certain ways. [See this documentation page for more information](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_format_string.html) 
  
**Changing the date and time flag on log entries:**<br>
The plugin will add the date and time to your entries automatically, but it's possible to change that. After you've added your string you can add an integer when you call `Log.entry("Message", 1)`. 0 includes date + time, 1 will only add the time and 2 will only show messages. If you find it cumbersome to add a 1 or 2 everytime you call `Log.entry()`. I recommend that you open the "Log.gd" script and find the function declaration for `entry()`. There you can change the flag from `date_time_flag : int = 0` to `date_time_flag : int = 1`(or 2). <br>
The date and time format used in this system is the UTC format(YYYY-MM-DDTHH:MM:SS), You can change it to use the local time format but note that if you are sent log files from other regions. The date and time will be in their local format, not yours. You change it by going into the "Log.gd" script and change the UTC parameter of each `Time.get_datetime_string_from_system()` and `Time.get_time_string_from_system()` call to false. [More info can be found in the doc page.](https://docs.godotengine.org/en/stable/classes/class_time.html#class-time-method-get-datetime-string-from-system)

**Switching between using the `DEVFILE` and the `FILE`:**<br>
Since this plugin runs entirely in the background, the only way to switch between the DEVFILE and FILE is to manually set `log_in_devfile` to true or false in the code of "GoLogger.gd". Adding a button or export variable to handle this switch is simple, as there are no signals or additional code execution tied to the variable. However, it is not recommended to just toggle the variable mid-session. While hotswapping the log file shouldn't cause errors, it will result in fragmented log files. Best practice is to use the `Log.stop_session()` and `Log.start_session()` before and after switching(see example usage below).

**How to stop and start sessions at runtime:**<br>
Using the above switching between the `DEVFILE` and the `FILE` as an example of when one might need to stop and start a session at runtime. Adding a toggle button in your game menu or in some debug panel is one way to achieve this.
	
 	func _on_button_toggled(toggle:bool) ->:
 		Log.stop_session()				# Stop session prior to swapping file
 		GoLogger.log_in_devfile = toggle  		# True will use DEVFILE, false will use FILE
   		log.start_session()				# Begins a new session on the other file
<br><br><br>

### Examples:
Here are some examples I use in my code for my save system and inventory.
![SaveSystem](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/Example/Example1.png)
![Inventory1](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/Example/Example2.png)
![Inventory2](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/Example/Example3.png)
![Log file contents](https://github.com/Burloe/GoLogger/blob/main/addons/GoLogger/Example/Example4.png)



