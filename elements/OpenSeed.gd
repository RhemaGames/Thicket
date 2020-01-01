extends Node

# Setup variables 
var thread = Thread.new()
var internal_thread = Thread.new()

var username = ""
# warning-ignore:unused_class_variable
var passphrase = ""
# warning-ignore:unused_class_variable
var email = ""
var token = ""
var steem = ""
# warning-ignore:unused_class_variable
var postingkey = ""
# warning-ignore:unused_class_variable
var steem_node = ""
# warning-ignore:unused_class_variable
var devId = "0a1831e5eb07615f9cbd999acc8464821b9299b642d033f501f177df5b5dc3a2"
# warning-ignore:unused_class_variable
var appId = "ve003-234fser234"
var openseed = "openseed.solutions"
var version = ""
var ipfs = ""
var connection = ""
# warning-ignore:unused_class_variable
var output = ""
#signals

#Profile variables
var profile_name = "User"
var profile_email = "User@mail.com"
var profile_about = "Does things and stuff"
var profile_image = ""
var profile_owns = [] 

var online = true
# warning-ignore:unused_signal
signal login(status)
# warning-ignore:unused_signal
signal interface(type)
# warning-ignore:unused_signal
signal linked()
signal userLoaded()

signal comment(info)

signal socket_returns(data)
signal chatdata(data)
signal sent_chat(data)

var dev_steem = ""
var dev_postingkey = ""

# Called when the node enters the scene tree for the first time.
# Default mode is set to login for obvious reasons. 
# Current interface options include:
# login: typical login interface also includes the new account creation dialogs
# steem: Interface to allow users to connect their game to the steem blockchain for cloud services.

func _ready():
	#emit_signal("interface","login")
	#loadUserData()
	pass

# Verifies the login creditials of an account on Openseed and reports back pass/fail/nouser.
func verify_account(u,p):
	print(u,p)
	var response = get_from_socket('{"act":"accountcheck","appID":"'+str(appId)+'","devID":"'+str(devId)+'","username":"'+str(u)+'","passphrase":"'+str(p)+'"}')
	print(response)
	return response
	
# Creates user based on the provided information. This user is added to the Openseed service. 
func create_user(u,p,e):
	var response = get_from_socket('{"act":"create","appID":"'+str(appId)+'","devID":"'+str(devId)+'","username":"'+str(u)+'","passphrase":"'+str(p)+'","email":"'+str(e)+'" }')
	return response

# Links steem account to openseed account for future functions.
func steem_link(u):
	
	#get_from_openseed("steem",openseed,8675,'act=link&username='+str(username))
# warning-ignore:unused_variable
	var response = get_from_socket('{"act":"link","appID":"'+str(appId)+'","devID":"'+str(devId)+'","steemname":"'+str(u)+'","username":"'+str(username)+'"}')


func _on_openseed_interface(type):
	match type :
		"login":
			$login.visible = true
			$new.visible = false
			#$link.visible = false
		"steem":
			$link.visible = true
			$login.visible = false
			$new.visible = false
		_:
			$link.visible = false
			$login.visible = false
			$new.visible = false

func get_steem_account(account):
	var profile = get_from_socket('{"act":"getaccount","appID":"'+str(appId)+'","devID":"'+str(devId)+'","account":"'+account+'"}')
	return profile

func get_full_steem_account(account):
	var profile = get_from_socket('{"act":"getfullaccount","appID":"'+str(appId)+'","devID":"'+str(devId)+'","account":"'+account+'"}')
	return profile

func get_openseed_account(account):
	var profile = parse_json(get_from_socket('{"act":"openseed_profile","appID":"'+str(appId)+'","devID":"'+str(devId)+'","account":"'+account+'"}'))
	return profile

func get_from_socket(data):
# warning-ignore:unused_variable
	var timeout = 18000
	var server = StreamPeerTCP.new()
	var connect = false
	server.connect_to_host(openseed, 8688)
	while server.get_status() != 2:
		connect = false
		#if timeout == 0:
		#	break
		#else:
		#	timeout -= 1
			
	server.put_data(data.to_utf8())
	var fromserver = server.get_data(161920)
	server.disconnect_from_host()
	return (fromserver[1].get_string_from_ascii())
	
func get_from_socket_threaded(data):
# warning-ignore:unused_variable
	var timeout = 18000
	var server = StreamPeerTCP.new()
	var connect = false
	server.connect_to_host(openseed, 8688)
	while server.get_status() != 2:
		connect = false
		#if timeout == 0:
		#	break
		#else:
		#	timeout -= 1
			
	server.put_data(data[0].to_utf8())
	var fromserver = server.get_data(161920)
	server.disconnect_from_host()
	call_deferred("returned_from_socket",data[1])
	return (fromserver[1].get_string_from_utf8())
	
func get_from_socket_threaded_internal(data):
# warning-ignore:unused_variable
	var timeout = 18000
	var server = StreamPeerTCP.new()
	var connect = false
	server.connect_to_host(openseed, 8688)
	while server.get_status() != 2:
		connect = false
		#if timeout == 0:
		#	break
		#else:
		#	timeout -= 1
			
	server.put_data(data[0].to_utf8())
	var fromserver = server.get_data(161920)
	server.disconnect_from_host()
	call_deferred("returned_from_socket_internal",data[1])
	return (fromserver[1].get_string_from_ascii())
	
