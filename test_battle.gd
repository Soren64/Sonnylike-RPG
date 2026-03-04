extends Node2D

#var combat_manager_scene = preload("res://scenes/combat_manager.tscn")
#var combat_manager_instance = combat_manager_scene.instantiate()
func _ready():
	#add_child(combat_manager_instance)
	#combat_manager_instance.start_battle()
	CombatManagerSingleton.start_battle()
