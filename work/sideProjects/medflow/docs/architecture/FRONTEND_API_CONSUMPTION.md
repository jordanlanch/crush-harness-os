# Frontend API Consumption Patterns

## Overview

All HTTP communication between the Angular frontend and the Go backend MUST use the centralized `ApiService`. This ensures consistent error handling, request/response transformation, and adherence to the backend's API contract.

## Core Principles

1. **Never use `HttpClient` directly** – always inject and use `ApiService`.
2. **Type all requests and responses** – leverage TypeScript interfaces generated from backend DTOs.
3. **Handle loading states in components** – use NgRx Signal Store or component signals.
4. **Let interceptors handle cross‑cutting concerns** – authentication, error display, response unwrapping.
5. **Follow the established service pattern** – consistent structure across all domain services.

## The ApiService

Located at `src/app/core/services/api.service.ts`, this service wraps Angular's `HttpClient` and provides:

- Automatic prefixing with `environment.apiUrl` (`/api/v1`)
- Consistent `ApiResponse<T>` wrapper for all responses
- Type‑safe methods (`get`, `post`, `put`, `patch`, `delete`, `upload`)
- Built‑in parameter serialization

### ApiResponse Interface

```typescript
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  meta?: PaginationMeta;
  error?: ApiError;
}
```

- `success`: `true` for successful responses, `false` for errors.
- `data`: The actual payload (absent in error responses).
- `meta`: Pagination metadata (when applicable).
- `error`: Structured error details (present only when `success` is `false`).

## Creating a Domain Service

Every domain (Patient, Appointment, Clinical Record, etc.) should have its own service in `src/app/core/services/`. Follow this template:

```typescript
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiService } from './api.service';
import { Patient, PatientSearchParams, CreatePatientRequest } from '../models/patient.model';

@Injectable({ providedIn: 'root' })
export class PatientService {
  private readonly api = inject(ApiService);
  private readonly basePath = '/patients';

  getById(id: number): Observable<Patient> {
    return this.api
      .get<Patient>(`${this.basePath}/${id}`)
      .pipe(map(response => response.data!));
  }

  search(params: PatientSearchParams): Observable<Patient[]> {
    return this.api
      .get<Patient[]>(`${this.basePath}/search`, params)
      .pipe(map(response => response.data ?? []));
  }

  create(request: CreatePatientRequest): Observable<Patient> {
    return this.api
      .post<Patient>(this.basePath, request)
      .pipe(map(response => response.data!));
  }

  // … other CRUD methods
}
```

### Key Points

- **Inject `ApiService`** – never `HttpClient`.
- **Define a `basePath`** that matches the backend route (`/patients`, `/appointments`, etc.).
- **Use `map` to unwrap `response.data`** – the `ApiResponse` wrapper is stripped at the service level.
- **Provide sensible defaults** – `?? []` for arrays, `!` for guaranteed data when success is assured.
- **Return `Observable<T>`** – not `Observable<ApiResponse<T>>`; the transformation is the service's responsibility.

## Error Handling

### Global Interceptor (`api.interceptor.ts`)

A dedicated HTTP interceptor (`apiInterceptor`) catches all HTTP errors and:

1. **Parses the backend error format** – extracts `error.code` and `error.message`.
2. **Shows a user‑friendly toast** – via `ToastService` for 4xx/5xx errors (except 401 which is handled by auth flow).
3. **Logs the error** – detailed console output for debugging.
4. **Returns a structured error object** – downstream components can access `status`, `message`, `details`.

The interceptor is registered in `app.config.ts` and runs **after** the authentication interceptor.

### Service‑Level Error Handling

Services should **not** catch errors globally; let the interceptor handle them. However, if a specific error requires domain‑specific logic (e.g., retrying a failed upload), catch it in the service and re‑throw a domain error.

```typescript
update(id: number, request: UpdateRequest): Observable<Patient> {
  return this.api
    .put<Patient>(`${this.basePath}/${id}`, request)
    .pipe(
      catchError(error => {
        if (error.status === 409) {
          // Transform conflict error into a domain‑specific message
          throw new PatientConflictError('Patient already modified');
        }
        throw error; // Let the global interceptor handle everything else
      })
    );
}
```

