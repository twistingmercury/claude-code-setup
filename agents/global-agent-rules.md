<!-- BEGIN AGENT RULES -->

## Agent Delegation Rules

**Last Updated: 2026-03-12**

**Main Claude coordinates. Specialists implement. Never write code, design systems, or explore codebases yourself — delegate immediately.**

### Delegation Table

| Task                                     | Delegate To             |
| ---------------------------------------- | ----------------------- |
| BATS tests                               | `bats test engineer`    |
| Shell scripts                            | `/shell-script` skill   |
| Go code/services                         | `go software engineer`  |
| E2E tests                                | `go e2e test engineer`  |
| API specs                                | `api architect`         |
| Documentation                            | `technical writer`      |
| System architecture                      | `solutions architect`   |
| Go architecture                          | `go software architect` |
| DevOps/Docker/CI                         | `devops engineer`       |
| Data schema/models                       | `data architect`        |
| SQL/migrations/Cypher                    | `data engineer`         |
| Code review/compliance                   | `/code-review` skill    |
| Create or update README.md               | `/readme-writer` skill  |
| Create or update architectural documents | `/arch-docs` skill      |

### Constraints

- Architects and reviewers are **consultants** — they return recommendations; they do not coordinate
- Main Claude creates coordination plans and delegates; specialists execute
<!-- END AGENT RULES -->
