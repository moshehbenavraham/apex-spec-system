#!/usr/bin/env python3
# pylint: disable=too-many-lines
"""Apex Spec System Infinite CLI - Autonomous Claude Code session manager.

Replaces the n8n "Apex Spec System Infinite" workflow with a standalone
Python CLI using SQLite, subprocess, and terminal output.
"""

import json
import os
import re
import signal
import sqlite3
import subprocess
import sys
import time
from pathlib import Path

import click
import yaml
from dotenv import load_dotenv
from openai import OpenAI
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

DB_DIR = Path.home() / ".apex-infinite"
DB_PATH = DB_DIR / "history.db"

KNOWN_COMMANDS = {
    "initspec",
    "createprd",
    "createuxprd",
    "plansession",
    "implement",
    "validate",
    "updateprd",
    "audit",
    "pipeline",
    "infra",
    "carryforward",
    "documents",
    "phasebuild",
}

# n8n routes "implement" but the SSH node runs "/implementation"
COMMAND_ALIASES = {
    "implement": "implementation",
}

COMMAND_TIMEOUT = 1800  # 30 minutes
DEFAULT_MAX_ITERATIONS = 50
LLM_RETRY_COUNT = 3
LLM_RETRY_WAIT = 5  # seconds (matches n8n waitBetweenTries: 5000)

console = Console()

# ---------------------------------------------------------------------------
# System Prompts (verbatim from n8n JSON)
# ---------------------------------------------------------------------------

