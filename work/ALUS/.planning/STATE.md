# STATE — Migración v2 segura

**Updated:** 2026-05-25 (Fase 7 k6 intento 3 documentado; gate 0% FAIL — Harness stop)  
**Active milestone:** MIG-V2-100 (Wave 0 → **3 NATS dev OK** → 5 **company golden parcial** → **6 rutas OK** → **7 gate FAIL (3 intentos)** → 8 subset OK)

## Documentación arquitectura v2 (2026-05-25)

| Documento | Ruta |
|-----------|------|
| **Env vars + service discovery post KrakenD/NATS** | [`docs/architecture/ENV_AND_SERVICE_DISCOVERY.md`](../docs/architecture/ENV_AND_SERVICE_DISCOVERY.md) |
| **Checklist limpieza env (sin borrar código)** | [`docs/architecture/CLEANUP_PHASE_ENV.md`](../docs/architecture/CLEANUP_PHASE_ENV.md) |
| Vista C4, contenedores, diagramas Mermaid (read-flow, NATS, batch, auth, cutover, OTel) | [`docs/architecture/ARCHITECTURE_MIGRATION_V2.md`](../docs/architecture/ARCHITECTURE_MIGRATION_V2.md) |
| Mapa endpoints por dominio (KrakenD 32 rutas dev, BFF, MS, NATS) | [`docs/architecture/ENDPOINTS_MAP_V2.md`](../docs/architecture/ENDPOINTS_MAP_V2.md) |
| 15 flujos críticos secuencia (login, catalog, batch, sell-out, …) | [`docs/architecture/FLOWS_BEHIND_ENDPOINTS.md`](../docs/architecture/FLOWS_BEHIND_ENDPOINTS.md) |
| Infra Dokploy NATS + KrakenD | [`.planning/INFRA_DOKPLOY_NATS_KRAKEND.md`](INFRA_DOKPLOY_NATS_KRAKEND.md) |
| ADR JetStream | [`docs/architecture/ADR-NATS-JETSTREAM.md`](../docs/architecture/ADR-NATS-JETSTREAM.md) |

## Paso 0 + post-fetch (2026-05-25)

Verificación inicial `origin/cicd` (refs locales desactualizadas): Fase 3/4 **ausentes** → Fase 5 código omitida.

Tras `git fetch` + push infra (`0436cfd`):

| Repo | Commit cicd | Fase | Estado remoto |
|------|-------------|------|---------------|
| **archetype-1** | `175f052` | Fase 8 v1+embedded KrakenD (39 rutas) | ✅ en remoto |
| **users-management** | `7b7d8668` | Fase 3 login audit NATS | ✅ en remoto |

**Esta sesión (deploy gates):** KrakenD **32 rutas** core+company+admin; UM NATS; contract-diff **22/22**; company profile **200**; admin rutas **401** (no 404); Newman 1/11 fail (cred admin).

**Infra versionada (sesión):** `archetype-1/scripts/apply-cutover-read-flow-dev.sh`, `infra/krakend/krakend.json`, catalog IDs en `configure-dokploy-nats-env.sh`.

## Deploy dev gates Fase 5/6/3 (2026-05-25 sesión)

| Acción | Ref / resultado |
|--------|-----------------|
| KrakenD redeploy | `make krakend-v2-admin` → **32 rutas** (core+company+admin); `apply-cutover-read-flow-dev.sh` ×2; servidor `/etc/dokploy/compose/compose-alus-krakend-dev/code/krakend.json` |
| archetype-1:cicd | `docker pull` newer digest `sha256:56af60…` + `service update --force app-reboot-neural-feed-3jkjw6`; NATS re-aplicado |
| catalog-service:cicd | Image up-to-date (`sha256:b0403327…`); sin redeploy |
| UM NATS Fase 3 | `ARCH_APP_ID=d5SVR3woARaQpq-GYmu3i` → `configure-dokploy-nats-env.sh` OK |
| contract-diff | **22/22 OK, 0 diffs** (`make contract-capture && contract-diff && contract-validate-golden`) |
| Fase 5 company | `company_profile` **200**; `company_sellout_tickets` **500** (backend, no 404) |
| Fase 6 admin | Rutas KrakenD OK — **401** sin token (no 404); `administrator`/`AlusAdmin123!` → login **401** en dev |
| precheck-dev | **PASSED** (participant login/catalog/profile/modules) |
| Newman admin-smoke | 11 req; **1 fail** — admin login 401 (credencial dev pendiente PM) |

## Completado (sesión 2026-05-24)

