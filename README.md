![GoLogger_Icon_Title](https://github.com/user-attachments/assets/2856b4fb-8d18-49b5-bd60-8a8015b6723a)

GoLogger is a simple yet flexible logging framework for Godot 4, designed to log game events and data to external .log files accessible by both developers and players. With minimal setup required, GoLogger can be integrated quickly and easily into any project. GoLogger runs in the background, capturing the data you define with timestamps, providing a snapshot of events leading up to crashes, bugs, or other issues, making it easier for users to share logs and investigate problems.

Log entries are as simple as calling `Log.entry()`(similar and as easy to use as `print()`) and can include any data that can be converted into a string. The framework is fully customizable, allowing you to log as much or as little information as you require. Format strings in whichever way you prefer. 
```gdscript
Log.entry("Current Player health is %s/%s." % (current_health, max_health))
Log.entry(str("Current Player health is", current_health, "/", max_health, "."))
# Resulting entry: [14:44:44] Current Player health is 85/100.
```
## **Contents**
1. Installation and setup
2. How to use GoLogger
   * Example usage of the main functions
   * Creating log entries with data
   * Managing log categories
4. Managing .log files
   * Entry count limit
   * Sesssion timer
   * File count limit

## Installation and setup:
**Note: Godot will print several errors upon importing the plugin and is expected!** *GoLogger simply requires the main script to be an autoload, which isn't added until the plugin is enabled.*

* **Importing the plugin:** Only import the "addons" into your project's root directory. The folder structure should look like `res://addons/GoLogger`.

* **Enable the plugin:** Navigate to `Project > Project Settings > Plugins`, and check "GoLogger" in the list of available plugins to enable it.<br>
*If errors persist, ensure "GoLogger.tscn" was added properly as an autoload and then restart Godot.*<br>
![enable_plugin](https://github.com/user-attachments/assets/6d201a57-638d-48a6-a9c0-fc8719beff37)

You're all set! Next time you run your project, directories and .log files will be created according to the settings and categories you've setup in the dock. It’s recommended to add `Log.stop_session()` before calling `get_tree().quit()` in your exit game function to help differentiate between normal exits, crashes, or forced closures, depending on whether the log file ends with "Stopped session."<br><br>


## How to use GoLogger:<br>
GoLogger uses 'sessions' to indicate when its logging or not. Each session creates a new log file with the timestamp of when the session was started. Sessions are also **global**, meaning that stopping a session will start and stop logging for all categories simultaneously. There are three main ways to start and stop sessions. 
* **Using the `autostart` setting** will start a session when you run your project.
* **Hotkeys** can perform the three main functions of the plugin(start, copy and stop)
* **Calling the functions though code**. You can call the functions through code as well and since the script is an autoload. You can call them from any script.

`Save Session Copy` feature was introduced in v1.2, allowing users to save the current session's logs into each respective category's subfolder. This feature serves two key purposes:
* **Prevent Deletion:** Oldest logs are automatically deleted when the file limit is reached. Saving a copy protects specific logs from being removed. *Simply moving a log file out of the category folder will of course also prevent deletion.*
* **Preserve Important Data:** When using the **Entry Count Limit** + **Remove Old Entries** options, older entries are deleted to make room for new ones. If a bug or unexpected event occurs during playtesting, you can use this feature to save the log without stopping the session or your game without the risk of overwriting the important log entries.

### **Example usage of the main functions:**<br>
In Godot, strings can be formatted in many ways. All of which can be done when creating log entries. Use any 
```gdscript
# General use, simply starts the session. Hotkey:  Ctrl + Shift + O
Log.start_session()
# Starts session 1.2 seconds after the call using the 'start_delay' parameter.
await Log.start_session(1.2)

# No category_index defined > defaults to category 0("game" category by default).
Log.entry(str("Current game time: ", time_of_day))
# Resulting entry : [2024-11-11 19:17:27] Current game time: 16.30

# Logs into category 1("player" category by default).
Log.entry(str("Player's current health: ", current_health, "(", max_health, ")"), 1)
# Resulting entry: [2024-11-11 19:17:27] Player's current health: 94(100)

# Initiates the "copy session" operation by showing the name prompt popup. Hotkey:  Ctrl + Shift + U
Log.save_copy()

# Stops an active session. Hotkey:  Ctrl + Shift + P
Log.stop_session() 
```

*The parameter `start_delay` provides the option to delay the start of a session by the specified time in seconds*


### **Creating log entries with data:**<br>
**Simply installing GoLogger does not log any entries**. This plugin is a frame work for you to define your own log entries in your code, including any string message and any data you want to log. Any data that can be converted to a string by using `str(data)` can be added to an entry.<br>

The `entry()` function has two parameters: `entry(log_entry : String, category_index : int)`
Only the first parameter mandatory and needs to be defined when calling the function while the rest are optional and allow you to customize the formatting of your log entry to your liking.
* `log_entry` - *Mandatory* - The string that makes up your log entry. Include any data that can be converted to a string can be logged.
* `category_index` - *Optional* - This parameter specifies the category or file where the entry is logged. The index of every category is shown in the "Categories" tab of the dock at the top left of each category.<br>

*Calling this function without defining an index will make it default to log into the category with index 0 which is why it's recommended to have your "base" category(like "game") as the 0 indexed category.* <br><br>

## Managing log categories:
GoLogger will create directories for each category in the dock's "category" tab. By default, a "game" and a "player" category is added for you but you can add, remove or rename them to fit your project's need. When a category name is applied, folders are created with the name of each category within the `base_directory` and once a session is started, the folders for all categories with applied names are created(if they don't already exist) and a .log file are saved inside. The number at the top left of each category is the `category_index` of that category. Meaning if you want to log an entry into the "player" category, use the index as the last parameter when calling the function. Example `Log.entry("My player entry", 1)`.<br> 
![GoLoggerCategoryDock](https://github.com/user-attachments/assets/f4346da0-a9b5-4b00-83ba-147bcfdd3481)

*Notes:*
* *The Reset button will remove locked categories. The lock button just disables the text field, apply and delete buttons.*
* *Folders for categories created by the plugin aren't deleted when you delete a category in the dock. This is to prevent accidental deletion of log files. It's best to open the directory using the "Open" button and manually delete the corresponding folder of any deleted category.*

## Managing .log file size:
A potential pitfall to consider when logging large/growing data is how Godot's `FileAccess` handles file writing. The `FileAccess.WRITE` mode truncates(deletes) the file's content, so the plugin first reads and stores old entries with `FileAccess.READ`, then re-enters them before appending a new entry. This process can cause performance issues when files become excessively large, leading to stuttering or slowdowns, especially during long sessions or with multiple systems logging to the same category. To address this, GoLogger provides two methods to limit log file sizes:

#### Entry Count Limit(recommended):
As the name suggests, the number of entries are counted and if they exceed the limit, you can either **stop** the session, **stop and start** a new session or you can **remove the oldest entries** to make space for the new ones. Objectively, removing old entries is the better method to this potential issue which is why it is recommended to use this regardless of whether you're experiencing issues or not. Additionally, remember that sessions are global, meaning once the entry count is reached on one category, the stop/start session affects all categories when using stop/start session action.<br>

#### Session Timer:
Whenever a session is started, a Timer is started using the `session_duration` setting as the wait time. This timer will stop the active session upon timing out and a new session can be started aftewards. The downside of this method is that there's still the potential of logging tons of entries within the session duration. However, the Session Timer still has other uses, stress testing a new system or you simply need to log for a specific time window and dont need continuous logging. The signals `session_timer_started` and `session_timer_stopped` were added to sync up any potential system or feature with logging sessions.

#### Both Entry Count Limit and Session Timer:
You can use also use both as well and GoLogger will still use both "Entry Count Action" and "Session Timer Action" settings to independently set the actions taken. That way, you can remove old entries with Entry Count and restart or stop a session entirely once the Session Timer times-out. 

#### File count limit:
Despite .log files taking minimal storage space, generating an endless amount of files is never a good idea. Therefore, GoLogger has an adjustable `file count limit` setting. By default, this limit is set to 10 and will delete the log file with the oldest date- and timestamp. Of course, this means it only deletes files in that directory, meaning you can move a log out of the folder to save it. It's possible to turn this off by setting the value to 0 but it is **NOT** recommended!
