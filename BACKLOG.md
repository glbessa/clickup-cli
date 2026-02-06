# Project Backlog & Improvement Plan

As a software engineering expert analysis of the `clickup-cli` project, the following improvements are proposed to enhance maintainability, scalability, and user experience.

## 1. Architecture & Refactoring

### 1.1. Modularization [DONE]
**Priority:** High
**Description:** The current `src/clickup-cli` is a monolithic script. We should leverage the empty `src/lib/` directory to split logic into reusable modules.
**Tasks:**
- [x] Extract logging logic (`log`, `debug`) to `src/lib/logger.sh`.
- [x] Extract API handling (`apiCall`, `escapeJson`, `isJQAvailable`) to `src/lib/api.sh`.
- [x] Extract configuration loading (`loadConfig`, `createClickupCliFolderIfNeeded`) to `src/lib/config.sh`.
- [x] Update the main entry point to source these files.

### 1.2. Strict POSIX Compliance or Bash Migration [DONE]
**Priority:** Medium
**Description:** The script uses `#!/bin/sh` but employs `local`, which is not strictly POSIX (though widely supported).
**Tasks:**
- [x] Decide on strict POSIX (remove `local` or use functional workarounds) OR explicitly target Bash (`#!/bin/bash`) for better feature support (arrays, stronger string manipulation).
- [x] *Recommendation:* Switch to Bash for robust array handling, which will be useful for JSON parsing and complex arguments.

## 2. Feature Implementation

### 2.1. Implement `list` Commands [DONE]
**Priority:** High
**Description:** The `list workspaces` and `list channels` commands are currently placeholders.
**Tasks:**
- [x] Implement `handleListWorkspaces`: GET `/team` endpoint.
- [x] Implement `handleListSpaces`: GET `/team/{team_id}/space`
- [x] Implement `handleListFolders`: GET `/space/{space_id}/folder`
- [x] Implement `handleListLists`: GET `/space/{space_id}/list` or `/folder/{folder_id}/list`
- [x] Output formatting: Use `printf` for tabular output or simple lists.

### 2.4. Implement Task Management [DONE]
**Priority:** High
**Description:** Enable users to manage tasks from the CLI.
**Tasks:**
- [x] Implement `create task` command.
- [x] Implement `list tasks` command.
- [x] Implement `show task` command.
- [x] Implement `update task` command.
- [x] Implement `delete task` command.

### 2.2. Interactive Configuration [DONE]
**Priority:** Medium
**Description:** Currently, users must manually edit `~/.clickup-cli/config`.
**Tasks:**
- [x] Create a `configure` command (e.g., `clickup-cli configure`).
- [x] Prompt user for API Token.
- [x] Validate the token immediately by making a test API call (e.g., list user).
- [x] Optionally guide user to select default Workspace/Channel from a list.

### 2.3. Shell Completion
**Priority:** Low
**Description:** Add tab completion for commands and flags to improve UX.
**Tasks:**
- Create a completion script for Bash (`clickup-cli.bash-completion`) and Zsh.
- Support completing commands (`send`, `list`) and flags (`--workspace`, `--verbose`).

## 3. Quality Assurance & Testing

### 3.1. Static Analysis (Linting)
**Priority:** High
**Description:** Ensure code quality and catch common shell pitfalls.
**Tasks:**
- Add a `.shellcheckrc` configuration.
- Run `shellcheck` against all source files.
- Fix identified warnings (quoting issues, unused variables, etc.).

### 3.2. Automated Testing
**Priority:** Medium
**Description:** No tests exist currently.
**Tasks:**
- Introduce a shell testing framework like [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core).
- Write unit tests for utility functions (JSON escaping, argument parsing).
- Write integration tests using mocked `curl` responses.

## 4. Installation & Distribution

### 4.1. Non-Root Installation [DONE]
**Priority:** Low
**Description:** `install.sh` requires `sudo`.
**Tasks:**
- [x] Update `install.sh` to allow installing to `~/.local/bin` (user space) if `sudo` access is not desired or available.
- [x] Check `$PATH` to ensure the installation directory is included.

### 4.2. Versioning
**Priority:** Low
**Description:** No versioning strategy is visible.
**Tasks:**
- Add a `VERSION` file or variable in the script.
- Add a `--version` flag to the CLI.
