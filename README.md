# Personal AHK Scripts

Open-source, source-first AutoHotkey v2 utilities for this Windows desktop.

## Window Layout Launcher

The first utility is a safe Sizer-style layout launcher. Press `Ctrl + Win + Z`
to open one popup menu for the window that was active at that moment. It will
offer exact outer-window sizes and monitor-relative layouts without injecting a
DLL or installing per-layout global shortcuts. Under Exact sizes, Place at
chooses where the next exact size lands. Center is the default. Choosing a
place does not move a window, and the size menu stays open.

Run the launcher with:

```powershell
.\Run-WindowLayoutLauncher.ps1
```

Run geometry tests with:

```powershell
& "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe" /ErrorStdOut .\tests\LayoutGeometry.Tests.ahk
```

Create a source package with:

```powershell
.\Package-Source.ps1
```

This repository is under active construction; the currently tracked source is
the authoritative implementation and test foundation.
