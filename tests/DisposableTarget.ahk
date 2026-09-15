#Requires AutoHotkey v2.0

gui := Gui("+Resize", "Window Layout Launcher Test Target")
gui.AddText "w260", "Disposable target window for manual layout smoke tests."
gui.Show "x80 y80 w300 h180"
OnMessage 0x10, (*) => ExitApp()
