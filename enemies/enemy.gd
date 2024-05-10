class_name Enemy
extends Node2D

@export var health: int = 10
@export var death_prefab: PackedScene
@export_category("Drop Table")
@export var drop_item_prefab: PackedScene
@export var drop_chance: float = 0.0
var damage_digit_prefab: PackedScene
@onready var damage_marker = $DamageMarker

func _ready():
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")

func damage(amount: int):
	health -= amount	
	#piscar o inmigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_marker:
		damage_digit.global_position = damage_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	if health <= 0:
		die()
		
func die():
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		dropItem()
	GameManager.monsters_defeated_counter +=1
	queue_free()
	
func dropItem():
	if drop_item_prefab:
		if randf() <= drop_chance:
			var item_drop_object = drop_item_prefab.instantiate()
			item_drop_object.position = position
			get_parent().add_child(item_drop_object)
			print("dropou a carne")
	
	
	
		

