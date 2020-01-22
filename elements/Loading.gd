extends Control

var OpenSeed
var Thicket
var gnum = 0
signal next(num)
signal alldone
signal bootup

var thread = Thread.new()
var what
var connect_thread = Thread.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	Thicket = get_node("/root/Thicket")
	OpenSeed = get_node("/root/OpenSeed")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Loading_bootup():
	if OpenSeed.online == true:
		if visible:
			$AnimationPlayer.play("loop")
			if !Thicket.check_cache("connections"):
				gather_connections()
			else:
				Thicket.load_cache("connections")
			
			if !Thicket.check_cache("new_artists"):
				gather_new_artists()
			else:
				Thicket.load_cache("new_artists")
			
			if !Thicket.check_cache("new_tracks"):
				gather_new_tracks()
			else:
				Thicket.load_cache("new_tracks")
			
			if !Thicket.check_cache("artists"):
				print("bla")
			else:
				Thicket.load_cache("artists")
			
			if !Thicket.check_cache("genres"):
				if gather_genres():
					Thicket.store("genres","")
					gather_all_tracks_artists(Thicket.genres[gnum])
			else:
				Thicket.load_cache("genres")
				
			if !Thicket.check_cache("tracks"):
				gather_all_tracks_artists(Thicket.genres[gnum])
			else:
				Thicket.load_cache("tracks")
				emit_signal("alldone")
	else:
		emit_signal("alldone")
	pass
	 
func _on_gathering(data):
	var returned_data
	
	pass
	
func gather_connections():
	$Label.text = "Gathering Connections"
	if OpenSeed.steem != "":
		Thicket.connections_list = OpenSeed.get_connections(OpenSeed.steem).split("\n")
	else:
		Thicket.connections_list = OpenSeed.get_connections(OpenSeed.username).split("\n")
	return 1

func gather_new_artists():
	$Label.text = "Gathering Artists"
	var artists = OpenSeed.get_from_socket('{"act":"newaccounts","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}')
	if artists:
		for a in artists.split(",),"):
			Thicket.new_artists.append(a.split("'")[1])
	return 1
	
func gather_new_tracks():
	$Label.text = "Gathering Tracks"
	var newtracks = OpenSeed.get_from_socket('{"act":"newtracks_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}')
	if newtracks:
		var clean_list = newtracks.split("}, ")
		print(len(clean_list))
		for t in clean_list:
			var json 
			if t[0] != "[":
				json = parse_json(t+"}")
			else:
				json = parse_json(t.trim_prefix("[")+"}")
			Thicket.new_tracks.append(json)
	return 1

func gather_genres():
	$Label.text = "Gathering Genres"
	var genres = OpenSeed.get_from_socket('{"act":"genres","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'"}')
	if genres:
		for g in genres.split(",),"):
			Thicket.genres.append(g.split("'")[1])
	return 1

func gather_all_tracks_artists(g):
	$Label.text = "Gathering Tracks ("+g+")"
	var content = OpenSeed.get_from_socket('{"act":"genre_json","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","genre":"'+g+'"}')
	if content:
		var clean_list = content.split("}, ")
		for t in clean_list:
			var json
			if t[0] != "[":
				json = parse_json(t+"}")
			else:
				json = parse_json(t.trim_prefix("[")+"}")
			Thicket.tracks.append(json)
			if json and json.keys().has("author"):
				if Thicket.artists:
					if !Thicket.artists.has(json["author"]):
						Thicket.artists.append(json["author"])
					else:
						Thicket.artists.append(json["author"])
			
	gnum += 1
	emit_signal("next",gnum)

func _on_trackandartist_timeout():
	$trackandartist.stop()
	gather_all_tracks_artists(Thicket.genres[gnum])
	
	pass # Replace with function body.


func _on_Loading_next(num):
	#$Label.text = "Gathering Tracks ("+Thicket.genres[num]+")"
	$Label.text = "Gathering Tracks ("+str(Thicket.tracks.size())+")"
	if Thicket.genres.size() -1 >= num:
		$trackandartist.start()
	else:
		convert_lists("recent")
		convert_lists("favorite")
		convert_lists("liked")
		$Label.text = "Store Data"
		Thicket.store("tracks",Thicket.tracks)
		Thicket.store("artists","")
		emit_signal("alldone")

func convert_lists(type):
	var file = File.new()
	var list
	var newlist 
	if file.file_exists("user://database/"+type+".dat"):
		file.open("user://database/"+type+".dat",File.READ)
		list = file.get_as_text()
		file.close()
		
		if list and list[0] == "[":
			var templist = list.split(", \n")
			for search in templist:
				var s = search.split(", ")[0].trim_prefix("[")
				var index = Thicket.find_track(s)
				if index != -1:
					if !newlist:
						newlist = to_json(Thicket.tracks[index])
					else:
						newlist = newlist+", \n"+to_json(Thicket.tracks[index])
			file.open("user://database/"+type+".dat",File.WRITE)
			file.store_string(newlist)
			file.close()
			
	
	

	
func _on_Loading_alldone():
	if what:
		what.show()
		#hide()

