# Project Guidelines


## Core Coding Principles (Karpathy Guidelines)

**These 4 principles override default behavior for ALL coding tasks:**

### 1. Think Before Coding
- **State assumptions explicitly** — If uncertain, ask rather than guess
- **Present multiple interpretations** — Don't pick silently when ambiguity exists
- **Push back when warranted** — If a simpler approach exists, say so
- **Stop when confused** — Name what's unclear and ask for clarification

### 2. Simplicity First
- **Minimum code that solves the problem. Nothing speculative.**
- No features beyond what was asked
- No abstractions for single-use code
- No "flexibility" or "configurability" that wasn't requested
- If 200 lines could be 50, rewrite it

### 3. Surgical Changes
- **Touch only what you must. Clean up only your own mess.**
- Don't "improve" adjacent code, comments, or formatting
- Don't refactor things that aren't broken
- Match existing style, even if you'd do it differently
- Every changed line should trace directly to the user's request

### 4. Goal-Driven Execution
- **Define success criteria. Loop until verified.**
- Transform imperative tasks into verifiable goals:
  - "Add validation" → "Write tests for invalid inputs, then make them pass"
  - "Fix the bug" → "Write a test that reproduces it, then make it pass"
  - "Refactor X" → "Ensure tests pass before and after"


---

# MedNext - Colombian Healthcare Platform

MedNext migrates SistemaMED (Delphi/VCL desktop, 233 .pas files) to a modern web platform: **Go 1.24+ backend** + **Angular 19+ frontend**, targeting Colombian IPS/EPS clinics.

## Repos & Structure

| Repo | GitHub | Stack |
|------|--------|-------|
| Backend | `jordanlanch/mednext-backend` | Go 1.24 · Echo · pgx/sqlc · Uber Fx |
| Frontend | `jordanlanch/mednext-frontend` | Angular 19 · NgRx Signal Store · Tailwind 4 |

```
medflow/                          # Local orchestration (not a git repo)
├── backend/                      # git → mednext-backend
├── frontend/                     # git → mednext-frontend
├── deploy/docker/coding-agent/   # Ralph agent task JSONs
├── dokploy/                      # Production compose files
├── docs/architecture/            # Detailed architecture docs
└── docker-compose.yml            # Dev environment (Postgres + Redis)
```

## 🛑 ANTI-HALLUCINATION & ARCHITECTURAL RIGOR 🛑

**DO NOT BE AN "EMPÍRICO".** The project has strict established patterns. Before writing or editing any code, you MUST:

1. **Read Existing Implementations:** If you are creating a new Service, Component, or Backend Handler, use `grep` and `read` to look at an existing one (e.g., `patient.service.ts` or `auth.go`). **COPY THEIR PATTERN EXACTLY.**
2. **Frontend API Calls (CRITICAL):**
   - NEVER use `HttpClient` directly (unless doing raw Blob downloads).
   - ALWAYS use `ApiService` (imported from `src/app/core/services/api.service.ts`).
   - The `ApiService` and `response.interceptor.ts` **automatically unwrap** `{ success: true, data: {...} }`. The observable returns the actual data `T`, NOT the wrapper. E.g., `this.api.get<Patient>('/patient').pipe(map(r => r.data!))` is correct because the interceptor leaves `r.data`. *Check existing services to see how it's done.*
3. **Backend API Responses:**
   - NEVER write raw `c.JSON()` or `c.NoContent()`.
   - ALWAYS use the `pkg/response` package (`response.Success`, `response.BadRequest`, `response.InternalError`).
4. **No Guessing Paths/Types:** If you don't know where a module or interface is located, DO NOT GUESS. Use `glob` or `grep` to find the exact file path before importing.

## Critical Constraints

- **NEVER** expose domain entities in API responses — always use DTOs
- **NEVER** use NgModules — Standalone Components only (Angular 19 zoneless)
- **NEVER** commit `.env`, credentials, or secrets
- **NEVER** force-push to main or skip hooks (`--no-verify`)
- Context (`ctx context.Context`) is ALWAYS the first parameter in Go functions
- `ChangeDetectionStrategy.OnPush` on EVERY Angular component
- `data-testid` attributes on ALL interactive elements
- pgx errors: check `pgx.ErrNoRows`, use `pgconn.PgError` for constraint violations
- New Angular control flow only: `@if`, `@for`, `@switch` (no `*ngIf`/`*ngFor`)
- Signals for local state, NgRx Signal Store for shared state

## Quick Commands

