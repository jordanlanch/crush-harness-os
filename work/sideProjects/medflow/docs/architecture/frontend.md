# Frontend Architecture

## Angular 19 Configuration

| Setting | Value | Why |
|---------|-------|-----|
| Components | **Standalone only** | No NgModules (Angular 19+) |
| Change Detection | **Zoneless** | `provideExperimentalZonelessChangeDetection()` |
| State (local) | **Signals** | Angular Signals for component state |
| State (shared) | **NgRx Signal Store** | `signalStore()` for cross-component state |
| Build | **ESBuild** | Fast builds, ES2022 target |
| CSS | **Tailwind v4** | OKLCH color system, utility-first |
| Control Flow | `@if` `@for` `@switch` | New template syntax (no `*ngIf`/`*ngFor`) |
| Testing | **Vitest** + **Playwright** | Unit + E2E |

## Directory Structure

```
frontend/src/app/
├── core/                                  # Singleton services (provided in root)
│   ├── services/
│   │   ├── api.service.ts                 # Base HTTP (HttpClient wrapper)
│   │   ├── auth.service.ts                # JWT login/logout/refresh, token storage
│   │   ├── session.service.ts             # isAuthenticated(), currentUser signal
│   │   ├── theme.service.ts               # Light/dark toggle, localStorage 'mn-theme'
│   │   ├── seo.service.ts                 # Meta tags, JSON-LD, Open Graph
│   │   └── ai-soap.service.ts             # SOAP note generation via AI API
│   ├── guards/
│   │   ├── auth.guard.ts                  # authGuard (staff), publicGuard (redirect authed)
│   │   └── patient-auth.guard.ts          # patientAuthGuard (patient portal)
│   ├── interceptors/
│   │   ├── auth.interceptor.ts            # Attach Bearer token (dual: staff vs patient)
│   │   ├── error.interceptor.ts           # Status → friendly message, 401 → logout
│   │   └── response.interceptor.ts        # Unwrap { success, data } → data
│   └── models/
│       └── *.ts                           # TypeScript interfaces/types
│
├── shared/                                # Reusable across features
│   ├── components/                        # 19 shared components
│   │   ├── button-loading/                # Loading button with spinner
│   │   ├── loading-spinner/               # Full-page spinner
│   │   ├── modal/                         # Generic modal wrapper
│   │   ├── toast/                         # Toast notification system
│   │   ├── skeleton-loader/               # Content placeholder
│   │   ├── data-grid/                     # Sortable, paginated table
│   │   ├── empty-state/                   # No data placeholder
│   │   ├── form-error/                    # Form validation display
│   │   ├── confirm-dialog/                # Confirmation modal
│   │   ├── patient-search-dialog/         # Patient search popup
│   │   ├── rich-text-editor/              # Quill.js wrapper
│   │   ├── time-slot-picker/              # Appointment slot selector
│   │   ├── specialty-selector/            # Medical specialty dropdown
│   │   ├── breadcrumb/                    # Route-based breadcrumbs
│   │   ├── public-header/                 # Public pages header
│   │   ├── theme-toggle/                  # Dark/light switch
│   │   ├── star-rating/                   # Star rating display/input
│   │   ├── icon/                          # SVG icon wrapper
│   │   └── footer/                        # Page footer
│   ├── directives/
│   │   ├── autofocus.directive.ts         # appAutofocus
│   │   └── click-outside.directive.ts     # appClickOutside
│   └── pipes/
│       ├── currency-cop.pipe.ts           # Colombian peso format ($1.234.567)
│       └── date-format.pipe.ts            # 6 formats including relative ("hace 2h")
│
├── layout/
│   ├── unified-layout/                    # Staff + Patient layout (sidebar + header)
│   │   └── unified-layout.component.ts
│   └── public-layout/                     # Public pages (minimal header + footer)
│       └── public-layout.component.ts
│
├── store/
│   └── app.store.ts                       # AppStore (sidebar, notifications, loading)
│
├── features/                              # Lazy-loaded feature modules (16)
│   ├── dashboard/                         # KPIs, charts, quick actions
│   ├── patients/                          # CRUD, search, documents, photo
│   ├── appointments/                      # Calendar, create, status management
│   ├── clinical-records/                  # SOAP notes, history, signing
│   ├── billing/                           # Accounts, payments, services catalog
│   ├── inventory/                         # Warehouses, materials, stock movements
│   ├── studies/                           # Lab orders, results, templates
│   ├── rips/                              # RIPS batch management
│   ├── reports/                           # Statistics, report generation
│   ├── admin/                             # User management, settings, audit
│   ├── auth/                              # Login, unauthorized pages
│   ├── patient-portal/                    # Patient self-service portal
│   ├── public/                            # Provider search, profiles
│   ├── landing/                           # Marketing/landing page
│   ├── legal/                             # Terms, privacy policy
│   └── not-found/                         # 404 page
│
├── app.routes.ts                          # Root routing configuration
├── app.component.ts                       # Root component
└── app.config.ts                          # App providers config

e2e/
├── pages/                                 # Page Object Models
└── tests/                                 # Playwright specs
```