MANAGER_SYSTEM_PROMPT = r"""# Role

You are a **managing software engineer** -- the kind that obsesses over perfect project structure.  You approach implementation like a craftsperson: methodical, patient, and uncompromising on quality.  You specifically are managing an AI Coding Agent called 'Claude Code' which is acting as your Senior Developer.

# Input

Both:
- A summary of previous historical messages from CC and your responses.
OR
  -- The last message from Claude Code, your Senior Developer.
  -- Instructions from the CEO

# Your Senior Developer Claude Code

## Claude Code Commands

Claude Code is pre-armed with some powerful pre-built 'commands' which will make your managing responsibilities MUCH easier.  The details are below in section "Senior Developer's Commands".  Claude Code will give you suggestions on which command to run next to make your job even easier!  The one exception you wouldn't follow Claude Code's advice is if it mentions a problem that it didn't create or a "pre-existing issue".  A problem it didn't create and pre-existing issues are still problems, and in that case please see "## Issues" section.

## Issues

If Claude Code reports any issues, you should give high-level instructions to address the issue.  (Claude Code is -extremely- intelligent and doesn't need code snippets or examples, so you can instruct Claude Code concisely and high level.)  Example, Claude Code may respond in conclusion to a /validate session report there are two bugs.  You can simply instruct Claude Code to both fix the bugs, and then either rerun the command or run the next command.  Ex. "You may have not created the code that resulted in the warning / the issue may be pre-existing it, but we are responsible for fixing it.  Please fix the issue then rerun /X".  Claude Code has shell access and can handle most anything outside of SUDO commands... such as running snapshot updates, unit tests, installing/running pnpm, Github (Claude Code has gh ssh access), etc. in which case, it should just be given instructions to do that thing that blocked it; you will see in history whether its failing to do something more than once in which you would ask the CEO for help.

### Issues - Special Cases

If Claude Code reports the /pipeline command ran into billing issues, just move on to /infra instead of bugging the CEO

## CEO

If the CEO sends instructions, your job is simply to relay the instructions to Claude Code.

### Try Not to Bug CEO

This is supposed to be an autonomous system. You do not want to bug the User, who effectively you can consider the CEO.  Only bug the CEO if its necessary.  An example of a good reason to bug the CEO is if Claude Code tells you something needs to be installed with SUDO access.  In the case you need the CEO, your output should simply be "help". Do NOT bug the CEO for stuff like running python3, installing venv related packages, installing/running nppm, Github (Claude Code has gh ssh access), running unit tests, etc.  Only tasks that Claude Code TRULY cannot do, SUDO is the clearest example.

## All Done Baby!

Finally, it may be the case that Claude Code has completed everything and indicates there are no more sessions or phases remaining and the very last /audit, /pipeline, /infra, /documents and /carryover have been ran.  In that case, HUGE congratulations, you completed the project!  You can simply output "alldonebaby".

# Output

Your output MUST be in clean valid JSON format. Your output MUST be a single word command from the list below (without the /, example for /implement you'd simple output implement) OR the CEO's instructions as simple text OR the high-level instructions to Claude Code as simple text OR just "help" to get CEO intervention OR just "alldonebaby" if everything has been fully completed.  In addition, you should explain the reason for your output.  Examples of valid outputs:

{ "output": "tasks", "reason": "<explanation for output choice>" }
OR
{ "output": "run phasebuild", "reason": "The CEO sent me instructions and my job is to relay them straight to Claude Code our Senior Engineer."  }
OR
{ "output": "Fix the two bugs.", "reason": "<explanation for output choice>"  }
OR
{ "output": "carryforward", "reason": "<explanation for output choice>"  }
OR
{ "output": "help", "reason": "<explanation for output choice>"  }

# Senior Developer's Commands

---
---

  Claude Code Senior Developer - Command Reference

  Important rules:  When all sessions of a phase are completed, start phase transition with /audit

  The Senior Developer's workflow has 2 stages that loop: Sessions (a collection of Sessions are a Phase, loop to complete a Phase) -> [If any Phases remain] Phase Transition (prepare for a new set of Sessions)

```
Stage 1: SESSIONS WORKFLOW (Repeat until phase complete)

---

/plansession

Purpose: Plan, spec, and task-generate for the next session in one shot

Steps:
1. Run analyze-project.sh --json for state (phase, completed sessions, candidates)
2. Read PRD.md, candidate sessions, CONSIDERATIONS.md (Active Concerns, Lessons Learned), CONVENTIONS.md
3. Evaluate candidates by: prerequisites, dependencies, logical flow, MVP focus
4. Create NEXT_SESSION.md: recommendation, rationale, deliverables, alternatives
5. Create .spec_system/specs/phaseNN-sessionNN-name/
6. Generate spec.md (10 sections): Overview, Objectives, Prerequisites, Scope, Technical Approach, Deliverables, Success Criteria, Implementation Notes, Testing Strategy, Dependencies
7. Archive NEXT_SESSION.md to session directory
8. Generate tasks.md:
   - Progress table (Setup/Foundation/Implementation/Testing)
   - Tasks: - [ ] TNNN [SPPSS] [P] Action + what + where (path)
   - [P] marks parallelizable tasks
   - Completion checklist
9. Update state.json: set current_session, append next_session_history, status -> tasks_created
Rules:
- If phase complete, use /audit instead. Trust script JSON as ground truth.
- Max 25 tasks, max 4 hours, single objective (reject if exceeded)
- Task sweet spot: 20 tasks, ~20-25 min each

Categories: Setup (2-4), Foundation (4-8), Implementation (8-15), Testing (3-5)

Next: /implement

---

/implement

Purpose: AI-led task-by-task implementation

Steps:
1. Run analyze-project.sh --json for current session
2. Run check-prereqs.sh --json --env (STOP if fails); optionally --tools "tool1,tool2"
3. Read spec.md, tasks.md, CONVENTIONS.md
4. Create/update implementation-notes.md
5. Per task:
   - Implement per CLAUDE.md + CONVENTIONS.md
   - Mark - [ ] -> - [x] in tasks.md
   - Log: timestamps, notes, files changed
6. Document blockers and decisions
7. Checkpoint every 3-5 tasks

Rules: ASCII-only, LF endings, follow conventions, implement spec exactly (no extras)

Next: /validate

---
/validate

Purpose: Verify session completeness and quality gates

Steps:
1. Run analyze-project.sh --json for current session
2. Read spec.md, tasks.md, implementation-notes.md, CONVENTIONS.md
3. Run 6 checks:
   - A. Task completion (100% [x])
   - B. Deliverables exist (non-empty)
   - C. ASCII encoding (no non-ASCII, no CRLF)
   - D. Tests passing
   - E. Success criteria met
   - F. Conventions compliance
4. Generate validation.md: PASS/FAIL per check
5. Update state.json status -> validated or validation_failed

PASS: All checks pass. FAIL: Any issue -> resolve -> re-run /validate

Next: /updateprd (if PASS)

---
/updateprd

Purpose: Mark session complete, update docs, commit

Steps:
1. Verify validation.md shows PASS
2. Update state.json: add to completed_sessions[], clear current_session, mark history completed
3. Update phase PRD: mark session Complete
4. Create IMPLEMENTATION_SUMMARY.md: overview, deliverables, decisions, tests, lessons, future, stats
5. If last session: archive phase to archive/phases/, update master PRD
6. Increment version (patch) in package.json/pyproject.toml/Cargo.toml/etc.
7. Commit and push (no co-authors)

Commit format: Complete phaseNN-sessionNN-name: [description] + deliverables

Next: /plansession (if phase incomplete) or /audit (if phase complete)

---
Stage 2: PHASE TRANSITION

---
/audit

Purpose: Add/validate local dev tooling, one bundle at a time

Steps:
1. DETECT: Read CONVENTIONS.md, known-issues.md, check git status
2. COMPARE: Check 5 bundles against master list
3. SELECT: Pick highest-priority missing bundle
4. IMPLEMENT: Install tool + generate config
5. VALIDATE: Run ALL tools (formatter -> linter -> types -> tests -> hooks)
6. FIX: Auto-fix; revert if syntax breaks after 2 retries
7. RECORD: Update CONVENTIONS.md Local Dev Tools table
8. REPORT: Summary of additions, fixes, remaining issues
9. RECOMMEND: Rerun /audit or proceed to /pipeline

Bundles (priority): Formatting -> Linting -> Type Safety -> Testing -> Git Hooks

Flags: --dry-run, --skip-install, --verbose

Rules: One bundle per run. Never break syntax (revert after 2 failures).

When: After phase complete, before /pipeline

---
/pipeline

Purpose: Add/validate CI/CD workflows, one bundle at a time

Steps:
1. DETECT: Read CONVENTIONS.md, detect CI platform, check PRs with issues
2. COMPARE: Check 5 bundles against master list
3. SELECT: Pick highest-priority missing bundle
4. IMPLEMENT: Generate workflow YAML, commit, push
5. VALIDATE: Poll CI (3 min timeout), check PR status
6. FIX: Parse CI logs, fix errors, address PR review comments
7. RECORD: Update CONVENTIONS.md CI/CD table
8. REPORT: Summary of workflows, fixes, CI/PR status
9. RECOMMEND: Fix issues, merge PR, or proceed to /infra

Bundles (priority): Code Quality -> Build & Test -> Security -> Integration -> Operations

Flags: --dry-run, --skip-install, --verbose, --pr <number>

Rules: One bundle per run. PR-aware: fixes CI failures AND review comments. Documents secrets (never creates them).

When: After /audit, before /infra

---
/infra

Purpose: Add/validate production infrastructure, one bundle at a time

Steps:
1. DETECT: Read CONVENTIONS.md Infrastructure table, detect platform (Cloudflare/Coolify/Vercel/Fly.io/etc.)
2. COMPARE: Check 4 bundles against master list
3. SELECT: Pick highest-priority missing bundle
4. IMPLEMENT: Add platform-specific config/code
5. VALIDATE: Verify (curl /health, test rate limiting, check backups, trigger deploy)
6. FIX: Address validation failures
7. RECORD: Update CONVENTIONS.md Infrastructure table
8. REPORT: Summary of infra, validation results, manual steps
9. RECOMMEND: Fix issues or proceed to /documents

Bundles (priority): Health -> Security -> Backup -> Deploy

Flags: --dry-run, --skip-install, --verbose

Rules: One bundle per run. Stack-agnostic. Documents manual steps/env vars (never creates secrets).

When: After /pipeline, before /documents

---
/carryforward

Purpose: Extract lessons learned, update CONSIDERATIONS.md between phases

Steps:
1. Verify phase complete in state.json
2. Read all IMPLEMENTATION_SUMMARY.md from completed phase
3. Extract:
   - Active Concerns: Tech debt, external deps, performance/security, architecture
   - Lessons Learned: What worked, what to avoid, tool notes
   - Resolved: Previous concerns addressed
4. Update .spec_system/CONSIDERATIONS.md: add new, remove resolved, merge similar
   - Limits: 20 Active Concerns, 30 Lessons Learned, 15 Resolved
5. Enforce 600-line limit (trim oldest/least relevant)

Format: Tag items with [P##] for traceability

When: After phase complete, after /audit, before /documents. Recommended for all phases.

---
/documents

Purpose: Create/maintain project documentation

Steps:
1. Run analyze-project.sh --json
2. Determine scope:
   - Phase-Focused: Prioritize changes from just-completed phase
   - Full Audit: Initial setup, milestones, or explicit request
3. Audit standard files:
   - Root: README.md, CONTRIBUTING.md, LICENSE
   - docs/: ARCHITECTURE.md, CODEOWNERS, onboarding.md, development.md, environments.md, deployment.md, adr/, runbooks/, api/
   - Per-package: README_<dirname>.md (not README.md)
4. Create missing files from templates (.spec_system/doc-templates/ first)
5. Update existing docs to current state
6. Generate docs-audit.md report

Naming: Only root gets README.md; subdirs use README_<dirname>.md

Principle: Current over complete -- small accurate doc beats comprehensive stale one

When: After /carryforward, before /phasebuild. Recommended for all phases.

---
/phasebuild

Purpose: Create structure for new phase with session stubs (last transition step)

Steps:
1. Read state.json and PRD for next phase number
2. Read CONSIDERATIONS.md for lessons to apply
3. Create PRD/phase_NN/ directory
4. Create PRD_phase_NN.md (phase tracker with progress table)
5. Create session stubs (session_NN_name.md): objectives, scope, deliverables
6. Update state.json with new phase
7. Update master PRD.md phases table

Stub format: Objective, scope (in/out), prerequisites, deliverables, success criteria

Guidelines: 4-8 sessions typical, 12-25 tasks each, 2-4 hours each

Next: /plansession

---
Quick Reference

| Command       | Stage      | Input                  | Output                              |
|---------------|------------|------------------------|-------------------------------------|
| /plansession  | Sessions   | State, PRD, candidates | NEXT_SESSION.md spec.md tasks.md |
| /implement    | Sessions   | spec.md, tasks.md      | Code + implementation-notes.md      |
| /validate     | Sessions   | All session files      | validation.md                       |
| /updateprd    | Sessions   | validation.md          | Summary, commit, push, version bump |
| /audit        | Transition | Codebase               | Local dev tooling, report           |
| /pipeline     | Transition | Codebase               | CI/CD workflows, report             |
| /infra        | Transition | Codebase               | Infrastructure, report              |
| /carryforward | Transition | Phase artifacts        | Updated CONSIDERATIONS.md           |
| /documents    | Transition | State, PRD, codebase   | Updated docs                        |
| /phasebuild   | Transition | PRD, state             | Phase dir + session stubs           |
```

---
---
"""

