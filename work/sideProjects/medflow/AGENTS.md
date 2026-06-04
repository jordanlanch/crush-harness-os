# AGENTS.md

This project uses RTK+GSD hybrid workflow for AI-assisted development.

## RTK (Rust Token Killer)
- Token optimization CLI that reduces command output by 60-90%
- Automatically rewrites commands (e.g., `git status` → `rtk git status`)
- Works with Claude Code (via hooks) and OpenCode (via MCP server)
- Zero dependencies, single binary

## GSD (Get Shit Done)
- Spec-driven development system for Claude Code and OpenCode
- Manages project lifecycle: discovery → planning → execution → verification
- Commands:
  - Claude Code: `/gsd:new-project`, `/gsd:plan-phase`, `/gsd:execute-phase`
  - OpenCode: `/gsd-new-project`, `/gsd-plan-phase`, `/gsd-execute-phase`
- Creates structured documentation in `.planning/` directory

## MCP Integration
- RTK-GSD MCP server provides optimized command execution
- Tools: `execute_command`, `rtk_rewrite`, `gsd_status`
- Access via MCP clients (Claude Desktop, OpenCode, etc.)

## Usage Guidelines

### Starting a New Feature
1. Run `/gsd:new-project` (Claude) or `/gsd-new-project` (OpenCode)
2. Answer questions about goals, constraints, tech preferences
3. Review generated roadmap and requirements
4. Execute phases with `/gsd:execute-phase`

### Daily Development
- Use normal bash commands - RTK optimizes them automatically
- For complex tasks, use GSD quick mode: `/gsd:quick` or `/gsd-quick`
- Monitor context usage with GSD hooks
- Commit frequently with atomic commits

### Project Structure
- `.planning/` - GSD project state and documentation
- `AGENTS.md` - This file, for AI agent context
- `.mcp.json` - MCP server configuration
- `CLAUDE.md` - Project-specific instructions for Claude

## Commands Reference

### RTK
```bash
rtk --version          # Check version
rtk gain               # View token savings
rtk discover           # Find optimization opportunities
rtk git status         # Optimized git status
rtk ls .               # Optimized directory listing
```

### GSD (Claude Code)
```
/gsd:help              # Show all commands
/gsd:new-project       # Start new project
/gsd:map-codebase      # Analyze existing codebase
/gsd:discuss-phase N   # Discuss implementation details
/gsd:plan-phase N      # Research and plan phase
/gsd:execute-phase N   # Execute phase plans
/gsd:verify-work N     # User acceptance testing
/gsd:quick             # Quick task execution
```

### GSD (OpenCode)
```
/gsd-help              # Show all commands
/gsd-new-project       # Start new project
/gsd-map-codebase      # Analyze existing codebase
/gsd-discuss-phase N   # Discuss implementation details  
/gsd-plan-phase N      # Research and plan phase
/gsd-execute-phase N   # Execute phase plans
/gsd-verify-work N     # User acceptance testing
/gsd-quick             # Quick task execution
```

## Configuration

### Claude Code Hooks
- RTK rewrite hook: `~/.claude/hooks/rtk-rewrite.sh`
- GSD hooks: `~/.claude/hooks/gsd-*.js`
- Settings: `~/.claude/settings.json`

### OpenCode Configuration
- GSD commands: `~/.config/opencode/command/gsd-*.md`
- GSD hooks: `~/.config/opencode/hooks/gsd-*.js`
- Config: `~/.config/opencode/opencode.json`

### MCP Server
- Location: `~/.local/share/mcp-rtk-gsd/`
- Config: `.mcp.json` in project root

## Troubleshooting

### RTK not working
- Check installation: `rtk --version`
- Verify hook: `ls -la ~/.claude/hooks/rtk-rewrite.sh`
- For OpenCode: Use MCP server tools

### GSD commands not found
- Restart Claude Code/OpenCode
- Verify installation: `npx get-shit-done-cc --claude --global`
- Check command directory exists

### MCP server not connecting
- Verify node is installed: `node --version`
- Check MCP server runs: `node ~/.local/share/mcp-rtk-gsd/index.js`
- Review `.mcp.json` configuration



## Senior Developer Autonomous Workflow

Senior developer agents (`medflow-senior-dev`) can autonomously discover project structure and setup test environments using the project MCP tools server.

### Automated Discovery Process
1. **Project Analysis**: Use `scan_project` tool to detect technologies, frameworks, test setup
2. **Test Environment**: Use `start_test_environment` to launch Docker test containers (if available)
3. **Test Execution**: Use `run_unit_tests` and `run_e2e_tests` to verify project health
4. **Task Management**: Update `.agent-tasks.json` with findings and progress

### Available MCP Tools
- `scan_project` - Comprehensive project structure analysis
- `detect_test_commands` - Discover test commands (unit, integration, E2E)
- `generate_project_report` - Full project analysis report
- `run_unit_tests` / `run_e2e_tests` - Execute tests
- `start_test_environment` / `stop_test_environment` - Manage Docker test environments
- `read_project_file` / `write_project_file` - File operations
- `run_command` - Execute any bash command with RTK optimization
- `list_tasks` / `update_task_status` / `create_task` - Task management

