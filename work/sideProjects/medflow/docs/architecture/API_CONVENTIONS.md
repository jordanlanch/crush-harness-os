# API Conventions

This document defines the conventions for the MedNext API to ensure consistency, predictability, and maintainability across all endpoints.

## Response Format

All API responses follow a standardized JSON structure:

### Successful Response

```json
{
  "success": true,
  "data": { ... },
  "meta": { ... } // optional
}
```

- `success`: Always `true` for successful responses.
- `data`: The primary response payload (object, array, or primitive).
- `meta`: Optional metadata (pagination, totals, etc.).

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "email", "message": "Email is required" }
    ]
  }
}
```

- `success`: Always `false` for error responses.
- `error.code`: Machine-readable error code (see below).
- `error.message`: Human-readable error message.
- `error.details`: Optional array of detailed error objects (e.g., validation errors).

## Error Codes

Standard error codes defined in `pkg/response/response.go`:

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `VALIDATION_ERROR` | 400 Bad Request | Request validation failed |
| `UNAUTHORIZED` | 401 Unauthorized | Authentication required or invalid credentials |
| `FORBIDDEN` | 403 Forbidden | Insufficient permissions |
| `NOT_FOUND` | 404 Not Found | Requested resource does not exist |
| `CONFLICT` | 409 Conflict | Resource conflict (e.g., duplicate entry) |
| `BAD_REQUEST` | 400 Bad Request | Generic client error |
| `INTERNAL_ERROR` | 500 Internal Server Error | Server-side error |

**Usage in handlers:**

```go
return response.ErrorResponse(c, http.StatusBadRequest, "Invalid input", err)
// Automatically maps to BAD_REQUEST code

return response.ValidationError(c, validationErr)
// Uses VALIDATION_ERROR code

return response.Unauthorized(c, "Invalid credentials")
// Uses UNAUTHORIZED code
```

## Request Validation

Use the `go-playground/validator` package integrated with Echo:

1. **Define validation tags in DTOs:**

```go
type CreatePatientRequest struct {
    Email     string `json:"email" validate:"required,email"`
    FirstName string `json:"first_name" validate:"required,min=2,max=50"`
}
```

2. **Automatic validation in handlers:**

```go
if err := c.Bind(&req); err != nil {
    return response.ErrorResponse(c, http.StatusBadRequest, "Invalid request body", err)
}

if err := c.Validate(&req); err != nil {
    return response.ValidationError(c, err)
}
```

## API Versioning

- **Path versioning:** All endpoints are prefixed with `/api/v1/`
- **No breaking changes within v1:** Backward-compatible additions only
- **Future versions:** Will use `/api/v2/` when breaking changes are required

## Pagination

Paginated endpoints follow a consistent pattern:

### Request

```http
GET /api/v1/patients?page=2&page_size=20
```

- `page`: Page number (1-indexed, default: 1)
- `page_size`: Items per page (default: 20, max: 100)

### Response

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "page": 2,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

**Helper function:**

```go
meta := response.Paginated(page, pageSize, total)
return response.SuccessWithMeta(c, data, meta)
```

## HTTP Status Codes

| Status | Usage |
|--------|-------|
| 200 OK | Successful GET, PUT, PATCH |
| 201 Created | Successful POST (resource created) |
| 204 No Content | Successful DELETE or empty response |
| 400 Bad Request | Client error (validation, malformed request) |
| 401 Unauthorized | Missing or invalid authentication |
| 403 Forbidden | Authenticated but insufficient permissions |
| 404 Not Found | Resource does not exist |
| 409 Conflict | Business rule violation (e.g., duplicate) |
| 429 Too Many Requests | Rate limiting |
| 500 Internal Server Error | Unexpected server error |

## Response Helpers

Use the `pkg/response` package for all HTTP responses:

| Function | Purpose | HTTP Status |
|----------|---------|-------------|
| `response.Success(c, status, data)` | Generic success | Any 2xx |
| `response.Created(c, data)` | Resource created | 201 |
| `response.NoContent(c)` | Empty response | 204 |
| `response.ErrorResponse(c, status, message, err)` | Generic error | Any 4xx/5xx |
| `response.ValidationError(c, err)` | Validation error | 400 |
| `response.Unauthorized(c, message)` | Authentication error | 401 |
| `response.Forbidden(c, message)` | Permission error | 403 |
| `response.NotFound(c, message)` | Resource not found | 404 |
| `response.Conflict(c, message)` | Conflict error | 409 |
| `response.InternalError(c, message)` | Server error | 500 |

**Never use direct `c.JSON` or `c.NoContent` calls.** Always use the response package.

## Security Constraints (from CLAUDE.md)

1. **Never expose domain entities directly in API responses.**
   - Use Data Transfer Objects (DTOs) in `internal/application/dto/`
   - Map between entities and DTOs in use cases or handlers

2. **Validate all user input.**
   - Use structural validation with `validator`
   - Sanitize strings where appropriate

3. **Protect sensitive data.**
   - Never expose passwords, tokens, or internal identifiers
   - Use separate DTOs for different contexts (e.g., `UserResponse` vs `UserCreateRequest`)

## Error Handling Middleware

A global error middleware (`middleware.Error()`) converts all unhandled errors to standardized error responses:

- **Echo HTTP errors:** Converted to response format with appropriate status code
- **Generic errors:** Default to 500 Internal Server Error
- **Logging:** All errors are logged with Zerolog

## Examples

### Successful Creation

```http
POST /api/v1/patients
{
  "email": "patient@example.com",
  "first_name": "John"
}
```

```json
{
  "success": true,
  "data": {
    "id": 123,
    "email": "patient@example.com",
    "first_name": "John",
    "created_at": "2025-03-06T17:25:49Z"
  }
}
```

### Validation Error

```http
POST /api/v1/patients
{
  "email": "invalid",
  "first_name": ""
}
```

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      { "field": "email", "message": "Email must be a valid email address" },
      { "field": "first_name", "message": "First name is required" }
    ]
  }
}
```

### Permission Error

```http
GET /api/v1/admin/users
```

```json
{
  "success": false,
  "error": {
    "code": "FORBIDDEN",
    "message": "Insufficient permissions"
  }
}
```

## Consistency Rules

1. **Always use response helpers** – no direct `c.JSON` calls
2. **Always validate input** – use DTOs with validation tags
3. **Always return appropriate HTTP status codes**
4. **Always document endpoints** with Swagger annotations
5. **Always test error scenarios** – ensure error responses follow the format

## References

- [CLAUDE.md](../CLAUDE.md) – Project-specific constraints
- [pkg/response/response.go](../../backend/pkg/response/response.go) – Response package implementation
- [validator documentation](https://pkg.go.dev/github.com/go-playground/validator) – Validation rules