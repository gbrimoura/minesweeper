extends Node

var peer = ENetMultiplayerPeer.new()

func host():
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
	)
func join():
	pass
