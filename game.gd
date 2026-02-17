extends Node

var current_task : int = -1

var just_launched := false

@onready var story := Story.new()
@onready var tasks := Tasks.new()

var hud: HUD = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func register_hud(hud):
	self.hud = hud

class StartState:
	var outer = null
	
	func init(outer):
		self.outer = outer
		return self
		
	func enter():
		var task_opts = outer.tasks.first_tasks() 
		outer.current_task = task_opts.pick_random()
		
		outer.hud.display_messages(outer.story.intro_text())
		
	func update():
		if outer.hud.is_finished():
			pass
			
	func on_launch(good):
		if good:
			var msg: Array[String] = ["Commander Ballari: Beautiful strike, the target was destroyed!"]
			outer.hud.display_messages(msg)
		else:
			var msg: Array[String] = ["What in hell are you doing!? Follow the launch orders this time. Insubordinaton will necessitate... termination."]
			outer.hud.display_messages(msg)
		
var current_state = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if current_state == null:
		current_state = StartState.new().init(self)
		current_state.enter()
		
	current_state.update()
	
	if just_launched and DoodadState.missile_load_type != 0:
		just_launched = false
		
		current_state.on_launch(tasks.was_correct(current_task))
		DoodadState.missile_load_type = 0
	
