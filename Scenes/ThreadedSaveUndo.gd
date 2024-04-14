extends Node

onready var oBuffers = Nodelist.list["oBuffers"]
onready var oUndoStates = Nodelist.list["oUndoStates"]
onready var oCurrentMap = Nodelist.list["oCurrentMap"]

var semaphore = Semaphore.new()
var thread = Thread.new()

func _enter_tree():
	thread.start(self, "run_threaded_undo_save")

func run_threaded_undo_save(_userdata):
	while true:
		semaphore.wait()
		var CODETIME_START = OS.get_ticks_msec()
		var current_state = {}
		for EXT in oBuffers.FILE_TYPES:
			print("Undo processing: ", EXT)
			if oBuffers.should_process_file_type(EXT) == false:
				continue
			current_state[EXT] = oBuffers.get_buffer_for_extension(EXT, oCurrentMap.path)
		oUndoStates.call_deferred("on_undo_state_saved", current_state)
		print("Undo state save time: " + str(OS.get_ticks_msec() - CODETIME_START) + "ms")