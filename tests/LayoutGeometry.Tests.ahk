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

area := {left: -1920, top: 0, right: 0, bottom: 1080}
kept := ResolveExactPlaced(area, 800, 600, "keep", -100, -40)
AssertEqual(kept.x, -800, "keep clamps to the right edge")
AssertEqual(kept.y, 0, "keep clamps to the top edge")
AssertEqual(kept.width, 800, "keep width")

leftSide := ResolveExactPlaced(area, 800, 600, "left")
AssertEqual(leftSide.x, -1920, "left x")
AssertEqual(leftSide.y, 240, "left y")

topLeft := ResolveExactPlaced(area, 800, 600, "top-left")
AssertEqual(topLeft.x, -1920, "top-left x")
AssertEqual(topLeft.y, 0, "top-left y")

topRight := ResolveExactPlaced(area, 800, 600, "top-right")
AssertEqual(topRight.x, -800, "top-right x")
AssertEqual(topRight.y, 0, "top-right y")

bottom := ResolveExactPlaced(area, 800, 600, "bottom")
AssertEqual(bottom.x, -1360, "bottom x")
AssertEqual(bottom.y, 480, "bottom y")

centered := ResolveCenteredCurrentSize(area, 800, 600)
AssertEqual(centered.x, -1360, "centered current-size x on negative monitor")
AssertEqual(centered.y, 240, "centered current-size y")
AssertEqual(centered.width, 800, "centered current-size width")
AssertEqual(centered.height, 600, "centered current-size height")

FileAppend "Layout geometry tests passed.`n", "*"
