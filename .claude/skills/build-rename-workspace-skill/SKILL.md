---
name: build-rename-workspace-skill
description: "Build a terminal-specific Claude skill named rename-workspace. Use when the user wants Claude to learn how to rename the current terminal, workspace, tab, pane, tmux window, cmux workspace, or similar session label for the terminal they are using."
---

# Build Rename Workspace Skill

Create or update a local Claude skill named `rename-workspace` that works for the terminal/session manager the user is currently using.

This is a builder skill. Do not assume the user is using cmux, tmux, iTerm2, Terminal.app, WezTerm, or any other specific terminal. Investigate first, interview the user, then write the actual `rename-workspace` skill for the detected environment.

## Goal

Help the user end up with a working local skill at:

```text
~/.claude/skills/rename-workspace/SKILL.md
```

That generated skill should know how to rename the user's current workspace, tab, window, pane, or equivalent task label in their terminal/session environment.

## Workflow

1. Inspect the current terminal/session environment.
2. Identify feasible rename mechanisms.
3. Interview the user about which visible label they want renamed and how names should be chosen.
4. Write or update `~/.claude/skills/rename-workspace/SKILL.md`.
5. Test the generated skill's commands in the current terminal as far as safely possible.
6. Report exactly what was created, how it was tested, and any limitations.

## Investigate the Terminal

Gather evidence with read-only commands first. Use only commands that are safe in the current shell.

Useful checks:

```bash
pwd
echo "$TERM"
echo "$TERM_PROGRAM"
echo "$SHELL"
env | sort | grep -E '^(CMUX|TMUX|WEZTERM|KITTY|ITERM|TERM_PROGRAM|TAB|WINDOW|PANE|CLAUDE|CODEX)='
command -v cmux
command -v tmux
command -v wezterm
command -v kitty
```

If inside a git repo, also inspect:

```bash
git rev-parse --show-toplevel
git branch --show-current
git status --short --branch
```

If `cmux` is available, inspect capabilities:

```bash
cmux --help
cmux identify
```

If `cmux identify` cannot connect to `/tmp/cmux.sock`, record that cmux exists but the current terminal is not connected to an active cmux session.

If `tmux` is active, inspect:

```bash
tmux display-message -p '#S:#I:#W'
tmux list-windows -F '#I #W'
```

For terminal emulators with escape-sequence title support, the feasible fallback is usually setting the window/tab title with:

```bash
printf '\033]0;%s\007' "TITLE"
```

Only propose it as a fallback because support varies by terminal and shell integration.

## Identify Feasible Rename Mechanisms

Classify each option with confidence:

- High confidence: A tool is active and exposes a direct rename command for the current workspace/window/tab.
- Medium confidence: A tool is installed but current session detection is partial.
- Low confidence: Generic terminal title escape sequence or manual instruction.

Known mechanisms:

- cmux workspace: `cmux identify`, then `cmux rename-workspace --workspace <workspace_ref> "<name>"`
- cmux tab: `cmux rename-tab --workspace <workspace_ref> "<name>"`
- tmux window: `tmux rename-window "<name>"`
- tmux session: `tmux rename-session "<name>"`
- generic terminal title: `printf '\033]0;%s\007' "<name>"`

Do not hard-code cmux unless the investigation shows cmux is the right target for this terminal.

## Interview the User

Before writing the generated skill, ask concise questions. Prefer one message with the minimum necessary questions.

Ask what visible label they want the generated skill to control:

```text
I found these feasible rename targets:
A. cmux workspace - best when the visible unit is a cmux workspace/sidebar item
B. tmux window - best when the visible unit is a tmux window name
C. terminal tab/window title - best when the tab title in the terminal app is what you scan
D. Other - tell me what visible label you want renamed
```

Ask how names should be chosen:

```text
How should the generated rename-workspace skill choose names?
A. Ask every time and suggest ticket/branch/repo/task options
B. Prefer ticket ID, then branch, then repo/task summary, but ask before renaming
C. Rename automatically when there is one clear ticket or branch name
D. Custom rule
```

If the user has already answered these in the request, do not ask again. Use their stated preferences.

## Generate the Skill

Create or update:

```text
~/.claude/skills/rename-workspace/SKILL.md
```

The generated skill must include:

- YAML front matter with `name: rename-workspace`.
- A description that mentions the detected terminal/session target.
- A short investigation summary stating why the chosen mechanism is appropriate.
- The exact commands to identify the current workspace/tab/window.
- The exact command to rename it.
- An interview step for the final name unless the user explicitly chose automatic renaming.
- Verification steps.
- Failure handling for when the terminal is not in the expected environment.

For cmux, the generated skill should use this command spelling:

```bash
cmux rename-workspace --workspace <workspace_ref> "<name>"
```

Do not write the misspelled command `rename-worspace`.

## Test

Test the generated skill without causing surprising state changes.

Required tests:

- Confirm `~/.claude/skills/rename-workspace/SKILL.md` exists.
- Read the generated skill and confirm the front matter includes `name: rename-workspace`.
- Confirm the generated skill includes the selected identify command and rename command.
- Run the identify command for the selected terminal/session target.

Rename tests:

- If the user approved a test name, run the rename command with a temporary or user-approved name, verify it, then optionally rename it back if the user wants.
- If the user did not approve changing the visible title, do not perform the rename; report that command validation was limited to discovery and static verification.

## Report

Finish with:

- The generated skill path.
- The selected terminal/session mechanism.
- The naming behavior the user chose.
- The tests run and their results.
- Any limitations, such as not being inside cmux/tmux in the current terminal.
