extends Node

const PORT = 12345 # porta para comunicações do servidor

var socket = PacketPeerUDP.new()
var is_host: bool = true
#var host_peer: String
#var joined_peer: String
var peer: String

func host():
	is_host = true
	socket.bind(PORT, get_parent().address)
	socket.set_broadcast_enabled(true)

func join(destiny):
	is_host = false
	peer = destiny
	socket.bind(PORT, get_parent().address) # Para receber mensagens
	socket.set_broadcast_enabled(true)
	socket.set_dest_address(peer, PORT)
	socket.put_packet(JSON.stringify(message("JOIN")).to_utf8_buffer())
	print("TRYING TO JOIN " + peer)

func message(op:String, flags: Array = []):
	var msg := {
		"v": 1,
		"op": op,
		"from": get_parent().address,
		"to" : peer
	}
	
	match op:
		"ACCEPT":
			msg["mines"] = get_parent().get_node("TileMap").mine_coords
		"UPDATE_FLAGS":
			msg["flags"] = flags
	
	print(msg)
	return msg

func receive_message(peer):
	if peer.get_available_bytes() > 0:
		var msg = peer.get_utf8_string(peer.get_available_bytes())
		var parsed = JSON.parse_string(msg)
		if typeof(parsed) == TYPE_DICTIONARY:
			handle_message(parsed)

func handle_message(msg):
	var received_message = JSON.parse_string(msg)
	match received_message["op"]:
		"JOIN":
			peer = socket.get_packet_ip()
			#print(joined_peer + " JOINED")
			socket.set_dest_address(peer, PORT)
			get_parent().new_game()
			socket.put_packet(JSON.stringify(message("ACCEPT")).to_utf8_buffer())
			
			await get_tree().process_frame
			socket.put_packet(JSON.stringify(message("START_ROUND")).to_utf8_buffer()) # start opponent turn
		"ACCEPT":
			peer = socket.get_packet_ip()
			#print(host_peer + " ACCEPTED")
			get_parent().get_node('TileMap').received_coords = received_message["mines"]
			get_parent().new_game()
		"START_ROUND":
			var tilemap = get_parent().get_node("TileMap")
			tilemap.start_turn()
			get_parent().get_node("HUD/PressEnter").text = "YOUR TURN"
		"SEND_LOSE":
			get_parent().get_node('TileMap').lose()
		"UPDATE_FLAGS":
			var tilemap = get_parent().get_node("TileMap")
			tilemap.update_flags(received_message["flags"])
			
			await get_tree().process_frame
			tilemap.start_turn()
			get_parent().get_node("HUD/PressEnter").text = "YOUR TURN"
		"SEND_WIN":
			get_parent().end_game(1)
		"ERROR":
			pass

func _process(_delta: float) -> void:
	if socket.get_available_packet_count() > 0:
		var array_bytes = socket.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		print("Received message: ", packet_string)
		handle_message(packet_string)
