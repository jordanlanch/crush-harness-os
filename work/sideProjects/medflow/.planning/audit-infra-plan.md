# Auditoría de Infraestructura & Tech — Plan GSD

> **Versión**: 1.0.0 | **Fecha**: 2026-05-29
> **Metodología**: GSD (Get Shit Done)

---

## Resumen Ejecutivo

La infraestructura de MedNext está sólida (Docker multi-entorno, CI/CD con GitHub Actions, Dokploy para producción) pero tiene vacíos en:

1. **Redis**: Subutilizado — solo para cache, no para gestión de sesiones concurrentes
2. **Testing**: Cobertura muy baja en backend (~3% global), infraestructura de test containers subutilizada
3. **Monitoreo**: Grafana desplegado pero sin dashboards de negocio (solo infra)
4. **CI/CD**: Sin stage de tests E2E en CI, sin stage de security scanning
5. **Database**: Migraciones con archivos "huérfanos" (db/migrations/ vs migrations/), sin sistema de rollback automático
6. **Config**: Múltiples archivos .env, falta consolidación

---

## FASE 1: Auditoría de Redis y Sesiones

### 1.1 Estado Actual

- Redis 7 desplegado en todos los entornos (dev, test, prod)
- Usado para: cache de sesiones JWT (probablemente), pub/sub
- NO usado para: gestión de concurrencia, rate limiting, token blacklist

### 1.2 Tareas

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-1.2.1 | Configurar Redis para `SessionManager` (keys, TTLs, contadores) | 🔴 ALTA |
| INF-1.2.2 | Configurar Redis para token blacklist (sesiones cerradas forzosamente) | 🔴 ALTA |
| INF-1.2.3 | Configurar Redis para rate limiting distribuido | 🟡 MEDIA |
| INF-1.2.4 | Probar failover de Redis: ¿qué pasa si Redis se cae en prod? | 🔴 ALTA |
| INF-1.2.5 | Documentar arquitectura Redis (keyspace, TTLs, backups) | 🟡 MEDIA |

---

## FASE 2: Auditoría de Base de Datos y Migraciones

### 2.1 Duplicación de Migraciones

**Problema detectado**: Dos ubicaciones de migraciones:
- `db/migrations/` — 28 archivos (usados por goose, los oficiales)
- `migrations/` — 2 archivos (001_create_base_tables.sql, 002_create_functions.sql) — PARECEN DUPLICADOS/HUÉRFANOS

**Riesgo**: Confusión sobre cuál es el source of truth. Los archivos en `migrations/` pueden ser versiones antiguas o no ejecutadas.

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-2.1.1 | Verificar si `migrations/` está siendo usado por algún proceso | 🔴 ALTA |
| INF-2.1.2 | Consolidar o eliminar `migrations/` si está obsoleto | 🔴 ALTA |
| INF-2.1.3 | Documentar que `db/migrations/` es el source of truth | 🟡 MEDIA |

### 2.2 Seeds y Datos de Prueba

**Problema**: Los seeds (`db/seeds/`, `seeds/`) están desactualizados. No incluyen datos para el nuevo modelo (clientes con estados, facilities con concurrencia).

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-2.2.1 | Actualizar seeds con clientes de prueba en diferentes estados | 🟡 MEDIA |
| INF-2.2.2 | Agregar seeds de facilities con `max_concurrent_sessions` | 🟡 MEDIA |
| INF-2.2.3 | Agregar seeds de `master_data_versions` (v1 inicial) | 🟡 MEDIA |

### 2.3 sqlc Queries

**Problema**: `db/queries/tenants.sql` tiene queries para `client_commercial_config` pero no para:
- Filtrado por estado
- Conteo de clientes por plan
- Consumo de instancias
- Alertas de clientes

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-2.3.1 | Agregar queries sqlc para dashboard admin (KPIs agregados) | 🔴 ALTA |
| INF-2.3.2 | Agregar queries sqlc para filtrado de clientes por estado | 🔴 ALTA |
| INF-2.3.3 | Agregar queries sqlc para consumo de instancias | 🔴 ALTA |
| INF-2.3.4 | Regenerar código sqlc después de cambios | 🔴 ALTA |

---

## FASE 3: Auditoría de Docker y Entornos

### 3.1 Entornos

| Entorno | Archivo | Estado |
|---------|---------|--------|
| Desarrollo | `docker-compose.yml` + `override.yml` | ✅ Completo |
| Test | `docker-compose.test.yml` | ✅ Completo |
| Producción | `dokploy/` (4 stacks) | ✅ Completo |
| CI | `.github/workflows/ci.yml` (service containers) | ✅ Completo |

### 3.2 Problemas Detectados

