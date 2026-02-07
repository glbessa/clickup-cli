#!/bin/bash

log() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$message" >&2
    if [ -n "$LOG_FILE" ]; then
        echo "$timestamp - $message" >> "$LOG_FILE"
    fi
}

debug() {
    if [ "$VERBOSE" = "1" ]; then
        local message="$1"
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "[DEBUG] $message" >&2
        if [ -n "$LOG_FILE" ]; then
            echo "$timestamp [DEBUG] - $message" >> "$LOG_FILE"
        fi
    fi
}
