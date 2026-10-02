#Requires AutoHotkey v2.0

ResolveGrid(workArea, columns, rows, columnStart, columnEnd, rowStart, rowEnd) {
    left := workArea.left + (workArea.right - workArea.left) * columnStart // columns
    right := workArea.left + (workArea.right - workArea.left) * columnEnd // columns
    top := workArea.top + (workArea.bottom - workArea.top) * rowStart // rows
    bottom := workArea.top + (workArea.bottom - workArea.top) * rowEnd // rows
    return {x: left, y: top, width: right - left, height: bottom - top}
}

ResolveExactCentered(workArea, requestedWidth, requestedHeight) {
    return ResolveExactPlaced(workArea, requestedWidth, requestedHeight, "center")
}

ResolveExactPlaced(workArea, requestedWidth, requestedHeight, anchor, currentX := 0, currentY := 0) {
    workWidth := workArea.right - workArea.left
    workHeight := workArea.bottom - workArea.top
    width := Min(requestedWidth, workWidth)
    height := Min(requestedHeight, workHeight)
    x := workArea.left
    y := workArea.top
    switch anchor {
        case "keep":
            x := currentX
            y := currentY
        case "left":
            y := workArea.top + ((workHeight - height) // 2)
        case "right":
            x := workArea.right - width
            y := workArea.top + ((workHeight - height) // 2)
        case "top":
            x := workArea.left + ((workWidth - width) // 2)
        case "bottom":
            x := workArea.left + ((workWidth - width) // 2)
            y := workArea.bottom - height
        case "top-left":
            x := workArea.left
            y := workArea.top
        case "top-right":
            x := workArea.right - width
        case "bottom-left":
            y := workArea.bottom - height
        case "bottom-right":
            x := workArea.right - width
            y := workArea.bottom - height
        default:
            x := workArea.left + ((workWidth - width) // 2)
            y := workArea.top + ((workHeight - height) // 2)
    }
    if (x < workArea.left)
        x := workArea.left
    if (y < workArea.top)
        y := workArea.top
    if (x + width > workArea.right)
        x := workArea.right - width
    if (y + height > workArea.bottom)
        y := workArea.bottom - height
    return {x: x, y: y, width: width, height: height}
}

ResolveCenteredCurrentSize(workArea, currentWidth, currentHeight) {
    return ResolveExactCentered(workArea, currentWidth, currentHeight)
}
