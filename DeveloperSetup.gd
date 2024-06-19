extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var displayed = 0
var banner = false
var avatar = false
var set_banner
var set_avatar
var banner_hash
var avatar_hash
var cName 
var pCon
var email
var steemaccount 
var about 


signal display(num)
# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/backButton.set("text","Cancel")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_nextButton_pressed():
	if displayed < 3:
		if $Panel/General.visible:
			if check_setup():
				displayed +=1
				
		elif $Panel/Files.visible:
			if set_banner and set_avatar:
				displayed += 1
				banner_hash = Thicket.ipfs_upload(set_banner)
				avatar_hash = Thicket.ipfs_upload(set_avatar)
				about = about+'","images":{"banner":"'+banner_hash+'","avatar":"'+avatar_hash+'"}'
		else:
			displayed += 1
	else:
		Thicket.developer_save(Thicket.dev_profile)
		hide()
		
	emit_signal("display",displayed)
		
	if !$Panel/Welcome.visible:
		$Panel/backButton.set("text","Back")
	else:
		$Panel/backButton.set("text","Cancel")
	
	if $Panel/Finish.visible:
		$Panel/nextButton.set("text","Finish")
		
		
	else:
		$Panel/nextButton.set("text","Next")

func _on_backButton_pressed():
	if displayed > 0:
		displayed -= 1
		emit_signal("display",displayed)
	else:
		hide()
		
	if $Panel/Finish.visible:
		$Panel/nextButton.set("text","Finish")
	else:
		
		$Panel/nextButton.set("text","Next")
		
	if !$Panel/Welcome.visible:
		$Panel/backButton.set("text","Back")
	else:
		$Panel/backButton.set("text","Cancel")



func _on_Banner_pressed():
	banner = true
	avatar = false 
	$FileDialog.popup_centered_ratio()
	pass # Replace with function body.

func _on_Avatar_pressed():
	avatar = true
	banner = false
	$FileDialog.popup_centered_ratio()
	pass # Replace with function body.

func _on_DeveloperSetup_display(num):
	$Panel/Welcome.hide()
	$Panel/General.hide()
	$Panel/Files.hide()
	$Panel/Finish.hide()
	
	match num:
		0: 
			displayed = num
			$Panel/Welcome.show()
		1:
			displayed = num
			$Panel/General.show()
		2:
			displayed = num
			$Panel/Files.show()
		3:
			displayed = num
			$Panel/Finish/Developer_ID.text = Thicket.create_developer(cName,pCon,email,steemaccount,about)
			
			$Panel/Finish.show()
	pass # Replace with function body.
	
func check_setup():
	cName = $Panel/General/companyName.text
	pCon = $Panel/General/primaryContact.text
	email = $Panel/General/email.text
	steemaccount = $Panel/General/steemAccount.text
	about = $Panel/General/aboutText.text
	
	if !cName:
		print("No Company")
		$Panel/General/companyName.placeholder_text = "Please Insert Company name"
	elif !pCon:
		print("No contact")
		$Panel/General/primaryContact.placeholder_text = "Please Insert primary contacts name"
	elif !email:
		print("No email")
		$Panel/General/email.placeholder_text = "Please Insert contact email"
	elif !steemaccount:
		print("No steemaccount")
		$Panel/General/steemAccount.placeholder_text = "Please Insert valid steem account"
	elif !about:
		$Panel/General/aboutText.text = "Will add profile later"
	else:
		print("all filled")
		
		return 1
		
	
	


func _on_FileDialog_confirmed():
	if banner:
		set_banner = $FileDialog.current_path
		print(set_banner)
		$Panel/Files/Banner.texture_normal = get_image(set_banner)
		
		banner = false
	if avatar:
		set_avatar = $FileDialog.current_path
		print(set_avatar)
		$Panel/Files/Avatar.texture_normal = get_image(set_avatar)
		avatar = false
		
	pass # Replace with function body.

func get_image(image):
	var imgfile = File.new()
	var Imagedata = Image.new()
	var Imagetex = ImageTexture.new()

	if imgfile.file_exists(image):
		print("Image found")
		imgfile.open(image, File.READ)
		var imagesize = imgfile.get_length()
		var err = Imagedata.load_jpg_from_buffer(imgfile.get_buffer(imagesize))
		#Imagedata.compress(0,0,75)
		if err !=OK:
			print("not a Jpeg...Checking if its a png")
			err = Imagedata.load_png_from_buffer(imgfile.get_buffer(imagesize))
			#Imagedata.compress(0,0,75)
			if err !=OK:
				Imagedata.load(image)
				Imagetex.create_from_image(Imagedata) #,0
			else:
				print("PNG found")
				Imagetex.create_from_image(Imagedata) #,0
		else:
			print("Jpg found")
			Imagetex.create_from_image(Imagedata) #,0
			
		imgfile.close()
		return Imagetex

