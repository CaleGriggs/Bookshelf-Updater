extends Control

@onready var mainNode: Node = get_tree().current_scene
var saveScript : SaveData

@onready var category: MenuButton = %Category
@onready var title: LineEdit = %Title
@onready var author: LineEdit = %Author
@onready var release: LineEdit = %Release
@onready var isbn: LineEdit = %ISBN
@onready var book_type: LineEdit = %"Book Type"
@onready var link: LineEdit = %Link
@onready var save_button: Button = %SaveButton
@onready var close_button: Button = %CloseButton
@onready var cover_button: Button = %CoverButton
@onready var cover_texture_rect: TextureRect = %CoverTextureRect
@onready var cover_name: LineEdit = %CoverName
@onready var rating: MenuButton = %Rating
@onready var finished_container: HBoxContainer = %Finished
var finished : String = "No"

var cover_extension: String = ""

const NEW_BOOK_THEME = preload("uid://dth2j5gd3kavv")
const ERROR_NEW_BOOK_THEME = preload("uid://cyq7a4nv25nc0")
const YN_THEME = preload("uid://cjd6kyv8tes4v")
const ERROR_YN_THEME = preload("uid://s0ek856xby3t")

var editBook : Node = null
var oldCover : String = ""
var newBookCover : String = ""
var justRename : bool = false

signal bookCreated

func _ready() -> void:
	category.get_popup().id_pressed.connect(setCategory)
	rating.get_popup().id_pressed.connect(setRating)
	await ready
	saveScript = mainNode.saveScript

## Edit existing book
func editThis(book : Node) -> void:
	editBook = book
	category.text = book.get_parent().name
	title.text = book.JSONinfo["Title"]
	author.text = book.JSONinfo["Author"]
	release.text = book.JSONinfo["Released"]
	isbn.text = book.JSONinfo["ISBN"]
	book_type.text = book.JSONinfo["Booktype"]
	link.text = book.JSONinfo["Link"]
	var coverPath : String = book.JSONinfo["Cover"]
	cover_name.text = coverPath.split(".")[0]
	oldCover = cover_name.text
	cover_extension = "." + coverPath.split(".")[1]
	cover_texture_rect.texture = book.cover_texture.texture_normal
	%Extension.text =  "*" + cover_extension
	mainNode.saveJSON()

func onTextUpdate(node : Node) -> void:
	if node.theme == ERROR_NEW_BOOK_THEME:
		node.theme = NEW_BOOK_THEME

func _on_Fin_YN(source : Node) -> void:
	if source == %Fin_Y:
		%Fin_N.set_pressed_no_signal(false)
		finished = "Yes"
	if source == %Fin_N:
		%Fin_Y.set_pressed_no_signal(false)
		finished = "No"
	finished_container.theme = YN_THEME

func checkEmpty() -> bool:
	var passFail = true
	if category.text == "" or category.text == "Category":
		category.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		category.theme = NEW_BOOK_THEME
	if title.text == "":
		title.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		title.theme = NEW_BOOK_THEME
	if author.text == "":
		author.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		author.theme = NEW_BOOK_THEME
	if release.text == "":
		release.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		release.theme = NEW_BOOK_THEME
	if isbn.text == "":
		isbn.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		isbn.theme = NEW_BOOK_THEME
	if book_type.text == "":
		book_type.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		book_type.theme = NEW_BOOK_THEME
	if link.text == "":
		link.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		link.theme = NEW_BOOK_THEME
	if cover_texture_rect.texture == null:
		cover_button.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		cover_texture_rect.theme = NEW_BOOK_THEME
	if cover_name.text == "":
		cover_name.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		cover_name.theme = NEW_BOOK_THEME
	if category.text == "Completed" && rating.text == "Rating":
		rating.theme = ERROR_NEW_BOOK_THEME
		passFail = false
	else:
		rating.theme = NEW_BOOK_THEME
	if finished == "":
		finished_container.theme = ERROR_YN_THEME
		passFail = false
	else:
		finished_container.theme = YN_THEME
	return passFail

