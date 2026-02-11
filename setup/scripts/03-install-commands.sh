#!/usr/bin/env bash

set -e

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
SETUP_DIR="${SETUP_DIR:-$(cd "${SCRIPTS}/.." && pwd)}"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SETUP_DIR}/.." && pwd)}"

# Logging setup
TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"
LOG_DIR="${SCRIPTS}/logs/${TIMESTAMP}"
LOG_FILE="${LOG_DIR}/03-install-commands.log"

mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG_FILE}") 2>&1

printf "Logging to: %s\n" "${LOG_FILE}"

COMMAND_SOURCE="${PROJ_ROOT}/agents/commands"
COMMANDS_DIR="${COMMANDS_DIR:-${HOME}/.claude/commands/}"

validate_environment() {
    if [ -z "${COMMANDS_DIR}" ]; then
        printf "ERROR: COMMANDS_DIR is not set\n" >&2
        return 1
    fi

    if [ ! -d "${COMMAND_SOURCE}" ]; then
        printf "ERROR: cannot locate the projects command directory: %s\n" "${COMMAND_SOURCE}" >&2
        return 1
    fi

    return 0
}

# Build a list of command basenames from the source directory.
# A command is any .md file in agents/commands/
list_repo_commands() {
    find "${COMMAND_SOURCE}" -type f -name "*.md" -exec basename {} \;
}

is_repo_managed_command() {
    local cmd_basename="${1}"
    local source_commands="${2}"

    printf '%s\n' "${source_commands}" | grep -qxF "${cmd_basename}"
}

remove_repo_managed_commands() {
    local removed_count=0
    local preserved_count=0
    local source_commands
    source_commands="$(list_repo_commands)"

    if [ ! -d "${COMMANDS_DIR}" ]; then
        return 0
    fi

    printf "Scanning existing commands...\n"

    for cmd_file in "${COMMANDS_DIR}"*.md; do
        if [ ! -f "${cmd_file}" ] && [ ! -L "${cmd_file}" ]; then
            continue
        fi

        local cmd_name
        cmd_name="$(basename "${cmd_file}")"

        if is_repo_managed_command "${cmd_name}" "${source_commands}"; then
            printf "  Removing repo command: %s\n" "${cmd_name}"
            rm -f "${cmd_file}"
            removed_count=$((removed_count + 1))
        else
            printf "  Preserving user command: %s\n" "${cmd_name}"
            preserved_count=$((preserved_count + 1))
        fi
    done

    printf "Removed %d repo command(s), preserved %d user command(s)\n" "${removed_count}" "${preserved_count}"
    return 0
}

symlink_repo_commands() {
    local installed_count=0

    printf "Installing repo commands from %s...\n" "${COMMAND_SOURCE}"

    while IFS= read -r source_file; do
        local cmd_name
        cmd_name="$(basename "${source_file}")"

        ln -s "${source_file}" "${COMMANDS_DIR}${cmd_name}"
        printf "  Installed: %s\n" "${cmd_name}"
        installed_count=$((installed_count + 1))
    done < <(find "${COMMAND_SOURCE}" -type f -name "*.md")

    printf "Installed %d repo command(s)\n" "${installed_count}"
    return 0
}

install_commands() {
    if ! validate_environment; then
        return 1
    fi

    if [ ! -d "${COMMANDS_DIR}" ]; then
        printf "Creating commands directory: %s\n" "${COMMANDS_DIR}"
        mkdir -p "${COMMANDS_DIR}"
    fi

    if ! remove_repo_managed_commands; then
        printf "ERROR: failed to remove repo commands\n" >&2
        return 1
    fi

    if ! symlink_repo_commands; then
        printf "ERROR: failed to install repo commands\n" >&2
        return 1
    fi

    printf "\nSUCCESS: all commands updated\n"
    return 0
}

install_commands
