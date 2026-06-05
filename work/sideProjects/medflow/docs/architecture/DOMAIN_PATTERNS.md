# Domain Patterns

This document outlines the standard patterns for implementing domains in the MedNext system, following Clean Architecture principles. The patterns ensure consistency, maintainability, and separation of concerns across all domains.

## Clean Architecture Layers

MedNext implements Clean Architecture with four primary layers:

1. **Domain Layer** (`backend/internal/domain/`) – Business entities, value objects, repository interfaces
2. **Application Layer** (`backend/internal/application/`) – Use cases (commands/queries), DTOs
3. **Infrastructure Layer** (`backend/internal/infrastructure/`) – Repository implementations, external services
4. **Interface Layer** (`backend/internal/interface/`) – HTTP handlers, middleware, request/response models

Dependencies flow inward: outer layers can depend on inner layers, but inner layers must not depend on outer layers.

## Creating a New Domain

Follow these steps to create a new domain (e.g., `template`):

### 1. Define the Domain Entity

Create `backend/internal/domain/{domain}/entity.go`:

```go
package template

import (
    "errors"
    "time"
)

type Status string

const (
    StatusDraft    Status = "draft"
    StatusActive   Status = "active"
    StatusArchived Status = "archived"
)

type TemplateItem struct {
    ID          int32
    Name        string
    Description string
    Status      Status
    CreatedAt   time.Time
    UpdatedAt   time.Time
    DeletedAt   *time.Time
    CreatedBy   *int32
    UpdatedBy   *int32
}

var (
    ErrTemplateNotFound = errors.New("template not found")
    ErrTemplateInvalid  = errors.New("template is invalid")
)

func (t *TemplateItem) IsDeleted() bool {
    return t.DeletedAt != nil
}
```

**Guidelines:**
- Define domain‑specific enums as typed constants
- Include audit fields (`CreatedAt`, `UpdatedAt`, `DeletedAt`, `CreatedBy`, `UpdatedBy`)
- Add business methods on the entity (e.g., `IsDeleted`, `IsActive`)
- Place domain errors in the same file

### 2. Define the Repository Interface

Create `backend/internal/domain/{domain}/repository.go`:

```go
package template

import "context"

type SearchParams struct {
    Query  string
    Status *Status
    Limit  int32
    Offset int32
}

type ListParams struct {
    Limit  int32
    Offset int32
}

type Repository interface {
    Create(ctx context.Context, template *TemplateItem) (*TemplateItem, error)
    GetByID(ctx context.Context, id int32) (*TemplateItem, error)
    GetByName(ctx context.Context, name string) (*TemplateItem, error)
    Update(ctx context.Context, template *TemplateItem) (*TemplateItem, error)
    Delete(ctx context.Context, id int32) error
    List(ctx context.Context, params ListParams) ([]*TemplateItem, int64, error)
    Search(ctx context.Context, params SearchParams) ([]*TemplateItem, int64, error)
    Count(ctx context.Context, status *Status) (int64, error)
    ExistsByName(ctx context.Context, name string) (bool, error)
}
```

**Guidelines:**
- Use parameter structs (`SearchParams`, `ListParams`) for flexible querying
- Include pagination support (`Limit`, `Offset`) and total count
- Follow the naming convention `GetByX`, `ExistsByX`, `Search`, `List`
- Keep the interface focused on data access, not business logic

### 3. Implement Use Cases (Commands & Queries)

Create `backend/internal/application/{domain}/usecase.go`:

```go
package template

import (
    "context"
    "errors"
    templateDomain "github.com/jordanlanch/mednext-backend/internal/domain/template"
)

type CreateTemplateRequest struct {
    Name        string `json:"name" validate:"required,min=3,max=100"`
    Description string `json:"description" validate:"max=500"`
    Status      templateDomain.Status `json:"status" validate:"required,oneof=draft active archived"`
    CreatedBy   *int32 `json:"created_by"`
}

type TemplateResponse struct {
    ID          int32                     `json:"id"`
    Name        string                    `json:"name"`
    Description string                    `json:"description"`
    Status      templateDomain.Status     `json:"status"`
    CreatedAt   string                    `json:"created_at"`
    UpdatedAt   string                    `json:"updated_at"`
    CreatedBy   *int32                    `json:"created_by,omitempty"`
    UpdatedBy   *int32                    `json:"updated_by,omitempty"`
}

type UseCase interface {
    CreateTemplate(ctx context.Context, req *CreateTemplateRequest) (*TemplateResponse, error)
    GetTemplateByID(ctx context.Context, id int32) (*TemplateResponse, error)
}

type useCaseImpl struct {
    repo templateDomain.Repository
}

func NewUseCase(repo templateDomain.Repository) UseCase {
    return &useCaseImpl{repo: repo}
}

// Implementation omitted for brevity...
```

**Guidelines:**
- Separate commands (mutations) from queries (reads)
- Define request/response DTOs with validation tags
- Map domain entities to DTOs in the use case layer
- Inject the repository interface, not the concrete implementation
- Handle domain errors and map them to appropriate application errors

### 4. Implement the Repository with sqlc

Create `backend/internal/infrastructure/persistence/repository/{domain}_repository.go`:

