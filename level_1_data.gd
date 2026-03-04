# levels/level_1_data.gd
extends Resource
#class_name LevelData

func get_level_data() -> Dictionary:
	return {
		"scene": "res://scenes/backgrounds/test_background.tscn",
		"entities": [
			{
				"name": "Hero",
				"scene": "res://entities/Placeholder.tscn",
				"team": "player",
				"stats": {
					"hp": 100,
					"atk": 12,
					"skills": ["Bash", "Heal_Pulse"]
				}
			},
			{
				"name": "Goblin",
				"scene": "res://entities/Placeholder.tscn",
				"team": "enemy",
				"stats": {
					"hp": 80,
					"max_hp": 80,
					"atk": 8,
					"skills": ["Bash"]
				}
			},
			{
				"name": "Hobgoblin",
				"scene": "res://entities/Placeholder.tscn",
				"team": "enemy",
				"stats": {
					"hp": 50,
					"max_hp": 50,
					"atk": 5,
					"skills": ["Bash"]
				}
			}
		]
	}