**3.2.1 Docker Compose de desarrollo**: No expone Redis con persistencia de datos. Al reiniciar, se pierden sesiones. Para desarrollo esto es aceptable, pero debe documentarse.

**3.2.2 Producción**: No hay backup automático de Redis (solo PostgreSQL). Las sesiones son efímeras, pero si Redis se reinicia, todos los usuarios son desconectados.

**3.2.3 Test**: `docker-compose.test.yml` no tiene Redis configurado para tests de concurrencia.

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-3.2.1 | Agregar persistencia Redis en `docker-compose.override.yml` (volumen con `redis-data:`) | 🟢 BAJA |
| INF-3.2.2 | Configurar backup de Redis en producción (AOF o RDB) | 🟡 MEDIA |
| INF-3.2.3 | Agregar Redis a `docker-compose.test.yml` para tests de sesiones | 🔴 ALTA |
| INF-3.2.4 | Actualizar CI workflow para incluir tests de concurrencia con Redis | 🟡 MEDIA |
| INF-3.2.5 | Documentar health checks de Redis en docker-compose | 🟢 BAJA |

---

## FASE 4: Auditoría de CI/CD

### 4.1 Workflow Actual (`.github/workflows/ci.yml`)

```
push/PR → lint (golangci) → test (go test + services) → build & push docker → deploy webhook
```

### 4.2 Problemas Detectados

- **Sin tests E2E en CI**: El proyecto tiene Playwright + E2E tests pero no se ejecutan en CI
- **Sin security scanning**: No hay Trivy, Snyk, o dependabot alerts para vulnerabilidades
- **Sin tests de frontend en CI**: Solo se ejecutan `go test`, no `npm test` (Vitest)
- **Deploy automático en cada push a main**: Puede ser peligroso sin stage de aprobación

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-4.2.1 | Agregar job de tests frontend (Vitest) al CI workflow | 🟡 MEDIA |
| INF-4.2.2 | Agregar job de tests E2E (Playwright) al CI workflow | 🟡 MEDIA |
| INF-4.2.3 | Agregar Trivy vulnerability scanning para imagen Docker | 🟡 MEDIA |
| INF-4.2.4 | Agregar stage de aprobación manual antes de deploy a prod (environment protection) | 🟡 MEDIA |
| INF-4.2.5 | Agregar notificación de deploy (Slack/Discord) | 🟢 BAJA |

---

## FASE 5: Auditoría de Monitoreo y Observabilidad

### 5.1 Estado Actual

- **Prometheus**: Endpoint `/metrics` existe (`metrics_handler.go`)
- **Grafana**: Desplegado en Dokploy (`dokploy/monitoring/docker-compose.yml`)
- **Logs**: zerolog con structured logging
- **Health checks**: `/health`, `/health/ready`, `/health/live`

### 5.2 Problemas Detectados

- Sin dashboards de negocio en Grafana (solo infraestructura)
- Sin alertas configuradas (clientes sin actividad, onboarding estancado, licencias llenas)
- Sin trazabilidad distribuida (OpenTelemetry)
- Las métricas de Prometheus son básicas (sin métricas de negocio)

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-5.2.1 | Agregar métricas de negocio a Prometheus (clientes por estado, sesiones activas, instancias consumidas) | 🟡 MEDIA |
| INF-5.2.2 | Crear dashboard Grafana para negocio (KPIs de clientes SaaS) | 🟡 MEDIA |
| INF-5.2.3 | Configurar alertas en Grafana: onboarding > 15 días, licencias > 90%, cliente inactivo 30 días | 🟡 MEDIA |
| INF-5.2.4 | Agregar health check de Redis al endpoint `/health/ready` | 🔴 ALTA |
| INF-5.2.5 | Documentar arquitectura de observabilidad | 🟢 BAJA |

---

## FASE 6: Auditoría de Seguridad

### 6.1 Estado Actual

- JWT con HS256, 15min access / 7d refresh
- CORS configurado
- Security headers (CSP, HSTS, XSS, Frame)
- PHI audit middleware
- Rate limiter en login

### 6.2 Problemas Detectados

- Sin escaneo de vulnerabilidades en dependencias (Go modules, npm)
- Sin CSP policy estricta (actualmente permisiva)
- Sin 2FA obligatorio para Platform Admin
- Sin auditoría de accesos del superusuario
- `.env` files con credenciales hardcodeadas en `.env.medflow` (desarrollo, pero mala práctica)

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-6.2.1 | Implementar 2FA obligatorio para Platform Admin (ya existe código, configurar policy) | 🔴 ALTA |
| INF-6.2.2 | Agregar `npm audit` y `govulncheck` al CI workflow | 🟡 MEDIA |
| INF-6.2.3 | Endurecer CSP policy | 🟡 MEDIA |
| INF-6.2.4 | Auditoría de logs: registrar toda acción del Platform Admin (crear/editar/eliminar clientes) | 🔴 ALTA |
| INF-6.2.5 | Limpiar credenciales hardcodeadas de `.env.medflow` | 🟢 BAJA |
| INF-6.2.6 | Agregar `.env.medflow` y `.env` al `.gitignore` (verificar) | 🟡 MEDIA |

