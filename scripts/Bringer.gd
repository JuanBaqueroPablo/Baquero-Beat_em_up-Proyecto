extends CharacterBody2D

@export var velocidad = 50
@export var distancia_ataque = 100
@export var daño = 80
@export var gravedad = 600
var vida_maxima = 400
var vida_actual
var recibiendo_daño = false
var muriendo = false
var atacando = false

@onready var animaciones = $AnimatedSprite2D
@onready var barra_vida = $TextureProgressBar

var jugador = null

func _ready():
	vida_actual = vida_maxima
	barra_vida.min_value = 0
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_maxima
	animaciones.animation_finished.connect(_on_animacion_terminada)

func _physics_process(delta):
	if muriendo:
		return
	if not is_on_floor():
		velocity.y += gravedad * delta
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("jugador")
		move_and_slide()
		return
	var distancia = global_position.distance_to(jugador.global_position)
	if distancia < distancia_ataque:
		if !atacando and !recibiendo_daño:
			_atacar()
	else:
		_perseguir()
	move_and_slide()

func _perseguir():
	if atacando or recibiendo_daño or muriendo or jugador == null:
		velocity.x = 0
		return
	var direccion = (jugador.global_position - global_position).normalized()
	velocity.x = direccion.x * velocidad
	animaciones.play("Camina-Bringer")
	animaciones.flip_h = jugador.global_position.x > global_position.x

func _atacar():
	atacando = true
	velocity.x = 0
	animaciones.play("Ataque-Bringer")
	animaciones.flip_h = jugador.global_position.x > global_position.x

func recibir_daño(cantidad):
	if muriendo:
		return
	vida_actual -= cantidad
	barra_vida.value = vida_actual
	if vida_actual <= 0:
		muriendo = true
		atacando = false
		recibiendo_daño = false
		jugador._sumar_puntos(1)
		animaciones.play("Muerte-Bringer")
		return
	atacando = false
	recibiendo_daño = true
	animaciones.play("Daniado-Bringer")

func _on_animacion_terminada():
	if muriendo:
		queue_free()
	elif recibiendo_daño:
		recibiendo_daño = false
		animaciones.play("Quieto-Bringer")
	elif atacando:
		atacando = false
		if jugador and global_position.distance_to(jugador.global_position) < distancia_ataque:
			jugador._recibir_daño(daño)
