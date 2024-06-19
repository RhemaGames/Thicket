extends Control

var OpenSeed
var Thicket
var gnum = 0
signal next(num)
signal alldone
# warning-ignore:unused_signal
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
			#cycle("genres")
			cycle("connections")
			#if !Thicket.check_cache("connections"):
			#	gather_connections()
			#else:
			#	Thicket.load_cache("connections")
			
			#if !Thicket.check_cache("new_artists"):
			#	gather_new_artists()
			#else:
			#	Thicket.load_cache("new_artists")
			
			#if !Thicket.check_cache("new_tracks"):
			#	gather_new_tracks()
			#else:
			#	Thicket.load_cache("new_tracks")
			
			#if !Thicket.check_cache("artists"):
			#	print("bla")
			#else:
			#	Thicket.load_cache("artists")
			#
			#if !Thicket.check_cache("genres"):
			#	print("stuff")
			#	if gather_genres():
			#		Thicket.store("genres","")
			#		gather_all_tracks_artists(Thicket.genres[gnum])
			#else:
			#	if Thicket.load_cache("genres") == 1:
			#		print("loaded genres")
			#	
			#if !Thicket.check_cache("tracks"):
			#	gather_all_tracks_artists(Thicket.genres[gnum])
			#else:
			#	Thicket.load_cache("tracks")
			#emit_signal("alldone")
	else:
		emit_signal("alldone")
	pass
	
func cycle(type):
	match type:
		"genres":
			if !Thicket.check_cache("genres"):
				if gather_genres():
					if Thicket.store("genres",Thicket.genres):
						cycle("tracks")
			else:
				if Thicket.load_cache("genres"):
					cycle("tracks")
		"tracks":
			if !Thicket.check_cache("tracks"):
				gather_all_tracks(Thicket.genres[gnum])
			else:
				if Thicket.load_cache("tracks") == 1:
					#cycle("artists")
					cycle("connections")
		"artists":
			if !Thicket.check_cache("artists"):
				cycle("new_artists")
			else:
				if Thicket.load_cache("artists") == 1:
					cycle("new_artists")
		"new_artists":
				if !Thicket.check_cache("new_artists"):
					if gather_new_artists():
						cycle("connections")
				else:
					if Thicket.load_cache("new_artists") == 1:
						cycle("connections")
		"connections":
				if !Thicket.check_cache("connections"):
					if gather_connections():
						cycle("done")
				else:
					if Thicket.load_cache("connections") == 1:
						cycle("done")
		"done":
			OpenSeed.loadUserProfile(OpenSeed.username)
			emit_signal("alldone")
	 
#func _on_gathering(data):
	#var returned_data
	
#	pass
	
func gather_connections():
	$Label.text = "Gathering Connections"
	if OpenSeed.token != "":
		OpenSeed.openSeedRequest("get_connections",[OpenSeed.username])
		
	#	var jsoned = parse_json(response)
	#	if typeof(jsoned) == TYPE_DICTIONARY:
	#		Thicket.connections_list = parse_json(response)["connections"]
	#else:
	#	response = OpenSeed.get_connections(OpenSeed.username)
	#	var jsoned = parse_json(response)
	#	if typeof(jsoned) == TYPE_DICTIONARY:
	#		Thicket.connections_list = parse_json(response)["connections"]
	cycle("done")
	return 1

func gather_new_artists():
	$Label.text = "Gathering Artists"
	var artists = OpenSeed.get_from_socket('{"act":"newaccounts","appPub":"'+str(OpenSeed.appPub)+'","devPub":"'+str(OpenSeed.devPub)+'"}')
	if artists:
		for a in artists.split(",),"):
			Thicket.new_artists.append(a.split("'")[1])
	return 1
	
func gather_new_tracks():
	$Label.text = "Gathering Tracks"
	var newtracks = OpenSeed.get_from_socket('{"act":"newtracks_json","appPub":"'+str(OpenSeed.appPub)+'","devPub":"'+str(OpenSeed.devPub)+'"}')
	if newtracks:
		var clean_list = newtracks.split("}, ")
		for t in clean_list:
			var json 
			if t[0] != "[":
				var test_json_conv = JSON.new()
				test_json_conv.parse(t+"}")
				json = test_json_conv.get_data()
			else:
				var test_json_conv = JSON.new()
				test_json_conv.parse(t.trim_prefix("[")+"}")
				json = test_json_conv.get_data()
			Thicket.new_tracks.append(json)
	return 1

func gather_genres():
	$Label.text = "Gathering Genres"
	var genres = OpenSeed.get_from_socket('{"act":"genres","appPub":"'+str(OpenSeed.appPub)+'","devPub":"'+str(OpenSeed.devPub)+'"}')
	var test_json_conv = JSON.new()
	test_json_conv.parse(genres)
	var list = test_json_conv.get_data()
	print(list["results"])
	if list:
		for g in list["results"]:
			Thicket.genres.append(g)
	return 1

func gather_all_tracks(g):
	$Label.text = "Gathering Tracks ("+g+")"
	var content = OpenSeed.get_from_socket('{"act":"genre_json","appPub":"'+str(OpenSeed.appPub)+'","devPub":"'+str(OpenSeed.devPub)+'","genre":"'+g+'"}')
	if content:
		var test_json_conv = JSON.new()
		test_json_conv.parse(content)
		var clean_list = test_json_conv.get_data()
		if typeof(clean_list) == TYPE_DICTIONARY:
			for t in clean_list["results"]:
				Thicket.tracks.append(t)
				if t.keys().has("author"):
					if Thicket.artists:
						if !Thicket.artists.has(t["author"]):
							Thicket.artists.append(t["author"])
					else:
							Thicket.artists.append(t["author"])
	gnum += 1
	emit_signal("next",gnum)

func _on_trackandartist_timeout():
	$trackandartist.stop()
	gather_all_tracks(Thicket.genres[gnum])
	
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
		cycle("artists")
		#emit_signal("alldone")

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
						newlist = JSON.new().stringify(Thicket.tracks[index])
					else:
						newlist = newlist+", \n"+JSON.new().stringify(Thicket.tracks[index])
			file.open("user://database/"+type+".dat",File.WRITE)
			file.store_string(newlist)
			file.close()
			
func _on_Loading_alldone():
	if what:
		what.show()
		#hide()