### Fase 0 — W0
- [x] pytest e2e: **17 passed, 2 skipped**
- [x] OpenAPI v2 + golden **contract-diff 6/6**
- [x] NATS JetStream Dokploy `compose-alus-nats-dev`
- [x] Bus NATS archetype + PoC invalidate
- [x] Scripts: `configure-dokploy-nats-env.sh`, `poc_nats_catalog_invalidate.sh`

### Fase 1 — W1 (shadow core) — **CERRADA + CUTOVER DEV**
- [x] KrakenD dev **18 rutas core**
- [x] contract-diff **6/6** archetype + krakend-dev (pre-cutover)
- [x] k6 shadow 30 RPS × 2 min **0% failed**
- [x] **Gate k6 45 RPS × 20 min** KrakenD (`krakend-gate-45rps`): **0% failed**, p95 ~175 ms, 54 001 req
- [x] **Cutover read-flow dev ejecutado:** `archetype-1-dev.docker.regalus.dev` → KrakenD (Traefik priority 100); backend interno `app-reboot-neural-feed-3jkjw6:9991` (sin loop)
- [x] Post-cutover: **precheck OK**; contract-diff **5/6** (auth_login excluido — JWT efímero; resto OK vía KrakenD)
- [x] Script: [`load-tests/scripts/apply-cutover-read-flow-dev.sh`](../load-tests/scripts/apply-cutover-read-flow-dev.sh) + copia [`archetype-1/scripts/`](../archetype-1/scripts/apply-cutover-read-flow-dev.sh)

### Fase 2 — W2 (lecturas / catalog → NATS) — **gate invalidación OK**
- [x] **catalog-service** `pkg/bus` publica `alus.catalog.categories.changed.v1` (commit **79a1eff**, imagen `catalog-service:cicd` en dev)
- [x] Deploy dev: `APP_NATS_*` en Dokploy + Swarm `app-generate-primary-pixel-n8e7z4` (`R76MsKu2zoij1bPTI3IzR`)
- [x] Redeploy build remoto + re-aplicar NATS env post-rollout
- [x] Gate E2E invalidación archetype: GET categories estable tras evento formato catalog (servidor `dokploy-network`)
- [ ] Mutación PM live vía `PUT /api/v1/pm/projects/.../categories/...` — **SKIP dev (documentado):** `noe+1@alus.com.mx` / `password123` → **401** en `catalog-service-dev` `/api/v1/auth/`

### Fase 3 — W2 (auth eventos) — **NATS dev OK**
- [x] `7b7d8668` UM: auditoría login NATS fire-and-forget
- [x] `APP_NATS_*` Dokploy BD + Swarm `app-quantify-cross-platform-panel-l3afl9` (2026-05-25)
- [ ] Gate e2e + invalidación tenant en dev

### Fase 4 — W3 (sagas participant) — **commit remoto OK**
- [x] `d1bfac7` archetype: evento NATS tras batch PO participant
- [ ] Golden POST redeem + e2e 003/004 alineados

### Fase 5 — W4 (company v2) — **golden parcial dev**
- [x] Inventario: [`FASE5_COMPANY_EXPLORE.md`](FASE5_COMPANY_EXPLORE.md)
- [x] Golden GET company profile **200** vía KrakenD (2026-05-25)
- [ ] Golden GET sell-out tickets — **500** backend dev (ruta OK, no 404)
- [ ] Spike NATS post sell-out approve — **pendiente Fase 4**

### Fase 7 — W6 (escala 1M) — **gate k6 FAIL — 3 intentos (Harness stop)**
- [x] k6 post-cutover @ 45 RPS × 20 min vía `run-clip-redis-pass2.sh` (`BASE_URL` preservado sobre `clip.env`)
- [x] Intento 1: **57.63% failed** — loop backend KrakenD; fix `KRAKEND_BACKEND=http://archetype-1-dev:9991`
- [x] Intento 2: **14.68% failed**, p95 ~162 ms en OK
- [x] **Intento 3** (`post-cutover-45rps`): **0.09% failed** (50/54 001), p95 **161 ms** (−1.1% vs baseline); 44×504 + 6×502
- [x] [`POST_MIGRATION_COMPARISON.md`](../load-tests/reports/POST_MIGRATION_COMPARISON.md) — tabla p95/failed vs baseline
- [x] Réplicas Swarm: [`.planning/FASE7_SWARM_REPLICAS_RECOMMENDED.md`](FASE7_SWARM_REPLICAS_RECOMMENDED.md) — **sin cambio prod**
- [ ] Gate **0% failed** post-cutover — **bloqueado** hasta escala dev + nuevo RUN_ID (no intento 4 sin escala)

