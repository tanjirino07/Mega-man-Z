extends Node2D

# Chamado quando o nó entra na árvore de cena pela primeira vez
func _ready():
	$zero/AnimationPlayer.play("7")

func _process(delta):
	pass

