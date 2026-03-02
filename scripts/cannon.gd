extends Node3D

@export var missile: Node3D = null
@onready var base_pos = missile.position

@export var dest_missile: Node3D = null

@export var splosions: Array[Node3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.cannon = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal finished

func fire():
	$sound.play()
	_CameraShake3D._custom_shake(3 / (Game.screenshake / 10.0), Game.screenshake * 0.01)
	$GPUParticles3D.emitting = true
	
	missile.position = base_pos
	
	var dir := basis.get_rotation_quaternion() * Vector3.BACK
	var tween = create_tween()
	tween.tween_property($Cannon, "global_position", $Cannon.global_position + 3.0 * dir, 0.1).set_ease(Tween.EASE_OUT)
	tween.tween_property($Cannon, "global_position", $Cannon.global_position, 0.8).set_ease(Tween.EASE_OUT)

	missile.scale = Vector3.ZERO
	var mt = create_tween().tween_property(missile, "position", base_pos + 50 * Vector3.FORWARD, 1.3)
	var t = create_tween()
	t.tween_property(missile, "scale", Vector3.ONE, 0.3)
	t.tween_property(missile, "scale", Vector3.ZERO, 0.5)

	await mt.finished
	await get_tree().create_timer(1.5).timeout
	
	_CameraShake3D._custom_shake(1 / (Game.screenshake / 10.0), Game.screenshake * 0.1)
	var splosion = splosions.pick_random()
	splosion.material_override.albedo_color = Color.YELLOW
	splosion.scale = Vector3.ONE
	splosion.transparency = 0.0
	
	t = create_tween()
	t.tween_property(splosion.material_override, "albedo_color", Color.RED, 1.3).set_ease(Tween.EASE_OUT)
	t.tween_property(splosion.material_override, "albedo_color", Color.BLACK, 0.5).set_ease(Tween.EASE_OUT)
	
	create_tween().tween_property(splosion, "scale", 24 * Vector3.ONE, 1.6).set_ease(Tween.EASE_OUT)
	
	t = create_tween()
	t.tween_property(splosion, "transparency", 0.0, 1.4).set_ease(Tween.EASE_OUT)
	t.tween_property(splosion, "transparency", 1.0, 0.5).set_ease(Tween.EASE_OUT)

	await t.finished
	finished.emit()
