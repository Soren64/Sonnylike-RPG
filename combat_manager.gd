extends Node
class_name CombatManager

var player_team: Array[Entity]
var enemy_team: Array[Entity]
var turn_order: Array[Entity]
var current_turn_index: int = 0
var turn_number = 1
var is_battle_active: bool = true
#@onready var battle_ui = get_parent().get_node("BattleUI")
#@onready var battle_ui = preload("res://scenes/ui/BattleUI.tscn")
@onready var battle_ui = get_node("/root/TestBattle/BattleUI")
var queued_skill: Skill = null
var queued_user: Entity = null  # The entity who will cast the skill
#var attacker : Entity = null
var target : Entity = null
var entity_visual_scene = preload("res://entities/EntityVisual.tscn") # Spawn entity visual
var previous_entity_visual: EntityVisual = null # turn indicator ring

func _ready():
	add_to_group("combat")
	print("Starting battle.")
	print("LevelLoader: ", LevelLoader)
	print("DEBUG: LevelLoader =", LevelLoader)
	print("DEBUG: Type =", typeof(LevelLoader))
	#LevelLoader.connect("level_loaded", Callable(self, "_on_level_loaded"))
	#print("DEBUG: Connected to LevelLoader.level_loaded")
	#LevelLoader.load_level("res://levels/level_1_data.gd", self)
	# start_battle()


# === Slots ===

func get_first_free_slot(team: String) -> Dictionary:
	var slots
	if team == "player":
		slots = Slots.player_slots
	else:
		slots = Slots.enemy_slots
	
	for slot in slots:
		if slot["occupant"] == null:
			return slot
	return {} # No free slot


func place_entity_in_slot(entity, team: String) -> bool:
	var slot = get_first_free_slot(team)
	if slot.is_empty():
		print("No free slots for team:", team)
		return false
	entity.position = slot["pos"]
	slot["occupant"] = entity
	return true


func remove_entity_from_slot(entity):
	for slot in Slots.player_slots:
		if slot["occupant"] == entity:
			slot["occupant"] = null
			return
	for slot in Slots.enemy_slots:
		if slot["occupant"] == entity:
			slot["occupant"] = null
			return
	
func on_entity_defeated(entity):
	remove_entity_from_slot(entity)
	entity.queue_free()


# === Skills ===

func queue_skill(user: Entity, skill: Skill) -> void:
	clear_target_highlights()
	if not skill.can_use(user):
		print("Warning: Trying to queue a skill that can't be used!")
	
	print("Queued skill: ", skill.name)
	queued_user = user
	queued_skill = skill
	show_valid_targets()

	
#When player clicks on an entity to target for a skill
func on_entity_clicked(target_entity: Entity) -> void:
	#print("Turn order size from entry of on_entity_clicked: ", turn_order.size())
	# Do nothing if no queued skill
	if queued_skill == null or queued_user == null:
		print("No skill/user queued.")
		return

	# Only allow using a skill if it's the player turn
	for e in turn_order:
		print("Entity in turn order: ", e.entity_name)
	var current_entity = get_current_turn_entity()
	if current_entity != queued_user:
		print("Can only use skill when it is player turn: ", current_entity.entity_name)
		return

	# Check if the skill is usable
	if not queued_skill.can_use(queued_user):
		print("Not enough resources or conditions to use this skill.")
		return

	# Check if target is valid
	if not queued_skill.is_valid_target(queued_user, target_entity):
		print("Invalid target.")
		return

	# Use the skill
	queued_skill.apply(queued_user, [target_entity])

	# Clear queued skill and user
	
	# Clear target indicator highlights
	clear_target_highlights()
	#clear_targeting()

	# End turn
	end_turn() 
	
"""
func clear_targeting():
	queued_skill = null
	queued_user = null
	for entity in get_all_entities():
		entity.set_targetable(false)
"""
func clear_targeting():
	queued_skill = null
	queued_user = null
	for entity in get_all_entities():
		if entity.visual:
			entity.visual.set_targetable(false)
#func show_valid_targets():
#	var all_entities = get_all_entities()
#	for entity in all_entities:
#		entity.set_targetable(queued_skill.is_valid_target(queued_user, entity))
func show_valid_targets():
	for node in get_tree().get_nodes_in_group("combat"):
		if node is EntityVisual and node.entity:
			var is_valid = queued_skill.is_valid_target(queued_user, node.entity)
			node.set_targetable(is_valid)
	
	
func clear_target_highlights():
	for node in get_tree().get_nodes_in_group("combat"):
		if node is EntityVisual:
			node.set_targetable(false)
	
func get_all_entities() -> Array:
	return player_team + enemy_team
	
