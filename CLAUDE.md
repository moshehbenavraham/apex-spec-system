# Apex Spec System - Claude Code Plugin Skill

## A specification-driven workflow system for AI-assisted development.

Philosophy: 1 session = 1 spec = 2-4 hours (12-25 tasks)

## When updating version, update it in all the following files:

README.md
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
skills/spec-workflow/SKILL.md

## Apex Infinite CLI

`apex-infinite-cli/` contains a standalone Python CLI that autonomously runs the full Apex Spec System workflow in an infinite loop -- a manager LLM decides which command to run next, executes Claude Code, logs the result, and repeats until the project is complete. Replaces the n8n "Apex Spec System Infinite" workflow. See `apex-infinite-cli/README-apex-infinite-cli.md`.

# Details - See @skills/spec-workflow/SKILL.md
