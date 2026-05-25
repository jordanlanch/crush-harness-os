# Checklist — fase limpieza de variables de entorno (migración v2)

**Estado:** Planificado — **no ejecutar borrado de código sin aprobación**  
**Fecha:** 2026-05-25  
**Companion:** [ENV_AND_SERVICE_DISCOVERY.md](./ENV_AND_SERVICE_DISCOVERY.md)

---

## Objetivo

Reducir deuda de configuración tras KrakenD + NATS + BFF: unificar nombres, eliminar hosts públicos innecesarios en tráfico MS↔MS, y documentar vars obsoletas con evidencia.

---

## Checklist operativo

### A. Hosts públicos vs internos

- [ ] **KrakenD backend:** confirmar `http://archetype-1-dev:9991` (no URL Traefik pública)
- [ ] **archetype → MS:** evaluar migrar de `*-dev.docker.regalus.dev` a alias `dokploy-network` (`catalog-service-dev:8080`, etc.)
- [ ] **MS → archetype:** usar alias interno o servicio Swarm, **nunca** `archetype-1-dev.docker.regalus.dev` (riesgo loop si cutover activo)
- [ ] **Clientes / k6 / frontend:** mantener `archetype-1-dev.docker.regalus.dev` — único punto de entrada externo

### B. Unificar nombres Swarm → aliases DNS

| Servicio | Nombre Swarm actual (ejemplo) | Alias objetivo | Script |
|----------|-------------------------------|----------------|--------|
| archetype-1 dev | `app-reboot-neural-feed-3jkjw6` | `archetype-1-dev:9991` | `load-tests/scripts/ensure-archetype-network-alias.sh` |
| users-management | `app-quantify-cross-platform-panel-l3afl9` | documentar alias en Dokploy | `configure-dokploy-nats-env.sh` |
| NATS | `compose-alus-nats-dev-nats-1:4222` | mantener nombre compose | — |

- [ ] Ejecutar `ensure-archetype-network-alias.sh` tras cada redeploy que recree servicio
- [ ] Documentar alias por MS en tabla Dokploy (UI → Environment → notas)
- [ ] Actualizar `KRAKEND_BACKEND` solo si alias verificado (`docker exec` + curl interno)

### C. Dokploy env sync post-redeploy

Orden recomendado tras **cualquier** `docker service update --force` o redeploy CI:

1. [ ] `./load-tests/scripts/audit-dokploy-env.sh` — detectar missing / BUG-CLIP-002
2. [ ] `./archetype-1/scripts/configure-dokploy-nats-env.sh` — `APP_NATS_*` BD + Swarm
3. [ ] `./load-tests/scripts/sync-swarm-clip-env.sh` — `APP_SERVICE_USERSV2_ENDPOINT`, `APP_JWT_LOCAL_VALIDATION`
4. [ ] `./load-tests/precheck-dev.sh` — smoke HTTP
5. [ ] `./archetype-1/scripts/poc_nats_catalog_invalidate.sh` — JetStream vivo

**Regla:** Dokploy BD (`application.env`) y spec Swarm del contenedor **pueden divergir**; siempre sync explícito.

### D. Variables obsoletas — candidatas (solo documentar)

> ⚠️ No eliminar del código sin ticket + aprobación ops.

| Variable / patrón | Evidencia obsolescencia | Acción propuesta |
|-------------------|-------------------------|------------------|
| `settings.yaml` / `-cnf` flags | Eliminado Fase L (`settings.go:13-15`) | **Deprecado** — ya removido |
| `APP_SERVICE_USERSV2` → users-service | `validate.go:33-38`, BUG-CLIP-002 | **Corregir valor** en Dokploy; no deprecar var |
| `APP_SECURITY_ENCRYPTION_KEY` vs `APP_ENCRYPTION_KEY` | Duplicado en `payload_dev.json` | **Unificar** nombre |
| `APP_RATE_LIMIT_INTERVAL` | Solo `settings.go:321`; sin README | Auditar prod → deprecar si vacío |
| `APP_SERVICE_USERS` apuntando a legacy | Muchos handlers aún `GetService("users")` | **Mantener** hasta migración handlers; alinear endpoint a UM |
| Hosts `users-service-dev` en usersV2 | `payload_dev.json` snapshot | **Cambiar** a users-management |
| `APP_SERVICE_PRODUCTS_*` vs `CATALOG_*` | Duplicado semántico catalog | Consolidar naming en limpieza futura |
| Público MS en `inject_envs.sh` | `APP_SERVICE_ARCHETYPE_ENDPOINT=http://archetype-1.docker.regalus.dev/api/v2` | Cambiar a alias interno en communication |

### E. BUGs de configuración conocidos (prioridad alta)

| ID | Síntoma | Fix env |
|----|---------|---------|
| BUG-CLIP-002 | Login/JWTV2 contra users-service legacy | `APP_SERVICE_USERSV2_ENDPOINT=http://users-management-dev.../api/v1` |
| BUG-CLIP-003 | Latencia introspección JWT | `APP_JWT_LOCAL_VALIDATION=true` |
| Loop KrakenD | 57% failed k6, timeouts | Backend KrakenD ≠ URL pública archetype |

---

## Auditoría loop — MS que apuntan a archetype público

Búsqueda en monorepo ALUS (`archetype-1-dev.docker.regalus.dev` como **backend HTTP de otro MS**):

| Repo / archivo | Uso | Riesgo loop post-cutover |
|----------------|-----|--------------------------|
| `communication` — `GetService("archetype")` | SMS/bulk llama archetype v2 | **Medio** si env = URL pública cutover |
| `inject_envs.sh` | `APP_SERVICE_ARCHETYPE_ENDPOINT=http://archetype-1.docker.regalus.dev/api/v2` | **Alto** en dev con cutover |
| `bbva-contracts/README.md` | Ejemplo `http://api_archetype:1332` | Bajo (compose local) |
| Scripts k6, contract, OpenAPI | `BASE_URL` cliente | **OK** — tráfico externo intencional |
| `generate_krakend_v2.py` comentario | Advierte NO usar URL pública | Documentación |

**No encontrado:** MS en código Go de producción con string hardcoded `archetype-1-dev.docker.regalus.dev` (solo tests/scripts/docs).

**Acción limpieza:** auditar env real de `communication-dev` en Dokploy para `APP_SERVICE_ARCHETYPE_ENDPOINT`; migrar a `http://archetype-1-dev:9991/api/v2` o nombre Swarm + alias.

---

## Criterios de cierre de fase

- [ ] `audit-dokploy-env.sh` → 0 apps dev con incidencias
- [ ] KrakenD `KRAKEND_BACKEND` = alias interno verificado
- [ ] `APP_NATS_*` presentes en archetype + catalog + UM tras redeploy
- [ ] Sin `APP_SERVICE_USERSV2_ENDPOINT` conteniendo `users-service`
- [ ] Tabla aliases Swarm documentada en Dokploy
- [ ] Este checklist y [ENV_AND_SERVICE_DISCOVERY.md](./ENV_AND_SERVICE_DISCOVERY.md) revisados por ops

---

## Referencias

- `.planning/INFRA_DOKPLOY_NATS_KRAKEND.md`
- `.planning/CUTOVER_READ_FLOW_TRAEFIK_DEV.md`
- `load-tests/reports/POST_MIGRATION_COMPARISON.md` (métricas loop)
- [ADR-NATS-JETSTREAM.md](./ADR-NATS-JETSTREAM.md)
- [API_V2_CONTRACT_INVARIANTS.md](./API_V2_CONTRACT_INVARIANTS.md)
