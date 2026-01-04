---
name: api-design
description: Detailed API design patterns - field-by-field specification with validation
---

# API Design (Detailed)

**Every field must be specified. No assumptions allowed.**

## The Problem with Shallow API Design

```markdown
❌ SHALLOW (causes bugs):
| Method | Path | Description |
| POST | /api/users | Create user |

❓ What fields are required?
❓ What validation rules?
❓ What error messages?
❓ What response format?
```

```markdown
✅ DETAILED (prevents bugs):
- Every request field with type, required, validation, example
- Every response field with type, nullable, example
- Every error case with status, code, message
```

---

## Endpoint Specification Template

### For Each Endpoint, Specify:

```yaml
endpoint:
  method: POST
  path: /api/users
  description: Create a new user account
  auth:
    required: false
    method: null
  rate_limit:
    requests_per_minute: 10
    requests_per_hour: 100

  request:
    headers:
      Content-Type: application/json
    body:
      fields:
        - name: email
          type: string
          required: true
          validation:
            - format: email
            - unique: users.email
            - max_length: 255
          example: "user@example.com"
          error_messages:
            required: "Email is required"
            format: "Please enter a valid email address"
            unique: "This email is already registered"

        - name: password
          type: string
          required: true
          validation:
            - min_length: 8
            - max_length: 128
            - pattern: "must contain: 1 uppercase, 1 lowercase, 1 number"
          example: "SecurePass123"
          error_messages:
            required: "Password is required"
            min_length: "Password must be at least 8 characters"
            pattern: "Password must contain uppercase, lowercase, and number"

        - name: name
          type: string
          required: true
          validation:
            - min_length: 1
            - max_length: 100
            - pattern: "letters, spaces, hyphens only"
          example: "John Doe"
          error_messages:
            required: "Name is required"
            max_length: "Name cannot exceed 100 characters"

        - name: avatar_url
          type: string
          required: false
          nullable: true
          validation:
            - format: url
            - pattern: "must be https://"
          default: null
          example: "https://example.com/avatar.jpg"
          error_messages:
            format: "Please enter a valid URL"
            pattern: "Avatar URL must use HTTPS"

  responses:
    201:
      description: User created successfully
      headers:
        Location: /api/users/{id}
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
        avatar_url:
          type: string
          nullable: true
          example: null
        created_at:
          type: string
          format: iso8601
          example: "2024-01-15T10:30:00Z"

    400:
      description: Validation error
      body:
        error:
          type: string
          value: "VALIDATION_ERROR"
        message:
          type: string
          description: "Human-readable error message"
        field:
          type: string
          nullable: true
          description: "Field that failed validation"
        details:
          type: array
          nullable: true
          description: "Multiple validation errors"
          items:
            field: string
            message: string

    409:
      description: Email already exists
      body:
        error:
          type: string
          value: "CONFLICT"
        message:
          type: string
          value: "This email is already registered"
        field:
          type: string
          value: "email"

    429:
      description: Rate limit exceeded
      headers:
        Retry-After: 60
      body:
        error:
          type: string
          value: "RATE_LIMIT_EXCEEDED"
        message:
          type: string
          value: "Too many requests. Please try again in 60 seconds."
        retry_after:
          type: integer
          example: 60
```

---

## Field Specification Checklist

For EVERY field, specify:

```markdown
□ name - Field identifier
□ type - string, number, boolean, array, object
□ required - true/false
□ nullable - Can it be null?
□ validation - ALL rules that apply:
  □ format (email, url, uuid, date, phone)
  □ min_length / max_length
  □ min / max (for numbers)
  □ pattern (regex description)
  □ enum (allowed values)
  □ unique (uniqueness constraint)
□ default - Value if not provided
□ example - Realistic example value
□ error_messages - Exact message for each validation failure
```

---

## Common Field Types

### Email Field
```yaml
email:
  type: string
  required: true
  validation:
    - format: email
    - max_length: 255
    - unique: users.email
    - lowercase: true  # Normalize to lowercase
  error_messages:
    required: "Email is required"
    format: "Please enter a valid email address"
    unique: "This email is already registered"
```

### Password Field
```yaml
password:
  type: string
  required: true
  write_only: true  # Never returned in responses
  validation:
    - min_length: 8
    - max_length: 128
    - contains_uppercase: true
    - contains_lowercase: true
    - contains_number: true
    - contains_special: false  # Optional
    - not_common_password: true
  error_messages:
    required: "Password is required"
    min_length: "Password must be at least 8 characters"
    weak: "Password is too weak. Include uppercase, lowercase, and numbers."
    common: "This password is too common. Please choose a stronger password."
```

### Phone Field
```yaml
phone:
  type: string
  required: false
  nullable: true
  validation:
    - format: e164  # International format: +1234567890
    - pattern: "^\+[1-9]\d{1,14}$"
  example: "+14155551234"
  error_messages:
    format: "Please enter phone in international format: +1234567890"
```

### Date Field
```yaml
birth_date:
  type: string
  format: date  # YYYY-MM-DD
  required: false
  nullable: true
  validation:
    - min: "1900-01-01"
    - max: "today"  # Cannot be in future
  example: "1990-05-15"
  error_messages:
    format: "Please enter date as YYYY-MM-DD"
    max: "Birth date cannot be in the future"
```

