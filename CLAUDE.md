# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LLM Switcher is a Bash utility that enables switching between different LLM backends while maintaining the Claude Code interface. It works by manipulating environment variables that Claude Code uses to determine which API endpoint and authentication to use.

## Architecture

### Core Components

**llm-switcher.sh** (Main Script)
- Shell function `llm()` that manages environment variables
- Supports four backends: DeepSeek, Qwen, Grok (via OpenRouter), and Claude Pro
- Auto-executes `claude` command after switching models
- Configuration loaded from `.env` file in `$SCRIPT_DIR`

### Backend Switching Mechanism

The script manipulates these environment variables to redirect Claude Code:

**For alternative APIs (DeepSeek, Qwen, Grok):**
- `ANTHROPIC_BASE_URL`: API endpoint URL
- `ANTHROPIC_AUTH_TOKEN`: API authentication token
- `ANTHROPIC_MODEL`: Primary model identifier
- `ANTHROPIC_SMALL_FAST_MODEL`: Fast model identifier (set to same as primary)
- `API_TIMEOUT_MS`: Extended timeout (600000ms = 10 minutes)
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`: Disables telemetry (set to 1)

**For Claude Pro (default):**
- All above variables are unset, reverting to browser-based authentication

### Supported Models

1. **DeepSeek** (`deepseek`, `ds`)
   - Endpoint: `https://api.deepseek.com/anthropic`
   - Model: `deepseek-chat`
   - Uses DeepSeek's Anthropic-compatible API

2. **Qwen** (`qwen`, `qw`)
   - Endpoint: `https://openrouter.ai/api/v1`
   - Model: `qwen/qwen-coder-32b:free`
   - Free tier via OpenRouter

3. **Grok** (`grok`, `gr`)
   - Endpoint: `https://openrouter.ai/api/v1`
   - Model: `x-ai/grok-code-fast-1`
   - Uses OpenRouter API

4. **Claude Pro** (`claude`, `pro`, `cl`)
   - Default browser authentication
   - No API key required

## Commands

### Model Switching (auto-executes Claude Code)
```bash
llm deepseek    # Switch to DeepSeek
llm qwen        # Switch to Qwen
llm grok        # Switch to Grok
llm claude      # Switch to Claude Pro
```

### Utility Commands
```bash
llm status      # Show current backend configuration
llm list        # List available models
llm edit        # Edit .env file with API keys
llm help        # Show help message
```

### Aliases
```bash
dlaude          # Shortcut for llm deepseek
qlaude          # Shortcut for llm qwen
glaude          # Shortcut for llm grok
claudo          # Shortcut for llm claude
```

## Configuration

### Installation
1. Add to `~/.zshrc`: `source ~/.config/claude-switcher/llm-switcher.sh`
2. Configure API keys in `~/.config/claude-switcher/.env`

### .env Format
```bash
DEEPSEEK_API_KEY=sk-xxxxx
OPENROUTER_API_KEY=sk-or-xxxxx
```

## Security Notes

- The `.env` file contains API keys and must never be committed to git
- `.gitignore` already includes `.env` and `*.key` patterns
- API keys are loaded via `source` command in the shell script

## Development Notes

- Script uses `$HOME/.config/claude-switcher` as base directory
- Shell function uses `local auto_run=false` flag to determine if `claude` should be executed
- Error handling: Unknown models return exit code 1
- Configuration editing uses `$EDITOR` variable with `nano` fallback
