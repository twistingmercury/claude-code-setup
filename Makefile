.PHONY: help setup create destroy

default: help 

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nAvailable targets:\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

create: ## Does a complete setup - Cognee, agents, patterns...everything.
	./setup/scripts/installer.sh

destroy: ## Burn it all down!
	docker compose -f setup/docker-compose.yaml down -v

agents: ## Reinstalls just the agent defintions; no patterns or enrichment.
	./setup/scripts/01-install-agents.sh

skills: ## Reinstalls just the skills.
	./setup/scripts/02-install-skills.sh