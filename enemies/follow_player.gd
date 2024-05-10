extends Node
@export var speed = 1.0

var sprite : AnimatedSprite2D 
var enemy : Enemy

func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")

func _physics_process(delta):
	if GameManager.is_game_over: return
	
	var player_position = GameManager.player_position
	var diference = player_position - enemy.position
	var input_vector = diference.normalized()
	
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()	

	 #girar sprite
	if input_vector.x > 0:
		#desmarcar fliph do sprite2d
		sprite.flip_h = false		
	elif input_vector.x < 0:
		#marcar o flip do sprite2d	
		sprite.flip_h = true