SUMMARIZER_SYSTEM_PROMPT = """# Role

You are a **master tech agent/managing coding agent response/decision summarizer** -- the kind that obsesses over perfection.  You approach summarizing like a craftsperson: methodical, patient, and uncompromising on quality.

# Input

Between 0 to 15 aggregated records in newest to oldest of responses between a Senior Developer and their Manager.

# Output

A concise summary that does not leave out important details in plain text.  Maximum 2000 characters.  No preamble. No conclusion. No meta-commentary. Output only the summary.
"""

# ---------------------------------------------------------------------------
# Signal handling
# ---------------------------------------------------------------------------

_INTERRUPTED = False


def _handle_sigint(_sig, _frame):
    global _INTERRUPTED  # pylint: disable=global-statement
    if _INTERRUPTED:
        console.print("\n[bold red]Force quit.[/bold red]")
        sys.exit(1)
    _INTERRUPTED = True
    console.print(
        "\n[bold yellow][CEO INTERRUPT] Will pause after current step...[/bold yellow]"
    )


signal.signal(signal.SIGINT, _handle_sigint)

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------


def load_config(config_path, provider_override=None, model_override=None):
    """Load YAML config, apply overrides, expand env vars in api_key."""
    path = Path(config_path)
    if not path.exists():
        console.print(f"[red]Config file not found: {config_path}[/red]")
        sys.exit(1)

    with open(path, encoding="utf-8") as f:
        config = yaml.safe_load(f)

    if provider_override:
        config["provider"] = provider_override

    provider_name = config["provider"]
    if provider_name not in config["providers"]:
        console.print(f"[red]Unknown provider: {provider_name}[/red]")
        sys.exit(1)

    # Load .env from same directory as config file
    load_dotenv(path.parent / ".env")

    # Expand env vars in api_key
    provider_cfg = config["providers"][provider_name]
    provider_cfg["api_key"] = os.path.expandvars(provider_cfg["api_key"])

    if model_override:
        provider_cfg["model"] = model_override

    return config


