extends Control

const RATING_DEFAULT = preload("uid://ckjm660rm7aud")
const RATING_LOVE = preload("uid://djj0m5dayexfy")
const RATING_LIKE = preload("uid://c8ncsb3qnpt7k")
const RATING_OK = preload("uid://ibnmfnp7pqm0")
const RATING_HATE = preload("uid://bjh7n784ymwdm")

@onready var mainNode: Node = get_tree().current_scene
@onready var cover_texture: TextureButton = %CoverTexture
@onready var title_label: Label = %Title
@onready var author_label: Label = %Author
@onready var released_label: Label = %Released
@onready var isbn_label: Label = %ISBN
@onready var book_type_label: Label = %BookType
@onready var rating_finished_label: RichTextLabel = %RatingFinished
var JSONinfo : Dictionary

var imgs_dir : String 
const imgDefault = preload("uid://cpx2vgrxw0h2i")

signal click

func set_info(book : Dictionary) -> void:
	await ready
	JSONinfo = book
	imgs_dir = mainNode.saveScript.imagesLocation
	var ratingColor = setRatingColor(book["Rating"])
	
	loadImage(imgs_dir.path_join(book["Cover"]))
	title_label.text = (book["Title"])
	author_label.text = (book["Author"])
	released_label.text = (book["Released"])
	isbn_label.text = (book["ISBN"])
	book_type_label.text = (book["Booktype"])
	if book["Rating"] != "N/A":
		rating_finished_label.append_text(ratingColor + book["Rating"] + "[/color]\t\t")
	if book["Finished"] == "No":
		match get_parent().name:
			"Current":
				rating_finished_label.append_text("Unfinished")
			"Completed":
				rating_finished_label.append_text("[color=red]DNF[/color]")
			"Up Next":
				rating_finished_label.append_text("Not Started")
	else:
		rating_finished_label.append_text("Finished")
		
	cover_texture.tooltip_text = "Open link to " + JSONinfo["Link"]

func setRatingColor(rating: String) -> String:
	var ratingColor : String
	var stylebox : StyleBoxTexture = %CardBG.get_theme_stylebox("panel")
	var grad := GradientTexture2D.new()
	if stylebox is StyleBoxTexture:
		stylebox = stylebox.duplicate()
		
	match rating.to_lower():
		"loved it":
			grad.gradient = RATING_LOVE
			ratingColor = "[color=MAGENTA]"
		"liked it":
			grad.gradient = RATING_LIKE
			ratingColor = "[color=LIME]"
		"it was ok":
			grad.gradient = RATING_OK
			ratingColor = "[color=GOLD]"
		"didn't like it":
			grad.gradient = RATING_HATE
			ratingColor = "[color=DARK_RED]"
		_:
			grad.gradient = RATING_DEFAULT
			ratingColor = "[color=WEB_GRAY]"
			
	stylebox.texture = grad
	%CardBG.add_theme_stylebox_override("panel", stylebox)
	return ratingColor

func loadImage(path) -> void:
	var img := Image.new()
	var error := img.load(path)
	
	if error == OK:
		cover_texture.texture_normal = ImageTexture.create_from_image(img)
	else:
		cover_texture.texture_normal = imgDefault
		print("Error loading {path}".format(path))

func _on_gui_input(_event: InputEvent) -> void:
	#mouse
	if _event.is_released() and _event is InputEventMouseButton:
		#left click
		if _event.button_index == 1 or _event.button_index == 2:
			click.emit(_event, self)

func _on_cover_button_up() -> void:
	OS.shell_open(JSONinfo["Link"])
	
func delete() -> void:
	var cover : String = imgs_dir.path_join(JSONinfo["Cover"])
	if FileAccess.file_exists(cover):
		var error = DirAccess.remove_absolute(cover)
		if error == OK:
			pass
		else:
			print("Error deleting " + cover)
	queue_free()
