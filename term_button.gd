extends Button

@onready var base_text = self.text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_entered.connect(on_enter)
	self.focus_entered.connect(on_enter)
	self.mouse_exited.connect(on_exit)
	self.focus_exited.connect(on_exit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func on_enter():
	self.text = "> " + base_text
	queue_redraw()
	
func on_exit():
	self.text = base_text
	queue_redraw()
	
