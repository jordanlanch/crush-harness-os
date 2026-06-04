# Auditoría de Frontend — Plan GSD

> **Versión**: 1.0.0 | **Fecha**: 2026-05-29
> **Metodología**: GSD (Get Shit Done)

---

## Resumen Ejecutivo

El frontend de MedNext (Angular 19, zoneless, 44 feature modules, 82 services, 16 stores) está funcionalmente completo en amplitud pero presenta deficiencias significativas en:

1. **Dashboard administrativo**: No está orientado a clientes ni refleja el modelo comercial definido
2. **Control de sesiones**: No existe UI de gestión de sesiones concurrentes
3. **Flujo de onboarding**: No hay wizard ni checklist visual de activación
4. **Estados del cliente**: No se muestran ni se gestionan en la UI
5. **Versionamiento**: Sin UI para gestión de versiones de tablas maestras
6. **Cobertura de tests**: <15% en componentes, <8% en servicios
7. **Documentación de UI**: Fragmentada, sin guía de patrones

---

## FASE 1: Auditoría de UI/UX y Usabilidad

### 1.1 Dashboard Administrativo Actual

**Estado**: `features/admin/admin-dashboard/` existe pero es incorrecto según el nuevo modelo

**Problemas detectados**:
- Muestra "Total de pacientes" y "citas del día" — esto NO debe estar en el dashboard del superusuario
- Carece de métricas de clientes: totales, activos, en onboarding, suspendidos
- No muestra distribución por plan ni por número de sedes
- No tiene alertas de clientes que requieren atención
- No muestra consumo de instancias concurrentes

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-1.1.1 | Rediseñar `AdminDashboardComponent` con layout orientado a clientes según `docs/DASHBOARD_ADMIN_SPEC.md` | 🔴 ALTA |
| FE-1.1.2 | Crear `AdminDashboardService` con métodos para KPIs | 🔴 ALTA |
| FE-1.1.3 | Implementar cards: clientes totales, activos, onboarding, suspendidos | 🔴 ALTA |
| FE-1.1.4 | Implementar gráfico "Clientes por Plan" | 🟡 MEDIA |
| FE-1.1.5 | Implementar gráfico "Distribución por Sedes" | 🟡 MEDIA |
| FE-1.1.6 | Implementar lista "Clientes que Requieren Atención" con alertas | 🔴 ALTA |
| FE-1.1.7 | Implementar timeline "Actividad Reciente" | 🟡 MEDIA |
| FE-1.1.8 | Implementar barras "Consumo de Instancias (Top 5)" | 🔴 ALTA |
| FE-1.1.9 | Tests unitarios del dashboard (Vitest) | 🟡 MEDIA |

### 1.2 Lista de Clientes

**Estado**: `features/admin/clients-list/` existe con tabla básica + modal de creación

**Problemas detectados**:
- No muestra estado del cliente (badge de color: prospecto, activo, suspendido, etc.)
- Sin filtros avanzados (por estado, plan, fecha)
- Sin indicadores visuales de alertas (onboarding estancado, docs pendientes)
- La creación es un modal simple, no un flujo guiado

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-1.2.1 | Agregar columna de estado con badge de color (semáforo) | 🔴 ALTA |
| FE-1.2.2 | Agregar filtros: estado, plan, rango de fechas | 🟡 MEDIA |
| FE-1.2.3 | Agregar columna de sedes (cantidad) | 🟡 MEDIA |
| FE-1.2.4 | Indicador visual de alertas (ícono ⚠️ para clientes con problemas) | 🔴 ALTA |
| FE-1.2.5 | Ordenar columnas (nombre, estado, fecha creación) | 🟢 BAJA |
| FE-1.2.6 | Exportar listado a CSV | 🟢 BAJA |

### 1.3 Detalle de Cliente

**Estado**: `features/admin/clients-detail/` con 5 tabs: básicos, facilities, docs, usuarios, comercial

**Problemas detectados**:
- Falta tab de "Sesiones Activas" (gestión de concurrencia)
- Falta indicador de consumo de instancias por facility
- Tab "Config Comercial" no incluye `max_concurrent_sessions` ni `session_timeout`
- No se muestra la versión de tablas maestras asignada
- Sin historial de cambios de estado (audit trail del cliente)

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-1.3.1 | Agregar tab "Sesiones Activas" con tabla de sesiones por facility | 🔴 ALTA |
| FE-1.3.2 | Botón "Cerrar Sesión" para admin en cada sesión activa | 🔴 ALTA |
| FE-1.3.3 | Mostrar consumo de instancias (X/Y) en tab "Puntos de Atención" | 🔴 ALTA |
| FE-1.3.4 | Agregar selector de versión de tablas maestras en tab básico | 🟡 MEDIA |
| FE-1.3.5 | Mostrar historial de cambios de estado (timeline) | 🟢 BAJA |
| FE-1.3.6 | Extender formulario de datos básicos con campos de estado | 🔴 ALTA |

