# MedNext — RBAC: Frontend vs Backend (Comparación Completa)

```
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                            RBAC CROSS-REFERENCE: BACKEND ↔ FRONTEND                                             ║
║                         Roles · Permisos · Módulos · Rutas · Guards                                              ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
```

---

## 🔴 BUG CRÍTICO: Inconsistencia de Nombres de Roles

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                           ROLE NAME MISMATCH — BACKEND vs FRONTEND                                              │
│                                                                                                                 │
│  Backend (defaultRolePermissions)     Frontend (route.data.roles)       JWT (claim "role")                      │
│  ────────────────────────────────     ─────────────────────────         ──────────────────                      │
│  "admin"       ✅                     "admin"       ✅                  "admin"                                  │
│  "doctor"      ✅                     "doctor"      ✅                  "doctor"                                 │
│  "nurse"       ✅                     "nurse"       ✅                  "nurse"                                  │
│  "receptionist"✅                     "receptionist"✅                  "receptionist"                           │
│  "pharmacy"    ❌ MISMATCH!           "pharmacist"  ❌                  "pharmacy" (DB seed)                     │
│  "lab"         ❌ MISMATCH!           "lab_tech"    ❌                  "lab" (DB seed)                          │
│  "billing"     ✅                     "billing"     ✅                  "billing"                                │
│                                                                                                                 │
│  ⚠️  PROBLEMA: El JWT contiene "pharmacy" y "lab" (desde el seed de BD),                                       │
│     pero el frontend checkea con route.data.roles = ['pharmacist'] y ['lab_tech'].                              │
│     authGuard.hasRole(['pharmacist']) NUNCA será true si el JWT dice "pharmacy".                                │
│                                                                                                                 │
│  📍 Archivos afectados:                                                                                         │
│     back: auth_handler.go:29 (roleNameMapping) → middleware/auth.go:212 (defaultRolePermissions)               │
│     front: app.routes.ts (route.data.roles) → auth.guard.ts (hasRole)                                          │
│     front: session.service.ts (navItems filter by role)                                                         │
│                                                                                                                 │
│  💡 SOLUCIÓN: Unificar nombres — usar "pharmacist" y "lab_tech" en ambos lados,                                │
│     o agregar un mapping en el frontend que traduzca los nombres.                                               │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 MATRIZ COMPLETA: Backend Permisos vs Frontend Rutas

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  MÓDULO          │ BACKEND (Permisos + Roles)                │ FRONTEND (Route data.roles)       │ MATCH?      │
├──────────────────┼──────────────────────────────────────────┼───────────────────────────────────┼─────────────┤
│                  │                                           │                                   │             │
│ PATIENTS         │ patients.view:   A,D,N,R,PH,L,B          │ roles: [A,D,N,R]                  │ 🟡 PARCIAL  │
│ /patients        │ patients.create: A,D,N,R                 │ (sin pharmacist, lab_tech,        │             │
│                  │ patients.edit:   A,D,N,R                 │  billing en frontend)             │             │
│                  │ patients.delete: A                        │                                   │             │
│                  │ RequireRole: admin,doctor,nurse,recept.   │                                   │             │
│                  │                                           │                                   │             │
│ APPOINTMENTS     │ appointments.view:   A,D,N,R,L,B         │ roles: [A,D,N,R]                  │ 🟡 PARCIAL  │
│ /appointments    │ appointments.create: A,D,N,R             │ (sin lab_tech, billing en FE)    │             │
│                  │ appointments.edit:   A,D,N,R             │                                   │             │
│                  │ appointments.cancel: A,R                 │                                   │             │
│                  │                                           │                                   │             │
│ CLINICAL RECORDS │ clinical.view:   A,D,N,R,PH              │ roles: [A,D,N]                    │ 🟡 PARCIAL  │
│ /clinical-records│ clinical.create: A,D,N                   │ (sin receptionist, pharmacist     │             │
│                  │ clinical.edit:   A,D                     │  en frontend)                     │             │
│                  │ clinical.sign:   A,D                     │                                   │             │
│                  │                                           │                                   │             │
│ BILLING          │ billing.view:     A,D,R,PH,B             │ roles: [A,B,R]                    │ 🟢 OK       │
│ /billing         │ billing.create:   A,R,B                  │ (doctor y pharmacist sin acceso   │             │
│                  │ billing.edit:     A,B                    │  de escritura en frontend pero     │             │
│                  │ billing.payments: A,R,B                  │  backend les da view)             │             │
│                  │ billing.invoice:  A,B                    │                                   │             │
│                  │                                           │                                   │             │
│ INVENTORY        │ inventory.view:    A,N,PH                │ roles: [A,PH,N]                   │ 🟢 OK       │
│ /inventory       │ inventory.entries: A,PH                  │                                   │             │
│                  │ inventory.exits:   A,N,PH                │                                   │             │
│                  │ inventory.adjust:  A,PH                  │                                   │             │
│                  │                                           │                                   │             │
│ STUDIES          │ studies.view:   A,D,N,L                  │ roles: [A,D,LT]                   │ 🔴 MISMATCH │
│ /studies         │ studies.create: A,D,L                    │ (nurse tiene view en backend      │ nurse tiene │
│                  │ studies.edit:   A,L                      │  pero NO en frontend)             │ view en BE  │
│                  │ studies.sign:   A,D                      │                                   │ pero no FE  │
│                  │                                           │                                   │             │
│ REPORTS          │ reports.view:     A,D,N,R,PH,L,B         │ roles: [A,B,D]                    │ 🟡 PARCIAL  │
│ /reports         │ reports.generate: A,D,B                  │ (solo admin, billing, doctor      │             │
│                  │ reports.export:   A,B                    │  en frontend; nurse, recept,      │             │
│                  │                                           │  pharm, lab sin acceso FE)        │             │
│                  │                                           │                                   │             │
│ ADMIN            │ RequireRole: admin                       │ roles: [A]                       │ 🟢 OK       │
│ /admin           │ admin.users/settings/audit/facilities    │                                   │             │
│                  │                                           │                                   │             │
│ PHARMACY POS     │ pharmacy.patient.view: A,D,PH            │ roles: [A,PH]                     │ 🟡 PARCIAL  │
│ /pharmacy        │ + inventory.* permissions                │ (doctor tiene view en backend     │             │
│                  │                                           │  pero NO en frontend)             │             │
│                  │                                           │                                   │             │
│ SCHEDULES        │ appointments.create: A,D,N,R             │ roles: [A,D]                      │ 🔴 MISMATCH │
│ /schedules       │ (create perm da acceso a schedules)      │ (nurse y receptionist SIN acceso  │ N,R tienen  │
│                  │                                           │  a schedules en frontend)         │ perm en BE  │
│                  │                                           │                                   │             │
│ RIPS             │ RequireRole: A,B,D                        │ roles: [A,B,D]                    │ 🟢 OK       │
│ /rips + /rips-v2 │                                           │                                   │             │
│                  │                                           │                                   │             │
│ APEDT            │ RequireRole: A,B,D                        │ roles: [A,B,D]                    │ 🟢 OK       │
│ /apedt           │                                           │                                   │             │
│                  │                                           │                                   │             │
│ WAITLIST         │ appointments.view/create: A,D,N,R        │ roles: [A,D,R]                    │ 🟡 PARCIAL  │
│ /waitlist        │                                           │ (nurse sin acceso en frontend)    │ nurse puede  │
│                  │                                           │                                   │ ver en BE    │
│                  │                                           │                                   │             │
│ RECURRING APPT   │ appointments.create: A,D,N,R             │ roles: [A,D,R]                    │ 🟡 PARCIAL  │
│ /recurring-appts │                                           │ (nurse sin acceso en frontend)    │             │
│                  │                                           │                                   │             │
│ OVERBOOKING      │ appt.create (read), admin (write)        │ roles: [A,D]                      │ 🟢 OK       │
│ /overbooking     │                                           │                                   │             │
│                  │                                           │                                   │             │
│ TARIFFS          │ billing.view/create: A,R,B               │ roles: [A,B]                      │ 🟡 PARCIAL  │
│ /tariffs         │                                           │ (receptionist sin acceso FE)      │             │
│                  │                                           │                                   │             │
│ CASHBOX          │ billing.view/create: A,B,R               │ roles: [A,B,R]                    │ 🟢 OK       │
│ /cashbox         │                                           │                                   │             │
│                  │                                           │                                   │             │
│ CREDIT NOTES     │ billing.view/create: A,B,R               │ roles: [A,B]                      │ 🟡 PARCIAL  │
│ /credit-notes    │                                           │ (receptionist sin acceso FE)      │             │
│                  │                                           │                                   │             │
│ E-INVOICING      │ billing.view: A,D,B,R,PH                 │ roles: [A,B]                      │ 🟡 PARCIAL  │
│ /electronic-inv. │ billing.create: A,B                      │ (doctor, recept, pharm sin FE)   │             │
│                  │                                           │                                   │             │
│ OCCUPATIONAL     │ clinical.view/create: A,D,N              │ roles: [A,D]                      │ 🟡 PARCIAL  │
│ /occupational    │                                           │ (nurse sin acceso FE)             │             │
│                  │                                           │                                   │             │
│ SYSTEM CONFIG    │ RequireRole: admin                       │ roles: [A]                       │ 🟢 OK       │
│ /system-config   │                                           │                                   │             │
│                  │                                           │                                   │             │
│ INSURANCE PLANS  │ billing.view/create: A,D,R,PH,B          │ roles: [A,B]                      │ 🔴 MISMATCH │
│ /insurance-plans │                                           │ (doctor, recept, pharm con        │ D,R,PH con  │
│                  │                                           │  view en BE pero sin FE)          │ view en BE  │
│                  │                                           │                                   │             │
│ DOC TEMPLATES    │ clinical.view/create: A,D,N              │ roles: [A,D]                      │ 🟡 PARCIAL  │
│ /document-templ. │                                           │ (nurse sin acceso FE)             │             │
│                  │                                           │                                   │             │
│ IMPORTS          │ RequireRole: admin                       │ roles: [A]                       │ 🟢 OK       │
│ /imports         │                                           │                                   │             │
│                  │                                           │                                   │             │
│ COMMUNICATION    │ communication.view: A,R                  │ roles: [A,R]                      │ 🟢 OK       │
│ /communication   │ communication.send: A                    │                                   │             │
│                  │                                           │                                   │             │
│ CALL CENTER      │ appointments.view/create: A,D,N,R        │ roles: [A,R]                      │ 🔴 MISMATCH │
│ /call-center     │                                           │ (doctor y nurse con permiso       │ D,N con     │
│                  │                                           │  en BE pero sin acceso FE)        │ permiso BE  │
│                  │                                           │                                   │             │
│ CERVICAL SCREEN. │ clinical.view/create: A,D,N              │ roles: [A,D]                      │ 🟡 PARCIAL  │
│ /cervical-screen │                                           │ (nurse sin acceso FE)             │             │
│                  │                                           │                                   │             │
│ ECHOCARDIOGRAPHY │ clinical.view/create: A,D,N              │ roles: [A,D]                      │ 🟡 PARCIAL  │
│ /echocardiography│                                           │ (nurse sin acceso FE)             │             │
│                  │                                           │                                   │             │
│ IMPLANTABLE DEV. │ clinical.view/create: A,D,N              │ roles: [A,D]                      │ 🟡 PARCIAL  │
│ /implantable-dev │                                           │ (nurse sin acceso FE)             │             │
│                  │                                           │                                   │             │
│ LAB IMPORT       │ lab.view/create: A,D,L                   │ roles: [A,LT,D]                   │ 🟢 OK       │
│ /lab-import      │                                           │                                   │             │
│                  │                                           │                                   │             │
│ DATA TRANSFORM   │ admin.view/create: A                     │ roles: [A]                       │ 🟢 OK       │
│ /data-transform  │                                           │                                   │             │
│                  │                                           │                                   │             │
│ DIGITAL SIGN.    │ clinical.view/create: A,D,N              │ roles: [A,D,N]                    │ 🟢 OK       │
│ /digital-sign.   │                                           │                                   │             │
│                  │                                           │                                   │             │
│ DOCTOR STAFF     │ staff.manage: A,D                        │ roles: [D]                        │ 🟡 PARCIAL  │
│ /doctor/staff    │                                           │ (admin tiene permiso en BE        │ admin puede  │
│                  │                                           │  pero no ruta en FE)              │ pero no FE  │
│                  │                                           │                                   │             │
│ SETTINGS         │ admin.setting: A                         │ roles: [A]                       │ 🟢 OK       │
│ /settings        │                                           │                                   │             │
│                  │                                           │                                   │             │
│ ACCOUNT          │ (cualquier staff autenticado)            │ (sin roles — cualquier staff)     │ 🟢 OK       │
│ /account         │                                           │                                   │             │
│                  │                                           │                                   │             │
│ DASHBOARD        │ (cualquier staff autenticado)            │ (sin roles — cualquier staff)     │ 🟢 OK       │
│ /dashboard       │                                           │                                   │             │
│                  │                                           │                                   │             │
│ PATIENT PORTAL   │ PatientAuth middleware                    │ patientAuthGuard                  │ 🟢 OK       │
│ /patient-portal  │                                           │                                   │             │
│                  │                                           │                                   │             │
│ PUBLIC           │ Sin auth                                 │ Sin auth                          │ 🟢 OK       │
│ /providers, etc  │                                           │                                   │             │
│                  │                                           │                                   │             │
│ LEGEND: A=Admin D=Doctor N=Nurse R=Receptionist PH=Pharmacist L=Lab_tech B=Billing LT=Lab_tech               │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🗺️ MAPA DE ARQUITECTURA RBAC: FLUJO COMPLETO

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                         ARQUITECTURA DUAL RBAC                                                 │
│                                                                                                                 │
│  ┌───────────────────────────────────────────────────┐   ┌───────────────────────────────────────────────────┐ │
│  │              FRONTEND (Angular)                    │   │              BACKEND (Go/Echo)                     │ │
│  │                                                   │   │                                                   │ │
│  │  ┌─────────────────┐                              │   │  ┌─────────────────┐                              │ │
│  │  │  app.routes.ts  │  data: { roles: [...] }      │   │  │   router.go     │  mw.RequireRole()            │ │
│  │  │  31 staff routes │  ──────────────────────┐    │   │  │  30+ grupos     │  mw.RequirePermission()      │ │
│  │  └────────┬────────┘                         │    │   │  └────────┬────────┘                              │ │
│  │           │                                   │    │   │           │                                       │ │
│  │           ▼                                   │    │   │           ▼                                       │ │
│  │  ┌─────────────────┐                          │    │   │  ┌─────────────────┐                              │ │
│  │  │  auth.guard.ts  │  hasRole(roles[])         │    │   │  │  auth.go        │  RequireRole(roles...)      │ │
│  │  │  (CanActivate)  │  ──────────────────┐     │    │   │  │  (middleware)   │  RequirePermission(perms..) │ │
│  │  └────────┬────────┘                    │     │    │   │  └────────┬────────┘                              │ │
│  │           │                              │     │    │   │           │                                       │ │
│  │           ▼                              │     │    │   │           ▼                                       │ │
│  │  ┌─────────────────┐                    │     │    │   │  ┌─────────────────┐                              │ │
│  │  │ auth.service.ts │  userRole()         │     │    │   │  │  JWT Claims     │  "role": "doctor"            │ │
│  │  │  hasRole([])    │  ← signal del JWT  │     │    │   │  │  (decoded)      │  "facility_id": 1           │ │
│  │  └────────┬────────┘                    │     │    │   │  └────────┬────────┘                              │ │
│  │           │                              │     │    │   │           │                                       │ │
│  │           ▼                              │     │    │   │           ▼                                       │ │
│  │  ┌─────────────────┐                    │     │    │   │  ┌─────────────────┐                              │ │
│  │  │ session.service │  navItems()         │     │    │   │  │defaultRolePerms │  map[role][]permission       │ │
│  │  │  .ts            │  ← filtra sidebar  │     │    │   │  │ (fallback)      │  + rbacService (DB)          │ │
│  │  └─────────────────┘                    │     │    │   │  └────────┬────────┘                              │ │
│  │                                          │     │    │   │           │                                       │ │
│  │  ┌─────────────────┐                    │     │    │   │           ▼                                       │ │
│  │  │ auth.interceptor│  Bearer <token>    │     │    │   │  ┌─────────────────┐                              │ │
│  │  │ .ts             │  ──────────────────┼─────┼───┼──│  │  Handler         │  UseCase → Repository         │ │
│  │  └─────────────────┘                    │     │    │   │  └─────────────────┘                              │ │
│  └──────────────────────────────────────────┼─────┼────┘   └───────────────────────────────────────────────────┘ │
│                                              │     │                                                              │
│                    ┌─────────────────────────┘     └──────────────────────────────────────────────┐               │
│                    │                                                                               │               │
│                    ▼                                                                               ▼               │
│           ┌────────────────┐                                                             ┌────────────────┐       │
│           │ ¿Coinciden?    │                                                             │ ¿Coinciden?    │       │
│           │ FE roles con   │                                                             │ BE permisos    │       │
│           │ BE permisos?   │                                                             │ con FE rutas?  │       │
│           └───────┬────────┘                                                             └───────┬────────┘       │
│                   │                                                                               │               │
│                   ▼                                                                               ▼               │
│           ┌────────────────┐                                                             ┌────────────────┐       │
│           │ ⚠️ PARCIAL     │                                                             │ ⚠️ PARCIAL     │       │
│           │ Falta: nurse   │                                                             │ 12/35 módulos  │       │
│           │ en schedules,  │                                                             │ tienen acceso   │       │
│           │ billing, etc.  │                                                             │ más amplio en   │       │
│           │ Pharmacist vs  │                                                             │ backend que en  │       │
│           │ pharmacy bug   │                                                             │ frontend        │       │
│           └────────────────┘                                                             └────────────────┘       │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 DETALLE POR ROL: Dónde el Frontend y Backend Divergen

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROL: NURSE                                                                                                     │
│  ──────────                                                                                                     │
│  Backend Permisos (8):                                                                                          │
│    patients.view/create/edit, appointments.view/create/edit, clinical.view/create                                │
│    inventory.view/exits, studies.view, reports.view                                                             │
│                                                                                                                 │
│  Frontend Rutas:                                                                                                │
│    ✅ dashboard, patients, appointments, clinical-records, inventory                                             │
│    ✅ digital-signatures                                                                                         │
│    ❌ schedules         (backend: appointments.create → acceso a schedules)                                      │
│    ❌ studies           (backend: studies.view → pero no en FE route data)                                       │
│    ❌ reports           (backend: reports.view → pero no en FE route data)                                       │
│    ❌ waitlist          (backend: appointments.view → pero no en FE route data)                                  │
│    ❌ recurring-appts   (backend: appointments.create → pero no en FE route data)                                │
│    ❌ occupational      (backend: clinical.view/create → pero no en FE route data)                               │
│    ❌ call-center       (backend: appointments.view → pero no en FE route data)                                  │
│    ❌ document-templates(backend: clinical.view → pero no en FE route data)                                      │
│    ❌ cervical-screening(backend: clinical.view → pero no en FE route data)                                      │
│    ❌ echocardiography  (backend: clinical.view → pero no en FE route data)                                      │
│    ❌ implantable-dev   (backend: clinical.view → pero no en FE route data)                                      │
│                                                                                                                 │
│  👉 Nurse tiene 8 permisos en backend pero solo 6 módulos en frontend.                                          │
│     Faltan: schedules, studies, reports, waitlist, recurring, occupational,                                     │
│              call-center, doc-templates, cervical, echo, implantable.                                           │
│     (Algunos de estos probablemente son intencionales — nurse no necesita                                       │
│      gestionar horarios ni call center — pero el backend les da acceso.)                                        │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROL: RECEPTIONIST                                                                                              │
│  ─────────────────                                                                                              │
│  Backend Permisos (10):                                                                                         │
│    patients.view/create/edit, appointments.view/create/edit/cancel                                               │
│    clinical.view, billing.view/create/payments, reports.view                                                    │
│                                                                                                                 │
│  Frontend Rutas:                                                                                                │
│    ✅ dashboard, patients, appointments, billing, cashbox                                                         │
│    ✅ waitlist, recurring-appointments, communication, call-center                                               │
│    ❌ clinical-records  (backend: clinical.view → pero no en FE route data)                                      │
│    ❌ reports           (backend: reports.view → pero no en FE route data)                                       │
│    ❌ schedules         (backend: appointments.create → acceso a schedules)                                      │
│    ❌ tariffs           (backend: billing.view/create → pero no en FE route data)                                │
│    ❌ credit-notes      (backend: billing.view → pero no en FE route data)                                       │
│    ❌ electronic-invoicing (backend: billing.view → pero no en FE route data)                                    │
│    ❌ insurance-plans   (backend: billing.view → pero no en FE route data)                                       │
│                                                                                                                 │
│  👉 Receptionist tiene 10 permisos pero solo 9 módulos en frontend.                                             │
│     Faltan: clinical-records, reports, schedules, tariffs, credit-notes,                                        │
│              electronic-invoicing, insurance-plans.                                                              │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROL: DOCTOR                                                                                                    │
│  ───────────                                                                                                    │
│  Backend Permisos (17):                                                                                         │
│    patients.view/create/edit, appointments.view/create/edit, clinical.view/create/edit/sign                      │
│    billing.view, studies.view/create/sign, reports.view/generate                                                │
│    pharmacy.patient.view, staff.manage, lab.view/create                                                         │
│                                                                                                                 │
│  Frontend Rutas:                                                                                                │
│    ✅ dashboard, patients, appointments, clinical-records, studies, reports                                       │
│    ✅ rips, rips-v2, apedt, schedules, occupational, digital-signatures                                          │
│    ✅ cervical, echocardiography, implantable-devices, document-templates                                        │
│    ✅ doctor/staff, lab-import, overbooking, waitlist, recurring-appointments                                    │
│    ❌ billing            (backend: billing.view → pero no en FE route data)                                      │
│    ❌ pharmacy           (backend: pharmacy.patient.view → pero no en FE route data)                             │
│    ❌ insurance-plans    (backend: billing.view → pero no en FE route data)                                      │
│    ❌ tariffs            (backend: billing.view → pero no en FE route data)                                      │
│    ❌ cashbox            (backend: billing.view → pero no en FE route data)                                      │
│    ❌ credit-notes       (backend: billing.view → pero no en FE route data)                                      │
│    ❌ electronic-invoicing (backend: billing.view → pero no en FE route data)                                    │
│    ❌ communication      (backend: NO tiene communication.*)                                                     │
│    ❌ call-center        (backend: appointments.view → pero no en FE route data)                                 │
│    ❌ inventory          (backend: NO tiene inventory.*)                                                         │
│                                                                                                                 │
│  👉 Doctor tiene 17 permisos y 23+ módulos en frontend (el rol más completo).                                   │
│     Backend le da billing.view pero frontend no lo expone.                                                       │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROL: PHARMACIST                                                                                                │
│  ───────────────                                                                                                │
│  Backend Permisos (8):                                                                                          │
│    patients.view, clinical.view, inventory.*, billing.view, pharmacy.patient.view                                │
│                                                                                                                 │
│  Frontend Rutas:                                                                                                │
│    ✅ dashboard, pharmacy, inventory                                                                              │
│    ❌ patients           (backend: patients.view → pero no en FE route data)                                     │
│    ❌ clinical-records   (backend: clinical.view → pero no en FE route data)                                     │
│    ❌ billing            (backend: billing.view → pero no en FE route data)                                      │
│    ❌ reports            (backend: reports.view → pero no en FE route data)                                      │
│                                                                                                                 │
│  👉 Pharmacist tiene 8 permisos pero solo 3 módulos en frontend.                                                │
│     ⚠️  BUG: El JWT dice "pharmacy" pero FE checkea "pharmacist" — posiblemente                                │
│        NINGUNA ruta funciona para pharmacy a menos que se corrija el mapping.                                   │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROL: LAB TECH                                                                                                  │
│  ─────────────                                                                                                  │
│  Backend Permisos (7):                                                                                          │
│    patients.view, appointments.view, studies.*, lab.*, reports.view                                              │
│                                                                                                                 │
│  Frontend Rutas:                                                                                                │
│    ✅ dashboard, studies, lab-import                                                                              │
│    ❌ patients           (backend: patients.view → pero no en FE route data)                                     │
│    ❌ appointments       (backend: appointments.view → pero no en FE route data)                                 │
│    ❌ reports            (backend: reports.view → pero no en FE route data)                                      │
│                                                                                                                 │
│  👉 Lab tech tiene 7 permisos pero solo 3 módulos en frontend.                                                  │
│     ⚠️  BUG: El JWT dice "lab" pero FE checkea "lab_tech" — igual que pharmacy.                                │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROL: BILLING                                                                                                   │
│  ────────────                                                                                                   │
│  Backend Permisos (10):                                                                                         │
│    patients.view, appointments.view, billing.*, reports.*                                                        │
│                                                                                                                 │
│  Frontend Rutas:                                                                                                │
│    ✅ dashboard, billing, tariffs, cashbox, credit-notes, electronic-invoicing                                    │
│    ✅ rips, rips-v2, apedt, reports, insurance-plans                                                             │
│    ❌ patients           (backend: patients.view → pero no en FE route data)                                     │
│    ❌ appointments       (backend: appointments.view → pero no en FE route data)                                 │
│                                                                                                                 │
│  👉 Billing tiene 10 permisos y 11+ módulos en frontend.                                                        │
│     Backend le da patients.view y appointments.view pero frontend no los expone.                                │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ROL: ADMIN                                                                                                     │
│  ──────────                                                                                                     │
│  Backend Permisos (37 — TODOS):                                                                                 │
│    Admin tiene bypass automático en RequirePermission (línea 188, auth.go).                                     │
│                                                                                                                 │
│  Frontend Rutas:                                                                                                │
│    ✅ TODOS los módulos (admin, dashboard)                                                                        │
│    ❌ doctor/staff       (backend: staff.manage → pero FE solo doctor)                                           │
│                                                                                                                 │
│  👉 Admin tiene acceso a TODO. Solo falta la ruta /doctor/staff en el frontend                                  │
│     (admin podría gestionar personal de cualquier doctor pero FE no lo expone).                                 │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔀 SIDEBAR (navItems) vs ROUTES — Mapping Visual

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  FRONTEND: Qué ve cada rol en el sidebar vs qué rutas tiene acceso                                               │
│                                                                                                                 │
│  ADMIN:                     DOCTOR:                   NURSE:                   RECEPTIONIST:                    │
│  ─────                      ──────                    ─────                    ─────────────                    │
│  Panel Admin     ✅         Dashboard       ✅        Dashboard       ✅        Dashboard       ✅               │
│  Clientes        ✅         Mi Personal     ✅        Pacientes       ✅        Pacientes       ✅               │
│  Usuarios        ✅         Pacientes       ✅        Citas           ✅        Citas           ✅               │
│  Instituciones   ✅         Citas           ✅        H. Clínica      ✅        Facturación     ✅               │
│  Auditoría       ✅         Horarios        ✅        Firmas Digital  ✅        Caja            ✅               │
│  Feature Flags   ✅         H. Clínica      ✅        Inventario      ✅        L. Espera       ✅               │
│  Migraciones     ✅         Plantillas      ✅        ─               ─        C. Recurrentes  ✅               │
│  Test Email      ✅         Firmas Digital  ✅        [NO schedules]  ❌        Comunicaciones  ✅               │
│  Configuración   ✅         Estudios        ✅        [NO studies]    ❌        Call Center     ✅               │
│  Importaciones   ✅         Import. Lab     ✅        [NO reports]    ❌        ─               ─                │
│  [NO doctor/staff] ❌      M. Laboral      ✅        [NO waitlist]   ❌        [NO schedules]  ❌               │
│                             Citología CCV   ✅        [NO recurring]  ❌        [NO reports]    ❌               │
│                             Ecocardiografía ✅        [NO occupational]❌       [NO tariffs]    ❌               │
│                             Disp. Implant.  ✅        [NO CCV]        ❌        [NO credit-notes]❌              │
│                             L. Espera       ✅        [NO echo]       ❌        [NO e-invoicing]❌               │
│                             C. Recurrentes  ✅        [NO implant]    ❌        [NO insurance]   ❌               │
│                             Sobrecupo       ✅        [NO templates]  ❌        [NO H. Clínica]  ❌               │
│                             Facturación     ❌        [NO call center]❌                                         │
│                             RIPS            ✅                                                                  │
│                             RIPS v2         ✅        PHARMACIST:             LAB TECH:                          │
│                             APEDT 4505      ✅        ─────────               ────────                          │
│                             Reportes        ✅        Dashboard     ✅        Dashboard       ✅                 │
│                             [NO billing]    ❌        Farmacia POS   ✅        Estudios        ✅                 │
│                             [NO pharmacy]   ❌        Inventario     ✅        Import. Lab     ✅                 │
│                             [NO insurance]  ❌        [NO patients]  ❌        [NO patients]   ❌                 │
│                             [NO tariffs]    ❌        [NO clinical]  ❌        [NO appointments]❌                │
│                             [NO cashbox]    ❌        [NO billing]   ❌        [NO reports]     ❌                 │
│                             [NO e-invoicing]❌       [NO reports]   ❌                                          │
│                             [NO communication]❌                                                               │
│                             [NO call-center] ❌      BILLING:                                                 │
│                                                      ───────                                                  │
│                                                      Dashboard     ✅                                            │
│                                                      Facturación   ✅                                            │
│                                                      Caja          ✅                                            │
│                                                      Tarifarios    ✅                                            │
│                                                      Notas Crédito ✅                                            │
│                                                      Fact. Electr. ✅                                            │
│                                                      RIPS          ✅                                            │
│                                                      RIPS v2       ✅                                            │
│                                                      APEDT 4505    ✅                                            │
│                                                      Reportes      ✅                                            │
│                                                      P. de Seguro  ✅                                            │
│                                                      [NO patients] ❌                                            │
│                                                      [NO appts]    ❌                                            │
│                                                                                                                 │
│  LEYENDA:                                                                                                       │
│  ✅ = Aparece en sidebar y tiene ruta       ❌ = NO aparece en sidebar pero BACKEND permite acceso              │
│  ⚠️  = BUG de naming (pharmacist vs pharmacy, lab_tech vs lab) — posiblemente no funciona                      │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛡️ FLUJO DE AUTORIZACIÓN COMPLETO (DOBLE CAPA)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                           REQUEST LIFECYCLE — DOBLE VALIDACIÓN                                                   │
│                                                                                                                 │
│  USUARIO                FRONTEND (Angular)                         BACKEND (Go/Echo)                             │
│  ───────                ─────────────────                         ────────────────                              │
│                                                                                                                 │
│  Login ────────▶  POST /auth/login  ─────────────────────▶  Validar credenciales                               │
│                          │                                       │                                              │
│                          │                                ┌──────┴──────┐                                       │
│                          │                                │  Generar JWT │                                       │
│                          │                                │  role: "X"   │                                       │
│                          │                                │  facility_id │                                       │
│                          │                                └──────┬──────┘                                       │
│                          │                                       │                                              │
│                          ◀──────────────  JWT + Refresh  ───────┘                                              │
│                          │                                                                                      │
│                          ▼                                                                                      │
│                   ┌─────────────┐                                                                               │
│                   │ Guardar JWT  │                                                                              │
│                   │ localStorage │                                                                              │
│                   └──────┬──────┘                                                                               │
│                          │                                                                                      │
│                          ▼                                                                                      │
│                   ┌──────────────┐                                                                              │
│                   │ Decodificar   │  (sin verificar firma, solo extraer payload)                                │
│                   │ userRole()    │                                                                              │
│                   └──────┬───────┘                                                                              │
│                          │                                                                                      │
│         ┌────────────────┼────────────────┐                                                                     │
│         ▼                ▼                 ▼                                                                    │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────┐                                                            │
│  │ authGuard  │  │ session.svc  │  │ auth.        │                                                            │
│  │ hasRole()  │  │ navItems()   │  │ interceptor  │                                                            │
│  │ checkea    │  │ filtra       │  │ adjunta      │                                                            │
│  │ route.data │  │ sidebar      │  │ Bearer token │                                                            │
│  │ .roles     │  │              │  │              │                                                            │
│  └─────┬──────┘  └──────────────┘  └──────┬───────┘                                                            │
│        │                                   │                                                                    │
│        │          ┌────────────────────────┘                                                                    │
│        │          │                                                                                             │
│        ▼          ▼                                                                                             │
│   ┌─────────────────────┐                                                                                       │
│   │ HTTP Request → API  │  Authorization: Bearer <jwt>                                                          │
│   └─────────┬───────────┘                                                                                       │
│             │                                                                                                   │
│             ▼                                                                                                   │
│   ┌──────────────────────────────────────────────────────────────────────────────────────┐                      │
│   │                              BACKEND MIDDLEWARE STACK                                 │                      │
│   │                                                                                      │                      │
│   │  ① RequestID   →   ② Logger   →   ③ Recover   →   ④ CORS   →   ⑤ Error              │                      │
│   │                                                                                      │                      │
│   │  ⑥ mw.Auth(cfg.JWT.Secret)                                                          │                      │
│   │     ├── Extraer Bearer token                                                         │                      │
│   │     ├── Validar firma HMAC-SHA256                                                    │                      │
│   │     ├── Check blacklist (logout)                                                     │                      │
│   │     ├── Extraer claims → c.Set("user_role", "doctor")                               │                      │
│   │     ├── Extraer claims → c.Set("user_id", 5)                                        │                      │
│   │     ├── Extraer claims → c.Set("facility_id", 1)                                    │                      │
│   │     ├── Set tenant_id en context                                                     │                      │
│   │     └── Force password change check                                                  │                      │
│   │                                                                                      │                      │
│   │  ⑦ mw.RequireRole("admin", "billing", "doctor")  ← Algunas rutas (RIPS, APEDT)     │                      │
│   │     └── Compara c.Get("user_role") con la lista                                      │                      │
│   │                                                                                      │                      │
│   │  ⑧ mw.RequirePermission("clinical.create")  ← La mayoría de rutas                   │                      │
│   │     ├── Si role == "admin" → bypass automático (línea 160)                           │                      │
│   │     ├── Si hay rbacService → DB check (tabla user_permissions)                       │                      │
│   │     └── Fallback → defaultRolePermissions[role] (hardcoded map)                      │                      │
│   │                                                                                      │                      │
│   │  ⑨ Handler → Parse DTO → Validate → UseCase → Repository                           │                      │
│   │                                                                                      │                      │
│   └──────────────────────────────────────────────────────────────────────────────────────┘                      │
│                                                                                                                 │
│  PUNTOS DE VALIDACIÓN:                                                                                          │
│  ┌──────────────────────────────┬──────────────────────────────────────────────────────┐                        │
│  │ CAPA          │ QUÉ VALIDA   │ DÓNDE                                                │                        │
│  ├───────────────┼──────────────┼──────────────────────────────────────────────────────┤                        │
│  │ Frontend      │ Roles        │ authGuard → route.data.roles vs userRole()           │                        │
│  │ (Angular)     │              │ session.service → navItems filter                     │                        │
│  │               │              │ ⚠️ SOLO COSMÉTICO — no es seguridad real             │                        │
│  ├───────────────┼──────────────┼──────────────────────────────────────────────────────┤                        │
│  │ Backend       │ JWT          │ mw.Auth() → firma, expiración, blacklist            │                        │
│  │ (Go)          │ Roles        │ mw.RequireRole() → comparación directa               │                        │
│  │               │ Permisos     │ mw.RequirePermission() → DB + fallback map           │                        │
│  │               │              │ 🔒 SEGURIDAD REAL — es la capa de enforcement        │                        │
│  └───────────────┴──────────────┴──────────────────────────────────────────────────────┘                        │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 RECOMENDACIONES Y ACCIONES

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                         PLAN DE CORRECCIÓN                                                       │
│                                                                                                                 │
│  🔴 CRÍTICO — BUGS DE NAMING                                                                                    │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ 1. Unificar nombres de rol en TODOS los layers:                                                           │   │
│  │    Opción A: Usar "pharmacist" y "lab_tech" en backend                                                     │   │
│  │      • Cambiar defaultRolePermissions keys: "pharmacy" → "pharmacist", "lab" → "lab_tech"                  │   │
│  │      • Cambiar roleNameMapping (o eliminarlo)                                                              │   │
│  │      • Cambiar DB seed data                                                                                 │   │
│  │                                                                                                            │   │
│  │    Opción B: Agregar mapping en frontend (menos disruptivo):                                               │   │
│  │      • Crear ROLE_MAPPING en auth.service.ts:                                                               │   │
│  │        { "pharmacy": "pharmacist", "lab": "lab_tech" }                                                      │   │
│  │      • hasRole() normaliza antes de comparar                                                               │   │
│  │      • session.service navItems también normaliza                                                           │   │
│  │                                                                                                            │   │
│  │    ⚠️  SIN ESTE FIX: pharmacist y lab_tech NO pueden acceder a NINGUNA ruta protegida.                    │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  🟡 MEDIO — DIVERGENCIAS DE ACCESO                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ 2. Nurse: Agregar acceso a reports, schedules, studies en FE (si aplica)                                   │   │
│  │ 3. Doctor: Agregar acceso a billing view en FE                                                            │   │
│  │ 4. Receptionist: Agregar clinical-records view en FE                                                       │   │
│  │ 5. Pharmacist: Agregar patients view, clinical view, billing view, reports view en FE                      │   │
│  │ 6. Lab tech: Agregar patients view, appointments view, reports view en FE                                  │   │
│  │ 7. Billing: Agregar patients view, appointments view en FE                                                 │   │
│  │                                                                                                            │   │
│  │ NOTA: Algunas divergencias pueden ser intencionales (frontend deliberadamente                             │   │
│  │       más restrictivo que backend). Revisar con el equipo de producto.                                     │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  🟢 OK — SIN PROBLEMAS                                                                                          │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ 8. Admin, billing, patient portal, public routes — alineados correctamente                                 │   │
│  │ 9. Flujo de auth dual (staff + patient) — consistente                                                       │   │
│  │ 10. Sistema de permisos con fallback — robusto                                                              │   │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
