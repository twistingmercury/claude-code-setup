#!/usr/bin/env bash

set -e

# shellcheck disable=SC1091

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
SETUP_DIR="${SETUP_DIR:-$(cd "${SCRIPTS}/.." && pwd)}"
PROJ_ROOT="${PROJ_ROOT:-$(cd "${SETUP_DIR}/.." && pwd)}"

echo "${SCRIPTS}"
echo "${SETUP_DIR}"
echo "${PROJ_ROOT}"

# Set shared timestamp for all logs during this install run
export TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"

# shellcheck source=../lib/print.sh
. "${SETUP_DIR}/lib/print.sh"

main(){
    print::info "Starting agent setup installation..."

    print::info "Step 1/8: Starting memory infrastructure..."
    if ! "${SCRIPTS}/00-start-memory-infra.sh"; then
        print::error "Failed to start memory infrastructure"
        return 1
    fi

    print::info "Step 2/8: Installing agent definitions..."
    if ! "${SCRIPTS}/01-install-agents.sh"; then
        print::error "Failed to install agent definitions"
        return 2
    fi

    print::info "Step 3/8: Installing skills..."
    if ! "${SCRIPTS}/02-install-skills.sh"; then
        print::error "Failed to install skills"
        return 3
    fi

    print::info "Step 4/8: Installing commands..."
    if ! "${SCRIPTS}/03-install-commands.sh"; then
        print::error "Failed to install commands"
        return 4
    fi

    print::info "Step 5/8: Installing global agent rules..."
    if ! "${SCRIPTS}/04-install-global-agent-rules.sh"; then
        print::error "Failed to install global agent rules"
        return 5
    fi

    print::info "Step 6/8: Validating pattern metadata..."
    if ! "${SCRIPTS}/05-validate-metadata.sh"; then
        print::error "Failed to validate metadata"
        return 6
    fi

    print::info "Step 7/8: Loading patterns..."
    if ! "${SCRIPTS}/06-load-patterns.sh"; then
        print::error "Failed to load patterns"
        return 7
    fi

    print::info "Step 8/8: Enriching patterns with relationships..."

    if [ ! -f "${SCRIPTS}/logs/${TIMESTAMP}/datasets-loaded.txt" ]; then
        print::error "expected file datasets-loaded.txt not found"
        return 7
    fi

    mapfile -t datasets < "${SCRIPTS}/logs/${TIMESTAMP}/datasets-loaded.txt"

    failed_count=0
    for ds in "${datasets[@]}"; do
        if ! echo "${ds}" | "${SCRIPTS}/07-enrich-patterns.sh"; then
            print::error "Failed to enrich dataset ${ds}"
            failed_count=$((failed_count + 1))
        else
            print::success "Successfully enriched dataset ${ds}"
        fi
    done

    if [ "${failed_count}" -gt 0 ]; then
        print::error "Failed to enrich ${failed_count} dataset(s)"
        return 8
    fi

    return 0
}

main "$@"