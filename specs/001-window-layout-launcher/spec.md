# Feature Specification: Active Window Layout Launcher

**Feature Branch**: `001-window-layout-launcher`

**Created**: 2026-09-14

**Status**: Draft

**Input**: User description: "Create a safe, open-source personal Windows
window-layout launcher with one global hotkey and a popup menu for exact and
monitor-relative layouts."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Apply a layout to the active window (Priority: P1)

As a desktop user, I can focus any normal application window, use one global
trigger, and choose a layout from a popup menu so that I can arrange the current
window without application-specific setup.

**Why this priority**: This replaces the single Sizer workflow the user relies
on while avoiding its invasive application integration.

**Independent Test**: Focus a resizable window, open the launcher, select a
layout, and verify the same captured window has the expected rectangle.

**Acceptance Scenarios**:

1. **Given** a normal resizable window is active, **When** the user invokes the
   global trigger and selects `1920 × 1080`, **Then** that captured window is
   moved and sized to a 1920 by 1080 outer rectangle when the monitor can fit it.
2. **Given** a normal resizable window is active, **When** the user selects
   `Left half`, **Then** that captured window fills the left half of the usable
   area on the monitor that contained it when the launcher opened.
3. **Given** the popup is open, **When** focus changes to another window before
   a selection, **Then** a selection still applies only to the originally
   captured window or is safely rejected if that window is no longer eligible.

---

### User Story 2 - Choose common monitor-relative layouts (Priority: P2)

As a multi-monitor user, I can choose halves, thirds, four columns, and
quadrants so that I can organize any window consistently on the display where it
is currently being used.

**Why this priority**: Relative layouts are the daily-use extension requested
beyond fixed resolutions.

**Independent Test**: Use a known usable monitor rectangle and verify every
built-in layout resolves to the documented rectangle without moving a real
window.

**Acceptance Scenarios**:

1. **Given** a monitor with a nonzero work area, **When** the user selects a
   third or four-column position, **Then** the resulting rectangles cover the
   usable width without gaps or overlap caused by rounding.
2. **Given** a taskbar reduces a monitor's usable height, **When** the user
   selects a quadrant, **Then** the rectangle stays within the usable work area.

---

### User Story 3 - Maintain custom layouts (Priority: P3)

As a user, I can open an Edit Layouts screen from the tray icon, inspect the
defaults, and add, edit, remove, or reset named layouts without editing program
source.

**Why this priority**: The utility must remain simple at runtime while allowing
personal layouts to evolve.

**Independent Test**: Add a named layout, restart the launcher, select it from
the menu, then reset settings and verify only documented defaults remain.

**Acceptance Scenarios**:

1. **Given** the settings screen is open, **When** the user saves a valid custom
   exact or relative layout, **Then** it appears in the popup menu on the next
   invocation.
2. **Given** saved optional settings are invalid, **When** the launcher starts,
   **Then** it preserves the invalid file for recovery, informs the user, and
   starts with safe defaults without applying any layout automatically.

### Edge Cases

- No eligible active window exists when the global trigger is invoked.
- The selected exact size is larger than the captured monitor's usable area.
- The captured window is minimized, maximized, closed, non-resizable, or becomes
  unavailable before selection.
- A display is added, removed, rotated, or changes scaling while the launcher is
  running.
- A relative layout division leaves remainder pixels.
- The global trigger is unavailable because another application owns it.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST expose exactly one configurable global trigger
  that opens the layout menu and MUST NOT register direct global layout
  shortcuts.
- **FR-002**: The system MUST capture the eligible active window and its monitor
  when the layout menu opens, and MUST target only that captured window.
- **FR-003**: The popup menu MUST include exact sizes: 1920 × 1080, 1600 × 900,
  1440 × 900, 1280 × 720, and 1024 × 768.
- **FR-004**: The popup menu MUST include full usable area, center, halves,
  thirds, four columns, and four quadrants.
- **FR-005**: Monitor-relative layouts MUST be derived from the usable work area
  of the captured window's monitor.
- **FR-006**: The system MUST keep layout operations explicit; it MUST NOT move
  or resize a window on application launch, focus change, or settings change.
- **FR-007**: The system MUST safely reject an ineligible captured window and
  show an understandable local message without selecting another window.
- **FR-008**: The tray menu MUST provide access to settings, documentation, and
  a normal exit action.
- **FR-009**: Users MUST be able to create, edit, delete, order, disable, and
  reset named custom layouts through the settings screen.
- **FR-010**: The system MUST store settings in a readable local text file and
  ship a documented default configuration.
- **FR-011**: The application MUST remain out of target application processes;
  it MUST NOT inject a module, create an overlay in the target, terminate a
  target, or alter target configuration.
- **FR-012**: The project MUST be published with full source, an OSI-approved
  license, setup instructions, and repeatable packaging instructions.

### Key Entities

- **Layout**: A named user-visible menu item that describes either an exact
  outer rectangle or a position within a monitor's usable area.
- **Captured Window**: The single eligible window selected when the user opens
  the menu; it is the only possible target for that invocation.
- **Monitor Work Area**: The usable display rectangle used for relative layout
  calculation.
- **Preferences**: User-owned local settings containing the global trigger,
  menu order, enabled state, and custom layouts.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can open the launcher and apply a built-in layout to a
  normal active window in no more than two interactions after focusing it.
- **SC-002**: All documented built-in layouts resolve within the captured
  monitor's usable work area for 100% of tested monitor rectangles.
- **SC-003**: The launcher applies no rectangle to a different window in 100%
  of tests where focus changes after menu opening.
- **SC-004**: The source-run setup and the packaged-run setup both complete the
  P1 smoke scenario on the supported Windows host.
- **SC-005**: The published repository contains every file required to inspect,
  configure, run, test, and package the utility without proprietary source.

## Assumptions

- The first release targets current Windows desktop versions and normal
  resizable desktop windows.
- Exact dimensions refer to the outer window rectangle, consistent with the
  requested Sizer-style behavior.
- Built-in layouts use the captured monitor's work area by default; targeting a
  different monitor is outside the first release.
- The global trigger default is `Ctrl + Win + Z`, while remaining editable in
  settings; no other layout shortcuts are provided.
- The first release starts with clean defaults and does not import Sizer
  configuration.
- Game render resolution, fullscreen control, and automatic per-application
  layout rules are outside scope.
