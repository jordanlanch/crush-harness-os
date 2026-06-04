# MedNext — Roadmap Consolidado GSD

> **Versión**: 2.0.0 | **Fecha**: 2026-05-29
> **Basado en**: Reunión 29/05/2026 + Auditoría completa Frontend/Backend/Infra
> **Metodología**: GSD (Get Shit Done)

---

## Mapa General de Ejecución

```
 SEMANA 1-2          SEMANA 3-4           SEMANA 5-6          SEMANA 7-8
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ SPRINT 1 🔴  │  │ SPRINT 2 🟡  │  │ SPRINT 3 🟢  │  │ SPRINT 4 🔵  │
│ FUNDACIÓN    │  │ EXPANSIÓN    │  │ PULIDO       │  │ TESTS + DOC  │
│              │  │              │  │              │  │              │
│ • Estados    │  │ • Dashboard  │  │ • Versionam. │  │ • Tests      │
│ • Sesiones   │  │   completo   │  │ • CI/CD      │  │ • Docs      │
│ • Dashboard  │  │ • Onboarding │  │ • Seguridad  │  │ • Monitoreo │
│   admin core │  │ • Documentos │  │ • Performance│  │ • Limpieza  │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

---

## SPRINT 1 🔴: Fundación (Semanas 1-2)

**Objetivo**: Implementar los pilares del nuevo modelo de negocio: estados del cliente, sesiones concurrentes, y dashboard administrativo core.

### Backend (14 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| BK-1.1.1 | Agregar `ClientStatus` enum al domain entity | Domain |
| BK-1.1.2 | Migración: columna `status` en `tenants` | DB |
| BK-1.1.3 | `UpdateStatus` en repository | Repository |
| BK-1.1.4 | Lógica de transiciones válidas en usecase | UseCase |
| BK-1.1.5 | Endpoint `PUT /admin/clients/:id/status` | Handler |
| BK-1.2.1 | Migración: `max_concurrent_sessions`, `session_timeout_minutes` en `facilities` | DB |
| BK-1.2.2 | `SessionManager` en Redis | Infra |
| BK-1.2.3 | Modificar `AuthUseCase.Login()` con concurrencia | UseCase |
| BK-1.2.4 | Modificar `AuthUseCase.Logout()` para limpiar sesión | UseCase |
| BK-1.2.5 | `SessionMiddleware` | Middleware |
| BK-1.2.7 | `GET /admin/facilities/:id/sessions` | Handler |
| BK-1.2.8 | `DELETE /admin/facilities/:id/sessions/:sessionId` | Handler |
| BK-1.2.9 | `GET /admin/clients/:id/instance-usage` | Handler |
| BK-2.1.1 a BK-2.1.4 | DTOs + UseCase + Handler + Routes para Dashboard Admin | Domain/UseCase/Handler |

### Frontend (12 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| FE-1.1.1 | Rediseñar `AdminDashboardComponent` | Component |
| FE-1.1.2 | `AdminDashboardService` | Service |
| FE-1.1.3 | Cards KPIs (clientes totales, activos, onboarding, suspendidos) | Component |
| FE-1.1.6 | Lista "Clientes que Requieren Atención" | Component |
| FE-1.1.8 | Barras "Consumo de Instancias (Top 5)" | Component |
| FE-1.2.1 | Badges de estado en lista de clientes | Component |
| FE-1.2.4 | Indicadores de alerta en lista | Component |
| FE-1.3.1 | Tab "Sesiones Activas" en detalle de cliente | Component |
| FE-1.3.2 | Botón "Cerrar Sesión" por sesión | Component |
| FE-1.3.3 | Consumo de instancias en tab "Puntos de Atención" | Component |
| FE-1.3.6 | Campos de estado en formulario | Component |
| FE-2.1.1 a FE-2.1.3 | Servicios: Dashboard, Status, Session | Service |
| FE-2.2.1 | `ClientStore` (Signal Store) | Store |
| FE-3.1.1 | Diferenciar sidebar Platform Admin vs Client Admin | Layout |
| FE-3.1.3 | Ocultar módulos platform-only a client admins | Layout |

### Infraestructura (7 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| INF-1.2.1 | Redis para `SessionManager` (keys, TTLs, contadores) | Redis |
| INF-1.2.2 | Redis para token blacklist | Redis |
| INF-1.2.4 | Probar failover de Redis | Infra |
| INF-2.1.1 | Consolidar `db/migrations/` vs `migrations/` | DB |
| INF-2.3.1 a INF-2.3.4 | sqlc queries para dashboard + estados + instancias | DB |
| INF-3.2.3 | Redis en `docker-compose.test.yml` | Docker |
| INF-5.2.4 | Health check Redis en `/health/ready` | Monitoreo |
| INF-6.2.1 | 2FA obligatorio para Platform Admin | Seguridad |
| INF-6.2.4 | Auditoría de acciones del Platform Admin | Seguridad |

**Total Sprint 1**: 40 tareas (14 BK + 15 FE + 9 INF)

---

## SPRINT 2 🟡: Expansión (Semanas 3-4)

**Objetivo**: Completar dashboard, implementar wizard de onboarding, workflow de documentos, configuración comercial extendida y refinar el **Módulo de Agendamiento**.

### Backend (14 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| BK-1.2.6 | Background job de limpieza de sesiones inactivas | Infra |
| BK-1.3.1 a BK-1.3.7 | Versionamiento de tablas maestras (7 tareas) | Domain/Repo/UseCase/Handler |
| BK-2.2.1 | Extender DTO `UpsertCommercialConfigRequest` | DTO |
| BK-2.2.2 | Actualizar `custom_config` JSONB | Repository |
| BK-2.3.1 a BK-2.3.3 | Workflow de documentos (aprobar/rechazar) | Handler |
| BK-3.3.1 a BK-3.3.3 | Rate limiting + token blacklist | Middleware |
| BK-5.1.1 a BK-5.1.4 | Refactor Módulo Agendamiento (Nuevos Estados: Reservado, Bloqueado, Fallido) | Domain/Repo/UseCase/Handler |

### Frontend (16 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| FE-1.1.4 | Gráfico "Clientes por Plan" | Component |
| FE-1.1.5 | Gráfico "Distribución por Sedes" | Component |
| FE-1.1.7 | Timeline "Actividad Reciente" | Component |
| FE-1.4.1 a FE-1.4.5 | `ClientOnboardingWizardComponent` (5 tareas) | Component |
| FE-1.5.1 | Estados de documento con badges | Component |
| FE-1.5.2 | Checklist de documentos requeridos vs cargados | Component |
| FE-2.2.2 | `DashboardStore` | Store |
| FE-3.2.1 | Auditoría de `data-testid` en nuevos componentes | Testing |
| FE-3.3.1 | Componente shared `StatusBadgeComponent` | Shared |
| FE-5.1.1 a FE-5.1.4 | Refactor Módulo Agendamiento UI (Flujos: Reservar, Bloquear, Reprogramar, Recepcionar) | Component/Store |

### Infraestructura (8 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| INF-2.2.1 a INF-2.2.3 | Seeds actualizados (clientes, facilities, master versions) | DB |
| INF-4.2.1 a INF-4.2.3 | CI mejorado (frontend tests, E2E, security scan) | CI/CD |
| INF-5.2.1 a INF-5.2.3 | Métricas de negocio + Grafana dashboards + alertas | Monitoreo |
| INF-6.2.2 | Security scanning en CI (`govulncheck`, `npm audit`) | Seguridad |

**Total Sprint 2**: 30 tareas (10 BK + 12 FE + 8 INF)

---

## SPRINT 3 🟢: Pulido (Semanas 5-6)

**Objetivo**: Completar versionamiento, seguridad, performance, y limpieza de código.

### Backend (8 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| BK-1.1.6 ✅ | Filtro `?status=` en `GET /admin/clients` | Handler |
| BK-1.3.8 ✅ | Tests de versionamiento | Testing |
| BK-2.2.3 | Sincronizar `custom_config` con `facilities.max_concurrent_sessions` | UseCase |
| BK-2.3.4 | Validación: no activar cliente sin docs obligatorios | UseCase |
| BK-3.1.1 a BK-3.1.3 | Auditoría RBAC tenant scoping + tests | Security |
| BK-3.2.1 a BK-3.2.3 | PHI isolation middleware + tests | Security |

### Frontend (6 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| FE-1.2.2 ✅ | Filtros avanzados en lista de clientes | Component |
| FE-1.2.3 | Columna de sedes (cantidad) | Component |
| FE-1.3.4 ✅ | Selector de versión de tablas maestras | Component |
| FE-1.4.6 | Validación por tipo de cliente (IPS vs médico independiente) | Component |
| FE-1.5.3 | Preview inline de documentos | Component |
| FE-3.2.2 a FE-3.2.3 | Responsive + ARIA en admin | Accessibility |

### Infraestructura (8 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| INF-3.2.2 | Backup Redis en producción (AOF/RDB) | Infra |
| INF-4.2.4 | Aprobación manual antes de deploy a prod | CI/CD |
| INF-6.2.3 | Endurecer CSP policy | Seguridad |
| INF-6.2.6 | `.env` en `.gitignore` | Seguridad |
| INF-7.2.1 a INF-7.2.3 | Caché Redis + índices + paginación | Performance |
| INF-8.1.1 | Mover scripts sueltos con `func main()` a `scripts/` | Limpieza |

**Total Sprint 3**: 22 tareas (8 BK + 6 FE + 8 INF)

---

## SPRINT 4 🔵: Tests + Documentación (Semanas 7-8)

**Objetivo**: Cobertura de tests, documentación, y pulido final.

### Testing (16 tareas)

| ID | Tarea | Capa |
|----|-------|------|
| BK-4.2.1 | Tests de `ClientUseCase` (CRUD + estados + transiciones) | Backend Test |
| BK-4.2.2 | Tests de `SessionManager` | Backend Test |
| BK-4.2.3 | Tests de `AdminDashboardUseCase` | Backend Test |
| BK-4.2.4 | Tests de `AuthUseCase` con concurrencia | Backend Test |
| BK-4.2.6 | Tests de integración: flujo creación cliente → activación | Backend Test |
| BK-4.2.7 | Tests de seguridad: RBAC tenant scoping | Backend Test |
| BK-4.2.8 | Tests de seguridad: PHI isolation | Backend Test |
| FE-1.1.9 | Tests de `AdminDashboardComponent` | Frontend Test |
| FE-4.2.1 a FE-4.2.6 | Tests de componentes + servicios + stores nuevos | Frontend Test |
| FE-1.4.7 | Tests E2E del flujo de onboarding (Playwright) | E2E |

### Documentación (6 tareas)

| ID | Tarea | 
|----|-------|
| DOC-1 | Documentar flujo de navegación admin con diagramas |
| DOC-2 | Documentar componentes shared disponibles |
| DOC-3 | Documentar paleta de colores de estado (guía UI) |
| DOC-4 | Documentar arquitectura Redis (keyspace, TTLs, backups) |
| DOC-5 | Documentar arquitectura de observabilidad |
| DOC-6 | Actualizar `docs/ROLES_PERMISOS.md` con tenant scoping |

### Monitoreo + Limpieza (5 tareas)

| ID | Tarea |
|----|-------|
| INF-4.2.5 | Notificación de deploy (Slack/Discord) |
| INF-5.2.5 | Documentar arquitectura de observabilidad |
| INF-6.2.5 | Limpiar credenciales hardcodeadas de `.env.medflow` |
| INF-8.1.2 a INF-8.1.5 | Mover hotfixes, eliminar `database.sqlite`, fixtures, `.gitignore` |

**Total Sprint 4**: 27 tareas (16 testing + 6 docs + 5 limpieza)

---

## Resumen de Tareas por Capa

| Capa | Sprint 1 | Sprint 2 | Sprint 3 | Sprint 4 | Total |
|------|----------|----------|----------|----------|-------|
| **Backend** | 14 | 10 | 8 | 7 | 39 |
| **Frontend** | 15 | 12 | 6 | 7 | 40 |
| **Infraestructura** | 9 | 8 | 8 | 5 | 30 |
| **Testing** | 0 | 0 | 0 | 16 | 16 |
| **Documentación** | 0 | 0 | 0 | 6 | 6 |
| **TOTAL** | **40** | **30** | **22** | **27** | **119** |

---

## Diagrama de Dependencias entre Sprints

```
Sprint 1 (Fundación)
  │
  ├──▶ Estados del cliente ──▶ Dashboards ──▶ Onboarding Wizard
  │
  ├──▶ Sesiones concurrentes ──▶ Session UI ──▶ Tests concurrencia
  │
  ├──▶ Dashboard admin core ──▶ Dashboard completo ──▶ Tests dashboard
  │
  └──▶ Redis + sqlc + Health ──▶ CI/CD + Monitoreo ──▶ Pulido + Docs
