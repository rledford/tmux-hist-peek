# tmux-hist-peek

A tmux plugin that maintains a per-pane file history fed by any tool or script, and lets you quickly pass those files to any command via a popup overlay.

## How it works

`tmux-hist-peek` exposes a `scripts/record.sh` script that anything can call to push file paths into the history. It reads a JSON payload from stdin, extracts the path(s), and prepends them to the pane's history file. When you trigger the popup, a navigable list appears and selecting a file passes it to your configured command.

What ends up in the history is entirely up to what you hook in — recently read files, newly created files, files modified by an agent, or anything else.

The history is per-pane and capped at a configurable maximum, always keeping the most recently pushed files at the top.

## Requirements

- tmux
- [jq](https://jqlang.org)
- Something that can pipe JSON to `scripts/record.sh` on stdin (see [Hooking in a tool](#hooking-in-a-tool))

## Installation

### With [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'rledford/tmux-hist-peek'
```

Then press `prefix + I` to install.

### Manual

Clone the repo and source the plugin in your `~/.tmux.conf`:

```tmux
run-shell /path/to/tmux-hist-peek/hist-peek.tmux
```

## Hooking in a tool

`record.sh` reads a JSON object from stdin. It expects one of two shapes:

Single file:
```json
{ "file": "/path/to/file.txt" }
```

Multiple files:
```json
{ "files": ["/path/to/file1.txt", "/path/to/file2.txt"] }
```

Anything that can produce JSON in either shape and pipe it to `record.sh` on stdin will work — shell scripts wrapping CLI tools, editor hooks, agent hook systems, and so on.

### Adapters

The `scripts/adapters/` directory contains pre-built adapters that transform a tool's native hook output into the format `record.sh` expects.

#### Claude Code

`scripts/adapters/claude.sh` transforms Claude Code's `PostToolUse` hook payload and pipes it to `record.sh`. Point the hook at the adapter instead of `record.sh` directly:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|Read",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/tmux-hist-peek/scripts/adapters/claude.sh"
          }
        ]
      }
    ]
  }
}
```

Adjust the `matcher` to capture only the tools you want tracked. Replace `/path/to/tmux-hist-peek` with the actual path to your installation.

## Usage

Press `prefix + e` (default) to open the file picker popup.

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `Enter` | Select file |
| `p` | Pin / unpin selected file |
| `r` | Reset history (prompts `y/N`) |
| `q` / `Esc` | Close |

Pinned files are highlighted in yellow and always appear at the top of the list. Up to `@hist-peek-max-pins` files can be pinned per pane at a time (default 5). Pressing `p` on an already-pinned file unpins it.

## Configuration

All options are set in `~/.tmux.conf`.

| Option | Default | Description |
|--------|---------|-------------|
| `@hist-peek-key` | `e` | Key to open the popup (combined with prefix) |
| `@hist-peek-width` | `80%` | Popup width |
| `@hist-peek-height` | `80%` | Popup height |
| `@hist-peek-max-files` | `5` | Maximum number of files to track per pane |
| `@hist-peek-max-pins` | `5` | Maximum number of pinned files per pane |
| `@hist-peek-command` | `vi` | Command to run on the selected file |

Example:

```tmux
set -g @hist-peek-key 'f'
set -g @hist-peek-max-files 10
set -g @hist-peek-command 'nvim'
```

## License

[MIT](LICENSE)
