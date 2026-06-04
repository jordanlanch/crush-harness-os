# GSD Project Plan — MedNext Platform Foundation

> **Project**: Definición de Modelo de Negocio y Plataforma Base
> **Creado**: 2026-05-29
> **Fuente**: Reunión 29/05/2026
> **Metodología**: GSD (Get Shit Done)

---

## FASE 0: Discovery (Completada ✅)

La reunión del 29/05/2026 definió:

- **Problema**: La plataforma carece de un modelo de negocio claro, glosario unificado, flujo de creación de clientes, control de sesiones, y versionamiento de tablas maestras
- **Objetivo**: Construir la base de la plataforma alrededor del concepto "MedNext administra clientes; los clientes administran su operación"
- **Decisiones clave**:
  - Cobro por punto de atención, no por usuario
  - Instancias concurrentes por facility
  - Dashboard administrativo orientado a clientes (no pacientes)
  - Versionamiento de tablas maestras
  - Roles separados: superusuario MedNext vs admin del cliente

---

## FASE 1: Definición y Documentación

### Phase 1 Deliverables

| # | Deliverable | Archivo | Estado |
|---|-------------|---------|--------|
| 1.1 | Glosario de Términos | `docs/GLOSARIO.md` | ✅ Creado |
| 1.2 | Modelo Comercial | `docs/MODELO_COMERCIAL.md` | ✅ Creado |
| 1.3 | Flujo de Creación de Cliente | `docs/FLUJO_CREACION_CLIENTE.md` | ✅ Creado |
| 1.4 | Dashboard Admin Spec | `docs/DASHBOARD_ADMIN_SPEC.md` | ✅ Creado |
| 1.5 | Sesiones Concurrentes | `docs/SESIONES_CONCURRENTES.md` | ✅ Creado |
| 1.6 | Versionamiento Tablas Maestras | `docs/VERSIONAMIENTO_TABLAS_MAESTRAS.md` | ✅ Creado |

### Phase 1 Review
- [ ] Revisar con el equipo el jueves (próxima reunión)
- [ ] Validar que el glosario cubra todas las ambigüedades
- [ ] Confirmar modelo de precios (rangos, valores)
- [ ] Aprobar el flujo de creación de cliente

---

## FASE 2: Backend — Modelo de Negocio

### 2.1 Estados del Cliente
**Archivos**: `internal/domain/client/entity.go`, migración SQL

- [ ] **TASK-2.1.1**: Agregar enum `ClientStatus` (prospecto, cotizado, contratado, en_onboarding, activo, suspendido, inactivo)
- [ ] **TASK-2.1.2**: Agregar columna `status` a tabla `tenants`
- [ ] **TASK-2.1.3**: Agregar endpoint `PUT /admin/clients/:id/status` para cambiar estado
- [ ] **TASK-2.1.4**: Agregar validaciones de transición de estados
- [ ] **TASK-2.1.5**: Tests de transiciones de estado

### 2.2 Configuración de Instancias Concurrentes
**Archivos**: `internal/domain/client/entity.go`, Redis, middleware

- [ ] **TASK-2.2.1**: Agregar `max_concurrent_sessions` a tabla `facilities`
- [ ] **TASK-2.2.2**: Agregar `session_timeout_minutes` a tabla `facilities`
- [ ] **TASK-2.2.3**: Implementar `SessionManager` en Redis (registrar, cerrar, contar)
- [ ] **TASK-2.2.4**: Modificar `AuthUseCase.Login()` con control de concurrencia
- [ ] **TASK-2.2.5**: Modificar `AuthUseCase.Logout()` para limpiar sesión
- [ ] **TASK-2.2.6**: Crear `SessionMiddleware` para validar sesión activa
- [ ] **TASK-2.2.7**: Background job de limpieza de sesiones inactivas
- [ ] **TASK-2.2.8**: Tests de concurrencia

### 2.3 Dashboard Admin Endpoints
**Archivos**: `internal/interface/http/handler/admin_dashboard.go`

- [ ] **TASK-2.3.1**: `GET /admin/dashboard/summary` — KPIs agregados
- [ ] **TASK-2.3.2**: `GET /admin/dashboard/clients-by-plan` — distribución
- [ ] **TASK-2.3.3**: `GET /admin/dashboard/clients-needing-attention` — alertas
- [ ] **TASK-2.3.4**: `GET /admin/dashboard/recent-activity` — timeline
- [ ] **TASK-2.3.5**: `GET /admin/dashboard/instance-usage` — consumo top
- [ ] **TASK-2.3.6**: Tests del dashboard

### 2.4 Versionamiento de Tablas Maestras
**Archivos**: migraciones, `internal/domain/master_data/`

- [ ] **TASK-2.4.1**: Crear tabla `master_data_versions`
- [ ] **TASK-2.4.2**: Crear tabla `master_data_changes`
- [ ] **TASK-2.4.3**: Agregar `master_data_version_id` a `tenants`
- [ ] **TASK-2.4.4**: Domain entity `MasterDataVersion`
- [ ] **TASK-2.4.5**: Repository + UseCase + Handler
- [ ] **TASK-2.4.6**: Endpoints REST para gestión de versiones
- [ ] **TASK-2.4.7**: Servicio `VersionResolver` (middleware que resuelve qué versión aplica)
- [ ] **TASK-2.4.8**: Tests

---

## FASE 3: Frontend — Admin Dashboard

### 3.1 Componente Dashboard Admin
**Archivos**: `frontend/src/app/features/admin/dashboard/`