## Loading State Management

### Using NgRx Signal Store

Each feature store should expose a `loading` signal that reflects pending API calls.

```typescript
// store/patient.store.ts
export class PatientStore extends SignalStore<{ loading: boolean }> {
  private readonly patientService = inject(PatientService);

  readonly loadPatient = effect((id: number) => {
    this.setLoading(true);
    this.patientService.getById(id)
      .pipe(finalize(() => this.setLoading(false)))
      .subscribe(patient => this.patchState({ patient }));
  });
}
```

### Using Component Signals

For simple components, manage loading state locally with a signal.

```typescript
@Component({ … })
export class PatientDetailComponent {
  private readonly patientService = inject(PatientService);
  readonly loading = signal(false);
  readonly patient = signal<Patient | null>(null);

  load(id: number): void {
    this.loading.set(true);
    this.patientService.getById(id)
      .pipe(finalize(() => this.loading.set(false)))
      .subscribe(p => this.patient.set(p));
  }
}
```

## Typing Requests & Responses

### Backend Alignment

All request and response interfaces are defined in `src/app/core/models/` and must mirror the backend DTOs. When the backend adds or changes a field, update the corresponding TypeScript interface.

### Generated Types (Future)

Consider using `openapi‑generator` or `swagger‑codegen` to automatically generate TypeScript interfaces from the OpenAPI specification. Currently, interfaces are maintained manually.

## Pagination

For paginated endpoints, the backend returns:

```json
{
  "success": true,
  "data": [ … ],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

Services should return the entire `data` + `meta` object. Define a response model that includes both:

```typescript
export interface PatientListResponse {
  patients: Patient[];
  page: number;
  page_size: number;
  total: number;
  total_pages: number;
}
```

## Testing Guidelines

### Unit Tests

- Mock `ApiService` (never `HttpClient`).
- Verify that the service calls the correct endpoint with the correct parameters.
- Test error‑handling branches (e.g., empty arrays, null data).

Example (using Vitest + Angular TestBed):

```typescript
describe('PatientService', () => {
  let service: PatientService;
  let apiServiceMock: Partial<ApiService>;

  beforeEach(() => {
    apiServiceMock = {
      get: vi.fn().mockReturnValue(of({ success: true, data: mockPatient }))
    };
    TestBed.configureTestingModule({
      providers: [
        PatientService,
        { provide: ApiService, useValue: apiServiceMock }
      ]
    });
    service = TestBed.inject(PatientService);
  });

  it('should call ApiService.get with correct endpoint', () => {
    service.getById(1);
    expect(apiServiceMock.get).toHaveBeenCalledWith('/patients/1');
  });
});
```

### Integration & E2E Tests

- Use the real `ApiService` (and therefore real HTTP calls) against a test backend.
- Verify that the global interceptor shows toasts on errors.
- Test loading state transitions.

## Examples

### Existing Services to Emulate

- `PatientService` (`src/app/core/services/patient.service.ts`) – basic CRUD with search.
- `AppointmentService` (`src/app/core/services/appointment.service.ts`) – complex queries with multiple parameters.
- `MedicalStaffService` (`src/app/core/services/medical-staff.service.ts`) – simple listing + “me” endpoint.

### Interceptor Registration

See `src/app/app.config.ts`:

```typescript
provideHttpClient(
  withInterceptors([authInterceptor, apiInterceptor])
)
```

## Deviations & Exceptions

- **Public endpoints** (e.g., patient‑portal login) may bypass `ApiService` if they do not conform to the standard `ApiResponse` format. Document any such exception.
- **File uploads** use `ApiService.upload()` which expects a `FormData` object.
- **WebSocket / Server‑Sent Events** are out of scope for this document.

## Maintenance

- When adding a new domain, create its service in `src/app/core/services/` and model in `src/app/core/models/`.
- Keep this document updated as patterns evolve.
- Run `npm run lint` and `npm test` before committing to ensure compliance.

---

*Last updated: 2026‑03‑06*  
*Author: GSD Plan 01‑foundation‑06*