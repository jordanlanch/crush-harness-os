# MedNext - Jerarquía de Roles, Permisos y Módulos (RBAC)

```
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                           MEDNEXT RBAC HIERARCHY                                               ║
║                                  Roles · Permisos · Módulos · API Endpoints                                     ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   ROLES                                                         │
│                                 (7 roles · 7 niveles de jerarquía)                                              │
│                                                                                                                 │
│    ┌──────────┐                                                                                                 │
│    │  ADMIN   │ ◄─── Superusuario (todos los permisos + admin.* + staff.manage)                                 │
│    │  ⭐⭐⭐⭐⭐  │                                                                                                 │
│    └────┬─────┘                                                                                                 │
│         │                                                                                                       │
│    ┌────┴─────┐                                                                                                 │
│    │  DOCTOR  │ ◄─── Médico (datos clínicos completos, firma, reportes, gestión personal)                       │
│    │  ⭐⭐⭐⭐   │                                                                                                 │
│    └────┬─────┘                                                                                                 │
│         │                                                                                                       │
│    ┌────┴──────┐            ┌─────────────┐          ┌──────────────┐                                           │
│    │   NURSE   │            │RECEPTIONIST │          │   BILLING    │                                           │
│    │   ⭐⭐⭐    │            │    ⭐⭐½    │          │    ⭐⭐½     │                                           │
│    └────┬──────┘            └──────┬──────┘          └──────┬───────┘                                           │
│         │                         │                         │                                                   │
│    ┌────┴──────┐            ┌──────┴──────┐          ┌──────┴───────┐                                           │
│    │ PHARMACY  │            │     LAB     │          │  (end)       │                                           │
│    │   ⭐⭐     │            │     ⭐      │          │              │                                           │
│    └───────────┘            └─────────────┘          └──────────────┘                                           │
│                                                                                                                 │
│    ⭐ = Nivel de acceso (aprox.)                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                        MÓDULOS DEL SISTEMA                                                       │
│                                            (16 módulos)                                                           │
│                                                                                                                 │
│    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐     │
│    │                                      CORE MÉDICO                                                     │     │
│    │  ┌──────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────┐                            │     │
│    │  │ PATIENTS │  │ CLINICAL RECORDS │  │  APPOINTMENTS    │  │ STUDIES  │                            │     │
│    │  └──────────┘  └──────────────────┘  └──────────────────┘  └──────────┘                            │     │
│    │       │                 │                     │                   │                                  │     │
│    │       ▼                 ▼                     ▼                   ▼                                  │     │
│    │  ┌──────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐                   │     │
│    │  │ view     │  │ view             │  │ view             │  │ view             │                   │     │
│    │  │ create   │  │ create           │  │ create           │  │ create           │                   │     │
│    │  │ edit     │  │ edit             │  │ edit             │  │ edit             │                   │     │
│    │  │ delete   │  │ sign             │  │ cancel           │  │ sign             │                   │     │
│    │  └──────────┘  └──────────────────┘  └──────────────────┘  └──────────────────┘                   │     │
│    └──────────────────────────────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                                                 │
│    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐     │
│    │                                    FINANCIERO                                                        │     │
│    │  ┌──────────┐  ┌──────────┐  ┌────────────────────────┐  ┌──────────────┐                           │     │
│    │  │ BILLING  │  │INVENTORY │  │ ELECTRONIC INVOICING   │  │  CASH BOXES  │                           │     │
│    │  └──────────┘  └──────────┘  │ (DIAN e-Factura)       │  └──────────────┘                           │     │
│    │       │              │       └────────────────────────┘                                              │     │
│    │       ▼              ▼                                                                                │     │
│    │  ┌──────────┐  ┌──────────┐                                                                          │     │
│    │  │ view     │  │ view     │                                                                          │     │
│    │  │ create   │  │ entries  │                                                                          │     │
│    │  │ edit     │  │ exits    │                                                                          │     │
│    │  │ payments │  │ adjust   │                                                                          │     │
│    │  │ invoice  │  └──────────┘                                                                          │     │
│    │  └──────────┘                                                                                         │     │
│    └──────────────────────────────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                                                 │
│    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐     │
│    │                                  REGULATORIO COLOMBIANO                                               │     │
│    │  ┌──────────┐  ┌──────────┐  ┌────────────────────────┐  ┌────────────────────────┐                 │     │
│    │  │   RIPS   │  │   FHIR   │  │   APEDT (Res. 4505)    │  │   INSURANCE PLANS      │                 │     │
│    │  └──────────┘  │   R4     │  └────────────────────────┘  └────────────────────────┘                 │     │
│    │                └──────────┘                                                                           │     │
│    └──────────────────────────────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                                                 │
│    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐     │
│    │                                     PLATAFORMA                                                        │     │
│    │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐       │     │
│    │  │  ADMIN   │  │ REPORTS  │  │ PATIENT PORTAL   │  │ PUBLIC PROVIDER  │  │       AI         │       │     │
│    │  └──────────┘  └──────────┘  └──────────────────┘  └──────────────────┘  └──────────────────┘       │     │
│    │       │              │                                                                                 │     │
│    │       ▼              ▼                                                                                 │     │
│    │  ┌──────────┐  ┌──────────┐                                                                           │     │
│    │  │ users    │  │ view     │                                                                           │     │
│    │  │ settings │  │ generate │                                                                           │     │
│    │  │ audit    │  │ export   │                                                                           │     │
│    │  │ facilities│ └──────────┘                                                                           │     │
│    │  └──────────┘                                                                                          │     │
│    └──────────────────────────────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                                                 │
│    ┌──────────────────────────────────────────────────────────────────────────────────────────────────────┐     │
│    │                               MÓDULOS ADICIONALES                                                    │     │
│    │                                                                                                      │     │
│    │  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐ ┌──────────────────┐ ┌──────────────────────┐    │     │
│    │  │  PHARMACY   │ │ IMMUNIZATIONS│ │ OCCUPATIONAL │ │  COMMUNICATION   │ │ REPORT BUILDER       │    │     │
│    │  │  POS        │ │ (vacunas)   │ │  MEDICINE    │ │  (SMS/Email)     │ │ (SQL Editor)         │    │     │
│    │  └─────────────┘ └─────────────┘ └──────────────┘ └──────────────────┘ └──────────────────────┘    │     │
│    │                                                                                                      │     │
│    │  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐ ┌──────────────────┐ ┌──────────────────────┐    │     │
│    │  │ WAITLIST    │ │CALL CENTER  │ │  CERVICAL    │ │ECHOCARDIOGRAPHY  │ │ LAB IMPORT           │    │     │
│    │  │             │ │ (quotas)    │ │  SCREENING   │ │                  │ │                      │    │     │
│    │  └─────────────┘ └─────────────┘ └──────────────┘ └──────────────────┘ └──────────────────────┘    │     │
│    │                                                                                                      │     │
│    │  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐ ┌──────────────────┐ ┌──────────────────────────┐│     │
│    │  │  IMPLANTABLE│ │   DIGITAL   │ │   PATIENT    │ │  BULK IMPORT     │ │  DATA TRANSFORM          ││     │
│    │  │  DEVICES    │ │  SIGNATURE  │ │   MERGE      │ │                  │ │                          ││     │
│    │  └─────────────┘ └─────────────┘ └──────────────┘ └──────────────────┘ └──────────────────────────┘│     │
│    │                                                                                                      │     │
│    │  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐ ┌──────────────────┐ ┌──────────────────────────┐│     │
│    │  │ MEDICATIONS │ │DOCTOR STAFF │ │ PRE-CONSULT  │ │RECURRING APPT    │ │  OVERBOOKING             ││     │
│    │  │ CATALOG     │ │ MANAGEMENT  │ │              │ │                  │ │                          ││     │
│    │  └─────────────┘ └─────────────┘ └──────────────┘ └──────────────────┘ └──────────────────────────┘│     │
│    └──────────────────────────────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      MATRIZ ROL × PERMISOS                                                       │
│                                                                                                                 │
│     PERMISO \ ROL          │ ADMIN │ DOCTOR │ NURSE │ RECEPT. │ PHARM. │ LAB │ BILLING │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     patients.view          │  ✅   │   ✅   │  ✅   │   ✅    │   ✅   │ ✅  │   ✅    │                        │
│     patients.create        │  ✅   │   ✅   │  ✅   │   ✅    │        │     │         │                        │
│     patients.edit          │  ✅   │   ✅   │  ✅   │   ✅    │        │     │         │                        │
│     patients.delete        │  ✅   │        │       │         │        │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     appointments.view      │  ✅   │   ✅   │  ✅   │   ✅    │        │ ✅  │   ✅    │                        │
│     appointments.create    │  ✅   │   ✅   │  ✅   │   ✅    │        │     │         │                        │
│     appointments.edit      │  ✅   │   ✅   │  ✅   │   ✅    │        │     │         │                        │
│     appointments.cancel    │  ✅   │        │       │   ✅    │        │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     clinical.view          │  ✅   │   ✅   │  ✅   │   ✅    │   ✅   │     │         │                        │
│     clinical.create        │  ✅   │   ✅   │  ✅   │         │        │     │         │                        │
│     clinical.edit          │  ✅   │   ✅   │       │         │        │     │         │                        │
│     clinical.sign          │  ✅   │   ✅   │       │         │        │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     billing.view           │  ✅   │   ✅   │       │   ✅    │   ✅   │     │   ✅    │                        │
│     billing.create         │  ✅   │        │       │   ✅    │        │     │   ✅    │                        │
│     billing.edit           │  ✅   │        │       │         │        │     │   ✅    │                        │
│     billing.payments       │  ✅   │        │       │   ✅    │        │     │   ✅    │                        │
│     billing.invoice        │  ✅   │        │       │         │        │     │   ✅    │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     inventory.view         │  ✅   │        │  ✅   │         │   ✅   │     │         │                        │
│     inventory.entries      │  ✅   │        │       │         │   ✅   │     │         │                        │
│     inventory.exits        │  ✅   │        │  ✅   │         │   ✅   │     │         │                        │
│     inventory.adjust       │  ✅   │        │       │         │   ✅   │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     studies.view           │  ✅   │   ✅   │  ✅   │         │        │ ✅  │         │                        │
│     studies.create         │  ✅   │   ✅   │       │         │        │ ✅  │         │                        │
│     studies.edit           │  ✅   │        │       │         │        │ ✅  │         │                        │
│     studies.sign           │  ✅   │   ✅   │       │         │        │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     reports.view           │  ✅   │   ✅   │  ✅   │   ✅    │   ✅   │ ✅  │   ✅    │                        │
│     reports.generate       │  ✅   │   ✅   │       │         │        │     │   ✅    │                        │
│     reports.export         │  ✅   │        │       │         │        │     │   ✅    │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     admin.users            │  ✅   │        │       │         │        │     │         │                        │
│     admin.settings         │  ✅   │        │       │         │        │     │         │                        │
│     admin.audit            │  ✅   │        │       │         │        │     │         │                        │
│     admin.facilities       │  ✅   │        │       │         │        │     │         │                        │
│     admin.view             │  ✅   │        │       │         │        │     │         │                        │
│     admin.create           │  ✅   │        │       │         │        │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     staff.manage           │  ✅   │   ✅   │       │         │        │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     pharmacy.patient.view  │  ✅   │   ✅   │       │         │   ✅   │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     lab.view               │  ✅   │   ✅   │       │         │        │ ✅  │         │                        │
│     lab.create             │  ✅   │   ✅   │       │         │        │ ✅  │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     communication.view     │  ✅   │        │       │   ✅    │        │     │         │                        │
│     communication.send     │  ✅   │        │       │         │        │     │         │                        │
│    ────────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┤                        │
│     TOTAL PERMISOS         │   37  │   17   │   8   │   10    │   8    │  7  │   10    │                        │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                ÁRBOL DE PERMISOS POR MÓDULO                                                       │
│                                                                                                                 │
│  👤 patients                                           📊 reports                                               │
│  ├── patients.view          (Ver Pacientes)            ├── reports.view          (Ver Reportes)                  │
│  ├── patients.create        (Crear Pacientes)          ├── reports.generate      (Generar Reportes)              │
│  ├── patients.edit          (Editar Pacientes)         └── reports.export        (Exportar Reportes)             │
│  └── patients.delete        (Eliminar Pacientes)                                                               │
│                                                                                                                 │
│  📅 appointments                                       ⚙️ admin                                                 │
│  ├── appointments.view      (Ver Citas)                ├── admin.users           (Gestión de Usuarios)           │
│  ├── appointments.create    (Crear Citas)              ├── admin.settings        (Configuración)                 │
│  ├── appointments.edit      (Editar Citas)             ├── admin.audit           (Ver Auditoría)                 │
│  └── appointments.cancel    (Cancelar Citas)           ├── admin.facilities      (Gestión de Sedes)              │
│                                                        ├── admin.view            (Ver Admin)                     │
│  🩺 clinical                                           └── admin.create          (Crear en Admin)                │
│  ├── clinical.view          (Ver Historia Clínica)                                                              │
│  ├── clinical.create        (Crear Eventos)            🏥 staff                                                 │
│  ├── clinical.edit          (Editar Eventos)           └── staff.manage          (Gestión del Personal)          │
│  └── clinical.sign          (Firmar Eventos)                                                                    │
│                                                                                                                 │
│  💰 billing                                            🧪 lab                                                   │
│  ├── billing.view           (Ver Facturación)          ├── lab.view              (Ver Laboratorio)               │
│  ├── billing.create         (Crear Cuentas)            └── lab.create            (Crear en Laboratorio)          │
│  ├── billing.edit           (Editar Cuentas)                                                                    │
│  ├── billing.payments       (Registrar Pagos)          💊 pharmacy                                              │
│  └── billing.invoice        (Facturar)                 └── pharmacy.patient.view (Ver Datos de Pacientes)        │
│                                                                                                                 │
│  📦 inventory                                          📨 communication                                         │
│  ├── inventory.view         (Ver Inventario)           ├── communication.view    (Ver Comunicaciones)            │
│  ├── inventory.entries      (Ingresos)                 └── communication.send    (Enviar Comunicaciones)         │
│  ├── inventory.exits        (Salidas)                                                                           │
│  └── inventory.adjust       (Ajustes)                                                                           │
│                                                                                                                 │
│  🔬 studies                                                                                                     │
│  ├── studies.view           (Ver Estudios)                                                                      │
│  ├── studies.create         (Crear Estudios)                                                                     │
│  ├── studies.edit           (Editar Estudios)                                                                    │
│  └── studies.sign           (Firmar Estudios)                                                                    │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                            MAPA COMPLETO: ROL → MÓDULOS → ENDPOINTS                                               │
│                                                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ ADMIN (37 permisos)                                                                                      │   │
│  │                                                                                                          │   │
│  │  ├── /patients/*              CRUD completo + merge + bulk import                                        │   │
│  │  ├── /appointments/*          CRUD completo + status + recurring + overbooking                           │   │
│  │  ├── /clinical-records/*      CRUD completo + sign + templates + attachments                             │   │
│  │  ├── /billing/*               CRUD + payments + invoice + credit notes + e-invoicing (DIAN)              │   │
│  │  ├── /inventory/*             warehouses + materials + entries + dispatches + counts                     │   │
│  │  ├── /studies/*               CRUD + sign + deliver + categories + templates                             │   │
│  │  ├── /rips/*                  CRUD batches + validate + generate + submit (RIPS + APEDT)                 │   │
│  │  ├── /reports/*               templates + generate + jobs + stats                                        │   │
│  │  ├── /reports/stats/*         dashboard + patients + appointments + billing + diagnoses                  │   │
│  │  ├── /admin/*                 users CRUD + roles + permissions + settings + audit + facilities           │   │
│  │  ├── /admin/clients/*         tenant management + documents + commercial config                          │   │
│  │  ├── /admin/migrations/*      SistemaMED data import                                                     │   │
│  │  ├── /admin/notifications/*   notification logs                                                          │   │
│  │  ├── /admin/reviews/*         moderation (pending, approve, reject)                                      │   │
│  │  ├── /ai/*                    transcription + SOAP + CDSS + chatbot + triage                             │   │
│  │  ├── /fhir/*                  metadata + Patient + Encounter + $everything                               │   │
│  │  ├── /pharmacy-sales/*        CRUD + receipts                                                             │   │
│  │  ├── /pharmacy-intakes/*      CRUD                                                                        │   │
│  │  ├── /pharmacy-verifications/* CRUD                                                                       │   │
│  │  ├── /pharmacy-packages/*     CRUD                                                                        │   │
│  │  ├── /pharmacy-expense-sheets/* CRUD                                                                      │   │
│  │  ├── /pharmacy-kardex/*       kardex listings                                                             │   │
│  │  ├── /medications/*           catalog CRUD                                                                │   │
│  │  ├── /medical-orders/*        CRUD + documents + email                                                    │   │
│  │  ├── /prescriptions/*         CRUD + status + documents + email                                           │   │
│  │  ├── /vital-signs/*           CRUD + trends                                                               │   │
│  │  ├── /incapacities/*          CRUD + documents                                                            │   │
│  │  ├── /referrals/*             CRUD + status + documents                                                   │   │
│  │  ├── /occupational-evals/*    CRUD + sign + document                                                      │   │
│  │  ├── /consents/*              templates + signatures                                                      │   │
│  │  ├── /cervical-screenings/*   CRUD + statistics                                                           │   │
│  │  ├── /echocardiographies/*    CRUD + trends                                                               │   │
│  │  ├── /implantable-devices/*   CRUD                                                                        │   │
│  │  ├── /digital-signatures/*    CRUD                                                                        │   │
│  │  ├── /lab-imports/*           upload + batches + results                                                  │   │
│  │  ├── /data-transforms/*       configs CRUD + run + jobs                                                   │   │
│  │  ├── /report-builder/*        execute + save + categories + templates                                     │   │
│  │  ├── /report-engine/*         execute SQL + parse + templates                                             │   │
│  │  ├── /communication/*         templates + campaigns + send                                                │   │
│  │  ├── /call-center/*           quotas + operators + logs + stats                                           │   │
│  │  ├── /waitlist/*              CRUD + stats + offer/accept/decline                                         │   │
│  │  ├── /pre-consultations/*     CRUD + form                                                                 │   │
│  │  ├── /system-config/*         read/write + module flags + behaviors                                       │   │
│  │  ├── /insurance-plans/*       CRUD + coverage + CMF/HEL exports                                           │   │
│  │  ├── /document-templates/*    CRUD + render + merge                                                       │   │
│  │  ├── /tariffs/*               CRUD + items + duplicate                                                    │   │
│  │  ├── /cash-boxes/*            open/close/reconcile + transactions                                         │   │
│  │  ├── /credit-notes/*          CRUD + approve/send/apply/void + e-invoice                                  │   │
│  │  ├── /doctor/staff/*          manage own staff                                                            │   │
│  │  ├── /schedules/*             CRUD + blocks + availability                                                │   │
│  │  ├── /providers/*             schedules + availability + appointments                                     │   │
│  │  ├── /facilities/*            appointments + accounts + warehouses + studies                              │   │
│  │  ├── /medical-staff/*         list + self                                                                 │   │
│  │  ├── /metrics                 Prometheus metrics                                                          │   │
│  │  └── /imports/*               bulk import                                                                 │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ DOCTOR (17 permisos)                                                                                     │   │
│  │                                                                                                          │   │
│  │  ├── /patients/*              view + create + edit (no delete)                                           │   │
│  │  ├── /appointments/*          view + create + edit                                                       │   │
│  │  ├── /clinical-records/*      view + create + edit + sign                                                │   │
│  │  ├── /billing/*               view only                                                                  │   │
│  │  ├── /studies/*               view + create + sign                                                       │   │
│  │  ├── /rips/*                  acceso completo (role-based)                                               │   │
│  │  ├── /reports/*               view + generate                                                            │   │
│  │  ├── /reports/stats/*         dashboard                                                                  │   │
│  │  ├── /ai/*                    transcription + SOAP + CDSS + chatbot + triage                             │   │
│  │  ├── /fhir/*                  metadata + Patient + Encounter + $everything                               │   │
│  │  ├── /vital-signs/*           CRUD + trends                                                               │   │
│  │  ├── /prescriptions/*         CRUD + status + documents + email                                          │   │
│  │  ├── /medical-orders/*        CRUD + status + documents + email                                          │   │
│  │  ├── /incapacities/*          CRUD + documents                                                            │   │
│  │  ├── /referrals/*             CRUD + status + documents                                                   │   │
│  │  ├── /occupational-evals/*    CRUD + sign + document                                                      │   │
│  │  ├── /clinical-templates/*    CRUD                                                                        │   │
│  │  ├── /document-templates/*    view + render + merge                                                       │   │
│  │  ├── /consents/*              templates + signatures                                                      │   │
│  │  ├── /event-attachments/*     upload + delete                                                             │   │
│  │  ├── /pharmacy-sales/*        read only (patient data)                                                    │   │
│  │  ├── /medications/*           view catalog                                                                │   │
│  │  ├── /cervical-screenings/*   CRUD + statistics                                                           │   │
│  │  ├── /echocardiographies/*    CRUD + trends                                                               │   │
│  │  ├── /implantable-devices/*   CRUD                                                                        │   │
│  │  ├── /digital-signatures/*    CRUD                                                                        │   │
│  │  ├── /lab-imports/*           view batches + results                                                      │   │
│  │  ├── /pre-consultations/*     CRUD + form                                                                 │   │
│  │  ├── /doctor/staff/*          manage own staff                                                            │   │
│  │  ├── /report-builder/*        execute + save + categories                                                 │   │
│  │  ├── /report-engine/*         execute SQL + parse                                                         │   │
│  │  ├── /waitlist/*              view only + stats                                                           │   │
│  │  ├── /schedules/*             CRUD + blocks                                                                │   │
│  │  ├── /providers/*             schedules + availability + appointments                                     │   │
│  │  ├── /facilities/*            appointments + studies (view)                                               │   │
│  │  ├── /medical-staff/*         list + self                                                                 │   │
│  │  └── /insurance-plans/*       view + coverage                                                             │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ NURSE (8 permisos)                                                                                       │   │
│  │                                                                                                          │   │
│  │  ├── /patients/*              view + create + edit                                                       │   │
│  │  ├── /appointments/*          view + create + edit + status update                                       │   │
│  │  ├── /clinical-records/*      view + create (no edit, no sign)                                           │   │
│  │  ├── /inventory/*             view + dispatches (exits)                                                  │   │
│  │  ├── /studies/*               view only                                                                  │   │
│  │  ├── /reports/stats/*         dashboard                                                                  │   │
│  │  ├── /vital-signs/*           CRUD + trends                                                               │   │
│  │  ├── /prescriptions/*         view only                                                                  │   │
│  │  ├── /medical-orders/*        view only                                                                  │   │
│  │  ├── /incapacities/*          view only                                                                  │   │
│  │  ├── /referrals/*             view only                                                                  │   │
│  │  ├── /consents/*              view + signatures                                                           │   │
│  │  ├── /clinical-templates/*    view                                                                        │   │
│  │  ├── /document-templates/*    view + render + merge                                                       │   │
│  │  ├── /cervical-screenings/*   view + statistics                                                           │   │
│  │  ├── /echocardiographies/*    view + trends                                                               │   │
│  │  ├── /implantable-devices/*   view                                                                        │   │
│  │  ├── /digital-signatures/*    view                                                                        │   │
│  │  ├── /pharmacy-sales/*        read only (patient data)                                                    │   │
│  │  ├── /waitlist/*              view + stats                                                               │   │
│  │  ├── /schedules/*             view + blocks                                                                │   │
│  │  ├── /providers/*             schedules + availability + appointments                                     │   │
│  │  ├── /facilities/*            appointments                                                                 │   │
│  │  ├── /medical-staff/*         list + self                                                                 │   │
│  │  └── /insurance-plans/*       view + coverage                                                             │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ RECEPTIONIST (10 permisos)                                                                               │   │
│  │                                                                                                          │   │
│  │  ├── /patients/*              view + create + edit (no delete)                                           │   │
│  │  ├── /appointments/*          view + create + edit + cancel + status                                     │   │
│  │  ├── /clinical-records/*      view only                                                                  │   │
│  │  ├── /billing/*               view + create + payments (no edit, no invoice)                              │   │
│  │  ├── /reports/stats/*         dashboard                                                                  │   │
│  │  ├── /communication/*         view templates + campaigns                                                  │   │
│  │  ├── /waitlist/*              view + create + edit + delete + stats                                      │   │
│  │  ├── /call-center/*           quotas + reservations + operators + logs + stats                           │   │
│  │  ├── /schedules/*             CRUD + blocks                                                                │   │
│  │  ├── /providers/*             schedules + availability + appointments                                     │   │
│  │  ├── /facilities/*            appointments                                                                 │   │
│  │  ├── /medical-staff/*         list + self                                                                 │   │
│  │  └── /insurance-plans/*       view + coverage                                                             │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ PHARMACY / Pharmacist (8 permisos)                                                                       │   │
│  │                                                                                                          │   │
│  │  ├── /patients/*              view only (datos limitados)                                                │   │
│  │  ├── /clinical-records/*      view only                                                                  │   │
│  │  ├── /billing/*               view only                                                                  │   │
│  │  ├── /inventory/*             view + entries + exits + adjust                                            │   │
│  │  ├── /pharmacy-sales/*        CRUD completo + receipts                                                    │   │
│  │  ├── /pharmacy-intakes/*      CRUD                                                                        │   │
│  │  ├── /pharmacy-verifications/* CRUD                                                                       │   │
│  │  ├── /pharmacy-packages/*     CRUD                                                                        │   │
│  │  ├── /pharmacy-expense-sheets/* CRUD                                                                      │   │
│  │  ├── /pharmacy-kardex/*       kardex listings                                                             │   │
│  │  ├── /medications/*           view + create + update (catalog)                                            │   │
│  │  ├── /reports/stats/*         dashboard                                                                  │   │
│  │  ├── /facilities/*            appointments                                                                 │   │
│  │  └── /medical-staff/*         list + self                                                                 │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ LAB / Lab Tech (7 permisos)                                                                              │   │
│  │                                                                                                          │   │
│  │  ├── /patients/*              view only                                                                  │   │
│  │  ├── /appointments/*          view only                                                                  │   │
│  │  ├── /studies/*               view + create + edit (no sign)                                             │   │
│  │  ├── /lab-imports/*           upload + batches + results                                                  │   │
│  │  ├── /reports/*               view + stats                                                               │   │
│  │  ├── /reports/stats/*         dashboard                                                                  │   │
│  │  ├── /facilities/*            appointments                                                                 │   │
│  │  └── /medical-staff/*         list + self                                                                 │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ BILLING (10 permisos)                                                                                    │   │
│  │                                                                                                          │   │
│  │  ├── /patients/*              view only                                                                  │   │
│  │  ├── /appointments/*          view only                                                                  │   │
│  │  ├── /billing/*               view + create + edit + payments + invoice                                   │   │
│  │  ├── /cash-boxes/*            open/close/reconcile + transactions                                         │   │
│  │  ├── /credit-notes/*          view + create + approve/send/apply/void + e-invoice                         │   │
│  │  ├── /tariffs/*               view + create + edit + delete + items                                       │   │
│  │  ├── /electronic-invoicing/*  providers + QR                                                             │   │
│  │  ├── /rips/*                  acceso completo (role-based)                                               │   │
│  │  ├── /reports/*               view + generate + export                                                    │   │
│  │  ├── /reports/stats/*         dashboard + billing stats                                                          │   │
│  │  ├── /report-builder/*        execute + save + categories                                                 │   │
│  │  ├── /report-engine/*         execute SQL + parse                                                         │   │
│  │  ├── /insurance-plans/*       view + create + update + delete + coverage + CMF/HEL                        │   │
│  │  ├── /facilities/*            appointments + accounts                                                      │   │
│  │  └── /medical-staff/*         list + self                                                                 │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      SISTEMA DE AUTENTICACIÓN                                                    │
│                                                                                                                 │
│  ┌─────────────────────────────────────────┐    ┌─────────────────────────────────────────┐                     │
│  │          STAFF AUTH (Staff)              │    │        PATIENT AUTH (Portal)            │                     │
│  │                                         │    │                                         │                     │
│  │  POST /api/v1/auth/login                │    │  POST /api/v1/patient-portal/auth/login │                     │
│  │         │                               │    │         │                               │                     │
│  │         ▼                               │    │         ▼                               │                     │
│  │  ┌──────────────────────────┐           │    │  ┌──────────────────────────┐           │                     │
│  │  │ JWT Token                │           │    │  │ JWT Token                │           │                     │
│  │  │ access:  15 min          │           │    │  │ access:  15 min          │           │                     │
│  │  │ refresh: 7 días          │           │    │  │ refresh: 7 días          │           │                     │
│  │  │                          │           │    │  │                          │           │                     │
│  │  │ Claims:                  │           │    │  │ Claims:                  │           │                     │
│  │  │  • UserID                │           │    │  │  • PatientID             │           │                     │
│  │  │  • Username              │           │    │  │  • Email                 │           │                     │
│  │  │  • Role (7 roles)        │           │    │  │  • Type: "patient"       │           │                     │
│  │  │  • FacilityID (tenant)   │           │    │  └──────────────────────────┘           │                     │
│  │  │  • DoctorID (opcional)   │           │    │         │                               │                     │
│  │  └──────────────────────────┘           │    │         ▼                               │                     │
│  │         │                               │    │  mw.PatientAuth()                        │                     │
│  │         ▼                               │    │  middleware                             │                     │
│  │  mw.Auth() middleware                   │    │         │                               │                     │
│  │         │                               │    │         ▼                               │                     │
│  │         ▼                               │    │  /api/v1/patient-portal/*               │                     │
│  │  ┌──────────────────┐                   │    │  (endpoints paciente)                   │                     │
│  │  │ RequireRole()    │ ← role check      │    └─────────────────────────────────────────┘                     │
│  │  │ RequirePermission│ ← permission check│                                                                   │
│  │  └──────────────────┘                   │                                                                   │
│  │         │                               │                                                                   │
│  │         ▼                               │                                                                   │
│  │  /api/v1/* (endpoints staff)            │                                                                   │
│  └─────────────────────────────────────────┘                                                                   │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                  FLUJO DE AUTORIZACIÓN (REQUEST LIFECYCLE)                                        │
│                                                                                                                 │
│   Request                                                                                                       │
│     │                                                                                                           │
│     ▼                                                                                                           │
│   ┌──────────────┐                                                                                              │
│   │  RequestID   │  ← Trace ID único                                                                            │
│   └──────┬───────┘                                                                                              │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │   Logger     │  ← zerolog request logging                                                                  │
│   └──────┬───────┘                                                                                              │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │   Recover    │  ← Panic recovery                                                                           │
│   └──────┬───────┘                                                                                              │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │    CORS      │  ← Configurable origins                                                                      │
│   └──────┬───────┘                                                                                              │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │    Auth      │  ← JWT Validation                                                                           │
│   │ (staff o     │     • Parse token                                                                           │
│   │  patient)    │     • Validate signature                                                                    │
│   └──────┬───────┘     • Check blacklist                                                                       │
│          │             • Set context: user_id, user_role, facility_id, tenant_id                               │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │ RequireRole  │  ← Role check (ej: admin, doctor)                                                           │
│   │ (opcional)   │     • Grupos de rutas protegidas por rol específico                                        │
│   └──────┬───────┘                                                                                              │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │RequirePermis-│  ← Permission check (ej: clinical.create)                                                   │
│   │ sion(opcional│     • Admin bypass automático                                                               │
│   └──────┬───────┘     • DB check (rbacService)                                                                │
│          │             • Fallback: defaultRolePermissions                                                       │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │   Handler    │  ← Parse DTO → Validate → Call UseCase → JSON Response                                     │
│   └──────┬───────┘                                                                                              │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │  UseCase     │  ← Business logic                                                                           │
│   └──────┬───────┘                                                                                              │
│          ▼                                                                                                      │
│   ┌──────────────┐                                                                                              │
│   │ Repository   │  ← pgx/sqlc queries (multi-tenant scoped)                                                   │
│   └──────────────┘                                                                                              │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                          LEYENDA                                                                 │
│                                                                                                                 │
│  ✅  = Permiso otorgado                                                                                         │
│  ⭐  = Nivel de acceso                                                                                          │
│  👤  = Módulo Patients                                                                                          │
│  📅  = Módulo Appointments                                                                                      │
│  🩺  = Módulo Clinical Records                                                                                  │
│  💰  = Módulo Billing                                                                                           │
│  📦  = Módulo Inventory                                                                                         │
│  🔬  = Módulo Studies                                                                                           │
│  📊  = Módulo Reports                                                                                           │
│  ⚙️  = Módulo Admin                                                                                             │
│  🏥  = Staff Management                                                                                         │
│  🧪  = Lab                                                                                                      │
│  💊  = Pharmacy                                                                                                 │
│  📨  = Communication                                                                                            │
│                                                                                                                 │
│  mw.Auth()         = JWT staff authentication middleware                                                        │
│  mw.PatientAuth()  = JWT patient portal authentication middleware                                               │
│  mw.RequireRole()  = Role-based access control middleware                                                       │
│  mw.RequirePermission() = Permission-based access control middleware                                            │
│                                                                                                                 │
│  NOTAS:                                                                                                         │
│  • Admin tiene bypass automático en RequirePermission (todos los permisos)                                      │
│  • El sistema soporta multi-tenancy vía facility_id en el JWT                                                   │
│  • Los permisos pueden ser personalizados por usuario en la DB (extra_permissions)                              │
│  • El flujo de autorización: Role → Permission → Route/Handler                                                 │
│  • RIPS y APEDT usan RequireRole (admin, billing, doctor) en vez de permisos                                    │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
