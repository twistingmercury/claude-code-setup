.PHONY: help setup create destroy agents skills commands

default: help 

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nAvailable targets:\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

create: ## Does a complete setup - Cognee, agents, patterns...everything.
	./setup/scripts/installer.sh

destroy: ## Burn it all down!
	docker compose -f setup/docker-compose.yaml down -v

agents: ## reates a symlink to  $HOME/.claude/skills for each skill under ./agents.
	./setup/scripts/01-install-agents.sh
	./setup/scripts/04-install-global-agent-rules.sh

skills: ## Creates a symlink to  $HOME/.claude/skills for each skill under ./skills.
	./setup/scripts/02-install-skills.sh

commands: ## Creates a symlink to $HOME/.claude/commands for each command under ./commands/.
	./setup/scripts/03-install-commands.sh

