# LLM Switcher for Claude Code

A bash utility that lets you dynamically switch between different LLM backends while keeping the Claude Code interface. Perfect for experimenting with different models or using alternative APIs without losing the development experience.

## Features

- 🔄 Quick switching between 4 different backends
- 🎯 Automatic Claude Code execution after switching
- ⚙️ Centralized environment variable management
- 🔐 Secure API key storage
- 📋 Utility commands for managing configuration

## Quick Start

### 1. File Structure

```
~/.config/claude-switcher/
├── llm-switcher.sh    # Main script
├── .env               # API keys (do NOT version)
└── README.md          # This documentation
```

### 2. Load the script in your shell

Add this line to `~/.zshrc` (or `~/.bashrc` if using Bash):

```bash
source ~/.config/claude-switcher/llm-switcher.sh
```

Then reload your shell configuration:

```bash
source ~/.zshrc
```

### 3. Configure API Keys

Create or edit `~/.config/claude-switcher/.env`:

```bash
DEEPSEEK_API_KEY=sk-xxxxx
OPENROUTER_API_KEY=sk-or-xxxxx
```

Get your keys:
- **DeepSeek**: https://platform.deepseek.com/api_keys
- **OpenRouter** (Qwen, Grok): https://openrouter.ai/keys

## Usage

### Switch Models (with auto-execution)

```bash
llm deepseek    # Switch to DeepSeek
llm qwen        # Switch to Qwen
llm grok        # Switch to Grok
llm claude      # Switch back to Claude Pro (default)
```

Each command switches the backend and automatically executes Claude Code with the new configuration.

### Available Aliases

For convenience, use these shortcuts:

```bash
dlaude          # Shortcut for: llm deepseek
qlaude          # Shortcut for: llm qwen
glaude          # Shortcut for: llm grok
claudo          # Shortcut for: llm claude
```

### Utility Commands

```bash
llm status      # Show current backend and environment variables
llm list        # List all available models
llm edit        # Edit .env file (opens with $EDITOR or nano)
llm help        # Show help message
```

## Supported Models

| Model | Aliases | Endpoint | Features |
|-------|---------|----------|----------|
| **DeepSeek** | `deepseek`, `ds` | api.deepseek.com | Anthropic-compatible API |
| **Qwen** | `qwen`, `qw` | openrouter.ai | Free tier, 32B parameters |
| **Grok** | `grok`, `gr` | openrouter.ai | Fast code model |
| **Claude Pro** | `claude`, `pro`, `cl` | Claude.ai | Browser-based auth (default) |

## Advanced Configuration

### Environment Variables Set

When switching to an alternative backend, the script automatically sets:

```bash
ANTHROPIC_BASE_URL              # API endpoint
ANTHROPIC_AUTH_TOKEN           # Authentication token
ANTHROPIC_MODEL                # Primary model
ANTHROPIC_SMALL_FAST_MODEL     # Fast model (alias of primary)
API_TIMEOUT_MS=600000          # Timeout: 10 minutes
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1  # Disables telemetry
```

When switching back to Claude Pro, these variables are unset.

### Manually Edit Configuration

```bash
nano ~/.config/claude-switcher/.env
```

## Security

⚠️ **IMPORTANT**: The `.env` file contains API keys and must never be versioned in git.

If you version your configuration, add to your `.gitignore`:

```
.env
*.key
```

This is already included in the repository if you use this structure.

## Troubleshooting

### "command not found: llm"
- Verify you've added the `source` line to `~/.zshrc` or `~/.bashrc`
- Reload your shell: `source ~/.zshrc`
- Check that `llm-switcher.sh` exists in `~/.config/claude-switcher/`

### "No API key configured"
- Run `llm edit` to configure your API keys
- Verify that `.env` exists in `~/.config/claude-switcher/`

### Claude Code doesn't execute after switching
- Make sure `claude` is installed: `which claude`
- Check that the model is available: `llm list`

## Uninstallation

### Option 1: Temporarily Disable

Comment out the line in `~/.zshrc`:

```bash
# source ~/.config/claude-switcher/llm-switcher.sh
```

### Option 2: Completely Remove

```bash
rm -rf ~/.config/claude-switcher
```

Then remove or comment out the `source` line in `~/.zshrc`.

## Usage Examples

```bash
# Switch to DeepSeek for a task
dlaude

# Check which model you're currently using
llm status

# Quickly switch to Grok
glaude

# Switch back to Claude Pro
claudo

# Edit your API keys
llm edit

# List all available models
llm list
```

## Technical Notes

- The utility works by manipulating environment variables that Claude Code uses to determine the API endpoint and authentication
- Timeout is set to 10 minutes (600000ms) for external APIs
- Telemetry is disabled when using alternative backends
- The script uses `$HOME/.config/claude-switcher` as the base directory
- Compatible with Bash and Zsh

## Support

If you encounter issues, verify:
- That your API keys are correct
- That you have connectivity to the endpoints
- That `claude` is installed and available in your PATH
- Claude Code logs in case of errors
