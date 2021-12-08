extends VBoxContainer
onready var oScriptTextEdit = Nodelist.list["oScriptTextEdit"]
onready var oDataScript = Nodelist.list["oDataScript"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]
onready var oEditor = Nodelist.list["oEditor"]

func _on_ScriptTextEdit_visibility_changed():
	print('_on_ScriptTextEdit_visibility_changed')
	if visible == true:
		reload_script_into_window()

func set_text(setWithString):
	print('set_text')
	oScriptTextEdit.text = setWithString
	oDataScript.data = setWithString
	_on_ScriptTextEdit_text_changed()

func reload_script_into_window():
	print('reload_script_into_window')
	oScriptTextEdit.text = oDataScript.data
#	if oCurrentMap.currentFilePaths.has("TXT"):
#		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]

func _on_ScriptTextEdit_text_changed():
	print('_on_ScriptTextEdit_text_changed')
	oEditor.mapHasBeenEdited = true
	oDataScript.data = oScriptTextEdit.text

#func place_text(insertString):
#	insertString =
	
	#oScriptTextEdit.cursor_set_line(lineNumber, txt)
#	var lineNumber = oScriptTextEdit.cursor_get_line()
#	var existingLineString = oScriptTextEdit.get_line(lineNumber)
#
#	if oScriptTextEdit.get_line(lineNumber).length() > 0: #If line contains stuff
#		oScriptTextEdit.set_line(lineNumber, existingLineString + '\n')
#		oScriptTextEdit.set_line(lineNumber+1, insertString)
#
#		oScriptTextEdit.cursor_set_line(oScriptTextEdit.cursor_get_line()+1)
#	else:
#		oScriptTextEdit.set_line(lineNumber, insertString)
#	oScriptTextEdit.update()


#func reload_script_into_window(): # Called from oDataScript
#	oScriptTextEdit.text = oDataScript.data
	
#	if oCurrentMap.currentFilePaths.has("TXT"):
#		oScriptNameLabel.text = oCurrentMap.currentFilePaths["TXT"][oCurrentMap.PATHSTRING]
#	else:
#		oScriptNameLabel.text = "No script file loaded"
	
#	hide_script_side()
	
#	if oDataScript.data == "":
#		hide_script_side()
#	else:
#		show_script_side()

#func hide_script_side():
#	oScriptContainer.visible = false
	# Make scroll bar area fill the entire window
	#oGeneratorContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#yield(get_tree(),'idle_frame')
	#rect_size.x = 0

#func show_script_side():
#	oScriptContainer.visible = true
#	# Reduce scroll bar area so ScriptContainer has space
#	oGeneratorContainer.size_flags_horizontal = Control.SIZE_FILL
#	yield(get_tree(),'idle_frame')
#	if rect_size.x < 960:
#		rect_size.x = 1280


