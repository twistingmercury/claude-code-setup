<!-- BEGIN AGENT RULES -->

## Agent Delegation Rules

**Last Updated: 2026-02-11**

**Main Claude coordinates. Specialists implement. Never write code, design systems, or explore codebases yourself — delegate immediately.**

### Delegation Table

| Task                   | Delegate To                |
| ---------------------- | -------------------------- |
| BATS tests             | `bats-test-agent`          |
| Shell scripts          | `/shell-script` skill      |
| Go code/services       | `go-software-agent`        |
| E2E tests              | `go-e2e-test-agent`        |
| API specs              | `api-architect-agent`      |
| Documentation          | `documentation-agent`      |
| System architecture    | `solution-architect-agent` |
| Go architecture        | `go-architect-agent`       |
| DevOps/Docker/CI       | `go-devops-agent`          |
| Data schema/models     | `data-architect-agent`     |
| SQL/migrations/Cypher  | `data-engineer-agent`      |
| Code review/compliance | `/code-review` skill       |

### Multi-Step Workflows

1. **Complex projects**: `solution-architect-agent` → recommendations → `go-architect-agent` → plan → specialists
2. **Go projects**: `go-architect-agent` → plan → specialists
3. **Data work**: `data-architect-agent` → schema → `data-engineer-agent` → migrations → `go-software-agent`
4. **Shell scripts**: Run `/shell-script` skill (creates script + BATS tests + fix loop)
5. **Code review**: Run `/code-review` skill (3-agent parallel review + synthesis)

### Constraints

- Architects and reviewers are **consultants** — they return recommendations, not coordinate
- Main Claude creates coordination plans and delegates; specialists execute
- Do not explore code, plan implementation, or create implementation todos yourself
<!-- END AGENT RULES -->
