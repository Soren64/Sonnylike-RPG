# stike.gd
extends Skill
class_name StrikeSkill

func _init():
	name = "Strike"
	power = 20
	cost_type = "none"
	skill_type = "physical"
	target_scope = "single"
	target_type = "enemy"

func apply_effect(user, target):
	var current_hp = target.stats.get("hp", 0)
	var new_hp = max(0, current_hp - power)
	#target.stats["hp"] = new_hp
	target.set_stat("hp", new_hp)
	print("%s takes %d damage from %s" % [target.entity_name, power, name])
