extends Node

const PORT = 12345 # porta para comunicações do servidor

var socket = PacketPeerUDP.new()
var is_host: bool = true
var host_peer: String
var joined_peer: String

func host():
	is_host = true
	socket.bind(PORT, "127.0.0.1")
	socket.set_broadcast_enabled(true)

func join(destiny):
	is_host = false
	host_peer = destiny
	socket.bind(PORT, "127.0.0.2") # Para receber mensagens
	socket.set_broadcast_enabled(true)
	socket.set_dest_address(host_peer, PORT)
	socket.put_packet(JSON.stringify(message("JOIN")).to_utf8_buffer())
	print("TRYING TO JOIN " + host_peer)

func message(op:String, flags: Array = []):
	var msg := {
		"v": 1,
		"op": op,
		"from": "nao implementado",
		"to" : "nao implementado"
	}
	
	match op:
		"ACCEPT":
			msg["mines"] = get_parent().get_node("TileMap").mine_coords
		"START_ROUND":
			pass
		"UPDATE_FLAGS":
			msg["flags"] = flags
		"SEND_LOSE":
			pass
	
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
			joined_peer = socket.get_packet_ip()
			#print(joined_peer + " JOINED")
			socket.set_dest_address(joined_peer, PORT)
			get_parent().new_game()
			socket.put_packet(JSON.stringify(message("ACCEPT")).to_utf8_buffer())
			
			await get_tree().process_frame
			socket.put_packet(JSON.stringify(message("START_ROUND")).to_utf8_buffer()) # start opponent turn
		"ACCEPT":
			host_peer = socket.get_packet_ip()
			#print(host_peer + " ACCEPTED")
			get_parent().get_node('TileMap').received_coords = received_message["mines"]
			get_parent().new_game()
		"REJECT":
			pass
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
		"SEND_COMPLETED":
			pass
		"SEND_WIN":
			pass
		"ERROR":
			pass

func _process(_delta: float) -> void:
	if socket.get_available_packet_count() > 0:
		var array_bytes = socket.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		#print("Received message: ", packet_string)
		handle_message(packet_string)
