class_name Player

extends CharacterBody2D
@onready var sprite :Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var speed = 2
@export var sword_damage: int = 2
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $ProgressBar

@export var health : int = 100
@export var max_health : int = 100

@export var death_prefab: PackedScene

var is_running: bool = false
var was_running: bool = false
var is_attacking :bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var input_vector : Vector2 = Vector2(0,0)

func _process(delta):
	GameManager.player_position = position # atualiza a posição do player na variavel do game manager
	
	read_input()
	update_attack_cooldown(delta)
	#attack
	if Input.is_action_just_pressed("attack"):
		attack()
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
		
	#processar dano
	update_hitbox_detection(delta)
	
	#atualizar o health progress bar
	health_progress_bar.value = health
	health_progress_bar.max_value = max_health
	
		
func _physics_process(delta):
	#Modificar a velocidade
	var target_velocity = input_vector * speed * 100
	if is_attacking:
		target_velocity *= 0.25
	velocity = lerp(velocity, target_velocity, 0.7)
	move_and_slide()
		
		
func read_input():
	#Obter o input vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.5)
	#apagar deadzone
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
		
	#atualizar o is_running
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func play_run_idle_animation():
	#tocar a animação
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite():
	#girar sprite
	if input_vector.x > 0:
		#desmarcar fliph do sprite2d
		sprite.flip_h = false		
	elif input_vector.x < 0:
		#marcar o flip do sprite2d	
		sprite.flip_h = true

func update_attack_cooldown(delta: float):
	#atualizar temporizador do ataque	
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func attack():
	if is_attacking:
		return
	if input_vector.y < 0:
		animation_player.play("attack_up_2")
	elif input_vector.y > 0:
		animation_player.play("attack_down_1")
	else:
		animation_player.play("attack_side_1")
	attack_cooldown = 0.6
	is_attacking = true
	 #aplicar dano
	
func deal_damage_to_enemies():
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product >0.4:
				enemy.damage(sword_damage)

func update_hitbox_detection(delta):
	#temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown >0 : return
	#frequencia 2x por degundo
	hitbox_cooldown = 0.5
	#hitboxarea
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)
	pass
		
func damage(amount: int):
	if health <=0: return
	
	health -= amount
	print("vida :", health,"/",max_health)
	
	#piscar o inmigo
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
	if health <= 0:
		die()
		
func die():
	GameManager.end_game()
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	queue_free()

func heal(amount: int):
	if health + amount >= max_health:
		health = 100	
	else:
		health += amount
	print("vida: ", health)
	return health
