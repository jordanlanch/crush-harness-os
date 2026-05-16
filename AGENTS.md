# AGENTS.md — The Harness OS (v2.0 Enterprise)

## 🧬 La Filosofía "Harness"
El código es un subproducto; el repositorio es el cerebro. Crush opera bajo el **Ciclo TAO (Thought-Action-Observation)** con compactación de memoria.

### 🛑 LAS RIENDAS (The Reins) - Reglas de Autocontrol
1. **Límite de Fricción**: Si un test falla 3 veces consecutivas, **DETENTE**. No sigas iterando a ciegas. Documenta el fallo en el plan activo y devuelve el control al humano.
2. **Revisión de Arquitectura Obligatoria**: Antes de tocar código core, DEBES usar la skill `plan-eng-review` (o `review`).
3. **Cero Alucinaciones (Context7)**: Prohibido usar APIs de librerías sin antes hacer `mcp_context7_query-docs`.

---

### ⚙️ El Bucle de Ejecución Avanzado

#### 🧭 Fase 0 — Comprensión & Scope Guard (Thought)
1. Lee `docs/architecture/DECISIONS.md` para el Stack y `docs/memory/STATE.md` para el contexto comprimido.
2. Carga las skills pertinentes (Ej: `view` a `para-memory-files` o `context7-mcp`).
3. Recupera la siguiente tarea del Task Queue en `docs/issues/` o crea un Plan Activo en `docs/plans/active/`.
4. **Scope Guard**: Valida estrictamente que el scope de la tarea esté claro antes de actuar.

#### ⚡ Fase 1 — Ejecución (Worker Mode)
1. Escribe el test (Rojo). Usa el framework nativo del repo.
2. Ejecuta el test. Lee los logs reales.
3. Escribe el código MÍNIMO necesario (Verde).
4. Refactoriza manteniendo la seguridad (SOLID).

#### 🧐 Fase 2 — Auto-Revisión (Reviewer Mode & BS Detector)
1. **Obligatorio**: Haz un `git diff` de tus propios cambios.
2. Evalúa tu código buscando malos patrones (ej. `any`, `try/catch` vacíos, SQLi). Ejecuta `docs/patterns/bs_detector.sh` si existe.
3. Si la auto-revisión falla, corrige el código (Exponential Backoff: al tercer fallo, solicita una revisión de arquitectura `plan-eng-review`).

#### 👁️ Fase 3 — Verificación Continua (Tester Mode)
1. Ejecuta linters y type-checkers.
2. Si es UI, lanza `mcp_playwright` o la skill `gstack/browse` para una verificación visual headless.
3. Verifica Invariantes: ¿Rompiste dependencias circulares? ¿Añadiste vulnerabilidades cruzadas?

#### 🧠 Fase 4 — Síntesis & Extracción de Patrones (Documenter Mode)
*Aquí es donde el agente evoluciona.*
1. **Extracción (Skill Creation)**: Si resolviste un problema complejo o descubriste una convención no documentada, extrae la solución a un archivo `.md` en `docs/patterns/` (Ej: `auth-pattern.md`).
2. **Compactación**: No dejes que el contexto explote. Archiva la memoria en las subcarpetas de `docs/memory/` (beliefs, strategies, system_patterns) y marca el issue como completado en `docs/issues/`.

---

## 🛠️ Tech Stack & Source of Truth
-> Leer `docs/architecture/DECISIONS.md` para ver el stack exacto.