## Feature Modules (16)

### Staff Features

| Feature | Route | Key Components | Store |
|---------|-------|----------------|-------|
| **Dashboard** | `/dashboard` | DashboardComponent | AppStore |
| **Patients** | `/patients` | PatientListComponent, PatientDetailComponent, PatientFormComponent | PatientStore |
| **Appointments** | `/appointments` | AppointmentCalendarComponent, AppointmentFormComponent, AppointmentDetailComponent | AppointmentStore |
| **Clinical Records** | `/clinical-records` | ClinicalRecordListComponent, SoapFormComponent, EventTimelineComponent | PatientEventStore |
| **Billing** | `/billing` | AccountListComponent, AccountDetailComponent, PaymentFormComponent, ServiceCatalogComponent | (local signals) |
| **Inventory** | `/inventory` | WarehouseListComponent, MaterialListComponent, StockOverviewComponent, EntryFormComponent | (local signals) |
| **Studies** | `/studies` | StudyListComponent, StudyDetailComponent, StudyFormComponent | (local signals) |
| **RIPS** | `/rips` | RipsBatchListComponent, RipsBatchDetailComponent | (local signals) |
| **Reports** | `/reports` | ReportDashboardComponent, ReportGeneratorComponent | (local signals) |
| **Admin** | `/admin` | UserListComponent, UserFormComponent, SettingsComponent, AuditLogComponent | (local signals) |

### Patient Portal Features

| Feature | Route | Key Components | Store |
|---------|-------|----------------|-------|
| **Portal Dashboard** | `/patient-portal/dashboard` | PatientDashboardComponent | PatientAuthStore |
| **Portal Appointments** | `/patient-portal/appointments` | MyAppointmentsComponent, BookAppointmentComponent, AppointmentDetailComponent | PatientAuthStore |
| **Portal Reviews** | `/patient-portal/reviews/:id` | WriteReviewComponent | PatientAuthStore |
| **Portal Profile** | `/patient-portal/profile` | PatientProfileComponent | PatientAuthStore |
| **Portal Settings** | `/patient-portal/settings` | PatientSettingsComponent | PatientAuthStore |

### Public Features

| Feature | Route | Key Components |
|---------|-------|----------------|
| **Landing** | `/` | LandingComponent (hero, features, testimonials, CTA) |
| **Login** | `/login` | LoginComponent (dual: staff + patient via `?type=patient`) |
| **Provider Search** | `/providers` | ProviderSearchComponent, ProviderProfileComponent |
| **Patient Register** | `/patient-portal/register` | PatientRegisterComponent |

## Routing Architecture

```
app.routes.ts
│
├── AUTHENTICATED (canMatch: isAuthenticated())
│   └── UnifiedLayoutComponent (sidebar + header + router-outlet)
│       │
│       ├── /dashboard                 ← authGuard (staff)
│       ├── /patients/**               ← authGuard, lazy PATIENTS_ROUTES
│       ├── /appointments/**           ← authGuard, lazy APPOINTMENTS_ROUTES
│       ├── /clinical-records/**       ← authGuard, lazy CLINICAL_RECORDS_ROUTES
│       ├── /billing/**                ← authGuard, lazy BILLING_ROUTES
│       ├── /inventory/**              ← authGuard, lazy INVENTORY_ROUTES
│       ├── /studies/**                ← authGuard, lazy STUDIES_ROUTES
│       ├── /rips/**                   ← authGuard, lazy RIPS_ROUTES
│       ├── /reports/**                ← authGuard, lazy REPORTS_ROUTES
│       ├── /admin/**                  ← authGuard, lazy ADMIN_ROUTES
│       ├── /settings                  ← authGuard
│       │
│       └── /patient-portal/**         ← patientAuthGuard
│           ├── /dashboard
│           ├── /appointments
│           ├── /book
│           ├── /reviews/:id
│           ├── /profile
│           └── /settings
│
├── PUBLIC (fallthrough when not authenticated)
│   └── PublicLayoutComponent (minimal header + footer + router-outlet)
│       │
│       ├── /                          ← LandingComponent
│       ├── /login                     ← publicGuard (redirects authed users)
│       ├── /patient-portal/register   ← PatientRegisterComponent
│       ├── /providers/**              ← PUBLIC_ROUTES (search, profile)
│       └── /unauthorized
│
└── /** (catch-all)                    ← NotFoundComponent
```

## State Management

### NgRx Signal Store Pattern