func returned_from_socket_internal(type):
	#print("From Thread type = ",type)
	var socket = internal_thread.wait_to_finish()
	emit_signal("socket_returns",[type,socket])
	
func returned_from_socket(type):
	#print("From Thread type = ",type)
	var socket = thread.wait_to_finish()
	
	emit_signal("socket_returns",[type,socket])

func _on_OpenSeed_socket_returns(data):
	#print(data[0])
	match data[0]:
		"profile":
			saveUserProfile(data[1])
		"chat":
			emit_signal("chatdata",data[1])
		"send_chat":
			emit_signal("sent_chat",data[1])
		_:
			print("unknown")
			
	pass # Replace with function body.
	
func _on_login_login(status):
	if status == 1:
		$Login.hide()
		pass

func _on_new_login(status):
	if status == 2:
		$NewAccount.hide()

func _on_link_linked():
	
	pass # Replace with function body.

# warning-ignore:unused_argument
func get_leaderboard(number):
	var scores = get_from_socket('{"act":"getleaderboard","appID":"'+str(appId)+'","devID":"'+str(devId)+'"}')
	return scores

# In this function we send OpenSeed a request to add new data to the leaderboard. Taking two variables u for user and d for the data.
# The data is then reformated into a transmitable json like format for get_leaderboard to parse.
# Note the need for a steem account (called steem) and a postingkey. As a developer you have the choice to use your own postingKey or require the user to use theirs. 
# a small fee 0.001 STEEM is required to post the memo on openseeds account to store the information on the chain. 

func update_leaderboard(u,d):
	var dataformat = '{\\"'
	var datapoint = 0
	while datapoint < len(d):
		var repoint = d[datapoint].split(":")[0]+'\\":\\"'+d[datapoint].split(":")[1]
		dataformat = str(dataformat)+str(repoint)
		if datapoint+1 < len(d):
			dataformat = str(dataformat)+'\\",\\"'
		datapoint += 1
	dataformat = dataformat+'\\"}'
	var response = get_from_socket('{"act":"toleaderboard","appID":"'+str(appId)+'","devID":"'+str(devId)+'","username":"'+str(u)+'","data":"'+str(dataformat)+'","steem":"'+str(dev_steem)+'","postingkey":"'+str(dev_postingkey)+'"}')
	return response

func saveUserData():
	var file = File.new()
	var key = appId+devId+str(123456)
	var content = '{"usertoken":"'+str(token)+'","username":"'+str(username)+'","steemaccount":"'+str(steem)+'","postingkey":"'+str(postingkey)+'"}'
	file.open_encrypted_with_pass("user://openseed.dat", File.WRITE,key)
	file.store_string(content)
	print(content)
	file.close()
	
func saveUserProfile(data):
	var file = File.new()
	file.open("user://"+username+"profile.dat",File.WRITE)
	file.store_string(data)
	file.close()
	
func loadUserProfile(username):
	var file = File.new()
	if file.file_exists("user://"+username+"profile.dat"):
		file.open("user://"+username+"profile.dat",File.READ)
		var content = parse_json(file.get_as_text())
		profile_name = content["data1"]["name"]
		profile_about = content["data2"]["about"]
		profile_image = content["data5"]["profile"]["profile_image"]
		file.close()
	else:
		print("no profile found")
		internal_thread.start(self,"get_from_socket_threaded_internal", ['{"act":"openseed_profile","appID":"'+str(appId)+'","devID":"'+str(devId)+'","account":"'+username+'"}',"profile"])

func loadUserData():
	var file = File.new()
	var key = appId+devId+str(123456)
	file.open_encrypted_with_pass("user://openseed.dat", File.READ,key)
	var content = parse_json(file.get_as_text())
	
	file.close()
	if content:
		username = content["username"]
		token = content["usertoken"]
		steem = content["steemaccount"]
		postingkey = content["postingkey"]
	emit_signal("userLoaded")
	return content

func _on_Timer_timeout():
	$LeaderBoard.emit_signal("get_scores",10)
	pass

func send_tokens(amount,to,what):
	var response = get_from_socket('{"act":"payment","appID":"'+str(appId)+'","devID":"'+str(devId)+'","steemaccount":"'+str(steem)+'","amount":"'+str(amount)+'","to":"'+str(to)+'","for":"'+str(what)+'"}')
	return response

func send_like(post):
	var response = get_from_socket('{"act":"like","appID":"'+str(appId)+'","devID":"'+str(devId)+'","steemaccount":"'+str(steem)+'","post":"'+post+'"}')
	return response

func follow(user):
	var response = get_from_socket('{"act":"follow","appID":"'+str(appId)+'","devID":"'+str(devId)+'","steemaccount":"'+str(steem)+'","follow":"'+user+'"}')
	
