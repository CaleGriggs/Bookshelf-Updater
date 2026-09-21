class_name SaveData
extends  RefCounted

var mainNode : Node
var imagesLocation : String
var bookshelfLocation : String
var preferences : Dictionary
var exePath : String

const NEW_SAVE_MENU = preload("uid://bust4awwjtl5l")

var saveInitailized = false
signal initSignal

func _init(newNode : Node) -> void:
	self.mainNode = newNode
	var saveFile : FileAccess
	if OS.has_feature("editor"):
		exePath = ProjectSettings.globalize_path("res://")
	else:
		exePath = OS.get_executable_path().get_base_dir()

	# open save file -> copy to internal -> close save file
	saveFile = findFile("save.dat", "")
	var saveInfo : Dictionary
	if saveFile.get_as_text() == "":
		saveInfo = await initSaveData()
		saveFile.store_string(JSON.stringify(saveInfo))
	else:
		saveInfo = JSON.parse_string(saveFile.get_as_text())
	saveFile.close()
	imagesLocation = exePath + saveInfo["imagesLocation"]
	bookshelfLocation = exePath + saveInfo["bookshelfLocation"]
	var bshelf : FileAccess = FileAccess.open(bookshelfLocation,FileAccess.READ)
	if !bshelf or bshelf.get_as_text() == "":
		initBookshelf(bookshelfLocation.split("/bookshelf.json")[0])
	saveInitailized = true
	initSignal.emit()
	
func initBookshelf(location : String) -> FileAccess:
	var bookshelf : FileAccess = findFile("bookshelf.json", location)
	if bookshelf.get_as_text() == "":
		bookshelf.store_string(JSON.stringify({"current" : [], "up_next" : [],"completed" : []}))
	return bookshelf
	
func initSaveData() -> Dictionary:
	var response : Array
	var saveMenu : Node = NEW_SAVE_MENU.instantiate()
	mainNode.add_child(saveMenu)
	await saveMenu._ready
	saveMenu.exePath = exePath
	response = await saveMenu.onSave
	var bshelf : FileAccess = initBookshelf(response[0])
	var defaultDict : Dictionary = {
		"imagesLocation" : response[1],
		"bookshelfLocation" : bshelf.get_path().split(exePath)[1]
	}
	bshelf.close()
	return defaultDict

func findFile(file : String, relPath : String) -> FileAccess:
	var savePath : String
	savePath = relPath.path_join(file)
	if !FileAccess.file_exists(exePath + savePath):
		# does not exist, create it
		return FileAccess.open(exePath + savePath, FileAccess.WRITE)
	else:
		return FileAccess.open(exePath + savePath, FileAccess.READ)

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

func saveBookshelf(newSave : Dictionary) -> void:
	var bookshelf : FileAccess = FileAccess.open(bookshelfLocation,FileAccess.WRITE)
	if bookshelf:
		bookshelf.store_string(JSON.stringify(newSave))
		bookshelf.close()
