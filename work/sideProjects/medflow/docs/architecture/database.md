# Database Architecture

## Overview

- **RDBMS**: PostgreSQL 16+
- **Driver**: pgx/v5 (native Go driver, no ORM)
- **Query generation**: sqlc (type-safe Go from SQL)
- **Migrations**: goose (versioned SQL migrations)
- **Cache**: Redis 7+ (sessions, token blacklist)

## Schema Overview

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        PostgreSQL Schema                                  │
│                                                                          │
│  ┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐       │
│  │   patients   │────▶│  patient_events  │     │   appointments   │       │
│  │             │     │  (clinical)      │     │                  │       │
│  │  id (UUID)  │     │  patient_id (FK) │     │  patient_id (FK) │       │
│  │  doc_type   │     │  provider_id     │     │  provider_id     │       │
│  │  doc_number │     │  event_type      │     │  facility_id     │       │
│  │  first_name │     │  content (JSONB) │     │  schedule_slot   │       │
│  │  last_name  │     │  signed_at       │     │  status          │       │
│  │  birth_date │     │  signed_by       │     │  start_time      │       │
│  │  gender     │     └─────────────────┘     │  end_time        │       │
│  │  phone      │                              └──────────────────┘       │
│  │  email      │                                       │                 │
│  │  insurance  │     ┌─────────────────┐              │                 │
│  └─────────────┘     │    schedules    │◀─────────────┘                 │
│        │             │                 │                                 │
│        │             │  provider_id    │     ┌──────────────────┐       │
│        │             │  facility_id    │     │  schedule_blocks │       │
│        │             │  day_of_week    │────▶│                  │       │
│        │             │  start_time     │     │  schedule_id     │       │
│        │             │  end_time       │     │  provider_id     │       │
│        │             │  slot_duration  │     │  start/end_time  │       │
│        │             └─────────────────┘     │  reason          │       │
│        │                                      └──────────────────┘       │
│        │                                                                 │
│  ┌─────┴───────┐     ┌─────────────────┐     ┌──────────────────┐       │
│  │  accounts   │────▶│    payments     │     │    invoices      │       │
│  │             │     │                 │     │                  │       │
│  │  patient_id │     │  account_id     │     │  account_id      │       │
│  │  facility_id│     │  method         │     │  number          │       │
│  │  number     │     │  amount         │     │  items (JSONB)   │       │
│  │  status     │     │  reference      │     │  total_amount    │       │
│  │  total      │     └─────────────────┘     │  tax_amount      │       │
│  └─────────────┘                              └──────────────────┘       │
│        │                                                                 │
│  ┌─────┴───────────┐                                                    │
│  │  account_items  │     ┌─────────────────┐                            │
│  │                 │────▶│    services     │                            │
│  │  account_id     │     │   (catalog)     │                            │
│  │  service_id     │     │                 │                            │
│  │  quantity       │     │  code (CUPS)    │                            │
│  │  unit_price     │     │  name           │                            │
│  └─────────────────┘     │  price          │                            │
│                           │  category       │                            │
│                           └─────────────────┘                            │
│                                                                          │
│  ┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐       │
│  │  warehouses │────▶│ warehouse_stock │     │    materials     │       │
│  │             │     │                 │◀────│                  │       │
│  │  facility_id│     │  warehouse_id   │     │  code            │       │
│  │  name       │     │  material_id    │     │  barcode         │       │
│  │  type       │     │  quantity       │     │  name            │       │
│  └─────────────┘     │  reorder_level  │     │  unit            │       │
│                       └─────────────────┘     │  min_stock       │       │
│                                               └──────────────────┘       │
│                                                                          │
│  ┌─────────────┐     ┌─────────────────┐     ┌──────────────────┐       │
│  │   studies   │────▶│   study_items   │     │ study_categories │       │
│  │             │     │                 │     │                  │       │
│  │  patient_id │     │  study_id       │     │  code            │       │
│  │  number     │     │  name           │     │  name            │       │
│  │  category_id│     │  result         │     │  description     │       │
│  │  status     │     └─────────────────┘     └──────────────────┘       │
│  │  signed_at  │                                                         │
│  └─────────────┘     ┌─────────────────┐     ┌──────────────────┐       │
│                       │study_attachments│     │ study_templates  │       │
│  ┌─────────────┐     │                 │     │                  │       │
│  │ rips_batches│     │  study_id       │     │  category_id     │       │
│  │             │     │  file_url       │     │  name            │       │
│  │  facility_id│     │  file_name      │     │  fields (JSONB)  │       │
│  │  number     │     └─────────────────┘     └──────────────────┘       │
│  │  period     │                                                         │
│  │  status     │     ┌─────────────────┐     ┌──────────────────┐       │
│  │  files      │     │ medical_staff   │     │   specialties    │       │
│  └─────────────┘     │                 │     │                  │       │
│                       │  user_id        │     │  name            │       │
│  ┌─────────────┐     │  specialty_id   │     │  code            │       │
│  │  inv_entries│     │  license_number │     └──────────────────┘       │
│  │  inv_dispatch│    │  facility_id    │                                │
│  │  inv_counts │     └─────────────────┘     ┌──────────────────┐       │
│  └─────────────┘                              │  patient_accounts│       │
│                       ┌─────────────────┐     │  (portal)        │       │
│                       │provider_reviews │     │  patient_id      │       │
│                       │                 │     │  email           │       │
│                       │  patient_id     │     │  password_hash   │       │
│                       │  provider_id    │     │  is_verified     │       │
│                       │  appointment_id │     └──────────────────┘       │
│                       │  rating (1-5)   │                                │
│                       │  comment        │     ┌──────────────────┐       │
│                       │  status         │     │  public_providers│       │
│                       └─────────────────┘     │                  │       │
│                                               │  slug            │       │
│  ┌─────────────┐     ┌─────────────────┐     │  name, specialty │       │
│  │   users     │     │    facilities   │     │  city, rating    │       │
│  │             │     │                 │     │  insurances      │       │
│  │  email      │     │  name           │     │  is_accepting    │       │
│  │  password   │     │  address        │     └──────────────────┘       │
│  │  role       │     │  phone          │                                │
│  │  is_active  │     │  nit            │     ┌──────────────────┐       │
│  └─────────────┘     └─────────────────┘     │   audit_logs     │       │
│                                               │   settings       │       │
│                                               │   permissions    │       │
│                                               └──────────────────┘       │
└──────────────────────────────────────────────────────────────────────────┘
```

## sqlc Usage

### Configuration (sqlc.yaml)

```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "db/queries/"
    schema: "db/migrations/"
    gen:
      go:
        package: "sqlcgen"
        out: "internal/infrastructure/persistence/sqlcgen"
        sql_package: "pgx/v5"
        emit_json_tags: true
        emit_db_tags: true
