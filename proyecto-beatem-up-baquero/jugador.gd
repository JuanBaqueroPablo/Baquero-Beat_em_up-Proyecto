extends CharacterBody2D

@export var velocidad := 200.0

@onready var animaciones = $AnimatedSprite2D

func _physics_process(delta):
	var direccion := 0
	
	if Input.is_action_pressed("ui_right"):
		direccion += 1
	if Input.is_action_pressed("ui_left"):
		direccion -= 1
	
	velocity.x = direccion * velocidad
	velocity.y = 0
	
	if direccion != 0:
		animaciones.play("Correr")
		animaciones.flip_h = direccion < 0
	else:
		animaciones.play("Parado")
	
	move_and_slide()