### Fase 8 — W6 (v1 legacy + embedded v1) — **subset OK dev**
- [x] `generate_krakend_v2.py` modo `core+v1`: **32 endpoints** (v2 core+company + v1 + embedded)
- [x] KrakenD dev redeploy + backend interno `http://archetype-1-dev:9991`
- [x] Golden v1: `v1_profile.json`, `v1_balance.json` — **200** post-deploy (frontend `profile.service.ts`)
- [x] contract-diff v1+v2: **0 diffs** (participant subset)
- [x] UM NATS dev: `ARCH_APP_ID=d5SVR3woARaQpq-GYmu3i` vía `configure-dokploy-nats-env.sh`

### Fase 6 — W5 (admin + auditor) — **rutas OK dev (401 sin cred PM)**
- [x] Inventario: [`FASE6_ADMIN_EXPLORE.md`](FASE6_ADMIN_EXPLORE.md) — ~175 admin + 12 auditor + gift-cards dual auth
- [x] Golden capture script: 8 GET admin + `admin_auth_login` + 2 GET auditor (`scripts/contract_capture_golden.py`)
- [x] OpenAPI: prefijos `/administrator/`, `/catalog-admin/` (fix parser subrouter + gift-cards mounts)
- [x] Newman: `archetype-1/test/contract/newman/admin-smoke.json` (11 requests)
- [x] KrakenD dev: `make krakend-v2-admin` → **32 rutas** (core+company+admin); deploy 2026-05-25
- [x] contract-diff admin en dev: **10 admin + 2 auditor golden OK, 0 diffs** (401 esperado sin token)
- [ ] Newman **200** con credencial admin PM dev (`administrator`/`AlusAdmin123!` → 401)

## Pendiente

| Item | Fase | Acción |
|------|------|--------|
| Fase 5 sell-out tickets 500 | 5 | Investigar backend dev (profile OK 200) |
| Credencial admin PM dev | 6 | Newman 200 + golden admin con token |
| Gate e2e Fase 3/4 en dev | 3–4 | Validar `7b7d8668` + `d1bfac7` |
| KrakenD full 391 paths | 1+ | Gin wildcard / FCGL |
| contract-diff auth_login golden | 1 | Excluir `token` del diff semántico |
| Sagas company sell-out/goals | 5 | Tras Fase 4 |
| Redeploy KrakenD v1+embedded dev | 8 | ✅ hecho — golden v1 OK |
| POST_MIGRATION compare | 7 | ✅ [`POST_MIGRATION_COMPARISON.md`](../load-tests/reports/POST_MIGRATION_COMPARISON.md) |
| k6 post-cutover 0% failed | 7 | **FAIL** tras 3 intentos — escalar réplicas dev antes de reintentar |

## Dev NATS

| Servicio | Dokploy appId | Swarm service |
|----------|---------------|---------------|
| archetype-1-dev | `auJJbXfpSeBjydjqM0NcH` | `app-reboot-neural-feed-3jkjw6` |
| catalog-service-dev | `R76MsKu2zoij1bPTI3IzR` | `app-generate-primary-pixel-n8e7z4` |
| users-management-dev | `d5SVR3woARaQpq-GYmu3i` | `app-quantify-cross-platform-panel-l3afl9` |
| KrakenD dev | `compose-alus-krakend-dev` | `compose-alus-krakend-dev-krakend-1` |

```bash
# users-management (Fase 3 NATS)
ARCH_APP_ID=d5SVR3woARaQpq-GYmu3i ARCH_SWARM_SVC=app-quantify-cross-platform-panel-l3afl9 \
  ./load-tests/scripts/configure-dokploy-nats-env.sh
```

## k6 gates (2026-05-24)

| RUN_ID | BASE_URL | RPS × min | failed | p95 |
|--------|----------|-----------|--------|-----|
| krakend-shadow | krakend-dev | 30 × 2 | 0% | ~162 ms |
| **krakend-gate-45rps** | krakend-dev | 45 × 20 | **0%** | **~175 ms** |

| post-cutover-45rps (intento 2) | archetype-1-dev cutover | 45 × 20 | **14.68%** | ~162 ms (ok) |
| **post-cutover-45rps** (intento 3) | archetype-1-dev cutover | 45 × 20 | **0.09%** ❌ | **~161 ms** |

## Próxima acción

1. Fase 7: escalar réplicas dev ([FASE7_SWARM_REPLICAS_RECOMMENDED.md](FASE7_SWARM_REPLICAS_RECOMMENDED.md)) → nuevo k6 (RUN_ID distinto).
2. Credencial admin PM dev → Newman 200 + golden admin autenticado.
3. Fase 5: diagnosticar `company_sellout_tickets` 500 en dev.
4. Gate e2e Fase 3/4 (`7b7d8668`, `d1bfac7`).
