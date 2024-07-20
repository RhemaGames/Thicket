extends Node2D

@export var pivotpoint:Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Service.from_peer.connect(_on_from_peer)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Input.rotation += delta * 0.1
	pass

func _on_from_peer(id,type,data):
	print(id," ",type)
	match type:
		"hello":
			var requests = {}
			requests["system"] = ["memory","storage","network","cpu"]
			Service.rpc_id(id,"request",multiplayer.get_unique_id(),requests)
		"network":
			#print(data)
			pass
		"cpu":
			#print(data)
			pass
		"memory":
			var used_mem = data["physical"] - data["free"]
			var percent = float(used_mem) / float(data["physical"])
			$System.fill_by_type("memory",percent*100)
		"storage":
			for s in data:
				if s["Type"] == "ext4" and s["Mounted"] == "/":
					var fulldisk = int(s["Used"]) + int(s["Available"])
					var percent = float(s["Used"]) / float(fulldisk)
					$System.fill_by_type("storage",percent * 100)
					break
					
