@tool
extends EditorPlugin

var _panel: Control

func _enter_tree() -> void:
	_panel = preload("ui/generator_panel.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_LEFT_UL, _panel)

func _exit_tree() -> void:
	if _panel:
		remove_control_from_docks(_panel)
		_panel.queue_free()