---

## FASE 7: Auditoría de Performance

### 7.1 Estado Actual

- pgx connection pool (configurable)
- Sin caché de consultas frecuentes (catálogos, tablas maestras)
- Sin paginación en algunos endpoints (clientes puede crecer)

### 7.2 Tareas

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-7.2.1 | Agregar caché Redis para tablas maestras (diagnósticos, CUPS, municipios) | 🟡 MEDIA |
| INF-7.2.2 | Verificar paginación en `GET /admin/clients` | 🟡 MEDIA |
| INF-7.2.3 | Agregar índices en columnas de búsqueda frecuente (`tenants.status`, `tenants.created_at`) | 🟡 MEDIA |
| INF-7.2.4 | Load testing básico con `wrk` o `k6` en endpoints de dashboard | 🟢 BAJA |

---

## FASE 8: Limpieza de Código Muerto

### 8.1 Archivos Huérfanos Detectados

| Archivo | Problema | Acción |
|---------|----------|--------|
| `forge-token.go` | `main` duplicado, script suelto | Mover a `scripts/` o eliminar |
| `hash.go` | `main` duplicado | Mover a `scripts/` o eliminar |
| `test_db.go` | `main` duplicado | Mover a `scripts/` o eliminar |
| `update_status_mock.go` | `main` duplicado | Mover a `scripts/` o eliminar |
| `database.sqlite` | No usado por el proyecto | Eliminar |
| `migrations/` (dir) | Duplicado de `db/migrations/` | Consolidar o eliminar |
| `patch*.js`, `fix*.js/py/sh` (30+ archivos) | Scripts de hotfix sueltos en raíz | Mover a `scripts/hotfixes/` |
| `test*.js/py/sh` (8+ archivos) | Scripts de prueba sueltos | Mover a `scripts/tests/` |
| `*.wav`, `*.json` sueltos | Archivos de prueba | Mover a `tests/fixtures/` |

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| INF-8.1.1 | Mover scripts sueltos con `func main()` a `scripts/` | 🟡 MEDIA |
| INF-8.1.2 | Mover archivos de hotfix a `scripts/hotfixes/` | 🟢 BAJA |
| INF-8.1.3 | Eliminar `database.sqlite` | 🟡 MEDIA |
| INF-8.1.4 | Mover fixtures de test a `tests/fixtures/` | 🟢 BAJA |
| INF-8.1.5 | Agregar reglas al `.gitignore` para evitar nuevos archivos sueltos | 🟡 MEDIA |

---

## Resumen de Prioridades Infraestructura

### 🔴 Sprint 1 (Semana 1-2): Core Infra para Features Nuevas
- INF-1.2.1, INF-1.2.2: Redis para sesiones y blacklist
- INF-1.2.4: Failover Redis
- INF-2.1.1, INF-2.1.2: Consolidar migraciones
- INF-2.3.1 a INF-2.3.4: sqlc queries nuevas
- INF-3.2.3: Redis en docker-compose.test.yml
- INF-5.2.4: Health check Redis
- INF-6.2.1: 2FA obligatorio Platform Admin
- INF-6.2.4: Auditoría de acciones del Platform Admin

### 🟡 Sprint 2 (Semana 3-4): CI/CD + Monitoreo
- INF-4.2.1 a INF-4.2.3: CI mejorado (frontend tests, E2E, security scan)
- INF-5.2.1 a INF-5.2.3: Métricas + Grafana dashboards
- INF-6.2.2: Security scanning en CI
- INF-7.2.1 a INF-7.2.3: Caché + índices
- INF-8.1.1: Limpiar scripts sueltos

### 🟢 Sprint 3 (Semana 5-6): Pulido + Documentación
- INF-2.2.*: Seeds actualizados
- INF-3.2.1, INF-3.2.2: Persistencia Redis
- INF-4.2.4, INF-4.2.5: Aprobación deploy + notificaciones
- INF-5.2.5: Documentación
- INF-6.2.5, INF-6.2.6: Limpieza .env
- INF-8.1.2 a INF-8.1.5: Limpieza final

---

_Última revisión: 2026-05-29 — Auditoría completa de infraestructura_
