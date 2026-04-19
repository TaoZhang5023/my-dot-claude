---
name: rename-workspace
description: "Figure out feasible cmux workspace names, interview the user for the desired name, then rename the current cmux workspace so the user can identify what task the session is working on. Use when the user asks to rename a workspace, tab, cmux session, or label the current work with a ticket/task name."
---

# Rename Workspace

Rename the current cmux workspace to a clear task label, usually a ticket ID or short task name.

## Workflow

1. Check whether `cmux` is available.
2. Run `cmux identify` to find the current `workspace_ref`.
3. Work out feasible names from the current task, ticket, branch, and repo.
4. Interview the user and ask which name to use.
5. Rename the workspace.
6. Verify the rename when cmux can report the workspace list.

## Identify the Workspace

Run:

```bash
cmux identify
```

Use the returned `workspace_ref`.

If the installed cmux version needs JSON for reliable parsing, run:

```bash
cmux --json identify
```

If `cmux identify` fails because there is no active cmux socket, say this terminal is not connected to an active cmux session and stop. Do not invent a workspace reference.

## Work Out Naming Options

Offer feasible options before renaming unless the user already gave an exact final name.

Prefer names from these signals:

- Ticket IDs or issue IDs in the user request, such as `ABC-123`, `T01`, `#42`, or `GH-42`.
- Current git branch, especially if it contains a ticket ID or readable task slug.
- Current repo or project directory name.
- A short summary of the current task.

Good names are short and scannable:

```text
ABC-123 login redirect
T01 auth redirect
#42 billing export
my-dot-claude skill
```

Ask the user like this:

```text
I found this cmux workspace: <workspace_ref>.

Feasible names:
A. <ticket-id-or-issue> - ticket-first label
B. <repo-or-project>: <short-task> - project plus task
C. <branch-name> - match the current branch
D. Custom - tell me the exact name

Which name should I use?
```

If the user chooses a letter, use that option. If they provide custom text, use the exact text after trimming surrounding whitespace.

## Rename

Run:

```bash
cmux rename-workspace --workspace <workspace_ref> "<WORKSPACE_NAME>"
```

Important:

- The command is `rename-workspace`.
- Do not use the misspelled command `rename-worspace`.
- Quote the workspace name.
- Use the workspace ref from `cmux identify`.

## Verify

Run:

```bash
cmux identify
cmux list-workspaces
```

Confirm the current workspace now shows the requested name. If `list-workspaces` is unavailable or does not show titles, report that the rename command succeeded but title verification was limited by the installed cmux output.

## Failures

- If `cmux` is not installed, tell the user `cmux` is not available.
- If `cmux identify` cannot connect to `/tmp/cmux.sock`, tell the user this terminal is not connected to an active cmux session.
- If no `workspace_ref` can be identified, ask the user for the target workspace.
- If the chosen name is empty, ask again for a non-empty workspace name.
