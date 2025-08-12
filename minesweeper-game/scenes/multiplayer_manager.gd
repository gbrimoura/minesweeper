extends Node

var hosting
var ishost: bool
var ip

func host():
	hosting = ENetMultiplayerPeer.new()
	hosting.create_server(25565)
	get_tree().set_network_peer(hosting)
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
	)
func join():
	hosting.create_client(ip, 25565)
	multiplayer.multiplayer_peer = hosting
	
func send_message():
	pass
