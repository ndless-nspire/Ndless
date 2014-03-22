If WinWait("[CLASS:nspire_emu]", "", 1) == 0 Then
   Exit 1
EndIf

WinActivate("[CLASS:nspire_emu]")
