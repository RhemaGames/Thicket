extends Node

# Setup variables 

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
var devId = "VE06300819"
# warning-ignore:unused_class_variable
var appId = "ve003-234fser234"
var openseed = "142.93.27.131"
var version = ""
var server = StreamPeerTCP.new()
var connection = ""
# warning-ignore:unused_class_variable
var output = ""
#signals

# warning-ignore:unused_signal
signal login(status)
# warning-ignore:unused_signal
signal interface(type)
# warning-ignore:unused_signal
signal linked()
signal userLoaded()

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
	var response = get_from_socket('{"act":"accountcheck","appID":"'+str(appId)+'","devID":"'+str(devId)+'","username":"'+str(u)+'","passphrase":"'+str(p)+'"}')
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

# get_from_openseed is the go to function for all http communications. Based on the godot documentations example. 
# The required variables are as follows:
# type: This ditates what happens to the returned data from the url and/or setting the right site / script on the server side.
# url: The site we need to connect too.
# port: The port to connect to port 80 is the standard http port where 443 is https. You can also supply your own port if you need to.
# fields: This is the data you send to the server via POST connection

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

func get_from_socket(data):
# warning-ignore:unused_variable
	var connect = false
	server.connect_to_host(openseed, 8688)
	while server.get_status() != 2:
		connect = false
	server.put_data(data.to_utf8())
	var fromserver = server.get_data(8192)
	server.disconnect_from_host()
	return (fromserver[1].get_string_from_ascii())
	

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
	var response = get_from_socket('{"act":"payment","appID":"'+str(appId)+'","devID":"'+str(devId)+'","steemaccount":"'+str(steem)+'","postingkey":"'+str(postingkey)+'","amount":"'+str(amount)+'","to":"'+str(to)+'","for":"'+str(what)+'"}')
	return response

#func get_updates():
		#var response = get_from_socket('{"act":"update","appID":"'+str(appId)+'","devID":"'+str(devId)+'"}')
		#if response != version:
			#var headers = [
				#	"User-Agent: Pirulo/1.0 (Godot)",
				#	"Accept: */*"
				#]
			#$HTTPRequest.request(str(image),headers,false,HTTPClient.METHOD_GET)

