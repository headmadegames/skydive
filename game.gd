extends Control

var startTime
var weekday

onready var dialog = get_node("dialog")

func loadDialog(weekday):
	dialog.loadText(weekday)
	
func _ready():
	startTime = OS.get_datetime(false)
	weekday = startTime.weekday
	loadDialog(weekday)
	