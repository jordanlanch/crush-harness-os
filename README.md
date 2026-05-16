# Crush Harness OS (v2.0)

![Harness OS](https://img.shields.io/badge/Crush-Harness_OS_v2.0-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

Harness OS v2.0 es una configuración hiper-tuneada y local del agente **Crush**. Está inspirada en la arquitectura de orquestación autónoma de [OpenSwarm](https://github.com/unohee/OpenSwarm), pero adaptada para operar nativamente en un entorno basado en CLI, usando el sistema de archivos (Markdown/PARA) como fuente de verdad y memoria.

## 🚀 Conceptos Principales (The OpenSwarm Influence)

Esta configuración transforma a Crush de un simple asistente interactivo a un agente autónomo estructurado en un **Pair Pipeline** con memoria cognitiva persistente.

### 1. Pair Pipeline Secuencial (AGENTS.md)
Crush asume distintos roles en etapas secuenciales estrictas para cada tarea, emulando un equipo de desarrollo:
- 🧭 **Fase 0 (Scope Guard):** Verificación del contexto y entendimiento estricto del *issue* antes de escribir código.
- ⚡ **Fase 1 (Worker Mode):** Ejecución iterativa bajo TDD (Escribir Test -> Escribir Código -> Refactor).
- 🧐 **Fase 2 (Reviewer Mode):** Auto-revisión crítica del `git diff` y ejecución de análisis estático continuo.
- 👁️ **Fase 3 (Tester Mode):** Verificación final con linters, type-checkers o pruebas visuales (E2E).
- 🧠 **Fase 4 (Documenter Mode):** Compactación del conocimiento y actualización de la memoria.

### 2. Cognitive Memory (Taxonomía)
En lugar de una memoria plana que se desborda, la memoria de Crush se organiza en `/docs/memory/`:
- `beliefs/`: Verdades inmutables e invariantes del sistema.
- `strategies/`: Guías operacionales (ej. "Cómo manejar Auth").
- `system_patterns/`: Decisiones arquitectónicas establecidas.

### 3. Task Queue Local (Autonomous Flow)
A través de `docs/issues/board.md`, Crush opera sobre un tablero Kanban local. Puedes encolar tareas en el Backlog (`Todo`), y Crush las procesará secuencialmente moviéndolas a `In Progress` y `Done` luego de aplicar su pipeline.

### 4. BS Detector (Análisis Estático Continuo)
Se introdujo `docs/patterns/bs_detector.sh`, un pequeño pipeline que Crush ejecuta de forma autónoma en su rol de *Reviewer*. Este script escanea en busca de malos patrones (uso de `any` en TypeScript, `TODOs` sueltos, `console.log` en producción) y detiene el avance si encuentra riesgos, forzando un *Exponential Backoff*.

---

## 📂 Estructura de Directorios

```text
├── AGENTS.md                          # Definición del Pair Pipeline y bucles TAO
├── docs/
│   ├── architecture/
│   │   └── DECISIONS.md               # Source of truth y Tech Stack
│   ├── issues/
│   │   └── board.md                   # Task Queue Local (Kanban)
│   ├── memory/
│   │   ├── README.md                  # Reglas del Cognitive Memory
│   │   ├── STATE.md                   # Estado de Dominio actual compactado
│   │   ├── beliefs/                   # Principios fundamentales
│   │   ├── strategies/                # Estrategias operacionales
│   │   └── system_patterns/           # Patrones extraídos
│   ├── patterns/
│   │   └── bs_detector.sh             # Script de detección de malos olores
│   ├── plans/
│   │   └── active/                    # Archivos scratchpad de planes actuales
│   └── specs/
│       └── TEMPLATE.md                # Template para iniciar nuevos features
```

## 🛠️ Cómo Utilizarlo

1. **Agrega Tareas**: Abre `docs/issues/board.md` y lista tus tareas en la sección `## Todo`.
2. **Desata a Crush**: Dile a Crush: `"Toma la siguiente tarea del board y ejecútala usando tu pipeline de AGENTS.md"`.
3. **Observa el Ciclo**: Crush pasará por Worker, Reviewer y Documenter, cerrará la tarea en el board y compactará los aprendizajes extraídos en `docs/memory/`.

## 🛑 Las Riendas (The Reins)
Si Crush falla un test o la validación del BS Detector 3 veces seguidas, está programado para **DETENERSE**. Solicitará una revisión de arquitectura (`plan-eng-review`) en lugar de caer en loops infinitos.