```

---

## Historias de Usuario (US) Transversales

### US-1: Como Platform Admin, quiero ver el estado de todos los clientes
**Sprints**: 1, 2 | **Tareas**: BK-1.1.*, BK-2.1.*, FE-1.1.*, FE-1.2.*

### US-2: Como Platform Admin, quiero crear un cliente nuevo con wizard guiado
**Sprints**: 1, 2 | **Tareas**: BK-1.1.*, BK-2.3.*, FE-1.4.*

### US-3: Como Platform Admin, quiero gestionar sesiones concurrentes
**Sprints**: 1, 2 | **Tareas**: BK-1.2.*, FE-1.3.*

### US-4: Como Platform Admin, quiero gestionar versiones de tablas maestras
**Sprints**: 2, 3 | **Tareas**: BK-1.3.*

### US-5: Como Client Admin, quiero ver solo mi información
**Sprints**: 1, 3 | **Tareas**: BK-3.1.*, BK-3.2.*, FE-3.1.*

### US-6: Como paciente/cliente, quiero que mis datos estén protegidos del Platform Admin
**Sprints**: 3 | **Tareas**: BK-3.2.*

---

## Definición de Done por Tarea

- [ ] Código implementado siguiendo patrones Clean Architecture
- [ ] Migraciones con rollback script
- [ ] Tests unitarios (según capa: 75-85% coverage)
- [ ] `data-testid` en todos los elementos interactivos (frontend)
- [ ] Sin errores de linter (`golangci-lint`, `ESLint`)
- [ ] Documentación actualizada si aplica

---

## Documentos de Referencia

| Documento | Ruta | Sprint |
|-----------|------|--------|
| Glosario de Términos | `docs/GLOSARIO.md` | 0 |
| Modelo Comercial | `docs/MODELO_COMERCIAL.md` | 0 |
| Flujo de Creación de Cliente | `docs/FLUJO_CREACION_CLIENTE.md` | 1-2 |
| Dashboard Admin Spec | `docs/DASHBOARD_ADMIN_SPEC.md` | 1-2 |
| Sesiones Concurrentes | `docs/SESIONES_CONCURRENTES.md` | 1 |
| Versionamiento Tablas Maestras | `docs/VERSIONAMIENTO_TABLAS_MAESTRAS.md` | 2-3 |
| Roles y Permisos | `docs/ROLES_PERMISOS.md` | 3-4 |
| Auditoría Frontend | `.planning/audit-frontend-plan.md` | 1-4 |
| Auditoría Backend | `.planning/audit-backend-plan.md` | 1-4 |
| Auditoría Infraestructura | `.planning/audit-infra-plan.md` | 1-4 |

---

## Próximo Paso Inmediato

Ejecutar **Sprint 1 — Semana 1**:

1. Crear migración `00119_add_client_status.sql`
2. Crear migración `00120_add_concurrent_sessions.sql`
3. Implementar `SessionManager` en Redis
4. Implementar `AdminDashboardHandler` con endpoints de KPIs
5. Rediseñar `AdminDashboardComponent`

---

_Última revisión: 2026-05-29 — Auditoría + Roadmap Consolidado GSD_
