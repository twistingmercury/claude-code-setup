# Claude Code Agent Ecosystem

> **Maturity Level**: ARCHIVED - No longer used. All attention is now on [Mnemonic](https://github.com/twistingmercury/mnemonic)
>
> - **Emerging**: Prototype, not production-ready, expect breaking changes
> - **Basic**: Production-ready but actively evolving, expect minor version changes
> - **Mature**: Stable, battle-tested, changes are rare
> - **Archived**: No longer maintained, but left readonly for others to fork and use.

---

> NOTE: The skill `/rlm` is licensed separately as it is a work derived from John Adeojo (brainqub3). The project is here: https://github.com/brainqub3/claude_code_RLM

Specialized development agents and reusable patterns for AI-assisted software development with Claude Code. Main Claude acts as a coordinator, delegating architecture, implementation, testing, deployment, and documentation tasks to purpose-built specialist agents that retrieve best-practice patterns from a Cognee knowledge graph.

## Usage

### Invoking agents

Agents are invoked by Main Claude through the Task tool based on the type of work requested. You do not call agents directly; instead, describe what you need and Main Claude delegates to the appropriate specialist.

```text
User: "Build a user management REST API in Go"

Main Claude:
  1. Consults solution-architect-agent for high-level architecture
  2. Delegates to go-architect-agent for implementation planning
  3. Sends API spec work to api-architect-agent
  4. Hands implementation to go-software-agent
  5. Sends test creation to go-e2e-test-agent
  6. Delegates deployment to go-devops-agent
```

For single-purpose tasks, Main Claude delegates directly:

```text
User: "Write BATS tests for scripts/backup.sh"
  -> Main Claude delegates to bats-test-agent

User: "Design a PostgreSQL schema for multi-tenant SaaS"
  -> Main Claude delegates to data-architect-agent, then data-engineer-agent

User: "Update the project README"
  -> Main Claude delegates to documentation-agent
```

### Using skills

Skills are multi-agent orchestration workflows invoked with slash commands:

- `/shell-script` -- Creates a production-grade shell script with automatic BATS test generation and an iterative fix loop until all tests pass.
- `/code-review` -- Runs a 3-agent parallel code review (code-review-agent + solution-architect-agent + go-architect-agent) with synthesis and reconciliation.

```text
User: /shell-script Create a backup script for Docker volumes
User: /code-review src/handlers/
User: /code-review #42
User: /code-review --diff
```

### Agent delegation reference

| Task type                                   | Specialist agent           |
| ------------------------------------------- | -------------------------- |
| System architecture (language-agnostic)     | `solution-architect-agent` |
| Go architecture and implementation planning | `go-architect-agent`       |
| API specification (REST, GraphQL, gRPC)     | `api-architect-agent`      |
| Database schema design                      | `data-architect-agent`     |
| SQL, Cypher, migrations                     | `data-engineer-agent`      |
| Go implementation                           | `go-software-agent`        |
| Python implementation                       | `python-software-agent`    |
| .NET implementation                         | `dotnet-software-agent`    |
| React implementation                        | `react-software-agent`     |
| Shell script creation                       | `/shell-script` skill      |
| Go end-to-end tests                         | `go-e2e-test-agent`        |
| BATS shell tests                            | `bats-test-agent`          |
| Docker, CI/CD, Kubernetes                   | `go-devops-agent`          |
| Documentation                               | `documentation-agent`      |
| Code review and pattern compliance          | `/code-review` skill       |

See [ABOUT-THE-AGENTS.md](agents/ABOUT-THE-AGENTS.md) for complete workflows, decision trees, and examples.

## How it works

Main Claude is the coordinator. It never writes code or designs systems itself. Instead, it identifies the type of work requested, consults the delegation table, and routes tasks to specialist agents using the Task tool.

**Specialist agents** are organized by role:

- **Architects** (solution-architect, go-architect, api-architect, data-architect) design systems and return recommendations to Main Claude. They are consultants, not coordinators.
- **Engineers** (go-software, python-software, dotnet-software, react-software, shell-script, data-engineer) implement services, APIs, CLIs, infrastructure, and database migrations.
- **Test engineers** (go-e2e-test, bats-test) create comprehensive test coverage.
- **DevOps engineers** (go-devops) handle containerization, orchestration, and CI/CD.
- **Documentation** (documentation-agent) maintains project docs.
- **Reviewers** (code-review-agent) validate code against patterns and best practices.

**Cognee knowledge graph** stores all development patterns instead of embedding them in agent prompts. This reduces agent prompt sizes by roughly 80% while providing comprehensive pattern libraries on demand. Agents query Cognee at task time for relevant patterns (API design, testing strategies, Go conventions, DevOps templates, etc.) and adapt them to the specific requirements.

**Pattern library** -- The `patterns/` directory contains reusable templates organized by domain (API, CLI, data, DevOps, e2e, engineering guidelines, Go, shell scripting, BATS). Each pattern includes YAML frontmatter metadata for Cognee ingestion. See [PATTERN-METADATA-SCHEMA.md](patterns/PATTERN-METADATA-SCHEMA.md) for the metadata specification.

**Trade-offs:**

- Cognee dependency: All pattern retrieval requires a running Cognee instance (Docker containers for PostgreSQL, Neo4j, and the Cognee MCP/API servers). Without Cognee, agents still function but lose access to the pattern library.
- Agent coordination overhead: Multi-agent delegation adds latency compared to a single monolithic prompt, but enables separation of concerns and smaller, more focused context windows.
- Initial setup time: The full installation (Docker services, pattern loading, knowledge graph enrichment) takes 10-15 minutes, though it is a one-time cost.

## Key Considerations

**This is a reference implementation, not a framework.** Adapt the agents, patterns, and coordination rules to fit your project's needs. The architecture is intentionally opinionated to demonstrate one effective approach to multi-agent coordination.

**Cognee MCP is required for pattern retrieval.** Agents depend on the Cognee knowledge graph to retrieve development patterns at task time. Setup instructions are in [setup/README.md](setup/README.md).

**Prerequisites:**

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with MCP support
- [Docker](https://docs.docker.com/engine/install/) 27+
- [Docker Compose](https://docs.docker.com/compose/install/) 2.32+
- [Bash](https://www.gnu.org/software/bash/) 4.x+ (required for MAPFILE support in install scripts)
- [yq](https://github.com/mikefarah/yq#install) 4.x+ (pattern metadata parsing)
- [jq](https://jqlang.github.io/jq/download/) 1.6+ (pattern validation)
- [curl](https://curl.se/download.html) 7.x+ (health checks and API calls in scripts)
- An OpenAI API key (set as `OPENAI_COGNEE_API_KEY` environment variable; used by Cognee for embeddings)

**System resources:** 8-12 GB RAM recommended. Cognee services, PostgreSQL, and Neo4j run as Docker containers and are memory-intensive. See [setup/README.md](setup/README.md) for port requirements and resource breakdown.

**Security:** The `OPENAI_COGNEE_API_KEY` is passed to Docker containers via environment variable. Do not commit it to version control. The default Cognee database credentials in `docker-compose.yaml` are intended for local development only.

**Breaking changes:** The agent coordination model, pattern metadata schema, and Cognee integration are under active development. Expect changes to agent frontmatter fields, delegation rules, and pattern structure between releases.

## Development Considerations

### Quick Start

1. Set the OpenAI API key:

   ```bash
   export OPENAI_COGNEE_API_KEY=your-api-key-here
   ```

2. Run the installer from the `setup/` directory:

   ```bash
   cd setup
   ./scripts/installer.sh
   ```

3. Restart Claude Code to pick up installed agents and skills.

4. Review [ABOUT-THE-AGENTS.md](agents/ABOUT-THE-AGENTS.md) for agent coordination patterns and workflows.

### Building & running

The `setup/scripts/installer.sh` script orchestrates the complete setup by running numbered scripts in sequence:

| Script                             | Purpose                                                                               |
| ---------------------------------- | ------------------------------------------------------------------------------------- |
| `00-start-memory-infra.sh`         | Start Cognee Docker services (MCP, API, PostgreSQL, Neo4j) and wait for health checks |
| `01-install-agents.sh`             | Copy agent definitions to `~/.claude/agents/` (preserves user-created agents)         |
| `02-install-skills.sh`             | Copy skill definitions to `~/.claude/skills/`                                         |
| `03-install-commands.sh`           | Install command definitions to `~/.claude/commands/`                                  |
| `04-install-global-agent-rules.sh` | Install coordination rules to `~/.claude/CLAUDE.md`                                   |
| `05-validate-metadata.sh`          | Validate YAML frontmatter on all pattern files                                        |
| `06-load-patterns.sh`              | Load pattern files into Cognee datasets via REST API                                  |
| `07-enrich-patterns.sh`            | Process loaded patterns into knowledge graph relationships                            |

All logs are written to `setup/scripts/logs/{TIMESTAMP}/` with one log file per script.

You can also run the installer via Make from the project root:

```bash
make complete
```

To re-load patterns after editing them:

```bash
cd setup
./scripts/06-load-patterns.sh
./scripts/07-enrich-patterns.sh
```

See [setup/README.md](setup/README.md) for manual setup steps, service endpoints, teardown, and troubleshooting.

### Testing

All shell scripts are validated with [ShellCheck](https://www.shellcheck.net/):

```bash
shellcheck setup/scripts/*.sh
```

Pattern metadata is validated by `05-validate-metadata.sh`, which checks that every pattern file has the required YAML frontmatter fields defined in [PATTERN-METADATA-SCHEMA.md](patterns/PATTERN-METADATA-SCHEMA.md).

### Versioning

This project uses Git commits on the `main` branch as its version history. There are no semantic version tags at this time. Refer to the Git log for change history.
