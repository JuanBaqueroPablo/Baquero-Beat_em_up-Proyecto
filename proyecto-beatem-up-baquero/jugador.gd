extends CharacterBody2D

# Variables ajustables desde el Inspector
@export var speed: float = 400.0
@export var friction: float = 0.2  # Valor entre 0 y 1 para un frenado suave

func _physics_process(_delta: float) -> void:
	# 1. Capturamos la dirección (W=arriba, S=abajo, A=izquierda, D=derecha)
	# Esto devuelve un Vector2 con valores entre -1 y 1
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Manejo del movimiento
	if direction != Vector2.ZERO:
		# Si hay entrada, aplicamos velocidad
		velocity = direction * speed
		
		# Opcional: Voltear el sprite según la dirección (si tienes un Sprite2D como hijo)
		if direction.x != 0:
			$Sprite2D.flip_h = direction.x < 0
	else:
		# Si no hay entrada, frenamos gradualmente hasta llegar a 0
		velocity = velocity.move_toward(Vector2.ZERO, speed * friction)

	# 3. Función clave: aplica la velocidad y maneja colisiones con paredes
	move_and_slide()
