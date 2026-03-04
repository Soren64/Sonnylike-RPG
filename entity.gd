# entity.gd
#extends Node
extends Node2D
class_name Entity

signal stat_changed(stat_name: String, current_value: int, max_value: int) # Signal for UI

@export var entity_name: String
@export var stats: Dictionary = {
	"max_hp": 100,
	"hp": 100,
	"attack": 10,
	"speed": 10, # Speed determines attack order
	"max_mp": 100,
	"mp": 100,
	"mp_regen": 5
}
var team: String = ""
var active_statuses: Dictionary = {} # Current applied buffs/debuffs | key: unique_id, value: StatusEffect
@export var skills: Array # Active skill set
var visual: EntityVisual = null
var indicator: Node = null # Skill target indicator
@onready var target_indicator = $EntityVisual/TargetIndicator
var sprite_scene_path: String = ""
var is_dead: bool = false
# signals for UI hp/mana bars
signal hp_changed(current_hp, max_hp) 
signal mp_changed(current_mp, max_mp)


# Click event
func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		get_tree().call_group("CombatManager", "on_entity_clicked", self)

# === Skill Targeting ===

func set_targetable(is_targeted: bool) -> void:
	target_indicator.visible = is_targeted


# === Team & Stats ===

func get_team() -> String:
	return team

func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)

func set_stat(stat_name: String, value: int) -> void:
	#stats[stat_name] = value
	#_emit_stat_update(stat_name)
	stats[stat_name] = value
	if stat_name == "hp":
		stats["hp"] = max(stats["hp"], 0)   # prevent negative HP
		is_dead = stats["hp"] <= 0
	else:
			is_dead = false
	_emit_stat_update(stat_name)

func modify_stat(stat_name: String, amount: int) -> void:
	#stats[stat_name] = get_stat(stat_name) + amount
	#_emit_stat_update(stat_name)
	set_stat(stat_name, get_stat(stat_name) + amount)

func _emit_stat_update(stat_name: String) -> void:
	# Only emit for stats that have a max value
	if stat_name in ["hp", "mp"]:
		var max_name = "max_%s" % stat_name
		var max_val = stats.get(max_name, 0)
		emit_signal("stat_changed", stat_name, stats[stat_name], max_val)

# === Player/AI Control === 

func is_player_controlled() -> bool:
	return false  # Override

func choose_action(allies: Array, enemies: Array) -> Skill:
	return null  # Override


# === Set Up ===

func set_up(name: String, team_name: String, pos: Vector2, stats_dict: Dictionary, skill_names: Array = [], visual_scene_path: String = ""):
	entity_name = name
	team = team_name
	#stats = stats_dict
	position = pos
	self.sprite_scene_path = visual_scene_path
	
	# Merge loaded stats into defaults
	for key in stats_dict.keys():
		stats[key] = stats_dict[key]
	
	skills.clear()
	for skill_name in skill_names:
		var skill_path = "res://scripts/skills/%s.tres" % skill_name
		if ResourceLoader.exists(skill_path):
			var skill_res = load(skill_path)
			skills.append(skill_res)
		else:
			print("Warning: Skill resource not found:", skill_path)

	print("Entity setup:")
	print("  Name:", entity_name)
	print("  Team:", team)
	print("  Position:", pos)
	print("  Stats:", stats)
	for s in skills:
		skill_names.append(s.name)
		print("  Loaded skills:", skill_names)

	update_visuals()

func update_visuals():
	# Override in subclasses to change visuals based on stats or name
	pass


# === Statuses === 

func apply_status(status: StatusEffect) -> void:
	if active_statuses.has(status.unique_id):
		# Overwrite or refresh duration
		active_statuses[status.unique_id].remove_effect(self)
		active_statuses.erase(status.unique_id)

	status.apply_effect(self)
	active_statuses[status.unique_id] = status


func remove_expired_statuses() -> void:
	var to_remove = []
	for id in active_statuses:
		var effect = active_statuses[id]
		if effect.duration <= 0: # Status is expired when duration is 0 or less
			effect.remove_effect(self)
			to_remove.append(id)

	for id in to_remove:
		var effect = active_statuses.get(id)
		print("%s removed from %s." % [effect.effect_name, entity_name])
		active_statuses.erase(id)


func remove_status_by_id(status_id: String) -> void:
	if active_statuses.has(status_id):
		active_statuses[status_id].remove_effect(self)
		active_statuses.erase(status_id)

# Remove all statuses based on the type. Buff -> strip, Non-buff -> cleanse
func remove_statuses_by_type(is_buff: bool) -> void:
	var to_remove = []
	for id in active_statuses:
		if active_statuses[id].is_buff == is_buff: # Remove statuses matching type (buff or non-buff) 
			active_statuses[id].remove_effect(self)
			to_remove.append(id)
	for id in to_remove:
		active_statuses.erase(id)

# Remove all statuses regardless of type
func remove_all_statuses() -> void:
	for effect in active_statuses.values():
		effect.remove_effect(self)
	active_statuses.clear()


func on_turn_start() -> void:
	for effect in active_statuses.values():
		if effect.trigger_timing in ["start", "both"]:
			effect.on_turn_start(self)
	remove_expired_statuses()


func on_turn_end() -> void:
	for effect in active_statuses.values():
		if effect.trigger_timing in ["end", "both"]:
			effect.on_turn_end(self)
	remove_expired_statuses()

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
