extends RigidBody2D

var speed = 500
var direction = Vector2(1, 0)

func _ready():
	pass

func _process(delta):
	position += direction * speed * delta

func _on_Area2D_body_entered(body):
	# Adicione lógica para quando o projétil atingir algo (por exemplo, diminuir a vida do Zero)
	if body.name == "Zero":
		body.take_damage(10)  # Exemplo de uma função que você pode ter no Zero para lidar com dano
	queue_free()

func _on_VisibilityEnabler2D_screen_exited():
	queue_free()
