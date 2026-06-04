# Auditoría de Backend — Plan GSD

> **Versión**: 1.0.0 | **Fecha**: 2026-05-29
> **Metodología**: GSD (Get Shit Done)

---

## Resumen Ejecutivo

El backend de MedNext (Go 1.24, Echo, Clean Architecture, 43 handlers, 40+ usecases, 50+ repos) está arquitectónicamente sólido pero presenta vacíos críticos para el nuevo modelo de negocio:

1. **Estados del cliente**: No existe `ClientStatus` enum ni workflow de transiciones
2. **Sesiones concurrentes**: No hay `SessionManager` en Redis ni middleware de concurrencia
3. **Dashboard admin**: No existen endpoints de KPIs agregados
4. **Versionamiento de tablas maestras**: No hay dominio, repositorio, ni endpoints
5. **Cobertura de tests**: 0% en handlers, 8% en usecases, 0% en repos (excepto AI)
6. **Migraciones**: Faltan tablas para concurrencia y versionamiento

---

## FASE 1: Auditoría de Dominio y Modelo de Datos

### 1.1 Estados del Cliente

**Estado actual**: Tabla `tenants` tiene `is_active` (boolean). No hay workflow de estados.

**Problema**: El modelo de negocio requiere un ciclo de vida con 7 estados: prospecto → cotizado → contratado → en_onboarding → activo → suspendido → inactivo.

**Archivos afectados**:
- `internal/domain/client/entity.go` — agregar `ClientStatus` enum
- `internal/domain/client/repository.go` — agregar `UpdateStatus`
- `internal/infrastructure/persistence/repository/client_repository.go` — implementar
- `internal/application/usecase/client_usecase.go` — lógica de transiciones
- `internal/application/dto/client/client_dto.go` — DTOs de estado
- `internal/interface/http/handler/client_handler.go` — endpoint `PUT /admin/clients/:id/status`
- `db/migrations/` — nueva migración con columna `status`

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-1.1.1 | Agregar `ClientStatus` enum al domain entity | 🔴 ALTA |
| BK-1.1.2 | Migración: agregar columna `status` a `tenants` con default `activo` | 🔴 ALTA |
| BK-1.1.3 | Implementar `UpdateStatus` en repository | 🔴 ALTA |
| BK-1.1.4 | Implementar lógica de transiciones válidas en usecase | 🔴 ALTA |
| BK-1.1.5 | Endpoint `PUT /admin/clients/:id/status` | 🔴 ALTA |
| BK-1.1.6 | Agregar filtro `?status=` en `GET /admin/clients` | 🟡 MEDIA |
| BK-1.1.7 | Tests unitarios de transiciones de estado | 🟡 MEDIA |

### 1.2 Sesiones Concurrentes

**Estado actual**: JWT-only. Sin persistencia de sesiones en Redis. Sin control de concurrencia.

**Problema**: El modelo comercial requiere control por facility de instancias concurrentes, cierre de sesiones duplicadas, y timeouts.

**Arquitectura propuesta**: Ver `docs/SESIONES_CONCURRENTES.md`

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-1.2.1 | Migración: agregar `max_concurrent_sessions` y `session_timeout_minutes` a `facilities` | 🔴 ALTA |
| BK-1.2.2 | Implementar `SessionManager` en Redis (registrar, cerrar, contar, limpiar) | 🔴 ALTA |
| BK-1.2.3 | Modificar `AuthUseCase.Login()` con verificación de concurrencia | 🔴 ALTA |
| BK-1.2.4 | Modificar `AuthUseCase.Logout()` para limpiar sesión en Redis | 🔴 ALTA |
| BK-1.2.5 | Crear `SessionMiddleware` que valida sesión activa en cada request | 🔴 ALTA |
| BK-1.2.6 | Background job de limpieza de sesiones inactivas (goroutine en Fx lifecycle) | 🟡 MEDIA |
| BK-1.2.7 | Endpoint `GET /admin/facilities/:id/sessions` | 🔴 ALTA |
| BK-1.2.8 | Endpoint `DELETE /admin/facilities/:id/sessions/:sessionId` | 🔴 ALTA |
| BK-1.2.9 | Endpoint `GET /admin/clients/:id/instance-usage` | 🔴 ALTA |
| BK-1.2.10 | Tests unitarios de `SessionManager` | 🟡 MEDIA |
| BK-1.2.11 | Tests de integración de login con concurrencia | 🟡 MEDIA |
| BK-1.2.12 | Tests de middleware de sesión | 🟡 MEDIA |

### 1.3 Versionamiento de Tablas Maestras

**Estado actual**: No existe. Las tablas de catálogo son estáticas sin versionado.

