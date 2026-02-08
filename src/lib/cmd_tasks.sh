#!/bin/bash

# Handle 'create' subcommand
handleCreateCommand() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        task)
            handleCreateTask "$@"
            ;;
        *)
            log "Error: Unknown create subcommand '$subcommand'"
            echo "Usage: $0 create task <name> --list <id> [options]"
            exit 1
            ;;
    esac
}

handleCreateTask() {
    local name=""
    local list_id=""
    local description=""
    local priority=""
    local status=""

    # First argument is the task name
    if [ $# -gt 0 ] && [[ ! "$1" =~ ^- ]]; then
        name="$1"
        shift
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --list|-l) list_id="$2"; shift 2 ;;
            --description|-d) description="$2"; shift 2 ;;
            --priority|-p) priority="$2"; shift 2 ;;
            --status|-s) status="$2"; shift 2 ;;
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) 
                if [ -z "$name" ]; then
                    name="$1"
                else
                    name="$name $1"
                fi
                shift 
                ;;
        esac
    done

    if [ -z "$name" ]; then
        log "Error: Task name is required"
        return 1
    fi

    if [ -z "$list_id" ]; then
        log "Error: List ID is required (--list <id>)"
        return 1
    fi

    debug "Creating task '$name' in list $list_id"

    local data
    if isJQAvailable; then
        data=$(jq -n \
            --arg name "$name" \
            --arg desc "$description" \
            --arg prio "$priority" \
            --arg status "$status" \
            '{name: $name, description: $desc}')
        
        # Add priority and status if provided
        [ -n "$priority" ] && data=$(echo "$data" | jq --arg prio "$priority" '.priority = ($prio | tonumber)')
        [ -n "$status" ] && data=$(echo "$data" | jq --arg status "$status" '.status = $status')
    else
        local escapedName=$(escapeJson "$name")
        local escapedDesc=$(escapeJson "$description")
        data="{\"name\": \"$escapedName\", \"description\": \"$escapedDesc\""
        [ -n "$priority" ] && data="$data, \"priority\": $priority"
        [ -n "$status" ] && data="$data, \"status\": \"$status\""
        data="$data}"
    fi

    local response
    response=$(apiCall "https://api.clickup.com/api/v2/list/$list_id/task" "POST" "$data")
    
    if [ $? -eq 0 ]; then
        log "Task created successfully"
        if isJQAvailable; then
            local task_id=$(echo "$response" | jq -r '.id')
            local task_url=$(echo "$response" | jq -r '.url')
            echo "ID: $task_id"
            echo "URL: $task_url"
        fi
    else
        log "Failed to create task"
    fi
}

# Handle 'show' subcommand
handleShowCommand() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        task)
            handleShowTask "$@"
            ;;
        *)
            log "Error: Unknown show subcommand '$subcommand'"
            echo "Usage: $0 show task <id>"
            exit 1
            ;;
    esac
}

handleShowTask() {
    local task_id=""
    
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose) VERBOSE=1; shift ;;
            *) if [ -z "$task_id" ]; then task_id="$1"; fi; shift ;;
        esac
    done

    if [ -z "$task_id" ]; then
        log "Error: Task ID is required"
        return 1
    fi

    local response
    response=$(apiCall "https://api.clickup.com/api/v2/task/$task_id" "GET" "")
    if [ $? -ne 0 ]; then return 1; fi

    if isJQAvailable; then
        echo "$response" | jq -r '
            "ID: \(.id)\n" +
            "Name: \(.name)\n" +
            "Status: \(.status.status)\n" +
            "Priority: \(.priority.priority // "none")\n" +
            "URL: \(.url)\n" +
            "Description:\n\(.description // "No description")"
        '
    else
        echo "$response"
    fi
}

# Handle 'update' subcommand
handleUpdateCommand() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        task)
            handleUpdateTask "$@"
            ;;
        *)
            log "Error: Unknown update subcommand '$subcommand'"
            echo "Usage: $0 update task <id> [options]"
            exit 1
            ;;
    esac
}

