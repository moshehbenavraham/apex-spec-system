# Apex Spec System v0.7.0-alpha

**Release Date:** December 2024
**Status:** Pre-release (Alpha)

## Overview

This release converts the Apex Spec System from a standalone workflow system into a **Claude Code plugin**, enabling seamless integration with Claude Code's plugin ecosystem.

## What's New

### Claude Code Plugin Architecture

- **Plugin manifest** (`.claude-plugin/plugin.json`) for Claude Code integration
- **Marketplace support** (`.claude-plugin/marketplace.json`) for easy distribution
- **Auto-activating skill** that provides workflow guidance when working with spec system projects

### 8 Slash Commands

| Command | Description |
|---------|-------------|
| `/init` | **NEW** - Initialize spec system in any project |
| `/nextsession` | Analyze project and recommend next session |
| `/sessionspec` | Create formal technical specification |
| `/tasks` | Generate 15-30 task checklist |
| `/implement` | AI-guided task-by-task implementation |
| `/validate` | Verify session completeness |
| `/updateprd` | Mark session complete, sync documentation |
| `/phasebuild` | Create structure for new phase |

### Bundled Resources

- **8 document templates** for specs, tasks, validation reports
- **4 bash utility scripts** for project analysis and setup
- **Skill references** with detailed workflow documentation

## Breaking Changes

- Removed `.spec_system/` directory structure
- Project files (PRD/, specs/, state.json) now created via `/init` command
- Commands now prefixed with `apex-spec:` when installed as plugin

## Installation

```bash
# Add marketplace
/plugin marketplace add moshehbenavraham/apex-spec-system

# Install plugin
/plugin install apex-spec
```

Or install directly:
```bash
claude --plugin-dir /path/to/apex-spec-system
```

## Quick Start

1. Install the plugin
2. Navigate to your project
3. Run `/apex-spec:init` to set up the spec system
4. Run `/apex-spec:nextsession` to get your first session recommendation

## Migration from Previous Versions

If you have an existing project using the old `.spec_system/` structure:

1. Install the plugin
2. Move your `state.json` to project root
3. Move `PRD/` directory to project root
4. Delete `.spec_system/` directory
5. Continue using workflow commands as before

## Known Limitations

- Alpha release - API may change
- Skill auto-activation requires `state.json` or `specs/` directory presence
- Templates and scripts bundled with plugin, not copied to project by default

## Repository

- **Main branch:** Claude Code plugin version
- **base-spec-system branch:** Original standalone version (preserved)

## Feedback

Report issues at: https://github.com/moshehbenavraham/apex-spec-system/issues
