extends Node

const PORT = 12345 # porta para comunicações do servidor

var peer = ENetMultiplayerPeer.new() # Objeto multiplayer usando a biblioteca de conexão da engine
var ishost: bool
var ip

func host():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer 
#	get_tree().set_network_peer(peer)
	
	multiplayer.peer_connected.connect(_on_peer_connected)

func join():
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(peer_id):
	print("Jogador entrou!")

func send_message(peer, op:String, data: Dictionary):
	var msg := {
		"v": 1,
		"op": op,
	}
	var json_str = JSON.stringify(data)
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
