# Variables de entorno y descubrimiento de servicios (post-migración v2)

**Estado:** Inventario operativo — fase limpieza  
**Fecha:** 2026-05-25  
**Alcance:** `archetype-1` (BFF/gateway), NATS, KrakenD, tráfico MS↔MS  
**Relacionado:** [ADR-NATS-JETSTREAM.md](./ADR-NATS-JETSTREAM.md), [API_V2_CONTRACT_INVARIANTS.md](./API_V2_CONTRACT_INVARIANTS.md), [CLEANUP_PHASE_ENV.md](./CLEANUP_PHASE_ENV.md)

---

## Resumen ejecutivo

Tras el cutover dev (Traefik → KrakenD → archetype interno):

| Capa | Rol de env vars |
|------|-----------------|
| **Cliente externo** | Solo conoce `archetype-1-dev.docker.regalus.dev` (sin cambio de URL) |
| **KrakenD** | Backend interno `http://archetype-1-dev:9991` — **no** URL pública Traefik |
| **archetype-1** | Sigue llamando MS por HTTP sync vía `APP_SERVICE_*_ENDPOINT` |
| **NATS** | Bus async (`APP_NATS_*`) — invalidación caché, eventos; no reemplaza HTTP sync aún |

El BFF **no elimina** las llamadas HTTP directas archetype → MS en esta fase.

---

## 1. Inventario `APP_*` en archetype-1

Fuente de verdad en código: `archetype-1/pkg/settings/settings.go`, `validate.go`, `pkg/bus/config.go`, `pkg/service_client/service_client.go`, `pkg/api/middlewares/jwt.go`.

### 1.1 Core / servidor

| Variable | Uso actual | Post-migración |
|----------|------------|----------------|
| `APP_ADDRESS` | Bind `interface:port` (ej. `0.0.0.0:9991`) | **Mantener** |
| `APP_INTERFACE` / `APP_PORT` | Alternativa a `APP_ADDRESS` | **Mantener** (legacy parcial) |
| `APP_DB_DSN` | Conexión MySQL/SQLite | **Mantener** |
| `APP_DB_DIALECT` | `mysql` \| `sqlite` | **Mantener** |
| `APP_DB_HOST`, `APP_DB_PORT`, `APP_DB_USER`, `APP_DB_PASS`, `APP_DB_NAME` | Arman DSN si falta `APP_DB_DSN` (Dokploy) | **Mantener** |
| `APP_DOMAIN` | Dominio del tenant/gateway | **Mantener** |
| `APP_LOG_FILE` | Ruta log; deriva `APP_LOGS_PATH` | **Mantener** |
| `APP_LOGS_PATH`, `APP_LOGS_ACCESS`, `APP_LOGS_ERROR` | Logging estructurado | **Mantener** |
| `APP_ACCESS_LOG` | Access log HTTP | **Mantener** |
| `APP_STATIC_PATH` | Assets estáticos | **Mantener** |
| `APP_PPROF` | Profiling opcional | **Mantener** |
| `APP_MIGRATION_PATH` | Migraciones GORM (deploy) | **Mantener** |

### 1.2 Seguridad / JWT

| Variable | Uso actual | Post-migración |
|----------|------------|----------------|
| `APP_SECURITY_JWT_ACCESS_SECRET` | Firma/validación JWT local | **Mantener** — KrakenD **no** valida JWT |
| `APP_SECURITY_TOKEN_LIFESPAN` | TTL token | **Mantener** |
| `APP_JWT_LOCAL_VALIDATION` | `true` = JWTV2 local; `false` = rollback introspección remota (BUG-CLIP-003) | **Mantener** (`true` en dev/prod) |
| `APP_ENCRYPTION_KEY` | Cifrado auxiliar | **Mantener** |
| `APP_SECURITY_ENCRYPTION_KEY` | Alias legacy en algunos payloads Dokploy | **Unificar** → `APP_ENCRYPTION_KEY` (candidata deprecación) |
| `APP_AUTH_TRACE_401` | Trace debug 401 | **Mantener** (solo debug) |

### 1.3 CORS / rate limit / HTTP saliente

| Variable | Uso actual | Post-migración |
|----------|------------|----------------|
| `APP_CORS_*` | CORS middleware | **Mantener** en archetype (KrakenD no sustituye CORS del MS) |
| `APP_RATE_LIMIT_IP_MAX_REQS` | DoS por IP (default 100) | **Mantener** — replicar en KrakenD plugin si se centraliza |
| `APP_RATE_LIMIT_IP_INTERVAL_SECONDS` | Ventana rate limit | **Mantener** |
| `APP_RATE_LIMIT_INTERVAL` | Legacy interval | **Deprecar** si no referenciado en prod |
| `APP_HTTP_CLIENT_TIMEOUT_SECONDS` | Timeout cliente HTTP saliente (default 30) | **Mantener** |
| `APP_HTTP_RETRY_GET_MAX` | Reintentos GET idempotentes | **Mantener** |
| `APP_HTTP_RETRY_BACKOFF_MS` | Backoff reintentos | **Mantener** |

