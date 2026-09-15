# Manual Window Layout Smoke Test

Use only the disposable target; do not test the launcher first against a game,
Discord, browser, or production application.

1. In one PowerShell window, run:

   ```powershell
   & "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe" .\tests\DisposableTarget.ahk
   ```

2. In another PowerShell window, run:

   ```powershell
   .\Run-WindowLayoutLauncher.ps1
   ```

3. Focus **Window Layout Launcher Test Target**.
4. Press `Ctrl + Win + Z` exactly once.
5. Select **Exact sizes → 1280 × 720**. Confirm only the disposable window
   moves and resizes. On a smaller monitor, confirm it is centered and clamped
   inside the usable work area.
6. Repeat with **Thirds → Center third**, **Four columns → Column 3 of 4**, and
   **Quadrants → Bottom right**.
7. Right-click the launcher tray icon and select **Exit**. Confirm the global
   hotkey no longer opens a menu.

Pass criteria: every selection affects only the captured disposable target; no
other application moves, and the tray Exit action stops the listener normally.