func setCategory(id : int) -> void:
	match id:
		0:
			category.text = "Current"
		1:
			category.text = "Up Next"
		2:
			category.text = "Completed"
		_:
			category.text = "Category"
	if category.text != "Category" && category.theme == ERROR_NEW_BOOK_THEME:
		category.theme = NEW_BOOK_THEME
	if category.text == "Completed":
		rating.visible = true
		finished_container.visible = true
		finished = ""
	else:
		rating.text = "Rating"
		rating.visible = false
		rating.remove_theme_color_override("font_color")
		finished_container.visible = false
		finished = "No"
		%Fin_Y.set_pressed_no_signal(false)
		%Fin_N.set_pressed_no_signal(false)

func setRating(id : int) -> void:
	match id:
		0:
			rating.text = "Loved it"
			rating.add_theme_color_override("font_color",Color.MAGENTA)
		1:
			rating.text = "Liked it"
			rating.add_theme_color_override("font_color",Color.LIME)
		2:
			rating.text = "It was ok"
			rating.add_theme_color_override("font_color",Color.GOLD)
		4:
			rating.text = "Didn't like it"
			rating.add_theme_color_override("font_color",Color.RED)
		_:
			rating.text = "Rating"
			rating.remove_theme_color_override("font_color")
	if rating.text != "Rating" && rating.theme == ERROR_NEW_BOOK_THEME:
		rating.theme = NEW_BOOK_THEME

## Choosing a new cover image
func _on_cover_button_up() -> void:
	# Search for image
	# Copy image to save location
	var dialog = FileDialog.new()
	add_child(dialog)
	
	dialog.use_native_dialog = true
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	
	dialog.title = "Select an iamge"
	dialog.filters = ["*.jpg,*.png ; Image Files"]
	dialog.file_selected.connect(_on_file_selected)
	
	dialog.canceled.connect(func(): print("Closed without selection"))
	dialog.popup_centered()

func _on_file_selected(cover : String) -> void:
	var img := Image.new()
	var error := img.load(cover)
	newBookCover = cover
	if error == OK:
		cover_texture_rect.texture = ImageTexture.create_from_image(img)
		cover_name.text = cover.get_file().split(".")[0]
		cover_extension = "." + cover.get_extension()
		
		if cover_button.theme == ERROR_NEW_BOOK_THEME:
			cover_button.theme = NEW_BOOK_THEME
	else:
		cover_extension = ""
		print("Error loading {path}".format(cover))
	if cover.get_base_dir() == saveScript.imagesLocation:
		justRename = true
	%Extension.text = "*" + cover_extension

func _on_save_button_up() -> void:
	# Save to dictionary, create card
	var cover : String = cover_name.text
	var cat : String = ""
	match category.text:
		"Current":
			cat= "current"
		"Up Next":
			cat = "up_next"
		"Completed":
			cat = "completed"
	var rat : String = ""
	if rating.text == "Rating":
		rat = "N/A"
	else:
		rat = rating.text
	if not checkEmpty():
		return
	cover = cover + cover_extension
	if oldCover+cover_extension != cover and oldCover != "":
		updateCover(cover)
	if newBookCover != "":
		addNewCover(cover)
	var newbook : Dictionary ={
		'Title' : title.text,
		'Cover' : cover,
		'Author' : author.text,
		'Released' : release.text,
		'Booktype' : book_type.text,
		'ISBN' : isbn.text, 
		'Rating' : rat,
		'Finished' : "Yes" if finished == "Yes" else "No",
		'Link' : link.text
		}
	if editBook:
		editBook.queue_free()
	var newCard = mainNode.buildCard(newbook, cat)
	if cat == "completed":
		newCard.get_parent().move_child(newCard,0)
	bookCreated.emit(true)
	queue_free()

func addNewCover(newName : String) -> void:
	var saveLocation : String = saveScript.imagesLocation.path_join(newName)
	if justRename:
		var error = DirAccess.rename_absolute(newBookCover, saveLocation)
		if error == OK:
			pass
		else:
			print("Error saving image")
	else:
		var error = DirAccess.copy_absolute(newBookCover, saveLocation)
		if error == OK:
			
			pass
		else:
			print("Error saving image")

func updateCover(newCover : String) -> void:
	var imgs : DirAccess = DirAccess.open(saveScript.imagesLocation)
	if imgs:
		var error = imgs.rename(oldCover+cover_extension, newCover)
		if error == OK:
			pass
		else:
			print("Error renaming image")

func _on_close_button_up() -> void:
	bookCreated.emit(false)
	queue_free()
