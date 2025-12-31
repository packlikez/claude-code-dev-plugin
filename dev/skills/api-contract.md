---
name: api-contract
description: API contract format - the handoff document between backend and frontend
---

# API Contract

The API contract is the definitive source of truth for frontend development.

## When to Generate

Generate after Step 4 (API Integration Tests) passes:
- All endpoints tested
- All response shapes verified
- All error cases documented

## Contract Location

Save to: `api-contracts/{feature-name}.yaml`

## Contract Format

```yaml
# api-contracts/user-registration.yaml
feature: user-registration
version: 1.0.0
generated: 2024-01-15T10:30:00Z
base_url: /api

# Authentication requirements
auth:
  type: bearer  # bearer | api-key | none
  header: Authorization
  format: "Bearer {token}"

# Rate limiting
rate_limit:
  requests_per_minute: 60
  requests_per_hour: 1000
  headers:
    - X-RateLimit-Limit
    - X-RateLimit-Remaining
    - X-RateLimit-Reset

# API versioning
versioning:
  strategy: url  # url | header | query
  current: v1
  format: /api/v1/resource

# Caching
caching:
  strategy: etag  # etag | last-modified | cache-control
  cacheable_endpoints:
    - GET /users
    - GET /users/{id}

# Endpoints
endpoints:
  # Create User
  - method: POST
    path: /users
    description: Create a new user account
    auth_required: false

    request:
      content_type: application/json
      body:
        email:
          type: string
          required: true
          format: email
          example: "user@example.com"
        password:
          type: string
          required: true
          min_length: 8
          example: "SecurePass123"
        name:
          type: string
          required: true
          min_length: 1
          max_length: 255
          example: "John Doe"

    responses:
      201:
        description: User created successfully
        content_type: application/json
        body:
          id:
            type: string
            format: uuid
            example: "550e8400-e29b-41d4-a716-446655440000"
          email:
            type: string
            example: "user@example.com"
          name:
            type: string
            example: "John Doe"
          createdAt:
            type: string
            format: iso8601
            example: "2024-01-15T10:30:00Z"

      400:
        description: Validation error
        body:
          error:
            type: string
            enum: ["VALIDATION_ERROR"]
          message:
            type: string
            examples:
              - "Email is required"
              - "Invalid email format"
              - "Password must be at least 8 characters"

      409:
        description: Email already exists
        body:
          error:
            type: string
            enum: ["CONFLICT"]
          message:
            type: string
            value: "Email already exists"

  # Get User
  - method: GET
    path: /users/{id}
    description: Get user by ID
    auth_required: true

    parameters:
      id:
        in: path
        type: string
        format: uuid
        required: true

    responses:
      200:
        description: User found
        body:
          id:
            type: string
            format: uuid
          email:
            type: string
          name:
            type: string
          createdAt:
            type: string
            format: iso8601

      401:
        description: Not authenticated
        body:
          error:
            type: string
            enum: ["UNAUTHORIZED"]
          message:
            type: string
            value: "Authentication required"

      404:
        description: User not found
        body:
          error:
            type: string
            enum: ["NOT_FOUND"]
          message:
            type: string
            value: "User not found"

# Common error format
error_format:
  body:
    error:
      type: string
      description: Error code (uppercase, underscore-separated)
    message:
      type: string
      description: Human-readable error message
    details:
      type: object
      optional: true
      description: Additional error details (field errors, etc.)
```

---

## Pagination

### Standard Pagination Format

```yaml
# List endpoint with pagination
- method: GET
  path: /users
  description: List all users with pagination
  auth_required: true

  parameters:
    page:
      in: query
      type: integer
      default: 1
      min: 1
    limit:
      in: query
      type: integer
      default: 20
      min: 1
      max: 100
    sort:
      in: query
      type: string
      enum: ["createdAt", "-createdAt", "name", "-name"]
      default: "-createdAt"

  responses:
    200:
      description: Paginated list of users
      body:
        data:
          type: array
          items:
            $ref: "#/definitions/User"
        pagination:
          page:
            type: integer
            example: 1
          limit:
            type: integer
            example: 20
          total:
            type: integer
            example: 150
          totalPages:
            type: integer
            example: 8
          hasNext:
            type: boolean
            example: true
          hasPrev:
            type: boolean
            example: false
```

### Cursor Pagination (for large datasets)

```yaml
# Cursor-based pagination
- method: GET
  path: /events

  parameters:
    cursor:
      in: query
      type: string
      description: Opaque cursor from previous response
    limit:
      in: query
      type: integer
      default: 50
      max: 100

  responses:
    200:
      body:
        data:
          type: array
        cursor:
          next:
            type: string
            nullable: true
            example: "eyJpZCI6MTAwfQ=="
          prev:
            type: string
            nullable: true
```

