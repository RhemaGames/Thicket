extends Control

signal activeRelease(except)
var navbutton = preload("res://NavButton.tscn")

var active_area = ""
var last_color
var mainButtons = [
{"title":"Games","icon":"res://Img/applications-games-symbolic.svg","color":Thicket.games_color},
{"title":"Music","icon":"res://Img/folder-music-symbolic.svg","color":Thicket.music_color},
{"title":"Apps","icon":"res://Img/view-grid-symbolic.svg","color":Thicket.app_color},
{"title":"Social","icon":"res://Img/avatar-default-symbolic.svg","color":Thicket.social_color}
]

var musicButtons = [
{"title":"Deck","icon":"res://Img/view-list-symbolic.svg","color":color_phase(Thicket.music_color,1)},
{"title":"Recent","icon":"res://Img/folder-recent-symbolic.svg","color":color_phase(Thicket.music_color,2)},
{"title":"Favorites","icon":"res://Img/user-bookmarks-symbolic.svg","color":color_phase(Thicket.music_color,3)},
{"title":"Play Lists","icon":"res://Img/playlist-symbolic.svg","color":color_phase(Thicket.music_color,4)},
{"title":"Library","icon":"res://Img/network-server-symbolic.svg","color":color_phase(Thicket.music_color,5)},
{"title":"Search","icon":"res://Img/edit-find-symbolic.svg","color":color_phase(Thicket.music_color,6)}
]
var gameButtons = [
{"title":"Recent","icon":"res://Img/folder-recent-symbolic.svg","color":color_phase(Thicket.games_color,1)},
{"title":"Favorites","icon":"res://Img/user-bookmarks-symbolic.svg","color":color_phase(Thicket.games_color,2)},
{"title":"Store","icon":"res://Img/gnome-software-symbolic.svg","color":color_phase(Thicket.games_color,3)},
{"title":"Library","icon":"res://Img/network-server-symbolic.svg","color":color_phase(Thicket.games_color,4)},
{"title":"Search","icon":"res://Img/edit-find-symbolic.svg","color":color_phase(Thicket.games_color,5)}
]

var settingsButtons = [
{"title":"Account","icon":"res://Img/avatar-default-symbolic.svg","color":color_phase(Thicket.settings_color,1)},
{"title":"Files","icon":"res://Img/folder-symbolic.svg","color":color_phase(Thicket.settings_color,2)},
{"title":"Network","icon":"res://Img/network-workgroup-symbolic.svg","color":color_phase(Thicket.settings_color,3)},
{"title":"Creator","icon":"res://Img/applications-engineering-symbolic.svg","color":color_phase(Thicket.settings_color,4)},
]
var appButtons = []
var socialButtons = []

func _ready():
	nav_buttons("main")
	pass # Replace with function body.

func nav_buttons(area) :
	var thearea = []
	match(area):
		"main":
			thearea = mainButtons
			active_area = "main"
		"settings":
			thearea = settingsButtons
			active_area = "settings"
		"music":
			thearea = musicButtons
			active_area = "music"
		"games":
			thearea = gameButtons
			active_area = "games"
		"apps":
			thearea = appButtons
			active_area = "apps"
			#Thicket.application_list()
		"social":
			thearea = socialButtons
			active_area = "social"
			
	var children = $Main.get_child_count()
	while children >= 0:
		$Main.remove_child($Main.get_child(children))
		children -= 1
	
	for n in thearea:
		var note = navbutton.instance()
		note.text = vert_words(n["title"])
		note.bgColor = n["color"]
		note.icon = n["icon"]
		note.get_node("AnimationPlayer").play_backwards("focus")
		$Main.add_child(note)
		note.connect("activeSet",self,"set_focus")
		self.connect("activeRelease",note,"_on_ActiveRelease")

func release_focus() :
	emit_signal("activeRelease")

func set_focus(item):
	get_parent().active = item
	emit_signal("activeRelease",get_parent().active)
	var navLabel = get_parent().get_node("TopBar/HBoxContainer2/Nav")
	match(get_parent().active.replace("\n","")):
		"Music":
			if !get_parent().get_node("WindowContainer/AnimationPlayer").is_playing():
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Games",0.2,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Social",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Apps",0.4,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Settings",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Music",0.4,3)
				navLabel.text = "Music"
			nav_buttons("music")
		"Games":
			if !get_parent().get_node("WindowContainer/AnimationPlayer").is_playing():
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Music",0.2,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Social",0.4,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Apps",0.4,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Settings",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Games",0.4,3)
				navLabel.text = "Games"	
			nav_buttons("games")
		"Apps":
			if !get_parent().get_node("WindowContainer/AnimationPlayer").is_playing():
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Music",0.2,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Games",0.4,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Social",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Settings",0.4,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Apps",0.4,3)	
				navLabel.text = "Applications"
			nav_buttons("apps")
		"Social":
			if !get_parent().get_node("WindowContainer/AnimationPlayer").is_playing():
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Music",0.2,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Games",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Apps",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Settings",0.4,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Social",0.4,3)
				navLabel.text = "Social"
			nav_buttons("social")
		"Settings":
			if !get_parent().get_node("WindowContainer/AnimationPlayer").is_playing():
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Music",0.2,-5,true)
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Games",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Apps",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Social",0.4,-5,true)	
				get_parent().get_node("WindowContainer/AnimationPlayer").play("Settings",0.4,3)
				navLabel.text = "Settings"
			nav_buttons("settings")
		"Deck":
			if active_area == "music":
				get_node("../WindowContainer/Music").emit_signal("show","md")
				navLabel.text = "Music"
				nav_buttons("music")
		"Recent":
			if active_area == "music":
				get_node("../WindowContainer/Music").emit_signal("show","recent")
				navLabel.text = "Music - Recent"
				nav_buttons("music")
		"Library":
			if active_area == "music":
				get_node("../WindowContainer/Music").emit_signal("show","library")
				navLabel.text = "Music - Library"
				nav_buttons("music")
		"Search":
			if active_area == "music":
				get_node("../WindowContainer/Music").emit_signal("show","search")
				navLabel.text = "Music - Search"
				nav_buttons("music")
	

func _on_Navi_activeRelease(except):
	pass # Replace with function body.

func vert_words(word):
	var vert = ""
	var num = 0
	while num < word.length():
		vert += word[num]+"\n"
		num +=1
		
	return vert
	
func color_phase(color,shift):
	color.b *= shift
	if shift % 2 == 0:
			color.g *= shift
	if shift % 3 == 0:
			color.r *= shift
			
	return color
