# 📦 Catálogo de Módulos — MedNext v1.1.0

**Verificado en producción:** 26/05/2026

---

## Módulos Core (Staff Médico)

### Dashboard
- **URL:** `/dashboard`
- **Roles:** Admin, Doctor, Enfermera, Recepción, Farmacia, Lab, Facturación
- **KPIs:** Pacientes Hoy, Citas Pendientes, Completadas, Alertas (varían por rol)
- **Acciones:** Nueva Cita, Buscar Paciente, Ver Citas (varían por rol)

### Pacientes
- **URL:** `/patients`
- **Roles:** Admin, Doctor, Enfermera, Recepción, Farmacia, Lab
- **Funcionalidades:** Listar 64,968 pacientes, Buscar por documento/nombre, Ver/Editar/Fusionar
- **Paginación:** 20 por página

### Citas / Agenda
- **URL:** `/appointments`
- **Roles:** Doctor, Enfermera, Recepción
- **Funcionalidades:** Nueva Cita (buscar paciente → profesional → sede → fecha), Ver agenda del día, Check-in
- **API:** `POST /appointments` (crear), `POST /appointments/:id/check-in` (registrar llegada), `PATCH /appointments/:id/status`

### Historia Clínica
- **URL:** `/clinical-records`
- **Roles:** Doctor, Enfermera (lectura), Paciente (propia)
- **Funcionalidades:** Timeline de eventos, Notas SOAP, 112,594 diagnósticos importados de SistemaMED

### Signos Vitales
- **URL:** integrated in clinical records
- **Roles:** Doctor, Enfermera
- **Funcionalidades:** Presión arterial, Temperatura, Peso, Frecuencia cardíaca, Saturación O2
- **Validaciones:** Rangos extremos bloquean el guardado

---

## Módulos Médicos (Solo Doctor)

### Mi Personal
- **URL:** `/doctor/staff`
- **Roles:** Doctor
- **Funcionalidades:** Gestionar equipo médico asignado

### Horarios
- **URL:** `/schedules`
- **Roles:** Doctor, Recepción
- **Funcionalidades:** Definir disponibilidad horaria, Bloques de agenda

### Plantillas
- **URL:** `/document-templates`
- **Roles:** Doctor
- **Funcionalidades:** Plantillas de notas clínicas predefinidas

### Firmas Digitales
- **URL:** `/digital-signatures`
- **Roles:** Doctor
- **Funcionalidades:** Firmar documentos clínicos digitalmente

### Medicamentos
- **URL:** `/medications`
- **Roles:** Doctor, Farmacia
- **Funcionalidades:** Catálogo de medicamentos, Recetar, Consultar interacciones

### Estudios
- **URL:** `/studies`
- **Roles:** Doctor
- **Funcionalidades:** Solicitar y revisar estudios diagnósticos

### Lista de Espera
- **URL:** `/waitlist`
- **Roles:** Doctor, Recepción
- **Funcionalidades:** Gestionar pacientes en espera de cupo

### Citas Recurrentes
- **URL:** `/recurring-appointments`
- **Roles:** Doctor, Recepción
- **Funcionalidades:** Programar citas periódicas

---

## Módulos Normativos

### RIPS
- **URL:** `/rips`
- **Roles:** Doctor, Facturación
- **Funcionalidades:** Generar lotes RIPS (Res. 2275), Validar, Descargar JSON/ZIP
- **Datos:** 29 lotes históricos (2023-2026), estados: Borrador, Válido, Generado, Enviado

### RIPS v2
- **URL:** `/rips-v2`
- **Roles:** Doctor, Facturación
- **Funcionalidades:** Nueva versión del módulo RIPS

### APEDT 4505
- **URL:** `/apedt`
- **Roles:** Doctor, Facturación
- **Funcionalidades:** Reporte APEDT 4505

### Facturación Electrónica
- **URL:** `/electronic-invoicing`
- **Roles:** Admin, Facturación
- **Funcionalidades:** Emitir facturas DIAN, Generar CUFE, Descargar PDF
- **Datos:** 3 cuentas (1 facturada con CUFE, 2 cerradas)

---

## Módulos Financieros

### Facturación
- **URL:** `/billing`
- **Roles:** Recepción, Facturación
- **Funcionalidades:** Crear cuentas, Registrar servicios, Cerrar cuenta, Facturar
- **KPIs:** Cuentas Abiertas, Total Facturado, Saldo Pendiente, Facturas DIAN

### Caja
- **URL:** `/cashbox`
- **Roles:** Recepción, Facturación
- **Funcionalidades:** Abrir/Cerrar caja, Registrar pagos, Copagos, Arqueo

### Tarifarios
- **URL:** `/tariffs`
- **Roles:** Facturación
- **Funcionalidades:** Definir precios de servicios y procedimientos

### Notas Crédito
- **URL:** `/credit-notes`
- **Roles:** Facturación
- **Funcionalidades:** Emitir notas crédito para ajustes

