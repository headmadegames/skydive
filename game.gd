extends Control

var startTime
var weekday
var score = 0

onready var dialog = get_node("gui/dialog")
onready var proximityLabel = get_node("gui/Proximity")
onready var contactLabel = get_node("gui/Contact")
onready var guiAnimationPlayer = get_node("gui/AnimationPlayer")
onready var scoreLabel = get_node("gui/scoreLabel/score")
onready var soundPlayer = get_node("soundPlayer")
	
func _ready():
	set_process(true)
	set_process_unhandled_key_input(true)

#	richLabelFX.toggleTypewriter(false)
	proximityLabel.updateText("\\6Proximity Bonus\\x")
	contactLabel.updateText("\\7Contact :)\\x")
	
	# draw collision shapes
	get_tree().set_debug_collisions_hint(true)

	startTime = OS.get_datetime(false)
	weekday = startTime.weekday
	loadDialog(weekday)
	
func loadDialog(weekday):
	dialog.loadText(weekday)
	
func showProximity():
	proximityLabel.show()
	
func hideProximity():
	proximityLabel.hide()
	
func showContact():
	guiAnimationPlayer.play("Contact")
	score += 1000
	
func _process(delta):
	if proximityLabel.is_visible():
		score += 100*delta
	
	scoreLabel.set_text("%010d" % score)
	
func _unhandled_key_input(event):
	print("Unhandled Event ", event)
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://game.tscn")