```bash
# Backend
cd backend && go run ./cmd/api          # Start API :8080
cd backend && make test                 # All tests
cd backend && sqlc generate             # Regenerate type-safe SQL

# Frontend
cd frontend && npm start                # Dev server :4200
cd frontend && npm test                 # Vitest
cd frontend && npm run e2e              # Playwright

# Dev environment (Postgres:5433, Redis:6380)
docker compose up -d
```

## Test Credentials

| Role | Email | Password |
|------|-------|----------|
| admin | admin@mednext.com | Admin123 |
| doctor | doctor@mednext.com | Doctor123 |
| nurse | enfermera@mednext.com | Nurse123 |
| receptionist | recepcion@mednext.com | Recep123 |
| pharmacy | farmacia@mednext.com | Pharma123 |
| lab | laboratorio@mednext.com | Lab123 |
| billing | facturacion@mednext.com | Billing123 |

## API Pattern

```
GET/POST/PUT/PATCH/DELETE  /api/v1/{resource}[/:id]
Response: { "data": {...}, "meta": { "page": 1, "total": 100 } }
Error:    { "error": { "code": "VALIDATION_ERROR", "message": "..." } }
```

## Domain (Colombia)

| Term | Meaning |
|------|---------|
| RIPS | Registro Individual de Prestacion de Servicios (regulatory reports) |
| CUPS | Codigos Unicos de Procedimientos en Salud |
| CIE-10 | Clasificacion Internacional de Enfermedades |
| CUFE | Codigo Unico de Factura Electronica (DIAN) |
| DIVIPOLA | Division Politico-Administrativa de Colombia |
| FHIR R4 | Interoperability standard (Res. 1888/2025) |

## Architecture Docs

| Document | Content |
|----------|---------|
| [docs/architecture/README.md](./docs/architecture/README.md) | System overview, high-level diagrams |
| [docs/architecture/backend.md](./docs/architecture/backend.md) | Clean Architecture, DI, all 14 domain entities |
| [docs/architecture/frontend.md](./docs/architecture/frontend.md) | Feature modules, stores, routing, theme system |
| [docs/architecture/data-flow.md](./docs/architecture/data-flow.md) | Auth, RIPS, FHIR, AI pipelines with flow diagrams |
| [docs/architecture/api-catalog.md](./docs/architecture/api-catalog.md) | All 200+ endpoints organized by resource |
| [docs/architecture/database.md](./docs/architecture/database.md) | Schema overview, sqlc queries, migrations |
| [ROADMAP.md](./ROADMAP.md) | 105 tasks, progress tracking, phase status |

## Workflow

```
Claude (plan) → tasks-{target}.json → /dispatch → Agent (implement) → PR → Human review
```

- Task files: `deploy/docker/coding-agent/tasks-{backend,frontend}.json`
- Conventional commits: `feat(api):`, `fix(ui):`, `test(api):` + `[TASK-XXX]`
- Branches: `main` (prod), `feature/TASK-XXX-desc`, `fix/TASK-XXX-desc`

## Coverage Requirements

| Layer | Backend | Frontend |
|-------|---------|----------|
| Services/UseCases | >=85% | >=85% |
| Handlers/Components | >=75% | >=75% |
| Repositories/Store | >=80% | >=80% |

Max file sizes: Handler/Component 150 lines, Service/UseCase 200 lines, Template 100 lines.

## RTK+GSD Hybrid Workflow

This project uses RTK (token optimization) and GSD (spec-driven development) for AI-assisted coding.

### Quick Start
1. RTK automatically optimizes command outputs (60-90% token reduction)
2. For major features: Run `/gsd:new-project` (Claude) or `/gsd-new-project` (OpenCode)
3. Follow GSD workflow: discuss → plan → execute → verify
4. Use MCP server for RTK-optimized tools in OpenCode

### Token Optimization
- Commands like `git status`, `ls`, `cat` are automatically rewritten with RTK
- View savings: `rtk gain`
- Manual optimization: Prepend `rtk` to any command (e.g., `rtk git log`)

### GSD Commands
- `/gsd:help` - Show all GSD commands
- `/gsd:progress` - Check project status
- `/gsd:quick` - Execute ad-hoc task with GSD guarantees
- `/gsd:debug` - Systematic debugging with state management

### Project Structure
- `.planning/` - GSD project state and documentation
- `AGENTS.md` - AI agent context and workflow documentation
- `.mcp.json` - MCP server configuration for RTK/GSD tools
