# Templates Reference

This directory contains document templates used by the spec system commands.

## Template Files

| Template | Purpose | Used By |
|----------|---------|---------|
| `nextsession-template.md` | Session recommendation format | `/nextsession` |
| `sessionspec-template.md` | Formal specification format | `/sessionspec` |
| `tasks-template.md` | Task checklist format | `/tasks` |
| `implementation-notes-template.md` | Progress logging format | `/implement` |
| `validation-template.md` | Validation report format | `/validate` |
| `prd-phase-template.md` | Phase PRD format | `/phasebuild` |
| `phase-readme-template.md` | Phase progress tracking | `/phasebuild` |
| `session-stub-template.md` | Session definition stub | `/phasebuild` |

## Placeholder Syntax

Templates use `{{PLACEHOLDER}}` syntax for variable substitution:

```markdown
**Session ID**: `{{SESSION_ID}}`
**Phase**: {{PHASE_NUM}} - {{PHASE_NAME}}
```

## Common Placeholders

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{{SESSION_ID}}` | Full session identifier | `phase01-session03-auth` |
| `{{PHASE_NUM}}` | Zero-padded phase number | `01` |
| `{{PHASE_NAME}}` | Phase display name | `Foundation` |
| `{{SESSION_REF}}` | Short session reference | `S0103` |
| `{{DATE}}` | Current date | `2025-01-15` |
| `{{TASK_COUNT}}` | Number of tasks | `22` |
| `{{DURATION}}` | Estimated hours | `2-3` |

## Customization

Templates can be customized for your project:

1. Copy template to modify
2. Adjust sections as needed
3. Add project-specific placeholders
4. Keep ASCII-only content

## Best Practices

- Keep templates ASCII-only (no Unicode)
- Use consistent placeholder naming
- Include all required sections
- Add helpful comments/notes
- Test templates with commands