### 1.4 Cache / misc

| Variable | Uso actual | Post-migración |
|----------|------------|----------------|
| `APP_CACHE_LIFE_WINDOW`, `APP_CACHE_CLEAN_WINDOW` | Cache in-process | **Mantener** |
| `APP_GIFT_CARD_REDEMPTION_URL` | URL canje gift cards | **Mantener** |

### 1.5 OpenTelemetry

| Variable | Uso actual | Post-migración |
|----------|------------|----------------|
| `OTEL_BSP_*` | Batch span processor | **Mantener** (ver README archetype-1) |

---

## 2. `APP_NATS_*` (archetype, catalog, users-management)

Implementación idéntica en:

- `archetype-1/pkg/bus/config.go`
- `catalog-service/pkg/bus/config.go`
- `users-management/app/pkg/bus/config.go`

| Variable | Default (código) | Uso | Post-migración |
|----------|------------------|-----|----------------|
| `APP_NATS_ENABLED` | off si vacío | Activa suscriptor/publicador JetStream | **Mantener** — `true` en dev tras Wave 0 |
| `APP_NATS_URL` | `nats://127.0.0.1:4222` | Broker NATS en `dokploy-network` | **Mantener** — dev: `nats://compose-alus-nats-dev-nats-1:4222` |
| `APP_NATS_STREAM` | `ALUS_DEV` | Stream JetStream | **Mantener** |

**Sync Dokploy ↔ Swarm:** tras redeploy archetype, re-aplicar con `archetype-1/scripts/configure-dokploy-nats-env.sh` (BD Dokploy ≠ spec Swarm). Ver `.planning/INFRA_DOKPLOY_NATS_KRAKEND.md`.

**Nota:** NATS complementa HTTP; no sustituye `APP_SERVICE_*` en esta fase.

---

## 3. `APP_SERVICE_*` — endpoints HTTP desde archetype-1

Patrón de parsing (`settings.go:325-358`):

```
APP_SERVICE_<NAME>_ENDPOINT
APP_SERVICE_<NAME>_SERVICE_NAME   → ServiceCode
APP_SERVICE_<NAME>_SERVICE_TOKEN
APP_SERVICE_<NAME>_CLIENT_CODE
APP_SERVICE_<NAME>_CLIENT_TOKEN
APP_SERVICE_<NAME>_PROJECT_CODE
```

`<NAME>` en env se normaliza case-insensitive en `GetService()`. Alias: `client` ↔ `clients`.

### 3.1 Servicios referenciados en código (GetService)

| Clave GetService | Variable env típica (dev) | MS destino | ¿HTTP directo post-BFF? |
|------------------|---------------------------|------------|-------------------------|
| `usersv2` | `APP_SERVICE_USERSV2_ENDPOINT` | **users-management** `/api/v1` | **Sí** — obligatorio; validación startup (BUG-CLIP-002) |
| `users` | `APP_SERVICE_USERS_ENDPOINT` | users-management o legacy users-service | **Sí** — flujos v1/v2 mixtos |
| `catalog` | `APP_SERVICE_CATALOG_ENDPOINT` | catalog-service | **Sí** |
| `client` / `clients` | `APP_SERVICE_CLIENT_ENDPOINT` o `_CLIENTS_` | clients / clients-v2 | **Sí** |
| `purchase-orders` | `APP_SERVICE_PURCHASE-ORDERS_ENDPOINT` | purchase-orders | **Sí** — sagas canje |
| `communication` | `APP_SERVICE_COMMUNICATION_ENDPOINT` | communication | **Sí** |
| `validation` | `APP_SERVICE_VALIDATION_ENDPOINT` | validation | **Sí** |
| `validation_v2` | `APP_SERVICE_VALIDATIONV2_ENDPOINT` | validation-v2 | **Sí** |
| `goals` | `APP_SERVICE_GOALS_ENDPOINT` | goals | **Sí** |
| `addresses` | `APP_SERVICE_ADDRESSES_ENDPOINT` | addresses | **Sí** (v2 participant address) |
| `products_list` | `APP_SERVICE_PRODUCTS_LIST_*` | catálogo/listados | **Sí** |
| `sell-out` | `APP_SERVICE_SELL-OUT_ENDPOINT` | sell-out MS | **Sí** |
| `products` | `APP_SERVICE_PRODUCTS_ENDPOINT` | catalog-service (alias) | **Sí** — legacy nombre |
| `wallets` | `APP_SERVICE_WALLETS_ENDPOINT` | wallets | **Sí** — en payload dev Dokploy |

