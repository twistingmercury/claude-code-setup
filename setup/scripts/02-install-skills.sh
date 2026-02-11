#!/usr/bin/env bash

set -e

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
SETUP_DIR="${SETUP_DIR:-$(cd "${SCRIPTS}/.." && pwd)}"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SETUP_DIR}/.." && pwd)}"

# Logging setup
TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"
LOG_DIR="${SCRIPTS}/logs/${TIMESTAMP}"
LOG_FILE="${LOG_DIR}/02-install-skills.log"

mkdir -p "${LOG_DIR}"
exec > >(tee -a "${LOG_FILE}") 2>&1

printf "Logging to: %s\n" "${LOG_FILE}"

SKILL_SOURCE="${PROJ_ROOT}/skills"
SKILLS_DIR="${SKILLS_DIR:-${HOME}/.claude/skills/}"

validate_environment() {
    if [ -z "${SKILLS_DIR}" ]; then
        printf "ERROR: SKILLS_DIR is not set\n" >&2
        return 1
    fi

    if [ ! -d "${SKILL_SOURCE}" ]; then
        printf "ERROR: cannot locate the projects skill directory: %s\n" "${SKILL_SOURCE}" >&2
        return 1
    fi

    return 0
}

# Build a list of skill directory names from the source.
# A skill is any subdirectory of skills/ that contains a SKILL.md file.
list_repo_skills() {
    find "${SKILL_SOURCE}" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;
}

is_repo_managed_skill() {
    local skill_name="${1}"
    local source_skills="${2}"

    printf '%s\n' "${source_skills}" | grep -qxF "${skill_name}"
}

remove_repo_managed_skills() {
    local removed_count=0
    local preserved_count=0
    local source_skills
    source_skills="$(list_repo_skills)"

    if [ ! -d "${SKILLS_DIR}" ]; then
        return 0
    fi

    printf "Scanning existing skills...\n"

    for skill_dir in "${SKILLS_DIR}"*/; do
        if [ ! -d "${skill_dir}" ] && [ ! -L "${skill_dir}" ]; then
            continue
        fi

        local skill_name
        skill_name="$(basename "${skill_dir}")"

        if is_repo_managed_skill "${skill_name}" "${source_skills}"; then
            printf "  Removing repo skill: %s\n" "${skill_name}"
            rm -f "${skill_dir}"
            removed_count=$((removed_count + 1))
        else
            printf "  Preserving user skill: %s\n" "${skill_name}"
            preserved_count=$((preserved_count + 1))
        fi
    done

    printf "Removed %d repo skill(s), preserved %d user skill(s)\n" "${removed_count}" "${preserved_count}"
    return 0
}

symlink_repo_skills() {
    local installed_count=0

    printf "Installing repo skills from %s...\n" "${SKILL_SOURCE}"

    while IFS= read -r source_dir; do
        local skill_name
        skill_name="$(basename "${source_dir}")"

        ln -s "${source_dir}" "${SKILLS_DIR}${skill_name}"
        printf "  Installed: %s\n" "${skill_name}"
        installed_count=$((installed_count + 1))
    done < <(find "${SKILL_SOURCE}" -mindepth 1 -maxdepth 1 -type d)

    printf "Installed %d repo skill(s)\n" "${installed_count}"
    return 0
}

install_skills() {
    if ! validate_environment; then
        return 1
    fi

    if [ ! -d "${SKILLS_DIR}" ]; then
        printf "Creating skills directory: %s\n" "${SKILLS_DIR}"
        mkdir -p "${SKILLS_DIR}"
    fi

    if ! remove_repo_managed_skills; then
        printf "ERROR: failed to remove repo skills\n" >&2
        return 1
    fi

    if ! symlink_repo_skills; then
        printf "ERROR: failed to install repo skills\n" >&2
        return 1
    fi

    printf "\nSUCCESS: all skills updated\n"
    return 0
}

install_skills
