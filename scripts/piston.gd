class_name Piston
extends Node3D

var running = false

func start():
	if not running:
		running = true
		$AnimationPlayer.play("pump")
	
func stop():
	if running:
		running = false
		var t = $AnimationPlayer.current_animation_position
		$AnimationPlayer.play_backwards("pump_noloop")
		$AnimationPlayer.seek(t, true)
