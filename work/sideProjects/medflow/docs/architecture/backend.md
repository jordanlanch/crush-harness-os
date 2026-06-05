# Backend Architecture

## Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    interface/http/                           │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  Router   │  │  Middleware  │  │      Handlers        │  │
│  │  (Echo)   │  │  Auth/CORS  │  │  Parse → Validate →  │  │
│  │           │  │  Log/Recover│  │  Call UseCase → JSON  │  │
│  └──────────┘  └──────────────┘  └──────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                    application/                              │
│  ┌──────────────────────┐  ┌─────────────────────────────┐  │
│  │        DTOs          │  │        Use Cases            │  │
│  │  Request/Response    │  │  Business logic, validation │  │
│  │  (never expose       │  │  Calls repository interfaces│  │
│  │   domain entities)   │  │  Returns DTOs              │  │
│  └──────────────────────┘  └─────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                      domain/                                 │
│  ┌──────────────────────┐  ┌─────────────────────────────┐  │
│  │      Entities        │  │      Repository Interfaces  │  │
│  │  Pure Go structs     │  │  Defined in domain layer    │  │
│  │  No framework deps   │  │  Implemented in infra       │  │
│  └──────────────────────┘  └─────────────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                   infrastructure/                            │
│  ┌────────────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌───────┐  │
│  │ persistence│  │  ai  │  │ fhir │  │email │  │  pdf  │  │
│  │ pgx/sqlc   │  │gateway│  │mapper│  │resend│  │render │  │
│  └────────────┘  └──────┘  └──────┘  └──────┘  └───────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Directory Structure

```
backend/
├── cmd/api/main.go                    # Entry point, Uber Fx wiring
├── internal/
│   ├── config/                        # Viper config + Fx modules
│   │   ├── config.go                  # Config struct (MEDNEXT_* env prefix)
│   │   ├── database.go                # DatabaseModule (pgx pool)
│   │   ├── redis.go                   # RedisModule
│   │   ├── ai.go                      # AIModule (provider configs)
│   │   └── email.go                   # EmailModule (Resend/Log)
│   │
│   ├── domain/                        # 14 domain entities
│   │   ├── patient/                   # Patient entity + repository interface
│   │   ├── patient_event/             # Clinical events (SOAP notes)
│   │   ├── patient_account/           # Patient portal accounts
│   │   ├── appointment/               # Appointments
│   │   ├── schedule/                  # Provider schedules + blocks
│   │   ├── billing/                   # Account, Invoice, Payment, Service
│   │   ├── inventory/                 # Warehouse, Material, Stock, Movement
│   │   ├── study/                     # Lab studies, categories, templates
│   │   ├── rips/                      # RIPS batches, validation
│   │   ├── medical_staff/             # Healthcare providers
│   │   ├── provider_review/           # Patient reviews of providers
│   │   ├── public_provider/           # Public search profiles
│   │   ├── specialty/                 # Medical specialties
│   │   └── email/                     # Email types + templates
│   │
│   ├── application/
│   │   ├── dto/                       # Request/Response DTOs per entity
│   │   │   ├── patient/
│   │   │   ├── appointment/
│   │   │   ├── schedule/
│   │   │   ├── patient_event/
│   │   │   ├── patient_portal/
│   │   │   ├── provider_review/
│   │   │   └── public_provider/
│   │   ├── usecase/                   # Business logic
│   │   │   ├── interfaces.go          # All UseCase interfaces
│   │   │   ├── patient/               # PatientUseCase
│   │   │   ├── patient_event/         # PatientEventUseCase
│   │   │   ├── appointment/           # AppointmentUseCase
│   │   │   ├── schedule/              # ScheduleUseCase
│   │   │   ├── patient_portal/        # PatientPortalUseCase
│   │   │   ├── provider_review/       # ProviderReviewUseCase
│   │   │   ├── public_provider/       # PublicProviderUseCase
│   │   │   ├── billing_usecase.go     # BillingUseCase
│   │   │   ├── inventory_usecase.go   # InventoryUseCase
│   │   │   ├── study_usecase.go       # StudyUseCase
│   │   │   ├── rips_usecase.go        # RIPSUseCase
│   │   │   ├── admin_usecase.go       # AdminUseCase
│   │   │   └── report_usecase.go      # ReportUseCase
│   │   └── module.go                  # application.Module (Fx)
│   │
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   ├── repository/            # pgx/sqlc repository implementations
│   │   │   └── module.go              # persistence.Module (Fx)
│   │   ├── ai/
│   │   │   ├── gateway.go             # AIGateway (multi-provider)
│   │   │   └── providers/             # OpenAI, Anthropic, LocalLLM
│   │   ├── fhir/
│   │   │   └── transformer.go         # Domain → FHIR R4 mapper
│   │   ├── email/
│   │   │   ├── service.go             # EmailService interface
│   │   │   └── providers/             # Resend (prod), Log (dev)
│   │   └── pdf/
│   │       └── renderer.go            # PDF generation
│   │
│   └── interface/http/
│       ├── handler/                   # 18 handlers (one per resource)
│       ├── middleware/
│       │   ├── auth.go                # JWT staff auth
│       │   ├── patient_auth.go        # JWT patient portal auth
│       │   ├── role.go                # Role-based access (RequireRole)
│       │   ├── cors.go                # CORS configuration
│       │   ├── logger.go              # Request logging (zerolog)
│       │   └── recover.go             # Panic recovery
│       ├── router/
│       │   └── router.go             # All route registration
│       └── module.go                  # http.Module (Fx)
│
├── pkg/                               # Shared utilities
│   ├── auth/                          # GetUserIDFromContext, HasRole
│   ├── response/                      # Success/Error JSON helpers
│   ├── pagination/                    # NewPagination (max 100 per page)
│   └── validator/                     # Echo validator wrapper
│
├── db/
│   ├── queries/                       # sqlc .sql query files
│   ├── migrations/                    # goose migration files
│   └── init/                          # Docker init scripts
│       ├── 01_schema.sql
│       ├── 02_users.sql
│       └── 03_seed_data.sql
│
└── sqlc.yaml                          # sqlc configuration
```