func on_player_skill_selected(user, skill):
	print("%s used %s" % [user.entity_name, skill.name])
	
	var possible_targets = []
	match skill.target_type:
		"enemy":
			possible_targets = enemy_team
		"ally", "ally_incl_self", "self":
			possible_targets = player_team
		"any":
			possible_targets = player_team + enemy_team
		_:
			possible_targets = []

	var raw_targets = []

	if skill.target_scope == "single":
		# Pick first valid target
		for target in possible_targets:
			if skill.is_valid_target(user, target):
				raw_targets.append(target)
				break
	elif skill.target_scope == "all":
		# All valid targets
		for target in possible_targets:
			if skill.is_valid_target(user, target):
				raw_targets.append(target)
	elif skill.target_scope == "multi":
		# Up to max_targets valid targets
		for target in possible_targets:
			if skill.is_valid_target(user, target):
				raw_targets.append(target)
				if raw_targets.size() >= skill.max_targets:
					break

	if raw_targets.is_empty():
		print("No valid targets for %s" % skill.name)
		return
	
	var hp_before = []
	for t in raw_targets:
		hp_before.append(t.stats["hp"])
	print("Targets before HP:", hp_before)
	skill.apply(user, raw_targets)
	var hp_after = []
	for t in raw_targets:
		hp_after.append(t.stats["hp"])
	print("Targets after HP:", hp_after)
	
	
	battle_ui.hide_skills()
	print("%s ends its turn." % [user.entity_name])
	end_turn()
	
	
# === Battle System ===

func get_current_turn_entity() -> Entity:
	print("Turn order size before get_current_turn_entity(): ", turn_order.size())
	print("Current turn index: ", current_turn_index)
	if turn_order.size() == 0:
		print("Turn order is empty! Cannot get current turn entity.")
		return
	if current_turn_index >= turn_order.size() or current_turn_index < 0:
		print("Current turn index out of bounds!")
		current_turn_index = 0
	return turn_order[current_turn_index]
	
"""
# Add EntityVisual to manage sprite and clickable target  
func spawn_entity_visual(entity: Entity) -> void:
	var visual_instance = entity_visual_scene.instantiate()
	add_child(visual_instance)  
	
	visual_instance.entity = entity  # assign the entity reference
	visual_instance.add_to_group("combat")
	
	# Load and instantiate the sprite scene inside EntityVisual
	if entity.sprite_scene_path != "":
		var sprite_scene = load(entity.sprite_scene_path)
		if sprite_scene:
			var sprite_instance = sprite_scene.instantiate()
			visual_instance.get_node("SpriteHolder").add_child(sprite_instance)
	   
	# Position the visual based on the entity's position or slot
	visual_instance.position = entity.position
"""

# Spawn EntityVisual and link it to the Entity
func spawn_entity_visual(entity: Entity) -> void:
	# Instantiate EntityVisual
	var visual_instance = entity_visual_scene.instantiate()
	add_child(visual_instance)
		
	# Assign entity reference
	visual_instance.entity = entity
	entity.visual = visual_instance  # link entity to visual
		
	# Add to combat group
	visual_instance.add_to_group("combat")
	
	# Load and instantiate sprite scene inside EntityVisual
	if entity.sprite_scene_path != "":
		var sprite_scene = load(entity.sprite_scene_path)
		if sprite_scene:
			var sprite_instance = sprite_scene.instantiate()
			visual_instance.sprite_holder.add_child(sprite_instance)
		
	# Position the visual
	visual_instance.position = entity.position
	
	# Ensure indicators start hidden (modular style)
	visual_instance.set_targetable(false)
	visual_instance.set_turn_indicator(false)


