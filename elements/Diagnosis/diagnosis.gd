extends Node2D

@export var pivotpoint:Node2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Service.from_peer.connect(_on_from_peer)
	Config.connect("loaded",Callable(self,"_on_config_loaded"))
	Config.open_config()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Input.rotation += delta * 0.1
	pass

func _on_from_peer(id,type,data):
	print_debug(id," ",type)
	match type:
		"hello":
			var requests = {}
			requests["system"] = ["memory","storage","network","cpu","sound"]
			Service.rpc_id(id,"request",multiplayer.get_unique_id(),requests)
		"network":
			#print(data)
			pass
		"cpu":
			print_debug(data)
			$CanvasLayer/PanelContainer/VBoxContainer/C/CPU.text = data["type"]
			pass
		"memory":
			var used_mem = data["physical"] - data["free"]
			var percent = float(used_mem) / float(data["physical"])
			$System.fill_by_type("memory",percent*100)
			$CanvasLayer/PanelContainer/VBoxContainer/M/Memory.text = str(used_mem/1024)
		"storage":
			for s in data:
				if s["Type"] == "ext4" and s["Mounted"] == "/":
					var fulldisk = int(s["Used"]) + int(s["Available"])
					var percent = float(s["Used"]) / float(fulldisk)
					$System.fill_by_type("storage",percent * 100)
					$CanvasLayer/PanelContainer/VBoxContainer/S/Storage.text = str(int(s["Used"])/1024)
					break
					
func _on_config_loaded():
	#print("Config loaded")
	Config.data["project"]["type"] = "ui"
	Service.connection_up = true