handleUpdateTask() {
    local task_id="$1"
    shift
    
    if [ -z "$task_id" ]; then
        log "Error: Task ID is required"
        return 1
    fi

    local name=""
    local description=""
    local priority=""
    local status=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --name|-n) name="$2"; shift 2 ;;
            --description|-d) description="$2"; shift 2 ;;
            --priority|-p) priority="$2"; shift 2 ;;
            --status|-s) status="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    local data="{"
    local first=1
    
    if [ -n "$name" ]; then
        data="$data \"name\": \"$(escapeJson "$name")\""
        first=0
    fi
    if [ -n "$description" ]; then
        [ $first -eq 0 ] && data="$data,"
        data="$data \"description\": \"$(escapeJson "$description")\""
        first=0
    fi
    if [ -n "$priority" ]; then
        [ $first -eq 0 ] && data="$data,"
        data="$data \"priority\": $priority"
        first=0
    fi
    if [ -n "$status" ]; then
        [ $first -eq 0 ] && data="$data,"
        data="$data \"status\": \"$status\""
        first=0
    fi
    data="$data }"

    if [ $first -eq 1 ]; then
        log "Error: No fields to update provided"
        return 1
    fi

    apiCall "https://api.clickup.com/api/v2/task/$task_id" "PUT" "$data" >/dev/null
    if [ $? -eq 0 ]; then
        log "Task $task_id updated successfully"
    else
        log "Failed to update task $task_id"
    fi
}

# Handle 'delete' subcommand
handleDeleteCommand() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        task)
            handleDeleteTask "$@"
            ;;
        *)
            log "Error: Unknown delete subcommand '$subcommand'"
            echo "Usage: $0 delete task <id>"
            exit 1
            ;;
    esac
}

handleDeleteTask() {
    local task_id=""
    local force=0
    
    while [ $# -gt 0 ]; do
        case "$1" in
            -y|--yes) force=1; shift ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) if [ -z "$task_id" ]; then task_id="$1"; fi; shift ;;
        esac
    done

    if [ -z "$task_id" ]; then
        log "Error: Task ID is required"
        return 1
    fi

    if [ $force -eq 0 ]; then
        printf "Are you sure you want to delete task $task_id? [y/N] "
        read confirm
        if [[ ! "$confirm" =~ ^[yY] ]]; then
            echo "Aborted."
            return 0
        fi
    fi

    apiCall "https://api.clickup.com/api/v2/task/$task_id" "DELETE" "" >/dev/null
    if [ $? -eq 0 ]; then
        log "Task $task_id deleted successfully"
    else
        log "Failed to delete task $task_id"
    fi
}

handleListTasks() {
    local list_id=""
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --list|-l) list_id="$2"; shift 2 ;;
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    if [ -z "$list_id" ]; then
        log "Error: --list <id> is required to list tasks"
        return 1
    fi

    local response
    response=$(apiCall "https://api.clickup.com/api/v2/list/$list_id/task" "GET" "")
    
    if [ $? -ne 0 ]; then return 1; fi

    echo "Tasks in List $list_id:"
    printf "%-15s %-10s %-10s %s\n" "ID" "STATUS" "PRIORITY" "NAME"
    printf "%-15s %-10s %-10s %s\n" "--" "------" "--------" "----"
    
    if isJQAvailable; then
        echo "$response" | jq -r '.tasks[] | "\(.id)\t\(.status.status)\t\(.priority.priority // "none")\t\(.name)"' | while IFS=$'\t' read -r id status prio name; do
            printf "%-15s %-10s %-10s %s\n" "$id" "$status" "$prio" "$name"
        done
    else
        # Very basic fallback
        echo "$response" | tr '}' '\n' | grep -o '"id":"[^"]*","name":"[^"]*"' | sed 's/"id":"\([^"]*\)","name":"\([^"]*\)"/\1\t\2/'
    fi
}
