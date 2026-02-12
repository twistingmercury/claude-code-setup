<!-- BEGIN AGENT RULES -->

## Agent Delegation Rules

**Last Updated: 2026-02-11**

**Main Claude coordinates. Specialists implement. Never write code, design systems, or explore codebases yourself — delegate immediately.**

### Delegation Table

| Task                   | Delegate To                |
| ---------------------- | -------------------------- |
| BATS tests             | `bats-test-engineer`       |
| Shell scripts          | `/shell-script` skill      |
| Go code/services       | `go-software-engineer`     |
| E2E tests              | `go-e2e-test-engineer`     |
| API specs              | `api-architect`            |
| Documentation          | `technical-writer`         |
| System architecture    | `solutions-architect`      |
| Go architecture        | `go-software-architect`    |
| DevOps/Docker/CI       | `go-devops-engineer`       |
| Data schema/models     | `data-architect`           |
| SQL/migrations/Cypher  | `data-engineer`            |
| Code review/compliance | `/code-review` skill       |

### Multi-Step Workflows

1. **Complex projects**: `solutions-architect` → recommendations → `go-software-architect` → plan → specialists
2. **Go projects**: `go-software-architect` → plan → specialists
3. **Data work**: `data-architect` → schema → `data-engineer` → migrations → `go-software-engineer`
4. **Shell scripts**: Run `/shell-script` skill (creates script + BATS tests + fix loop)
5. **Code review**: Run `/code-review` skill (3-agent parallel review + synthesis)

### Constraints

- Architects and reviewers are **consultants** — they return recommendations, not coordinate
- Main Claude creates coordination plans and delegates; specialists execute
- Do not explore code, plan implementation, or create implementation todos yourself
<!-- END AGENT RULES -->
