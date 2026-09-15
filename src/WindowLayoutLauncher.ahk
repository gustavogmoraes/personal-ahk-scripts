#Requires AutoHotkey v2.0
#SingleInstance Force
#Include LayoutGeometry.ahk

Persistent
CoordMode "Menu", "Screen"

global CapturedWindow := 0
global LayoutMenu := BuildLayoutMenu()
ConfigureTray()
Hotkey "^#z", OpenLayoutMenu, "On B0 T1"

ConfigureTray() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add "Open layout menu", OpenLayoutMenu
    A_TrayMenu.Add
    A_TrayMenu.Add "Exit", (*) => ExitApp()
    A_IconTip := "Window Layout Launcher"
}

BuildLayoutMenu() {
    menu := Menu()
    exact := Menu()
    exact.Add "1920 × 1080", ApplyExact.Bind(1920, 1080)
    exact.Add "1600 × 900", ApplyExact.Bind(1600, 900)
    exact.Add "1440 × 900", ApplyExact.Bind(1440, 900)
    exact.Add "1280 × 720", ApplyExact.Bind(1280, 720)
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
    global CapturedWindow, LayoutMenu
    hwnd := WinExist("A")
    if !IsEligible(hwnd) {
        TrayTip "Window Layout Launcher", "Select a normal resizable window first."
        return
    }
    CapturedWindow := hwnd
    MouseGetPos &x, &y
    LayoutMenu.Show x, y
}

IsEligible(hwnd) {
    if !hwnd || !DllCall("IsWindow", "ptr", hwnd, "int") || !WinGetStyle(hwnd) & 0x10000000
        return false
    class := WinGetClass(hwnd)
    return class != "Progman" && class != "WorkerW" && class != "Shell_TrayWnd"
}

GetWorkArea(hwnd := 0) {
    if hwnd {
        WinGetPos &x, &y, &width, &height, hwnd
        centerX := x + width // 2
        centerY := y + height // 2
        monitorCount := MonitorGetCount()
        loop monitorCount {
            MonitorGetWorkArea A_Index, &left, &top, &right, &bottom
            if centerX >= left && centerX < right && centerY >= top && centerY < bottom
                return {left: left, top: top, right: right, bottom: bottom}
        }
    }
    MonitorGetWorkArea 1, &left, &top, &right, &bottom
    return {left: left, top: top, right: right, bottom: bottom}
}

ApplyExact(width, height, *) {
    global CapturedWindow
    if !IsEligible(CapturedWindow)
        return
    rect := ResolveExactCentered(GetWorkArea(CapturedWindow), width, height)
    WinMove rect.x, rect.y, rect.width, rect.height, CapturedWindow
}

ApplyGrid(columns, rows, columnStart, columnEnd, rowStart, rowEnd, *) {
    global CapturedWindow
    if !IsEligible(CapturedWindow)
        return
    rect := ResolveGrid(GetWorkArea(CapturedWindow), columns, rows, columnStart, columnEnd, rowStart, rowEnd)
    WinMove rect.x, rect.y, rect.width, rect.height, CapturedWindow
}
