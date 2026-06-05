# MedNext - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  CLIENTS                                        │
│                                                                                 │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│   │ Doctors  │  │Reception │  │  Admin   │  │ Patients │  │ Public   │       │
│   │ (Staff)  │  │ (Staff)  │  │ (Staff)  │  │ (Portal) │  │ (Search) │       │
│   └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘       │
│        │              │              │              │              │             │
│        └──────────────┴──────────────┴──────────────┴──────────────┘             │
│                                      │                                           │
├──────────────────────────────────────┼───────────────────────────────────────────┤
│                                      ▼                                           │
│                       ┌─────────────────────────────┐                            │
│                       │      Angular 19 SPA          │                            │
│                       │  Zoneless · Standalone · NgRx │                            │
│                       │  Tailwind 4 · OKLCH Theme     │                            │
│                       └──────────────┬──────────────┘                            │
│                                      │ HTTPS/REST                                │
│                                      ▼                                           │
│                       ┌─────────────────────────────┐                            │
│                       │     Go Backend (Echo)        │                            │
│                       │  Clean Arch · DDD · CQRS     │                            │
│                       │  Uber Fx DI · pgx/sqlc       │                            │
│                       └──────────────┬──────────────┘                            │
│                                      │                                           │
│              ┌───────────────────────┼───────────────────────┐                   │
│              │                       │                       │                   │
│              ▼                       ▼                       ▼                   │
│   ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐              │
│   │   PostgreSQL 16  │  │    Redis 7       │  │   AI Gateway     │              │
│   │   pgx/v5 + sqlc  │  │  Sessions/Cache  │  │ OpenAI/Anthropic │              │
│   │   40+ tables     │  │                  │  │ MedASR/Llama     │              │
│   └──────────────────┘  └──────────────────┘  └──────────────────┘              │
│                                                                                  │
├──────────────────────────────────────────────────────────────────────────────────┤
│                         EXTERNAL INTEGRATIONS                                    │
│                                                                                  │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│   │   DIAN   │  │  Resend  │  │   FHIR   │  │  ADRES   │  │  Dataico │        │
│   │ E-Factura│  │  Email   │  │ R4 API   │  │  RIPS    │  │  Billing │        │
│   └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└──────────────────────────────────────────────────────────────────────────────────┘
```

## Tech Stack

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Backend** | Go | 1.24+ | API server |
| HTTP Framework | Echo | v4.12+ | REST API routing |
| Database Driver | pgx | v5 | Native PostgreSQL driver |
| SQL Generation | sqlc | 1.25+ | Type-safe Go from SQL |
| DI Framework | Uber Fx | 1.22+ | Dependency injection + lifecycle |
| Logger | zerolog | latest | Structured JSON logging |
| Validator | go-playground | v10 | Request validation |
| Auth | golang-jwt | v5 | JWT access/refresh tokens |
| **Frontend** | Angular | 19+ | SPA (zoneless mode) |
| State | NgRx Signal Store | 19+ | Signal-based reactive state |
| CSS | Tailwind CSS | 4+ | Utility-first with OKLCH colors |
| **Database** | PostgreSQL | 16+ | Primary data store |
| **Cache** | Redis | 7+ | Sessions, caching, pub/sub |
| **AI** | OpenAI GPT-4o | latest | SOAP notes, CDSS, chatbot |
| **AI** | Google MedASR | latest | Medical speech-to-text |
| **Testing** | Vitest + Playwright | latest | Frontend unit + E2E |
| **Testing** | testify + testcontainers | latest | Backend unit + integration |

## Functional Modules

### Core Medical
| Module | Description | Backend Entity | Frontend Feature |
|--------|-------------|----------------|------------------|
| Patients | Full patient lifecycle | `patient` | `features/patients` |
| Clinical Records | SOAP notes, history, signing | `patient_event` | `features/clinical-records` |
| Appointments | Scheduling, status, calendar | `appointment` + `schedule` | `features/appointments` |
| Studies | Lab orders, pathology, results | `study` | `features/studies` |

### Financial
| Module | Description | Backend Entity | Frontend Feature |
|--------|-------------|----------------|------------------|
| Billing | Accounts, invoices, payments | `billing` (Account/Invoice/Payment) | `features/billing` |
| Inventory | Warehouses, stock, movements | `inventory` | `features/inventory` |

### Colombian Regulatory
| Module | Description | Backend Entity | Frontend Feature |
|--------|-------------|----------------|------------------|
| RIPS | Regulatory reports (8 file types) | `rips` | `features/rips` |
| FHIR R4 | Interoperability (Res. 1888/2025) | `fhir` (transformer) | N/A (API only) |
| Email/Notifications | Transactional emails via Resend | `email` | N/A (backend only) |

### Platform
| Module | Description | Backend Handler | Frontend Feature |
|--------|-------------|-----------------|------------------|
| Auth (Staff) | JWT login, register, refresh | `auth_handler` | `features/auth` |
| Patient Portal | Self-scheduling, reviews | `patient_portal` | `features/patient-portal` |
| Public Search | Provider search, profiles | `public_provider` | `features/public` |
| Provider Reviews | Ratings, moderation | `provider_review` | (in patient-portal) |
| Admin | Users, roles, settings, audit | `admin` | `features/admin` |
| Reports | Statistics, PDF generation | `report` | `features/reports` |
| AI Features | Scribe, CDSS, chatbot, triage | `ai` | (in clinical-records) |
| Dashboard | KPIs, charts, quick actions | N/A | `features/dashboard` |
| Landing | Marketing page, SEO | N/A | `features/landing` |

## Request Lifecycle

```
┌──────────┐     ┌──────────┐     ┌──────────────┐     ┌──────────────┐     ┌────────────┐
│  Client  │────▶│  Echo    │────▶│  Middleware   │────▶│   Handler    │────▶│  UseCase   │
│ (Angular)│     │ Router   │     │ (Auth/CORS/   │     │ (Validate +  │     │ (Business  │
│          │     │          │     │  Log/Recover) │     │  Parse DTO)  │     │  Logic)    │
└──────────┘     └──────────┘     └──────────────┘     └──────┬───────┘     └─────┬──────┘
                                                               │                   │
