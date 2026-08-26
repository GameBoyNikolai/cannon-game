@tool
extends Node3D

@onready var top_base = $LargePiston2.position.y
@onready var bottom_base = $LargePiston.position.y

func set_separation(val: float):
	$LargePiston2.position.y = top_base + val
	#$LargePiston.position.y = bottom_base - val
	
	$LargePiston2/Energy.visible = val < 0.1
	
	if val < 0.1:
		self.emit()

func emit():
	$Sparks.emitting = true
	$Smoke.emitting = true
