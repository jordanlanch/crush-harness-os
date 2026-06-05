# Plan GSD: Resolución de Auditoría y Estándares de Calidad

## Fase 1: Correcciones de Bloqueo Inmediato (Hotfixes) - ✅ COMPLETADA
- **[COMPLETADO] Tarea 1.1:** Investigar y corregir credenciales o estado del usuario de facturación (`quirogavargas.ceci@gmail.com`). 
- **[COMPLETADO] Tarea 1.2:** Desplegar a producción el fix del menú de "Instituciones" (cambio de `/admin/facilities` a `/admin/sedes`) para eliminar el error 404 en el panel del Administrador.
- **[COMPLETADO] Tarea 1.3:** Auditoría de inspección y refactor masivo de la deuda técnica de `facility_id` hacia `sede_id`. Se reemplazaron más de 100 ocurrencias en el Backend (Go) y Frontend (Angular), logrando compilación limpia y 100% de tests unitarios de los handlers pasando con éxito.

## Fase 2: Automatización y Bypass de Seguridad en QA - ✅ COMPLETADA
- **[COMPLETADO] Tarea 2.1:** Implementar un mecanismo de bypass o inyección de semilla (Secret) para el 2FA del Doctor (`elkin@migrado.mednext.cloud`) en el entorno de pruebas (`Playwright`).
- **[COMPLETADO] Tarea 2.2:** Integrar el uso de TOTP dinámico en los scripts de Playwright (p.ej. usando `otplib`) para que el E2E pueda autenticarse sin intervención manual.

## Fase 3: Pruebas E2E Profundas (Flujos de Negocio Core) - ✅ COMPLETADA
- **[COMPLETADO] Tarea 3.1 (Recepción):** Crear un test E2E estricto que valide la transición correcta de estados de las citas (Disponible -> Reservado -> Asignado -> En Curso -> Fallido/Confirmado) asegurando integridad en la base de datos.
- **[COMPLETADO] Tarea 3.2 (Doctor):** Crear un test E2E de "Cierre de Cita" que certifique que:
  1. Se llenen los campos obligatorios de la HC (Alergias, Antecedentes, Signos Vitales, CIE-10).
  2. El cierre actualice el estado a `CLOSED`.
  3. El sistema dispare la generación del RIPS y del RDA de la consulta de forma automatizada y persistente.

## Fase 4: Cumplimiento de Cobertura y Estándares (ROADMAP)
- **Tarea 4.1 (Backend Tests):** Aumentar la cobertura de tests en el backend para:
  - Repositorios (actual 0%)
  - Casos de Uso (actual 8%)
  - Handlers HTTP (actual 0%)
- **Tarea 4.2 (Frontend Tests):** Aumentar la cobertura en:
  - Componentes (actual 15%)
  - Servicios (actual 8%)
  - Stores (NgRx Signals)

## Fase 5: Integración Continua (CI/CD)
- **Tarea 5.1:** Incorporar la ejecución de la suite `auditoria-profunda` en los pipelines de GitHub Actions / GitLab CI.
- **Tarea 5.2:** Configurar alertas cuando alguna de las reglas de RBAC (Peluqueo de módulos) falle en el pipeline, asegurando que los roles siempre estén encapsulados.
