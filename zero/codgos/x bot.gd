extends KinematicBody2D

# Variáveis de movimento
var speed = 100
var gravity = 500
var direction = Vector2(-1, 0)  # Começa indo para a direita
var velocity = Vector2.ZERO

var dir = -1

# Referências às áreas e ao Zero
onready var direita_area = $direita
onready var esquerda_area = $esquerda
onready var animated_sprite = $AnimatedSprite2D  # Referência ao AnimatedSprite2D para virar o sprite
onready var zero = get_node("res://zero.tscn")  # Ajuste o caminho para a instância do Zero

# Referência ao projeto de tiro
onready var projectile_scene = preload("res://cenas/tiro normal.tscn")  # Substitua pelo caminho da cena do projétil

func _ready():
	# Conectar sinais de entrada e saída das áreas
	direita_area.connect("body_entered", self, "_on_direita_body_entered")
	esquerda_area.connect("body_entered", self, "_on_esquerda_body_entered")

func _physics_process(delta):
	# Aplicar gravidade
	velocity.y += gravity * delta

	# Mover o inimigo na direção atual
	velocity.x = direction.x * speed
	move_and_slide(velocity, Vector2.UP)

	# Virar o sprite conforme a direção
	if direction.x > 0:
		$AnimatedSprite.flip_h = false
	elif direction.x < 0:
		$AnimatedSprite.flip_h = true

	# Tocar a animação de andar
	if velocity.x != 0:
		$AnimatedSprite.play("andando")
	else:
		$AnimatedSprite.play("parado")

# Função chamada quando o Zero entra na área direita
func _on_direita_body_entered(body):
	velocity = -100
	attack()

# Função chamada quando o Zero entra na área esquerda
func _on_esquerda_body_entered(body):
	velocity = 100
	attack()

# Função para atirar no Zero
func attack():
	$AnimatedSprite.play("atirando")
	var projectile = projectile_scene.instance()
	projectile.position = position + Vector2(direction.x * 10, 0)  # Ajuste a posição de spawn do projétil
	projectile.direction = direction  # Define a direção do projétil
	get_parent().add_child(projectile)
