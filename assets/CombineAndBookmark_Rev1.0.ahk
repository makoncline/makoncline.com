#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance, Force

;Script
;select source folder
FileSelectFolder, sourceDir, ,1,Select Source Folder

;make temporary working directory
tempDir := makeTempDir(sourceDir)

;copy source files to temp working directory
copyDir(sourceDir, tempDir)

; make text file of all bookmarks
exportBookmarksForFilesIn(tempDir)

;delete all bookmarks
deleteBookmarksForFilesIn(tempDir)

;make bookmarks based on file name
makeBlankBookmarksForFilesIn(tempDir)

;add bookmarks to pdfs, delete bookmark text file
addBookmarksToFilesIn(tempDir)


bottomUpCombinePDF(tempDir)

MsgBox, Done




;functions
makeTempDir(dir){
	global sourceDir
	dirPath := parentDir(sourceDir)"\"dirName(sourceDir)"_temp"
	ifNotExist, %dirPath%
	FileCreateDir, %dirPath%
	return dirPath
}

currentDir(Path,Count=0,Delimiter="\") {
	While (InStr(Path,Delimiter) <> 0 && Count <> A_Index - 1)
	Path := SubStr(Path,1,InStr(Path,Delimiter,0,0) - 1)
	Return Path
}

parentDir(Path,Count=1,Delimiter="\") {
	While (InStr(Path,Delimiter) <> 0 && Count <> A_Index - 1)
	Path := SubStr(Path,1,InStr(Path,Delimiter,0,0) - 1)
	Return Path
}

dirName(dir){
	x = %dir%
	Stringgetpos,pos,x,\,R  
	StringLeft,path,x,%pos%
	pos+=1
	Stringtrimleft,dirName,x,%pos%
	return dirName
}

parentDirName(dir){
	return dirName(parentDir(dir))
}

copyDir(inDir, outDir){
	FileCopy, %inDir%, %outDir%
	Loop, Files, %inDir%\*.*, D
	{
		FileCopyDir, %A_LoopFileFullPath%, %outDir%\%A_LoopFileName%
	}
	return outDir
}

exportBookmark(file){
	SplitPath, file,,dir,,name
	outputName := dir "\" name ".txt"
	RunWait %comspec% /c pdftk "%file%" dump_data output "%outputName%"
	return outputName
}

exportBookmarksForFilesIn(dir){
	outputList := ""
	Loop, Files, %dir%\*.pdf, R
	{
		exportBookmark(A_LoopFilePath)
		outputList .= A_LoopFilePath "`n"
	}
	return outputList
}


deleteBookmark(file) {
	FileRead, contents, %file%
	if not ErrorLevel  ; Successfully loaded.
	{
		FileDelete, %file%
		contents := " "
		FileAppend, %Contents%, %file%
	}
	return %file%
}

deleteBookmarksForFilesIn(dir){
	outputList := ""
	Loop, Files, %dir%\*.txt, R
	{
		deleteBookmark(A_LoopFilePath)
		outputList .= A_LoopFilePath "`n"
	}
	return outputList
}

makeBookmark(file){
	FileRead, contents, %file%
	if not ErrorLevel 
	{
		title := removeFileExt(file)
		level := dirLevel(file)
		bookmark = BookmarkBegin`nBookmarkTitle: %title%`nBookmarkLevel: %level%`nBookmarkPageNumber: 1`n
		bookmark .= contents
		deleteFile(file)
		FileAppend, %bookmark%, %file%
	}
}
makeBookmarksForFilesIn(dir){
	outputList := ""
	Loop, Files, %dir%\*.txt, R
	{
		makeBookmark(A_LoopFilePath)
		outputList .= A_LoopFilePath "`n"
	}
	return outputList
}

makeBlankBookmark(file){
	FileRead, contents, %file%
	if not ErrorLevel 
	{
		title := 
		level := 1
		bookmark = BookmarkBegin`r`nBookmarkTitle: `r`nBookmarkLevel: 1`r`nBookmarkPageNumber: 0
		bookmark .= contents
		deleteFile(file)
		FileAppend, %bookmark%, %file%
	}
}
makeBlankBookmarksForFilesIn(dir){
	outputList := ""
	Loop, Files, %dir%\*.txt, R
	{
		makeBlankBookmark(A_LoopFilePath)
		outputList .= A_LoopFilePath "`n"
	}
	return outputList
}

removeFileExt(file){
	SplitPath, file,,,,name
	return name
}

