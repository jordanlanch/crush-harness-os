# GSD Roadmap v1.2 — Núcleo Clínico

> **Período:** 16 semanas (4 fases × 4 semanas)
> **Estado:** 🔵 Planificado
> **Documento fuente:** Obsidian vault `docs → MedNext v1.2/`

## Resumen Ejecutivo

El plan v1.2 transforma MedNext de un sistema de agenda básica a un núcleo clínico completo con:
- Sede + Unidad Asistencial como pilares operativos
- Agenda separada del ciclo de atención
- Programación grupal para cirugías/procedimientos
- Glosario embebido + navegación centralizada
- Validación E2E de 3 casos críticos (cirugía, láser, rayos X)

---

## Diagrama de Fases

```
S1   S2   S3   S4   S5   S6   S7   S8   S9   S10  S11  S12  S13  S14  S15  S16
├────┼────┤
│  FASE 1   │
│ Sede+UA   │
├───────────┼────┼────┤
│           │  FASE 2        │
│           │  Agenda+Ciclo  │
│           ├────────────────┼────┼────┤
│           │                │ FASE 3      │
│           │                │ Cliente+Glos│
│           │                ├─────────────┼────┼────┤
│           │                │             │ FASE 4        │
│           │                │             │ QA+Casos      │
│           │                │             │ Críticos      │
└───────────┴────────────────┴─────────────┴───────────────┘
```

---

## Estado de Fases

| Fase | Nombre | Sprints | Estado | Req | Obsidian |
|------|--------|---------|--------|-----|----------|
| 1 | Sede y Unidad Asistencial | S1-S2 (Sem 1-4) | 🔵 Planificado | R1-R5 | [[GSD-Plan/Fase-1-Sede-y-Unidad-Asistencial]] |
| 2 | Agenda y Ciclo | S3-S4 (Sem 5-8) | 🔵 Planificado | R6-R9 | [[GSD-Plan/Fase-2-Agenda-y-Ciclo]] |
| 3 | Cliente y Glosario | S5-S6 (Sem 9-12) | 🔵 Planificado | R10-R13 | [[GSD-Plan/Fase-3-Cliente-Glosario]] |
| 4 | QA y Casos Críticos | S7-S8 (Sem 13-16) | 🔵 Planificado | R14 | [[GSD-Plan/Fase-4-QA-Casos-Criticos]] |

**Leyenda:** 🔴 Bloqueado · 🟡 En curso · 🟢 Completado · 🔵 Planificado

---

## Grafo de Dependencias

```
Fase 1 (Sede + UA)
  │
  ├──► Fase 2 (Agenda + Ciclo)
  │      │
  │      └──► Fase 4 (QA + Casos Críticos)
  │
  └──► Fase 3 (Cliente + Glosario)
         │
         └──► Fase 4 (QA + Casos Críticos)
```

- Fase 1 bloquea todo lo demás
- Fase 2 y 3 pueden solaparse parcialmente (Fase 3 arranca en S5-S6, Fase 2 termina en S8)
- Fase 4 requiere que 2 y 3 estén completas

---

## Mapeo de Requisitos

| Req | Descripción | Fase | Especificación |
|-----|-------------|------|----------------|
| R1 | Normalizar Sede vs Punto de Atención | 1 | [[Especificaciones/Req-01-Sede-PuntoAtencion]] |
| R2 | Modelar Unidades Asistenciales por Sede | 1 | [[Especificaciones/Req-01-Sede-PuntoAtencion]] |
| R3 | Soportar varios profesionales por UA | 1 | [[Especificaciones/Req-02-Unidad-Asistencial]] |
| R4 | Controlar disponibilidad de profesionales | 1 | [[Especificaciones/Req-02-Unidad-Asistencial]] |
| R5 | Controlar recursos físicos | 1 | [[Especificaciones/Req-02-Unidad-Asistencial]] |
| R6 | Programación grupal | 2 | [[Especificaciones/Req-02-Unidad-Asistencial]] |
| R7 | Visor de agenda con filtros | 2 | [[Especificaciones/Modulo-Agendamiento]] |
| R8 | Separar agenda del ciclo de atención | 2 | [[Especificaciones/Modulo-Agendamiento]] |
| R9 | Integrar ciclo de atención completo | 2 | [[Especificaciones/Formulario-Preconsulta-RIPS]] |
| R10 | Revisar creación de clientes | 3 | [[Especificaciones/Modulo-Creacion-Cliente]] |
| R11 | Incorporar glosario en la app | 3 | [[Especificaciones/Glosario-MedNext]] |
| R12 | Mejorar navegación de documentos | 3 | [[Especificaciones/Glosario-MedNext]] |
| R13 | Colaboración sobre definiciones | 3 | [[Especificaciones/Glosario-MedNext]] |
| R14 | Validar casos de uso críticos | 4 | [[GSD-Plan/Fase-4-QA-Casos-Criticos]] |

---

## Mapeo Graphify

| Fase | Comunidades | Nodos afectos | Naturaleza |
|------|-------------|---------------|------------|
| 1 | #1, #4, #32, #48 | ~1100 | Refactor + expansión |
| 2 | #1, #7, #9, #14, #16, #21, #26 | ~870 | Refactor + greenfield (Agenda) |
| 3 | #32, #34 | ~380 | Refactor + nuevo módulo |
| 4 | #13, #16, #174 | ~230 | Tests + validación |
| **Total** | | **~2580 nodos** | |

---

## Estimaciones por Fase

| Fase | Backend | Frontend | Infra | QA | Total (días) |
|------|---------|----------|-------|----|----|
| 1 | 15.5 | 9 | 2 | 0 | 26.5 |
| 2 | 23.5 | 19 | 3 | 0 | 45.5 |
| 3 | 13.5 | 17 | 1.75 | 0 | 32.25 |
| 4 | 3.5 | 0 | 0 | 14 | 17.5 |
| **Total** | **55.5** | **45** | **6.75** | **14** | **121.25 días-hombre** |

> Asumiendo 2 devs backend + 2 frontend + 1 QA + 1 infra a tiempo completo:
> - 4 devs × 16 semanas × 5 días = 320 días-hombre disponibles
> - 121.25 días necesarios → ~38% utilización (margen para bugs, soporte, revisión)

---

## Riesgos Críticos

| # | Riesgo | Fase | Prob | Impacto | Mitigación |
|---|--------|------|------|---------|------------|
| 1 | Refactor Facility→Sede rompe refs | 1 | Alta | Alto | Graphify mapping + feature flags |
| 2 | Agenda module es ~greenfield | 2 | Alta | Alto | Prototipo temprano en Sprint 3 |
| 3 | Group scheduling transaccional | 2 | Alta | Medio | DB transactions + lock optimist |
| 4 | State machine refactor de 345 nodos | 2 | Alta | Alto | Compatibilidad hacia atrás |
| 5 | Modelo comercial no definido | 3 | Alta | Bajo | Dejar campo como draft |
| 6 | RIPS normativa cambia | 4 | Media | Medio | Referenciar Res. 2275/2023 |

---

## Paths de Referencia

| Recurso | Ubicación |
|---------|-----------|
| Obsidian vault | `/home/jordanlanch/work/cubiko/docs/MedNext v1.2/` |
| Especificaciones | `MedNext v1.2/Especificaciones/` |
| GSD Plan | `MedNext v1.2/GSD-Plan/` |
| Graphify data | `graphify-out/GRAPHIFY_REPORT.md` |
| v1.1 Roadmap (template) | `.planning/gsd-roadmap-consolidated.md` |
| Este documento | `.planning/gsd-plan-v1.2.md` |
