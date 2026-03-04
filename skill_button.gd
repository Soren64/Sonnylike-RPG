extends Button

var skill
var callback_func
var user

func _ready():
	pressed.connect(_on_pressed)

"""
func _on_pressed():
	print("Skill button pressed: ", skill.name)
	if callback_func:
		callback_func.call(user, skill)
"""
func _on_pressed():
	print("Skill button pressed: ", skill.name)
	if CombatManagerSingleton != null:
		CombatManagerSingleton.queue_skill(user, skill)