**Problema**: Cambios normativos (CIE-10, CUPS, DIVIPOLA) romperían la operación de clientes existentes si no hay versionado.

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-1.3.1 | Migración: crear `master_data_versions` y `master_data_changes` | 🟡 MEDIA |
| BK-1.3.2 | Migración: agregar `master_data_version_id` a `tenants` | 🟡 MEDIA |
| BK-1.3.3 | Crear domain `master_data` con `MasterDataVersion` entity | 🟡 MEDIA |
| BK-1.3.4 | Implementar `MasterDataVersionRepository` | 🟡 MEDIA |
| BK-1.3.5 | Implementar `MasterDataVersionUseCase` | 🟡 MEDIA |
| BK-1.3.6 | Implementar `MasterDataVersionHandler` con endpoints CRUD | 🟡 MEDIA |
| BK-1.3.7 | Crear `VersionResolver` — middleware/servicio que resuelve la versión activa por tenant | 🟡 MEDIA |
| BK-1.3.8 | Tests de versionamiento | 🟢 BAJA |

---

## FASE 2: Auditoría de Endpoints — Vacíos

### 2.1 Dashboard Admin Endpoints

**Estado actual**: No existen endpoints de dashboard administrativo. El handler `report.go` tiene endpoints de reportes operativos (citas, pacientes, billing), no de gestión SaaS.

**Endpoints requeridos** (según `docs/DASHBOARD_ADMIN_SPEC.md`):

| Endpoint | Propósito | Handler |
|----------|-----------|---------|
| `GET /api/v1/admin/dashboard/summary` | KPIs agregados | `AdminDashboardHandler` |
| `GET /api/v1/admin/dashboard/clients-by-plan` | Distribución por plan | ^ |
| `GET /api/v1/admin/dashboard/clients-needing-attention` | Alertas | ^ |
| `GET /api/v1/admin/dashboard/recent-activity` | Timeline | ^ |
| `GET /api/v1/admin/dashboard/instance-usage` | Consumo top | ^ |

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-2.1.1 | Crear DTOs `admin_dashboard_dto.go` | 🔴 ALTA |
| BK-2.1.2 | Implementar `AdminDashboardUseCase` con queries agregadas | 🔴 ALTA |
| BK-2.1.3 | Implementar `AdminDashboardHandler` con 5 endpoints | 🔴 ALTA |
| BK-2.1.4 | Registrar rutas en `router.go` bajo `RequireRole(admin)` | 🔴 ALTA |
| BK-2.1.5 | Tests unitarios del usecase | 🟡 MEDIA |
| BK-2.1.6 | Tests de integración de endpoints | 🟡 MEDIA |

### 2.2 Configuración Comercial Extendida

**Estado actual**: `client_commercial_config` existe con `billing_model`, `session_price`, etc. Pero falta `max_concurrent_sessions` a nivel facility.

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-2.2.1 | Extender DTO `UpsertCommercialConfigRequest` con `max_concurrent_sessions_per_facility` | 🔴 ALTA |
| BK-2.2.2 | Actualizar `client_commercial_config.custom_config` JSONB con nuevos campos | 🔴 ALTA |
| BK-2.2.3 | Sincronizar `custom_config.max_concurrent_sessions` con `facilities.max_concurrent_sessions` | 🟡 MEDIA |

### 2.3 Documentos del Cliente — Workflow

**Estado actual**: CRUD de documentos existe pero sin workflow de aprobación.

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-2.3.1 | Agregar enum `DocumentStatus` (pendiente, aprobado, rechazado) | 🟡 MEDIA |
| BK-2.3.2 | Endpoint `PUT /admin/clients/:id/documents/:docId/approve` | 🟡 MEDIA |
| BK-2.3.3 | Endpoint `PUT /admin/clients/:id/documents/:docId/reject` | 🟡 MEDIA |
| BK-2.3.4 | Validación: no activar cliente si documentos obligatorios faltan | 🔴 ALTA |

---

## FASE 3: Auditoría de Middleware y Seguridad

### 3.1 RBAC — Roles MedNext vs Cliente

**Estado actual**: Roles definidos como strings (`admin`, `doctor`, `nurse`, etc.) sin diferenciación de tenant.

**Problema**: El "admin" puede ser tanto Platform Admin (MedNext) como Client Admin (cliente). No hay distinción en el middleware.

**Análisis**:
- `RequireRole("admin")` protege rutas `/admin/*` — pero un admin de cliente NO debería ver todos los clientes
- Solución: El `Auth` middleware ya inyecta `tenant_id` en el contexto. Las queries deben filtrar por `tenant_id` donde aplica
- El Platform Admin tiene `tenant_id` del tenant MedNext (ID 1, el default)
- Los Client Admins tienen `tenant_id` de su propio cliente

**Verificación**: Revisar que todos los handlers de admin filtren correctamente por tenant. Esto YA debería estar implementado en el `client_repository.go` y `admin_usecase.go`.

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-3.1.1 | Auditar que `GET /admin/clients` solo retorne todos para Platform Admin (tenant_id=1) | 🔴 ALTA |
| BK-3.1.2 | Verificar que Client Admin no pueda ver/editar otros clientes | 🔴 ALTA |
| BK-3.1.3 | Agregar test de seguridad: Client Admin intenta acceder a otro tenant → 403 | 🔴 ALTA |
| BK-3.1.4 | Documentar matriz RBAC con tenant scoping | 🟡 MEDIA |

