---
phase: env-audit
plan: 1
subsystem: infra
tags: [env, krakend, nats, dokploy, app_service, migration-v2]

requires:
  - phase: migration-v2-cutover
    provides: KrakenD cutover dev, NATS JetStream operativo
provides:
  - Inventario APP_* archetype-1 post-migración
  - Checklist limpieza env sin borrar código
  - Auditoría loop archetype-1-dev.docker.regalus.dev
affects: [ops, dokploy, cicd, cleanup]

tech-stack:
  added: []
  patterns: ["alias dokploy-network para KrakenD backend", "APP_NATS sync post-redeploy"]

key-files:
  created:
    - docs/architecture/ENV_AND_SERVICE_DISCOVERY.md
    - docs/architecture/CLEANUP_PHASE_ENV.md
  modified:
    - docs/architecture/API_V2_CONTRACT_INVARIANTS.md
    - docs/architecture/ADR-NATS-JETSTREAM.md
    - docs/architecture/DECISIONS.md

key-decisions:
  - "BFF no elimina HTTP sync archetype→MS en esta fase"
  - "KrakenD backend debe ser alias interno archetype-1-dev:9991, no URL Traefik pública"
  - "Vars obsoletas listadas con evidencia; sin borrado de código sin aprobación"

requirements-completed: []

duration: 25min
completed: 2026-05-25
---

# Fase env-audit Plan 1: Inventario env post-migración v2 Summary

**Inventario operativo de APP_*, APP_NATS_* y APP_SERVICE_* con reglas KrakenD y checklist de limpieza Dokploy/Swarm**

## Performance

- **Duration:** ~25 min
- **Started:** 2026-05-25T00:00:00Z
- **Completed:** 2026-05-25T00:25:00Z
- **Tasks:** 6
- **Files modified:** 5

## Accomplishments

- Tablas completas de variables archetype-1 (core, JWT, NATS, MS HTTP)
- Checklist CLEANUP con sync Dokploy, aliases Swarm, candidatas deprecación
- Grep loop: communication/inject_envs apuntan a archetype público — documentado
- ADRs existentes enlazados desde DECISIONS, API_V2, NATS ADR

## Task Commits

1. **Inventario ENV_AND_SERVICE_DISCOVERY** — (docs monorepo)
2. **CLEANUP + ADR cross-refs** — (docs monorepo)

## Deviations from Plan

None - plan executed exactly as written.

## Self-Check: PASSED

- FOUND: docs/architecture/ENV_AND_SERVICE_DISCOVERY.md
- FOUND: docs/architecture/CLEANUP_PHASE_ENV.md

---
*Phase: env-audit*
*Completed: 2026-05-25*
