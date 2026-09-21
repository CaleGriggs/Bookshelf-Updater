extends Node

@export var cardScene : PackedScene
@export var rightClickMenuScene : PackedScene
@export var newBookMenuScene : PackedScene
@export var closeSave : PackedScene
@export var confirmWin : PackedScene
var rightClickMenu : Node
var rightClickMenuToggle : bool = false
var saveScript : SaveData

func canQuit() -> bool:
	var menu := confirmWin.instantiate()
	add_child(menu)
	await menu._ready
	menu.setMessage("Are you sure you want to close?")
	var response : bool = await menu.response
	if response:
		saveJSON()
		menu.queue_free()
		return response
	else:
		return response

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if await canQuit():
			get_tree().quit()

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	saveScript = await SaveData.new(self)
	await _ready
	get_window().min_size = Vector2i(780,400)
	if !saveScript.saveInitailized:
		await saveScript.initSignal
	var bookshelf : Dictionary = JSON.parse_string(FileAccess.open(saveScript.bookshelfLocation, FileAccess.READ).get_as_text())
	openBookshelf(bookshelf)
	%CurrentAddButton.button_up.connect(addBook.bind("Current"))
	%UpNextAddButton.button_up.connect(addBook.bind("Up Next"))
	%CompleteAddButton.button_up.connect(addBook.bind("Completed"))

func buildCard(book : Dictionary, category : String) -> Control:
	var card = cardScene.instantiate()
	card.set_info(book)
	card.click.connect(_handleClicks)
	match category:
		"current":
			%Current.add_child(card)
		"up_next":
			%"Up Next".add_child(card)
		"completed":
			%Completed.add_child(card)
	return card

func openBookshelf(bookshelf : Dictionary) -> void:
	for category in bookshelf:
		for book in bookshelf[category]:
			buildCard(book, category)

func _on_gui_input(_event: InputEvent) -> void:
	#mouse
	if _event.is_released() and _event is InputEventMouseButton:
		#left click
		if _event.button_index == 1:
			_handleClicks(_event, self)

func _handleClicks(_event : InputEvent, book : Node) -> void:
	if _event.button_index == 2:
		_displayRightClickMenu(get_viewport().get_mouse_position(), book)
	if _event.button_index == 1:
		hideRightClickMenu()

func _displayRightClickMenu(mousePos : Vector2, book : Node) -> void:
	if !rightClickMenuToggle:
		rightClickMenuToggle = true
	else:
		rightClickMenu.queue_free()
		await rightClickMenu.tree_exited
	rightClickMenu = rightClickMenuScene.instantiate()
	get_tree().current_scene.add_child(rightClickMenu)
	if mousePos.y + rightClickMenu.size.y >= get_window().size.y:
		#too close to bottom of the window
		#place menu's bottom edge above mouse 
		mousePos.y = mousePos.y - rightClickMenu.size.y
	if mousePos.x + rightClickMenu.size.x >= get_window().size.x:
		#too close to right side of window
		#pace menu's right side left of mouse
		mousePos.x = mousePos.x - rightClickMenu.size.x
	rightClickMenu.position = mousePos
	rightClickMenu.book = book

func hideRightClickMenu() -> void:
	if rightClickMenuToggle:
		rightClickMenuToggle = false
		rightClickMenu.queue_free()

func addBook(category: String) -> void:
	var newBookMenu = newBookMenuScene.instantiate()
	self.add_child(newBookMenu)
	var id : int
	match category:
		"Current":
			id = 0
		"Up Next":
			id = 1
		"Completed":
			id = 2
	newBookMenu.setCategory(id)
	if await newBookMenu.bookCreated:
		saveJSON()

func saveJSON() -> void:
	var current : Array = []
	var up_next : Array = []
	var completed : Array = []
	for child in %Current.get_children():
		current.append(child.JSONinfo)
	for child in %"Up Next".get_children():
		up_next.append(child.JSONinfo)
	for child in %Completed.get_children():
		completed.append(child.JSONinfo)
	var bookshelf : Dictionary = {
		"current" : current, 
		"up_next" : up_next,
		"completed" : completed
	}
	saveScript.saveBookshelf(bookshelf)
