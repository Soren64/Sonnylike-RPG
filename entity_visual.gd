#extends Area2D
extends Node2D
class_name EntityVisual

@export var entity: Entity = null
@onready var sprite_holder = $SpriteHolder
@onready var target_indicator = $TargetIndicator
@onready var turn_ring = $TurnRing
@onready var area2d = $Area2D 

func _ready():
	add_to_group("combat")
	target_indicator.visible = false
	turn_ring.visible = false
	#$Area2D.input_pickable = true
	area2d.connect("input_event", Callable(self, "_on_area_input_event"))

	"""
	if entity and entity.sprite_scene_path != "":
		var sprite_scene = load(entity.sprite_scene_path)
		if sprite_scene:
			var sprite_instance = sprite_scene.instantiate()
			$SpriteHolder.add_child(sprite_instance)
	"""

func set_targetable(is_targetable: bool) -> void:
	target_indicator.visible = is_targetable

func set_turn_indicator(active: bool) -> void:
	print("TurnRing set visible: ", active, " for entity: ", entity.entity_name)
	turn_ring.visible = active

"""
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if entity:
			print("Clicked on", entity.name)
			get_tree().call_group("combat", "on_entity_clicked", entity)


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
"""
func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Clicked on entity:", entity.entity_name if entity else "No entity assigned")
		CombatManagerSingleton.on_entity_clicked(entity)

func show_floating_number(value: int, type: String):
	var scene = preload("res://entities/FloatingText.tscn")
	var instance = scene.instantiate()
	var container = $FloatingTextContainer
	var offset_y = -20 - (container.get_child_count() * 15)
	container.add_child(instance)
	instance.position = Vector2(0, offset_y)
	instance.setup(str(value), get_damage_color(type))
	
func get_damage_color(type: String) -> Color:
	match type:
		"healing": return Color(0, 1, 0)
		"mp": return Color(0.3, 0.7, 1)
		"fire": return Color(1, 0.4, 0)
		"poison": return Color(0.3, 0.8, 0.3)
		"shadow": return Color(0.6, 0, 0.6)
		_: return Color(1, 0, 0)
