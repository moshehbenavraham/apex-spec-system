# Apex Spec System

**Version: 1.0.2-beta**

A Claude Code plugin providing a specification-driven workflow system for AI-assisted development. Think Github Spec Kit (our source inspiration) simplified.

## Overview

The Apex Spec System breaks large projects into manageable, well-scoped implementation sessions that fit within AI context windows and human attention spans.

**Philosophy**: `1 session = 1 spec = 2-4 hours (12-25 tasks) = safe context window of AI`

## Installation

```bash
# Install from local directory
claude --plugin-dir /path/to/apex-spec-system

# Or copy to your plugins directory
cp -r apex-spec-system ~/.claude/plugins/
```

## Requirements

| Dependency | Required | Install |
|------------|----------|---------|
| **jq** | Yes | `apt install jq` or `brew install jq` |
| **git** | Optional | Usually pre-installed |

The scripts use `jq` for JSON parsing. Verify with: `bash scripts/check-prereqs.sh --env`

## Quick Start

1. **Install the plugin** (see above)

2. **Initialize in your project**:
   ```
   /initspec OR /apex-spec:initspec
   ```
   This creates the spec system structure in your project.

   **Optional but recommended**: Customize `.spec_system/CONVENTIONS.md` with your project's coding standards (naming, structure, error handling, testing philosophy, etc.)

   ```
   /createprd OR /apex-spec:createprd OR Manually fill out .spec_system/PRD/PRD.md
   ```
   Optional:  Turn argument or file path into a technical PRD for development.
   Example: /createprd "a habit trackker app"
            /createprd @docs/requirements.md

   ```
   /phasebuild OR /apex-spec:phasebuild
   ```
   This will set up the initial Phase and Sessions for that initial Phase

3. **Run the session workflow and repeat until all sessions inside the Phase are completed, thus completing the Phase**:
   ```
   /plansession OR /apex-spec:plansession    # Analyze, spec, and generate task checklist
   /implement OR /apex-spec:implement        # Start implementation
   /validate OR /apex-spec:validate          # Verify completeness, security & compliance
   /updateprd OR /apex-spec:updateprd        # Mark complete, update system
   ```

 4. **Between Phases**
   ```
   /audit OR /apex-spec:audit                # Local dev tooling (formatter, linter, types, tests, observability, hooks)
   /pipeline OR /apex-spec:pipeline          # CI/CD workflows (quality, build, security, integration, ops)
   /infra OR /apex-spec:infra                # Production infrastructure (health, security, backup, deploy)
   /carryforward OR /apex-spec:carryforward  # Lessons learned, security/compliance records
   /documents OR /apex-spec:documents        # Create, maintain project documentation
   -- Optional but recommended, do manual testing HERE --
   /phasebuild OR /apex-spec:phasebuild      # Set up next Phase and Phase's sessions
   ```

 5. **Repeat until all phases complete!**

## Features

- **12-Command Workflow**: Structured process from initialization to completion
- **Session Scoping**: Keep work manageable with 12-25 tasks per session
- **Progress Tracking**: State file and checklists track progress
- **Validation Gates**: Verify completeness, security & GDPR compliance before marking done
- **Coding Conventions**: Customizable standards enforced during implementation and validation
- **Auto-Activating Skill**: Provides workflow guidance automatically
- **Dev Tooling**: Regular code quality audits
- **Documentation Maintenance**: Keep project documentation up to date
- **ASCII Enforcement**: Avoid encoding issues that break code generation

## Plugin Components

### Commands (12 total)

| Command | Purpose |
|---------|---------|
| `/initspec` | Initialize spec system in current project |
| `/createprd` | Generate master PRD from requirements document |
| `/plansession` | Analyze project, create spec and task checklist |
| `/implement` | AI-led task-by-task implementation |
| `/validate` | Verify session completeness |
| `/updateprd` | Mark session complete, sync documentation |
| `/audit` | Local dev tooling (formatter, linter, types, tests, observability, hooks) |
| `/pipeline` | CI/CD workflows (quality, build, security, integration, ops) |
| `/infra` | Production infrastructure (health, security, backup, deploy) |
| `/documents` | Audit and update project documentation |
| `/carryforward` | Extract lessons learned, maintain security/compliance record between phases |
| `/phasebuild` | Create structure for new phase |

### Skill

The **spec-workflow** skill auto-activates when:
- Working in projects with `.spec_system/` directory
- User mentions spec system concepts
- User asks about session workflow

### Bundled Resources

- **scripts/**: Bash utilities for project analysis

## Project Structure

After running `/initspec`, your project will have:

```
your-project/
|-- .spec_system/               # All spec system files
|   |-- state.json              # Project state tracking
|   |-- CONSIDERATIONS.md       # Institutional memory (lessons learned)
|   |-- SECURITY-COMPLIANCE.md  # Security posture & GDPR compliance
|   |-- CONVENTIONS.md          # Project coding standards and conventions
|   |-- PRD/                    # Product requirements
|   |   |-- PRD.md              # Master PRD
|   |   \-- phase_00/           # Phase definitions
|   |-- specs/                  # Implementation specs
|   |   \-- phaseNN-sessionNN-name/
|   |       |-- spec.md
|   |       |-- tasks.md
|   |       |-- implementation-notes.md
|   |       |-- security-compliance.md
|   |       \-- validation.md
|   \-- archive/                # Completed work
\-- (your project source files)
```

## Session Scope

- Maximum 25 tasks per session
- Maximum 4 hours estimated time
- Single clear objective
- Ideal: 12-25 tasks (sweet spot: 20)

## ASCII Encoding (Non-Negotiable)

All files must use ASCII-only characters (0-127). No Unicode, emoji, or smart quotes.

## Video Tutorial

[Watch on YouTube](https://youtu.be/iY6ySesmOCg) - Installation and workflow walkthrough

## Documentation

- [Usage Guidance](docs/GUIDANCE.md) - When to use, workflow modes, team patterns
- [Production Walkthrough](docs/WALKTHROUGH.md) - Real-world example (79+ sessions, 16 phases)

## License

MIT License - Use freely in your projects.
