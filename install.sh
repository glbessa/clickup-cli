#!/bin/bash

# ClickUp CLI Installation Script
# Supports root and non-root installation

SCRIPT_NAME="clickup-cli"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_SCRIPT_PATH="$SRC_DIR/src/$SCRIPT_NAME"
SRC_LIB_DIR="$SRC_DIR/src/lib"

# Determine default PREFIX
if [ "$(id -u)" -eq 0 ]; then
    PREFIX="/usr/local"
else
    PREFIX="$HOME/.local"
fi

# Parse prefix from arguments if provided
while [ $# -gt 0 ]; do
    case "$1" in
        --prefix)
            PREFIX="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

INSTALL_BIN_DIR="$PREFIX/bin"
INSTALL_LIB_DIR="$PREFIX/lib/clickup-cli"

echo "Installing $SCRIPT_NAME to $PREFIX"

# Create directories
mkdir -p "$INSTALL_BIN_DIR"
mkdir -p "$INSTALL_LIB_DIR"

# Copy files
if [ ! -w "$INSTALL_BIN_DIR" ]; then
    echo "Error: Cannot write to $INSTALL_BIN_DIR"
    echo "Please run this script with sudo or ensure you have write permissions."
    exit 1
fi

if [ ! -w "$INSTALL_LIB_DIR" ] && [ -d "$INSTALL_LIB_DIR" ]; then
     echo "Error: Cannot write to $INSTALL_LIB_DIR"
     echo "Please run this script with sudo or ensure you have write permissions."
     exit 1
elif [ ! -d "$INSTALL_LIB_DIR" ]; then
    # Check if we can create the directory (check parent)
    PARENT_LIB_DIR=$(dirname "$INSTALL_LIB_DIR")
    if [ ! -w "$PARENT_LIB_DIR" ]; then
        echo "Error: Cannot create directory in $PARENT_LIB_DIR"
        echo "Please run this script with sudo or ensure you have write permissions."
        exit 1
    fi
fi

cp "$SRC_SCRIPT_PATH" "$INSTALL_BIN_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_BIN_DIR/$SCRIPT_NAME"
cp -r "$SRC_LIB_DIR"/* "$INSTALL_LIB_DIR/"

echo "$SCRIPT_NAME installed to $INSTALL_BIN_DIR/$SCRIPT_NAME"
echo "Libraries installed to $INSTALL_LIB_DIR"

# Check if INSTALL_BIN_DIR is in PATH
if ! echo "$PATH" | grep -q "$INSTALL_BIN_DIR"; then
    echo "Warning: $INSTALL_BIN_DIR is not in your PATH."
    echo "You might need to add 'export PATH=\"\$PATH:$INSTALL_BIN_DIR\"' to your shell profile."
fi

# Initialize configuration
CLICKUP_CLI_FOLDER="$HOME/.clickup-cli"
CONFIG_FILE="$CLICKUP_CLI_FOLDER/config"
LOG_FILE="$CLICKUP_CLI_FOLDER/log"

mkdir -p "$CLICKUP_CLI_FOLDER"

if [ ! -f "$LOG_FILE" ]; then
    touch "$LOG_FILE"
    chmod 644 "$LOG_FILE"
fi

if [ ! -f "$CONFIG_FILE" ]; then
    cat <<EOF > "$CONFIG_FILE"
#!/bin/bash
export API_TOKEN="your_clickup_api_token_here"
export DEFAULT_WORKSPACE_ID=""
export DEFAULT_CHANNEL_ID=""
EOF
    chmod 600 "$CONFIG_FILE"
    echo "Created default config at $CONFIG_FILE"
fi

echo "Installation complete. Run '$SCRIPT_NAME configure' to set up your API token."