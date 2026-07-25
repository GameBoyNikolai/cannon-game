extends Node3D

var flipping = false
var forward = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false

	$AnimationPlayer.animation_finished.connect(_on_turn)
	
	#$NextViewport/Pages.next_page()
	#$AnimationPlayer.play("flip")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.visible:
		if Input.is_action_just_pressed("Book"):
			self.visible = false
			InteractionManager.exit_interaction()
			return
			
		if not flipping:
			if Input.is_action_just_pressed("ui_right") and $CurrentViewport/Pages.can_next():
				flipping = true
				forward = true
				$AnimationPlayer.play("flip")
				$AnimationPlayer.advance(0)
				
				# wait until the pages are no longer fully overlapping
				await get_tree().process_frame
				await get_tree().process_frame
				await get_tree().process_frame
				$NextViewport/Pages.next_page()
				#$CurrentViewport/Pages.next_page()
			elif Input.is_action_just_pressed("ui_left") and $CurrentViewport/Pages.can_prev():
				flipping = true
				forward = false
				$AnimationPlayer.play_backwards("flip")
				#$NextViewport/Pages.previous_page()
				$CurrentViewport/Pages.previous_page()
	else:
		if Input.is_action_just_pressed("Book"):
			self.visible = true
			InteractionManager.start_modal_interaction(self)
		
func _on_turn(name):
	if name == "RESET":
		return
		
	if not self.visible:
		return
		
	flipping = false
	
	if forward:
		$CurrentViewport/Pages.next_page()
	else:
		$NextViewport/Pages.previous_page()

func start_interaction():
	pass
	
func stop_interaction():
	pass
