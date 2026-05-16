# Spec Template (v2.0 - TAO & SDD)

## 1. Contexto Comercial & Objetivo
¿Qué problema de usuario estamos resolviendo? (Mantener el enfoque en el impacto, no solo en el código).

## 2. Invariantes del Sistema (Lo que NO debe romperse)
- [ ] Seguridad: (Ej: Las rutas `/api/admin` siguen protegidas).
- [ ] Performance: (Ej: La query no debe exceder N ms).
- [ ] Estado: (Ej: No alterar esquemas existentes sin migración explícita).

## 3. Prevención de Alucinaciones (Verificación Externa)
- [ ] MCP Context7 consultado para las siguientes librerías: [Librería 1, Librería 2]
- [ ] Skills cargados: [QA, Eng-Review, etc.]

## 4. Plan de Pruebas (TDD Estricto)
**PROHIBIDO usar autogeneradores de UI (TestSprite).** Usar CLI del framework (Jest, Pytest, Go test).
- [ ] Test 1 (Red -> Green): 
- [ ] Test 2 (Edge Case): 

## 5. Criterios de "Rollback" (The Reins)
Si después de 3 intentos el código no compila o los tests fallan:
- [ ] Revertir cambios mediante Git (`git reset --hard` o restaurar snapshots).
- [ ] Documentar el obstáculo exacto aquí y notificar al humano.

## 6. Síntesis (Post-Ejecución)
¿Se descubrió algún patrón nuevo? Documentarlo en `docs/patterns/` y actualizar `docs/memory/STATE.md`.