### 3.2 Auditoría de PHI (Protected Health Information)

**Estado actual**: Middleware `PHIAccessAudit()` existe para pharmacy. `access_log.go` audita accesos clínicos.

**Problema**: El superusuario MedNext NO debe ver PHI (historias clínicas, datos de pacientes). Esto debe ser forzado a nivel de middleware/query, no solo UI.

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-3.2.1 | Agregar middleware que bloquee acceso a endpoints clínicos para Platform Admin | 🔴 ALTA |
| BK-3.2.2 | Revisar que queries de dashboard admin no incluyan datos de pacientes | 🔴 ALTA |
| BK-3.2.3 | Test: Platform Admin intenta `GET /patients` → 403 | 🔴 ALTA |

### 3.3 Rate Limiting y Seguridad de Sesiones

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-3.3.1 | Rate limiter específico para `/auth/login` (prevenir brute force) | 🟡 MEDIA |
| BK-3.3.2 | Token blacklist en Redis para sesiones cerradas por admin | 🟡 MEDIA |
| BK-3.3.3 | Invalidar refresh tokens al cerrar sesión forzosamente | 🟡 MEDIA |

---

## FASE 4: Auditoría de Tests

### 4.1 Cobertura Actual

| Capa | Cobertura | Target |
|------|-----------|--------|
| Handlers | ~0% | 75% |
| UseCases | ~8% | 85% |
| Repositories | ~0% | 80% |
| Domain Entities | ~30% | 90% |
| AI Module | 80% | 85% |
| Integration | Parcial | 80% |

### 4.2 Tareas de Testing

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-4.2.1 | Tests de `ClientUseCase` (CRUD + estados + transiciones) | 🟡 MEDIA |
| BK-4.2.2 | Tests de `SessionManager` | 🟡 MEDIA |
| BK-4.2.3 | Tests de `AdminDashboardUseCase` | 🟡 MEDIA |
| BK-4.2.4 | Tests de `AuthUseCase` con concurrencia | 🟡 MEDIA |
| BK-4.2.5 | Tests de `MasterDataVersionUseCase` | 🟢 BAJA |
| BK-4.2.6 | Tests de integración: flujo completo creación cliente → activación | 🟡 MEDIA |
| BK-4.2.7 | Tests de seguridad: RBAC tenant scoping | 🔴 ALTA |
| BK-4.2.8 | Tests de seguridad: PHI isolation | 🔴 ALTA |

---

## FASE 5: Migraciones Pendientes

### 5.1 Nuevas Migraciones Requeridas

| # | Nombre | Tablas/Columnas |
|---|--------|-----------------|
| 00119 | `add_client_status.sql` | `tenants.status VARCHAR(20) DEFAULT 'activo'` |
| 00120 | `add_concurrent_sessions.sql` | `facilities.max_concurrent_sessions INT DEFAULT 5`, `facilities.session_timeout_minutes INT DEFAULT 30` |
| 00121 | `create_master_data_versions.sql` | `master_data_versions`, `master_data_changes` |
| 00122 | `add_tenant_master_version.sql` | `tenants.master_data_version_id UUID FK` |
| 00123 | `seed_master_data_v1.sql` | Insertar versión 1 inicial para clientes existentes |

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| BK-5.1.1 | Crear migración 00119 (client status) | 🔴 ALTA |
| BK-5.1.2 | Crear migración 00120 (concurrent sessions) | 🔴 ALTA |
| BK-5.1.3 | Crear migración 00121-00123 (master data versioning) | 🟡 MEDIA |
| BK-5.1.4 | Rollback scripts para cada migración | 🔴 ALTA |

---

## Resumen de Prioridades Backend

### 🔴 Sprint 1 (Semana 1-2): Estados + Sesiones + Dashboard
- BK-1.1.1 a BK-1.1.5: Estados del cliente
- BK-1.2.1 a BK-1.2.5: SessionManager + Redis + middleware
- BK-1.2.7 a BK-1.2.9: Endpoints de sesiones
- BK-2.1.1 a BK-2.1.4: Dashboard admin endpoints
- BK-3.1.1 a BK-3.1.3: RBAC tenant scoping
- BK-3.2.1 a BK-3.2.3: PHI isolation
- BK-5.1.1, BK-5.1.2, BK-5.1.4: Migraciones core

### 🟡 Sprint 2 (Semana 3-4): Comercial + Documentos + Versionamiento
- BK-1.3.1 a BK-1.3.7: Master data versioning
- BK-2.2.1 a BK-2.2.3: Config comercial extendida
- BK-2.3.1 a BK-2.3.4: Workflow de documentos
- BK-3.3.1 a BK-3.3.3: Rate limiting y seguridad
- BK-5.1.3: Migraciones versionamiento

### 🟢 Sprint 3 (Semana 5-6): Tests
- BK-4.2.*: Todos los tests
- BK-1.1.6, BK-1.1.7: Filtros y tests de estados
- BK-1.2.10 a BK-1.2.12: Tests de sesiones

---

_Última revisión: 2026-05-29 — Auditoría completa de backend_