func start_battle():
	print("CombatManager instance ID from start_battle: ", get_instance_id())
	#player_team.clear()
	#enemy_team.clear()
		# TEMP - create entities manually
	"""
	var player = PlayerCharacter.new()
	player.name = "Hero"
	player.entity_name = player.name
	player.stats["speed"] = 10
	player.skills = []  # add test skills here
	player.skills.append(preload("res://scripts/skills/bash.tres"))
	player.skills.append(preload("res://scripts/skills/heal_pulse.tres"))
	player.skills.append(preload("res://scripts/skills/venom_slash.tres"))

	var enemy = EnemyCharacter.new()
	enemy.name = "Goblin"
	enemy.entity_name = enemy.name
	enemy.stats["speed"] = 5
	enemy.skills = []
	enemy.skills.append(preload("res://scripts/skills/bash.tres"))  # add test skills here
	
	player_team.append(player)
	enemy_team.append(enemy)

	turn_order = (player_team + enemy_team).duplicate()
	turn_order.sort_custom(func(a, b): return a.get_stat("speed") > b.get_stat("speed"))
	"""
	
	"""
	# Load the level and add entities
	var level_data = LevelLoader.load_level("res://levels/level_1_data.gd", self)
	print("Level load complete: ", level_data != null)
	if not level_data:
		push_error("Failed to load level data.")
		return
	
	print("Level fully loaded.")
	"""
	
	var entities = LevelLoader.load_level("res://levels/level_1_data.gd", self)
	print("Loaded entities count: ", entities.size())
	
	for entity in entities:
		spawn_entity_visual(entity)
		if entity.team == "player":
			player_team.append(entity)
		elif entity.team == "enemy":
			enemy_team.append(entity)
	
	# Bind the entities to the UI, for displaying bars and info
	battle_ui.bind_entities(entities)
	
	# Spawn visuals + fill teams
	#for entity in level_data.entities: # You need your level loader to return entity instances
	#	spawn_entity_visual(entity)
	"""
	# Scan for entities immediately after loading
	print("All children in CombatManager:")
	#for child in get_children():
	for child in get_tree().get_nodes_in_group("combat"):
		print("  ", child.name, " - ", child, " - ", child.get_class())
		

		if child is Entity:
			var team = child.get_team()
			print("Found Entity: ", child.entity_name, " | Team: ", team)
			
			if team == "player":
				player_team.append(child)
			elif team == "enemy":
				enemy_team.append(child)
		if child is EntityVisual and child.entity:
			var team = child.entity.get_team()
			print("Found Entity: ", child.entity.entity_name, " | Team: ", team)

			if team == "player":
				player_team.append(child.entity)
			elif team == "enemy":
				enemy_team.append(child.entity)
	
		# Spawn visuals for all entities
	for entity in player_team + enemy_team:
		spawn_entity_visual(entity)
	
	print("Player team: ", player_team)
	print("Enemy team: ", enemy_team)
	"""
	print("Player team: ", player_team)
	print("Enemy team: ", enemy_team)
	print("Player team size: ", player_team.size())
	print("Enemy team size: ", enemy_team.size())
	
	# Set up turn order
	turn_order = (player_team + enemy_team).duplicate()
	turn_order.sort_custom(func(a, b): return a.get_stat("speed") > b.get_stat("speed"))
	
	print("Turn order size: ", turn_order.size())
	for e in turn_order:
		print("Entity in turn order: ", e.entity_name)
	
	queued_user = get_current_turn_entity()
	
	print("Battle Start!")
	start_turn()

func debug_battle_state():
	print("\n=== Battle State ===")
	print("Turn order: ", turn_order.map(func(e): return e.entity_name))
	print("Player Team: ", player_team.map(func(e): return "%s (%d HP)" % [e.entity_name, e.get_stat("hp")]))
	print("Enemy Team: ", enemy_team.map(func(e): return "%s (%d HP)" % [e.entity_name, e.get_stat("hp")]))
	print("====================\n")


func start_turn():
	debug_battle_state()
	if !is_battle_active:
		return 
	
	if turn_order.is_empty():
		print("No one left to fight.")
		return
	
	print("\n--- Turn %d ---" % turn_number)
	turn_number += 1
	
	var entity = turn_order[current_turn_index]
	print("Turn: " + entity.entity_name)
	
	# --- Turn indicator ---
	# Turn off previous visual's ring
	if previous_entity_visual:
		previous_entity_visual.set_turn_indicator(false)
		
	# Turn on current visual's ring
	entity.visual.set_turn_indicator(true)
	previous_entity_visual = entity.visual
	
	# Trigger start-of-turn effects
	entity.on_turn_start()
	
	if entity.is_player_controlled():
		print("Waiting for player to act...")
		# Skill/action choosen from UI
		queued_user = entity
		battle_ui.show_skills(entity, Callable(self, "on_player_skill_selected")) 
		
	else:
		# Enemy AI picks random skill and target
		var enemies = player_team if entity.team == "enemy" else enemy_team
		if enemies.is_empty():
			end_battle()
			return
			
		# Pick skill and target
		var skill = entity.skills.pick_random()
		var target = player_team.pick_random()
		
		# --- Pause / telegraph before acting ---
		var pause_time = 1.5  # Number of seconds
		await get_tree().create_timer(pause_time).timeout

		# Execute Skill
		print("%s uses %s on %s" % [entity.entity_name, skill.name, target.entity_name])
		print("Target HP before: ", target.stats["hp"])
		skill.apply(entity, [target])
		print("Target HP after: ", target.stats["hp"])
		print("%s ends its turn." % [entity.entity_name])
		end_turn()

