SetTimer, startTests, -1000

#Include %A_ScriptDir%\app.ahk
#Include %A_ScriptDir%\node_modules
#Include expect.ahk\export.ahk
#NoTrayIcon
#SingleInstance, force
SetBatchLines, -1


startTests:
expect := new expect()
expect.group("selectBestCode")
expect.label("with L settings")
expect.test(selectBestCode(settings.shortCutLmap, settings.possibleStringsL, "Applicant's depot "), "L330: Depositions")
expect.test(selectBestCode(settings.shortCutLmap, settings.possibleStringsL, "L340: ExpertDiscover"), "L340: Expert Discovery")

expect.label("with A settings")
expect.test(selectBestCode(settings.shortCutAmap, settings.possibleStringsA, "prepare five "), "A103: Draft/Revise")
expect.test(selectBestCode(settings.shortCutAmap, settings.possibleStringsA, "A104: Revie"), "A104: Review/Analyze")


; wrap up
expect.final()
expect.fullReport()
expect.writeResultsToFile()
ExitApp
