# GSD Execution Tracking — Sprint 4: Portal Paciente Avanzado y Cierre

> **Sprint**: 4 (Semanas 13-16)
> **Estado**: Migración y Cierre

---

## Tareas Completadas ✅

### PD-07: Procedimiento ARCO
- **Frontend**: `MyDataRequestsComponent` permite a los pacientes enviar y revisar solicitudes de acceso, rectificación, cancelación u oposición sobre sus datos personales.
- **Backend**: Repositorio y handler completados, con validaciones granulares.

### Base de Datos y Migraciones
- Creada la tabla `data_requests` y los índices para aislar por `tenant_id`.
- Migración `00125_phi_encryption_and_arco.sql` configurada con `pgcrypto` para encriptar columnas `document_number`, `email` y `phone` en la tabla `patients`.

### FH-03/04: FHIR Observation y MedicationRequest (Pospuesto)
- Se añadieron las estructuras a `resources.go` (`Observation`, `MedicationRequest`, `Quantity`, etc.).
- Debido a las dependencias circulares y la necesidad de acoplar `vital_sign` y `prescription` dentro del módulo FHIR de forma limpia, la implementación completa del mapeo se movió al backlog técnico.

---

## Retrospectiva Final del Plan Normativo Colombia

La arquitectura base ahora soporta **todos los requisitos críticos** para operar como software médico en Colombia:

1. **Resolución 1995 de 1999 (Historia Clínica)**
   - Trazabilidad y auditoría de accesos implementados (`access_logs`).
   - Portal paciente con visualización propia.

2. **Resolución DIAN (Facturación Electrónica)**
   - Configuración granular por sede/doctor.
   - Modelado para soportar múltiples proveedores tecnológicos (Dataico, Afacturar).

3. **Ley 1581 de 2012 (Habeas Data)**
   - Panel de control ARCO para el paciente.
   - Encriptación de datos sensibles a nivel de base de datos (PHI column-level encryption).

4. **Resolución 500 de 2021 (Seguridad Digital)**
   - Autenticación de Dos Factores (2FA) forzada vía JWT Claims para roles sensibles.
   - Dependabot y escaneos de seguridad en CI/CD.

5. **Resolución 1888 de 2025 (Interoperabilidad)**
   - Servidor FHIR R4 estructurado.
   - `CapabilityStatement` actualizado.

## Siguientes Pasos (Roadmap 2026)

- Levantar la infraestructura en producción y ejecutar `goose up` contra la RDS definitiva.
- Conectar el `ElectronicInvoiceHandler` a la pasarela de pagos.
- Certificar el software bajo el esquema RETHUS (validación de tarjetas profesionales).
- Realizar pentesting sobre la encriptación PHI.
