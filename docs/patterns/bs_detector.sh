#!/bin/bash
# BS Detector - Análisis estático simple para malos olores en el código
# Se ejecuta durante la Fase 2 (Auto-Revisión) del pipeline de Crush.

echo "[BS Detector] Iniciando escaneo de malos patrones..."

ERRORS=0

# Buscar "any" en archivos TypeScript
if grep -rn " any " src/ 2>/dev/null; then
    echo "⚠️  ADVERTENCIA: Se detectó el uso de 'any' en TypeScript. Considera usar un tipado estricto."
    ERRORS=$((ERRORS+1))
fi

# Buscar TODOs olvidados
if grep -rn "TODO:" src/ 2>/dev/null; then
    echo "⚠️  ADVERTENCIA: Se encontraron TODOs en el código. ¿Deberían resolverse antes de considerar la tarea terminada?"
    ERRORS=$((ERRORS+1))
fi

# Buscar consoles.log en código de producción (excluir tests)
if grep -rn "console\.log" src/ --exclude-dir="__tests__" 2>/dev/null; then
    echo "⚠️  ADVERTENCIA: console.log detectado en src/. Usa un logger apropiado."
    ERRORS=$((ERRORS+1))
fi

if [ $ERRORS -gt 0 ]; then
    echo "[BS Detector] Se encontraron $ERRORS advertencias (Smells). Verifica tu código antes de avanzar."
    exit 1
else
    echo "[BS Detector] Todo limpio. Código aprobado."
    exit 0
fi
