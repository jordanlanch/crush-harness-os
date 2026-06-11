# Proyecto de Corrección de Bugs en Registro de Clientes (GSD)

## Fases del Proyecto

### Fase 1: Mejoras en Backend y Validaciones de DTO
- **Objetivo:** Reforzar las validaciones en el DTO de creación/actualización de clientes y adaptar el endpoint de eliminación para realizar un borrado lógico (cambio de estado).
- **Tareas:**
  1. Modificar `CreateClientRequest` y `UpdateClientRequest` en `client_dto.go`:
     - Agregar validaciones regex a `contact_name` (sólo letras).
     - Agregar validaciones a `phone` y `whatsapp_phone` (sólo numéricos o formato específico).
  2. Modificar el caso de uso y el handler de eliminación (`DeleteClient` en `client_handler.go` y `client_usecase.go`) para que en lugar de eliminar el registro físicamente, cambie el estado a `inactivo`.

### Fase 2: Mejoras de UX/UI en el Asistente de Registro (Onboarding Wizard)
- **Objetivo:** Prevenir errores en el ingreso de datos modificando los controles de formulario en el frontend y agregando validaciones paso a paso.
- **Tareas:**
  1. **Tipo de Documento:** Cambiar el input libre por un `<select>` con opciones predefinidas (NIT, CC, CE, etc.).
  2. **País y Municipio:** Cambiar los campos de texto a `<select>`. El de Municipio debe depender del País seleccionado. (Se pueden usar listas estáticas temporales si no hay un endpoint de maestro, o consumir el maestro de DIVIPOLA/Países si existe).
  3. **Validación Paso a Paso:** En `client-onboarding-wizard.component.ts`, asegurar que cada paso verifique las reglas del formulario y muestre errores en los campos antes de permitir hacer clic en "Siguiente".
  4. **Campos de Contacto y Teléfono:** Agregar `Validators.pattern` para `contact_name` (solo letras) y para teléfonos (solo números/formato indicativo).

### Fase 3: Documentación y Glosario
- **Objetivo:** Agregar las definiciones de modelos comerciales y estados del cliente al glosario de la aplicación.
- **Tareas:**
  1. Crear o actualizar el componente de Glosario (si existe en el frontend) o la documentación interna (si es para desarrolladores o manual de usuario).

### Fase 4: TDD y Pruebas
- **Objetivo:** Asegurar mediante pruebas automatizadas que las validaciones y el borrado lógico funcionan.
- **Tareas:**
  1. Escribir pruebas unitarias en Go para las validaciones del DTO y el borrado lógico del `ClientUseCase`.
  2. Escribir pruebas unitarias en Angular para el componente `ClientOnboardingWizardComponent` comprobando que el botón "Siguiente" no avanza si hay errores de formato en nombre o teléfono.

---

Este plan guiará las siguientes acciones. Empezaremos ejecutando la Fase 1.