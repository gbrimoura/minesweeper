extends Node

const PORT = 12345 # porta para comunicações do servidor

#var peer = ENetMultiplayerPeer.new() # Objeto multiplayer usando a biblioteca de conexão da engine
var socket = PacketPeerUDP.new()
var is_host: bool = true
var host_peer: String
var joined_peer: String

func host():
	is_host = true
	socket.bind(PORT, "127.0.0.1")
	socket.set_broadcast_enabled(true)
	multiplayer.multiplayer_peer = socket 
#	get_tree().set_network_peer(peer)
#	multiplayer.peer_connected.connect(_on_peer_connected)

func join(destiny):
	is_host = false
	host_peer = destiny
	socket.bind(PORT, "127.0.0.2") # Para receber mensagens
	socket.set_broadcast_enabled(true)
	socket.set_dest_address(host_peer, PORT)
	socket.put_packet(JSON.stringify(message("JOIN")).to_utf8_buffer())
	print("TRYING TO JOIN " + host_peer)
	#socket.create_client(friend_peer, PORT)
	#multiplayer.multiplayer_peer = socket

#func _on_peer_connected(peer_id):
	#game_peer_id = str(peer_id)
#	print("Jogador entrou!")
	#get_parent().get_node("HUD/PressEnter").text = game_peer_id
#	get_parent().new_game()

func message(op:String):
	var msg := {
		"v": 1,
		"op": op,
		"from": "nao implementado",
		"to" : "nao implementado"
	}
	
	if op == "ACCEPT":
		msg["mines"] = get_parent().get_node("TileMap").mine_coords
	
	return msg

func receive_message(peer):
	if peer.get_available_bytes() > 0:
		var msg = peer.get_utf8_string(peer.get_available_bytes())
		var parsed = JSON.parse_string(msg)
		if typeof(parsed) == TYPE_DICTIONARY:
			handle_message(parsed)

func handle_message(msg):
	var received_message = JSON.parse_string(msg)
	print(received_message)
	match received_message["op"]:
		"JOIN":
			joined_peer = socket.get_packet_ip()
			print(joined_peer + " JOINED")
			socket.set_dest_address(joined_peer, PORT)
			get_parent().new_game()
			socket.put_packet(JSON.stringify(message("ACCEPT")).to_utf8_buffer())
		"ACCEPT":
			host_peer = socket.get_packet_ip()
			print(host_peer + " ACCEPTED")
			get_parent().get_node('TileMap').received_coords = received_message["mines"]
			get_parent().new_game()
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
		handle_message(packet_string)
