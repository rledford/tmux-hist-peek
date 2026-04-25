# tmux-claude-peek

A tmux plugin that tracks files touched by Claude Code during your session and lets you quickly reopen them in an editor via a popup overlay.

## How it works

`tmux-claude-peek` hooks into Claude Code's tool output to record every file Claude reads or edits. When you trigger the popup, a navigable list of those files appears. Selecting one opens it in your configured editor inside another popup.

The file history is per-pane and capped at a configurable maximum, always keeping the most recently touched files at the top.

## Requirements

- tmux
- [jq](https://jqlang.org)
- Claude Code with hooks configured (see [Installation](#installation))

## Installation

### With [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add to your `~/.tmux.conf`:

```tmux
set -g @plugin 'rledford/tmux-claude-peek'
```

Then press `prefix + I` to install.

### Manual

Clone the repo and source the plugin in your `~/.tmux.conf`:

```tmux
run-shell /path/to/tmux-claude-peek/claude-peek.tmux
```

### Claude Code hook

`tmux-claude-peek` requires a Claude Code `PostToolUse` hook to capture file activity. Add the following to your Claude Code settings (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|Read",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/tmux-claude-peek/scripts/record.sh"
          }
        ]
      }
    ]
  }
}
```

Replace `/path/to/tmux-claude-peek` with the actual path to your installation.

## Usage

Press `prefix + e` (default) to open the file picker popup.

| Key | Action |
|-----|--------|
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `Enter` | Open selected file |
| `p` | Pin / unpin selected file |
| `q` / `Esc` | Close |

Pinned files are highlighted in yellow and always appear at the top of the list. Up to `@claude-peek-max-pins` files can be pinned per pane at a time (default 5). Pressing `p` on an already-pinned file unpins it.

## Configuration

All options are set in `~/.tmux.conf`.

| Option | Default | Description |
|--------|---------|-------------|
| `@claude-peek-key` | `e` | Key to open the popup (combined with prefix) |
| `@claude-peek-width` | `80%` | Popup width |
| `@claude-peek-height` | `80%` | Popup height |
| `@claude-peek-max-files` | `5` | Maximum number of files to track per pane |
| `@claude-peek-max-pins` | `5` | Maximum number of pinned files per pane |
| `@claude-peek-editor` | `vi` | Editor used to open files |

Example:

```tmux
set -g @claude-peek-key 'f'
set -g @claude-peek-max-files 10
set -g @claude-peek-editor 'nvim'
```

## License

[MIT](LICENSE)
