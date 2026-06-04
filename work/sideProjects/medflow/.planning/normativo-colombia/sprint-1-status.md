# GSD Execution Tracking — Sprint 1: Cimentación Regulatoria

> **Plan**: docs/PLAN_NORMATIVO_COLOMBIA.md
> **Sprint**: 1-2 (Semanas 1-4)
> **Estado**: En ejecución

---

## Tareas Completadas

### BUG-01: Unificar nombres de roles ✅
- **Archivos**: `db/init/02_users.sql`, `db/seeds/users.sql`
- **Cambio**: `pharmacy` → `pharmacist`, `lab` → `lab_tech` en seeds BD
- **Nota**: Backend ya tenía aliases legacy; frontend ya normaliza

### HC-01: Registro de accesos a HC ✅
- **Nuevo dominio**: `internal/domain/access_log/entity.go`
- **Nueva migración**: `db/migrations/00123_create_access_logs.sql`
- **Nuevo repositorio**: `internal/infrastructure/persistence/repository/access_log_repository.go`
- **Nuevo middleware**: `internal/interface/http/middleware/access_log.go` (LogAccess)
- **Queries sqlc**: `db/queries/access_logs.sql`

### FE-08/12: Configuración FE ✅
- **Nuevo dominio**: `internal/domain/electronic_invoice_config/entity.go`
- **Nueva migración**: `db/migrations/00124_create_electronic_invoice_tables.sql`
- **Nuevo repositorio**: `internal/infrastructure/persistence/repository/electronic_invoice_config_repository.go`
- **Nuevo DTO**: `internal/application/dto/electronic_invoice_config_dto.go`
- **Nuevo handler**: `internal/interface/http/handler/electronic_invoice_config.go`
- **Queries sqlc**: `db/queries/electronic_invoice.sql`

## Tareas Pendientes

### SEG-01: 2FA obligatorio
- Requiere: middleware Require2FA o modificar auth.go para forzar TOTP en roles admin/doctor

### RP-01/02: Catálogos CUPS/CIE-10 2024
- Requiere: actualizar seeds o migration con nuevos códigos oficiales

### PD-01/02/06: Protección de datos
- PD-01: Política de privacidad completa (HTML page en legal/)
- PD-02: Banner de cookies con consentimiento granular
- PD-06: ROPA (registro de actividades de tratamiento)

### SEG-09/10: Seguridad
- SEG-09: Configurar Dependabot/GitHub security scanning
- SEG-10: Verificar TLS 1.3 en Traefik

### Wiring pendiente
- Registrar AccessLogRepository y ElectronicInvoiceConfigRepository en Fx DI (`module.go`)
- Registrar ElectronicInvoiceConfigHandler
- Agregar rutas en `router.go`:
  ```
  GET  /api/v1/admin/electronic-invoicing/config
  PUT  /api/v1/admin/electronic-invoicing/config
  ```
- Aplicar `mw.LogAccess()` en rutas de historia clínica

---

## Archivos Creados (10)

```
db/migrations/00122_normalize_role_names.sql
db/migrations/00123_create_access_logs.sql
db/migrations/00124_create_electronic_invoice_tables.sql
db/queries/access_logs.sql
db/queries/electronic_invoice.sql
internal/domain/access_log/entity.go
internal/domain/electronic_invoice_config/entity.go
internal/infrastructure/persistence/repository/access_log_repository.go
internal/infrastructure/persistence/repository/electronic_invoice_config_repository.go
internal/application/dto/electronic_invoice_config_dto.go
internal/interface/http/handler/electronic_invoice_config.go
internal/interface/http/middleware/access_log.go
```

## Archivos Modificados (3)

```
db/init/02_users.sql                — pharmacy→pharmacist, lab→lab_tech
db/seeds/users.sql                   — pharmacy→pharmacist, lab→lab_tech
internal/interface/http/middleware/middleware.go — campo accessLogRepo + setter
```

---

## Bloqueantes

1. **sqlc generate** falla por `patients.sql:70` — columna `tenant_id` removida en migración 00115 pero query no actualizada. Pre-existente, no introducido por estos cambios.
2. **Wiring Fx** — los nuevos repositorios/handlers no están registrados en el contenedor DI todavía.
