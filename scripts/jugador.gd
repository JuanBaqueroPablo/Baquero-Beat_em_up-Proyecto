extends CharacterBody2D

signal puntos_cambiaron(puntos)

@export var vida = 500
@export var velocidad := 300
@export var velocidad_salto = -400
@export var gravedad = 600

@onready var animaciones = $AnimatedSprite2D
@onready var ataque_area = $Ataque1
@onready var ataque_shape = $Ataque1/CollisionShape2D
@onready var barra_vida = $TextureProgressBar

var vida_actual
var muriendo = false
var recibiendo_daño = false
var atacando = false
var avanzar = true
var daño_actual = 0
var puntos = 0
var cooldown_ataque1 = 0.0
var cooldown_ataque2 = 0.0

func _ready():
	vida_actual = vida
	ataque_shape.disabled = true
	ataque_area.body_entered.connect(_on_ataque_body_entered)
	animaciones.animation_finished.connect(_on_animacion_terminada)
	barra_vida.min_value = 0
	barra_vida.max_value = vida
	barra_vida.value = vida

func _physics_process(delta):
	if muriendo:
		return
	var direccion = 0
	if not is_on_floor():
		velocity.y += gravedad * delta
	
	#CORRECCION: El cooldonw podría ser unificado, un solo timer que dura un tiempo de acuerdo al último ataque que se hizo. Si tuvieras 10 ataques tendrías 10 variables?? ojo acá [Desarrollo (-)]
	cooldown_ataque1 -= delta
	cooldown_ataque2 -= delta
	if !recibiendo_daño:
		if Input.is_action_just_pressed("Ataque1") && !atacando && cooldown_ataque1 <= 0:
			cooldown_ataque1 = .5
			#CORRECCION: No está del todo mal pero conviene tener este número en una variable
			_atacar("Ataque1", 1000)
		elif Input.is_action_just_pressed("ataque2") && !atacando && cooldown_ataque2 <= 0:
			cooldown_ataque2 = .5
			_atacar("Ataque2", 1000)
		if Input.is_action_pressed("mover_derecha"):
			direccion += 1
		if Input.is_action_pressed("mover_izquierda"):
			direccion -= 1
		if Input.is_action_just_pressed("saltar") && is_on_floor():
			if atacando:
				_cancelar_ataque()
			_saltar("Salto")
	if avanzar:
		velocity.x = direccion * velocidad
	else:
		velocity.x = 0
	if !atacando and !recibiendo_daño:
		if not is_on_floor():
			animaciones.play("Salto")
		elif direccion != 0:
			animaciones.play("Correr")
			animaciones.flip_h = direccion < 0
		else:
			animaciones.play("Parado")
	_actualizar_posicion_hitbox()
	move_and_slide()

func _saltar(animacion):
	animaciones.play(animacion)
	velocity.y = velocidad_salto

func _atacar(animacion, daño):
	recibiendo_daño = false
	atacando = true
	avanzar = false
	daño_actual = daño
	#CORRECCION: EL ataque debe lanzarse en un momento de la animación, no en el principio, hay que calcular en qué frame necesitamos que se ejecute el daño. [Diseño (-)]
	ataque_shape.disabled = false
	animaciones.play(animacion)

func _cancelar_ataque():
	ataque_shape.disabled = true
	atacando = false
	avanzar = true
	daño_actual = 0

func _on_animacion_terminada():
	if muriendo:
		get_tree().change_scene_to_file("res://Escenas/Inicio.tscn")
	elif recibiendo_daño:
		recibiendo_daño = false
		atacando = false
		ataque_shape.disabled = true
		avanzar = true
	elif atacando:
		ataque_shape.disabled = true
		atacando = false
		avanzar = true
		daño_actual = 0

func _actualizar_posicion_hitbox():
	if animaciones.flip_h:
		ataque_area.scale.x = -1
	else:
		ataque_area.scale.x = 1

func _on_ataque_body_entered(body):
	if body.is_in_group("enemigos"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño_actual)

func _recibir_daño(cantidad):
	#CORRECCION: Bien este tipo de "salidas rápidas" [Desarrollo (+)]
	if muriendo or recibiendo_daño:
		return
	vida_actual -= cantidad
	if atacando:
		_cancelar_ataque()
	barra_vida.value = vida_actual
	if vida_actual <= 0:
		muriendo = true
		ataque_shape.disabled = true
		velocity = Vector2.ZERO
		animaciones.play("Muerte")
	else:
		recibiendo_daño = true
		avanzar = false
		velocity.x = 0
		animaciones.play("Golpe")

func _sumar_puntos(cantidad):
	puntos += cantidad
	emit_signal("puntos_cambiaron", puntos)
