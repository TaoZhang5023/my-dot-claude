---
name: cmux-workspace-name
description: "Rename the current cmux workspace or tab so the user can identify what task the session is working on. Use when the user asks to rename a workspace/tab/session, label a cmux workspace, set a ticket name, or make the current terminal easier to identify."
---

# cmux Workspace Name

Rename the current cmux workspace or tab to a clear task label, usually a ticket ID.

## The Job

1. Work out whether the session is running inside cmux.
2. Offer the user feasible naming options based on the terminal context.
3. Ask the user what name they want.
4. Run the cmux rename command.
5. Confirm the final name and what was renamed.

## Detect cmux Context

Start with:

```bash
cmux identify
```

Use the returned `workspace_ref` as the target workspace when it is available.

If `cmux identify` fails because cmux is unavailable, not running, or cannot connect to the socket, say that cmux workspace renaming is not available in this terminal. Do not invent a workspace ID.

If the command output includes JSON only when `--json` is supplied in the installed version, use:

```bash
cmux --json identify
```

Extract the workspace reference from the output field named `workspace_ref`, or from the equivalent workspace ref field shown by that installed cmux version.

## Interview the User

Before renaming, offer concise naming choices that fit the current task. Do this even if one option looks likely, unless the user already gave an exact name.

Use options like:

```text
I can rename this cmux workspace. Feasible names:
A. <ticket-id> - ticket-first label, best for issue work
B. <project-or-repo>: <short-task> - readable task label
C. <branch-name> - mirrors the active git branch
D. Custom name - tell me the exact title

Which name should I use?
```

Prefer these sources, in order:

- Ticket IDs or issue IDs explicitly mentioned by the user, such as `ABC-123`, `T01`, `#42`, or `GH-42`.
- Current git branch name, if it contains a useful ticket or task slug.
- Current repository or project directory name.
- A short task summary from the user's latest request.

Keep the final name short enough to scan in a tab bar. A good default format is:

```text
<TICKET_ID> <short task>
```

Examples:

```text
CMUX-17 workspace rename
T01 auth redirect
#42 billing export
my-dot-claude skill
```

## Rename the Workspace

Use the current cmux command spelling:

```bash
cmux rename-workspace --workspace <workspace_ref> "<WORKSPACE_NAME>"
```

Notes:

- The command is `rename-workspace`.
- Do not use the misspelled form `rename-worspace`.
- Always quote the workspace name.
- If `CMUX_WORKSPACE_ID` is set and `cmux identify` does not expose a ref, use that value only after saying it is the environment-provided workspace ID.

## Optional Tab Rename

If the user specifically asks to rename the tab instead of the workspace, use:

```bash
cmux rename-tab --workspace <workspace_ref> "<TAB_NAME>"
```

If they ask for both, rename the workspace first, then the tab.

## Verification

After renaming, run:

```bash
cmux identify
```

If available, also run:

```bash
cmux list-workspaces
```

Confirm that the selected workspace now shows the requested name. If verification cannot read the title but the rename command succeeded, report that the rename command completed and state the verification limitation.

## Failure Handling

- If cmux is not installed, say `cmux` is not available and stop.
- If cmux cannot connect to `/tmp/cmux.sock`, say this terminal is not connected to an active cmux session.
- If there are multiple plausible workspaces and no current workspace can be identified, ask the user which workspace to rename before running a rename command.
- If the chosen name is empty or only whitespace, ask again for a non-empty name.
