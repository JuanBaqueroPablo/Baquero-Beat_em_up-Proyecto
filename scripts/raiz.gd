extends Node

@onready var jugador = $Jugador
@onready var boss = $Boss
@onready var limite1 = $LimiteIzq/Limite1
@onready var limiteIzq = $LimiteIzq/LimiteIzq
@onready var limite0 = $LimiteIzq/Limite0
@onready var limite2 = $LimiteIzq/Limite2
@onready var limite3 = $LimiteIzq/Limite3
@onready var limite4 = $LimiteIzq/Limite4
@onready var limite5 = $LimiteIzq/Limite5
@onready var menu_pausa = $Jugador/Pausa

var transicionando = false

func _ready():
	jugador.puntos_cambiaron.connect(_on_puntos_cambiaron)
	boss.cuarto_vida.connect(_on_boss_cuarto_vida)
	boss.mitad_vida.connect(_on_boss_mitad_vida)
	menu_pausa.visible = false

func _on_puntos_cambiaron(puntos):
	if puntos >= 6:
		if is_instance_valid(limite1):
			limite1.queue_free()
		if is_instance_valid(limiteIzq):
			limiteIzq.queue_free()
		if is_instance_valid(limite0):
			limite0.queue_free()
	if puntos >= 14:
		if is_instance_valid(limite2):
			limite2.queue_free()
	if puntos >= 20:
		if is_instance_valid(limite3):
			limite3.queue_free()
	if puntos >= 126:
		get_tree().change_scene_to_file("res://Escenas/victoria.tscn")
func _on_boss_cuarto_vida():
	if is_instance_valid(limite4):
		limite4.queue_free()

func _on_boss_mitad_vida():
	if is_instance_valid(limite5):
		limite5.queue_free()

func _process(delta):
	if transicionando:
		return
	if jugador.muriendo:
		transicionando = true
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://derrota.tscn")
	if boss.muriendo:
		transicionando = true
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://victoria.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			menu_pausa.visible = false
		else:
			get_tree().paused = true
			menu_pausa.visible = true