## Domain Entities (14)

| Entity | Key Fields | Repository Methods |
|--------|------------|-------------------|
| **Patient** | ID, DocumentType, DocumentNumber, FirstName, LastName, BirthDate, Gender, Phone, Email, InsuranceID | Create, GetByID, GetByDocument, List, Search, Update, Delete |
| **PatientEvent** | ID, PatientID, ProviderID, EventType (SOAP/NOTE/LAB/PROCEDURE), Content (JSON), SignedAt, SignedBy | Create, GetByID, ListByPatient, Update, Delete, Sign |
| **Appointment** | ID, PatientID, ProviderID, FacilityID, ScheduleSlotID, Status (scheduled/confirmed/in_progress/completed/cancelled/no_show), StartTime, EndTime | Create, GetByID, ListByDateRange, ListByPatient, ListByProvider, Update, UpdateStatus, Delete |
| **Schedule** | ID, ProviderID, FacilityID, DayOfWeek, StartTime, EndTime, SlotDuration, IsActive | Create, GetByID, ListByProvider, GetAvailableSlots, Update, Delete |
| **ScheduleBlock** | ID, ScheduleID, ProviderID, StartTime, EndTime, Reason | Create, GetByID, ListByProviderAndDate, Delete |
| **Account** | ID, PatientID, FacilityID, Number, Status (open/closed/cancelled), TotalAmount | Create, GetByID, GetByNumber, ListByPatient, ListByFacility, Update, Close, Cancel |
| **Invoice** | ID, AccountID, Number, Items, TotalAmount, TaxAmount | Created via Account close |
| **Payment** | ID, AccountID, Method, Amount, Reference | Create, GetByID, ListByAccount, Cancel |
| **Service** (catalog) | ID, Code (CUPS), Name, Price, Category | Create, GetByID, GetByCode, List, Search, Update |
| **Warehouse** | ID, FacilityID, Name, Type | Create, GetByID, ListByFacility, Update |
| **Material** | ID, Code, Barcode, Name, Unit, MinStock | Create, GetByID, GetByCode, GetByBarcode, List, Search, Update |
| **WarehouseStock** | WarehouseID, MaterialID, Quantity, ReorderLevel | List, Get, LowStockAlerts |
| **Study** | ID, PatientID, Number, CategoryID, Status (ordered/in_progress/completed/signed/delivered), Items, Attachments | Create, GetByID, GetByNumber, Search, Update, Sign, Deliver, ListByPatient, ListByFacility |
| **RIPSBatch** | ID, FacilityID, Number, PeriodStart, PeriodEnd, Status (DRAFT/VALIDATING/VALID/INVALID/GENERATED/SUBMITTED), FileTypes | Create, GetByID, GetByNumber, List, Update, Delete, Validate, Generate, Download |
| **MedicalStaff** | ID, UserID, SpecialtyID, LicenseNumber, FacilityID | (managed via Admin) |
| **ProviderReview** | ID, PatientID, ProviderID, AppointmentID, Rating, Comment, Status (pending/approved/rejected) | Create, ListByProvider, ListPending, Approve, Reject, CanReview |
| **PublicProvider** | ID, Slug, Name, Specialty, City, Rating, AvailableSlots, IsAcceptingNew, Insurances | Search, GetByID, GetBySlug, GetFeatured, GetAvailability, GetSpecialties, GetCities, GetInsurances |

## Uber Fx Dependency Injection