### Quick Start for Senior-Dev
```bash
# 1. Discover project (autonomous)
scan_project

# 2. Setup test environment  
start_test_environment

# 3. Run baseline tests
run_unit_tests
run_e2e_tests

# 4. Check assigned tasks
list_tasks

# 5. Implement with RTK+GSD
rtk git status          # Optimized git status
/gsd-new-project        # Start GSD workflow
```

### RTK Optimization
- All commands should be prefixed with `rtk` for 60-90% token reduction
- Example: `rtk git status` instead of `git status`
- Works with all bash commands via project MCP server

### Test Environment Requirements
- Docker socket mounted to containers
- Project-specific `docker-compose.test.yml` for test environments
- MCP server provides automated discovery and management

## Hierarchical Agent Coordination Framework

Medflow uses a hierarchical coordination framework for enterprise-scale development management.

### Agent Hierarchy Structure
```
CEO (medflow-ceo) → Director (medflow-director) → Senior-Dev (medflow-senior-dev)
    ↓                       ↓                           ↓
Marketing              Product                    Developers
(medflow-marketing)   (medflow-product)          (medflow-developer, etc.)
                            ↓
                           QA
                    (medflow-qa)
```

### Role Definitions

**CEO Agent:**
- Business strategy and priorities
- Resource allocation across teams
- Compliance and risk oversight
- Stakeholder communication

**Director Agent:**
- Project management and timelines
- Technical architecture decisions
- Team coordination and mentoring
- Quality assurance oversight

**Senior-Dev Agent:**
- Technical implementation leadership
- Code review and standards enforcement
- Test environment management
- Developer mentoring

**Developer Agents:**
- Feature implementation
- Bug fixes and maintenance
- Unit test creation
- Code documentation

**QA Agent:**
- Test planning and execution
- Bug reporting and verification
- Regression testing
- Quality metrics tracking

**Marketing Agent:**
- Feature documentation
- Release communications
- User feedback collection
- Market analysis

**Product Agent:**
- Requirements definition
- User story creation
- Feature prioritization
- Product roadmap

### Communication Protocols

1. **Task Flow:** CEO → Director → Senior-Dev → Developers/QA
2. **Status Flow:** Developers → Senior-Dev → Director → CEO
3. **Emergency Escalation:** Any agent → CEO (immediate)

### Tool Usage Matrix

| Role | Primary Tools | Secondary Tools |
|------|---------------|-----------------|
| CEO | scan_project, generate_project_report, list_tasks, create_task | git_status, run_command |
| Director | All CEO tools + detect_test_commands, update_task_status | read_project_file |
| Senior-Dev | All Director tools + run_unit_tests, start_test_environment, write_project_file | run_e2e_tests, stop_test_environment |
| Developer | read_project_file, write_project_file, run_command, run_unit_tests | update_task_status |
| QA | run_unit_tests, run_e2e_tests, start_test_environment, detect_test_commands | read_project_file, run_command |

### GSD Phase Mapping

- **Phase 1 (Discuss):** CEO + Director - Business context
- **Phase 2 (Plan):** Director + Senior-Dev - Technical planning
- **Phase 3 (Execute):** Senior-Dev + Developers - Implementation
- **Phase 4 (Verify):** QA + Director - Validation

## Uncommitted Work Handling

Medflow currently has uncommitted work in backend and frontend. Follow the uncommitted work handling workflow in `.agent/workflows/uncommitted-work-handling.md`.

### Current Priority Changes:
1. Pharmacy domain implementation
2. Patient merge functionality
3. Database migrations
4. Frontend test updates

### Handling Process:
1. **Assessment:** Senior-Dev scans project and analyzes git status
2. **Planning:** Director creates completion plan with agent assignments
3. **Execution:** Developers complete changes with Senior-Dev review
4. **Integration:** QA tests, Director verifies, CEO approves

## Healthcare Compliance Integration

All agents must consider healthcare compliance requirements:
- HIPAA for patient data protection
- PHI (Protected Health Information) handling
- Audit trail requirements
- Security and privacy by design

## Success Metrics

- **CEO:** Business objectives met, compliance adherence
- **Director:** Project timelines, budget, quality
- **Senior-Dev:** Code quality, test coverage, team velocity
- **Developer:** Feature completion, bug rate, test coverage
- **QA:** Defect detection rate, test coverage, regression prevention

## Implementation Status

- [x] Agent ecosystem created (33 total agents)
- [x] MCP servers configured (medflow-tools-server.js)
- [x] RTK installed in all containers (v0.26.0)
- [x] Docker environment running (mednext-* containers)
- [x] Hierarchical workflows documented
- [ ] Uncommitted work assessment completed
- [ ] Agent coordination tested end-to-end
- [ ] Healthcare compliance validation
- [ ] Success metrics tracking implemented

## Next Steps

1. Test CEO → Director → Senior-Dev communication
2. Handle uncommitted work using agent coordination
3. Implement healthcare compliance checks
4. Create E2E tests for agent workflows
5. Monitor success metrics in Pixel Office dashboard

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- After modifying code files in this session, run `python3 -c "from graphify.watch import _rebuild_code; from pathlib import Path; _rebuild_code(Path('.'))"` to keep the graph current