"""
func end_turn():
	var entity = turn_order[current_turn_index]
	entity.on_turn_end()  # Trigger end-of-turn effects
	
	#Dequeue skill/user
	queued_skill = null
	queued_user = null
	
	current_turn_index = (current_turn_index + 1) % turn_order.size()
	remove_dead_entities()
	check_win_conditions()
	
	if is_battle_active:
		start_turn()
"""
"""
func end_turn():
	if !is_battle_active:
		return
	
	var entity = null
	if current_turn_index < turn_order.size():
		entity = turn_order[current_turn_index]
	
	if entity:
		entity.on_turn_end()  # Trigger end-of-turn effects
	
	# Regenerate MP
	var new_mp = min(entity.get_stat("mp") + entity.get_stat("mp_regen"), entity.get_stat("max_mp"))
	print("%s regains %s mp after their turn." % [entity.entity_name, new_mp - entity.get_stat("mp")])
	entity.set_stat("mp", new_mp)
	
	# Dequeue skill/user
	queued_skill = null
	queued_user = null

	# Remove dead entities *before* advancing the index
	remove_dead_entities()
	check_win_conditions()
	
	# Advance turn index safely
	if turn_order.is_empty():
		print("No entities left — battle over.")
		end_battle()
		return
	
	# If current entity died, the new remove_dead_entities() already corrected the index
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
	
	# Start the next turn
	start_turn()
"""
func end_turn():
	if !is_battle_active:
		return
	
	var entity = null
	if current_turn_index < turn_order.size():
		entity = turn_order[current_turn_index]
	
	if entity:
		# If entity died during its own turn, skip the rest
		if entity.is_dead:
			print("%s is dead, skipping end-of-turn effects." % entity.entity_name)
		else:
			entity.on_turn_end()  # Trigger end-of-turn effects
			
			# Regenerate MP (for living entities only)
			var current_mp = entity.get_stat("mp")
			var mp_regen = entity.get_stat("mp_regen")
			var new_mp = min(current_mp + mp_regen, entity.get_stat("max_mp"))
			
			if new_mp > current_mp:
				print("%s regains %d MP after their turn." % [entity.entity_name, new_mp - current_mp])
				entity.set_stat("mp", new_mp)
	
	# Dequeue skill/user regardless
	queued_skill = null
	queued_user = null

	# Remove dead entities *before* advancing the index
	remove_dead_entities()
	check_win_conditions()
	
	# If the battle ended (both teams empty), stop here
	if !is_battle_active or turn_order.is_empty():
		print("No entities left — battle over.")
		end_battle()
		return
	
	# Advance turn index safely
	current_turn_index += 1
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
	
	# Skip over any dead entities that somehow remain in turn_order
	while current_turn_index < turn_order.size() and turn_order[current_turn_index].is_dead:
		print("Skipping dead entity: %s" % turn_order[current_turn_index].entity_name)
		current_turn_index = (current_turn_index + 1) % turn_order.size()
	
	# Start the next turn
	start_turn()

func remove_dead_entities():
	#player_team = player_team.filter(func(e): return e.get_stat("hp") > 0)
	#enemy_team = enemy_team.filter(func(e): return e.get_stat("hp") > 0)
	#turn_order = (player_team + enemy_team).duplicate()
	#turn_order.sort_custom(func(a, b): return a.get_stat("speed") > b.get_stat("speed"))
	var current_entity = null
	if current_turn_index < turn_order.size():
		current_entity = turn_order[current_turn_index]

	# Remove dead entities from each team
	#player_team = player_team.filter(func(e): return e.get_stat("hp") > 0)
	#enemy_team = enemy_team.filter(func(e): return e.get_stat("hp") > 0)
	player_team = player_team.filter(func(e): return !e.is_dead)
	enemy_team = enemy_team.filter(func(e): return !e.is_dead)


	# Rebuild the full turn order
	turn_order = (player_team + enemy_team).duplicate()
	turn_order.sort_custom(func(a, b): return a.get_stat("speed") > b.get_stat("speed"))

	# Recalculate current_turn_index
	if current_entity == null:
		current_turn_index = 0
	else:
		var idx = turn_order.find(current_entity)
		if idx == -1:
			# The current entity died, so wrap to the next valid one
			current_turn_index = current_turn_index % max(turn_order.size(), 1)
		else:
			current_turn_index = idx

	# Optional: print debug info
	print("Rebuilt turn order:", turn_order.map(func(e): return e.entity_name))
	print("Current entity index after rebuild:", current_turn_index)



func check_win_conditions():
	if player_team.is_empty():
		print("Defeat")
		end_battle()
	elif enemy_team.is_empty():
		print("Victory")
		end_battle()


func end_battle():
	if previous_entity_visual: # Remove turn indicator ring
		previous_entity_visual.set_turn_indicator(false)
	is_battle_active = false
	#print("Remaining player(s): ", player_team)
	print("Battle has ended.")
	debug_battle_state()
	# WIP
