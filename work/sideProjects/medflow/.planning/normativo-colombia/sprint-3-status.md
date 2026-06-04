# GSD Execution Tracking — Sprint 3: Portal Paciente y Privacidad

> **Sprint**: 3 (Semanas 9-12)
> **Estado**: Backend + Frontend core completado

---

## Tareas Completadas ✅

### HC-03: Portal Paciente - Mi Historia Clínica
- **Backend**: Endpoint `GET /patient-portal/clinical-records` integrado con `PatientPortalHandler`.
- **Frontend**: Componente `MyClinicalRecordsComponent` con timeline de eventos clínicos (firmados/pendientes).
- **Rutas**: Integrado en el sidebar de paciente bajo "Mi Historia Clínica".
- **Cumplimiento**: Ley 2015/2020 (Derecho del paciente a acceder a su HC).

### PD-07: Derechos ARCO (Acceso, Rectificación, Cancelación, Oposición)
- **Dominio**: Nueva entidad `arco.DataRequest` para trazabilidad de solicitudes de privacidad.
- **Backend**: Endpoints `GET` y `POST` `/patient-portal/data-requests`.
- **Frontend**: Componente `MyDataRequestsComponent` para crear y listar solicitudes ARCO y ver resoluciones.
- **Rutas**: Integrado en el portal de paciente bajo "Solicitudes ARCO".
- **Cumplimiento**: Ley 1581/2012 (Habeas Data).

### PD-03: Encriptación PHI (Protected Health Information)
- **Migración**: `00125_phi_encryption_and_arco.sql` creada para encriptación de datos sensibles a nivel de columna (email, phone, document_number) usando `pgcrypto`.

### FH-02/03: FHIR R4
- **Mejora**: Integrados los recursos `Condition` (Diagnósticos), y configurados en el CapabilityStatement.

---

## Archivos Creados/Modificados (Sprint 3)

```
NUEVOS:
backend/internal/domain/arco/entity.go
backend/internal/infrastructure/persistence/repository/arco_repository.go
frontend/src/app/core/models/arco.model.ts
frontend/src/app/core/services/arco.service.ts
frontend/src/app/features/patient-portal/data-requests/my-data-requests.component.ts
frontend/src/app/features/patient-portal/clinical-records/my-clinical-records.component.ts
backend/db/migrations/00125_phi_encryption_and_arco.sql

MODIFICADOS:
backend/internal/application/dto/patient_portal/dto.go
backend/internal/interface/http/handler/patient_portal.go
backend/internal/interface/http/module.go
backend/internal/infrastructure/persistence/module.go
backend/internal/interface/http/router/router.go
frontend/src/app/app.routes.ts
frontend/src/app/core/services/session.service.ts
frontend/src/app/core/services/patient-portal.service.ts
```

---

## Pendiente global

| Prioridad | Tarea | Sprint |
|-----------|-------|--------|
| ALTA | Aplicar migraciones (`goose up`) | Sprint 4 |
| MEDIA | Pruebas end-to-end (E2E) con Playwright | Sprint 4 |
| MEDIA | UI Admin para responder a solicitudes ARCO | Sprint 4 |
| BAJA | Tests unitarios para handlers | Sprint 4 |