### 1.4 Flujo de Creación de Cliente (Onboarding Wizard)

**Estado**: No existe. Solo hay un modal simple en `clients-list`.

**Problemas detectados**:
- No hay un wizard paso a paso para el flujo de 10 pasos definido en `docs/FLUJO_CREACION_CLIENTE.md`
- No hay validación de documentos requeridos antes de activar
- Sin checklist visual de onboarding
- Sin notificaciones de progreso

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-1.4.1 | Crear `ClientOnboardingWizardComponent` (stepper de 4 etapas) | 🔴 ALTA |
| FE-1.4.2 | Paso 1: Datos Básicos (formulario completo con validación) | 🔴 ALTA |
| FE-1.4.3 | Paso 2: Configuración Comercial (plan, instancias, módulos) | 🔴 ALTA |
| FE-1.4.4 | Paso 3: Documentos (upload contrato, RUT, cámara de comercio) | 🟡 MEDIA |
| FE-1.4.5 | Paso 4: Revisión y Activación (checklist visual) | 🔴 ALTA |
| FE-1.4.6 | Validación de campos requeridos por tipo de cliente (IPS vs médico independiente) | 🟡 MEDIA |
| FE-1.4.7 | Tests E2E del flujo de onboarding (Playwright) | 🟡 MEDIA |

### 1.5 Gestión de Documentos del Cliente

**Estado**: Tab "Documentos" en detalle de cliente existe pero es básico

**Problemas detectados**:
- Sin validación de documentos obligatorios por tipo de cliente
- Sin estados de documento (pendiente, aprobado, rechazado)
- Sin thumbnail/preview de documentos
- No hay indicador visual de documentos faltantes

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-1.5.1 | Agregar estados de documento con badges | 🟡 MEDIA |
| FE-1.5.2 | Mostrar checklist de documentos requeridos vs cargados | 🟡 MEDIA |
| FE-1.5.3 | Preview inline de documentos (PDF, imágenes) | 🟢 BAJA |

---

## FASE 2: Auditoría de Servicios y Estado

### 2.1 Servicios Faltantes

| Servicio | Archivo | Estado |
|----------|---------|--------|
| `AdminDashboardService` | `core/services/admin-dashboard.service.ts` | ❌ No existe |
| `ClientStatusService` | `core/services/client-status.service.ts` | ❌ No existe |
| `SessionManagementService` | `core/services/session-management.service.ts` | ❌ No existe |
| `MasterDataVersionService` | `core/services/master-data-version.service.ts` | ❌ No existe |

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-2.1.1 | Implementar `AdminDashboardService` con endpoints de KPIs | 🔴 ALTA |
| FE-2.1.2 | Implementar `ClientStatusService` para transiciones de estado | 🔴 ALTA |
| FE-2.1.3 | Implementar `SessionManagementService` para gestión de sesiones | 🔴 ALTA |
| FE-2.1.4 | Implementar `MasterDataVersionService` | 🟡 MEDIA |

### 2.2 Stores Faltantes

| Store | Ubicación | Estado |
|-------|-----------|--------|
| `ClientStore` | `features/admin/store/client.store.ts` | ❌ No existe |
| `DashboardStore` | `features/admin/store/dashboard.store.ts` | ❌ No existe |

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-2.2.1 | Crear `ClientStore` (Signal Store) con estado de cliente, lista, filtros | 🔴 ALTA |
| FE-2.2.2 | Crear `DashboardStore` para datos del dashboard administrativo | 🔴 ALTA |

---

## FASE 3: Auditoría de UI/UX — Problemas Generales

### 3.1 Navegación y Sidebar

**Problemas detectados**:
- Roles no diferencian correctamente entre "admin MedNext" y "admin del cliente" — ven el mismo sidebar
- El módulo "admin" aparece para el admin del cliente pero sin diferenciación clara
- Links a "Migraciones" y "Feature Flags" visibles para roles que no deberían verlos

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-3.1.1 | Diferenciar sidebar entre Platform Admin (MedNext) y Client Admin (cliente) | 🔴 ALTA |
| FE-3.1.2 | Revisar visibilidad de módulos según matriz ROLES_PERMISOS.md | 🟡 MEDIA |
| FE-3.1.3 | Ocultar módulos de platform admin (migraciones, feature flags) a client admins | 🔴 ALTA |

