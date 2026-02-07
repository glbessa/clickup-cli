#!/bin/bash

CLICKUP_CLI_FOLDER="$HOME/.clickup-cli"
CONFIG_FILE="${CONFIG_FILE:-$CLICKUP_CLI_FOLDER/config}"
LOG_FILE="${LOG_FILE:-$CLICKUP_CLI_FOLDER/log}"

createClickupCliFolderIfNeeded() {
    if [ ! -d "$CLICKUP_CLI_FOLDER" ]; then
        mkdir -p "$CLICKUP_CLI_FOLDER"
        echo "Created directory $CLICKUP_CLI_FOLDER"
    fi

    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo "Warning: Could not create log file at $LOG_FILE. Check permissions." >&2
        fi
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        cat <<EOF > "$CONFIG_FILE"
#!/bin/bash
export API_TOKEN="your_clickup_api_token_here"
export DEFAULT_WORKSPACE_ID=""
export DEFAULT_CHANNEL_ID=""
EOF
        chmod 600 "$CONFIG_FILE"
        echo "Created config file at $CONFIG_FILE"
        echo "Please edit this file to add your ClickUp API token and default workspace/project."
    fi
}

loadConfig() {
    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
    fi
}

saveConfig() {
    local api_token="$1"
    local workspace_id="$2"
    local channel_id="$3"

    cat <<EOF > "$CONFIG_FILE"
#!/bin/bash
export API_TOKEN="$api_token"
export DEFAULT_WORKSPACE_ID="$workspace_id"
export DEFAULT_CHANNEL_ID="$channel_id"
EOF
    chmod 600 "$CONFIG_FILE"
}

interactiveConfigure() {
    echo "--- ClickUp CLI Configuration ---"
    
    # Current values
    local current_token="$API_TOKEN"
    local current_workspace="$DEFAULT_WORKSPACE_ID"
    local current_channel="$DEFAULT_CHANNEL_ID"

    printf "Enter your ClickUp API Token [%s]: " "$current_token"
    read -s input_token
    echo ""
    API_TOKEN="${input_token:-$current_token}"

    if [ -z "$API_TOKEN" ] || [ "$API_TOKEN" = "your_clickup_api_token_here" ]; then
        echo "Error: API Token is required."
        return 1
    fi

    echo "Validating token..."
    # Use v2 team endpoint as it's the standard way to check if a token is valid
    export API_TOKEN
    
    if ! apiCall "https://api.clickup.com/api/v2/team" "GET" "" >/dev/null; then
        echo "Failed to validate token. Please check if it's correct."
        return 1
    fi
    echo "Token validated successfully!"

    # Ask for Workspace ID
    echo ""
    printf "Enter default Workspace ID [%s]: " "$current_workspace"
    read input_workspace
    DEFAULT_WORKSPACE_ID="${input_workspace:-$current_workspace}"
    WORKSPACE_ID="$DEFAULT_WORKSPACE_ID"

    if [ -n "$WORKSPACE_ID" ]; then
        echo ""
        if command -v handleListSpaces >/dev/null 2>&1; then
            handleListSpaces
        fi
    fi
    echo ""
    printf "Enter default Channel ID (Optional) [%s]: " "$current_channel"
    read input_channel
    DEFAULT_CHANNEL_ID="${input_channel:-$current_channel}"

    saveConfig "$API_TOKEN" "$DEFAULT_WORKSPACE_ID" "$DEFAULT_CHANNEL_ID"
    echo "Configuration saved to $CONFIG_FILE"
}
