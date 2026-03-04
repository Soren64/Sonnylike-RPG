# generic_status_skill.gd
extends Skill
class_name GenericStatusSkill

func apply_effect(user, target):
	if power > 0:
		var dmg = power
		target.stats["hp"] -= dmg
		print("%s deals %d damage to %s" % [user.name, dmg, target.name])

	for effect_id in status_applied:
		var effect = StatusEffectDB.get_status_effect_by_id(effect_id)
		if effect:
			target.apply_status(effect.duplicate())
			print("%s applies status effect: %s to %s" % [user.name, effect_id, target.name])
		else:
			print("WARNING: Status effect ID '%s' not found in StatusEffectDB!" % effect_id)
