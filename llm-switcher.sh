#!/usr/bin/env bash
# LLM Switcher para Claude Code
# Cambia entre diferentes backends de LLM manteniendo la interfaz de Claude Code

# ============================================================================
# CARGAR CONFIGURACIÓN
# ============================================================================
SCRIPT_DIR="$HOME/.config/claude-switcher"

# Cargar modelos desde YAML
if [ ! -f "$SCRIPT_DIR/models.yaml" ]; then
    echo "❌ Error: No se encontró $SCRIPT_DIR/models.yaml"
    echo "   Este archivo debe existir para cargar la configuración de modelos"
    return 1
fi

# Cargar API keys desde .env
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
else
    echo "⚠️  Advertencia: No se encontró $SCRIPT_DIR/.env"
    echo "   Crea el archivo con tus API keys"
fi

# ============================================================================
# FUNCIONES AUXILIARES PARA PARSEAR YAML
# ============================================================================

# Obtener valor del YAML usando yq o grep como fallback
_get_yaml_value() {
    local key=$1
    local model=$2

    if command -v yq &> /dev/null; then
        yq eval "\.models\.${model}\.${key}" "$SCRIPT_DIR/models.yaml" 2>/dev/null
    else
        # Fallback simple si no está instalado yq
        grep -A 50 "^  $model:" "$SCRIPT_DIR/models.yaml" | grep "    ${key}:" | head -1 | sed 's/.*: //' | tr -d '"'
    fi
}

# Cargar configuración de un modelo
_load_model_config() {
    local model=$1

    local base_url=$(_get_yaml_value "base_url" "$model")
    local model_name=$(_get_yaml_value "model_name" "$model")
    local auth_var=$(_get_yaml_value "auth_token_var" "$model")
    local auth_default=$(_get_yaml_value "auth_token_default" "$model")
    local timeout=$(_get_yaml_value "timeout" "$model")
    local disable_traffic=$(_get_yaml_value "disable_traffic" "$model")
    local display_name=$(_get_yaml_value "display_name" "$model")
    local name=$(_get_yaml_value "name" "$model")

    # Obtener el token: desde variable de entorno o valor por defecto
    local auth_token=""
    if [ -n "$auth_var" ] && [ "$auth_var" != "null" ]; then
        # Compatible con bash y zsh usando eval
        auth_token=$(eval echo "\${${auth_var}:-${auth_default}}")
    fi

    echo "base_url=$base_url"
    echo "model_name=$model_name"
    echo "auth_token=$auth_token"
    echo "timeout=$timeout"
    echo "disable_traffic=$disable_traffic"
    echo "display_name=$display_name"
    echo "name=$name"
}

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================
llm() {
    local auto_run=false
    local model_arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')  # Convertir a minúsculas

    # Función interna para cambiar a un modelo
    _switch_to_model() {
        local model=$1

        # Cargar config del modelo
        eval "$(_load_model_config "$model")"

        # Si es Claude Pro (sin base_url), desactivar APIs personalizadas
        if [ -z "$base_url" ] || [ "$base_url" = "null" ]; then
            unset ANTHROPIC_BASE_URL
            unset ANTHROPIC_MODEL
            unset ANTHROPIC_SMALL_FAST_MODEL
            unset ANTHROPIC_AUTH_TOKEN
            unset API_TIMEOUT_MS
            unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
            echo "🤖 Claude Code → $name"
            echo "   Usando autenticación del browser"
        else
            # Configurar API personalizada
            export ANTHROPIC_BASE_URL="$base_url"
            export ANTHROPIC_AUTH_TOKEN="$auth_token"
            export ANTHROPIC_MODEL="$model_name"
            export ANTHROPIC_SMALL_FAST_MODEL="$model_name"
            [ -n "$timeout" ] && [ "$timeout" != "null" ] && export API_TIMEOUT_MS="$timeout"
            [ -n "$disable_traffic" ] && [ "$disable_traffic" != "null" ] && export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="$disable_traffic"

            echo "🤖 Claude Code → $name"
            echo "   Model: $display_name"
            echo "   Base: $base_url"
        fi

        auto_run=true
    }

    case $model_arg in
        deepseek|ds)
            _switch_to_model "deepseek"
            ;;
        qwen|qw)
            _switch_to_model "qwen"
            ;;
        grok|gr)
            _switch_to_model "grok"
            ;;
        minimax|mm)
            _switch_to_model "minimax"
            ;;
        claude|pro|cl)
            _switch_to_model "claude"
            ;;
        status|st)
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📊 Estado actual de Claude Code:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            if [ -z "$ANTHROPIC_BASE_URL" ]; then
                echo "✅ Backend: Claude Pro (browser auth)"
            else
                echo "🔧 Backend: Custom API"
                echo "   Base URL: $ANTHROPIC_BASE_URL"
                echo "   Model: ${ANTHROPIC_MODEL:-not set}"
            fi
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            ;;
        list|ls)
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📋 Modelos disponibles:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  deepseek (ds)  → DeepSeek Chat"
            echo "  qwen (qw)      → Qwen Coder 32B"
            echo "  grok (gr)      → Grok Code Fast 1"
            echo "  minimax (mm)   → Minimax M2"
            echo "  claude (pro)   → Claude Pro (default)"
            echo ""
            echo "💡 Comandos útiles:"
            echo "  llm status     → Ver configuración actual"
            echo "  llm list       → Ver esta lista"
            echo "  llm edit       → Editar configuración"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            ;;
        edit|config)
            echo "📝 Abriendo configuración..."
            ${EDITOR:-nano} "$SCRIPT_DIR/.env"
            ;;
        help|--help|-h|"")
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🔧 LLM Switcher para Claude Code"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Uso: llm [comando]"
            echo ""
            echo "Modelos (auto-ejecutan claude):"
            echo "  deepseek, ds   → Usar DeepSeek"
            echo "  qwen, qw       → Usar Qwen Coder"
            echo "  grok, gr       → Usar Grok Code Fast 1"
            echo "  minimax, mm    → Usar Minimax M2"
            echo "  claude, pro    → Volver a Claude Pro"
            echo ""
            echo "Info:"
            echo "  status, st     → Ver backend actual"
            echo "  list, ls       → Listar modelos"
            echo "  edit, config   → Editar API keys"
            echo "  help           → Mostrar esta ayuda"
            echo ""
            echo "Ejemplo:"
            echo "  llm deepseek   # Cambiar a DeepSeek y ejecutar"
            echo "  llm claude     # Volver a Claude Pro y ejecutar"
            echo ""
            echo "Configuración: $SCRIPT_DIR"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            ;;
        *)
            echo "❌ Modelo desconocido: $1"
            echo "💡 Usa 'llm help' para ver opciones"
            return 1
            ;;
    esac
    
    # Auto-ejecutar claude si se cambió de modelo
    if [ "$auto_run" = true ]; then
        echo ""
        echo "🚀 Iniciando Claude Code..."
        echo ""
        claude
    fi
}

# ============================================================================
# ALIAS
# ============================================================================
alias dlaude='llm deepseek'
alias qlaude='llm qwen'
alias glaude='llm grok'
alias mlaude='llm minimax'
alias claudo='llm claude'