extends WindowDialog
onready var oChooseFileListFileDialog = Nodelist.list["oChooseFileListFileDialog"]
onready var oTextureCache = Nodelist.list["oTextureCache"]
onready var oReloadEveryLineEdit = Nodelist.list["oReloadEveryLineEdit"]
onready var oReloaderContainer = Nodelist.list["oReloaderContainer"]
onready var oReloaderPathLabel = Nodelist.list["oReloaderPathLabel"]
onready var oExportTmapaDatDialog = Nodelist.list["oExportTmapaDatDialog"]
onready var oReadPalette = Nodelist.list["oReadPalette"]
onready var oChooseTmapaFileDialog = Nodelist.list["oChooseTmapaFileDialog"]
onready var oRNC = Nodelist.list["oRNC"]

var filelistfile = File.new()
var fileListFilePath = ""
var editingImg = Image.new()


func _ready():
	editingImg.create(8*32, 68*32, false, Image.FORMAT_RGB8)
	oReloaderContainer.visible = false

func _on_ChooseFileListFileDialog_file_selected(path):
	fileListFilePath = path
	oReloaderPathLabel.text = path
	
	oReloaderContainer.visible = true
	reloader_loop()

func reloader_loop():
	var timerNumber = float(oReloadEveryLineEdit.text)
	print(timerNumber)
	yield(get_tree().create_timer(timerNumber), "timeout")
	
	if fileListFilePath != "":
		execute()
	
	reloader_loop()

func _on_LoadFilelistButton_pressed():
	Utils.popup_centered(oChooseFileListFileDialog)
	oChooseFileListFileDialog.current_file = "filelist_tmapa000.txt"

func _on_ExportTmapaButton_pressed():
	Utils.popup_centered(oExportTmapaDatDialog)
	oExportTmapaDatDialog.current_file = get_tmapa_filename()+".dat"


func execute():
	var baseDir = fileListFilePath.get_base_dir()
	
	if filelistfile.open(fileListFilePath, File.READ) != OK: return
	
	var content = filelistfile.get_as_text()
	filelistfile.close()
	
	var lineArray = Array(content.split('\n', false))
	lineArray.pop_front() # remove the first line: textures_pack_000	8	68	32	32
	
	for i in lineArray.size():
		lineArray[i] = Array(lineArray[i].split('\t', false))
		#print(lineArray[i].size())
	
	
	#img.fill(Color(1,1,1,1))
	editingImg.lock()
	var imgLoader = Image.new()
	var CODETIME_START = OS.get_ticks_msec()
	for i in lineArray.size():
		#if i == 40:
			#print(lineArray[i])
			var path = lineArray[i][0]
			var x = lineArray[i][1]
			var y = lineArray[i][2]
			var width = lineArray[i][3]
			var height = lineArray[i][4]
			imgLoader.load(baseDir.plus_file(path))
			
			var destY = i/8
			var destX = i-(destY*8)
			
			var destination = Vector2(destX*32,destY*32)
			
			editingImg.blit_rect(imgLoader,Rect2(x,y,width,height), destination)
			#for z in lineArray[i]:
			#	print(z)
	editingImg.unlock()
	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')
	
	
	
	var tmapaNumber = get_tmapa_filename()
	oTextureCache.load_image_into_cache(editingImg, tmapaNumber)
	oTextureCache.set_current_texture_pack()
#	var imgTex = ImageTexture.new()
#	imgTex.create_from_image(img,0)
#	$"../TextureRect".texture = imgTex

func get_tmapa_filename():
	return fileListFilePath.right(fileListFilePath.length()-12).to_lower().trim_suffix(".txt")


func _on_ExportTmapaDatDialog_file_selected(path):
	var buffer = StreamPeerBuffer.new()
	#print(oTextureCache.paletteData)
	var CODETIME_START = OS.get_ticks_msec()
	
	editingImg.lock()

	for y in 68*32:
		for x in 8*32:
			var col = editingImg.get_pixel(x,y)
			var R = floor(col.r8/4.0)*4
			var G = floor(col.g8/4.0)*4
			var B = floor(col.b8/4.0)*4
			
			var roundedCol = Color8(R,G,B)
			
			var paletteIndex = 255 # Purple should show easier as an issue to debug
			if oReadPalette.dictionary.has(roundedCol) == true:
				paletteIndex = oReadPalette.dictionary[roundedCol]
#			else:
#				print(str(roundedCol.r) + ', '+str(roundedCol.g) + ', '+str(roundedCol.b) + ', '+str(roundedCol.a))
			
			buffer.put_8(paletteIndex)
	editingImg.unlock()
	
	var file = File.new()
	file.open(path,File.WRITE)
	file.store_buffer(buffer.data_array)
	file.close()

	print('Codetime: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')



