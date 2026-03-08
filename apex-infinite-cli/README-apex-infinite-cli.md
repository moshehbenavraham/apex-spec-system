# Apex Infinite CLI

Autonomous Claude Code session manager -- a standalone Python CLI that runs the full Apex Spec System workflow in an infinite loop without human intervention.

Originally powered by an n8n workflow with Airtable, Slack, and SSH nodes, this CLI replaces all of that with SQLite, subprocess, and terminal output in a single ~1000-line Python file.

## How It Works

```
             +------------------+
             |   Manager LLM    |
             | (decides next    |
             |  command)        |
             +--------+---------+
                      |
          +-----------v-----------+
          |                       |
     +----v----+           +------v------+
     |  Claude |           |   History   |
     |  Code   |           |  (SQLite)   |
     | (Senior |           |  Last 15    |
     |  Dev)   |           |  records    |
     +----+----+           +------+------+
          |                       ^
          +-----------+-----------+
                      |
              (loop until done)
```

1. **Fetch history** -- Last 15 interactions from SQLite
2. **Summarize** -- LLM condenses history to <2000 chars
3. **Decide** -- Manager LLM picks the next command (plansession, implement, validate, etc.)
4. **Execute** -- Runs `claude -p` with the chosen command in your project directory
5. **Log** -- Records the interaction
6. **Repeat** -- Until `alldonebaby` or max iterations reached

The manager LLM can also output `help` to pause for CEO (human) input, or give custom instructions to Claude Code for edge cases.

## Supported Commands

All 13 Apex Spec commands are recognized and routed through the plugin activation prompt:

| Stage | Commands |
|-------|----------|
| Initialization | `initspec`, `createprd`, `createuxprd` |
| Session workflow | `plansession`, `implement`, `validate`, `updateprd` |
| Phase transition | `audit`, `pipeline`, `infra`, `carryforward`, `documents`, `phasebuild` |
| Terminal | `help` (pauses for CEO input), `alldonebaby` (stops loop) |

Any output not matching a known command is sent as custom instructions via the `ULTRATHINK - {raw output}` fallback, allowing the manager LLM to give ad-hoc instructions to Claude Code (e.g., "Fix the two failing tests then rerun /validate").

## Install

```bash
cd apex-infinite-cli
pip install -r requirements.txt
```

## Configuration

Edit `config.yaml` to choose your LLM provider:

```yaml
provider: grok  # ollama | grok | openai

providers:
  ollama:
    base_url: "http://localhost:11434/v1"
    api_key: "ollama"
    model: "llama3.1:70b"

  grok:
    base_url: "https://api.x.ai/v1"
    api_key: "${XAI_API_KEY}"       # Set this env var
    model: "grok-4-1-fast-reasoning"

  openai:
    base_url: "https://api.openai.com/v1"
    api_key: "${OPENAI_API_KEY}"    # Set this env var
    model: "gpt-4o"
```

API keys use `${ENV_VAR}` syntax, expanded at runtime.

## Usage

```bash
# Interactive mode -- prompts for project selection
python apex_infinite.py

# Direct mode
python apex_infinite.py --path ~/projects/my-app/ --start plansession

# With CEO instructions
python apex_infinite.py --path ~/projects/my-app/ --start plansession --ceo "focus on auth first"

# Dry run -- see LLM decisions without executing claude
python apex_infinite.py --path ~/projects/my-app/ --start plansession --dry-run

# View history
python apex_infinite.py --history
python apex_infinite.py --history --path ~/projects/my-app/

# Override provider/model
python apex_infinite.py --path ~/projects/my-app/ --provider ollama --model "qwen2.5:72b"

# Limit iterations
python apex_infinite.py --path ~/projects/my-app/ --start plansession --max-iterations 5
```

## Options

```
--path TEXT               Project path (prompted if not given)
--start TEXT              Starting command (e.g. "plansession")
--ceo TEXT                Initial CEO instructions
--provider TEXT           LLM provider override: ollama|grok|openai
--model TEXT              Model override
--config TEXT             Config file path (default: ./config.yaml)
--history                 Show interaction history
--max-iterations INTEGER  Safety limit (default: 50)
--dry-run                 Show what would execute without running claude
--verbose                 Show full CC output
--version                 Show version
```

## CEO Intervention

Two ways to inject human guidance:

- **`help` pause** -- When the manager LLM outputs `help`, the CLI pauses and prompts for input
- **Ctrl+C interrupt** -- Press once to pause after the current step for CEO input. Press twice to force quit.

## Safety Features

- **Max iterations** -- Default 50, prevents runaway loops
- **30-min timeout** -- Per claude execution
- **Dry run mode** -- See decisions without executing
- **Error feedback** -- Failed commands feed error text back to the manager LLM
- **Graceful interrupt** -- Single Ctrl+C pauses, double exits

## Data

Interaction history is stored at `~/.apex-infinite/history.db` (SQLite with WAL mode).

## Notes

- **Nesting**: The CLI clears the `CLAUDECODE` environment variable so it can launch `claude -p` subprocesses even when run from within a Claude Code session.
- **Slash tolerance**: The manager LLM sometimes outputs `/plansession` instead of `plansession`. The CLI strips leading slashes before routing.
- **implement -> /implementation**: The n8n workflow routes "implement" but the actual SSH command runs `/implementation`. The CLI preserves this alias.
- **LLM retries**: Both LLM calls (summarizer and manager) retry 3 times with a 5-second wait between attempts, matching the original n8n workflow's `retryOnFail` + `waitBetweenTries: 5000`.
- **Reference workflow**: The original n8n workflow JSON is preserved in `n8n-workflow/` for reference.

## Requirements

- Python 3.10+
- Claude Code CLI (`claude`) installed and accessible
- An LLM provider API key (Grok, OpenAI) or local Ollama instance
