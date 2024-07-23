extends KinematicBody2D

# Variáveis de movimento
var carregar = 0

var wall_slide = false
var velocity = Vector2.ZERO
var gravity = 1000
var speed = 200
var jump_strength = -400
var dash_speed = 600
var dash_jump_strength = -200  # Força do pulo durante o dash
var can_double_jump = false
var is_dashing = false
var has_dashed = false  # Flag para controlar se o personagem já realizou um dash após tocar no chão
var is_attacking = false  # Flag para controlar se o personagem está atacando
var is_sabre_attacking = false  # Flag para controlar se o personagem está atacando com o sabre
var is_wall_sliding = false  # Flag para controlar se o personagem está deslizando na parede
var wall_slide_speed = 50  # Ajuste este valor conforme necessário

# Tempo de dash
var dash_time = 0.3
var dash_timer = 0

# Tempo de ataque
var attack_duration = 0.2
var attack_timer = 0

# Tempo de ataque com sabre
var sabre_attack_duration = 0.4
var sabre_attack_timer = 0

# Controle de duplo clique
var double_click_timer = 0.2
var click_count = 1
var double_click_threshold = 0.3
var time_since_last_click = 0
var animation_duration = 3

# Referências a nós
onready var animated_sprite = $AnimatedSprite2D
onready var collision_shape = $CollisionShape2D
onready var dash_sound = $DashSound  # Substitua 'DashSound' pelo nome do seu nó de som de dash
onready var attack_sound = $AttackSound  # Substitua 'AttackSound' pelo nome do seu nó de som de ataque
onready var projectile_scene = preload("res://cenas/tiro do zero.tscn")  # Carrega a cena do projétil

# Variável para controlar a direção
var move_direction = 1  # 1 para direita, -1 para esquerda

# Constantes de estado
enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING, ATTACKING, SABRE_ATTACKING }
var current_state = State.IDLE

