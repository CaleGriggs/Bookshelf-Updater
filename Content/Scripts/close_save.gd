extends Control

@onready var mainNode: Node = get_tree().current_scene

signal response

func _on_save_button_up() -> void:
	response.emit("Save")

func _on_cancel_button_up() -> void:
	response.emit("Cancel")

func _on_discard_button_up() -> void:
	response.emit("Discard")
