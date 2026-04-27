extends Control

func _on_button_pressed():
	get_tree().paused = false
	visible = false

func _on_button_2_pressed() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Escenas/Inicio.tscn")
