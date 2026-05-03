extends CharacterBody2D

signal cuarto_vida
signal mitad_vida

@export var velocidad = 150
@export var distancia_ataque = 200
@export var distancia_perseguir = 400
@export var daño = 150
@export var gravedad = 600
var vida_maxima = 600
var vida_actual
var recibiendo_daño = false
var muriendo = false
var atacando = false
var invocando = false
var detectado = false
var limite_liberado_cuarto = false
var limite_liberado_mitad = false

@onready var animaciones = $AnimatedSprite2D
@onready var barra_vida = $TextureProgressBar2

#CORRECCION: Ves le agrego export y aparece a la derecha (en el nodo que tenga este script)
@export var jugador:Node2D = null

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
	
	#CORRECCION: Ojo con esta salida rápida. podrías haber seteado el jugador
	# con @export desde el editor -------->
	if jugador == null:
		jugador = get_tree().get_first_node_in_group("jugador")
		move_and_slide()
		return
	var distancia = global_position.distance_to(jugador.global_position)
	if distancia < distancia_perseguir:
		detectado = true
	#CORECCION: Lo mismo acá, poner muchos move_and_slide es indicio de que estás haciendo algo mal. Si hay más de uno ya perdés algo de control sobre el movimiento.
	if invocando:
		velocity.x = 0
		move_and_slide()
		return
	if distancia < distancia_ataque:
		if !atacando and !recibiendo_daño:
			atacar()
	elif detectado:
		perseguir()
	else:
		velocity.x = 0
		animaciones.play("Quieto")
	move_and_slide()

func perseguir():
	if atacando or recibiendo_daño or muriendo or invocando:
		velocity.x = 0
		return
	var direccion = (jugador.global_position - global_position).normalized()
	velocity.x = direccion.x * velocidad
	animaciones.play("Caminando")
	animaciones.flip_h = jugador.global_position.x > global_position.x

func atacar():
	atacando = true
	velocity.x = 0
	animaciones.play("Ataque")
	animaciones.flip_h = jugador.global_position.x > global_position.x

func recibir_daño(cantidad):
	if muriendo or invocando:
		return
	vida_actual -= cantidad
	barra_vida.value = vida_actual
	if vida_actual <= 0:
		muriendo = true
		atacando = false
		recibiendo_daño = false
		jugador._sumar_puntos(100)
		animaciones.play("Muerto")
		return
	if !limite_liberado_cuarto and vida_actual <= vida_maxima * 0.75:
		limite_liberado_cuarto = true
		invocando = true
		atacando = false
		recibiendo_daño = false
		#CORRECCION: Bien la señal, pero por qué no cuarto_vida.emit()?? F1->Signal y te muestra esa manera, sin salir de Godot!
		emit_signal("cuarto_vida")
		animaciones.play("Invocar")
		return
	if !limite_liberado_mitad and vida_actual <= vida_maxima / 2:
		limite_liberado_mitad = true
		invocando = true
		atacando = false
		recibiendo_daño = false
		emit_signal("mitad_vida")
		animaciones.play("Invocar")
		return
	atacando = false
	recibiendo_daño = true
	animaciones.play("Daniado")

func _on_animacion_terminada():
	if muriendo:
		queue_free()
	elif invocando:
		invocando = false
		animaciones.play("Quieto")
	elif recibiendo_daño:
		recibiendo_daño = false
		animaciones.play("Quieto")
	elif atacando:
		atacando = false
		if jugador and global_position.distance_to(jugador.global_position) < distancia_ataque:
			jugador._recibir_daño(daño)