---

## Rate Limiting

### Response Headers

```yaml
# Rate limit headers on every response
headers:
  X-RateLimit-Limit: 60          # Max requests per window
  X-RateLimit-Remaining: 45       # Remaining requests
  X-RateLimit-Reset: 1704067200   # Unix timestamp when limit resets
```

### Rate Limit Exceeded Response

```yaml
429:
  description: Too many requests
  headers:
    Retry-After: 60  # Seconds until retry allowed
  body:
    error:
      type: string
      value: "RATE_LIMIT_EXCEEDED"
    message:
      type: string
      value: "Too many requests. Please retry after 60 seconds."
    retryAfter:
      type: integer
      example: 60
```

---

## Caching

### ETag Pattern

```yaml
# GET response with ETag
responses:
  200:
    headers:
      ETag: '"abc123"'
      Cache-Control: "private, max-age=0, must-revalidate"
    body:
      # ... resource data

# Conditional request
request:
  headers:
    If-None-Match: '"abc123"'

# 304 response when unchanged
responses:
  304:
    description: Not modified (use cached version)
    headers:
      ETag: '"abc123"'
```

### Cache-Control Headers

```yaml
# Cacheable public resources
Cache-Control: "public, max-age=3600"

# Private user data
Cache-Control: "private, no-cache"

# Never cache
Cache-Control: "no-store"
```

---

## API Versioning

### URL Versioning (Recommended)

```yaml
base_url: /api/v1

endpoints:
  - path: /api/v1/users  # Current version
  - path: /api/v2/users  # New version (breaking changes)
```

### Header Versioning

```yaml
request:
  headers:
    API-Version: "2024-01-01"  # Date-based versioning
    # or
    Accept: "application/vnd.api.v2+json"
```

### Deprecation Headers

```yaml
# Deprecated endpoint response
headers:
  Deprecation: "true"
  Sunset: "Sat, 01 Jan 2025 00:00:00 GMT"
  Link: '</api/v2/users>; rel="successor-version"'
```

---

## Frontend Usage

### 1. Generate TypeScript Types

```typescript
// Generated from api-contracts/user-registration.yaml

// Request types
export interface CreateUserRequest {
  email: string;
  password: string;
  name: string;
}

// Response types
export interface UserResponse {
  id: string;
  email: string;
  name: string;
  createdAt: string;
}

// Error types
export interface ApiError {
  error: string;
  message: string;
  details?: Record<string, string>;
}

// Error codes
export type ErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'FORBIDDEN'
  | 'NOT_FOUND'
  | 'CONFLICT'
  | 'INTERNAL_ERROR';
```

### 2. Create API Client

```typescript
// src/api/users.ts
import { CreateUserRequest, UserResponse, ApiError } from '@/types/api/users';

const BASE_URL = '/api';

export const usersApi = {
  create: async (data: CreateUserRequest): Promise<UserResponse> => {
    const response = await fetch(`${BASE_URL}/users`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });

    if (!response.ok) {
      const error: ApiError = await response.json();
      throw new ApiRequestError(response.status, error);
    }

    return response.json();
  },

  get: async (id: string): Promise<UserResponse> => {
    const response = await fetch(`${BASE_URL}/users/${id}`, {
      headers: { Authorization: `Bearer ${getToken()}` },
    });

    if (!response.ok) {
      const error: ApiError = await response.json();
      throw new ApiRequestError(response.status, error);
    }

    return response.json();
  },
};
```

### 3. Handle All Error Cases

```typescript
// src/components/RegisterForm.tsx
const handleSubmit = async (data: CreateUserRequest) => {
  try {
    const user = await usersApi.create(data);
    router.push('/dashboard');
  } catch (error) {
    if (error instanceof ApiRequestError) {
      switch (error.status) {
        case 400:
          // Validation error - show field errors
          setFieldError(error.body.message);
          break;
        case 409:
          // Conflict - email exists
          setFieldError('email', 'Email already exists');
          break;
        default:
          // Unexpected error
          setError('Something went wrong. Please try again.');
      }
    }
  }
};
```

---

## Validation Rules

Frontend MUST:

1. **Use exact types from contract** - no making up fields
2. **Handle all error codes** - every status code in contract
3. **Show appropriate messages** - match error messages to UI
4. **Validate same rules** - match backend validation

---

## Contract Updates

When backend changes:

1. Update API tests to reflect changes
2. Regenerate contract after tests pass
3. Update frontend types
4. Update API client
5. Update error handling
6. Re-run frontend tests