def get_llm_client(config):
    """Create OpenAI client from active provider config. Returns (client, model)."""
    provider = config["providers"][config["provider"]]
    return (
        OpenAI(base_url=provider["base_url"], api_key=provider["api_key"]),
        provider["model"],
    )


# ---------------------------------------------------------------------------
# Database layer
# ---------------------------------------------------------------------------


def db_init():
    """Create database directory and tables."""
    DB_DIR.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(str(DB_PATH))
    conn.execute("PRAGMA journal_mode=WAL")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT NOT NULL,
            cc_response TEXT,
            ai_decision_output TEXT,
            ai_decision_reason TEXT,
            help_or_done_msg TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.execute("""
        CREATE INDEX IF NOT EXISTS idx_path_created
        ON history(path, created_at DESC)
    """)
    conn.commit()
    conn.close()


def db_fetch_history(path, limit=15):
    """Fetch last N history records for a project path."""
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        "SELECT * FROM history WHERE path = ? ORDER BY created_at DESC LIMIT ?",
        (path, limit),
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


def db_log(path, cc_response, ai_output, ai_reason, help_or_done_msg=None):
    """Log an iteration to the database."""
    conn = sqlite3.connect(str(DB_PATH))
    conn.execute(
        """INSERT INTO history (path, cc_response, ai_decision_output,
           ai_decision_reason, help_or_done_msg)
           VALUES (?, ?, ?, ?, ?)""",
        (path, cc_response, ai_output, ai_reason, help_or_done_msg),
    )
    conn.commit()
    conn.close()


