extends Node

# The URL we will connect to.
var websocket_url = "ws://localhost:12345" # Replace with actual server address and port
var socket := WebSocketPeer.new()

func _ready():
	if socket.connect_to_url(websocket_url) != OK:
		print("Could not connect.")
		set_process(false)

func _process(_delta):
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			print("Recv. >",socket.get_packet().get_string_from_ascii(),"<")


func _exit_tree():
	socket.close()

func _input(event):
	# Send "Ping!" to the server when Enter is pressed.
	if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
			print("You are currently not connected to the server.")
		else:
			socket.send_text("Ping!")
