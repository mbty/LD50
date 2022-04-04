extends Button

func _process(_delta):
	self.pressed = GameState.selected_tool == GameState.Tool.AISLE

func _on_AisleUI_pressed():	
	GameState.on_tool_selected(GameState.Tool.AISLE)
