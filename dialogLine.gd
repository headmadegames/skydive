extends Node

var bbcode

func setBbcode(bbcode):
	self.bbcode = bbcode;
	call_deferred("deferredSetBbcode", self.bbcode)

func deferredSetBbcode(bbcode):
	get_parent().getTextNode().set_bbcode(bbcode)
		
func appendBbcode(bbcode):
	self.bbcode = self.bbcode + bbcode;
	call_deferred("deferredAppendBbcode", bbcode)

func deferredAppendBbcode(bbcode):
	get_parent().getTextNode().append_bbcode(bbcode)