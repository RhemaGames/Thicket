extends Node
var openseed = load("res://elements/OpenSeed.gd")
var OpenSeed = openseed.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.

func developer_mode():
	pass
	
func settings_save(cf,p2p,ipfs,dev,mf,vf):
	var file = File.new()
	var content = '{"customFolders":"'+str(cf)+'","p2p":"'+str(p2p)+'","ipfs":"'+str(ipfs)+'","devMode":"'+str(dev)+'","MusicFolder":"'+str(mf)+'","VideoFolder":"'+str(vf)+'"}'
	file.open("user://settings.dat", File.WRITE)
	file.store_string(content)
	file.close()
	print("Saving")
	
func settings_load():
	var file = File.new()
	if file.file_exists("user://settings.dat"):
		file.open("user://settings.dat", File.READ)
		var content = parse_json(file.get_as_text())
		file.close()
		return content
	
func developer_post():
	pass
	
func game_post():
	pass
	
func get_post(author,url):
	var post = OpenSeed.get_from_socket('{"act":"post","appID":"'+str(OpenSeed.appId)+'","devID":"'+str(OpenSeed.devId)+'","author":"'+author+'","permlink":"'+url+'"}')
	return post
	
func playlist_load(type):
	var file = File.new()
	var list
	match(type):
		"recent":
			if file.file_exists("user://database/"+type+".dat"):
				file.open("user://database/"+type+".dat", File.READ)
				list = file.get_as_text()
				file.close()
		_:
			if file.file_exists("user://database/"+type+".dat"):
				file.open("user://database/"+type+".dat", File.READ)
				list = file.get_as_text()
				file.close()
	return(list)
			

func playlist_save(type,data):
	var list = playlist_load(type)
	var file = File.new()
	if list:
		if list.find(str(data)+",") == -1:
			file.open("user://database/"+type+".dat", File.WRITE)
			file.store_string(str(data)+", \n"+list)
	else:
		file.open("user://database/"+type+".dat", File.WRITE)
		file.store_string(str(data)+", \n")
		
	file.close()

func create_folders():
	var dir = Directory.new()
	if !dir.dir_exists("user://cache"):
		dir.make_dir("user://cache")
	if !dir.dir_exists("user://favorites"):
		dir.make_dir("user://favorites")
	if !dir.dir_exists("user://database"):
		dir.make_dir("user://database")
	if !dir.dir_exists("user://database/artists"):
		dir.make_dir("user://database/artists")
	if !dir.dir_exists("user://database/genres"):
		dir.make_dir("user://database/genres")
	if !dir.dir_exists("user://games"):
		dir.make_dir("user://games")
	if !dir.dir_exists("user://updates"):
		dir.make_dir("user://updates")
	if !dir.dir_exists("user://playlists"):
		dir.make_dir("user://playlists")

# warning-ignore:unused_argument
func played_song_record(track):
	var file = File.new()
# warning-ignore:unused_variable
	var current_records
	if file.file_exists("user://records.dat"):
		file.open("user://records.dat", File.READ)
		current_records = parse_json(file.get_as_text())
		file.close()
	pass

func local_knowledge_load(type):
	var file = File.new()
	var list 
	match(type):
		_:
			if file.file_exists("user://database/"+type+".dat"):
				file.open("user://database/"+type+".dat", File.READ)
				list = file.get_as_text()
				file.close()
			else:
				list = ""
	return(list)
	
func local_knowledge_add(type,track):
	var list = local_knowledge_load(type)
	var file = File.new()
	if list.find(track) == -1:
		file.open("user://database/"+type+".dat", File.WRITE)
		file.store_string(list+", \n"+str(track))
		build_genres(track)
	file.close()

func build_genres(track):
	var list = ""
	var genre = ""
	var file = File.new()
	var tracked = str(track).split("', ")
	if len(tracked) == 17 or len(tracked) == 19:
		if tracked[7].split("'")[1]:
			genre = tracked[7].split("'")[1]
			list =local_knowledge_load(tracked[7].split("'")[1])
	if len(tracked) == 16 or len(tracked) == 15:
		if tracked[6].find("'") != -1:
			genre = tracked[6].split("'")[1]
			list =local_knowledge_load(tracked[6].split("'")[1])
		else:
			genre = tracked[6]
			list =local_knowledge_load(tracked[6])
		
	if list.find(str(track)+",") == -1:
		file.open("user://database/"+genre+".dat", File.WRITE)
		file.store_string(list+", \n"+str(track))
	file.close()

func create_playlist(name):
	print(name)
	var file = File.new()
	if !file.file_exists("user://playlists/"+name+".dat"):
		file.open("user://playlists/"+name+".dat",File.WRITE)
		file.close()
		return(true)
	else:
		return(false)
	