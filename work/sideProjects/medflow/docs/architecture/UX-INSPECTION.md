# MedNext — Inspección de Casos de Uso, CRUD, Visibilidad y Flujos UX

```
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                    UX INSPECTION — Casos de Uso · CRUD · Flujos · Accesibilidad                                 ║
║                              Análisis por rol, módulo y pantalla                                                ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
```

---

## 📊 MATRIZ CRUD POR ROL

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  MÓDULO              │ ADMIN │ DOCTOR │ NURSE │ RECEPT. │ PHARM. │ LAB │ BILLING │ PATIENT │                   │
├──────────────────────┼───────┼────────┼───────┼─────────┼────────┼─────┼─────────┼─────────┤                   │
│  Pacientes           │ CRUD  │ CRUD   │ CRU-  │ CRU-    │ R----- │ R--  │ R-----  │ -----   │                   │
│  Citas               │ CRUD  │ CRUD   │ CRU-  │ CRUD    │ -----  │ R--  │ R-----  │ -R-D (p)│                   │
│  Horarios            │ CRUD  │ CRUD   │ ----- │ R-----  │ -----  │ ---  │ -----   │ -----   │                   │
│  Historia Clínica    │ CRUD  │ CRUD   │ CR--  │ R-----  │ R----- │ ---  │ -----   │ -----   │                   │
│  Plantillas          │ ---   │ CRUD   │ ----- │ -----   │ -----  │ ---  │ -----   │ -----   │                   │
│  Firmas Digitales    │ CRUD  │ CRUD   │ CR--  │ -----   │ -----  │ ---  │ -----   │ -----   │                   │
│  Estudios            │ CRUD  │ CRU-   │ R---- │ -----   │ -----  │ CRUD │ -----   │ -----   │                   │
│  Import. Lab         │ CRUD  │ -----  │ ----- │ -----   │ -----  │ CRUD │ -----   │ -----   │                   │
│  Facturación         │ CRUD  │ R----  │ ----- │ CR--    │ R----- │ ---  │ CRUD    │ -----   │                   │
│  Caja                │ CRUD  │ -----  │ ----- │ CR--    │ -----  │ ---  │ CRUD    │ -----   │                   │
│  Tarifarios          │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ CRUD    │ -----   │                   │
│  Notas Crédito       │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ CRUD    │ -----   │                   │
│  Fact. Electrónica   │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ CRUD    │ -----   │                   │
│  RIPS / APEDT        │ CRUD  │ CRUD   │ ----- │ -----   │ -----  │ ---  │ CRUD    │ -----   │                   │
│  Reportes            │ RUD   │ RU-    │ R---- │ R-----  │ R----- │ R--  │ RUD     │ -----   │                   │
│  Planes de Seguro    │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ CRUD    │ -----   │                   │
│  Inventario          │ CRUD  │ -----  │ R--D  │ -----   │ CRUD  │ ---  │ -----   │ -----   │                   │
│  Farmacia POS        │ CRUD  │ R----  │ ----- │ -----   │ CRUD  │ ---  │ -----   │ -----   │                   │
│  Comunicaciones      │ CRUD  │ -----  │ ----- │ CR--    │ -----  │ ---  │ -----   │ -----   │                   │
│  Call Center         │ CRUD  │ -----  │ ----- │ CRUD    │ -----  │ ---  │ -----   │ -----   │                   │
│  Lista de Espera     │ CRUD  │ CRUD   │ ----- │ CRUD    │ -----  │ ---  │ -----   │ -----   │                   │
│  Citas Recurrentes   │ CRUD  │ CRUD   │ ----- │ CRUD    │ -----  │ ---  │ -----   │ -----   │                   │
│  Sobrecupo           │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ -----   │ -----   │                   │
│  Mi Personal         │ CRUD  │ CRUD   │ ----- │ -----   │ -----  │ ---  │ -----   │ -----   │                   │
│  Admin (usuarios)    │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ -----   │ -----   │                   │
│  Admin (clientes)    │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ -----   │ -----   │                   │
│  Configuración       │ CRUD  │ -----  │ ----- │ -----   │ -----  │ ---  │ -----   │ -----   │                   │
│                                                                                                                 │
│  C=Create R=Read U=Update D=Delete -=no access  (p)=patient portal only                                         │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔍 INSPECCIÓN POR ROL

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  🩺 DOCTOR (15 sidebar items)                                                                                   │
│                                                                                                                 │
│  PANTALLAS INSPECCIONADAS: Dashboard, Pacientes, Registros Clínicos, Citas                                     │
│                                                                                                                 │
│  ✅ FORTALEZAS:                                                                                                 │
│  • Dashboard excelente: 4 KPIs + 7 quick actions + Citas de Hoy + Pacientes Recientes                          │
│  • Quick actions reducen clicks: Nueva Cita, Buscar Paciente, Nuevo Evento desde dashboard                     │
│  • Lista de pacientes con avatar, documento, contacto, edad, estado — bien organizada                          │
│  • Registros clínicos muestra tipo (Consulta/Control/Urgencia), estado (Borrador/Firmado), fecha               │
│  • Sidebar con 15 items (ya optimizado de 21)                                                                   │
│                                                                                                                 │
│  ⚠️  MEJORAS PENDIENTES:                                                                                       │
│  • 517,489 registros clínicos — filtro por rango de fechas no visible en snapshot                              │
│  • Pacientes recientes muestra datos migrados con nombres extraños (888nombre, LA LENA) — data cleanup needed  │
│  • Duplicados en registros clínicos (mismo paciente, misma fecha, múltiples registros "Migrado de SistemaMED") │
│  • "Nuevo Evento" desde dashboard → ¿abre modal o navega a otra página? (debería ser modal rápido)             │
│  • Sin acceso rápido a signos vitales del paciente desde la lista de pacientes                                 │
│  • RIPS/RIPS v2/APEDT son 3 items separados — podrían agruparse bajo "Reportes Regulatorios"                  │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🏥 NURSE (7 sidebar items)                                                                                     │
│                                                                                                                 │
│  ⚠️  MEJORAS PENDIENTES:                                                                                       │
│  • Nurse ve Inventario pero no Farmacia POS — correcto (inventario != farmacia)                                │
│  • Nurse NO ve signos vitales como módulo separado — los signos vitales están dentro de clinical-records       │
│  • Nurse debería tener un dashboard con "Pacientes asignados hoy" y "Toma de signos pendiente"                 │
│  • Falta acceso rápido a crear evento clínico desde dashboard (nurse tiene clinical.create)                    │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  📞 RECEPTIONIST (10 sidebar items)                                                                             │
│                                                                                                                 │
│  ✅ FORTALEZAS:                                                                                                 │
│  • Tiene acceso a Facturación + Caja (cobra consultas)                                                         │
│  • Tiene Comunicaciones + Call Center (gestiona llamadas entrantes)                                            │
│  • Tiene Horarios (crea citas → necesita ver disponibilidad)                                                   │
│                                                                                                                 │
│  ⚠️  MEJORAS PENDIENTES:                                                                                       │
│  • Receptionist NO ve Historia Clínica en sidebar (aunque backend da clinical.view) — correcto clínicamente    │
│  • Dashboard de receptionist debería mostrar: Citas de hoy, Llamadas pendientes, Facturación del día           │
│  • Al crear cita, debería poder ver disponibilidad del doctor en el mismo formulario (no ir a Horarios)        │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  💊 PHARMACIST (4 sidebar items)                                                                                │
│                                                                                                                 │
│  ✅ FORTALEZAS:                                                                                                 │
│  • Farmacia POS funcional con tabla de ventas, filtros, stats                                                  │
│  • Inventario separado con entradas/salidas/ajustes                                                            │
│  • Dashboard muestra Stock Bajo (KPI relevante)                                                                 │
│                                                                                                                 │
│  ⚠️  MEJORAS PENDIENTES:                                                                                       │
│  • Dashboard de pharmacist podría incluir "Ventas del día" y "Medicamentos próximos a vencer"                  │
│  • Falta botón rápido "Nueva Venta" desde el dashboard                                                        │
│  • Pharmacist ve pacientes pero solo con pharmacy.patient.view (datos limitados) — debería poder buscar        │
│    paciente por documento para asociar venta                                                                   │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🔬 LAB TECH (4 sidebar items)                                                                                  │
│                                                                                                                 │
│  ⚠️  MEJORAS PENDIENTES:                                                                                       │
│  • Dashboard no muestra "Estudios pendientes" — sería el KPI más importante                                    │
│  • Falta botón rápido "Nuevo Estudio" / "Importar Resultados" desde dashboard                                 │
│  • Lab tech ve pacientes pero rara vez necesita buscar — el flujo es paciente→estudio, no al revés             │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  💰 BILLING (11 sidebar items)                                                                                  │
│                                                                                                                 │
│  ✅ FORTALEZAS:                                                                                                 │
│  • Módulo más completo del sistema financiero                                                                  │
│  • Flujo: Cuenta → Items → Pagos → Cierre → Factura → DIAN                                                     │
│                                                                                                                 │
│  ⚠️  MEJORAS PENDIENTES:                                                                                       │
│  • Dashboard debería mostrar "Cuentas por cobrar", "Facturación del mes", "Pagos pendientes"                   │
│  • 11 items en sidebar es mucho — Facturación + Caja + Tarifarios + Notas Crédito + Fact Electrónica +         │
│    RIPS + RIPS v2 + APEDT + Reportes + Planes de Seguro                                                       │
│  • Sugerencia: Agrupar RIPS/RIPS v2/APEDT bajo "Reportes Regulatorios"                                        │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  🏢 ADMIN (6 sidebar items)                                                                                    │
│                                                                                                                 │
│  ✅ FORTALEZAS:                                                                                                 │
│  • Panel Admin con métricas de plataforma                                                                      │
│  • Clientes → Detalle con tabs: Datos Básicos, Puntos de Atención, Documentos, Usuarios (ahora funcional),     │
│    Config. Comercial                                                                                           │
│  • Usuarios con filtro por rol, estado, búsqueda                                                               │
│                                                                                                                 │
│  ⚠️  MEJORAS PENDIENTES:                                                                                       │
│  • Panel Admin dashboard sin KPIs claros (n° clientes activos, n° usuarios, facturación total)                │
│  • Al crear usuario, el dropdown de facility_id muestra IDs numéricos — debería mostrar nombres de sedes       │
│  • Importaciones debería mostrar historial de imports, no solo el botón de upload                              │
│  • Auditoría muestra logs pero sin filtros avanzados (por entidad, por acción)                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 FLUJOS CRÍTICOS — EFICIENCIA

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  FLUJO: Doctor atiende consulta                                                                                 │
│                                                                                                                 │
│  ACTUAL:                                                                                                        │
│  Dashboard → Buscar Paciente (1 click) → Seleccionar paciente (1 click) → Nuevo Evento (1 click)               │
│  → Llenar SOAP (N campos) → Guardar (1 click) → Firmar (1 click)                                               │
│  TOTAL: ~5 clicks + formulario                                                                                  │
│                                                                                                                 │
│  MEJORA POSIBLE:                                                                                                │
│  Dashboard → Click en paciente de "Citas de Hoy" (1 click) → Abre SOAP rápido (modal) → Dictar/AI (0 clicks)  │
│  → Firmar (1 click)                                                                                             │
│  TOTAL: ~3 clicks + voz                                                                                         │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  FLUJO: Receptionist agenda cita                                                                                │
│                                                                                                                 │
│  ACTUAL:                                                                                                        │
│  Dashboard → Citas (1 click) → Nueva Cita (1 click) → Seleccionar paciente (búsqueda) →                        │
│  Seleccionar doctor → Seleccionar horario → Confirmar (1 click)                                                │
│  TOTAL: ~4 clicks + búsquedas                                                                                    │
│                                                                                                                 │
│  MEJORA POSIBLE:                                                                                                │
│  Dashboard → "Nueva Cita" quick action (1 click) → Buscar paciente → Ver disponibilidad                        │
│  integrada en misma pantalla (sin ir a Horarios) → Confirmar (1 click)                                         │
│  TOTAL: ~3 clicks + búsqueda                                                                                    │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  FLUJO: Pharmacist vende medicamento                                                                            │
│                                                                                                                 │
│  ACTUAL:                                                                                                        │
│  Farmacia POS → Nueva Venta (1 click) → Buscar paciente (1 click) → Agregar items (N clicks) →                 │
│  Seleccionar método de pago → Completar venta (1 click)                                                        │
│  TOTAL: ~4 + N clicks                                                                                           │
│                                                                                                                 │
│  MEJORA POSIBLE:                                                                                                │
│  Dashboard → "Nueva Venta" quick action (1 click) → Escanear código de barras (0 clicks) →                     │
│  Completar (1 click)                                                                                            │
│  TOTAL: ~2 clicks                                                                                               │
│                                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  FLUJO: Billing cierra cuenta                                                                                   │
│                                                                                                                 │
│  ACTUAL:                                                                                                        │
│  Facturación → Buscar cuenta (1 click) → Seleccionar (1 click) → Ver items →                                  │
│  Agregar pago → Cerrar cuenta → Generar factura DIAN                                                           │
│  TOTAL: ~6 clicks                                                                                               │
│                                                                                                                 │
│  ✅ Este flujo es inherentemente multi-paso por requisitos legales (DIAN). No simplificable.                   │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## ✅ QUICK WINS IMPLEMENTADOS (24 May 2026)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  # │ MEJORA                                                │ IMPACTO │ ROL           │ ESTADO                    │
├────┼───────────────────────────────────────────────────────┼─────────┼───────────────┼───────────────────────────┤
│  1 │ Dashboard: +Nueva Venta, +Kardex para pharmacist      │ ALTO    │ Pharmacist    │ ✅ IMPLEMENTADO           │
│  2 │ Dashboard: +Nuevo Estudio, +Importar Lab para lab     │ ALTO    │ Lab Tech      │ ✅ IMPLEMENTADO           │
│  3 │ Dashboard: +Inventario para nurse                     │ MEDIO   │ Nurse         │ ✅ IMPLEMENTADO           │
│  4 │ Dashboard: +Cobrar Consulta, +Comunicaciones reception│ ALTO    │ Receptionist  │ ✅ IMPLEMENTADO           │
│  5 │ Dashboard: +Registrar Pago para billing               │ MEDIO   │ Billing       │ ✅ IMPLEMENTADO           │
│  6 │ KPIs: Ventas Hoy, Stock Bajo (no "Citas Hoy") pharmacy│ ALTO    │ Pharmacist    │ ✅ IMPLEMENTADO           │
│  7 │ KPIs: Muestras Recibidas (no "Citas Hoy") lab         │ ALTO    │ Lab Tech      │ ✅ IMPLEMENTADO           │
│  8 │ KPIs: Cuentas Pendientes (no "Citas Hoy") billing     │ ALTO    │ Billing       │ ✅ IMPLEMENTADO           │
│  9 │ Admin dashboard: quitar FeatureFlags,Email,Migraciones│ MEDIO   │ Admin         │ ✅ IMPLEMENTADO           │
│ 10 │ Admin dashboard: +Ver Clientes, +Configuración        │ MEDIO   │ Admin         │ ✅ IMPLEMENTADO           │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## 🔍 HALLAZGOS ADICIONALES (codebase scan)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  # │ HALLAZGO                                              │ SEVERIDAD │ UBICACIÓN                              │
├────┼───────────────────────────────────────────────────────┼───────────┼────────────────────────────────────────┤
│  1 │ Patient detail: 3 tabs vacíos (Diagnósticos,          │ ALTA      │ patient-detail.component.ts            │
│    │ Inmunizaciones, Adjuntos) — solo icono + texto        │           │                                        │
│  2 │ Vital-signs form: 26 campos sin progressive disclosure│ MEDIA     │ vital-signs-form.component.ts          │
│  3 │ Pharmacy POS: sin autocomplete/barcode en items       │ ALTA      │ pharmacy-new.component.ts              │
│  4 │ 10 TODOs en código (RIPS download, study sign, etc.)  │ BAJA      │ 6 archivos                             │
│  5 │ EmptyStateComponent compartido — solo usado en 2 de   │ MEDIA     │ patient-list, appointment-list         │
│    │ 40+ componentes que muestran estados vacíos           │           │                                        │
│  6 │ Loading spinner inconsistente — sin componente         │ BAJA      │ 20+ archivos con patrones distintos    │
│    │ estándar (anim-spin inline vs skeleton vs spinner)    │           │                                        │
│  7 │ Cervical-screening form: 18 campos                    │ MEDIA     │ cervical-screening-form.component.ts   │
│  8 │ Patient merge accesible para Doctor (no solo Admin)   │ BAJA      │ patients.routes.ts (merge route)      │
│  9 │ Cashbox: create + close dialogs son stubs (TODO)      │ MEDIA     │ cashbox-list, cashbox-detail           │
│ 10 │ RIPS v2 + APEDT son 3 items separados en sidebar      │ BAJA      │ session.service.ts                     │
│    │ (podrían ser sub-pestañas de RIPS)                    │           │                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📐 ARQUITECTURA DE DASHBOARD POR ROL

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  DASHBOARD CARDS QUE DEBERÍA VER CADA ROL                                                                       │
│                                                                                                                 │
│  DOCTOR:                  NURSE:                  RECEPTIONIST:            PHARMACIST:                          │
│  ──────                   ─────                   ────────────             ──────────                           │
│  • Mis Pacientes Hoy      • Pacientes Asignados   • Citas Hoy              • Ventas Hoy                         │
│  • Citas Pendientes       • Signos Pendientes     • Llamadas Pendientes    • Stock Bajo                         │
│  • Completadas Hoy        • Curaciones Hoy        • Facturación del Día    • Meds. por Vencer                   │
│  • Estudios Pendientes    • Inventory Bajo        • Pagos Recibidos        • Pendientes                         │
│                                                                                                                 │
│  LAB TECH:                BILLING:                ADMIN:                                                         │
│  ────────                 ───────                 ─────                                                          │
│  • Estudios Pendientes    • Cuentas por Cobrar    • Clientes Activos                                             │
│  • Resultados Hoy         • Facturación del Mes   • Usuarios Totales                                             │
│  • Urgentes               • Pagos Pendientes      • Facturación Total                                            │
│  • Muestras Recibidas     • RIPS por Generar      • Sesiones del Mes                                             │
│                                                                                                                 │
│  QUICK ACTIONS POR ROL:                                                                                          │
│                                                                                                                 │
│  DOCTOR:           NURSE:            RECEPTIONIST:      PHARMACIST:      LAB TECH:       BILLING:               │
│  ───────           ─────             ────────────       ──────────       ────────        ───────                │
│  Nueva Cita        Registrar Signos  Nueva Cita         Nueva Venta      Nuevo Estudio   Nueva Cuenta           │
│  Buscar Paciente   Nuevo Evento      Buscar Paciente    Nuevo Ingreso    Importar Lab    Registrar Pago          │
│  Nuevo Evento      Buscar Paciente   Llamar Paciente    Verificar Stock  Ver Pendientes  Generar RIPS           │
│  Estudios          Inventario        Cobrar Consulta    Reporte          Reporte         Reporte                │
│  RIPS                                Comunicaciones                                                              │
│  Reportes                                                                                                       │
│  Historial                                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
