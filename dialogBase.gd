extends Node

var bbcode = ""

func addLine(bbcode):
	self.bbcode = self.bbcode+bbcode

func addLink(text, callback, color="red"):
	self.bbcode = self.bbcode+"[indent][color="+color+"][url="+callback+"]"+text+"[/url][/color][/indent]"

func setBbcode(bbcode):
	self.bbcode = bbcode;
	call_deferred("deferredSetBbcode", self.bbcode)

func deferredSetBbcode(bbcode):
	get_parent().getTextNode().set_bbcode(bbcode)
		
func appendBbcode(bbcode):
	self.bbcode = self.bbcode + bbcode;
	print("BbCode.length()", self.bbcode.length())
	update()
	
func update():
	call_deferred("deferredSetBbcode", bbcode)

func deferredAppendBbcode(bbcode):
	get_parent().getTextNode().append_bbcode(bbcode)