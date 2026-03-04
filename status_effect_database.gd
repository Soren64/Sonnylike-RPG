# StatusEffectDatabase.gd
extends Node


var status_effects: Dictionary = {
	"poison": preload("res://scripts/statuses/poison_status.tres"),
	# Add more as going along...
}

func get_status_effect_by_id(id: String) -> StatusEffect:
	return status_effects.get(id, null)
