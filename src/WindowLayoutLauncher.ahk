#Requires AutoHotkey v2.0
#SingleInstance Force
#Include LayoutGeometry.ahk
#Include LayoutConfig.ahk

Persistent
CoordMode "Menu", "Screen"

global CapturedWindow := 0
global CapturedPid := 0
global CapturedClass := ""
global ExactAnchor := "center"
global ExactPlaceMenu := Menu()
global CapturedWidth := 0
global CapturedHeight := 0
global CapturedMaximized := false
global CustomExactSizes := []
global ConfigWarnKey := ""
global LayoutMenu := BuildLayoutMenu()
Hotkey "^#z", OpenLayoutMenu, "On B0 T1"

ConfigureTray() {
    global CustomExactSizes
    A_TrayMenu.Delete()
    A_TrayMenu.Add "Open layout menu", OpenLayoutMenu
    A_TrayMenu.Add "Edit layouts...", OpenLayoutSettings
    deleteMenu := Menu()
    if (CustomExactSizes.Length = 0) {
        deleteMenu.Add "(none)", (*) => 0
        deleteMenu.Disable "(none)"
    } else {
        for item in CustomExactSizes
            deleteMenu.Add item.label " (" item.width " × " item.height ")", DeleteCustomExactSize.Bind(item.id, item.label)
    }
    A_TrayMenu.Add "Delete custom size", deleteMenu
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
    rootMenu := Menu()
    rootMenu.Add "Fill usable area", ApplyFullWorkArea
    rootMenu.Add "Center current size", ApplyCenterCurrentSize
    rootMenu.Add
    LoadCustomSizes()
    exact := Menu()
    exact.Add(CurrentSizeLabel(), (*) => 0)
    exact.Disable(CurrentSizeLabel())
    exact.Add
    exact.Add "1920 × 1080", ApplyExact.Bind(1920, 1080)
    exact.Add "1600 × 900", ApplyExact.Bind(1600, 900)
    exact.Add "1440 × 900", ApplyExact.Bind(1440, 900)
    exact.Add "1280 × 720", ApplyExact.Bind(1280, 720)
    exact.Add "1024 × 768", ApplyExact.Bind(1024, 768)
    for item in CustomExactSizes
        AddExactItem(exact, item.label, ApplyExact.Bind(item.width, item.height))
    exact.Add "Save current size...", SaveCurrentSize
    exact.Add
    exact.Add "Place at", (*) => 0
    exact.Disable "Place at"
    global ExactPlaceMenu := exact
    for choice in GetExactAnchors()
        exact.Add choice.label, SetExactAnchor.Bind(choice.id)
    RefreshAnchorChecks()
    rootMenu.Add "Exact sizes", exact
    halves := Menu()
    halves.Add "Left half", ApplyGrid.Bind(2, 1, 0, 1, 0, 1)
    halves.Add "Right half", ApplyGrid.Bind(2, 1, 1, 2, 0, 1)
    halves.Add "Top half", ApplyGrid.Bind(1, 2, 0, 1, 0, 1)
    halves.Add "Bottom half", ApplyGrid.Bind(1, 2, 0, 1, 1, 2)
    rootMenu.Add "Halves", halves
    thirds := Menu()
    thirds.Add "Left third", ApplyGrid.Bind(3, 1, 0, 1, 0, 1)
    thirds.Add "Center third", ApplyGrid.Bind(3, 1, 1, 2, 0, 1)
    thirds.Add "Right third", ApplyGrid.Bind(3, 1, 2, 3, 0, 1)
    rootMenu.Add "Thirds", thirds
    columns := Menu()
    loop 4
        columns.Add "Column " A_Index " of 4", ApplyGrid.Bind(4, 1, A_Index - 1, A_Index, 0, 1)
    rootMenu.Add "Four columns", columns
    quadrants := Menu()
    quadrants.Add "Top left", ApplyGrid.Bind(2, 2, 0, 1, 0, 1)
    quadrants.Add "Top right", ApplyGrid.Bind(2, 2, 1, 2, 0, 1)
    quadrants.Add "Bottom left", ApplyGrid.Bind(2, 2, 0, 1, 1, 2)
    quadrants.Add "Bottom right", ApplyGrid.Bind(2, 2, 1, 2, 1, 2)
    rootMenu.Add "Quadrants", quadrants
    ConfigureTray()
    return rootMenu
}

CurrentSizeLabel() {
    global CapturedWidth, CapturedHeight, CapturedMaximized
    if (CapturedWidth < 1 || CapturedHeight < 1)
        return "Current: —"
    label := "Current: " CapturedWidth " × " CapturedHeight
    if CapturedMaximized
        label .= " (maximized)"
    return label
}

