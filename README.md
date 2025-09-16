# ClickUp CLI

A command-line interface for interacting with the ClickUp API, specifically designed for sending messages to ClickUp chat channels.

## Features

- 🚀 **Simple and flexible**: Multiple ways to specify workspace and channel
- 🔧 **Extensible**: Easy to add new commands and features
- 📝 **Detailed help**: Comprehensive usage information and examples
- 🐛 **Error handling**: Clear error messages and HTTP status code handling
- 🔍 **Debug mode**: Verbose output for troubleshooting

## Installation

### Using the install script (recommended)

1. Clone or download the repository
2. Run the installation script: `./install.sh`

This will:
- Install the CLI to `/usr/local/bin/clickup-cli`
- Create a configuration directory at `~/.clickup-cli`
- Set up a config file and log file

### Manual installation

1. Clone or download the script from `src/clickup-cli`
2. Make it executable: `chmod +x clickup-cli`
3. Optionally, move to your PATH: `mv clickup-cli /usr/local/bin/`

## Configuration

### Method 1: Configuration File (recommended)

The CLI automatically creates a configuration file at `~/.clickup-cli/config` when installed. Edit this file with your credentials:

```bash
# Edit the config file
nano ~/.clickup-cli/config
```

The config file format:
```bash
#!/bin/sh
export API_TOKEN="your_clickup_api_token_here"
export DEFAULT_WORKSPACE_ID="your_workspace_id"
export DEFAULT_CHANNEL_ID="your_channel_id"
```

### Method 2: Environment Variables

```bash
export API_TOKEN="your_clickup_api_token"
export DEFAULT_WORKSPACE_ID="your_workspace_id" 
export DEFAULT_CHANNEL_ID="your_channel_id"
```

### Getting Your Credentials

- **API Token**: Go to https://app.clickup.com/settings/apps and generate a token
- **Workspace ID**: Found in the URL when viewing your workspace
- **Channel ID**: Found in the URL when viewing a chat channel

## Logging and Debugging

The CLI automatically logs all activities to `~/.clickup-cli/log`. This includes:

- API calls and responses
- Error messages with timestamps
- Debug information when verbose mode is enabled

### Log file location
- Default: `~/.clickup-cli/log`
- Can be customized with the `LOG_FILE` environment variable

### Verbose mode
Use the `--verbose` or `-v` flag to enable detailed debug output. This will:
- Show API endpoints being called
- Display request/response data
- Add detailed timestamps to the log file

Example:
```bash
clickup-cli --verbose send message "Debug test"
```

## Usage

### Basic Examples

```bash
# Send a simple message (using config file or environment variables)
clickup-cli send message "Hello, world!"

# Send message with explicit workspace and channel
clickup-cli --workspace 123456 --channel 789012 send message "Hello!"

# Send message with inline parameters
clickup-cli send message "Hello team!" to 789012 in 123456

# Mixed usage (flags + inline)
clickup-cli --workspace 123456 send message "Status update" to 789012

# Enable verbose output for debugging
clickup-cli --verbose send message "Debug test"

# Show help
clickup-cli --help
```

### Advanced Examples

```bash
# Send multi-word message
clickup-cli send message "This is a longer message with multiple words"

# Send message with special characters
clickup-cli send message "Status: ✅ Complete! 🎉"

# Using different command aliases
clickup-cli send msg "Short form works too"
```

## Command Structure

The CLI follows a hierarchical command structure that makes it easy to extend:

```
clickup-cli [global-options] <command> <subcommand> [arguments]
```

### Global Options
- `-h, --help`: Show help
- `-w, --workspace <ID>`: Set workspace ID
- `-c, --channel <ID>`: Set channel ID  
- `-v, --verbose`: Enable debug output

### Commands
- `send message <text>`: Send a message
- `list workspaces`: List workspaces (planned)
- `list channels`: List channels (planned)
- `help`: Show help

## Error Handling

The CLI provides specific error messages for common issues:

- **401 Unauthorized**: Check your API token
- **403 Forbidden**: Check workspace/channel permissions
- **404 Not Found**: Workspace or channel doesn't exist
- **429 Rate Limited**: Too many requests, try again later

## Extending the CLI

The modular design makes it easy to add new features:

### Adding a New Command

1. Add the command to the main `case` statement in `parseArguments()`
2. Create a handler function like `handleNewCommand()`
3. Update the `showUsage()` function
4. Add any new global options as needed

### Example: Adding a "status" command

```bash
# In parseArguments()
status)
    handleStatusCommand "$@"
    ;;

# New handler function
handleStatusCommand() {
    echo "ClickUp CLI Status: OK"
    echo "API URL: $BASE_URL"
    echo "Workspace: ${WORKSPACE_ID:-"not set"}"
    echo "Channel: ${CHANNEL_ID:-"not set"}"
}
```

## Requirements

- POSIX shell (bash, zsh, dash, etc.)
- `curl` for API calls
- `jq` for JSON handling (optional - has built-in fallback)

## Troubleshooting

1. **Enable verbose mode**: Use `--verbose` to see debug information
2. **Check the log file**: View `~/.clickup-cli/log` for detailed error messages
3. **Check credentials**: Ensure API_TOKEN, workspace, and channel IDs are correct
4. **Test API access**: Try with minimal message first
5. **Check permissions**: Ensure your API token has access to the workspace/channel

## Future Enhancements

- [ ] List workspaces and channels
- [ ] Send files and attachments
- [ ] Read messages from channels
- [ ] Manage tasks and lists
- [ ] Support for templates and mentions
- [ ] Tab completion

## Contributing

Feel free to submit issues and pull requests to improve the CLI!