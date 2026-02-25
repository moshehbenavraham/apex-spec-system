---
name: createuxprd
description: Generate the UX PRD companion document from design requirements
---

# /createuxprd Command

Convert user-provided design documents (wireframes, user flows, design specs, Figma notes) into the UX PRD at `.spec_system/PRD/PRD_UX.md`.

This is a companion to `PRD.md` (functional requirements). `/plansession` reads both when planning UI-focused sessions.

## Rules

1. **PRD.md must exist first** - run `/createprd` if it doesn't
2. **Never overwrite a real PRD_UX.md** without explicit user confirmation (template placeholders can be overwritten silently)
3. **Do not invent design decisions** - ask 3-8 targeted questions for missing info
4. **ASCII-only characters** and Unix LF line endings in all output
5. **Reference PRD.md, don't duplicate it** - link to functional requirements, don't restate them
6. **Keep it actionable** - every section should directly inform implementation

## Steps

### 1. Confirm Spec System and PRD Exist

Check for `.spec_system/PRD/PRD.md`. If missing, tell the user to run `/createprd` first -- the UX PRD depends on functional requirements being defined.

Read `.spec_system/PRD/PRD.md` to understand the product context, users, and requirements.

### 2. Get Deterministic Project State

Run the analysis script:

```bash
if [ -d ".spec_system/scripts" ]; then
  bash .spec_system/scripts/analyze-project.sh --json
else
  bash ${CLAUDE_PLUGIN_ROOT}/scripts/analyze-project.sh --json
fi
```

Use the JSON output for project name and current state.

### 3. Collect the Source Design Document

Ask the user for UX/design source material in one of these forms:
- Paste text directly (design notes, user flow descriptions, screen lists)
- Provide a file path (design spec, exported Figma notes)
- Describe the UX verbally

If the source is sparse, ask 3-8 targeted questions covering:
- Primary user flows (what are the critical paths?)
- Screen/page inventory (what screens exist?)
- Navigation structure (how do users move between screens?)
- Key interaction patterns (forms, modals, drag-drop, real-time?)
- Device/responsive strategy (mobile-first? desktop-only? both?)
- Accessibility requirements (WCAG level? specific needs?)

### 4. Decide Whether to Create or Update

Check whether `.spec_system/PRD/PRD_UX.md` already exists.

- If it does not exist: create it
- If it exists with template placeholders (2+ bracket markers like `[Screen Name]`): overwrite silently
- If it exists with real content: ask for confirmation, backup to `.spec_system/archive/PRD/PRD_UX-backup-YYYYMMDD-HHMMSS.md` before overwriting

### 5. Extract and Normalize UX Requirements

From the source material and PRD.md context, extract:
- **User flows**: critical paths through the application
- **Screen inventory**: every distinct screen/page/view
- **Navigation structure**: how screens connect
- **Interaction patterns**: forms, modals, notifications, real-time elements
- **Design tokens**: colors, typography, spacing (if provided)
- **Responsive strategy**: breakpoints, mobile vs desktop differences
- **Accessibility**: WCAG targets, keyboard nav, screen reader needs
- **Component patterns**: reusable UI patterns identified

Important:
- Derive flows from PRD.md use cases -- don't invent new ones
- If design details are missing, note them in Open Questions rather than guessing
- Focus on structure and behavior, not pixel-level aesthetics

### 6. Generate UX PRD

Create `.spec_system/PRD/PRD_UX.md`:

```markdown
# [PROJECT_NAME] - UX Requirements Document

**Companion to**: [PRD.md](PRD.md)
**Created**: [YYYY-MM-DD]

---

## 1. UX Overview

[1-2 paragraphs: overall UX approach, design philosophy, key principles]

---

## 2. User Flows

### Flow 1: [Flow Name]
**Trigger**: [What starts this flow]
**Goal**: [What the user accomplishes]

```
[Step 1] --> [Step 2] --> [Step 3] --> [Outcome]
     |
     v
  [Alt path] --> [Recovery]
```

**Happy path**: [Brief description]
**Error states**: [Key error scenarios and recovery]

### Flow 2: [Flow Name]
[Same structure]

---

## 3. Screen Inventory

| Screen | Route/Path | Purpose | Key Components |
|--------|------------|---------|----------------|
| [Screen] | [/path] | [Purpose] | [Components] |

---

## 4. Navigation Structure

```
[Root]
|-- [Section 1]
|   |-- [Screen A]
|   \-- [Screen B]
|-- [Section 2]
|   \-- [Screen C]
\-- [Settings/Profile]
```

**Navigation pattern**: [tabs, sidebar, breadcrumb, etc.]
**Deep linking**: [supported routes]

---

## 5. Interaction Patterns

### Forms
- Validation: [inline, on-submit, or both]
- Error display: [pattern]
- Success feedback: [pattern]

### Modals/Dialogs
- [When modals are used vs inline]
- Confirmation dialogs: [destructive actions that need confirmation]

### Loading States
- [Skeleton screens, spinners, progressive loading]

### Notifications
- [Toast, banner, inline -- when each is used]

---

## 6. Responsive Strategy

| Breakpoint | Target | Layout Changes |
|------------|--------|----------------|
| [< 640px] | Mobile | [Changes] |
| [640-1024px] | Tablet | [Changes] |
| [> 1024px] | Desktop | [Changes] |

**Approach**: [mobile-first / desktop-first / adaptive]

---

## 7. Accessibility

**Target**: [WCAG 2.1 AA / AAA / custom]

- Keyboard navigation: [requirements]
- Screen reader: [requirements]
- Color contrast: [requirements]
- Focus management: [requirements]

---

## 8. Design Tokens (if available)

### Colors
- Primary: [color]
- Secondary: [color]
- Error/Success/Warning: [colors]

### Typography
- Headings: [font, sizes]
- Body: [font, size]

### Spacing
- Base unit: [value]

*Note: Omit this section if no design tokens were provided. Add them when design assets become available.*

---

## 9. Component Patterns

| Component | Used In | Behavior |
|-----------|---------|----------|
| [Component] | [Screens] | [Key behavior] |

---

## 10. Open UX Questions

1. [Question requiring designer/user input]
2. [Question]
```

Notes:
- Omit sections that have no content rather than leaving placeholders
- Section 8 (Design Tokens) is optional -- omit entirely if not provided
- Keep flows as ASCII diagrams, not verbose prose

### 7. Validate Output

```bash
file .spec_system/PRD/PRD_UX.md
LC_ALL=C grep -n '[^[:print:][:space:]]' .spec_system/PRD/PRD_UX.md && echo "Non-ASCII found"
```

If checks fail, fix and re-check.

## Output

```
/createuxprd Complete!

Created:
- .spec_system/PRD/PRD_UX.md (UX requirements)
[If backup was made:]
- Backup: .spec_system/archive/PRD/PRD_UX-backup-YYYYMMDD-HHMMSS.md

Summary:
- User Flows: N defined
- Screens: N inventoried
- Interaction Patterns: N documented
- Open UX Questions: N items

Next Steps:
1. Review the UX PRD and refine as needed
2. Run /plansession -- it will use both PRD.md and PRD_UX.md for UI sessions
```
