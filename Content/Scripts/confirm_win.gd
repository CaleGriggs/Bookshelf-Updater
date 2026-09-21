extends Control

@onready var mainNode: Node = get_tree().current_scene
@onready var message_label: Label = %MessageLabel
@onready var yes_button: Button = $CenterContainer/AspectRatioContainer/VBoxContainer/HBoxContainer/YesButton
@onready var no_button: Button = $CenterContainer/AspectRatioContainer/VBoxContainer/HBoxContainer/NoButton

signal response

func _ready() -> void:
	pass

func setMessage(msg : String) -> void:
	message_label.text = msg

func _on_Yes() -> void:
	response.emit(true)
	queue_free()
	
func _on_No() -> void:
	response.emit(false)
	queue_free()