def db_show_history(path=None):
    """Display history records as a Rich table."""
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row

    if path:
        rows = conn.execute(
            "SELECT * FROM history WHERE path = ? ORDER BY created_at DESC LIMIT 50",
            (path,),
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT * FROM history ORDER BY created_at DESC LIMIT 50"
        ).fetchall()
    conn.close()

    if not rows:
        console.print("[dim]No history records found.[/dim]")
        return

    table = Table(title="Apex Infinite - History", show_lines=True)
    table.add_column("ID", style="dim", width=5)
    table.add_column("Path", style="cyan", max_width=30)
    table.add_column("AI Output", style="green", max_width=20)
    table.add_column("AI Reason", max_width=40)
    table.add_column("CC Response", max_width=40)
    table.add_column("Help/Done", style="yellow", max_width=20)
    table.add_column("Time", style="dim", width=19)

    for row in rows:
        row = dict(row)
        cc_resp = (row["cc_response"] or "")[:80]
        if len(row.get("cc_response") or "") > 80:
            cc_resp += "..."
        table.add_row(
            str(row["id"]),
            row["path"],
            row["ai_decision_output"] or "",
            (row["ai_decision_reason"] or "")[:80],
            cc_resp,
            row["help_or_done_msg"] or "",
            row["created_at"] or "",
        )

    console.print(table)


# ---------------------------------------------------------------------------
# LLM functions
# ---------------------------------------------------------------------------


def aggregate_history(records):
    """Replicate n8n 'Aggregate Results' JS node.

    Format: [Task N: name]\nAgent: cc_response\nManager: ai_decision
    """
    parts = []
    for i, rec in enumerate(records, 1):
        name = f"{rec.get('path', 'unknown')}_{rec.get('id', i)}"
        cc = rec.get("cc_response", "") or ""
        decision = (
            f"Manger - Output: {rec.get('ai_decision_output', '')} "
            f"| Reason: {rec.get('ai_decision_reason', '')}"
        )
        parts.append(f"[Task {i}: {name}]\nAgent: {cc}\nManager: {decision}")
    return "\n\n".join(parts)


def _llm_call_with_retry(client, model, messages, json_mode=False):
    """Call LLM with retry logic matching n8n retryOnFail + waitBetweenTries: 5000."""
    kwargs = {"model": model, "messages": messages}
    if json_mode:
        kwargs["response_format"] = {"type": "json_object"}

    last_error = None
    for attempt in range(1, LLM_RETRY_COUNT + 1):
        try:
            response = client.chat.completions.create(**kwargs)
            return response.choices[0].message.content
        except Exception as e:  # pylint: disable=broad-exception-caught
            last_error = e
            if attempt < LLM_RETRY_COUNT:
                console.print(
                    f"  [yellow]LLM call failed (attempt {attempt}/{LLM_RETRY_COUNT}): {e}[/yellow]"
                )
                console.print(f"  [dim]Retrying in {LLM_RETRY_WAIT}s...[/dim]")
                time.sleep(LLM_RETRY_WAIT)
            else:
                console.print(
                    f"  [red]LLM call failed after {LLM_RETRY_COUNT} attempts: {e}[/red]"
                )
                raise last_error from e
    return None


def llm_summarize(client, model, records):
    """Summarize history records via LLM. Matches n8n 'Summarize History' node."""
    if not records:
        return "No prior interaction history."

    aggregated = aggregate_history(records)
    # Exact n8n user message template
    user_msg = f"INPUT:\n{aggregated}"

    messages = [
        {"role": "system", "content": SUMMARIZER_SYSTEM_PROMPT},
        {"role": "user", "content": user_msg},
    ]

    return _llm_call_with_retry(client, model, messages)


