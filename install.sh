#!/bin/sh

SRC_SCRIPT_PATH="$(dirname "$0")/src/clickup-cli"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="clickup-cli"
CLICKUP_CLI_FOLDER="$HOME/.clickup-cli"
LOG_FILE="$CLICKUP_CLI_FOLDER/log"
CONFIG_FILE="$CLICKUP_CLI_FOLDER/config"

moveScriptToPath() {
    local script_path="$INSTALL_DIR/$SCRIPT_NAME"
    
    echo "Installing clickup-cli to $script_path"
    sudo cp "$SRC_SCRIPT_PATH" "$script_path"
    sudo chmod +x "$script_path"
    echo "clickup-cli installed to $script_path"
}

createConfigFile() {
    if [ ! -d "$CLICKUP_CLI_FOLDER" ]; then
        mkdir -p "$CLICKUP_CLI_FOLDER"
        echo "Created directory $CLICKUP_CLI_FOLDER"
    fi

    if [ ! -f "$CONFIG_FILE" ]; then
        cat <<EOF > "$CONFIG_FILE"
#!/bin/sh
export API_TOKEN="your_clickup_api_token_here"
export DEFAULT_WORKSPACE_ID=""
export DEFAULT_CHANNEL_ID=""
EOF
        chmod 600 "$CONFIG_FILE"
        echo "Created config file at $CONFIG_FILE"
        echo "Please edit this file to add your ClickUp API token and default workspace/project."
    fi
}

createLogFile() {
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
}

createLogFile
createConfigFile
moveScriptToPath
