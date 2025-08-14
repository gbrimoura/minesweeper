extends CanvasLayer

func _on_host_pressed() -> void:
	get_parent().get_node("MultiplayerManager").host()
	get_parent().get_node("HUD/PressEnter").text = ""
	get_parent().new_game()


func _on_join_pressed() -> void:
	$TextEdit.show()
	$JoinGame.show()
	$Join.hide()
	$Host.hide()
	$Back.show()

func _on_back_pressed() -> void:
	$TextEdit.hide()
	$Back.hide()
	$Join.show()
	$Host.show()


func _on_join_game_pressed() -> void:
	get_parent().get_node("MultiplayerManager").ip = $TextEdit.text
	print(get_parent().get_node("MultiplayerManager").ip)
	get_parent().get_node("MultiplayerManager").join()