```

### Query Pattern

```sql
-- db/queries/patients.sql

-- name: GetPatientByID :one
SELECT * FROM patients WHERE id = $1 AND deleted_at IS NULL;

-- name: ListPatients :many
SELECT * FROM patients
WHERE deleted_at IS NULL
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: SearchPatients :many
SELECT * FROM patients
WHERE deleted_at IS NULL
  AND (
    first_name ILIKE '%' || $1 || '%'
    OR last_name ILIKE '%' || $1 || '%'
    OR document_number ILIKE '%' || $1 || '%'
  )
ORDER BY last_name, first_name
LIMIT $2 OFFSET $3;

-- name: CreatePatient :one
INSERT INTO patients (
  id, document_type, document_number, first_name, last_name,
  birth_date, gender, phone, email, insurance_id, created_at
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW())
RETURNING *;
```

### Generated Code Usage

```go
// Repository uses generated sqlc queries
func (r *PatientRepository) GetByID(ctx context.Context, id uuid.UUID) (*domain.Patient, error) {
    row, err := r.queries.GetPatientByID(ctx, id)
    if err != nil {
        if errors.Is(err, pgx.ErrNoRows) {
            return nil, ErrNotFound
        }
        return nil, err
    }
    return mapRowToPatient(row), nil
}
```

## Migration Strategy

### Tool: goose

```bash
# Create new migration
goose -dir db/migrations create add_studies_table sql

# Run migrations
goose -dir db/migrations postgres "$DATABASE_URL" up

# Rollback
goose -dir db/migrations postgres "$DATABASE_URL" down
```

### Migration Naming

```
db/migrations/
├── 00001_initial_schema.sql
├── 00002_add_appointments.sql
├── 00003_add_billing.sql
├── 00004_add_inventory.sql
├── 00005_add_studies.sql
├── 00006_add_rips.sql
├── 00007_add_patient_portal.sql
├── 00008_add_provider_reviews.sql
├── 00009_add_fhir_support.sql
└── ...
```

## Init Scripts (Docker)

These run automatically when PostgreSQL container is created:

```
backend/db/init/
├── 01_schema.sql        # Table creation (DDL)
├── 02_users.sql         # Default users + roles
└── 03_seed_data.sql     # Test data (specialties, facilities, sample patients)
```

## Key Design Decisions

### UUIDs for Primary Keys
All tables use UUID v4 primary keys for distributed ID generation.

### Soft Deletes
Most entities use `deleted_at TIMESTAMP` for soft deletes. Queries always filter `WHERE deleted_at IS NULL`.

### JSONB for Flexible Content
- `patient_events.content` — SOAP notes, vitals, prescriptions (schema varies by event type)
- `study_templates.fields` — Template field definitions
- `rips_batches.files` — Generated file metadata

### Timestamps
All tables include `created_at` and `updated_at` timestamps. Some entities also have `deleted_at` for soft deletes.

### Foreign Keys
All relationships use UUID foreign keys with proper constraints. Cascading deletes are NOT used — all deletes are soft.

## Redis Usage

| Key Pattern | TTL | Purpose |
|-------------|-----|---------|
| `session:{user_id}` | 7 days | Active session data |
| `token_blacklist:{jti}` | 15 min | Revoked access tokens |
| `rate_limit:{ip}` | 1 min | Rate limiting counters |
| `cache:patient:{id}` | 5 min | Frequently accessed patients |
| `cache:schedule:{provider}:{date}` | 1 min | Provider availability |
