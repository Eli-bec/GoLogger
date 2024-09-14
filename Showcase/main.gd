extends Control

## Disregard this script. Only exists to facilitate the showcase simulations in the example scene.

@onready var gamelog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/GAMElog
@onready var playerlog: Label = $LogContents/MarginContainer/ScrollContainer/VBoxContainer/HBoxContainer2/PLAYERlog

var rng := RandomNumberGenerator.new()


func _ready() -> void:
	randomize()
	GoLogger.session_status_changed.connect(_on_session_status_changed)
	for c in $VBoxContainer/Simulations/MarginContainer/VBoxContainer.get_children(): # Event Simulation buttons
		if c is Button:
			c.button_up.connect(_on_entry_sim_button_up.bind(c))
	
	var _fg = FileAccess.open(get_last_log(Log.GAME_PATH), FileAccess.READ)
	var _gc = ""
	if _fg != null: _gc = _fg.get_as_text()
	gamelog.text = _gc
	var _pg = FileAccess.open(get_last_log(Log.PLAYER_PATH), FileAccess.READ)
	var _pc = ""
	if _pg != null: _pc = _fg.get_as_text()
	playerlog.text = _gc

## Returns the last log in a directory. Call using the paths specified in [Log]. Example usage: [code]FileAccess.open(get_last_log(Log.GAME_PATH), FileAccess.READ[/code]
func get_last_log(path) -> String:
	var _dir = DirAccess.open(path) 
	if !_dir:
		var _err = DirAccess.get_open_error()
		if _err != OK:
			printerr("Showcase Error: Attempting to open directory (", path, ") to find .log -> Error[", _err, "]")
			return ""
	else: 
		var _files = _dir.get_files()
		return str(path + _files[_files.size() -1]) 
	return ""


## Receives signal from [GoLogger] whenever a status is changed.
func _on_session_status_changed():
	var _f = FileAccess.open(get_last_log(Log.GAME_PATH), FileAccess.READ)
	if !_f:
		var _err = FileAccess.get_open_error()
		if _err != OK: gamelog.text = str("GoLogger Error: Reading file (", get_last_log(Log.GAME_PATH), ") -> Error[", _err, "]")
	else:
		var _c = _f.get_as_text()
		gamelog.text = _c
	var _fl = FileAccess.open(get_last_log(Log.PLAYER_PATH), FileAccess.READ)
	if !_fl:
		var _err = FileAccess.get_open_error()
		if _err != OK: playerlog.text = str("GoLogger Error: Reading file (", get_last_log(Log.PLAYER_PATH), ") -> Error[", _err, "]")
	else:
		var _c = _f.get_as_text()
		playerlog.text = _c

 

## Buttons that simulates log entries.
func _on_entry_sim_button_up(btn : Button):
	var items : Array[String] = ["Pipe", "Handgun", "Gunpowder", "Uncased Bullets"]
	match btn.get_name():
		"Pickup":
			Log.entry(1, str("Picked up ", items[rng.randi_range(0, items.size() -1)], " x", rng.randi_range(1, 6), "."))
		"Combine": 
			Log.entry(1, str("Combined ItemA[Gunpowder] and itemB[Uncased Bullets] to create item[Handgun Ammo] x", rng.randi_range(1, 6), "."))
		"Discard": 
			Log.entry(1, str("Discarded [", items[rng.randi_range(0, items.size() -1)], "] x", randi_range(1, 6), "."))
		"Death": 
			Log.entry(1, "Player died")
		"Respawn": 
			Log.entry(1, str("Player respawned @", Vector2(randi_range(0, 512), randi_range(0, 512)), "."))
		"Load":
			Log.entry(0, str("Loaded GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Save": 
			Log.entry(0, str("Saved GameSave#1 on Slot#", randi_range(1, 3), "."))
		"Exit": 
			Log.entry(0, "Exited game, closing session.")
		
	var _fg = FileAccess.open(get_last_log(Log.GAME_PATH), FileAccess.READ)
	var _cg = ""
	if _fg != null: _cg = _fg.get_as_text()
	gamelog.text = _cg
	var _fp = FileAccess.open(get_last_log(Log.PLAYER_PATH), FileAccess.READ)
	var _cp = ""
	if _fp != null: _cp = _fp.get_as_text()
	playerlog.text = _cp
