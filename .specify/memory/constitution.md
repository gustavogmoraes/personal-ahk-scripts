<!--
Sync Impact Report
- Version change: template -> 1.0.0
- Modified principles: all template placeholders replaced
- Added sections: Safety Boundaries; Quality Gates
- Removed sections: none
- Templates requiring updates: .specify/templates/*.md ✅ reviewed; no changes needed
- Follow-up TODOs: none
-->

# Personal AHK Scripts Constitution

## Core Principles

### I. Active-Window Safety First

Every layout action MUST operate only on the window that was active when the
user opened the launcher. The project MUST use supported, out-of-process
Windows window-management APIs and MUST NOT inject DLLs, hooks, overlays, or
code into target applications. It MUST never terminate, restart, modify, or
persistently configure another application.

### II. One-Trigger, Low-Friction Interaction

The window-layout launcher MUST expose exactly one configurable global trigger
for opening its layout menu. It MUST NOT register direct global shortcuts for
individual layouts. Common actions MUST be discoverable in the popup menu and
accessible with mouse and standard menu keyboard navigation.

### III. Deterministic Monitor-Aware Layouts

Built-in zone layouts MUST calculate from the usable work area of the monitor
containing the captured active window, so taskbars, multiple monitors, and
different display sizes are handled predictably. Exact-size layouts MUST use
explicit pixel dimensions. Geometry calculation MUST be separable from window
movement and covered by automated tests.

### IV. User-Owned, Portable Configuration

Layouts and preferences MUST be stored in readable, versioned local text files.
The application MUST start with safe useful defaults and recover from missing or
invalid optional configuration without resizing a window unexpectedly. The
repository MUST include an example configuration and documentation for adding,
editing, and resetting custom layouts.

### V. Source-First Delivery and Verifiable Releases

The repository MUST contain complete, readable source, an OSI-approved license,
setup instructions, test instructions, and a repeatable packaging path. Changes
to geometry, menu routing, configuration parsing, or safety boundaries MUST be
validated before release. A compiled package, if provided, MUST be reproducible
from the tracked source and MUST NOT be the only supported way to run the tool.

## Safety Boundaries

The launcher is a desktop productivity tool, not a game-resolution controller,
window injector, process manager, or automation framework. It may reposition a
normal resizable active window only after an explicit launcher action. It MUST
refuse to apply a layout when no eligible captured window exists, and it MUST
show a clear local error instead of guessing a target.

## Quality Gates

Each feature MUST have measurable acceptance scenarios. Pure geometry and
configuration behavior MUST have automated tests. End-to-end smoke validation
MUST verify that the one global trigger opens the menu, a menu selection applies
the expected rectangle to the captured active window, and no target-process
module is introduced by the launcher. Documentation MUST be reviewed against
the shipped configuration and package instructions before publication.

## Governance

This constitution supersedes local convenience choices. Every specification,
plan, task list, review, and release check MUST identify applicable principles.
Amendments require a documented rationale, a semantic-version update, and an
assessment of configuration or user-behavior migration. Compliance is reviewed
before each published release.

**Version**: 1.0.0 | **Ratified**: 2026-09-14 | **Last Amended**: 2026-09-14
