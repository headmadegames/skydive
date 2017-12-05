extends Patch9Frame

onready var textNode = get_node("RichTextLabel")

var textAdvanceDelta = 0
var textAdvanceSpeed = 0.02
var bbcode
var dialog

func _ready():
	print("Dialog init")
	set_process(true)
	textNode.set_scroll_follow(true)

func loadText(weekday):
	var textResPath = "res://dialog/day_"+str(weekday)+".gd"
	print("loading dialog ", textResPath)
	var textRes = load(textResPath)
	if dialog:
		remove_child(dialog)
		queue_free(dialog)
	dialog = textRes.new()
	add_child(dialog)
	dialog.set_owner(self)

func _process(delta):
#	if textNode and textNode.get_percent_visible() < 1.0 and textAdvanceDelta > textAdvanceSpeed:
	if textNode and textNode.get_total_character_count() >= textNode.get_visible_characters():
		textAdvanceDelta = textAdvanceDelta+delta
		if textAdvanceDelta > textAdvanceSpeed:
			print("textAdvanceDelta ", textAdvanceDelta)
			var advanceBy = round(textAdvanceDelta/textAdvanceSpeed)
			print("advanceBy ", advanceBy)
			textNode.set_visible_characters(textNode.get_visible_characters()+advanceBy)
			textAdvanceDelta = 0
			if textNode.get_total_character_count() == textNode.get_visible_characters():
				print("Showing "+str(textNode.get_visible_characters())+ "/" + str(textNode.get_total_character_count()) + " length: " + str(textNode.get_text().length()))

func getTextNode():
	return self.textNode

func _on_RichTextLabel_meta_clicked( meta ):
	print("meta clicked ", meta)
	dialog.call(meta)
