extends RigidBody2D

var speed = 500
var direction = Vector2.RIGHT  # Esta direção será definida pelo script do personagem ao instanciar o projétil

func _ready():
	# Definir a direção do projétil de acordo com a variável global
	direction = Vector2(Global.dir, 0)

func _process(delta):
	position += direction * speed * delta

func _on_tiro_do_zero_body_entered(body):
		queue_free() # Replace with function body.


func _on_VisibilityEnabler2D_screen_exited():
	queue_free()

