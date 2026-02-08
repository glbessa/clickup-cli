#!/bin/bash

# Handle 'send' subcommand with flexible syntax
handleSendCommand() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        message|msg)
            handleSendMessage "$@"
            ;;
        *)
            log "Error: Unknown send subcommand '$subcommand'"
            echo "Usage: $0 send message <text>"
            exit 1
            ;;
    esac
}

# Handle sending messages with flexible argument parsing
handleSendMessage() {
    local message=""

    # Parse message arguments - support quoted strings and concatenation
    while [ $# -gt 0 ]; do
        case "$1" in
            to)
                shift
                if [ -n "$1" ]; then
                    CHANNEL_ID="$1"
                    shift
                fi
                ;;
            in)
                shift
                if [ -n "$1" ]; then
                    WORKSPACE_ID="$1"
                    shift
                fi
                ;;
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -c|--channel) CHANNEL_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *)
                # Accumulate message text
                if [ -z "$message" ]; then
                    message="$1"
                else
                    message="$message $1"
                fi
                shift
                ;;
        esac
    done
    
    if [ -z "$message" ]; then
        log "Error: No message provided"
        echo "Usage: $0 send message <text> [to <channel>] [in <workspace>]"
        exit 1
    fi
    
    if [ -z "$WORKSPACE_ID" ] || [ -z "$CHANNEL_ID" ]; then
        log "Error: Workspace ID and Channel ID are required"
        log "Use --workspace and --channel flags or environment variables"
        exit 1
    fi
    
    sendMessageToChannel "$message"
}

sendMessageToChannel() {
    local message="$1"
    
    # Validate inputs
    if [ -z "$message" ]; then
        log "Error: Message cannot be empty"
        return 1
    fi
    
    if [ -z "$WORKSPACE_ID" ]; then
        log "Error: Workspace ID is required"
        return 1
    fi
    
    if [ -z "$CHANNEL_ID" ]; then
        log "Error: Channel ID is required"
        return 1
    fi
    
    if [ -z "$API_TOKEN" ]; then
        log "Error: API_TOKEN environment variable is required"
        return 1
    fi
    
    debug "Sending message to workspace:$WORKSPACE_ID channel:$CHANNEL_ID"
    debug "Message: $message"
    
    local endpoint="workspaces/$WORKSPACE_ID/chat/channels/$CHANNEL_ID/messages"
    local data
    
    if isJQAvailable; then
        data=$(jq -n --arg text "$message" '{type: "message", content_format: "text/plain", content: $text}')
    else
        local escapedMessage=$(escapeJson "$message")
        data="{\"type\": \"message\", \"content_format\": \"text/plain\", \"content\": \"$escapedMessage\"}"
    fi
    
    local response
    response=$(apiCall "$endpoint" "POST" "$data")
    local result=$?
    
    if [ $result -eq 0 ]; then
        log "Message sent successfully"
        if [ "$VERBOSE" = "1" ] && [ -n "$response" ]; then
            debug "Response: $response"
        fi
    else
        log "Failed to send message"
    fi
    
    return $result
}

handleListChannels() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    if [ -z "$WORKSPACE_ID" ]; then
        log "Error: Workspace ID is required to list channels"
        log "Use --workspace flag or set DEFAULT_WORKSPACE_ID"
        return 1
    fi

    local response
    # Chat channels are v3 specific
    response=$(apiCall "workspaces/$WORKSPACE_ID/chat/channels" "GET" "")
    
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "Channels (Chat) in Workspace $WORKSPACE_ID:"
    
    if isJQAvailable; then
        local channel_count=$(echo "$response" | jq '.channels | length // 0')
        
        if [ "$channel_count" -eq 0 ]; then
            echo "No chat channels found in this workspace."
            return 0
        fi

        echo -e "ID\t\tName"
        echo -e "--\t\t----"
        echo "$response" | jq -r '.channels[]? | "\(.id)\t\(.name)"'
    else
         # Basic fallback
        echo "$response"
    fi
}
