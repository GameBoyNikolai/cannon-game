extends Node

var current_task : int = -1

var just_launched := false

@onready var story := Story.new()
@onready var tasks := Tasks.new()

var hud: HUD = null

class Email:
	var from: String
	var message: String
	var is_new: bool
	
	func init(f, msg):
		from = f
		message = msg
		is_new = true
		return self
		
var emails: Array[Email] = []

func update_task(new_task: int):
	current_task = new_task
	
	emails.insert(0, Email.new().init("Commander Ballari", tasks.get_recipe_description(current_task)))
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func register_hud(hud):
	self.hud = hud

class StartState:
	var outer = null
	
	var first_tasks
	var current = 0
	
	func init(outer):
		self.outer = outer
		return self
		
	func enter():
		first_tasks = outer.tasks.first_tasks() 
		outer.update_task(first_tasks[0])
		
		outer.hud.display_messages(outer.story.intro_text())
		
	func update():
		if outer.hud.is_finished():
			pass
			
	func on_launch(good):
		if good:			
			if current == len(first_tasks) - 1:
				outer.current_state = NormalFlow.new().init(outer)
				outer.current_state.enter()
			else:
				var msg: Array[String] = ["Commander Ballari:\nBeautiful strike, the target was destroyed!", "Commander Ballari:\nI've sent over more instructions, check your terminal."]
				outer.hud.display_messages(msg)
			
				current += 1
				outer.update_task(first_tasks[current])
		else:
			var msg: Array[String] = ["What in hell are you doing!? Follow the launch orders this time. Insubordinaton will necessitate... termination."]
			outer.hud.display_messages(msg)
		
class NormalFlow:
	var outer = null
	
	var all_tasks
	var completed = 0
	
	var incorrect = 0
	
	func init(outer):
		self.outer = outer
		
		return self
		
	func enter():
		# somehow gradually increase difficulty buckets
		all_tasks = outer.tasks.normal_tasks() 
		outer.update_task(all_tasks.pick_random())
		
		outer.hud.display_messages(outer.story.normal_flow_start())
	
	func update():
		pass
		
	func on_launch(good):
		if good:
			outer.hud.display_messages(outer.story.good_hit_bark())
			outer.update_task(all_tasks.pick_random())
			
			completed += 1
			print(completed)
			
			if completed == 3:
				pass  #  difficult ramp?
			elif completed == 4:
				outer.cat.activate()
			elif completed == 5:
				outer.emails.insert(0, Email.new().init("???", "You don't have to do this."))
			elif completed == 6:
				pass  # difficulty ramp?
			elif completed == 7:
				# send CAT disablement code
				outer.emails.insert(0, Email.new().init("???", "You can set the C.A.T to auto. The code is 7935. They want you distracted."))
			elif completed == 10:
				outer.emails.insert(0, Email.new().init("???", "They'll only kill you if they think you're disobeying.They don't actually know if the missiles hit.\nSet the Z target to +200 to safely detonate them above us."))
			elif completed == 13:
				outer.emails.insert(0, Email.new().init("???", "They say the invaders are along the front? Where does that leave them? Only Z -250 will penetrate their bunker."))
				# or, "the controls to rotate the station will be behind a locked door. Connect the vaccum tubes in <some order> to unlock it.

		else:
			outer.hud.display_messages(outer.story.bad_hit_bark())
			incorrect += 1
			
			if incorrect == 3:  # and it matters still
				pass  # TODO: game over
		
var current_state = null

var cat: Node3D = null

var debug_launch := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if current_state == null:
		current_state = StartState.new().init(self)
		current_state.enter()
		
	current_state.update()
	
	if Input.is_action_just_pressed("debug_good_launch"):
		debug_launch = true
	
	if just_launched and cat.is_good() and (DoodadState.missile_load_type != 0 or debug_launch):
		just_launched = false
		
		current_state.on_launch(debug_launch or tasks.was_correct(current_task))
		# TODO: separate on_launch() from prepare_next()
		DoodadState.missile_load_type = 0
		debug_launch = false
		
	just_launched = false
