#!/usr/bin/env node
// =============================================================================
// Apex Spec System MCP Server
// =============================================================================
// Exposes project analysis, prerequisite checking, state management, and
// command listing as MCP tools over stdio transport.
// =============================================================================

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { execFile } from "node:child_process";
import { readFile, writeFile, readdir } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

// Resolve paths relative to the repository root (two levels up from dist/)
const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT_DIR = resolve(__dirname, "..", "..");
const SCRIPTS_DIR = resolve(ROOT_DIR, "scripts");
const COMMANDS_DIR = resolve(ROOT_DIR, "commands");

// Allow overriding the project directory via environment variable
const PROJECT_DIR = process.env.APEX_PROJECT_DIR || process.cwd();

// =============================================================================
// Helpers
// =============================================================================

async function runScript(
  script: string,
  args: string[],
  cwd: string
): Promise<string> {
  const scriptPath = resolve(SCRIPTS_DIR, script);
  const { stdout } = await execFileAsync("bash", [scriptPath, ...args], {
    cwd,
    env: { ...process.env, SPEC_SYSTEM_DIR: resolve(cwd, ".spec_system") },
    timeout: 30_000,
  });
  return stdout;
}

function parseYamlFrontmatter(
  content: string
): { fields: Record<string, string>; body: string } {
  const lines = content.split("\n");
  const fields: Record<string, string> = {};
  let body = content;

  if (lines[0]?.trim() === "---") {
    let endIdx = -1;
    for (let i = 1; i < lines.length; i++) {
      if (lines[i]?.trim() === "---") {
        endIdx = i;
        break;
      }
      const match = lines[i]?.match(/^(\w[\w-]*):\s*(.*)$/);
      if (match) {
        fields[match[1]] = match[2];
      }
    }
    if (endIdx > 0) {
      body = lines.slice(endIdx + 1).join("\n");
    }
  }

  return { fields, body };
}

// =============================================================================
// Server setup
// =============================================================================

const server = new McpServer({
  name: "apex-spec",
  version: "0.35.12",
});

// ---------------------------------------------------------------------------
// Tool: analyze_project
// ---------------------------------------------------------------------------

server.tool(
  "analyze_project",
  "Analyze project state: current phase, session, completed sessions, and next candidates. " +
    "Returns the same JSON as scripts/analyze-project.sh --json.",
  {
    project_dir: z
      .string()
      .optional()
      .describe(
        "Absolute path to the project directory containing .spec_system/. Defaults to the server's working directory."
      ),
  },
  async ({ project_dir }) => {
    const cwd = project_dir || PROJECT_DIR;
    try {
      const output = await runScript("analyze-project.sh", ["--json"], cwd);
      return { content: [{ type: "text" as const, text: output.trim() }] };
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      return {
        content: [{ type: "text" as const, text: `Error: ${msg}` }],
        isError: true,
      };
    }
  }
);

// ---------------------------------------------------------------------------
// Tool: check_prereqs
// ---------------------------------------------------------------------------

server.tool(
  "check_prereqs",
  "Validate prerequisites: environment (spec system, jq, git), required tools, files, and session dependencies. " +
    "Returns the same JSON as scripts/check-prereqs.sh --json.",
  {
    project_dir: z
      .string()
      .optional()
      .describe(
        "Absolute path to the project directory containing .spec_system/. Defaults to the server's working directory."
      ),
    tools: z
      .string()
      .optional()
      .describe("Comma-separated list of required tools to check (e.g. 'node,npm,docker')."),
    files: z
      .string()
      .optional()
      .describe("Comma-separated list of required file paths to check."),
    prereqs: z
      .string()
      .optional()
      .describe("Comma-separated list of prerequisite session IDs to check."),
    env_only: z
      .boolean()
      .optional()
      .describe("If true, only check the environment (spec system, jq, git). Default: false."),
  },
  async ({ project_dir, tools, files, prereqs, env_only }) => {
    const cwd = project_dir || PROJECT_DIR;
    const args = ["--json"];
    if (env_only) args.push("--env");
    if (tools) args.push("--tools", tools);
    if (files) args.push("--files", files);
    if (prereqs) args.push("--prereqs", prereqs);

    try {
      const output = await runScript("check-prereqs.sh", args, cwd);
      return { content: [{ type: "text" as const, text: output.trim() }] };
    } catch (err: unknown) {
      // check-prereqs exits non-zero when prereqs fail -- still return JSON
      const msg = err instanceof Error ? (err as NodeJS.ErrnoException & { stdout?: string }).stdout || err.message : String(err);
      return {
        content: [{ type: "text" as const, text: typeof msg === "string" ? msg.trim() : String(msg) }],
        isError: true,
      };
    }
  }
);