```typescript
// Example: PatientStore
export const PatientStore = signalStore(
  { providedIn: 'root' },
  withState<PatientState>({
    patients: [],
    selectedPatient: null,
    loading: false,
    error: null,
    pagination: { page: 1, limit: 20, total: 0 },
  }),
  withComputed((store) => ({
    hasPatients: computed(() => store.patients().length > 0),
    isLoading: computed(() => store.loading()),
  })),
  withMethods((store, apiService = inject(ApiService)) => ({
    loadPatients: rxMethod<{ page: number; limit: number }>(
      pipe(
        tap(() => patchState(store, { loading: true })),
        switchMap(({ page, limit }) =>
          apiService.get<PaginatedResponse<Patient>>(`/patients?page=${page}&limit=${limit}`)
        ),
        tap((response) => patchState(store, {
          patients: response.data,
          pagination: response.meta,
          loading: false,
        })),
      ),
    ),
  })),
);
```

### Stores

| Store | Location | Scope | State |
|-------|----------|-------|-------|
| **AppStore** | `store/app.store.ts` | Global | sidebar, notifications, loading, user |
| **PatientStore** | `features/patients/` | Feature | patients[], selectedPatient, pagination |
| **AppointmentStore** | `features/appointments/` | Feature | appointments[], calendar view, filters |
| **PatientEventStore** | `features/clinical-records/` | Feature | events[], selectedEvent, timeline |
| **PatientAuthStore** | `features/patient-portal/` | Feature | patientProfile, bookings, auth state |

## Theme System

```
┌─────────────────────────────────────────────────────┐
│                  Theme Architecture                  │
│                                                      │
│  ThemeService                                        │
│  ├── Reads localStorage('mn-theme')                  │
│  ├── Sets document.documentElement.dataset.theme     │
│  └── Provides theme$ signal                          │
│                                                      │
│  Tailwind v4 (OKLCH Colors)                          │
│  ├── --mn-bg-page, --mn-bg-surface                   │
│  ├── --mn-text-heading, --mn-text-body               │
│  ├── --mn-border, --mn-accent                        │
│  └── Toggle via data-theme="dark" attribute          │
│                                                      │
│  Brand Colors:                                       │
│  ├── Primary:   #2586C9 (cerulean blue)              │
│  ├── Secondary: #235092 (medium blue)                │
│  ├── Navy:      #131751 (deep navy)                  │
│  └── Light:     #698DBB (light blue)                 │
└─────────────────────────────────────────────────────┘
```

## Interceptors

```
HTTP Request
  │
  ├── authInterceptor
  │   ├── Checks URL path
  │   ├── If /patient-portal/* → uses patient_access_token
  │   ├── Else → uses access_token (staff)
  │   └── Attaches: Authorization: Bearer <token>
  │
  ├── responseInterceptor
  │   └── Unwraps { success: true, data: {...} } → returns data directly
  │
  ├── errorInterceptor
  │   ├── 401 → AuthService.logout() + redirect /login
  │   ├── 403 → "No tiene permisos"
  │   ├── 404 → "Recurso no encontrado"
  │   ├── 422 → Validation errors
  │   └── 500 → "Error interno del servidor"
  │
  ▼
HTTP Response
```

## Guards

| Guard | Purpose | Behavior |
|-------|---------|----------|
| `authGuard` | Staff authentication | Checks `access_token` in localStorage → redirect `/login` if missing |
| `publicGuard` | Redirect authenticated users | If authenticated → redirect `/dashboard` |
| `patientAuthGuard` | Patient portal auth | Checks `patient_access_token` → redirect `/login?type=patient` |

## SEO

| Feature | Implementation |
|---------|---------------|
| Dynamic Meta Tags | `SeoService.setMeta()` — title, description, keywords per route |
| Open Graph | og:title, og:description, og:image, og:url |
| Twitter Cards | twitter:card, twitter:title, twitter:description |
| JSON-LD | Organization, MedicalBusiness, FAQPage schemas |
| Breadcrumbs | `BreadcrumbList` JSON-LD from route data |

## Path Aliases

```json
{
  "@app/*": ["src/app/*"],
  "@core/*": ["src/app/core/*"],
  "@shared/*": ["src/app/shared/*"],
  "@features/*": ["src/app/features/*"],
  "@env/*": ["src/environments/*"]
}
```

## Testing

| Type | Tool | Config | Threshold |
|------|------|--------|-----------|
| Unit | Vitest | `vitest.config.ts` | 75% coverage |
| E2E | Playwright | `playwright.config.ts` | Page Object pattern |

```bash
npm test                    # Vitest watch mode
npm run test:coverage       # Coverage report
npm run e2e                 # Playwright (headless)
npm run e2e:ui              # Playwright (interactive)
```