func get_connections(account):
	var profile = get_from_socket('{"act":"openseed_connections","appID":"'+str(appId)+'","devID":"'+str(devId)+'","account":"'+account+'"}')
	return profile
	
func send_comment(account,comment,post):
	var response = get_from_socket('{"act":"comment","appID":"'+str(appId)+'","devID":"'+str(devId)+'","account":"'+account+'","comment":"'+comment+'","post":"'+post+'"}')
	return response

#func get_updates():
		#var response = get_from_socket('{"act":"update","appID":"'+str(appId)+'","devID":"'+str(devId)+'"}')
		#if response != version:
			#var headers = [
				#	"User-Agent: Pirulo/1.0 (Godot)",
				#	"Accept: */*"
				#]
			#$HTTPRequest.request(str(image),headers,false,HTTPClient.METHOD_GET)

func check_dev():
	pass

func check_ipfs():
	var output = []
	var ipfs_path = ""
	var file = File.new()
	if OS.get_name() == "X11":
		if file.file_exists("/usr/bin/ipfs"):
			ipfs_path = "/usr/bin/ipfs"
		elif file.file_exists("/snap/bin/ipfs"):
			ipfs_path = "/snap/bin/ipfs"
		if ipfs_path != "":
			ipfs = ipfs_path
			OS.execute("ps",["-e"],true,output)
			print(output[0].find("ipfs"))
			if output[0].find("ipfs") == -1:
				print(OS.execute(ipfs_path,["daemon","--routing=dhtclient"],false))
	pass

func _on_OpenSeed_comment(info):
	print("Getting here")
	#var cment = Comment.instance()
	#cment.show()
	#$CanvasLayer.add_child(cment)
	$CanvasLayer/Comment.show()
	pass # Replace with function body.
	
func get_keys_for(users):
	var response = get_from_socket('{"act":"update_key","appID":"'+str(appId)+'","devID":"'+str(devId)+'","thetype":"1","users":"'+users+'","uid":"'+token+'"}')
	return response.split("<::>")[1]

func simp_crypt(key,raw_data):
	key = key.replace("0","q")\
            .replace("1","a").replace("2","b")\
            .replace("3","c").replace("4","d")\
            .replace("5","F").replace("6","A")\
            .replace("7","Z").replace("8","Q")\
            .replace("9","T").replace("#","G")\
            .replace("!","B").replace(",","C")\
            .replace(" ","!").replace("/","S")\
            .replace("=","e").replace(":","c")\
            .replace("\n","n")
	var secret = ""
	var datanum = 0
	var offset = 0
	#var data = raw_data.replace(/%/g, ":percent:").replace(/&/g, ":ampersand:")
	var tdata = raw_data
	var digits = ""
	#//lets turn it into integers first//
	for t in raw_data.replace("%", ":percent:").replace("&", ":ampersand:"):
		var c = t.ord_at(0)
		digits += str(c)+" "
		
	var data = digits+str(str(" ").ord_at(0))
	while datanum < len(data):
		var keynum = 0
		while keynum < len(key):
			var salt = int(round(randf() * 40))
			if keynum < len(data) and salt % 3 == 0 and datanum < len(data):
				if data[datanum] == key[keynum]:
					var num = keynum
					while num < len(key) -1:
						secret = secret + key[num]
						num += 1
						if data[datanum] != key[num]:
							keynum = num
							secret = secret+data[datanum]
							print("shifting by:" + keynum)
							break
						else:
							secret = secret + key[num]
#                    	//secret = secret+data[datanum]
				else:
					secret = secret+data[datanum]
				datanum += 1
			else:
				if keynum < len(key) and key[keynum]:
					secret = secret + key[keynum]
				else:
					keynum = 0
					secret = secret + key[keynum]
			keynum += 1
		#datanum += 1
	return secret.replace(" ","zZz")

func simp_decrypt(key,raw_data):
	key = key.replace("0","q")\
            .replace("1","a").replace("2","b")\
            .replace("3","c").replace("4","d")\
            .replace("5","F").replace("6","A")\
            .replace("7","Z").replace("8","Q")\
            .replace("9","T").replace("#","G")\
            .replace("!","B").replace(",","C")\
            .replace(" ","!").replace("/","S")\
            .replace("=","e").replace(":","c")\
            .replace("\n","n")
			
	var key_stretch = key
	var message = ""
	var datanum = 0
	var offset = 0
	var decoded = ""

	var data = raw_data.replace("zZz"," ")

	if key_stretch != "":
		if len(data) > len(key_stretch):
			while len(key_stretch) < len(data):
				key_stretch = key_stretch + key

		while datanum < len(data):
			if key_stretch[datanum] != data[datanum]:
				if data[datanum]:
					message = message + data[datanum]
				else:break
			datanum = datanum + 1
			
		for c in message.split(" "):
			#if c < 101:
				#decoded += fromCharCode(message.split(" ")[c])
			if int(c) < 255:
				decoded += char(int(c))
			#else:
			#	decoded += c+" "
	else:
		 decoded = "Unable to Decrypt"
	return decoded.replace(":percent:","%").replace(":ampersand:","&")


