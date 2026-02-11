#!/usr/bin/env bash

set -e

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
SETUP_DIR="${SETUP_DIR:-$(cd "${SCRIPTS}/.." && pwd)}"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SETUP_DIR}/.." && pwd)}"

# Logging setup
TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"
LOG_DIR="${SCRIPTS}/logs/${TIMESTAMP}"
LOG_FILE="${LOG_DIR}/01-install-agents.log"

mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG_FILE}") 2>&1

printf "Logging to: %s\n" "${LOG_FILE}"

AGENT_SOURCE="${PROJ_ROOT}/agents"
AGENTS_DIR="${AGENTS_DIR:-${HOME}/.claude/agents/}"

validate_environment() {
    if [ -z "${AGENTS_DIR}" ]; then
        printf "ERROR: AGENTS_DIR is not set\n" >&2
        return 1
    fi

    if [ ! -d "${AGENT_SOURCE}" ]; then
        printf "ERROR: cannot locate the projects agent definitions directory: %s\n" "${AGENT_SOURCE}" >&2
        return 1
    fi

    return 0
}

# Build a list of agent basenames from the source directory.
# An agent is any .md file in a subdirectory of agents/ (excludes top-level files
# like ABOUT-THE-AGENTS.md).
build_source_agent_list() {
    find "${AGENT_SOURCE}" -mindepth 2 -type f -name "*.md" -exec basename {} \;
}

is_project_agent() {
    local agent_basename="${1}"
    local source_agents="${2}"

    printf '%s\n' "${source_agents}" | grep -qxF "${agent_basename}"
}

remove_project_agents() {
    local removed_count=0
    local preserved_count=0
    local source_agents
    source_agents="$(build_source_agent_list)"

    if [ ! -d "${AGENTS_DIR}" ]; then
        return 0
    fi

    printf "Scanning existing agents...\n"

    for agent_file in "${AGENTS_DIR}"/*.md; do
        if [ ! -f "${agent_file}" ]; then
            continue
        fi

        local agent_name
        agent_name="$(basename "${agent_file}")"

        if is_project_agent "${agent_name}" "${source_agents}"; then
            printf "  Removing project agent: %s\n" "${agent_name}"
            rm -f "${agent_file}"
            removed_count=$((removed_count + 1))
        else
            printf "  Preserving user agent: %s\n" "${agent_name}"
            preserved_count=$((preserved_count + 1))
        fi
    done

    printf "Removed %d project agent(s), preserved %d user agent(s)\n" "${removed_count}" "${preserved_count}"
    return 0
}

install_project_agents() {
    local installed_count=0

    printf "Installing project agents from %s...\n" "${AGENT_SOURCE}"

    while IFS= read -r source_file; do
        local agent_name
        agent_name="$(basename "${source_file}")"

        cp "${source_file}" "${AGENTS_DIR}${agent_name}"
        printf "  Installed: %s\n" "${agent_name}"
        installed_count=$((installed_count + 1))
    done < <(find "${AGENT_SOURCE}" -mindepth 2 -type f -name "*.md")

    printf "Installed %d project agent(s)\n" "${installed_count}"
    return 0
}

install_agents() {
    if ! validate_environment; then
        return 1
    fi

    if [ ! -d "${AGENTS_DIR}" ]; then
        printf "Creating agents directory: %s\n" "${AGENTS_DIR}"
        mkdir -p "${AGENTS_DIR}"
    fi

    if ! remove_project_agents; then
        printf "ERROR: failed to remove project agents\n" >&2
        return 1
    fi

    if ! install_project_agents; then
        printf "ERROR: failed to install project agents\n" >&2
        return 1
    fi

    printf "\nSUCCESS: all agents updated\n"
    return 0
}

install_agents