┌──────────┐     ┌──────────┐     ┌──────────────┐            │                   │
│  Client  │◀────│  JSON    │◀────│   Response    │◀───────────┘                   │
│          │     │ Response │     │  pkg/response │                                │
└──────────┘     └──────────┘     └──────────────┘                                │
                                                                                   │
                  ┌──────────────┐     ┌──────────────┐                            │
                  │  PostgreSQL  │◀────│  Repository  │◀───────────────────────────┘
                  │  (pgx/sqlc)  │     │  (Interface) │
                  └──────────────┘     └──────────────┘
```

## Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    TWO AUTH SYSTEMS                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  STAFF AUTH                    PATIENT PORTAL AUTH           │
│  ──────────                   ──────────────────            │
│  POST /api/v1/auth/login      POST /api/v1/patient-portal/  │
│                                     auth/login              │
│         │                              │                    │
│         ▼                              ▼                    │
│  ┌─────────────┐              ┌─────────────┐              │
│  │ JWT Token   │              │ JWT Token   │              │
│  │ access: 15m │              │ access: 15m │              │
│  │ refresh: 7d │              │ refresh: 7d │              │
│  │             │              │             │              │
│  │ Claims:     │              │ Claims:     │              │
│  │ - UserID    │              │ - PatientID │              │
│  │ - Email     │              │ - Email     │              │
│  │ - Role      │              │ - Type:     │              │
│  │ - FacilityID│              │   "patient" │              │
│  └─────────────┘              └─────────────┘              │
│         │                              │                    │
│         ▼                              ▼                    │
│  mw.Auth()                    mw.PatientAuth()             │
│  middleware                   middleware                    │
│         │                              │                    │
│         ▼                              ▼                    │
│  /api/v1/* routes             /api/v1/patient-portal/*     │
│  (staff endpoints)            (patient endpoints)           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 DigitalOcean VPS                         │
│                 138.197.89.224                           │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │               Dokploy Panel :3000                │   │
│  │                                                  │   │
│  │  ┌──────────────┐   ┌──────────────┐            │   │
│  │  │   Traefik    │   │   Dokploy    │            │   │
│  │  │ (Reverse     │   │   Manager    │            │   │
│  │  │  Proxy + SSL)│   │              │            │   │
│  │  └──────┬───────┘   └──────────────┘            │   │
│  │         │                                        │   │
│  │  ┌──────┼────────────────────────────────────┐  │   │
│  │  │      ▼        Docker Compose              │  │   │
│  │  │                                           │  │   │
│  │  │  ┌────────────────┐  ┌────────────────┐  │  │   │
│  │  │  │ mednext-frontend│  │  mednext-api   │  │  │   │
│  │  │  │ mednext.cloud   │  │ api.mednext.   │  │  │   │
│  │  │  │ :80             │  │ cloud :8080    │  │  │   │
│  │  │  └────────────────┘  └───────┬────────┘  │  │   │
│  │  │                              │            │  │   │
│  │  │  ┌────────────────┐  ┌──────┴─────────┐  │  │   │
│  │  │  │ mednext-redis  │  │ mednext-postgres│  │  │   │
│  │  │  │ :6379          │  │ :5432           │  │  │   │
│  │  │  └────────────────┘  └────────────────┘  │  │   │
│  │  │                                           │  │   │
│  │  │  ┌────────────────┐                       │  │   │
│  │  │  │ mednext-grafana│                       │  │   │
│  │  │  │ grafana.mednext│                       │  │   │
│  │  │  │ .cloud :3000   │                       │  │   │
│  │  │  └────────────────┘                       │  │   │
│  │  └───────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Domains (Namecheap DNS → 138.197.89.224):
  mednext.cloud         → Frontend
  api.mednext.cloud     → Backend API
  grafana.mednext.cloud → Monitoring
```

## Detailed Documentation

| Document | Content |
|----------|---------|
| [backend.md](./backend.md) | Clean Architecture layers, all 14 entities, DI wiring, Uber Fx modules |
| [frontend.md](./frontend.md) | Feature modules, stores, routing, theme system, guards, interceptors |
| [data-flow.md](./data-flow.md) | RIPS workflow, FHIR pipeline, AI features, email system |
| [api-catalog.md](./api-catalog.md) | Complete API reference — all 200+ endpoints by resource |
| [database.md](./database.md) | Schema overview, sqlc usage, migration strategy |
| [DOMAIN_PATTERNS.md](./DOMAIN_PATTERNS.md) | Domain patterns, repository interface, use case structure, DTOs, multi‑tenancy, RBAC |
