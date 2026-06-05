# Plan de Auditoría Profunda E2E con Playwright - MedNext

## 1. Objetivos de la Auditoría
- Validar los flujos críticos de la plataforma `mednext.cloud` utilizando los usuarios certificados en la base de datos de producción.
- Determinar qué funcionalidades aplican y cuáles "ya no aplican" (para depurar/peluquear) según cada perfil.
- Garantizar que el control de accesos (RBAC) esté correctamente implementado.
- Sistematizar esta auditoría a través de scripts de Playwright para ejecución continua.

## 2. Cuentas de Prueba Certificadas (Producción)

| Rol | Usuario (Email) | Contraseña | 2FA |
|---|---|---|---|
| Administrador | admin@mednext.com | Admin123 | No |
| Recepcionista | recepcion@mednext.com | Recep123 | No |
| Enfermera | patricia.ruiz@mednext.com | Test1234! | No |
| Doctor | elkin@migrado.mednext.cloud | q9yKm4nHvVQMejY | SÍ |
| Farmacéutico | farmacia@mednext.com | Pharma123 | No |
| Laboratorista | laboratorio@mednext.com | Lab123 | No |
| Facturación | quirogavargas.ceci@gmail.com | Test1234! | No |
| Paciente | *Crear en /patient-portal/register* | *Cualquiera* | No |

## 3. Revisión por Perfil y Flujos a Auditar (Playwright)

*(Nota: De acuerdo a la documentación funcional de MedNext 2026.05.31)*

### 3.1. Super Usuario (MedNext) y Usuario Administrador (Cliente)
- **Aplica (Super Usuario):** Gestión de clientes (registro maestro, IdCliente), asociación de contratos, creación de usuarios globales, políticas de backup.
- **Aplica (Usuario Administrador Cliente `admin@mednext.com`):** Configuración específica de la IPS, Unidades Asistenciales (Agendas), Puntos de Atención (Sedes), Usuarios Finales (con roles), Políticas de bloqueo y reseteo de contraseñas.
- **Flujos a auditar en Playwright:**
  - Login exitoso.
  - CRUD de Usuarios (crear nuevo médico, suspender/inactivar acceso, control de intentos fallidos).
  - Creación y parametrización de Unidad de Atención y Punto de Atención.
  - Configuración de entidades y planes de tarifas.
- **Peluquear:** El administrador no realiza atenciones clínicas, ni factura directamente.

### 3.2. Recepcionista (`recepcion@mednext.com` - Usuario Final)
- **Aplica:** Agendamiento (Gestión de Cupos/Citas) y creación de pacientes.
- **Flujos a auditar en Playwright:**
  - Login exitoso.
  - Creación de paciente nuevo con toda la data demográfica, ubicación, aseguradora y validación de documento.
  - **Gestión de Agenda:**
    - Crear cita (estado: `Disponible`).
    - Bloquear / Reservar cupo (desde `Disponible`).
    - Asignar cita a paciente (estado: `Asignado`).
    - Reprogramar cita (cambia actual a `Fallido` y asigna a nuevo cupo).
    - Cancelar cita (estado: `Fallido` con motivo).
    - Confirmar cita (estado: `Confirmado`).
    - Recepcionar paciente (marca cita `En Curso` y procesos de admisión/facturación).
- **Peluquear:** No debe tener acceso a Historias Clínicas, ni a configuración, ni a RIPS. No puede cerrar la cita clínica (solo la cambia a En Curso).

### 3.3. Enfermera (`patricia.ruiz@mednext.com` - Usuario Final)
- **Aplica:** Triage, toma de signos vitales, notas de enfermería, aplicación de medicamentos.
- **Flujos a auditar en Playwright:**
  - Acceso a pacientes en estado "En Curso".
  - Captura de constantes vitales.
  - Notas de evolución.
- **Peluquear:** No puede generar incapacidades, formular medicamentos o realizar cierres de historia clínica (Cerrar Cita -> Generar RDA).

