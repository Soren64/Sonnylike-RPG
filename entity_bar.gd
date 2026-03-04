extends Control

@onready var hp_bar: ProgressBar = $HBoxContainer/HPBar
@onready var hp_text = $HBoxContainer/HPBar/Label
@onready var mp_bar: ProgressBar = $HBoxContainer/MPBar
@onready var mp_text = $HBoxContainer/MPBar/Label
@onready var name_label = $HBoxContainer/NameLabel

var entity: Entity = null

func set_entity(e: Entity) -> void:
	entity = e
	name_label.text = entity.entity_name
	entity.connect("stat_changed", Callable(self, "_on_stat_changed"))
	# Force an initial update so the bars show current values right away
	entity._emit_stat_update("hp")
	entity._emit_stat_update("mp")

func _on_stat_changed(stat_name: String, current_value: int, max_value: int):
	match stat_name:
		"hp":
			hp_bar.max_value = max_value
			hp_bar.value = current_value
			hp_text.text = str(current_value, " / ", max_value)
		"mp":
			mp_bar.max_value = max_value
			mp_bar.value = current_value
			mp_text.text = str(current_value, " / ", max_value)