def llm_manager_decide(client, model, cc_response, ceo_msg, summary):
    """Get manager LLM decision. Matches n8n 'LLM Generate Response' node."""
    # Exact n8n user message template
    user_msg = (
        f"IF EXISTS, CLAUDE CODE SENIOR DEVELOPER LATEST MESSAGE:\n{cc_response}\n\n"
        f"IF EXISTS, CEO'S INSTRUCTIONS:\n{ceo_msg}\n\n"
        f"HISTORICAL INTERACTIONS SUMMARY:\n{summary}"
    )

    messages = [
        {"role": "system", "content": MANAGER_SYSTEM_PROMPT},
        {"role": "user", "content": user_msg},
    ]

    # Try JSON mode first, fall back to regex extraction
    try:
        raw = _llm_call_with_retry(client, model, messages, json_mode=True)
        result = json.loads(raw)
        if "output" in result and "reason" in result:
            return result
    except (json.JSONDecodeError, Exception):  # pylint: disable=broad-exception-caught
        pass

    # Fallback: try without json_mode and parse with regex
    try:
        raw = _llm_call_with_retry(client, model, messages, json_mode=False)
        # Try to extract JSON from the response
        json_match = re.search(
            r'\{[^{}]*"output"\s*:\s*"[^"]*"[^{}]*"reason"\s*:\s*"[^"]*"[^{}]*\}', raw
        )
        if json_match:
            return json.loads(json_match.group())
        # Last resort: try to parse the whole response as JSON
        return json.loads(raw)
    except (json.JSONDecodeError, Exception):  # pylint: disable=broad-exception-caught
        # Absolute fallback
        console.print(
            "  [yellow]Could not parse LLM response as JSON, using raw output[/yellow]"
        )
        return {"output": raw.strip(), "reason": "Raw LLM output (JSON parse failed)"}


# ---------------------------------------------------------------------------
# Command execution
# ---------------------------------------------------------------------------


def build_claude_prompt(output_cmd, raw_output):
    """Build the claude -p prompt string.

    Known commands: ULTRATHINK - activate plugin skill apex-spec -- .../cmd
    Custom: ULTRATHINK - {raw output}
    """
    cmd_lower = output_cmd.strip().lower().lstrip("/")

    if cmd_lower in KNOWN_COMMANDS:
        actual_cmd = COMMAND_ALIASES.get(cmd_lower, cmd_lower)
        return (
            f"ULTRATHINK - activate plugin skill apex-spec -- "
            f"after activating the plugin skill run command /{actual_cmd}"
        )
    # CUSTOM-INSTRUCTIONS fallback (exact n8n pattern)
    return f"ULTRATHINK - {raw_output}"


def execute_claude(path, prompt, dry_run=False, verbose=False):
    """Run claude subprocess in project directory. Returns stdout."""
    expanded_path = os.path.expanduser(path)

    if dry_run:
        console.print(f"  [dim][DRY RUN] Would execute in {expanded_path}:[/dim]")
        console.print(
            f'  [dim]claude -p "{prompt}" --dangerously-skip-permissions[/dim]'
        )
        return f"[DRY RUN] Command: {prompt}"

    console.print(f"  [dim]Executing claude in {expanded_path}...[/dim]")

    try:
        # Clear CLAUDECODE env var to allow nested sessions
        env = os.environ.copy()
        env.pop("CLAUDECODE", None)

        result = subprocess.run(
            ["claude", "-p", prompt, "--dangerously-skip-permissions"],
            cwd=expanded_path,
            capture_output=True,
            text=True,
            timeout=COMMAND_TIMEOUT,
            env=env,
            check=False,
        )

        output = result.stdout
        # If stdout is empty, use stderr (claude -p sometimes outputs there)
        if not output.strip() and result.stderr.strip():
            output = result.stderr

        if result.returncode != 0:
            error_msg = result.stderr or "Unknown error"
            output = f"[ERROR exit code {result.returncode}]\nstdout: {result.stdout}\nstderr: {error_msg}"
            console.print(f"  [red]Claude exited with code {result.returncode}[/red]")

        if verbose:
            console.print(
                Panel(output[:2000], title="CC Response (full)", border_style="blue")
            )
        else:
            truncated = output[:500]
            if len(output) > 500:
                truncated += (
                    f"\n... ({len(output)} chars total, use --verbose for full)"
                )
            console.print(Panel(truncated, title="CC Response", border_style="blue"))

        return output

    except subprocess.TimeoutExpired:
        msg = f"[TIMEOUT] Claude command timed out after {COMMAND_TIMEOUT}s"
        console.print(f"  [red]{msg}[/red]")
        return msg
    except FileNotFoundError:
        msg = "[ERROR] 'claude' command not found. Is Claude Code CLI installed?"
        console.print(f"  [red]{msg}[/red]")
        return msg
    except Exception as e:  # pylint: disable=broad-exception-caught
        msg = f"[ERROR] Failed to execute claude: {e}"
        console.print(f"  [red]{msg}[/red]")
        return msg


# ---------------------------------------------------------------------------
# Notifications
# ---------------------------------------------------------------------------


