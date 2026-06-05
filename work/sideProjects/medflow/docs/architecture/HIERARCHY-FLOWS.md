# MedNext — Jerarquía Completa: Roles · Clientes · Flujos

```
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                           MEDNEXT HIERARCHY — ADMIN → CLIENT → DOCTOR → STAFF                                   ║
║                              SaaS Multi-Tenant · RBAC · Flujos Frontend ↔ Backend                               ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
```

---

## 🌳 ÁRBOL DE JERARQUÍA COMPLETO

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                         MEDNEXT SAAS HIERARCHY                                                  │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                     PLATFORM ADMIN (SaaS)                                               │   │
│  │                              admin@mednext.com · Rol: admin                                              │   │
│  │                                                                                                         │   │
│  │  Sidebar: [Panel Admin] [Clientes] [Usuarios] [Auditoría] [Configuración]                               │   │
│  │                                                                                                         │   │
│  │  ┌──────────────────────────────────────────────────────────────────────────────────────────────────┐   │   │
│  │  │                                CLIENTES (Tenants / IPS)                                           │   │   │
│  │  │                     Panel Admin → Clientes → [Crear Cliente]                                      │   │   │
│  │  │                                                                                                  │   │   │
│  │  │  Cada cliente tiene:                                                                             │   │   │
│  │  │  ┌───────────────────────────────────────────────────────────────────────────────────────────┐   │   │   │
│  │  │  │ CLIENTE: "Clínica del Valle" (tenant_id=5)                                                │   │   │   │
│  │  │  │                                                                                           │   │   │   │
│  │  │  │  Tabs: [Datos Básicos] [Puntos de Atención] [Documentos] [Usuarios] [Config. Comercial]   │   │   │   │
│  │  │  │                                                                                           │   │   │   │
│  │  │  │  ┌──────────────────────────────────────────────────────────────────────────────────┐    │   │   │   │
│  │  │  │  │ PUNTOS DE ATENCIÓN (Sedes / Facilities)                                          │    │   │   │   │
│  │  │  │  │                                                                                  │    │   │   │   │
│  │  │  │  │  ├── Sede Principal (facility_id=10)                                             │    │   │   │   │
│  │  │  │  │  ├── Sede Norte (facility_id=11)                                                 │    │   │   │   │
│  │  │  │  │  └── Sede Sur (facility_id=12)                                                   │    │   │   │   │
│  │  │  │  └──────────────────────────────────────────────────────────────────────────────────┘    │   │   │   │
│  │  │  │                                                                                           │   │   │   │
│  │  │  │  ┌──────────────────────────────────────────────────────────────────────────────────┐    │   │   │   │
│  │  │  │  │ USUARIOS ASOCIADOS (facility_id → sede)                                          │    │   │   │   │
│  │  │  │  │                                                                                  │    │   │   │   │
│  │  │  │  │  ┌─────────────────────────────────────────────────────────────────────────┐    │    │   │   │   │
│  │  │  │  │  │  DOCTOR (⭐4)     ← Admin crea usuarios vía /admin/users                │    │    │   │   │   │
│  │  │  │  │  │  doctor@clinic.com  facility_id=10                                       │    │    │   │   │   │
│  │  │  │  │  │                                                                          │    │    │   │   │   │
│  │  │  │  │  │  Sidebar: [Dashboard] [Mi Personal] [Pacientes] [Citas] [Horarios]      │    │    │   │   │   │
│  │  │  │  │  │           [H. Clínica] [Estudios] [RIPS] [Reportes] [Plantillas]...      │    │    │   │   │   │
│  │  │  │  │  │                                                                          │    │    │   │   │   │
│  │  │  │  │  │  ┌──────────────────────────────────────────────────────────────────┐   │    │    │   │   │   │
│  │  │  │  │  │  │  MI PERSONAL (Doctor Staff)                                       │   │    │    │   │   │   │
│  │  │  │  │  │  │  /doctor/staff → RequirePermission("staff.manage")                │   │    │    │   │   │   │
│  │  │  │  │  │  │                                                                   │   │    │    │   │   │   │
│  │  │  │  │  │  │  Doctor crea/edita/elimina:                                       │   │    │    │   │   │   │
│  │  │  │  │  │  │  ├── RECEPTIONIST (⭐2½)  ← doctor_id = doctor                     │   │    │    │   │   │   │
│  │  │  │  │  │  │  │   recepcion@clinic.com  facility_id=10                         │   │    │    │   │   │   │
│  │  │  │  │  │  │  │                                                               │   │    │    │   │   │   │
│  │  │  │  │  │  │  │   Sidebar: [Dashboard] [Pacientes] [Citas] [Facturación]       │   │    │    │   │   │   │
│  │  │  │  │  │  │  │            [Caja] [L. Espera] [C. Recurrentes]                 │   │    │    │   │   │   │
│  │  │  │  │  │  │  │            [Comunicaciones] [Call Center]                       │   │    │    │   │   │   │
│  │  │  │  │  │  │  │                                                               │   │    │    │   │   │   │
│  │  │  │  │  │  │  └── NURSE (⭐3)        ← doctor_id = doctor                       │   │    │    │   │   │   │
│  │  │  │  │  │  │      nurse@clinic.com   facility_id=10                             │   │    │    │   │   │   │
│  │  │  │  │  │  │                                                                   │   │    │    │   │   │   │
│  │  │  │  │  │  │      Sidebar: [Dashboard] [Pacientes] [Citas] [H. Clínica]         │   │    │    │   │   │   │
│  │  │  │  │  │  │               [Firmas Digitales] [Inventario]                      │   │    │    │   │   │   │
│  │  │  │  │  │  └──────────────────────────────────────────────────────────────────┘   │    │    │   │   │   │
│  │  │  │  │  └─────────────────────────────────────────────────────────────────────────┘    │    │   │   │   │
│  │  │  │  │                                                                                  │    │   │   │   │
│  │  │  │  │  ┌─────────────────────────────────────────────────────────────────────────┐    │    │   │   │   │
│  │  │  │  │  │  PHARMACIST (⭐2)   ← Admin crea directamente                            │    │    │   │   │   │
│  │  │  │  │  │  farmacia@clinic.com  facility_id=10                                     │    │    │   │   │   │
│  │  │  │  │  │  Sidebar: [Dashboard] [Farmacia POS] [Inventario]                        │    │    │   │   │   │
│  │  │  │  │  └─────────────────────────────────────────────────────────────────────────┘    │    │   │   │   │
│  │  │  │  │                                                                                  │    │   │   │   │
│  │  │  │  │  ┌─────────────────────────────────────────────────────────────────────────┐    │    │   │   │   │
│  │  │  │  │  │  LAB TECH (⭐1)     ← Admin crea directamente                             │    │    │   │   │   │
│  │  │  │  │  │  lab@clinic.com      facility_id=10                                      │    │    │   │   │   │
│  │  │  │  │  │  Sidebar: [Dashboard] [Estudios] [Import. Lab]                           │    │    │   │   │   │
│  │  │  │  │  └─────────────────────────────────────────────────────────────────────────┘    │    │   │   │   │
│  │  │  │  │                                                                                  │    │   │   │   │
│  │  │  │  │  ┌─────────────────────────────────────────────────────────────────────────┐    │    │   │   │   │
│  │  │  │  │  │  BILLING (⭐2½)     ← Admin crea directamente                             │    │    │   │   │   │
│  │  │  │  │  │  facturacion@clinic.com  facility_id=10                                  │    │    │   │   │   │
│  │  │  │  │  │  Sidebar: [Dashboard] [Facturación] [Caja] [Tarifarios] [Notas Crédito]  │    │    │   │   │   │
│  │  │  │  │  │           [Fact. Electrónica] [RIPS] [RIPS v2] [APEDT] [Reportes]       │    │    │   │   │   │
│  │  │  │  │  └─────────────────────────────────────────────────────────────────────────┘    │    │   │   │   │
│  │  │  │  └──────────────────────────────────────────────────────────────────────────────────┘    │   │   │   │
│  │  │  └───────────────────────────────────────────────────────────────────────────────────────────┘   │   │   │
│  │  └──────────────────────────────────────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │                                     PATIENT PORTAL (Separado)                                           │   │
│  │                                                                                                         │   │
│  │  Pacientes se registran solos vía /patient-portal/register                                              │   │
│  │  Auth independiente: PatientAuth JWT                                                                    │   │
│  │  Sidebar: [Dashboard] [Buscar Médico] [Mis Citas] [Mis Fórmulas] [Perfil]                               │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 FLUJO: Admin crea Cliente + Usuarios

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  FLOW: ADMIN → CREATE CLIENT → CREATE USERS                                                                    │
│                                                                                                                 │
│  FRONTEND (Angular)                                          BACKEND (Go/Echo)                                  │
│  ─────────────────                                           ────────────────                                  │
│                                                                                                                 │
│  ┌──────────────────────┐                                    ┌──────────────────────┐                          │
│  │ Admin Login           │                                    │ POST /auth/login      │                          │
│  │ admin@mednext.com     │ ──── JWT (role=admin) ──────────▶ │ → JWT + Refresh       │                          │
│  └──────────┬───────────┘                                    └──────────────────────┘                          │
│             │                                                                                                   │
│             ▼                                                                                                   │
│  ┌──────────────────────┐                                                                                      │
│  │ Sidebar: Clientes     │                                                                                      │
│  │ → /admin/clients      │                                                                                      │
│  └──────────┬───────────┘                                                                                      │
│             │                                                                                                   │
│             ▼                                                                                                   │
│  ┌──────────────────────┐                                    ┌──────────────────────┐                          │
│  │ ClientsListComponent  │                                    │ GET /admin/clients    │                          │
│  │ "Nuevo Cliente"       │ ──── POST ──────────────────────▶ │ POST /admin/clients   │                          │
│  │  name: Clínica Norte   │                                    │ → ClientUseCase       │                          │
│  │  slug: clinica-norte   │                                    │   INSERT INTO clients │                          │
│  │  document_number: ...  │                                    │   RETURN client {id:5}│                          │
│  │  contact_name: ...     │                                    └──────────────────────┘                          │
│  └──────────┬───────────┘                                                                                      │
│             │                                                                                                   │
│             ▼                                                                                                   │
│  ┌──────────────────────┐                                                                                      │
│  │ Client Detail (id=5)  │                                                                                      │
│  │ Tab: Datos Básicos    │ ◀── Editar nombre, contacto, dirección, estado                                      │
│  │ Tab: Puntos Atención  │ ◀── GET /admin/clients/5/facilities → tabla de sedes                                │
│  │ Tab: Documentos        │ ◀── GET/POST /admin/clients/5/documents → CRUD docs                                │
│  │ Tab: Usuarios          │ ◀── GET /admin/users?facility_id=10&page_size=100 → tabla de usuarios              │
│  │ Tab: Config Comercial  │ ◀── GET/PUT /admin/clients/5/commercial-config                                     │
│  └──────────┬───────────┘                                                                                      │
│             │                                                                                                   │
│             ▼                                                                                                   │
│  ┌──────────────────────┐                                    ┌──────────────────────┐                          │
│  │ Admin → Usuarios      │                                    │ GET /admin/users      │                          │
│  │ → /admin/users         │                                    │ ?role=doctor          │                          │
│  │                         │                                    │ &facility_id=10       │                          │
│  │ "Crear Usuario"        │ ──── POST ──────────────────────▶ │ POST /admin/users     │                          │
│  │  username: dr.garcia   │                                    │ → AdminUseCase         │                          │
│  │  email: dr@clinic.com  │                                    │   bcrypt(password)     │                          │
│  │  role: doctor          │                                    │   INSERT INTO users    │                          │
│  │  facility_id: 10       │                                    │   RETURN user          │                          │
│  │  doctor_id: (vacío)    │                                    └──────────────────────┘                          │
│  └──────────────────────┘                                                                                      │
│                                                                                                                 │
│  ⚠️  NOTA: El facility_id en la creación de usuario asigna el usuario a una sede específica.                   │
│     Para asignar un doctor como "dueño" de staff, se usa doctor_id en el formulario de creación.               │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 FLUJO: Doctor gestiona su Staff

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  FLOW: DOCTOR → STAFF MANAGEMENT                                                                                │
│                                                                                                                 │
│  FRONTEND (Angular)                                          BACKEND (Go/Echo)                                  │
│  ─────────────────                                           ────────────────                                  │
│                                                                                                                 │
│  ┌──────────────────────┐                                    ┌──────────────────────┐                          │
│  │ Doctor Login          │                                    │ POST /auth/login      │                          │
│  │ doctor@clinic.com     │ ──── JWT (role=doctor,           │ → doctor_id en claims  │                          │
│  │                        │       doctor_id=3) ────────────▶ │   facility_id=10      │                          │
│  └──────────┬───────────┘                                    └──────────────────────┘                          │
│             │                                                                                                   │
│             ▼                                                                                                   │
│  ┌──────────────────────┐                                                                                      │
│  │ Sidebar: Mi Personal  │                                                                                      │
│  │ → /doctor/staff        │                                                                                      │
│  └──────────┬───────────┘                                                                                      │
│             │                                                                                                   │
│             ▼                                                                                                   │
│  ┌──────────────────────┐                                    ┌──────────────────────┐                          │
│  │ StaffListComponent    │                                    │ GET /doctor/staff     │                          │
│  │ "Nuevo Miembro"       │ ──── POST ──────────────────────▶ │ POST /doctor/staff    │                          │
│  │  first_name: María     │                                    │ → DoctorStaffUseCase  │                          │
│  │  last_name: López      │                                    │   Auto: doctor_id=3   │                          │
│  │  role: receptionist    │                                    │   Auto: facility_id=10│                          │
│  │  username: maria.l     │                                    │   INSERT INTO users   │                          │
│  │  password: ****        │                                    │   RETURN user          │                          │
│  └──────────────────────┘                                    └──────────────────────┘                          │
│                                                                                                                 │
│  🔑 Doctor puede:                                                                                              │
│  • Crear receptionists y nurses (solo esos 2 roles)                                                            │
│  • Editar datos de su staff                                                                                    │
│  • Resetear contraseñas                                                                                        │
│  • Activar/desactivar miembros                                                                                 │
│  • Eliminar miembros                                                                                           │
│                                                                                                                 │
│  🚫 Doctor NO puede:                                                                                           │
│  • Crear otros doctores (solo admin)                                                                           │
│  • Ver staff de otros doctores                                                                                 │
│  • Crear pharmacists, lab_tech, billing (solo admin)                                                           │
│                                                                                                                 │
│  📍 El staff creado hereda:                                                                                    │
│  • facility_id del doctor                                                                                      │
│  • doctor_id del doctor (jerarquía)                                                                            │
│  • Tenant scoping automático vía repository.WithTenant()                                                       │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🗺️ MAPA DE RUTAS POR ROL (Frontend Route Data)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROL          │ RUTAS ACCESIBLES (determinado por route.data.roles)                                             │
├───────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────┤
│               │                                                                                                 │
│  ADMIN        │ /admin/* (dashboard, clients, users, audit-log, settings), /imports                            │
│  (SaaS)       │ SIN acceso a módulos clínicos (pacientes, citas, etc.)                                         │
│               │                                                                                                 │
│  DOCTOR       │ /dashboard, /patients, /appointments, /schedules, /clinical-records,                           │
│  (Clínica)    │ /studies, /rips/*, /apedt, /reports, /doctor/staff, /occupational,                            │
│               │ /cervical-screening, /echocardiography, /implantable-devices,                                  │
│               │ /document-templates, /digital-signatures, /lab-import,                                         │
│               │ /waitlist, /recurring-appointments, /overbooking                                               │
│               │                                                                                                 │
│  NURSE        │ /dashboard, /patients, /appointments, /clinical-records,                                       │
│  (Clínica)    │ /inventory, /digital-signatures                                                                │
│               │                                                                                                 │
│  RECEPTIONIST │ /dashboard, /patients, /appointments, /billing, /cashbox,                                      │
│  (Clínica)    │ /waitlist, /recurring-appointments, /communication, /call-center                               │
│               │                                                                                                 │
│  PHARMACIST   │ /dashboard, /pharmacy, /inventory                                                              │
│  (Clínica)    │                                                                                                 │
│               │                                                                                                 │
│  LAB TECH     │ /dashboard, /studies, /lab-import                                                              │
│  (Clínica)    │                                                                                                 │
│               │                                                                                                 │
│  BILLING      │ /dashboard, /billing, /tariffs, /cashbox, /credit-notes,                                       │
│  (Clínica)    │ /electronic-invoicing, /rips/*, /apedt, /reports, /insurance-plans                             │
│               │                                                                                                 │
│  PATIENT      │ /patient-portal/* (dashboard, appointments, book, reviews, profile,                            │
│  (Portal)     │ settings, prescriptions, medical-orders, incapacities, referrals)                              │
│               │                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔀 FLUJO COMPLETO: Admin Sidebar + Navegación

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ADMIN SIDEBAR — session.service.ts > getStaffNavItems()                                                        │
│                                                                                                                 │
│  ┌─────────────────────────┐                                                                                    │
│  │  🏠 Panel Admin         │ → /admin/dashboard                                                                 │
│  │  🏢 Clientes            │ → /admin/clients                                                                   │
│  │     └── Cliente Detail  │ → /admin/clients/:id                                                               │
│  │         ├── Datos Basicos│   (editar nombre, contacto, dirección)                                            │
│  │         ├── Puntos Atenc│   (tabla de sedes del cliente)                                                     │
│  │         ├── Documentos   │   (CRUD docs: RUT, Cámara Comercio, etc.)                                         │
│  │         ├── Usuarios     │   👈 AHORA FUNCIONAL — tabla de usuarios filtrados por facility_id                │
│  │         └── Config Comer│   (modelo facturación, precio sesión, plan)                                        │
│  │  👥 Usuarios            │ → /admin/users                                                                     │
│  │     └── Crear/Editar     │   (username, email, role, facility_id, doctor_id)                                 │
│  │  📋 Logs de Auditoría   │ → /admin/audit-log                                                                 │
│  │  ⚙️  Configuración      │ → /admin/settings                                                                  │
│  └─────────────────────────┘                                                                                    │
│                                                                                                                 │
│  🚫 REMOVIDOS del sidebar (no operacionales):                                                                   │
│  • Instituciones (→ integrado en Clientes > Puntos de Atención)                                                │
│  • Feature Flags (→ herramienta de desarrollo)                                                                  │
│  • Migraciones (→ herramienta one-time)                                                                         │
│  • Test Email (→ herramienta de desarrollo)                                                                     │
│                                                                                                                 │
│  Rutas aún accesibles vía URL directa (no en sidebar):                                                          │
│  /admin/facilities, /admin/feature-flags, /admin/migrations, /admin/email-test                                  │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🛡️ TENANT SCOPING — Multi-Tenancy

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  TENANT ISOLATION (facility_id)                                                                                 │
│                                                                                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ JWT contiene facility_id=X                                                                              │   │
│  │   ↓                                                                                                     │   │
│  │ Middleware Auth(): repository.WithTenant(ctx, facilityID)                                               │   │
│  │   ↓                                                                                                     │   │
│  │ Todos los queries SQL se ejecutan con tenant_id=X                                                       │   │
│  │   ↓                                                                                                     │   │
│  │ Cada clínica/cliente ve SOLO sus propios datos                                                          │   │
│  └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                                                 │
│  EJEMPLO:                                                                                                       │
│  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │ Doctor de "Clínica del Valle" (facility_id=10) → GET /patients → solo pacientes de facility 10           │  │
│  │ Doctor de "Clínica Norte" (facility_id=20) → GET /patients → solo pacientes de facility 20               │  │
│  │ Admin SaaS (facility_id=1) → GET /admin/users → todos los usuarios (global)                              │  │
│  └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 RESUMEN DE CAPACIDADES POR ROL

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ACCIÓN                        │ ADMIN │ DOCTOR │ NURSE │ RECEPT │ PHARM │ LAB │ BILLING │ PATIENT            │
├────────────────────────────────┼───────┼────────┼───────┼────────┼───────┼─────┼─────────┼────────────────────┤
│  Crear clientes (tenants)      │  ✅   │        │       │        │       │     │         │                    │
│  Gestionar usuarios (global)   │  ✅   │        │       │        │       │     │         │                    │
│  Gestionar mi staff            │  ✅   │   ✅   │       │        │       │     │         │                    │
│  Ver/crear pacientes           │  ✅   │   ✅   │  ✅   │   ✅   │  ✅   │ ✅  │   ✅    │                    │
│  Historia clínica completa     │  ✅   │   ✅   │  ✅   │   ✅   │  ✅   │     │         │                    │
│  Firmar eventos clínicos       │  ✅   │   ✅   │       │        │       │     │         │                    │
│  Crear/editar citas            │  ✅   │   ✅   │  ✅   │   ✅   │       │     │         │  ✅ (self-book)     │
│  Facturación y pagos           │  ✅   │   ✅   │       │   ✅   │  ✅   │     │   ✅    │                    │
│  Inventario                    │  ✅   │        │  ✅   │        │  ✅   │     │         │                    │
│  Farmacia POS                  │  ✅   │   ✅   │       │        │  ✅   │     │         │                    │
│  Estudios de laboratorio       │  ✅   │   ✅   │  ✅   │        │       │ ✅  │         │                    │
│  RIPS / APEDT                  │  ✅   │   ✅   │       │        │       │     │   ✅    │                    │
│  Reportes y estadísticas       │  ✅   │   ✅   │  ✅   │   ✅   │  ✅   │ ✅  │   ✅    │                    │
│  Auditoría del sistema         │  ✅   │        │       │        │       │     │         │                    │
│  Configuración del sistema     │  ✅   │        │       │        │       │     │         │                    │
│  Portal del paciente           │       │        │       │        │       │     │         │  ✅                │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
