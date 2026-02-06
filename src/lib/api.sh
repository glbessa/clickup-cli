#!/bin/bash

BASE_URL="${BASE_URL:-https://api.clickup.com/api/v2}"

apiCall() {
    local endpoint="$1"
    local method="$2"
    local data="$3"
    
    local url="$BASE_URL/$endpoint"
    
    debug "Making API call: $method $url"
    debug "Data: $data"

    local response
    response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" \
        -H "Authorization: $API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$data" 2>/dev/null)

    if [ $? -ne 0 ]; then
        log "Error: Failed to connect to ClickUp API"
        return 1
    fi

    # Extract HTTP status code (last line)
    local http_code=$(echo "$response" | tail -n1)
    local response_body=$(echo "$response" | sed '$d')
    
    debug "HTTP Status: $http_code"
    debug "Response: $response_body"

    # Check for successful HTTP status codes
    case "$http_code" in
        2*)
            debug "API call successful"
            echo "$response_body"
            return 0
            ;;
        401)
            log "Error: Authentication failed. Check your API_TOKEN"
            return 1
            ;;
        403)
            log "Error: Permission denied. Check workspace and channel permissions"
            return 1
            ;;
        404)
            log "Error: Workspace or channel not found"
            return 1
            ;;
        429)
            log "Error: Rate limit exceeded. Please try again later"
            return 1
            ;;
        *)
            log "Error: API call failed with HTTP status $http_code"
            if [ -n "$response_body" ]; then
                log "Response: $response_body"
            fi
            return 1
            ;;
    esac
}

isJQAvailable() {
    if command -v jq >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

escapeJson() {
    local str="$1"
    str=$(echo "$str" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/\n/\\n/g' | sed 's/\r/\\r/g')
    echo "$str"
}