func _on_CreateFilelistButton_pressed():
	Utils.popup_centered(oChooseTmapaFileDialog)

func _on_ChooseTmapaFileDialog_file_selected(path):
	var sourceImg = oTextureCache.convert_tmapa_to_image(path)
	if sourceImg == null: return
	var CODETIME_START = OS.get_ticks_msec()
	
	var baseDir = path.get_base_dir()
	
	var filelistFile = File.new()
	if filelistFile.open(Settings.unearthdata.plus_file("exportfilelist.txt"), File.READ) != OK:
		return
	
	# Split the Filelist into usable arrays
	
	var content = filelistFile.get_as_text()
	var numberString = path.get_file().get_basename().trim_prefix('tmapa')
	content = content.replace("subdir", "pack" + numberString)
	content = content.replace("textures_pack_number", "textures_pack_" + numberString)
	filelistFile.close()
	save_new_filelist_txt_file(content, numberString, baseDir)
	
	var lineArray = Array(content.split('\n', false))
	lineArray.pop_front() # For the array remove the first line: textures_pack_number	8	68	32	32
	
	for i in lineArray.size():
		lineArray[i] = Array(lineArray[i].split('\t', false))
	
	# The strings can be out of order, so create a dictionary that looks like this - "subdir/earth_standard.png" : []
	# Calculate the maxWidth and maxHeight by figuring out the largest destination positions that are in the list for each string
	var imageDictionary = {}
	for i in lineArray.size():
		var localPath = lineArray[i][0]
		
		if imageDictionary.has(localPath) == true:
			var compareWidth = int(lineArray[i][1]) + 32 #int(lineArray[i][3])
			var compareHeight = int(lineArray[i][2]) + 32 #int(lineArray[i][4])
			
			if imageDictionary[localPath][0] < compareWidth:
				imageDictionary[localPath][0] = compareWidth
			if imageDictionary[localPath][1] < compareHeight:
				imageDictionary[localPath][1] = compareHeight
		else:
			imageDictionary[localPath] = [32, 32] # 1 tile - minimum sized image
	
	# Replace the width and height array with an Image.
	for i in imageDictionary:
		var createNewImage = Image.new()
		var w = imageDictionary[i][0]
		var h = imageDictionary[i][1]
		createNewImage.create(w,h,false,Image.FORMAT_RGB8)
		imageDictionary[i] = createNewImage
	
	var dir = Directory.new()
	for i in lineArray.size():
		var sourceTileY = i / 8
		var sourceTileX = i - (sourceTileY * 8)
		
		var localPath = lineArray[i][0]
		var destX = lineArray[i][1]
		var destY = lineArray[i][2]
#		var width = lineArray[i][3]
#		var height = lineArray[i][4]
		var createNewImage = imageDictionary[localPath]
		createNewImage.lock()
		createNewImage.blit_rect(sourceImg, Rect2(sourceTileX*32,sourceTileY*32, 32,32), Vector2(destX, destY))
		createNewImage.unlock()
		
		var savePath = baseDir.plus_file(localPath)
		var packFolder = savePath.get_base_dir()
		
		if dir.dir_exists(packFolder) == false:
			dir.make_dir(packFolder)
		createNewImage.save_png(savePath)
		
		#sourceImg.save_png(savePath)
	
	print('Exported Filelist in: ' + str(OS.get_ticks_msec() - CODETIME_START) + 'ms')

func save_new_filelist_txt_file(content, numberString, baseDir):
	var file = File.new()
	file.open(baseDir.plus_file("filelist_tmapa"+numberString+".txt"), File.WRITE)
	file.store_string(content)
	file.close()

#	for y in 68:
#		for x in 8:
#
#			pass
#editingImg.lock()
#	var imgLoader = Image.new()
#	var CODETIME_START = OS.get_ticks_msec()
#	for i in lineArray.size():
#		#if i == 40:
#			#print(lineArray[i])
#			var path = lineArray[i][0]
#			var x = lineArray[i][1]
#			var y = lineArray[i][2]
#			var width = lineArray[i][3]
#			var height = lineArray[i][4]
#			imgLoader.load(baseDir.plus_file(path))
#
#			var destY = i/8
#			var destX = i-(destY*8)
#
#			var destination = Vector2(destX*32,destY*32)
#
#			editingImg.blit_rect(imgLoader,Rect2(x,y,width,height), destination)
#			#for z in lineArray[i]:
#			#	print(z)
#	editingImg.unlock()
