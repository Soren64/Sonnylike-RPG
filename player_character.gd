# player_character.gd
extends "res://scripts/entities/entity.gd"
class_name PlayerCharacter

func _init():
	team = "player"

func is_player_controlled() -> bool:
	return true

func choose_action(allies: Array, enemies: Array) -> Skill:
	print("Waiting for player input...") 
	return null # Dummy value for now
