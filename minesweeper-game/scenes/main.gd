extends Node

#game variables
const TOTAL_MINES : int = 20
var remaining_mines : int
var active_turn : bool
var is_host : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	#new_game() # Remover isso dps
	$GameOver.hide()
	$TileMap.hide()
	$HUD.hide()
func new_game():
	remaining_mines = TOTAL_MINES
	$TileMap.new_game()
	$GameOver.hide()
	$Title.hide()
	$HUD.show()
	$TileMap.show()
	$TileMap.clicked = false
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$HUD.get_node("Stopwatch").text = str(int(time_elapsed))
	$HUD.get_node("RemainingMines").text = str(remaining_mines)

func end_game(result):
	get_tree().paused = true
	$GameOver.show()
	if result == 1:
		# se o parceiro já ganhou, encerrar a partida. Senão, mandar mensagem de jogo "meio ganho"
		$GameOver.get_node("Label").text = "YOU WIN!"
	else:
		# mandar mensagem de jogo perdido, também encerrar a partida
		$GameOver.get_node("Label").text = "BOOM!"

func _on_tile_map_flag_placed():
	remaining_mines -= 1

func _on_tile_map_flag_removed():
	remaining_mines += 1

func _on_tile_map_end_game():
	end_game(-1)

func _on_tile_map_game_won():
	end_game(1)
	
func _on_game_over_restart():
	new_game()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if not $TileMap.clicked:
			$HUD/PressEnter.text = ""
