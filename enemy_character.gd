# enemy_character.gd
extends "res://scripts/entities/entity.gd"
class_name EnemyCharacter

func _init():
	team = "enemy"

func is_player_controlled() -> bool:
	return false

func choose_action(allies: Array, enemies: Array) -> Skill:
	return skills.pick_random() # Use random skill
