#!/bin/bash

showUsage() {
    echo "ClickUp CLI - Command Line Interface for ClickUp API"
    echo
    echo "USAGE:"
    echo "  $0 [OPTIONS] <COMMAND> [ARGS...]"
    echo
    echo "GLOBAL OPTIONS:"
    echo "  -h, --help              Show this help message"
    echo "  --version               Show version information"
    echo "  -w, --workspace <ID>    Workspace ID (overrides DEFAULT_WORKSPACE_ID)"
    echo "  -c, --channel <ID>      Channel ID (overrides DEFAULT_CHANNEL_ID)"
    echo "  -v, --verbose           Enable verbose output"
    echo
    echo "COMMANDS:"
    echo "  send message <text>     Send a message to a channel"
    echo "    [to <channel>]          Specify channel ID inline"
    echo "    [in <workspace>]        Specify workspace ID inline"
    echo
    echo "  list workspaces         List available workspaces"
    echo "  list spaces             List spaces in workspace"
    echo "  list folders --space <id> List folders in space"
    echo "  list lists --space <id>  List lists in space"
    echo "  list lists --folder <id> List lists in folder"
    echo "  list shared             List shared folders and lists"
    echo "  list tasks --list <id>  List tasks in a list"
    echo "  list channels           List channels in workspace"
    echo
    echo "  show task <id>          Show task details"
    echo
    echo "  create task <name> --list <id> [options]"
    echo "    OPTIONS:"
    echo "      -d, --description <text>  Task description"
    echo "      -p, --priority <1-4>      Priority (1: Urgent, 2: High, 3: Normal, 4: Low)"
    echo "      -s, --status <name>       Initial status (e.g., \"to do\")"
    echo
    echo "  update task <id> [options]"
    echo "    OPTIONS:"
    echo "      -n, --name <text>         New task name"
    echo "      -d, --description <text>  New description"
    echo "      -p, --priority <1-4>      New priority"
    echo "      -s, --status <name>       New status"
    echo
    echo "  delete task <id> [-y]     Delete a task"
    echo
    echo "  configure               Interactive configuration"
    echo
    echo "  help                    Show this help message"
    echo
    echo "EXAMPLES:"
    echo "  # Send message using environment variables"
    echo "  $0 send message \"Hello, world!\""
    echo
    echo "  # Send message with explicit workspace and channel"
    echo "  $0 --workspace 123 --channel 456 send message \"Hello!\""
    echo
    echo "  # Send message with inline parameters"
    echo "  $0 send message \"Hello!\" to 456 in 123"
    echo
    echo "  # Mixed usage"
    echo "  $0 --workspace 123 send message \"Hello!\" to 456"
    echo
    echo "ENVIRONMENT VARIABLES:"
    echo "  BASE_URL                Base URL for ClickUp API"
    echo "                          (default: https://api.clickup.com/api/v3)"
    echo "  API_TOKEN               Your ClickUp API token (required)"
    echo "  DEFAULT_WORKSPACE_ID    Default workspace ID"
    echo "  DEFAULT_CHANNEL_ID     Default channel ID"
    echo
    echo "For more information, visit: https://clickup.com/api"
}
