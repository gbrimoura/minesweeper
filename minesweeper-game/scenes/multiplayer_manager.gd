extends Node

const PORT = 12345 # porta para comunicações do servidor

#var peer = ENetMultiplayerPeer.new() # Objeto multiplayer usando a biblioteca de conexão da engine
var socket = PacketPeerUDP.new()
var ishost: bool
var friend_peer: String
var game_peer_id: String

func host():
	socket.bind(PORT)
	multiplayer.multiplayer_peer = socket 
#	get_tree().set_network_peer(peer)
	
	multiplayer.peer_connected.connect(_on_peer_connected)

func join(destiny):
	friend_peer = destiny
	socket.set_dest_address(friend_peer, PORT)
	socket.put_packet("JOIN".to_utf8_buffer())
	#socket.create_client(friend_peer, PORT)
	#multiplayer.multiplayer_peer = socket

func _on_peer_connected(peer_id):
	game_peer_id = str(peer_id)
	print("Jogador entrou!")
	get_parent().get_node("HUD/PressEnter").text = game_peer_id
	get_parent().new_game()

func send_message(peer, op:String, data: Dictionary):
	var msg := {
		"v": 1,
		"op": op,
		"from": friend_peer
	}
	var json_str = JSON.stringify(msg)
	peer.put_utf8_string(json_str)

func receive_message(peer):
	if peer.get_available_bytes() > 0:
		var msg = peer.get_utf8_string(peer.get_available_bytes())
		var parsed = JSON.parse_string(msg)
		if typeof(parsed) == TYPE_DICTIONARY:
			handle_message(parsed)

func handle_message(msg):
	match msg["op"]:
		"JOIN":
			pass
		"ACCEPT":
			pass
		"REJECT":
			pass
		"SEND_LOSE":
			pass
		"UPDATE_FLAGS":
			pass
		"SEND_COMPLETED":
			pass
		"SEND_WIN":
			pass
		"ERROR":
			pass

func _process(delta: float) -> void:
	if socket.get_available_packet_count() > 0:
		var array_bytes = socket.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		print("Received message: ", packet_string)
