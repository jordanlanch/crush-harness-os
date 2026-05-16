# Plan de Mejora del Workflow de Crush (Inspirado en OpenSwarm)

## Análisis Profundo: OpenSwarm vs Crush (Harness OS v2.0)

OpenSwarm destaca por su orquestación autónoma de múltiples agentes (Worker, Reviewer, Tester, Documenter), su sistema de memoria cognitiva (LanceDB) y su registro de código con detección de "BS" (malos patrones). Crush actualmente opera bajo el **Ciclo TAO** (Thought-Action-Observation) y compactación de memoria manual/markdown.

Para llevar a Crush al siguiente nivel, integraremos los conceptos de OpenSwarm adaptándolos a un entorno de CLI interactivo y basado en archivos locales (PARA).

---

## Fases del Plan de Mejora

### Fase 1: Emulación de Roles (Pair Pipeline)
*Problema actual:* Crush asume todas las responsabilidades a la vez, lo que puede llevar a sesgos de confirmación o saltos directos a la codificación.
*Mejora:* Implementar un flujo de roles secuenciales estrictos en `AGENTS.md`.
1. **Scope Guard (Decision Engine):** Antes de iniciar una tarea, validar si el scope está bien definido.
2. **Worker Mode:** Escribir el código y los tests.
3. **Reviewer Mode:** Auto-revisión crítica del propio diff (`git diff`) buscando vulnerabilidades, inyecciones SQL o violaciones de límites de confianza (LLM trust boundaries).
4. **Documenter/Auditor Mode:** Actualizar el DOMAIN TREE y `STATE.md` obligatoriamente tras el éxito.

### Fase 2: Code Registry & BS Detector (Análisis Estático Continuo)
*Problema actual:* La validación depende únicamente de linters y tests fallidos.
*Mejora:* 
1. **Registro Local:** Crear un script o pipeline `check_smells.sh` que escanee patrones peligrosos (`any` en TS, `try/catch` vacíos, secretos hardcodeados) antes de dar por verde la tarea (Observation phase).
2. **Grafo de Conocimiento:** Mantener un mapeo de dependencias en `docs/architecture/` para evaluar el impacto cruzado antes de editar archivos core.

### Fase 3: Evolución de la Memoria Cognitiva (Hybrid Retrieval en Markdown)
*Problema actual:* `STATE.md` y `AGENTS.md` pueden saturarse o volverse obsoletos.
*Mejora:* Expandir la estructura de `docs/memory/` en categorías taxonómicas (inspirado en la memoria de OpenSwarm):
- `docs/memory/beliefs/`: Principios absolutos del proyecto.
- `docs/memory/strategies/`: Cómo resolver problemas específicos (ej. auth).
- `docs/memory/system_patterns/`: Convenciones de arquitectura extraídas.
- **Proceso de Decadencia (Decay):** Al final de cada sesión o plan, consolidar y eliminar información redundante.

### Fase 4: Autonomous Pipeline Local (Task Queue)
*Problema actual:* Crush reacciona solo a prompts manuales.
*Mejora:* 
1. Adoptar un modelo de "Cola de Tareas" local en `docs/issues/` (estilo Kanban en Markdown).
2. Al recibir el comando de inicio, Crush toma el ticket de mayor prioridad, ejecuta el Pair Pipeline (Worker -> Reviewer -> Tester), actualiza el ticket a "Done", extrae el patrón a `docs/patterns/` y avanza al siguiente automáticamente.

### Fase 5: Prevención de Fricción Extendida (Pace Control)
*Problema actual:* "Límite de Fricción" para a los 3 errores.
*Mejora:* 
1. **Exponential Backoff Mental:** Si una tarea es rechazada en la fase Reviewer, el Worker debe proponer una arquitectura radicalmente distinta antes de reintentar (obligando a usar la skill `plan-eng-review`).
2. **Impact Analysis:** Prevenir la colisión de cambios analizando el grafo de conocimientos.

---

## Próximos Pasos de Implementación (TODOs)
1. [ ] Modificar `AGENTS.md` para incluir el "Pair Pipeline" (Worker -> Reviewer -> Tester).
2. [ ] Crear la estructura de memoria avanzada en `docs/memory/` (beliefs, strategies, system_patterns).
3. [ ] Implementar un tracker local en `docs/issues/` para orquestación autónoma.
4. [ ] Crear el script base del BS Detector en `docs/patterns/bs_detector.sh`.