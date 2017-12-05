extends "res://dialogBase.gd"

func _init():
	setBbcode("[center]"\
	+"[b]Saturday[/b]"\
	+"[url=success]On Monday god created night and day[/url]"\
	+"[/center]")

func success():
	appendBbcode("And God said, Let there be light: and there was light.\n"\
	+"And God saw the light, that it was good: and God divided the light from the darkness.\n"\
	+"And God called the light Day, and the darkness He called Night. And there was evening and there was morning, one day..")
	