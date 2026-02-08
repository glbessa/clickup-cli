#!/bin/bash

# Handle 'list' subcommand
handleListCommand() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        workspaces|teams)
            handleListWorkspaces "$@"
            ;;
        spaces)
            handleListSpaces "$@"
            ;;
        folders)
            handleListFolders "$@"
            ;;
        lists)
            handleListLists "$@"
            ;;
        shared)
            handleListShared "$@"
            ;;
        tasks)
            handleListTasks "$@"
            ;;
        channels)
            handleListChannels "$@"
            ;;
        *)
            log "Error: Unknown list subcommand '$subcommand'"
            echo "Usage: $0 list [workspaces|spaces|folders|lists|channels]"
            exit 1
            ;;
    esac
}

handleListWorkspaces() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    local response
    # v2 is required for listing teams/workspaces as of now
    response=$(apiCall "https://api.clickup.com/api/v2/team" "GET" "")
    
    if [ $? -ne 0 ]; then
        return 1
    fi

    echo "Workspaces:"
    echo "ID\t\tName"
    echo "--\t\t----"
    
    if isJQAvailable; then
        echo "$response" | jq -r '.teams[] | "\(.id)\t\(.name)"'
    else
        # Basic fallback for simple JSON structure
        # Assumes standard formatting, highly brittle
        echo "$response" | tr '}' '\n' | grep -o '"id":"[^"]*","name":"[^"]*"' | sed 's/"id":"\([^"]*\)","name":"\([^"]*\)"/\1\t\2/'
    fi
}

handleListSpaces() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    local team_id="${WORKSPACE_ID}"
    if [ -z "$team_id" ]; then
        log "Error: Workspace (Team) ID is required. Use --workspace or set DEFAULT_WORKSPACE_ID."
        return 1
    fi

    local response
    response=$(apiCall "https://api.clickup.com/api/v2/team/$team_id/space" "GET" "")
    
    if [ $? -ne 0 ]; then return 1; fi

    echo "Spaces in Workspace $team_id:"
    echo -e "ID\t\tName"
    echo -e "--\t\t----"
    
    if isJQAvailable; then
        echo "$response" | jq -r '.spaces[] | "\(.id)\t\(.name)"'
    else
        echo "$response" | tr '}' '\n' | grep -o '"id":"[^"]*","name":"[^"]*"' | sed 's/"id":"\([^"]*\)","name":"\([^"]*\)"/\1\t\2/'
    fi
}

handleListFolders() {
    local space_id=""
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --space) space_id="$2"; shift 2 ;;
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    if [ -z "$space_id" ]; then
        log "Error: --space <id> is required to list folders"
        return 1
    fi

    local response
    response=$(apiCall "https://api.clickup.com/api/v2/space/$space_id/folder" "GET" "")
    
    if [ $? -ne 0 ]; then return 1; fi

    echo "Folders in Space $space_id:"
    echo -e "ID\t\tName"
    echo -e "--\t\t----"
    
    if isJQAvailable; then
        echo "$response" | jq -r '.folders[] | "\(.id)\t\(.name)"'
    else
        echo "$response" | tr '}' '\n' | grep -o '"id":"[^"]*","name":"[^"]*"' | sed 's/"id":"\([^"]*\)","name":"\([^"]*\)"/\1\t\2/'
    fi
}

handleListLists() {
    local space_id=""
    local folder_id=""
    
    while [ $# -gt 0 ]; do
        case "$1" in
            --space) space_id="$2"; shift 2 ;;
            --folder) folder_id="$2"; shift 2 ;;
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    local url=""
    local context=""
    if [ -n "$folder_id" ]; then
        url="https://api.clickup.com/api/v2/folder/$folder_id/list"
        context="Folder $folder_id"
    elif [ -n "$space_id" ]; then
        url="https://api.clickup.com/api/v2/space/$space_id/list"
        context="Space $space_id"
    else
        log "Error: --space <id> or --folder <id> is required to list lists"
        return 1
    fi

    local response
    response=$(apiCall "$url" "GET" "")
    
    if [ $? -ne 0 ]; then return 1; fi

    echo "Lists in $context:"
    echo -e "ID\t\tName"
    echo -e "--\t\t----"
    
    if isJQAvailable; then
        echo "$response" | jq -r '.lists[] | "\(.id)\t\(.name)"'
    else
        echo "$response" | tr '}' '\n' | grep -o '"id":"[^"]*","name":"[^"]*"' | sed 's/"id":"\([^"]*\)","name":"\([^"]*\)"/\1\t\2/'
    fi
}

handleListShared() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -w|--workspace) WORKSPACE_ID="$2"; shift 2 ;;
            -v|--verbose) VERBOSE=1; shift ;;
            *) shift ;;
        esac
    done

    local team_id="${WORKSPACE_ID}"
    if [ -z "$team_id" ]; then
        log "Error: Workspace (Team) ID is required. Use --workspace or set DEFAULT_WORKSPACE_ID."
        return 1
    fi

    local response
    response=$(apiCall "https://api.clickup.com/api/v2/team/$team_id/shared" "GET" "")
    
    if [ $? -ne 0 ]; then return 1; fi

    if [ "$VERBOSE" = "1" ]; then
        debug "Response: $response"
    fi

    echo "Shared Hierarchy in Workspace $team_id:"
    
    if isJQAvailable; then
        local folder_count=$(echo "$response" | jq '(.shared.folders // .folders // []) | length')
        local list_count=$(echo "$response" | jq '(.shared.lists // .lists // []) | length')
        local task_count=$(echo "$response" | jq '(.shared.tasks // .tasks // []) | length')

        if [ "$folder_count" -eq 0 ] && [ "$list_count" -eq 0 ] && [ "$task_count" -eq 0 ]; then
            echo "No shared folders, lists or tasks found."
            return 0
        fi

        if [ "$folder_count" -gt 0 ]; then
            echo -e "\nFOLDERS:"
            echo -e "ID\t\tName"
            echo "$response" | jq -r '(.shared.folders // .folders)[] | "\(.id)\t\(.name)"'
        fi

        if [ "$list_count" -gt 0 ]; then
            echo -e "\nLISTS:"
            echo -e "ID\t\tName"
            echo "$response" | jq -r '(.shared.lists // .lists)[] | "\(.id)\t\(.name)"'
        fi

        if [ "$task_count" -gt 0 ]; then
            echo -e "\nTASKS:"
            echo -e "ID\t\tName"
            echo "$response" | jq -r '(.shared.tasks // .tasks)[] | "\(.id)\t\(.name)"'
        fi
    else
        echo "$response"
    fi
}
