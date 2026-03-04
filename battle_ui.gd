# battle_ui.gd
extends CanvasLayer

signal skill_selected(skill)

#var EntityBarScene = preload("res://scenes/ui/EntityBar.tscn")
@export var entity_bar_scene: PackedScene = preload("res://scenes/ui/EntityBar.tscn")
@onready var player_bars_container = $PlayerBarsContainer
@onready var enemy_bars_container = $EnemyBarsContainer
@onready var skill_list = $SkillListPanel/SkillList

func show_skills(user, callback_func):
	clear_skill_list()
	
	for skill in user.skills:
		var btn = preload("res://scenes/ui/SkillButton.tscn").instantiate()
		btn.text = skill.name
		btn.skill = skill
		btn.user = user
		btn.callback_func = callback_func
		skill_list.add_child(btn)

func hide_skills():
	clear_skill_list()


func clear_skill_list():
	for child in skill_list.get_children():
		child.queue_free()

func bind_entities(entities: Array) -> void:
	# Clear previous bars if any
	for child in player_bars_container.get_children():
		child.queue_free()
	for child in enemy_bars_container.get_children():
		child.queue_free()
	
	for entity in entities:
		var bar = entity_bar_scene.instantiate()
	
		if entity.team == "player":
			player_bars_container.add_child(bar)
		elif entity.team == "enemy":
			enemy_bars_container.add_child(bar)
		else:
			# Optionally handle neutral or other teams here
			pass
		
		bar.set_entity(entity)
