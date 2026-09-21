extends Control

var exePath : String

const NORMAL_THEME = preload("uid://dth2j5gd3kavv")
const ERROR_THEME = preload("uid://cyq7a4nv25nc0")

##[bookshelf.json, /imgs]
signal onSave

func _ready() -> void:
	pass
	
func checkEmpty() -> bool: 
	var passFail : bool = true
	if %BookJSONSel.text == "Select Bookshelf Location" or %BookJSONSel.text == "Invalid Locatoin":
		passFail = false
		%BookJSONSel.theme = ERROR_THEME
	else:
		%BookJSONSel.theme = NORMAL_THEME
	if %ImgsDirSel.text == "Select Images Location" or %ImgsDirSel.text == "Invalid Locatoin":
		passFail = false
		%ImgsDirSel.theme = ERROR_THEME
	else:
		%ImgsDirSel.theme = NORMAL_THEME
	return passFail

func _on_location_button(caller : Node) -> void:
	var path : String = await set_save_dir(caller) + "/"
	if !path.contains(exePath):
		caller.text = "Invalid Locatoin"
		caller.theme = ERROR_THEME
		return
	if path != exePath:
		path = path.split(exePath)[1]
	else:
		path = ""
	caller.theme = NORMAL_THEME
	caller.text = path

func _on_save_button_button_up() -> void:
	if checkEmpty():
		onSave.emit([%BookJSONSel.text, %ImgsDirSel.text])
		queue_free()

func set_save_dir(caller : Node) -> String:
	var newLocation
	var dialog = FileDialog.new()
	caller.add_child(dialog)
	
	dialog.use_native_dialog = true
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.title = "Select a save location"
	dialog.popup_centered()
	newLocation = await dialog.dir_selected
	
	dialog.queue_free()
	
	return newLocation