```go
package repository

import (
    "context"
    "github.com/jackc/pgx/v5/pgxpool"
    templateDomain "github.com/jordanlanch/mednext-backend/internal/domain/template"
    "github.com/jordanlanch/mednext-backend/internal/infrastructure/persistence/db"
)

type TemplateRepository struct {
    pool    *pgxpool.Pool
    queries *db.Queries
}

func NewTemplateRepository(pool *pgxpool.Pool) *TemplateRepository {
    return &TemplateRepository{
        pool:    pool,
        queries: db.New(pool),
    }
}

func (r *TemplateRepository) Create(ctx context.Context, t *templateDomain.TemplateItem) (*templateDomain.TemplateItem, error) {
    params := r.toCreateParams(t)
    result, err := r.queries.CreateTemplate(ctx, params)
    if err != nil {
        return nil, err
    }
    return r.toDomain(result), nil
}

// Additional methods (GetByID, Update, Delete, etc.) follow the same pattern.

func (r *TemplateRepository) toDomain(p *db.Patient) *templateDomain.TemplateItem {
    // Conversion logic
}

func (r *TemplateRepository) toCreateParams(t *templateDomain.TemplateItem) *db.CreateTemplateParams {
    // Conversion logic
}
```

**Guidelines:**
- Use sqlc‑generated queries (`db.Queries`) for type‑safe SQL
- Implement all methods from the domain repository interface
- Provide conversion helpers (`toDomain`, `toCreateParams`, `toUpdateParams`)
- Handle `pgx.ErrNoRows` and translate to `nil` results
- Ensure the repository compiles (`go build ./internal/infrastructure/persistence/repository/...`)

### 5. Create HTTP Handler

Create `backend/internal/interface/http/handler/{domain}.go`:

```go
package handler

import (
    "net/http"
    "strconv"
    "github.com/labstack/echo/v4"
    "github.com/jordanlanch/mednext-backend/internal/application/template"
    "github.com/jordanlanch/mednext-backend/pkg/response"
)

type TemplateHandler struct {
    useCase template.UseCase
}

func NewTemplateHandler(useCase template.UseCase) *TemplateHandler {
    return &TemplateHandler{useCase: useCase}
}

func (h *TemplateHandler) Create(c echo.Context) error {
    var req template.CreateTemplateRequest
    if err := c.Bind(&req); err != nil {
        return response.ErrorResponse(c, http.StatusBadRequest, "Invalid request", err)
    }
    result, err := h.useCase.CreateTemplate(c.Request().Context(), &req)
    if err != nil {
        return response.ErrorResponse(c, http.StatusInternalServerError, "Failed to create template", err)
    }
    return response.Success(c, http.StatusCreated, result)
}

func (h *TemplateHandler) GetByID(c echo.Context) error {
    id, err := strconv.ParseInt(c.Param("id"), 10, 32)
    if err != nil {
        return response.ErrorResponse(c, http.StatusBadRequest, "Invalid template ID", err)
    }
    result, err := h.useCase.GetTemplateByID(c.Request().Context(), int32(id))
    if err != nil {
        return response.ErrorResponse(c, http.StatusNotFound, "Template not found", err)
    }
    return response.Success(c, http.StatusOK, result)
}
```

**Guidelines:**
- Use the `response` package for consistent JSON responses
- Validate input with `c.Bind()` and `validator`
- Map application errors to appropriate HTTP status codes
- Keep handlers thin—delegate business logic to use cases

## Multi‑Tenancy Integration

All tenant‑scoped tables must include a `tenant_id` column:

```sql
CREATE TABLE templates (
    id          SERIAL PRIMARY KEY,
    tenant_id   INTEGER NOT NULL REFERENCES tenants(id),
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    status      VARCHAR(20) NOT NULL DEFAULT 'draft',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at  TIMESTAMPTZ,
    created_by  INTEGER REFERENCES users(id),
    updated_by  INTEGER REFERENCES users(id)
);
```

**Repository implementation must:**  
- Inject `tenant_id` from context (set by auth middleware)
- Include `WHERE tenant_id = $1` in every query
- Use transaction managers for cross‑repository operations

## RBAC Integration

Role‑Based Access Control is enforced at the handler level using middleware:

```go
// middleware/authorization.go
func RequirePermission(permission string) echo.MiddlewareFunc {
    return func(next echo.HandlerFunc) echo.HandlerFunc {
        return func(c echo.Context) error {
            userRole := c.Get("user_role").(string)
            if !hasPermission(userRole, permission) {
                return response.ErrorResponse(c, http.StatusForbidden, "Insufficient permissions", nil)
            }
            return next(c)
        }
    }
}
```

**Permissions are stored in the database** (`roles`, `permissions`, `role_permissions`, `user_roles`) and loaded per request.

## Real‑World Examples

- **Patient Domain** – `backend/internal/domain/patient/`, `backend/internal/application/usecase/patient_merge_usecase.go`
- **Appointment Domain** – `backend/internal/domain/appointment/`, `backend/internal/application/usecase/referral/usecase.go`
- **Template Domain** – Reference implementation created in Phase 01‑Foundation Plan 08

## Testing Guidelines

- **Domain Layer:** Unit tests for entity methods and validation
- **Application Layer:** Unit tests with mocked repositories
- **Infrastructure Layer:** Integration tests with Testcontainers‑go
- **Interface Layer:** HTTP handler tests using Echo’s test utilities

## Common Pitfalls

1. **Exposing domain entities in API responses** – Always use DTOs.
2. **Missing tenant isolation** – Every query must filter by `tenant_id`.
3. **Hard‑coding permissions** – Store permissions in the database.
4. **N+1 queries** – Use sqlc joins or batch queries.
5. **Ignoring soft‑delete** – Check `deleted_at IS NULL` in all queries.

## Next Steps

After creating the domain, register the repository in the dependency injection container (`backend/internal/config/modules.go`), add HTTP routes (`backend/internal/interface/http/routes.go`), and create database migrations (`db/migrations/`).

---

*Document version: 1.0*  
*Last updated: 2026‑03‑06*  
*Based on Phase 01‑Foundation Plan 08 (Template Domain)*