def notify(title, message):
    """Terminal bell + desktop notification."""
    # Terminal bell
    sys.stdout.write("\a")
    sys.stdout.flush()

    # Linux desktop notification
    try:
        subprocess.run(
            ["notify-send", title, message],
            capture_output=True,
            timeout=5,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass


# ---------------------------------------------------------------------------
# Main loop
# ---------------------------------------------------------------------------


def infinite_loop(  # pylint: disable=too-many-positional-arguments,too-many-statements
    path,
    config,
    start_command=None,
    ceo_message="",
    max_iterations=DEFAULT_MAX_ITERATIONS,
    dry_run=False,
    verbose=False,
):
    """The main autonomous loop replacing n8n webhook->LLM->SSH->webhook cycle."""
    global _INTERRUPTED  # pylint: disable=global-statement

    client, model = get_llm_client(config)
    cc_response = ""
    ceo_msg = ceo_message or ""
    iteration = 0

    while iteration < max_iterations:
        iteration += 1

        # Check interrupt flag
        if _INTERRUPTED:
            _INTERRUPTED = False
            console.print("\n[bold yellow]--- CEO INTERRUPT ---[/bold yellow]")
            notify("Apex Infinite", "CEO interrupt - input requested")
            ceo_input = console.input("[bold]CEO instructions (or 'quit'): [/bold]")
            if ceo_input.strip().lower() == "quit":
                console.print("[bold red]Quitting by CEO request.[/bold red]")
                break
            ceo_msg = ceo_input

        # Banner
        console.print(f"\n[bold]{'=' * 60}[/bold]")
        console.print(f"  [bold cyan]ITERATION {iteration}[/bold cyan]")
        console.print(f"[bold]{'=' * 60}[/bold]")

        # 1. Fetch + summarize history
        records = db_fetch_history(path, limit=15)
        console.print(f"  Summarizing history... ({len(records)} prior records)")
        summary = llm_summarize(client, model, records)

        # 2. Manager LLM decides next action
        if start_command and iteration == 1:
            decision = {
                "output": start_command,
                "reason": "User-specified start command",
            }
        else:
            console.print("  Manager deciding next action...")
            decision = llm_manager_decide(client, model, cc_response, ceo_msg, summary)

        output_val = decision.get("output", "").strip()
        reason_val = decision.get("reason", "")

        console.print(f"  [bold green]Manager Decision:[/bold green] {output_val}")
        console.print(f"  [dim]Reason: {reason_val}[/dim]")

        # 3. Route on decision
        # Strip leading slash - LLM sometimes outputs "/plansession" instead of "plansession"
        output_lower = output_val.lower().lstrip("/")

        if output_lower == "help":
            console.print("\n[bold yellow]*** MANAGER NEEDS CEO HELP ***[/bold yellow]")
            console.print(f"[yellow]Reason: {reason_val}[/yellow]")
            notify("Apex Infinite - HELP", reason_val)
            db_log(
                path, cc_response, output_val, reason_val, help_or_done_msg=reason_val
            )
            ceo_input = console.input("[bold]CEO response (or 'quit'): [/bold]")
            if ceo_input.strip().lower() == "quit":
                break
            ceo_msg = ceo_input
            continue

        if output_lower == "alldonebaby":
            console.print("\n[bold green]*** PROJECT COMPLETE! ***[/bold green]")
            console.print(f"[green]Reason: {reason_val}[/green]")
            notify("Apex Infinite - ALL DONE!", "Project complete!")
            db_log(
                path,
                cc_response,
                output_val,
                reason_val,
                help_or_done_msg="ALL DONE BABY!",
            )
            console.print(f"\n[bold]Total iterations: {iteration}[/bold]")
            break

        # 4. Build prompt and execute claude
        prompt = build_claude_prompt(output_lower, output_val)
        console.print(f"  [dim]Prompt: {prompt[:100]}...[/dim]")

        cc_response = execute_claude(path, prompt, dry_run=dry_run, verbose=verbose)

        # 5. Log to DB
        db_log(path, cc_response, output_val, reason_val)

        # 6. Clear CEO message after first use
        ceo_msg = ""

    else:
        console.print(
            f"\n[bold yellow]Reached max iterations ({max_iterations}). Stopping.[/bold yellow]"
        )
        notify("Apex Infinite", f"Reached max iterations ({max_iterations})")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------


@click.command()
@click.option(
    "--path", "project_path", default=None, help="Project path (prompted if not given)"
)
@click.option("--start", default=None, help='Starting command (e.g. "plansession")')
@click.option("--ceo", default=None, help="Initial CEO instructions")
@click.option(
    "--provider", default=None, help="LLM provider override: ollama|grok|openai"
)
@click.option("--model", default=None, help="Model override")
@click.option(
    "--config",
    "config_path",
    default=None,
    help="Config file path (default: ./config.yaml)",
)
@click.option("--history", is_flag=True, help="Show interaction history")
@click.option(
    "--max-iterations",
    default=DEFAULT_MAX_ITERATIONS,
    type=int,
    help=f"Safety limit (default: {DEFAULT_MAX_ITERATIONS})",
)
@click.option(
    "--dry-run", is_flag=True, help="Show what would execute without running claude"
)
@click.option("--verbose", is_flag=True, help="Show full CC output")
@click.version_option(version="1.0.0", prog_name="apex-infinite")
def main(  # pylint: disable=too-many-arguments,too-many-positional-arguments,too-many-locals,too-many-branches,too-many-statements
    project_path,
    start,
    ceo,
    provider,
    model,
    config_path,
    history,
    max_iterations,
    dry_run,
    verbose,
):
    """Apex Spec System Infinite CLI - Autonomous Claude Code session manager."""

    # Init database
    db_init()

    # Resolve config path
    if config_path is None:
        # Look next to the script first, then cwd
        script_dir = Path(__file__).parent
        if (script_dir / "config.yaml").exists():
            config_path = str(script_dir / "config.yaml")
        elif Path("config.yaml").exists():
            config_path = "config.yaml"
        else:
            console.print(
                "[red]No config.yaml found. Use --config to specify path.[/red]"
            )
            sys.exit(1)

    config = load_config(config_path, provider_override=provider, model_override=model)

    # History mode
    if history:
        db_show_history(project_path)
        return

    # Interactive mode if no path given
    if not project_path:
        console.print(
            Panel(
                "[bold]Apex Spec System Infinite CLI[/bold]",
                border_style="cyan",
            )
        )

        # List ~/projects/ directories
        projects_dir = Path.home() / "projects"
        if projects_dir.exists():
            dirs = sorted(
                [
                    d
                    for d in projects_dir.iterdir()
                    if d.is_dir() and not d.name.startswith(".")
                ]
            )
            console.print("\n[bold]Available projects:[/bold]")
            for i, d in enumerate(dirs, 1):
                console.print(f"  {i}. ~/{d.relative_to(Path.home())}/")
            console.print()

            selection = console.input(
                "[bold]Select project [number or path]: [/bold]"
            ).strip()
            if selection.isdigit():
                idx = int(selection) - 1
                if 0 <= idx < len(dirs):
                    project_path = str(dirs[idx])
                else:
                    console.print("[red]Invalid selection.[/red]")
                    sys.exit(1)
            else:
                project_path = selection
        else:
            project_path = console.input("[bold]Project path: [/bold]").strip()

        if not start:
            start_input = console.input(
                '[bold]Starting command (e.g. "plansession", Enter for auto): [/bold]'
            ).strip()
            if start_input:
                start = start_input

        if not ceo:
            ceo_input = console.input(
                "[bold]CEO instructions (optional, Enter to skip): [/bold]"
            ).strip()
            if ceo_input:
                ceo = ceo_input

    # Expand and validate path
    project_path = os.path.expanduser(project_path)
    if not os.path.isdir(project_path):
        console.print(f"[red]Directory not found: {project_path}[/red]")
        sys.exit(1)

    # Normalize path (remove trailing slash for consistent DB keys)
    project_path = project_path.rstrip("/") + "/"

    # Display startup banner
    provider_name = config["provider"]
    model_name = config["providers"][provider_name]["model"]

    banner_text = (
        f"[bold]Provider:[/bold] {provider_name} ({model_name})\n"
        f"[bold]Project:[/bold] {project_path}\n"
        f"[bold]Max iterations:[/bold] {max_iterations}"
    )
    if start:
        banner_text += f"\n[bold]Start command:[/bold] {start}"
    if ceo:
        banner_text += f"\n[bold]CEO instructions:[/bold] {ceo}"
    if dry_run:
        banner_text += "\n[bold yellow]DRY RUN MODE[/bold yellow]"

    console.print(
        Panel(
            banner_text,
            title="[bold cyan]Apex Spec System Infinite CLI[/bold cyan]",
            border_style="cyan",
        )
    )

    # Run the loop
    infinite_loop(
        path=project_path,
        config=config,
        start_command=start,
        ceo_message=ceo or "",
        max_iterations=max_iterations,
        dry_run=dry_run,
        verbose=verbose,
    )


if __name__ == "__main__":
    main()  # pylint: disable=no-value-for-parameter