### 3.2 Valores dev documentados (evidencia)

Ejemplo real en `payload_dev.json` (Dokploy archetype-1-dev) — **contiene error conocido** en usersV2:

| Variable | Valor en payload | Nota |
|----------|------------------|------|
| `APP_SERVICE_USERSV2_ENDPOINT` | `http://users-service-dev...` | **Incorrecto** — debe ser users-management (BUG-CLIP-002) |
| `APP_SERVICE_CATALOG_ENDPOINT` | `http://catalog-service-dev.docker.regalus.dev/api/v1` | OK patrón Traefik |
| `APP_SERVICE_CLIENT_ENDPOINT` | `http://clients-dev.docker.regalus.dev/api/v1` | OK |

### 3.3 Resolución de host recomendada (dev Swarm)

| Patrón | Cuándo usar | Post-migración |
|--------|-------------|----------------|
| `{ms}-dev.docker.regalus.dev` | MS con dominio Traefik propio | **Mantener** para tráfico archetype→MS (interno red Docker resuelve) |
| `{ms}-dev:PORT` | Alias en `dokploy-network` | **Preferir** en limpieza (menos hop Traefik) |
| `app-*-random:PORT` | Nombre Swarm feo | **Cambiar** → alias legible (ver CLEANUP) |

**KrakenD no interviene** en llamadas archetype → otros MS; solo en tráfico **entrante** cliente → gateway.

---

## 4. KrakenD — qué NO configurar

Fuente: `archetype-1/scripts/generate_krakend_v2.py`, `.planning/INFRA_DOKPLOY_NATS_KRAKEND.md`.

| Config | ¿En KrakenD? | Motivo |
|--------|--------------|--------|
| Validación JWT / introspección UM | **NO** | Permanece en archetype (`JWTV2`, `APP_JWT_LOCAL_VALIDATION`) |
| `APP_SERVICE_*` / hosts MS | **NO** | KrakenD solo proxy a archetype |
| Backend `http://archetype-1-dev.docker.regalus.dev` | **NO** post-cutover | Loop Traefik→KrakenD→Traefik (~57% failed k6) |
| Backend `http://archetype-1-dev:9991` | **SÍ** (default) | Alias interno `dokploy-network` |
| Rate limit auth login | Exempt o límite alto | `POST /api/v2/auth/` |
| CORS origen tenant | Opcional en KrakenD | CORS sigue en archetype hoy |

Variable de generación:

```bash
export KRAKEND_BACKEND=http://archetype-1-dev:9991   # default correcto
# Emergencia: KRAKEND_BACKEND=$KRAKEND_BACKEND_SWARM_FALLBACK
```

---

## 5. users-management y catalog — `APP_SERVICE_*` salientes

**users-management** (`validate.go`): obligatorios `APP_SERVICE_CLIENTS_ENDPOINT`, `APP_SERVICE_CATALOG_ENDPOINT`.

**catalog-service:** publica eventos NATS; dependencias HTTP vía su propio `APP_SERVICE_*` (ver `catalog-service/pkg/service/config.go`).

Estos MS **no** deben apuntar a `archetype-1-dev.docker.regalus.dev` para llamadas internas (ver sección loop en CLEANUP).

---

## 6. Referencias ADR

| Documento | Relación |
|-----------|----------|
| [API_V2_CONTRACT_INVARIANTS.md](./API_V2_CONTRACT_INVARIANTS.md) | Contrato HTTP congelado; env no cambia paths |
| [ADR-NATS-JETSTREAM.md](./ADR-NATS-JETSTREAM.md) | Decisión bus async + `APP_NATS_*` |
| [CLEANUP_PHASE_ENV.md](./CLEANUP_PHASE_ENV.md) | Checklist deprecaciones y aliases Swarm |

---

## 7. Verificación rápida

```bash
# Auditar env Dokploy dev (SSH al host)
./load-tests/scripts/audit-dokploy-env.sh

# Tras redeploy archetype — NATS
./archetype-1/scripts/configure-dokploy-nats-env.sh

# Smoke gateway (URL pública — correcto para clientes)
BASE_URL=http://archetype-1-dev.docker.regalus.dev ./load-tests/precheck-dev.sh
```
