# MedNext — Plan de Usabilidad por Rol

```
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║                      PLAN DE USABILIDAD — Qué necesita CADA ROL para ser productivo                             ║
║                          Análisis funcional · Módulos · Flujos · Prioridades                                   ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
```

---

## 🏢 ADMIN (SaaS Owner) — El dueño de la plataforma

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PERFIL: Administrador del sistema SaaS. Gestiona clientes, usuarios, monitorea la plataforma.                 │
│  NO tiene acceso a datos clínicos de los tenants.                                                              │
│                                                                                                                 │
│  MÓDULOS ACTUALES (sidebar):                          QUICK ACTIONS (dashboard):                                │
│  ────────────────────────                              ─────────────────────────                                 │
│  ✅ Panel Admin                                        ✅ Gestionar Usuarios                                    │
│  ✅ Clientes                                           ✅ Ver Clientes                                          │
│  ✅ Usuarios                                           ✅ Instituciones                                         │
│  ✅ Importaciones                                      ✅ Logs de Auditoría                                     │
│  ✅ Logs de Auditoría                                  ✅ Importaciones                                         │
│  ✅ Configuración                                      ✅ Migraciones                                           │
│                                                        ✅ Email Test                                            │
│  LO QUE FALTA EN SIDEBAR:                              ✅ Feature Flags                                         │
│  ────────────────────────                              ✅ Configuración                                         │
│  ⚠️  Migraciones (solo en dashboard, no sidebar)                                                               │
│  ⚠️  Email Test (solo en dashboard, no sidebar)                                                                │
│  ⚠️  Feature Flags (solo en dashboard, no sidebar)                                                             │
│  ⚠️  Instituciones (solo en dashboard + URL directa)                                                           │
│                                                                                                                 │
│  DECISIÓN: El admin es el DUEÑO del SaaS. Debe tener acceso a TODO.                                            │
│  Los items que quitamos del sidebar (Instituciones, Feature Flags, etc.) son                                    │
│  HERRAMIENTAS OPERACIONALES del admin. Restaurarlos.                                                           │
│                                                                                                                 │
│  SIDEBAR FINAL ADMIN:                                                                                           │
│  🏠 Panel Admin  🏢 Clientes  👥 Usuarios  🏥 Instituciones  📋 Logs de Auditoría                              │
│  ⚙️  Configuración  🚩 Feature Flags  📧 Email Test  📦 Importaciones  🗄️ Migraciones                          │
│  ───────────────────────────────────────────────────────────────────────────────────────────────────────       │
│  10 items. El admin necesita ver todo. NO hay "tool de desarrollo" — todo es operational.                      │
│                                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🩺 DOCTOR — El dueño de la clínica

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PERFIL: Médico / Dueño de consultorio. Atiende pacientes, firma historias clínicas,                           │
│  ordena estudios, gestiona su personal.                                                                         │
│                                                                                                                 │
│  MÓDULOS ACTUALES (15):                                                                                         │
│  ✅ Dashboard  ✅ Mi Personal  ✅ Pacientes  ✅ Citas  ✅ Horarios  ✅ Historia Clínica                          │
│  ✅ Plantillas  ✅ Firmas Digitales  ✅ Estudios  ✅ Lista de Espera  ✅ Citas Recurrentes                      │
│  ✅ RIPS  ✅ RIPS v2  ✅ APEDT 4505  ✅ Reportes                                                                │
│                                                                                                                 │
│  LO QUE FALTA / MEJORAR:                                                                                        │
│  ───────────────────────                                                                                        │
│  🔴 CRÍTICO: RIPS, RIPS v2, APEDT 4505 son 3 items separados en sidebar                                       │
│     → SOLUCIÓN: Un solo item "Reportes Regulatorios" con sub-pestañas dentro                                   │
│                                                                                                                 │
│  🟡 ALTO: El doctor NO ve "Medicamentos" en sidebar pero prescribe en consulta                                 │
│     → SOLUCIÓN: Agregar "Catálogo de Medicamentos" (read-only) al sidebar                                      │
│                                                                                                                 │
│  🟡 ALTO: El doctor NO ve "Órdenes Médicas" como módulo separado                                              │
│     → Están dentro de Historia Clínica → Evento. Debería ser accesible directamente.                           │
│                                                                                                                 │
│  🟢 MEDIO: Especialidades (Citología, Ecocardiografía, etc.) están ocultas                                     │
│     → Se acceden desde el perfil del paciente. OK así.                                                          │
│                                                                                                                 │
│  SIDEBAR IDEAL DOCTOR (18 items):                                                                               │
│  🏠 Dashboard  👥 Mi Personal  👤 Pacientes  📅 Citas  🕐 Horarios  📋 H. Clínica                             │
│  📄 Plantillas  ✍️ Firmas Digitales  🔬 Estudios  💊 Medicamentos  📝 Órdenes Médicas                         │
│  📊 Reportes  📑 Reportes Regulatorios (RIPS+APEDT unificados)                                                │
│  ⏳ Lista de Espera  🔄 Citas Recurrentes                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🏥 NURSE — Asistente clínico

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PERFIL: Enfermera. Toma signos vitales, asiste en procedimientos, administra medicamentos,                    │
│  gestiona inventario de insumos.                                                                                │
│                                                                                                                 │
│  MÓDULOS ACTUALES (7):                                                                                          │
│  ✅ Dashboard  ✅ Pacientes  ✅ Citas  ✅ Historia Clínica  ✅ Firmas Digitales                                 │
│  ✅ Inventario  ✅ Reportes                                                                                     │
│                                                                                                                 │
│  LO QUE FALTA / MEJORAR:                                                                                        │
│  ───────────────────────                                                                                        │
│  🔴 CRÍTICO: "Signos Vitales" NO es un módulo separado. La enfermera toma signos todo el día.                  │
│     → SOLUCIÓN: Agregar "Signos Vitales" al sidebar (atajo a /vital-signs o al paciente)                       │
│                                                                                                                 │
│  🟡 ALTO: La enfermera ve "Citas" pero solo para ver — no puede crear. OK. Pero el dashboard                   │
│     debería mostrar "Pacientes asignados hoy" y "Toma de signos pendiente".                                    │
│     → SOLUCIÓN: Dashboard KPI específico para nurse (backend ya da datos)                                      │
│                                                                                                                 │
│  🟡 ALTO: "Medicamentos" — la enfermera administra medicamentos pero no ve el catálogo                         │
│     → SOLUCIÓN: Agregar "Medicamentos" (read-only) al sidebar                                                  │
│                                                                                                                 │
│  SIDEBAR IDEAL NURSE (10 items):                                                                                │
│  🏠 Dashboard  👤 Pacientes  📅 Citas  🩺 Signos Vitales  📋 H. Clínica  ✍️ Firmas Digitales                 │
│  💊 Medicamentos  📦 Inventario  📊 Reportes                                                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📞 RECEPTIONIST — Front desk

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PERFIL: Recepcionista. Agenda citas, recibe pacientes, cobra consultas,                                        │
│  gestiona comunicaciones y call center.                                                                         │
│                                                                                                                 │
│  MÓDULOS ACTUALES (10):                                                                                         │
│  ✅ Dashboard  ✅ Pacientes  ✅ Citas  ✅ Horarios  ✅ Facturación  ✅ Caja                                     │
│  ✅ Lista de Espera  ✅ Citas Recurrentes  ✅ Comunicaciones  ✅ Call Center                                    │
│                                                                                                                 │
│  LO QUE FALTA / MEJORAR:                                                                                        │
│  ───────────────────────                                                                                        │
│  🟡 ALTO: Al crear cita, debería ver disponibilidad del doctor en el mismo formulario                          │
│     (actualmente tiene que ir a Horarios aparte).                                                               │
│     → El appointment-form YA tiene loadAvailableSlots(). OK.                                                    │
│                                                                                                                 │
│  🟢 MEDIO: El dashboard debería mostrar "Citas de hoy" + "Pagos pendientes"                                    │
│     → Ya muestra Citas Hoy y Pendientes. OK.                                                                    │
│                                                                                                                 │
│  SIDEBAR IDEAL RECEPTIONIST (10 items): Mismo que actual. OK.                                                   │
│  La receptionist tiene exactamente lo que necesita.                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 💊 PHARMACIST — Farmacia

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PERFIL: Farmacéutico. Dispensa medicamentos, gestiona inventario de farmacia,                                 │
│  recibe ingresos de medicamentos.                                                                               │
│                                                                                                                 │
│  MÓDULOS ACTUALES (4):                                                                                          │
│  ✅ Dashboard  ✅ Farmacia POS  ✅ Inventario  ✅ Reportes                                                      │
│                                                                                                                 │
│  LO QUE FALTA / MEJORAR:                                                                                        │
│  ───────────────────────                                                                                        │
│  🔴 CRÍTICO: El POS NO tiene búsqueda de productos por código de barras o autocomplete.                        │
│     → SOLUCIÓN: Agregar barcode scanner + autocomplete en pharmacy-new.component                               │
│                                                                                                                 │
│  🟡 ALTO: "Medicamentos" (catálogo) — el farmacéutico gestiona el catálogo pero                                │
│     está dentro de Inventario. Debería ser un módulo separado.                                                  │
│     → SOLUCIÓN: Agregar "Catálogo Medicamentos" al sidebar o integrarlo mejor en Farmacia POS                  │
│                                                                                                                 │
│  🟡 ALTO: "Pacientes" — el farmacéutico ve pacientes en el POS pero con datos limitados.                       │
│     → SOLUCIÓN: Permitir búsqueda de paciente por documento en el POS (ya tiene pharmacy.patient.view)         │
│                                                                                                                 │
│  🟢 MEDIO: Dashboard KPI "Medicamentos próximos a vencer"                                                       │
│     → SOLUCIÓN: Agregar endpoint de lotes por vencer y mostrarlo en dashboard                                  │
│                                                                                                                 │
│  SIDEBAR IDEAL PHARMACIST (6 items):                                                                             │
│  🏠 Dashboard  🏪 Farmacia POS  📦 Inventario  💊 Medicamentos  👤 Pacientes  📊 Reportes                     │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔬 LAB TECH — Laboratorio

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PERFIL: Técnico de laboratorio. Procesa muestras, registra resultados,                                        │
│  importa resultados de equipos externos.                                                                        │
│                                                                                                                 │
│  MÓDULOS ACTUALES (4):                                                                                          │
│  ✅ Dashboard  ✅ Estudios  ✅ Import. de Lab  ✅ Reportes                                                      │
│                                                                                                                 │
│  LO QUE FALTA / MEJORAR:                                                                                        │
│  ───────────────────────                                                                                        │
│  🟡 ALTO: El lab tech ve "Estudios" pero no tiene un flujo claro de "Muestras recibidas → Procesar →           │
│     Completar → Firmar". El listado de estudios es genérico.                                                    │
│     → SOLUCIÓN: Agregar filtros por estado en la lista de estudios (pendiente, en proceso, completado)         │
│                                                                                                                 │
│  🟡 ALTO: "Pacientes" (read-only) — el lab tech necesita ver datos del paciente                                │
│     para corroborar identidad de la muestra.                                                                    │
│     → SOLUCIÓN: Agregar "Pacientes" al sidebar (read-only)                                                     │
│                                                                                                                 │
│  🟢 MEDIO: "Muestras" como concepto separado de "Estudios"                                                      │
│     → Un estudio puede tener múltiples muestras. El lab tech trabaja con muestras, no estudios.                │
│                                                                                                                 │
│  SIDEBAR IDEAL LAB TECH (5 items):                                                                              │
│  🏠 Dashboard  🔬 Estudios  📥 Import. de Lab  👤 Pacientes  📊 Reportes                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 💰 BILLING — Facturación

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PERFIL: Facturador. Gestiona cuentas, pagos, facturación electrónica DIAN,                                   │
│  RIPS, tarifarios, planes de seguro.                                                                            │
│                                                                                                                 │
│  MÓDULOS ACTUALES (11):                                                                                         │
│  ✅ Dashboard  ✅ Facturación  ✅ Caja  ✅ Tarifarios  ✅ Notas Crédito  ✅ Fact. Electrónica                   │
│  ✅ RIPS  ✅ RIPS v2  ✅ APEDT 4505  ✅ Reportes  ✅ Planes de Seguro                                          │
│                                                                                                                 │
│  LO QUE FALTA / MEJORAR:                                                                                        │
│  ───────────────────────                                                                                        │
│  🔴 CRÍTICO: RIPS, RIPS v2, APEDT 4505 son 3 items. El billing usa esto a diario.                             │
│     → SOLUCIÓN: Unificar bajo "Reportes Regulatorios" con tabs internos                                        │
│                                                                                                                 │
│  🟢 MEDIO: Billing tiene 11 items → es el rol con más items del sidebar. OK para un事实urador.                 │
│                                                                                                                 │
│  SIDEBAR IDEAL BILLING (9 items):                                                                               │
│  🏠 Dashboard  💰 Facturación  🏧 Caja  📋 Tarifarios  📝 Notas Crédito                                       │
│  ⚡ Fact. Electrónica  📑 Reportes Regulatorios  📊 Reportes  🛡️ Planes de Seguro                             │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 PLAN DE ACCIÓN — PRIORIZADO

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  PRIORIDAD  │ ACCIÓN                                                     │ ROLES AFECTADOS    │ ESFUERZO        │
├─────────────┼────────────────────────────────────────────────────────────┼────────────────────┼─────────────────┤
│  🔴 P0      │ Restaurar sidebar admin completo (10 items)                │ Admin              │ 5 min           │
│  🔴 P0      │ Agrupar RIPS/RIPS v2/APEDT como "Reportes Regulatorios"   │ Doctor, Billing    │ 1h (nueva ruta) │
│  🔴 P0      │ Agregar "Signos Vitales" al sidebar de nurse               │ Nurse              │ 1 línea         │
│  🟡 P1      │ Agregar "Medicamentos" al sidebar de doctor + nurse        │ Doctor, Nurse      │ 1 línea         │
│  🟡 P1      │ Agregar "Pacientes" al sidebar de pharmacist + lab tech    │ Pharmacist, Lab    │ 1 línea         │
│  🟡 P1      │ Agregar "Órdenes Médicas" al sidebar de doctor             │ Doctor             │ 1 línea         │
│  🟡 P1      │ Agregar "Catálogo Medicamentos" al sidebar de pharmacist   │ Pharmacist         │ 1 línea         │
│  🟢 P2      │ Dashboard KPI: "Medicamentos por vencer" (pharmacist)      │ Pharmacist         │ 2h (backend+FE)│
│  🟢 P2      │ Dashboard KPI: "Signos pendientes" (nurse)                 │ Nurse              │ 2h (backend+FE)│
│  🟢 P2      │ Pharmacy POS: autocomplete/barcode en items                │ Pharmacist         │ 4h              │
│  🟢 P2      │ Patient detail: ocultar tabs vacíos si no hay datos        │ Doctor, Nurse      │ 30min           │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📐 SIDEBAR FINAL POR ROL (Propuesta)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│  ROL          │ ITEMS │ SIDEBAR                                                                                  │
├───────────────┼───────┼──────────────────────────────────────────────────────────────────────────────────────────┤
│  ADMIN        │  10   │ Panel Admin, Clientes, Usuarios, Instituciones, Importaciones,                          │
│               │       │ Logs de Auditoría, Feature Flags, Migraciones, Email Test, Configuración               │
│  DOCTOR       │  16   │ Dashboard, Mi Personal, Pacientes, Citas, Horarios, H. Clínica,                        │
│               │       │ Plantillas, Firmas Digitales, Estudios, Medicamentos, Órdenes Médicas,                 │
│               │       │ Reportes Regulatorios (RIPS+APEDT), Reportes, Lista de Espera, Citas Recurrentes       │
│  NURSE        │  10   │ Dashboard, Pacientes, Citas, Signos Vitales, H. Clínica,                               │
│               │       │ Firmas Digitales, Medicamentos, Inventario, Reportes                                   │
│  RECEPTIONIST │  10   │ Dashboard, Pacientes, Citas, Horarios, Facturación, Caja,                              │
│               │       │ Lista de Espera, Citas Recurrentes, Comunicaciones, Call Center                        │
│  PHARMACIST   │   6   │ Dashboard, Farmacia POS, Inventario, Medicamentos, Pacientes, Reportes                 │
│  LAB TECH     │   5   │ Dashboard, Estudios, Import. de Lab, Pacientes, Reportes                               │
│  BILLING      │   9   │ Dashboard, Facturación, Caja, Tarifarios, Notas Crédito,                               │
│               │       │ Fact. Electrónica, Reportes Regulatorios, Reportes, Planes de Seguro                   │
│  PATIENT      │   9   │ Dashboard, Buscar Médico, Mis Citas, Mis Fórmulas, Mis Órdenes,                       │
│               │       │ Mis Incapacidades, Mis Remisiones, Mi Perfil, Configuración                            │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
