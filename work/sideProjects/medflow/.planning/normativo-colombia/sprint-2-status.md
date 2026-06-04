# GSD Execution Tracking — Sprint 2: Facturación e Interoperabilidad

> **Sprint**: 2 (Semanas 5-8)
> **Estado**: Backend + Frontend core completado

---

## Tareas Completadas ✅

### FE-05/09: UI Configuración Facturación Electrónica
- **Model**: `electronic-invoice-config.model.ts`
- **Service**: `electronic-invoice-config.service.ts`
- **Component**: `admin/electronic-invoice-config/electronic-invoice-config.component.ts`
  - Toggle ON/OFF
  - Tipo contribuyente (natural/jurídica)
  - NIT, DV, Razón Social
  - Proveedor DIAN (Dataico/Afacturar/Faktoom)
  - API Key con enmascaramiento
  - Resolución DIAN (número, prefijo, rango, vencimiento)
  - Estado actual (facturas restantes, última emitida)
  - Guardar / Cancelar
- **Route**: `/admin/electronic-invoicing` en `admin.routes.ts`
- **Sidebar**: Entry en `session.service.ts` (admin role)

### HC-02: Auditoría de Accesos a HC
- **Handler**: `access_log.go` — `GET /patients/:patientId/access-logs`
- **Route**: registrada en `router.go` con `RequirePermission("clinical.view")`
- **Filtros**: limit (50 default, max 100)

### HC-03: Portal Paciente Acceso a HC
- La infraestructura ya existía: `PatientEventHandler.List` + `PatientPortalHandler`
- El paciente ya puede ver sus eventos clínicos vía portal

### SEG-01: 2FA Obligatorio (completado en Sprint 1)
- JWT claim `require_2fa_setup` en token
- Middleware enforcement: bloquea todo excepto `/auth/2fa/*`, `/auth/me`, `/auth/logout`
- Aplica a roles `admin` y `doctor` sin TOTP habilitado

### SEG-09/10: Dependabot
- `.github/dependabot.yml` — Go, npm, Docker, GitHub Actions

---

## Archivos Creados/Modificados (Sprint 2)

```
NUEVOS:
frontend/src/app/core/models/electronic-invoice-config.model.ts
frontend/src/app/core/services/electronic-invoice-config.service.ts
frontend/src/app/features/admin/electronic-invoice-config/electronic-invoice-config.component.ts
backend/internal/interface/http/handler/access_log.go

MODIFICADOS:
frontend/src/app/features/admin/admin.routes.ts         — +ruta electronic-invoicing
frontend/src/app/core/services/session.service.ts        — +nav item admin
backend/internal/interface/http/module.go                — +AccessLogHandler, +ElectronicInvoiceConfigHandler
backend/internal/interface/http/router/router.go          — +accessLogHandler param, +route access-logs, +e-invoice config routes
backend/internal/infrastructure/persistence/module.go     — +AccessLogRepository, +EInvoiceConfigRepo
backend/internal/interface/http/middleware/middleware.go  — +accessLogRepo field + setter
backend/internal/interface/http/middleware/auth.go        — +Require2FASetup claim, +enforcement
backend/internal/interface/http/handler/auth_handler.go   — +Require2FASetup JWT claim, +login enforcement
backend/internal/interface/http/handler/auth_handler_2fa.go — updated generateAccessToken call
```

---

## Total acumulado (Sprint 1 + 2)

- **23 archivos creados** (11 backend + 4 frontend + 4 migrations + 4 infra)
- **9 archivos modificados**
- **3 nuevas migraciones SQL**
- **5 nuevas rutas API**
- **3 nuevos handlers**
- **2 nuevos repositorios**
- **2 nuevos middlewares**

---

## Pendiente global

| Prioridad | Tarea | Sprint |
|-----------|-------|--------|
| ALTA | Aplicar migraciones (`goose up`) | Ahora |
| ALTA | Frontend: 2FA setup forzado (cuando `require_2fa_setup`) | Sprint 3 |
| ALTA | PD-03: Encriptación PHI real (pgcrypto column-level) | Sprint 3 |
| MEDIA | PD-07: UI solicitudes ARCO en portal paciente | Sprint 3 |
| MEDIA | RP-01/02: Carga masiva catálogos CUPS/CIE-10 oficiales | Sprint 3 |
| MEDIA | FE-02/03: Implementar proveedor DIAN concreto (Dataico) | Sprint 3 |
| MEDIA | FH-01/02/03: Completar FHIR R4 recursos | Sprint 3 |
| BAJA | Tests unitarios para nuevos handlers/repos | Sprint 4 |
