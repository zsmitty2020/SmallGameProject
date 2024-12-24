extends Area3D


var playersInArea = 0
var playerList = []
var oxygenGainSpeed = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if playersInArea >= 1:
		for player in playerList:
			player.gain_oxygen(delta * oxygenGainSpeed)
	
func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player_group"):
		print("appended: ", body)
		playerList.append(body)
		playersInArea += 1

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player_group"):
		print("removed: ", body)
		playerList.erase(body)
		playersInArea -= 1
