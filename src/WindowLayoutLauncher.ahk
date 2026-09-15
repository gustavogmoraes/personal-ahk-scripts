#Requires AutoHotkey v2.0
#SingleInstance Force
#Include LayoutGeometry.ahk

Persistent
CoordMode "Menu", "Screen"

global CapturedWindow := 0
global CapturedPid := 0
global CapturedClass := ""
global LayoutMenu := BuildLayoutMenu()
ConfigureTray()
Hotkey "^#z", OpenLayoutMenu, "On B0 T1"

ConfigureTray() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add "Open layout menu", OpenLayoutMenu
    A_TrayMenu.Add "Edit layouts...", OpenLayoutSettings
    A_TrayMenu.Add
    A_TrayMenu.Add "Exit", (*) => ExitApp()
    A_IconTip := "Window Layout Launcher"
}

OpenLayoutSettings(*) {
    configPath := A_AppData "\PersonalAhkScripts\WindowLayoutLauncher\layouts.json"
    configDirectory := RegExReplace(configPath, "\\[^\\]+$")
    DirCreate configDirectory
    if !FileExist(configPath)
        FileCopy A_ScriptDir "\..\defaults\layouts.json", configPath
    Run 'notepad.exe "' configPath '"'
}

BuildLayoutMenu() {
    menu := Menu()
    menu.Add "Fill usable area", ApplyFullWorkArea
    menu.Add "Center current size", ApplyCenterCurrentSize
    menu.Add
    exact := Menu()
    exact.Add "1920 × 1080", ApplyExact.Bind(1920, 1080)
    exact.Add "1600 × 900", ApplyExact.Bind(1600, 900)
    exact.Add "1440 × 900", ApplyExact.Bind(1440, 900)
    exact.Add "1280 × 720", ApplyExact.Bind(1280, 720)
    exact.Add "1024 × 768", ApplyExact.Bind(1024, 768)
    menu.Add "Exact sizes", exact
    halves := Menu()
    halves.Add "Left half", ApplyGrid.Bind(2, 1, 0, 1, 0, 1)
    halves.Add "Right half", ApplyGrid.Bind(2, 1, 1, 2, 0, 1)
    halves.Add "Top half", ApplyGrid.Bind(1, 2, 0, 1, 0, 1)
    halves.Add "Bottom half", ApplyGrid.Bind(1, 2, 0, 1, 1, 2)
    menu.Add "Halves", halves
    thirds := Menu()
    thirds.Add "Left third", ApplyGrid.Bind(3, 1, 0, 1, 0, 1)
    thirds.Add "Center third", ApplyGrid.Bind(3, 1, 1, 2, 0, 1)
    thirds.Add "Right third", ApplyGrid.Bind(3, 1, 2, 3, 0, 1)
    menu.Add "Thirds", thirds
    columns := Menu()
    loop 4
        columns.Add "Column " A_Index " of 4", ApplyGrid.Bind(4, 1, A_Index - 1, A_Index, 0, 1)
    menu.Add "Four columns", columns
    quadrants := Menu()
    quadrants.Add "Top left", ApplyGrid.Bind(2, 2, 0, 1, 0, 1)
    quadrants.Add "Top right", ApplyGrid.Bind(2, 2, 1, 2, 0, 1)
    quadrants.Add "Bottom left", ApplyGrid.Bind(2, 2, 0, 1, 1, 2)
    quadrants.Add "Bottom right", ApplyGrid.Bind(2, 2, 1, 2, 1, 2)
    menu.Add "Quadrants", quadrants
    return menu
}

OpenLayoutMenu(*) {
    global CapturedWindow, CapturedPid, CapturedClass, LayoutMenu
    hwnd := WinExist("A")
    if !IsEligible(hwnd) {
        TrayTip "Window Layout Launcher", "Select a normal resizable window first."
        return
    }
    CapturedWindow := hwnd
    CapturedPid := WinGetPID(hwnd)
    CapturedClass := WinGetClass(hwnd)
    MouseGetPos &x, &y
    LayoutMenu.Show x, y
}

IsEligible(hwnd, expectedPid := 0, expectedClass := "") {
    if !hwnd || !DllCall("IsWindow", "ptr", hwnd, "int")
        return false
    style := WinGetStyle(hwnd)
    if (style & 0x10000000) = 0 || (style & 0x40000000) != 0
        return false
    class := WinGetClass(hwnd)
    if expectedPid && (WinGetPID(hwnd) != expectedPid || class != expectedClass)
        return false
    return class != "Progman" && class != "WorkerW" && class != "Shell_TrayWnd"
}

GetWorkArea(hwnd := 0) {
    if hwnd {
        monitor := DllCall("MonitorFromWindow", "ptr", hwnd, "uint", 2, "ptr")
        monitorInfo := Buffer(40, 0)
        NumPut "uint", 40, monitorInfo, 0
        if monitor && DllCall("GetMonitorInfoW", "ptr", monitor, "ptr", monitorInfo.Ptr, "int")
            return {
                left: NumGet(monitorInfo, 20, "int"),
                top: NumGet(monitorInfo, 24, "int"),
                right: NumGet(monitorInfo, 28, "int"),
                bottom: NumGet(monitorInfo, 32, "int")
            }
    }
    MonitorGetWorkArea 1, &left, &top, &right, &bottom
    return {left: left, top: top, right: right, bottom: bottom}
}

ApplyExact(width, height, *) {
    global CapturedWindow, CapturedPid, CapturedClass
    if !IsEligible(CapturedWindow, CapturedPid, CapturedClass)
        return
    rect := ResolveExactCentered(GetWorkArea(CapturedWindow), width, height)
    if WinGetMinMax(CapturedWindow) = 1
        WinRestore CapturedWindow
    WinMove rect.x, rect.y, rect.width, rect.height, CapturedWindow
}

ApplyFullWorkArea(*) {
    global CapturedWindow, CapturedPid, CapturedClass
    if !IsEligible(CapturedWindow, CapturedPid, CapturedClass)
        return
    rect := GetWorkArea(CapturedWindow)
    RestoreBeforeMove(CapturedWindow)
    WinMove rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top, CapturedWindow
}

ApplyCenterCurrentSize(*) {
    global CapturedWindow, CapturedPid, CapturedClass
    if !IsEligible(CapturedWindow, CapturedPid, CapturedClass)
        return
    WinGetPos ,, &width, &height, CapturedWindow
    rect := ResolveCenteredCurrentSize(GetWorkArea(CapturedWindow), width, height)
    RestoreBeforeMove(CapturedWindow)
    WinMove rect.x, rect.y, rect.width, rect.height, CapturedWindow
}

ApplyGrid(columns, rows, columnStart, columnEnd, rowStart, rowEnd, *) {
    global CapturedWindow, CapturedPid, CapturedClass
    if !IsEligible(CapturedWindow, CapturedPid, CapturedClass)
        return
    rect := ResolveGrid(GetWorkArea(CapturedWindow), columns, rows, columnStart, columnEnd, rowStart, rowEnd)
    RestoreBeforeMove(CapturedWindow)
    WinMove rect.x, rect.y, rect.width, rect.height, CapturedWindow
}

RestoreBeforeMove(hwnd) {
    if WinGetMinMax(hwnd) = 1
        WinRestore hwnd
}
