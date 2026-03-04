# poison_status_effect.gd 
extends StatusEffect

func on_turn_end(entity: Entity) -> void:
	if per_turn_effects.has("dot_damage"):
		var damage = per_turn_effects["dot_damage"]
		entity.modify_stat("hp", -damage)
		print(effect_name + " deals " + str(damage) + " damage to " + entity.name)