```
main.go
  │
  ├── config.NewConfig              # Load MEDNEXT_* env vars via Viper
  │
  ├── config.DatabaseModule         # pgxpool.Pool (PostgreSQL connection pool)
  ├── config.RedisModule            # redis.Client
  ├── config.AIModule               # AI provider configs (OpenAI, Anthropic, Local)
  ├── config.EmailModule            # Email provider (Resend or Log)
  │
  ├── persistence.Module            # All repository implementations
  │   ├── NewPatientRepository
  │   ├── NewPatientEventRepository
  │   ├── NewAppointmentRepository
  │   ├── NewScheduleRepository
  │   ├── NewBillingRepository
  │   ├── NewInventoryRepository
  │   ├── NewStudyRepository
  │   ├── NewRIPSRepository
  │   ├── NewMedicalStaffRepository
  │   ├── NewProviderReviewRepository
  │   ├── NewPublicProviderRepository
  │   └── NewPatientPortalRepository
  │
  ├── application.Module            # All use cases
  │   ├── NewPatientUseCase
  │   ├── NewPatientEventUseCase
  │   ├── NewAppointmentUseCase
  │   ├── NewScheduleUseCase
  │   ├── NewBillingUseCase
  │   ├── NewInventoryUseCase
  │   ├── NewStudyUseCase
  │   ├── NewRIPSUseCase
  │   ├── NewAdminUseCase
  │   ├── NewReportUseCase
  │   ├── NewAIUseCase
  │   ├── NewFHIRUseCase
  │   ├── NewPublicProviderUseCase
  │   ├── NewPatientPortalUseCase
  │   ├── NewProviderReviewUseCase
  │   └── NewEmailUseCase
  │
  └── http.Module                   # Echo server + all handlers + route registration
      ├── NewEchoServer
      ├── NewMiddleware
      ├── New{Entity}Handler (×18)
      └── RegisterRoutes
```

## Handlers (18)

| Handler | File | Routes Registered |
|---------|------|-------------------|
| HealthHandler | `health.go` | `/health`, `/health/ready`, `/health/live` |
| MetricsHandler | `metrics_handler.go` | `/metrics` (Prometheus) |
| AuthHandler | `auth_handler.go` | `/api/v1/auth/*` (login, register, refresh, logout, me) |
| PatientHandler | `patient.go` | `/api/v1/patients/*` |
| PatientEventHandler | `patient_event.go` | `/api/v1/patients/:id/events/*`, `/api/v1/events/*` |
| AppointmentHandler | `appointment.go` | `/api/v1/appointments/*`, patient/provider/facility lookups |
| ScheduleHandler | `schedule.go` | `/api/v1/schedules/*`, `/api/v1/schedule-blocks/*`, provider availability |
| BillingHandler | `billing.go` | `/api/v1/accounts/*`, `/api/v1/payments/*`, `/api/v1/services/*` |
| InventoryHandler | `inventory.go` | `/api/v1/warehouses/*`, `/api/v1/materials/*`, entries/dispatches/counts |
| StudyHandler | `study.go` | `/api/v1/studies/*`, `/api/v1/study-categories/*`, `/api/v1/study-templates/*` |
| RIPSHandler | `rips.go` | `/api/v1/rips/batches/*` |
| ReportHandler | `report.go` | `/api/v1/reports/*` (templates, generate, stats) |
| AdminHandler | `admin.go` | `/api/v1/admin/*` (users, permissions, roles, settings, facilities, audit) |
| AIHandler | `ai.go` | `/api/v1/ai/*` (transcription, SOAP, CDSS, chatbot, triage) |
| PublicProviderHandler | `public_provider.go` | `/api/v1/public/providers/*`, specialties, cities, insurances |
| PatientPortalHandler | `patient_portal.go` | `/api/v1/patient-portal/*` (auth, profile, bookings) |
| ProviderReviewHandler | `provider_review.go` | Public reviews, portal create, admin moderation |
| FHIRHandler | `fhir.go` | `/api/v1/fhir/*` (metadata, Patient, Encounter, $everything) |

## Middleware Stack

```
Request
  │
  ├── RequestID()          # Unique request ID header
  ├── Logger()             # zerolog request logging
  ├── Recover()            # Panic recovery
  ├── CORS()               # Configurable origins
  │
  ├── [Route Group]
  │   ├── Auth()           # JWT validation for staff routes
  │   ├── PatientAuth()    # JWT validation for patient portal routes
  │   └── RequireRole()    # Role-based access (admin only)
  │
  ▼
Handler
```

## Packages (pkg/)

| Package | Key Functions | Usage |
|---------|--------------|-------|
| `pkg/response` | `Success(c, data)`, `SuccessWithMeta(c, data, meta)`, `Error(c, code, msg)`, `ValidationError(c, errs)` | Standardized JSON responses |
| `pkg/pagination` | `NewPagination(page, limit)` → max 100 per page, defaults to page=1, limit=20 | Query pagination |
| `pkg/validator` | `New()` → Echo validator using go-playground/validator/v10 | Request struct validation |
| `pkg/auth` | `GetUserIDFromContext(c)`, `GetRoleFromContext(c)`, `HasRole(c, role)` | Extract JWT claims from Echo context |

## Testing Strategy

```
        E2E (10%)           ← Full API flows (Playwright)
      Integration (30%)     ← Repository + real DB (testcontainers-go)
     Unit Tests (60%)       ← UseCases + Handlers with mocks (testify)
```

- Unit tests: `*_test.go` files alongside source
- Integration tests: Use testcontainers-go for real PostgreSQL
- Mocking: `testify/mock` for repository interfaces
- Run: `make test` (all), `make test-unit`, `make test-integration`, `make test-coverage`
