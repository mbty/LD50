extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	self.pressed = GameState.selected_tool == GameState.Tool.AISLE

func _on_AisleUI_pressed():	
	var selected = GameState.Tool.AISLE if GameState.selected_tool != GameState.Tool.AISLE else null
	GameState.on_tool_selected(selected)
