#Requires AutoHotkey v2.0

ResolveGrid(workArea, columns, rows, columnStart, columnEnd, rowStart, rowEnd) {
    left := workArea.left + (workArea.right - workArea.left) * columnStart // columns
    right := workArea.left + (workArea.right - workArea.left) * columnEnd // columns
    top := workArea.top + (workArea.bottom - workArea.top) * rowStart // rows
    bottom := workArea.top + (workArea.bottom - workArea.top) * rowEnd // rows
    return {x: left, y: top, width: right - left, height: bottom - top}
}

ResolveExactCentered(workArea, requestedWidth, requestedHeight) {
    width := Min(requestedWidth, workArea.right - workArea.left)
    height := Min(requestedHeight, workArea.bottom - workArea.top)
    return {
        x: workArea.left + ((workArea.right - workArea.left - width) // 2),
        y: workArea.top + ((workArea.bottom - workArea.top - height) // 2),
        width: width,
        height: height
    }
}
