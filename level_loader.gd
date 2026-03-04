# level_loader.gd
extends Node

func load_level(level_resource_path: String, parent_node: Node):
	print("Loading level from: ", level_resource_path)
	var level_script = load(level_resource_path)
	var level_resource = level_script.new()  # Create an instance to access methods
	#var level_resource = ResourceLoader.load(level_resource_path)
	#var level_resource = load(level_resource_path)
	if not level_resource:
		push_error("Failed to load level resource: " + level_resource_path)
		return null
	
	var level_data = {}
	if level_resource.has_method("get_level_data"):
		level_data = level_resource.get_level_data()
	else:
		print("Level resource missing 'get_level_data' method")
		return null
	
	print("Level data loaded:", level_data)
	
	# === Load background ===
	if level_data.has("scene"):
		var bg_scene = load(level_data["scene"])
		if bg_scene:
			var bg_instance = bg_scene.instantiate()
			parent_node.add_child(bg_instance)
		else:
			print("Warning: could not load background scene:", level_data["scene"])
	
	var entity_instances = []
	# === Load entities ===
	for entity_data in level_data.get("entities", []):
		var entity_scene = load(entity_data.get("scene", ""))
		if entity_scene == null:
			print("Failed to load scene for entity:", entity_data.get("name", "Unknown"))
			continue
		
		var entity_instance = entity_scene.instantiate()
		
		# Attach behavior script based on team
		var behavior_script
		match entity_data.get("team", ""):
			"player":
				behavior_script = preload("res://scripts/entities/player_character.gd")
			"enemy":
				behavior_script = preload("res://scripts/entities/enemy_character.gd")
			_:
				behavior_script = preload("res://scripts/entities/entity.gd")
			
		entity_instance.set_script(behavior_script)
		
		# Prepare skills
		var skill_names = []
		if entity_data.has("stats") and entity_data.stats.has("skills"):
			skill_names = entity_data.stats["skills"]
			
		print("Instance type: ", entity_instance.get_class()) 
		
			# Find a free slot for this team
		var slot = Slots.get_first_free_slot(entity_data.get("team", ""))
		if slot.is_empty():
			print("No free slot available for", entity_data.get("name", "Unknown"))
			continue  # Skip if no space
		
		# Assign position from slot
		entity_instance.position = slot["pos"]
		slot["occupant"] = entity_instance
		
		entity_instance.set_up(
			entity_data.get("name", "Unknown"),
			entity_data.get("team", ""),
			#entity_data.get("position", Vector2.ZERO),
			entity_instance.position,
			entity_data.get("stats", {}),
			skill_names,
			entity_data.get("scene", "")
		)
		
		parent_node.add_child(entity_instance)
		entity_instances.append(entity_instance)
		print("Loaded entity: ", entity_instance.entity_name, " | team: ", entity_instance.team)
	
	print("Level Successfully loaded.")
	#return level_data
	return entity_instances