### 3.4. Doctor (`elkin@migrado.mednext.cloud` - Usuario Final - Requiere 2FA)
- **Aplica:** Atención médica, evolución clínica, antecedentes, diagnósticos, procedimientos.
- **Flujos a auditar en Playwright:**
  - Login con 2FA.
  - Cargar paciente desde su agenda (estado `En Curso`).
  - Diligenciamiento de HC:
    - Registro de Grupo Sanguíneo, Alergias, Factores de riesgo.
    - Registro de Antecedentes familiares (Hipertensión, Diabetes, Cáncer, etc.)
  - Asignación de diagnóstico principal.
  - **Cierre de Cita:** Cambiar cita a `Cerrado`, actualizar HC, generar RIPS y RDA Consulta.
- **Peluquear:** Accesos a facturación, inventario general y configuración del sistema.

### 3.5. Farmacéutico (`farmacia@mednext.com` - Usuario Final)
- **Aplica:** Despacho de medicamentos, inventario de farmacia, control de lotes y fechas de vencimiento.
- **Flujos a auditar en Playwright:**
  - Búsqueda de fórmula médica por ID de paciente o documento.
  - Registro de entrega de medicamentos.
  - Descuento de inventario.
- **Peluquear:** No debe tener acceso a consultas médicas, RIPS ni agenda médica.

### 3.6. Laboratorista (`laboratorio@mednext.com`)
- **Aplica:** Recepción de órdenes de laboratorio, ingreso de resultados, validación.
- **Flujos a auditar en Playwright:**
  - Búsqueda de órdenes pendientes.
  - Carga de resultados (texto o archivo adjunto).
  - Notificación de resultado disponible.
- **Peluquear:** Mismo que farmacia, restringido a su módulo.

### 3.7. Facturación (`quirogavargas.ceci@gmail.com`)
- **Aplica:** Generación de pre-facturas, liquidación de citas, facturación electrónica (CUFE), copagos, RIPS financieros.
- **Flujos a auditar en Playwright:**
  - Generación de factura desde una cita completada.
  - Aplicación de copago o cuota moderadora.
  - Generación del archivo JSON/XML para facturación electrónica.
- **Peluquear:** No puede editar historias clínicas bajo ninguna circunstancia.

### 3.8. Paciente (Portal de Pacientes)
- **Aplica:** Autoagendamiento, visualización de resultados de laboratorio, descarga de fórmulas.
- **Flujos a auditar en Playwright:**
  - Registro nuevo (`/patient-portal/register`).
  - Solicitud de cita.
  - Visualización de historial de citas.

## 4. Estructura Recomendada de Playwright

Se organizará el suite de Playwright dentro de `frontend/e2e/tests/auditoria-profunda/`:
- `admin-audit.spec.ts`
- `reception-audit.spec.ts`
- `nurse-audit.spec.ts`
- `doctor-audit.spec.ts` (Incluyendo soporte 2FA)
- `pharmacy-audit.spec.ts`
- `lab-audit.spec.ts`
- `billing-audit.spec.ts`
- `patient-portal-audit.spec.ts`

**Nota sobre 2FA:** Para el Doctor, se requerirá manejar el prompt de 2FA. Si es por TOTP, Playwright deberá utilizar una librería como `otplib` e inyectar el token secreto (si se tiene para pruebas) o usar un entorno de bypass en stagging. Si no se puede bypass en `mednext.cloud`, se requerirá intervención manual o un token de prueba hardcodeado (`000000` si está configurado en QA).

## 5. Siguientes Pasos
1. Ejecutar las pruebas unitarias y de E2E existentes para verificar el baseline.
2. Implementar los scripts de `auditoria-profunda` iterando perfil por perfil, comenzando por las validaciones de acceso (lo que NO pueden ver).
3. Entregar el reporte final con el comando `npx playwright test --project=chromium --reporter=html`.
