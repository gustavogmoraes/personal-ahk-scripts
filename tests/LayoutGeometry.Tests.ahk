#Requires AutoHotkey v2.0

#Include ..\src\LayoutGeometry.ahk

AssertEqual(actual, expected, name) {
    if (actual != expected)
        throw Error(name ": expected " expected ", got " actual)
}

third := ResolveGrid({left: 0, top: 0, right: 1919, bottom: 1000}, 3, 1, 1, 2, 0, 1)
AssertEqual(third.x, 639, "middle-third x")
AssertEqual(third.width, 640, "middle-third width")

fourth := ResolveGrid({left: -1920, top: 0, right: 0, bottom: 1080}, 4, 1, 3, 4, 0, 1)
AssertEqual(fourth.x, -480, "fourth x on negative monitor")
AssertEqual(fourth.width, 480, "fourth width")

exact := ResolveExactCentered({left: 100, top: 50, right: 1700, bottom: 950}, 1920, 1080)
AssertEqual(exact.x, 100, "clamped exact x")
AssertEqual(exact.y, 50, "clamped exact y")
AssertEqual(exact.width, 1600, "clamped exact width")
AssertEqual(exact.height, 900, "clamped exact height")

centered := ResolveCenteredCurrentSize({left: -1920, top: 0, right: 0, bottom: 1080}, 800, 600)
AssertEqual(centered.x, -1360, "centered current-size x on negative monitor")
AssertEqual(centered.y, 240, "centered current-size y")
AssertEqual(centered.width, 800, "centered current-size width")
AssertEqual(centered.height, 600, "centered current-size height")

FileAppend "Layout geometry tests passed.`n", "*"
