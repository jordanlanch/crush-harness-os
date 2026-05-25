# Invariantes de contrato API v2 (congelado)

> **Configuración / env:** La migración KrakenD + NATS no altera paths ni bodies HTTP. Ver [ENV_AND_SERVICE_DISCOVERY.md](./ENV_AND_SERVICE_DISCOVERY.md) y checklist [CLEANUP_PHASE_ENV.md](./CLEANUP_PHASE_ENV.md).

## Superficies

- `/api/v2/auth/*`, `/api/v2/participant/*`, `/api/v2/company/*`, `/api/v2/administrator/*`
- `/api/v2/public/*`, `/api/v2/auditor/*`, `/api/v2/otp/*`, `/api/v2/gift-cards/*`, `/api/v2/legacy/*`, `/api/v2/status/`

## Login

- `POST /api/v2/auth/{client}/{project}/` — `application/x-www-form-urlencoded`
- `200` — body con `token` y `account` en top-level
- `404` credenciales inválidas reescrito a mensaje genérico

## Canje

- `POST /api/v2/participant/purchase-orders/batch`
- Éxito: `200` + `{ "success": true, "title": "Carrito canjeado exitosamente" }`
- Error saga: `400` + `{ "success": false, "title", "errors" }`
- **Prohibido:** `202 Accepted` en este endpoint

## Auth protegida

- Header `Authorization: Bearer {jwt}`
- `JWTV2` + introspección users-management
- `RoleV2("participant"|"company")`

## Verificación

- Golden: `archetype-1/test/contract/golden/`
- Script: `archetype-1/scripts/contract_diff.sh`
- k6: `load-tests/scripts/run-clip-redis-pass2.sh` @ 45 RPS, 0% failed