### Planes de Seguro
- **URL:** `/insurance-plans`
- **Roles:** Facturación
- **Funcionalidades:** Gestionar entidades de seguro y planes

---

## Módulos de Farmacia

### Farmacia POS
- **URL:** `/pharmacy`
- **Roles:** Farmacia
- **Funcionalidades:** Punto de venta, Despachar fórmulas, Verificar stock

### Inventario (Kardex)
- **URL:** `/inventory`
- **Roles:** Farmacia
- **Funcionalidades:** Catálogo Materiales, Entrada/Salida, Control de lotes, Fechas de vencimiento
- **KPIs:** Total Items (0), Stock Bajo (0), Por Vencer (0), Valor Total ($0)
- **Filtros:** Almacén, Categoría, Estado

---

## Módulos de Recepción

### Comunicaciones
- **URL:** `/communication`
- **Roles:** Recepción
- **Funcionalidades:** Enviar recordatorios, Notificaciones a pacientes

### Call Center
- **URL:** `/call-center`
- **Roles:** Recepción
- **Funcionalidades:** Gestión de llamadas, Agendamiento telefónico

---

## Módulos de Administración

### Panel Admin
- **URL:** `/admin/dashboard`
- **Roles:** Admin
- **KPIs:** Total Usuarios (265), Sedes (136), Pacientes (64,968), Citas Hoy (0)
- **Estado Sistema:** API Operativo, DB Conectada, Email Operativo, Almacenamiento Operativo

### Clientes
- **URL:** `/admin/clients`
- **Roles:** Admin
- **Funcionalidades:** Gestión multi-tenant

### Usuarios
- **URL:** `/admin/users`
- **Roles:** Admin
- **Funcionalidades:** CRUD usuarios, Activar/Desactivar, Asignar roles, Filtrar por rol/estado
- **Roles disponibles:** Administrador, Médico, Enfermera, Recepcionista, Farmacéutico, Laboratorista, Facturación

### Sedes
- **URL:** `/admin/sedes`
- **Roles:** Admin
- **Funcionalidades:** 136 sedes/facilidades (incluye importados de SistemaMED)

### Importaciones
- **URL:** `/imports`
- **Roles:** Admin
- **Funcionalidades:** Importar datos desde SistemaMED (Firebird → PostgreSQL)

### Logs de Auditoría
- **URL:** `/admin/audit-log`
- **Roles:** Admin
- **Funcionalidades:** Registro de actividad de usuarios

### Feature Flags
- **URL:** `/admin/feature-flags`
- **Roles:** Admin
- **Funcionalidades:** Activar/desactivar funcionalidades en runtime

### Migraciones
- **URL:** `/admin/migrations`
- **Roles:** Admin
- **Funcionalidades:** Estado de migraciones Goose

### Email Test
- **URL:** `/admin/email-test`
- **Roles:** Admin
- **Funcionalidades:** Probar envío de emails

### Configuración
- **URL:** `/admin/settings`
- **Roles:** Admin, Paciente (perfil)
- **Funcionalidades:** Parámetros del sistema

### Fact. Electrónica (Admin)
- **URL:** `/admin/electronic-invoicing`
- **Roles:** Admin
- **Funcionalidades:** Configuración de facturación electrónica DIAN

---

## Portal de Pacientes

### Dashboard Paciente
- **URL:** `/patient-portal/dashboard`
- **Roles:** Paciente
- **Funcionalidades:** Bienvenida, Buscar médico, Próximas citas

### Buscar Médico
- **URL:** `/providers/search`
- **Roles:** Paciente, Público
- **Funcionalidades:** Buscar por especialidad, ciudad, nombre

### Mis Citas
- **URL:** `/patient-portal/appointments`
- **Roles:** Paciente
- **Funcionalidades:** Ver, agendar, cancelar citas

### Mis Fórmulas
- **URL:** `/patient-portal/prescriptions`
- **Roles:** Paciente

### Mis Órdenes
- **URL:** `/patient-portal/medical-orders`
- **Roles:** Paciente

### Mis Incapacidades
- **URL:** `/patient-portal/incapacities`
- **Roles:** Paciente

### Mis Remisiones
- **URL:** `/patient-portal/referrals`
- **Roles:** Paciente

### Mi Historia Clínica
- **URL:** `/patient-portal/clinical-records`
- **Roles:** Paciente (solo propia)

### Solicitudes ARCO
- **URL:** `/patient-portal/data-requests`
- **Roles:** Paciente
- **Funcionalidades:** Derechos ARCO (Acceso, Rectificación, Cancelación, Oposición)

### Mi Perfil
- **URL:** `/patient-portal/profile`
- **Roles:** Paciente

### Configuración
- **URL:** `/patient-portal/settings`
- **Roles:** Paciente

---

*Verificado en producción 26/05/2026*
