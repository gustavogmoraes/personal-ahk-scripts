#Requires AutoHotkey v2.0

#Include ..\src\LayoutConfig.ahk

Assert(condition, name) {
    if !condition {
        FileAppend "FAIL " name "`n", A_ScriptDir "\config-test-result.txt"
        ExitApp 1
    }
}

try RunConfigTests()
catch as err {
    FileAppend "THROW " err.Message " @ " err.Line "`n", A_ScriptDir "\config-test-result.txt"
    ExitApp 1
}

RunConfigTests() {
defaults := A_ScriptDir "\..\defaults\layouts.json"
loaded := LoadLayoutFile(defaults)
Assert(loaded.ok, loaded.HasProp("error") ? loaded.error : "defaults load")
Assert(CustomExactLayouts(loaded.data).Length = 0, "defaults have no custom sizes")
Assert(loaded.data["layouts"].Length = 20, "defaults keep every built-in layout")
Assert(loaded.data["layouts"][1]["label"] = "1920 × 1080", "first built-in label")

folder := A_Temp "\layout-config-" A_TickCount
DirCreate folder
path := folder "\layouts.json"
bad := "{ this is not json"
FileOpen(path, "w", "UTF-8-RAW").Write(bad)
before := FileRead(path, "UTF-8")
invalid := LoadLayoutFile(path)
Assert(!invalid.ok, "invalid json is rejected")
Assert(FileRead(path, "UTF-8") = before, "invalid json is kept byte for byte")
saveError := SaveCustomExact(path, defaults, "Game", 1600, 900)
Assert(saveError != "", "save refuses an invalid file")
Assert(FileRead(path, "UTF-8") = before, "refused save keeps the invalid file")

FileDelete path
saved := SaveCustomExact(path, defaults, "Game window", 1600, 900)
Assert(saved = "", "save custom size: " saved)
again := LoadLayoutFile(path)
customs := CustomExactLayouts(again.data)
Assert(customs.Length = 1, "one custom size")
Assert(customs[1].label = "Game window", "custom label")
Assert(customs[1].width = 1600 && customs[1].height = 900, "custom dimensions")
Assert(again.data["layouts"].Length = 21, "built-ins remain beside the custom size")
Assert(again.data["settings"]["openMenuHotkey"] = "^#z", "settings survive the save")
duplicate := SaveCustomExact(path, defaults, "Game window", 800, 600)
Assert(duplicate != "", "duplicate name is rejected")
Assert(CustomExactLayouts(LoadLayoutFile(path).data).Length = 1, "duplicate name writes nothing")

removed := DeleteCustomExact(path, customs[1].id)
Assert(removed = "", "delete custom size: " removed)
afterDelete := LoadLayoutFile(path)
Assert(CustomExactLayouts(afterDelete.data).Length = 0, "custom size is gone")
Assert(afterDelete.data["layouts"].Length = 20, "built-ins remain after delete")

FileDelete path
DirDelete folder
}
