extends Control

signal typing_toggled(is_typing)

const TOGGLE_KEY = KEY_ENTER
const MESSAGE_FORMAT = "%s: %s"

sync var chat_text: = "" setget set_chat_text

var player_name: = "Unknown"

onready var line_edit: LineEdit = $LineEdit
onready var chat_history: RichTextLabel = $Panel/ChatHistory

func _input(event: InputEvent) -> void:
	pass


func _unhandled_input(event: InputEvent) -> void:
	if is_typing():
		get_tree().set_input_as_handled()

	if event.is_action_pressed("ToggleChatWrite"):
		toggle_typing()

func toggle() -> bool:
	visible = not visible

	if not visible:
		$LineEdit.hide()

	return visible

func toggle_typing() -> bool:
	$LineEdit.visible = not $LineEdit.visible and visible

	return $LineEdit.visible

func is_typing() -> bool:
	return $LineEdit.visible

func _on_LineEdit_text_entered(new_text: String) -> void:
	toggle_typing()
	if new_text:
		var formatted_message = MESSAGE_FORMAT % [player_name, new_text]
		line_edit.text = ""
		rset("chat_text", chat_text + formatted_message)

func _on_LineEdit_visibility_changed() -> void:
	if line_edit.visible:
		line_edit.grab_focus()
	else:
		line_edit.release_focus()

func set_chat_text(value: String) -> void:
	visible = true
	chat_text = "%s\n" % value
	chat_history.text = chat_text


func _on_LineEdit_gui_input(event: InputEvent) -> void:
	get_tree().set_input_as_handled()
	pass
