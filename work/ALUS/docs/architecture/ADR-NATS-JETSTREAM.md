# ADR: NATS JetStream como bus operativo ALUS

**Estado:** Aceptado  
**Fecha:** 2026-05-22  
**Contexto:** Migración interna `/api/v2` sin cambio de contrato HTTP externo.

## Decisión

Usar **NATS JetStream** como bus de mensajes interno entre microservicios (comandos, eventos de dominio, invalidación de caché). **No** exponer NATS al cliente ni cambiar respuestas HTTP existentes.

## Alternativas consideradas

| Opción | Descartada porque |
|--------|-------------------|
| Kafka | Ops pesado en Dokploy/Swarm para ~100 RPS operativo |
| RabbitMQ | No estándar en el monorepo; más broker que stream |
| Solo HTTP sync | Cuello de botella en sagas (8–15 hops) |
| API 202 async | Rompe frontend Angular y app móvil |

## Convención de subjects

`alus.{dominio}.{accion}.v1` — payload JSON con `client`, `project`, `occurred_at`.

Prioridad inicial:

- `alus.catalog.categories.changed.v1`
- `alus.tenant.bundle.invalidated.v1`
- `alus.redeem.batch.requested.v1` (fase saga interna)

## Despliegue

- Dev: compose `compose-alus-nats-dev` en `dokploy-network` (sin Traefik público)
- Variables: `APP_NATS_ENABLED`, `APP_NATS_URL`, `APP_NATS_STREAM`
- Inventario completo y sync Dokploy: [ENV_AND_SERVICE_DISCOVERY.md](./ENV_AND_SERVICE_DISCOVERY.md) §2, [CLEANUP_PHASE_ENV.md](./CLEANUP_PHASE_ENV.md) §C

## Consecuencias

- archetype-1 consume eventos de invalidación Redis
- purchase-orders puede orquestar sagas vía NATS manteniendo fachada HTTP síncrona
- Kafka opcional fase tardía solo para analytics