addBookmark(file){
	;global tempDir
	SplitPath, file,,dir,,name
	fileName := dir "\" name ".pdf"
	data := dir "\" name ".txt"
	outputName := dir "\" name "_bookmarked.pdf"
	RunWait %comspec% /c pdftk "%fileName%" update_info "%data%" output "%outputName%"
	deleteFile(filename)
	deleteFile(data)
	FileMove, %outputName%, %fileName%
;MsgBox, Bookmark added to %fileName%
}

addBookmarksToFilesIn(dir) {
	outputList := ""
	Loop, Files, %dir%\*.txt, R
	{
		addBookmark(A_LoopFilePath)
		outputList .= A_LoopFilePath "`n"
	}
	return outputList
}

deleteFile(file){
	FileDelete, %file%
	;MsgBox, file deleted: %file%
}
deleteDir(dir){
	Loop, Files, %dir%\*.*, F 
	{
		FileDelete, %A_LoopFilePath%
	}
	FileRemoveDir, %dir%
	;MsgBox, Directory deleted: %dir%
}

lowestDir(dir){
	global workingDirectory
	Loop, Files, %dir%\*.*, D 
	{
		x := hasSubDir(A_LoopFilePath)
		if (x = false)
		workingDirectory := A_LoopFilePath
	}
	return workingDirectory
}

hasSubDir(dir){
	num := 0
	Loop, Files, %dir%\*.*, D 
	{
		num += 1
	}
	output := ""
	if (num > 0)
	output := true
	if (num = 0)
	output := false

	return output
}

combinePDFIn(dir){
	outputLocation := parentDir(dir)
	name := outputFileName(makePDFArray(dir))
	output := outputLocation "\" name ".pdf"
	RunWait %comspec% /c pdftk "%dir%\*.pdf" cat output "%output%"
	;MsgBox, fileCreated: %output%
	return output
}

outputFileName(file){
	outputName := removeFileExt(file.name)
	; if (file.level = 1)
	; {
	; 	outputName .= file.name
	; }
	; if (file.level = 2)
	; {
	; 	x := parentDirName(file.path)
	; 	outputName .= x
	; 	outputName .= " - "
	; 	outputName .= file.name
	; }
	return outputName
}

makePDFArray(dir){
	global sourceDir
	global tempDir
	path = %dir%
	name := dirName(path)
	if (path = tempDir) {
		name := dirName(sourceDir) "_combined"
	}
	level := dirLevel(path)
	Array := {name: name, path: path, level:level}
	return Array
	;MsgBox, array: %Array%
}

dirLevel(directory){
	global tempDir
	level:= 0
	dir := directory
	loop
	{
		if (dir = tempDir)
		{
			break
		}
		level += 1
		dir := parentDir(dir)
	}

	return level
}


removeBlankBookmark(file){
	FileRead, contents, %file%
	if not ErrorLevel 
	{
		replacedContent := RegExReplace(contents, "BookmarkBegin`r`nBookmarkTitle: `r`nBookmarkLevel: .`r`nBookmarkPageNumber: 0")
		FileDelete, %file%
		FileAppend, %replacedContent%, %file%
	}
}

removeBlankBookmarksFromFilesIn(dir){
	outputList := ""
	Loop, Files, %dir%\*.txt, R
	{
		removeBlankBookmark(A_LoopFilePath)
		outputList .= A_LoopFilePath "`n"
	}
	return outputList
}

lowestDirLevel(dir){
	maxLevel := 0
	Loop, Files, %dir%\*.*, DR 
	{	
		level := dirLevel(A_LoopFilePath)
		If (level > maxLevel) 
			maxLevel := level
	}
	return maxLevel
}

bottomUpCombinePDF(dir) {
	Loop, 10 
	{
		Loop, Files, %dir%\*.*, DR 
		{	
			combineLevel := lowestDirLevel(dir)
			;MsgBox, combineLevel: %combineLevel%
			level := dirLevel(A_LoopFilePath)
			If (combineLevel = 0)
				Break
			If (level = combineLevel) {
				exportBookmarksForFilesIn(A_LoopFilePath)
				makeBookmarksForFilesIn(A_LoopFilePath)
				addBookmarksToFilesIn(A_LoopFilePath)
				combinePDFIn(A_LoopFilePath)
				deleteDir(A_LoopFilePath)
			}
		}
	}
	exportBookmarksForFilesIn(dir)
	makeBookmarksForFilesIn(dir)
	removeBlankBookmarksFromFilesIn(dir)
	addBookmarksToFilesIn(dir)
	combinePDFIn(dir)
	deleteDir(dir)
}