### Enum Field
```yaml
status:
  type: string
  required: true
  enum:
    - draft
    - pending
    - approved
    - rejected
  default: draft
  error_messages:
    enum: "Status must be one of: draft, pending, approved, rejected"
```

### Array Field
```yaml
tags:
  type: array
  required: false
  items:
    type: string
    min_length: 1
    max_length: 50
  validation:
    - max_items: 10
    - unique_items: true
  default: []
  example: ["javascript", "react"]
  error_messages:
    max_items: "Maximum 10 tags allowed"
    unique_items: "Duplicate tags are not allowed"
```

### Nested Object Field
```yaml
address:
  type: object
  required: false
  nullable: true
  properties:
    street:
      type: string
      required: true
      max_length: 200
    city:
      type: string
      required: true
      max_length: 100
    country:
      type: string
      required: true
      enum: ["US", "CA", "UK", "AU", ...]
    postal_code:
      type: string
      required: true
      pattern: "varies by country"
  error_messages:
    street.required: "Street address is required"
    city.required: "City is required"
    country.required: "Country is required"
```

### Money Field
```yaml
amount:
  type: object
  required: true
  properties:
    value:
      type: integer
      description: "Amount in cents (not dollars)"
      min: 0
      max: 999999999
      example: 1999  # $19.99
    currency:
      type: string
      enum: ["USD", "EUR", "GBP"]
      default: "USD"
  error_messages:
    value.min: "Amount cannot be negative"
    value.max: "Amount exceeds maximum allowed"
```

---

## Error Response Patterns

### Validation Error (400)
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Please enter a valid email address",
  "field": "email",
  "details": [
    { "field": "email", "message": "Please enter a valid email address" },
    { "field": "password", "message": "Password must be at least 8 characters" }
  ]
}
```

### Not Found (404)
```json
{
  "error": "NOT_FOUND",
  "message": "User not found",
  "resource": "user",
  "id": "550e8400-..."
}
```

### Conflict (409)
```json
{
  "error": "CONFLICT",
  "message": "This email is already registered",
  "field": "email",
  "suggestion": "Try logging in instead"
}
```

### Rate Limit (429)
```json
{
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Too many requests. Please try again in 60 seconds.",
  "retry_after": 60
}
```

---

## API Design Checklist

Before completing API design, verify:

```markdown
## Request
□ All fields have type specified
□ All fields marked required/optional
□ All fields have validation rules
□ All validation rules have error messages
□ All fields have realistic examples
□ Nullable fields explicitly marked
□ Default values specified where applicable

## Response
□ Success response fully specified
□ All returned fields documented
□ Nullable fields marked
□ Response examples provided

## Errors
□ 400 validation errors with field-specific messages
□ 401 unauthorized (if auth required)
□ 403 forbidden (if role-based)
□ 404 not found (if resource lookup)
□ 409 conflict (if uniqueness constraint)
□ 429 rate limit (with retry-after)
□ 500 internal error (generic fallback)

## Security
□ Auth requirements per endpoint
□ Rate limiting defined
□ Input size limits set
□ Sensitive fields marked (passwords, tokens)
```

---

## Example: Complete Endpoint Specification

```markdown
### POST /api/auth/register

**Description:** Create a new user account

**Authentication:** None required

**Rate Limit:** 10 requests/minute, 100 requests/hour per IP

#### Request

**Headers:**
| Header | Required | Value |
|--------|----------|-------|
| Content-Type | Yes | application/json |

**Body:**
| Field | Type | Required | Validation | Example |
|-------|------|----------|------------|---------|
| email | string | Yes | Valid email, unique, max 255 chars | "user@example.com" |
| password | string | Yes | Min 8 chars, 1 upper, 1 lower, 1 number | "SecurePass1" |
| name | string | Yes | 1-100 chars | "John Doe" |
| terms_accepted | boolean | Yes | Must be true | true |

**Validation Error Messages:**
| Field | Rule | Message |
|-------|------|---------|
| email | required | "Email is required" |
| email | format | "Please enter a valid email address" |
| email | unique | "This email is already registered" |
| password | required | "Password is required" |
| password | min_length | "Password must be at least 8 characters" |
| password | pattern | "Password must include uppercase, lowercase, and number" |
| name | required | "Name is required" |
| name | max_length | "Name cannot exceed 100 characters" |
| terms_accepted | required | "You must accept the terms of service" |
| terms_accepted | value | "You must accept the terms of service" |

#### Responses

**201 Created:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "John Doe",
  "created_at": "2024-01-15T10:30:00Z"
}
```

**400 Validation Error:**
```json
{
  "error": "VALIDATION_ERROR",
  "message": "Please enter a valid email address",
  "field": "email"
}
```

**409 Conflict:**
```json
{
  "error": "CONFLICT",
  "message": "This email is already registered",
  "field": "email"
}
```

**429 Rate Limit:**
```json
{
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "Too many registration attempts. Please try again later.",
  "retry_after": 60
}
```
```

This level of detail leaves ZERO room for implementer assumptions.