- [ ] **TASK-3.1.1**: Crear `AdminDashboardComponent` standalone
- [ ] **TASK-3.1.2**: Cards de KPIs (clientes totales, activos, onboarding, suspendidos)
- [ ] **TASK-3.1.3**: Gráfico "Clientes por Plan" (barras)
- [ ] **TASK-3.1.4**: Gráfico "Distribución por Sedes"
- [ ] **TASK-3.1.5**: Lista "Clientes que Requieren Atención"
- [ ] **TASK-3.1.6**: Lista "Últimos Clientes Creados"
- [ ] **TASK-3.1.7**: Timeline "Actividad Reciente"
- [ ] **TASK-3.1.8**: Barras "Consumo de Instancias (Top 5)"
- [ ] **TASK-3.1.9**: Tests unitarios (Vitest)

### 3.2 Servicio Dashboard Admin
**Archivos**: `frontend/src/app/core/services/admin-dashboard.service.ts`

- [ ] **TASK-3.2.1**: Crear `AdminDashboardService` con métodos para cada endpoint
- [ ] **TASK-3.2.2**: Tipos/Interfaces para respuestas del dashboard
- [ ] **TASK-3.2.3**: Tests del servicio

### 3.3 Extender Detalle de Cliente
**Archivos**: `frontend/src/app/features/admin/clients-detail/`

- [ ] **TASK-3.3.1**: Agregar indicador de estado del cliente (badge)
- [ ] **TASK-3.3.2**: Mostrar consumo de instancias en tab "Config Comercial"
- [ ] **TASK-3.3.3**: Botón para cambiar estado del cliente (admin)
- [ ] **TASK-3.3.4**: Mostrar sesiones activas en tab "Puntos de Atención"

### 3.4 Extender Lista de Clientes
**Archivos**: `frontend/src/app/features/admin/clients-list/`

- [ ] **TASK-3.4.1**: Agregar columna de estado con badge de color
- [ ] **TASK-3.4.2**: Filtros por estado, plan, fecha
- [ ] **TASK-3.4.3**: Indicador de alertas (onboarding estancado, docs pendientes)

---

## FASE 4: Testing y Validación

### 4.1 Backend Tests
- [ ] **TASK-4.1.1**: Tests unitarios de `SessionManager`
- [ ] **TASK-4.1.2**: Tests de integración de login con concurrencia
- [ ] **TASK-4.1.3**: Tests de endpoints del dashboard
- [ ] **TASK-4.1.4**: Tests de versionamiento de tablas maestras
- [ ] **TASK-4.1.5**: Tests de transiciones de estado del cliente

### 4.2 Frontend Tests
- [ ] **TASK-4.2.1**: Tests unitarios del `AdminDashboardComponent`
- [ ] **TASK-4.2.2**: Tests unitarios del `AdminDashboardService`
- [ ] **TASK-4.2.3**: Tests E2E del flujo de creación de cliente
- [ ] **TASK-4.2.4**: Tests E2E del dashboard admin

### 4.3 Casos Borde
- [ ] Login con licencia llena → rechazo 429
- [ ] Login duplicado mismo usuario → cierra sesión anterior
- [ ] Sesión expira por inactividad
- [ ] Admin cierra sesión de otro usuario
- [ ] Creación de cliente sin documentos requeridos
- [ ] Cliente con múltiples sedes y diferentes versiones de tablas

---

## Priorización

### 🚀 Sprint 1 (Alta Prioridad — Próxima semana)
1. TASK-2.1.1 al 2.1.5: Estados del cliente
2. TASK-2.2.1 al 2.2.3: Base de datos + Redis para sesiones
3. TASK-3.1.1 al 3.1.3: Dashboard admin básico (KPIs + gráficos)

### 🔧 Sprint 2 (Media Prioridad)
4. TASK-2.2.4 al 2.2.8: Control de concurrencia completo
5. TASK-2.3.1 al 2.3.6: Endpoints del dashboard
6. TASK-3.1.4 al 3.1.9: Dashboard admin completo

### 📋 Sprint 3 (Media-Baja)
7. TASK-2.4.1 al 2.4.8: Versionamiento de tablas maestras
8. TASK-3.3.1 al 3.4.3: Extensiones de cliente en frontend
9. TASK-4.1.1 al 4.2.4: Tests

---

## Documentos Relacionados

| Documento | Ruta | Propósito |
|-----------|------|-----------|
| Glosario | `docs/GLOSARIO.md` | Términos unificados |
| Modelo Comercial | `docs/MODELO_COMERCIAL.md` | Cobro por punto de atención |
| Flujo Cliente | `docs/FLUJO_CREACION_CLIENTE.md` | 10 pasos del onboarding |
| Dashboard Spec | `docs/DASHBOARD_ADMIN_SPEC.md` | Layout y endpoints |
| Sesiones | `docs/SESIONES_CONCURRENTES.md` | Control de concurrencia |
| Versionamiento | `docs/VERSIONAMIENTO_TABLAS_MAESTRAS.md` | Estrategia de versionado |
| Roles y Permisos | `docs/ROLES_PERMISOS.md` | Matriz existente |
| Jerarquía | `docs/architecture/HIERARCHY-FLOWS.md` | Flujos y árbol |

---

## Decisiones Pendientes (para revisar jueves)

1. ¿Cómo se formaliza el glosario? (documento vivo, wiki, ambos)
2. ¿Qué incluye exactamente cada plan? (precios, features)
3. ¿El contrato es requisito obligatorio antes de activar?
4. ¿La creación de cliente será manual (formulario) o semiautomática (workflow)?
5. ¿Qué datos se migran de clientes antiguos? ¿Quién lo hace?
6. ¿Qué módulos ve el admin interno vs qué ve el admin del cliente?

---

_Última revisión: Reunión 29/05/2026_
