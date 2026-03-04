"""
Skill.gd - Skill Resource Class

Target Types:
  - "enemy"          : Targets enemies only
  - "ally"           : Targets allies excluding self
  - "self"           : Targets self only
  - "ally_incl_self" : Targets allies including self

Target Scopes:
  - "single" : Targets a single entity from the group
  - "all"    : Targets all entities in the group

max_targets:
  - 0        : No limit (all valid targets)
  - >0       : Maximum number of targets affected (only valid with target_scope == "all")

Validation Rules:
  - If target_scope == "single", max_targets must be 0 or 1
  - If target_type == "self", target_scope must be "single" and max_targets <= 1
"""

extends Resource
class_name Skill

const TARGET_TYPES = ["enemy", "ally", "self", "ally_incl_self"]
const TARGET_SCOPES = ["single", "all", "multi"]
const SKILL_TYPES = ["physical", "magic", "fire", "ice", "heal", "buff", "debuff"]
const COST_TYPES = ["mp", "hp", "none"]


@export var name: String = "Skill"
@export var cost: int = 0
@export var cost_type: String = "mp"
@export var power: int = 0 # the scaler of the ability (i.e. how much damage/healing/other effect the skill does)
@export var description: String = ""
@export var target_type: String = "enemy" # "enemy", "self", "ally", "any"
@export var target_scope: String = "single" # how many/what type of entities it targets
@export var max_targets: int = 0 # 0 = no limit, otherwise cap the number of targets
@export var skill_type: String = "physical" # e.g. physical, magic, fire, ice, heal, e.g. 
@export var cooldown: int = 1
@export var status_applied: Array[String] = [] # Array of status effects applied


func can_use(user) -> bool:
	match cost_type:
		"mp":
			return user.stats.get("mp", 0) >= cost
		"hp":
			return user.stats.get("hp", 0) > cost  # Don't allow self-death
		"none":
			return true
		_:
			return true


func apply_cost(user):
	if cost_type == "mp":
		#user.stats["mp"] -= cost
		user.modify_stat("mp", -cost)
		user.emit_signal("mp_changed", user.stats["mp"], user.stats["max_mp"])
	elif cost_type == "hp":
		#user.stats["hp"] -= cost
		user.modify_stat("hp", -cost)
		user.emit_signal("hp_changed", user.stats["hp"], user.stats["max_hp"])


func is_valid_target(user, target) -> bool:
	if target == null:
		return false

	match target_type:
		"enemy":
			return user.team != target.team
		"ally":
			return user.team == target.team and user != target
		"self":
			return user == target
		"ally_incl_self":
			return user.team == target.team
		"any":
			return true
		_:
			return false


func resolve_targets(user, raw_targets: Array) -> Array:
	var valid_targets = []
	for t in raw_targets:
		if is_valid_target(user, t):
			valid_targets.append(t)
	# Apply scope logic to trimmed list
	if target_scope == "single":
		return [valid_targets[0]] if valid_targets.size() > 0 else []
	elif target_scope == "all":
		return valid_targets
	elif target_scope == "multi":
		return valid_targets.slice(0, min(max_targets, valid_targets.size()))
	return []


func apply(user, raw_targets: Array):
	if !can_use(user):
		print("%s cannot use %s (insufficient %s)" % [user.name, name, cost_type])
		return

	apply_cost(user)

	var targets = resolve_targets(user, raw_targets)
	if targets.is_empty():
		print("No valid targets for %s" % name)
		return

	for target in targets:
		apply_effect(user, target)

	apply_status_effects(user, targets)
	print("%s used %s on %s" % [user.entity_name, name, targets.map(func(t): return t.entity_name)])


func apply_effect(user, target):
	# Override in child skill classes
	print("No effect implemented for %s" % name)


func apply_status_effects(user, targets):
	for unique_id in status_applied:
		var effect = StatusEffectDB.get_status_effect_by_id(unique_id)
		if effect != null:
			for target in targets:
				target.apply_status(effect)
		else:
			print("Warning: No status effect found for ID '%s'" % unique_id)
