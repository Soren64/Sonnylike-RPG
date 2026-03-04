# heal.gd
extends Skill
class_name HealSkill

func _init():
	name = "Heal"
	power = 50
	cost = 25
	cost_type = "mp"
	skill_type = "heal"
	target_scope = "single"
	target_type = "ally_incl_self"

func apply_effect(user, target):
	var current_hp = target.stats.get("hp", 0)
	var max_hp = target.stats.get("max_hp", 100)
	var new_hp = min(max_hp, current_hp + power)
	target.set_stat("hp", new_hp)
	#target.stats["hp"] = new_hp
	print("%s heals %s for %d HP" % [user.entity_name, target.entity_name, new_hp - current_hp])
