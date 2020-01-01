extends Control


var page = 0

func _ready():
	page = 0
	$Panel/Welcome.show()
	
	pass # Replace with function body.


func _on_backButton_pressed():
	if page > 0:
		page -= 1
		pages(page)
		


func _on_nextButton_pressed():
	if page < 4:
		page +=1
		pages(page)
		
func pages(num):
	print(num)
	match num:
		0:
			$Panel/Welcome.show()
			$Panel/General.hide()
		1:
			$Panel/Welcome.hide()
			$Panel/General.show()
			$Panel/NewAccount.hide()
		2:
			$Panel/General.hide()
			$Panel/NewAccount.show()
			$Panel/Finish.hide()
		3:
			$Panel/NewAccount.hide()
			$Panel/Finish.show()
