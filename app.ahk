SetBatchLines, -1
#SingleInstance, Force
#Include %A_ScriptDir%\node_modules
#Include biga.ahk\export.ahk
#Include array.ahk\export.ahk
#Include string-similarity.ahk\export.ahk
#Include json.ahk\export.ahk
;#Include %A_ScriptDir%\CbAutoComplete-master\CbAutoComplete.ahk
; menu, tray, icon, % a_scriptDir "\Merus.ico"

FileGetTime ScriptStartModTime, % A_ScriptFullPath
SetTimer CheckScriptUpdate, 2000000, 0x7FFFFFFF ; 200 ms, highest priority

;------------------------------------------------------------------------------
; Script
;------------------------------------------------------------------------------
A := new biga() ; requires https://www.npmjs.com/package/biga.ahk



; read all A shortcuts from file
fileread, memoryFile, % A_ScriptDir "\settings.json"
; parse into a variable, because right now its just a big string
if (JSON.test(memoryFile)) {
	settings := JSON.parse(memoryFile)
} else {
	msgbox, "Could not read " A_ScriptDir "\settings.json or it isn't valid JSON!`nApp will quit"
}

msgbox, % bestLCode := selectLCode(settings, "Applicant's depot ")
; => L330: Depositions


#IfWinActive ahk_exe brave.exe
F1::	; Search for billing code
InputBox, UserInput, Phase of Litigation (L code)
bestMatchL := selectLCode(settings, UserInput)
InputBox, UserInput, Task type (A code)
; check if shortcut was entered
bestShortcut := stringsimilarity.findBestMatch(settings.shortCutAMap.keys(), UserInput).bestMatch
if (bestShortcut.rating > .80) {
	UserInput := settings.shortCutAMap[bestShortcut.target]
}
bestMatchA := stringsimilarity.simpleBestMatch(UserInput, settings.possibleStringsA)
bestMatch := bestMatchL . bestMatchA
msgbox, % "closest matching input:`n" bestMatch "`n`nPress F2 when ready to send"
OldClip := ClipboardAll
Clipboard := bestMatch
return


F2::		; Send billing code to Merus
sendInput, % bestMatch
Clipboard := Old
return

;------------------------------------------------------------------------------
; functions
;------------------------------------------------------------------------------
selectLCode(param_settings, param_input) {
	; check if shortcut was entered
	bestShortcut := stringsimilarity.findBestMatch(param_input, biga.keys(param_settings.shortCutLMap)).bestMatch
	if (bestShortcut.rating > .80) {
		key := param_settings.shortCutLMap[bestShortcut.target]
		biga.print(param_settings.shortCutLMap)
		return param_settings.possibleStringsL[key]
	}
	bestMatch := stringsimilarity.findBestMatch(param_input, param_settings.possibleStringsA).bestMatch
	if (bestMatch.rating > .80) {
		return param_settings.possibleStringsL[bestMatch.target]
	} else {
		return "No match found"
	}
}

#IfWinActive

;------------------------------------------------------------------------------
; Automatically reload after edit, Part 2
;------------------------------------------------------------------------------

CheckScriptUpdate() {
	global ScriptStartModTime
	FileGetTime curModTime, %A_ScriptFullPath%
	If (curModTime <> ScriptStartModTime) {
		SetTimer CheckScriptUpdate, Off
		Loop
		{
			reload
			Sleep 300 ; ms
			MsgBox 0x2, %A_ScriptName%, Reload failed. ; 0x2 = Abort/Retry/Ignore
			IfMsgBox Abort
				ExitApp
			IfMsgBox Ignore
				break
		} ; loops reload on "Retry"
	}
}
