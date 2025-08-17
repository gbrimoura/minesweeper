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

func message(op:String, flags: Array = [], flags_remaining: int = -1):
	var msg := {
		"v": 1,
		"op": op,
		"from": "nao implementado",
		"to" : "nao implementado"
	}
	
	match op:
		"ACCEPT":
			msg["mines"] = get_parent().get_node("TileMap").mine_coords
			msg["total_flags"] = get_parent().TOTAL_MINES  # Enviar total de flags
		"START_ROUND":
			pass
		"UPDATE_FLAGS":
			msg["flags"] = flags
<<<<<<< HEAD
			msg["flags_remaining"] = flags_remaining
		"SYNC_FLAGS":
			# Nova mensagem para sincronização inicial de flags
			msg["flags"] = flags
			msg["flags_remaining"] = flags_remaining
=======
		"SEND_LOSE":
			pass
>>>>>>> e55270c16056878dc9b65790a03d2c5e08c06b02
	
	return msg

func receive_message(peer):
	if peer.get_available_bytes() > 0:
		var msg = peer.get_utf8_string(peer.get_available_bytes())
		var parsed = JSON.parse_string(msg)
		if typeof(parsed) == TYPE_DICTIONARY:
			handle_message(parsed)

func handle_message(msg):
	var received_message
	# Corrigir parsing duplo - msg já pode estar parseado
	if typeof(msg) == TYPE_STRING:
		received_message = JSON.parse_string(msg)
	else:
		received_message = msg
		
	if typeof(received_message) != TYPE_DICTIONARY:
		print("Erro: mensagem inválida recebida")
		return
		
	match received_message["op"]:
		"JOIN":
			joined_peer = socket.get_packet_ip()
			socket.set_dest_address(joined_peer, PORT)
			get_parent().new_game()
			socket.put_packet(JSON.stringify(message("ACCEPT")).to_utf8_buffer())
			
			await get_tree().process_frame
			socket.put_packet(JSON.stringify(message("START_ROUND")).to_utf8_buffer())
			
		"ACCEPT":
			host_peer = socket.get_packet_ip()
			var tilemap = get_parent().get_node('TileMap')
			tilemap.received_coords = received_message["mines"]
			# Sincronizar total de flags se recebido
			if received_message.has("total_flags"):
				tilemap.total_flags = received_message["total_flags"]
				tilemap.flags_remaining = received_message["total_flags"]
			get_parent().new_game()
			
		"REJECT":
			pass
			
		"START_ROUND":
			var tilemap = get_parent().get_node("TileMap")
			tilemap.start_turn()
			get_parent().get_node("HUD/PressEnter").text = "YOUR TURN"
			
		"SEND_LOSE":
<<<<<<< HEAD
			pass
			
=======
			get_parent().get_node('TileMap').lose()
>>>>>>> e55270c16056878dc9b65790a03d2c5e08c06b02
		"UPDATE_FLAGS":
			var tilemap = get_parent().get_node("TileMap")
			# Sincronizar todas as flags (compartilhadas)
			tilemap.update_flags(received_message["flags"])
			# Sincronizar contagem de flags restantes
			if received_message.has("flags_remaining"):
				tilemap.flags_remaining = received_message["flags_remaining"]
				tilemap.update_flag_counter()
			
			await get_tree().process_frame
			tilemap.start_turn()
			get_parent().get_node("HUD/PressEnter").text = "YOUR TURN"
			
		"SYNC_FLAGS":
			# Sincronização inicial de flags compartilhadas
			var tilemap = get_parent().get_node("TileMap")
			tilemap.update_flags(received_message["flags"])
			
		"SEND_COMPLETED":
			pass
		"SEND_WIN":
			pass
		"ERROR":
			pass

<<<<<<< HEAD
func send_flag_update(flags: Array, flags_remaining: int):
	# Função específica para envio de atualizações de flags
	print("Enviando flags: ", flags, " - Restantes: ", flags_remaining)  # Debug
	var message_data = message("UPDATE_FLAGS", flags, flags_remaining)
	socket.put_packet(JSON.stringify(message_data).to_utf8_buffer())

func _process(delta: float) -> void:
=======
func _process(_delta: float) -> void:
>>>>>>> e55270c16056878dc9b65790a03d2c5e08c06b02
	if socket.get_available_packet_count() > 0:
		var array_bytes = socket.get_packet()
		var packet_string = array_bytes.get_string_from_ascii()
		handle_message(packet_string)
