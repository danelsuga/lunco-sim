extends Node

var PlayerEntity := preload("res://core/entities/player-entity.tscn")
var OperatorEntity := preload("res://core/entities/operator-entity.tscn")
var SpacecraftEntity := preload("res://core/entities/starship-entity.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		%MachineRole.text = "Server"
		multiplayer.peer_disconnected.connect(remove_player)
	else:
		%MachineRole.text = "Peer id: " + str(multiplayer.get_unique_id())
		multiplayer.server_disconnected.connect(server_offline)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Functions

func remove_player():
	pass

func server_offline():
	pass
	
	
@rpc("call_local", "any_peer")
func send_message(player_name, message, is_server):
	pass

@rpc("any_peer")
func add_player(id):
	pass
#	var player_instance = player.instantiate()
#	player_instance.name = str(id)
#	%SpawnPosition.add_child(player_instance)

#	send_message.rpc(str(id), " has joined the game", false)
@rpc("any_peer", "call_local")
func add_operator():
	var id = multiplayer.get_remote_sender_id()
	print("add_operator remoteid: ", id, " local id: ", multiplayer.get_unique_id())
	
	var found := false
	
	for i in %SpawnPosition.get_children():
		if i.name == str(id):
			found = true
	
	if not found:
		var operator = OperatorEntity.instantiate()
		operator.name = str(id)
		
		%SpawnPosition.add_child(operator)
		
		_on_multiplayer_spawner_spawned(operator)
			
		send_message.rpc(str(id), " has joined the game", false)

@rpc("any_peer")
func add_spacecraft(id):
	pass
	
#----------

func _on_create_operator():
	print("_on_create_operator: ", multiplayer.get_unique_id())
	add_operator.rpc_id(1)


func _on_multiplayer_spawner_spawned(node):
	if node.name == str(multiplayer.get_unique_id()):
		$Avatar.Operator = node
		$Avatar.set_target(node)
		
		%ObjectInspector.set_object(node)