func _physics_process(delta):
	# Atualize a velocidade de queda durante o deslize na parede
	if is_wall_sliding:
		velocity.y = min(velocity.y, wall_slide_speed)

	Global.carga = carregar
	if Input.is_action_pressed("a"):
		carregar += 1
	else:
		carregar = 0
	$ProgressBar.value = carregar
	if carregar >= 100:
		carregar = 100
		if Input.is_action_just_released("a"):
			shoot()

	if move_direction == 1:
		Global.dir = 1
	if move_direction == -1:
		Global.dir = -1

	if $AnimatedSprite.get_animation() == "dash":
		if move_direction == 1:
			$AnimatedSprite/SpriteTrail.active = true
			$fogodir.visible = true
			$fogoesq.visible = false
		elif move_direction == -1:
			$AnimatedSprite/SpriteTrail.active = true
			$fogoesq.visible = true
			$fogodir.visible = false
	else:
		$fogoesq.visible = false
		$fogodir.visible = false
		$AnimatedSprite/SpriteTrail.active = false

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		else:
			if Input.is_action_pressed("z") and $AnimatedSprite.get_animation() != "parede":
				$jump.play()
				velocity.y = dash_jump_strength
				can_double_jump = false  # Bloqueia o pulo duplo após o dash
			else:
				velocity.y = 0  # Impede a gravidade durante o dash

			velocity.x = dash_speed * move_direction
			velocity = move_and_slide(velocity, Vector2.UP)
			if $AnimatedSprite:
				$AnimatedSprite.play("dash")
			return

	velocity.y += gravity * delta

	if is_on_floor():
		can_double_jump = true
		has_dashed = false  # Permitir dash infinito enquanto estiver no chão
		if $AnimatedSprite.get_animation() != "parede":
			if Input.is_action_just_pressed("z"):
				$jump.play()
				if is_dashing:
					velocity.y = dash_jump_strength
					can_double_jump = false  # Bloqueia o pulo duplo após o dash
				else:
					velocity.y = jump_strength
				current_state = State.JUMPING
	else:
		if Input.is_action_just_pressed("z") and can_double_jump and not has_dashed:
			$jump.play()
			if is_dashing:
				velocity.y = dash_jump_strength
				can_double_jump = false  # Bloqueia o pulo duplo após o dash
			else:
				velocity.y = jump_strength
			can_double_jump = false
			has_dashed = true  # Permitir apenas um dash enquanto estiver no ar

	if Input.is_action_just_pressed("x") and not is_dashing:
		if is_on_floor() or not has_dashed:
			is_dashing = true
			dash_timer = dash_time
			has_dashed = true  # Marcando que o dash foi usado
			$dash.play()  # Toca o som de dash
		return

	# Permitir movimento durante o ataque no ar
	if (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")) and (is_sabre_attacking and (current_state == State.JUMPING or current_state == State.FALLING)) and wall_slide == false:
		if Input.is_action_pressed("ui_right"):
			velocity.x = speed
			move_direction = 1
			if $AnimatedSprite:
				$AnimatedSprite.flip_h = false
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -speed
			move_direction = -1
			if $AnimatedSprite:
				$AnimatedSprite.flip_h = true
	else:
		if Input.is_action_pressed("ui_right") and not is_sabre_attacking:
			velocity.x = speed
			move_direction = 1
			if $AnimatedSprite:
				$AnimatedSprite.flip_h = false
		elif Input.is_action_pressed("ui_left") and not is_sabre_attacking:
			velocity.x = -speed
			move_direction = -1
			if $AnimatedSprite:
				$AnimatedSprite.flip_h = true
		else:
			velocity.x = 0

	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			current_state = State.IDLE

	if is_sabre_attacking:
		sabre_attack_timer -= delta
		if sabre_attack_timer <= 0:
			is_sabre_attacking = false
			current_state = State.IDLE

	velocity = move_and_slide(velocity, Vector2.UP)

	 # atualizar a animação
	update_animation()

	# Atualizar o tempo desde o último clique
	time_since_last_click += delta
	if time_since_last_click > double_click_threshold:
		click_count = 0  # Redefine o contador de cliques após o limite de tempo
		
	# Mecanica de escalar
	if not is_on_floor() and is_on_wall() and velocity.y > 0:
		start_wall_slide()
		can_double_jump = false
		if Input.is_action_pressed("ui_left"):
			move_direction = 1
			is_wall_sliding = true
			velocity.y += 30
			if Input.is_action_just_pressed("z"):
				$jump.play()
				velocity.y -= 500
				velocity.x -= 500
		elif Input.is_action_pressed("ui_right"):
			move_direction = -1
			is_wall_sliding = true
			velocity.y += 30
			if Input.is_action_just_pressed("z"):
				$jump.play()
				velocity.y -= 500
				velocity.x += 500
	else:
		stop_wall_slide()

	if is_wall_sliding:
		velocity.y = min(velocity.y, wall_slide_speed)

	# mecanica de animação "parede" de escalar
func start_wall_slide():
	is_wall_sliding = true
	$AnimatedSprite.play("parede")

func stop_wall_slide():
	is_wall_sliding = false

	 # animações
func update_animation():
	if not $AnimatedSprite:
		return

	if is_wall_sliding:
		$AnimatedSprite.play("parede")
	elif is_attacking:
		if not is_on_floor():
			if velocity.y < 0:
				$AnimatedSprite.play("atirando e pulando")
			else:
				$AnimatedSprite.play("atirando e caindo")
		elif velocity.x != 0:
			$AnimatedSprite.play("atirando e andando")
		else:
			$AnimatedSprite.play("atirando")
	elif is_sabre_attacking:
		if not is_on_floor():
			if velocity.y < 0:
				$AnimatedSprite.play("pulando zsabre")
			else:
				$AnimatedSprite.play("caindo zsabre")
		elif velocity.x != 0:
			$AnimatedSprite.play("andando zsabre")
		else:
			$AnimatedSprite.play("parado zsabre")
	elif is_dashing:
		$AnimatedSprite.play("dash")
	elif not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite.play("pulando")
		else:
			$AnimatedSprite.play("caindo")
	else:
		if velocity.x == 0:
			$AnimatedSprite.play("parado")
		else:
			$AnimatedSprite.play("andar")
		if is_on_wall() and velocity.y > 0:
			$AnimatedSprite.play("parede")

	# mecanicas de attack
func _input(event):
	# atirar 
	if event.is_action_pressed("a") and not is_attacking and not is_sabre_attacking:
		attack()

	# Zsabre
	if event.is_action_pressed("s") and not is_attacking and not is_sabre_attacking:
		if is_on_floor():
			ground_sabre_attack()
		else:
			air_sabre_attack()

	# função de atirar
func shoot():
	var projectile = projectile_scene.instance()
	projectile.position = position + Vector2(move_direction * 10, -5)  # Ajuste a posição de spawn do projétil
	projectile.direction = Vector2(move_direction, 0)  # Define a direção do projétil
	get_parent().add_child(projectile)

	# controla a animação de atirar
func attack():
	is_attacking = true
	attack_timer = attack_duration
	current_state = State.ATTACKING
	$AnimatedSprite.play("atirando")
	shoot()

	# para os movimentos do ZERO
func stop_movement():
	velocity = Vector2.ZERO  # Zera a velocidade para parar qualquer movimento
	move_and_slide(velocity, Vector2.UP)  # Aplica o movimento com a nova velocidade zerada

	# usar sabre no ar
func air_sabre_attack():
	if !is_on_floor() or velocity.y != 0:
		is_sabre_attacking = true
		sabre_attack_timer = sabre_attack_duration
		click_count += 1
		$AnimatedSprite.play("pulando zsabre")
		yield(get_tree().create_timer(animation_duration), "timeout")
		# Reseta click_count após o ataque
		click_count = 0

	# usar sabre no chão
func ground_sabre_attack():
	# Faz o ataque de sabre no chão
	is_sabre_attacking = true
	sabre_attack_timer = sabre_attack_duration
	click_count += 1
	stop_movement()  # Parar qualquer movimento

	if click_count == 1:
		$AnimatedSprite.play("parado zsabre 1")
	elif click_count == 2:
		$AnimatedSprite.play("parado zsabre 2")
		click_count = 0

	yield(get_tree().create_timer(animation_duration), "timeout")
	if click_count == 1:  # Se ainda for um único clique após o tempo de animação
		click_count = 0  # Reseta o contador de cliques
