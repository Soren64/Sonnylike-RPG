# slots.gd
extends Node

# Max number of slots per team
const MAX_PLAYER_SLOTS = 3
const MAX_ENEMY_SLOTS = 3

# Example max 3 slots per team — adjust as needed
var player_slots = [
	{"pos": Vector2(150, 350), "occupant": null},
	{"pos": Vector2(250, 400), "occupant": null},
	{"pos": Vector2(350, 450), "occupant": null}
]

var enemy_slots = [
	{"pos": Vector2(700, 350), "occupant": null},
	{"pos": Vector2(800, 400), "occupant": null},
	{"pos": Vector2(900, 450), "occupant": null}
]

func get_first_free_slot(team: String) -> Dictionary:
	var slots = []
	if team == "player":
		slots = player_slots
	else:
		slots = enemy_slots
	
	for slot in slots:
		if slot["occupant"] == null:
			return slot
	return {}
