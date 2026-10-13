extends Button

const home : PackedScene = preload("res://home.tscn")

func _on_pressed() -> void:
	get_tree().change_scene_to_packed(home)