### 3.2 Responsive y Accesibilidad

**Problemas detectados**:
- Sin tests de accesibilidad (WCAG, screen readers)
- `data-testid` no verificado en todos los componentes interactivos
- Sin pruebas de responsive en tablets/móviles (el dashboard admin debe funcionar en tablet)

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-3.2.1 | Auditoría de `data-testid` en componentes nuevos | 🟡 MEDIA |
| FE-3.2.2 | Verificar responsive del dashboard admin en viewport tablet | 🟢 BAJA |
| FE-3.2.3 | Agregar roles ARIA en componentes de admin | 🟢 BAJA |

### 3.3 Consistencia Visual

**Problemas detectados**:
- Uso de Tarjetas (`.card`) inconsistente — algunos componentes usan Tailwind directo, otros clases custom
- Badges de estado sin paleta de colores unificada (éxito, warning, error, info)
- Sin componente shared de "StatusBadge"

**Tareas**:

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-3.3.1 | Crear componente shared `StatusBadgeComponent` con paleta unificada | 🟡 MEDIA |
| FE-3.3.2 | Estandarizar uso de clases `.card`, `.card-header`, `.card-body` | 🟢 BAJA |
| FE-3.3.3 | Documentar paleta de colores de estado en guía de UI | 🟢 BAJA |

---

## FASE 4: Testing y Cobertura

### 4.1 Cobertura Actual

| Capa | Cobertura | Target |
|------|-----------|--------|
| Componentes | ~15% | 75% |
| Servicios | ~8% | 85% |
| Stores | ~5% | 80% |
| E2E | 100% | 100% |

### 4.2 Tareas de Testing

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-4.2.1 | Tests unitarios de `AdminDashboardComponent` | 🟡 MEDIA |
| FE-4.2.2 | Tests unitarios de `ClientsListComponent` extendido | 🟡 MEDIA |
| FE-4.2.3 | Tests unitarios de `ClientsDetailComponent` extendido | 🟡 MEDIA |
| FE-4.2.4 | Tests unitarios de `ClientOnboardingWizardComponent` | 🟡 MEDIA |
| FE-4.2.5 | Tests de servicios nuevos (Dashboard, Status, Session, Version) | 🟡 MEDIA |
| FE-4.2.6 | Tests de stores nuevos (ClientStore, DashboardStore) | 🟡 MEDIA |
| FE-4.2.7 | Tests E2E de flujo completo de creación de cliente | 🟡 MEDIA |
| FE-4.2.8 | Tests E2E de control de sesiones concurrentes | 🟢 BAJA |

---

## FASE 5: Documentación de UI

### 5.1 Tareas

| ID | Tarea | Prioridad |
|----|-------|-----------|
| FE-5.1.1 | Crear guía de patrones UI para módulo admin | 🟢 BAJA |
| FE-5.1.2 | Documentar flujo de navegación admin con diagramas | 🟢 BAJA |
| FE-5.1.3 | Documentar componentes shared disponibles | 🟢 BAJA |

---

## Resumen de Prioridades Frontend

### 🔴 Sprint 1 (Semana 1-2): Dashboard + Clientes Core
- FE-1.1.1 a FE-1.1.3: Dashboard admin rediseñado con KPIs
- FE-1.1.6: Alertas de clientes que requieren atención
- FE-1.1.8: Consumo de instancias
- FE-1.2.1: Badges de estado en lista de clientes
- FE-1.2.4: Indicadores de alerta
- FE-1.3.1 a FE-1.3.3: Sesiones activas y consumo en detalle
- FE-1.3.6: Campos de estado en formulario
- FE-2.1.1 a FE-2.1.3: Servicios nuevos
- FE-2.2.1: ClientStore
- FE-3.1.1: Diferenciar sidebar admin
- FE-3.1.3: Ocultar módulos platform-only

### 🟡 Sprint 2 (Semana 3-4): Onboarding + Dashboard Completo
- FE-1.4.1 a FE-1.4.5: Wizard de onboarding
- FE-1.1.4, FE-1.1.5, FE-1.1.7: Gráficos del dashboard
- FE-1.5.1 a FE-1.5.2: Documentos + checklist
- FE-2.2.2: DashboardStore
- Tests y documentación

### 🟢 Sprint 3 (Semana 5-6): Pulido + Accesibilidad + E2E
- FE-4.2.*: Tests
- FE-3.2.*: Accesibilidad
- FE-3.3.*: Consistencia visual
- FE-5.*: Documentación

---

_Última revisión: 2026-05-29 — Auditoría completa de frontend_