// ---------------------------------------------------------------------------
// Tool: get_state
// ---------------------------------------------------------------------------

server.tool(
  "get_state",
  "Read the current project state from .spec_system/state.json. Returns the full JSON state object.",
  {
    project_dir: z
      .string()
      .optional()
      .describe(
        "Absolute path to the project directory containing .spec_system/. Defaults to the server's working directory."
      ),
  },
  async ({ project_dir }) => {
    const cwd = project_dir || PROJECT_DIR;
    const stateFile = resolve(cwd, ".spec_system", "state.json");
    try {
      const content = await readFile(stateFile, "utf-8");
      // Validate JSON
      JSON.parse(content);
      return { content: [{ type: "text" as const, text: content.trim() }] };
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      return {
        content: [{ type: "text" as const, text: `Error reading state: ${msg}` }],
        isError: true,
      };
    }
  }
);

// ---------------------------------------------------------------------------
// Tool: update_state
// ---------------------------------------------------------------------------

server.tool(
  "update_state",
  "Update specific fields in .spec_system/state.json. Merges the provided fields into the existing state. " +
    "Supports: current_phase (number), current_session (string|null), adding to completed_sessions (string[]).",
  {
    project_dir: z
      .string()
      .optional()
      .describe(
        "Absolute path to the project directory containing .spec_system/. Defaults to the server's working directory."
      ),
    current_phase: z.number().optional().describe("Set the current phase number."),
    current_session: z
      .string()
      .nullable()
      .optional()
      .describe("Set the current session ID, or null to clear it."),
    add_completed_sessions: z
      .array(z.string())
      .optional()
      .describe("Session IDs to append to the completed_sessions array."),
    phase_status: z
      .object({
        phase: z.string().describe("Phase number as string (e.g. '0', '1')."),
        status: z.enum(["not_started", "in_progress", "completed"]),
      })
      .optional()
      .describe("Update a specific phase's status."),
  },
  async ({ project_dir, current_phase, current_session, add_completed_sessions, phase_status }) => {
    const cwd = project_dir || PROJECT_DIR;
    const stateFile = resolve(cwd, ".spec_system", "state.json");
    try {
      const raw = await readFile(stateFile, "utf-8");
      const state = JSON.parse(raw);

      if (current_phase !== undefined) {
        state.current_phase = current_phase;
      }
      if (current_session !== undefined) {
        state.current_session = current_session;
      }
      if (add_completed_sessions?.length) {
        if (!Array.isArray(state.completed_sessions)) {
          state.completed_sessions = [];
        }
        for (const s of add_completed_sessions) {
          if (!state.completed_sessions.includes(s)) {
            state.completed_sessions.push(s);
          }
        }
      }
      if (phase_status) {
        if (!state.phases) state.phases = {};
        if (!state.phases[phase_status.phase]) {
          state.phases[phase_status.phase] = {};
        }
        state.phases[phase_status.phase].status = phase_status.status;
      }

      const updated = JSON.stringify(state, null, 2) + "\n";
      await writeFile(stateFile, updated, "utf-8");
      return {
        content: [{ type: "text" as const, text: updated.trim() }],
      };
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      return {
        content: [{ type: "text" as const, text: `Error updating state: ${msg}` }],
        isError: true,
      };
    }
  }
);

// ---------------------------------------------------------------------------
// Tool: list_commands
// ---------------------------------------------------------------------------

server.tool(
  "list_commands",
  "List all available Apex Spec System commands with their names and descriptions. " +
    "Reads from the canonical commands/ directory.",
  {},
  async () => {
    try {
      const files = await readdir(COMMANDS_DIR);
      const commands: { name: string; description: string }[] = [];

      for (const file of files.sort()) {
        if (!file.endsWith(".md")) continue;
        const content = await readFile(resolve(COMMANDS_DIR, file), "utf-8");
        const { fields } = parseYamlFrontmatter(content);
        if (fields.name) {
          commands.push({
            name: fields.name,
            description: fields.description || "",
          });
        }
      }

      const result = JSON.stringify({ commands, count: commands.length }, null, 2);
      return { content: [{ type: "text" as const, text: result }] };
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      return {
        content: [{ type: "text" as const, text: `Error listing commands: ${msg}` }],
        isError: true,
      };
    }
  }
);

// =============================================================================
// Start server
// =============================================================================

async function main(): Promise<void> {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error("Fatal:", err);
  process.exit(1);
});
