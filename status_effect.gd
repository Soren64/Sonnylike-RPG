extends Resource
class_name StatusEffect

@export var effect_name: String
@export var description: String
@export var duration: int # number of turns applied
@export var is_buff: bool
@export var stat_modifiers: Dictionary # e.g. {"attack": 10}
var original_values: Dictionary = {} # For reverting original values
@export var unique_id: String # For stacking or overriding same effect
@export var trigger_timing: String = "end"  # Determines when the effect activates on a turn; Options: "start", "end", "both"
@export var per_turn_effects: Dictionary = { # key: effect_name, value: stat amount
	"dot_damage": 0,
	"hot_heal": 0,
	"mp_regen": 0
}


func apply_effect(entity: Entity) -> void:
	original_values.clear()
	for stat in stat_modifiers:
		original_values[stat] = entity.get_stat(stat)
		entity.modify_stat(stat, stat_modifiers[stat])


func remove_effect(entity: Entity) -> void:
	for stat in original_values:
		var revert_amount = original_values[stat] - entity.get_stat(stat)
		entity.modify_stat(stat, revert_amount)
		print("%s removed from %s." % [effect_name, entity.name])


func on_turn_start(entity: Entity) -> void:
	print("%s has %d turns left on %s." % [entity.name, duration, effect_name]) 


func on_turn_end(entity: Entity) -> void:
	duration -= 1
	print("%s has %d turns left on %s." % [entity.name, duration, effect_name]) 
	for effect_type in per_turn_effects.keys():
		var value = per_turn_effects[effect_type]

		match effect_type:
			"dot_damage":
				_apply_dot(entity, value)
			"hot_heal":
				_apply_hot(entity, value)
			"mp_regen":
				_apply_mp_regen(entity, value)
			_: 
				print("Unknown per-turn effect: %s" % effect_type)


func _apply_dot(entity: Entity, damage: int) -> void:
	entity.stats["hp"] = max(0, entity.stats["hp"] - damage)
	print("%s takes %d damage from %s" % [
		entity.name,
		damage,
		effect_name
	])

func _apply_hot(entity: Entity, heal: int) -> void:
	var max_hp = entity.stats.get("max_hp", 100)
	entity.stats["hp"] = min(max_hp, entity.stats["hp"] + heal)
	print("%s heals %d HP from %s" % [entity.name, heal, effect_name])


func _apply_mp_regen(entity: Entity, amount: int) -> void:
	var max_mp = entity.stats.get("max_mp", 100)
	entity.stats["mp"] = min(max_mp, entity.stats["mp"] + amount)
	print("%s restores %d MP from %s" % [entity.name, amount, effect_name])