LoadCustomSizes() {
    global CustomExactSizes, ConfigWarnKey
    loaded := LoadLayoutFile(LayoutConfigPath())
    if !loaded.ok {
        CustomExactSizes := []
        stamp := LayoutConfigPath()
        try stamp .= "|" FileGetTime(LayoutConfigPath(), "M")
        if (stamp != ConfigWarnKey) {
            ConfigWarnKey := stamp
            MsgBox loaded.error, "Window Layout Launcher", "Icon!"
        }
        return
    }
    ConfigWarnKey := ""
    CustomExactSizes := CustomExactLayouts(loaded.data)
}

AddExactItem(exactMenu, label, callback) {
    candidate := label
    suffix := 2
    loop {
        try {
            exactMenu.Add candidate, callback
            return
        }
        candidate := label " (" suffix ")"
        suffix++
    }
}

SaveCurrentSize(*) {
    global CapturedWidth, CapturedHeight, CapturedMaximized, CustomExactSizes
    if (CapturedWidth < 1 || CapturedHeight < 1) {
        MsgBox "The captured window has no size to save.", "Window Layout Launcher", "Icon!"
        return
    }
    prompt := "Save " CapturedWidth " × " CapturedHeight
    if CapturedMaximized
        prompt .= " (maximized)"
    asked := InputBox(prompt " as:", "Save current size", "w360")
    if (asked.Result != "OK")
        return
    name := Trim(asked.Value)
    if (name = "")
        return
    if IsReservedSizeLabel(name) {
        MsgBox "That name is already used.", "Window Layout Launcher", "Icon!"
        return
    }
    saved := SaveCustomExact(LayoutConfigPath(), LayoutDefaultsPath(), name, CapturedWidth, CapturedHeight)
    if (saved != "") {
        MsgBox saved, "Window Layout Launcher", "Icon!"
        return
    }
    global LayoutMenu := BuildLayoutMenu()
}

DeleteCustomExactSize(id, label, *) {
    answer := MsgBox("Delete " label "?", "Window Layout Launcher", "YesNo Icon!")
    if (answer != "Yes")
        return
    removed := DeleteCustomExact(LayoutConfigPath(), id)
    if (removed != "") {
        MsgBox removed, "Window Layout Launcher", "Icon!"
        return
    }
    global LayoutMenu := BuildLayoutMenu()
}

IsReservedSizeLabel(name) {
    global CustomExactSizes
    if (SubStr(name, 1, 8) = "Current:")
        return true
    if (name = "Place at" || name = "Save current size...")
        return true
    for builtin in ["1920 × 1080", "1600 × 900", "1440 × 900", "1280 × 720", "1024 × 768"]
        if (builtin = name)
            return true
    for choice in GetExactAnchors()
        if (choice.label = name)
            return true
    for item in CustomExactSizes
        if (item.label = name)
            return true
    return false
}

GetExactAnchors() {
    return [
        {id: "keep", label: "Keep position"},
        {id: "center", label: "Center"},
        {id: "left", label: "Left"},
        {id: "right", label: "Right"},
        {id: "top", label: "Top"},
        {id: "bottom", label: "Bottom"},
        {id: "top-left", label: "Top left"},
        {id: "top-right", label: "Top right"},
        {id: "bottom-left", label: "Bottom left"},
        {id: "bottom-right", label: "Bottom right"}
    ]
}

SetExactAnchor(anchorId, *) {
    global ExactAnchor
    for choice in GetExactAnchors() {
        if (choice.id = anchorId) {
            ExactAnchor := anchorId
            RefreshAnchorChecks()
            SetTimer ShowExactPlaceMenu, -1
            return
        }
    }
}

ShowExactPlaceMenu() {
    global ExactPlaceMenu
    ExactPlaceMenu.Show()
}

RefreshAnchorChecks() {
    global ExactPlaceMenu, ExactAnchor
    for choice in GetExactAnchors() {
        if (choice.id = ExactAnchor)
            ExactPlaceMenu.Check choice.label
        else
            ExactPlaceMenu.Uncheck choice.label
    }
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
    WinGetPos ,,, &width, &height, hwnd
    global CapturedWidth := width
    global CapturedHeight := height
    global CapturedMaximized := WinGetMinMax(hwnd) = 1
    global LayoutMenu := BuildLayoutMenu()
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
    global ExactAnchor
    RestoreBeforeMove(CapturedWindow)
    WinGetPos &currentX, &currentY,,, CapturedWindow
    rect := ResolveExactPlaced(GetWorkArea(CapturedWindow), width, height, ExactAnchor, currentX, currentY)
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
