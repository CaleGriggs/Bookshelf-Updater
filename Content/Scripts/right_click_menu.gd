extends Control

var book : Node
@onready var editButton: Button = $Panel/VBoxContainer/Edit
@onready var mainNode: Node = get_tree().current_scene

func _on_Edit() -> void:
	var editMenu = mainNode.newBookMenuScene.instantiate()
	mainNode.add_child(editMenu)
	await editMenu._ready
	editMenu.editThis(book)
	mainNode.rightClickMenuToggle = false
	queue_free()

func _on_delete() -> void:
	var confirmation : Node = mainNode.confirmWin.instantiate()
	mainNode.add_child(confirmation)
	await confirmation._ready
	confirmation.setMessage("Are you sure you want to delete " + book.title_label.text)
	if await confirmation.response:
		book.delete()
		queue_free()
		mainNode.rightClickMenuToggle = false
	else:
		mainNode.rightClickMenuToggle = false
		queue_free()
