---
name: test-patterns-api
description: API integration test patterns - real database, HTTP cycle, response verification
---

# API Test Patterns

## Key Differences from Unit Tests

| Aspect | Unit Test | API Test |
|--------|-----------|----------|
| Database | Mocked | Real (test DB) |
| Services | Mocked | Real |
| HTTP | Not tested | Full cycle |
| Isolation | Function level | Request level |
| Speed | Fast | Slower |

---

## Required Response Codes

| Code | Scenario | Test Required |
|------|----------|---------------|
| 200 | Success GET/PUT/PATCH | ✓ Always |
| 201 | Created POST | ✓ If creates |
| 204 | No content DELETE | ✓ If deletes |
| 400 | Validation error | ✓ Always |
| 401 | Unauthorized (no token) | ✓ If auth |
| 401 | Unauthorized (invalid token) | ✓ If auth |
| 401 | Unauthorized (expired token) | ✓ If auth |
| 403 | Forbidden (wrong role) | ✓ If roles |
| 404 | Not found | ✓ If has ID |
| 409 | Conflict (duplicate) | ✓ If unique |
| 500 | Server error | ✓ Always |

---

## Real Database (NO MOCKS)

```typescript
// ❌ BLOCKED - Mocked database
jest.mock('../db');
const mockDb = { users: { create: jest.fn() } };

// ✅ REQUIRED - Real test database
import { testDb } from '../test/setup';

beforeEach(async () => {
  await testDb.clean();  // Fresh state
});
```

---

## Test Isolation (Seed Per Test)

```typescript
// ❌ BLOCKED - Shared seed (tests depend on each other)
beforeAll(async () => {
  await testDb.seed(sharedData);
});

// ✅ REQUIRED - Isolated seed per test
beforeEach(async () => {
  await testDb.clean();
});

it('test 1', async () => {
  const user = await testDb.createUser({ email: 'test1@example.com' });
  // use user
});

it('test 2', async () => {
  const user = await testDb.createUser({ email: 'test2@example.com' });
  // use user - independent of test 1
});
```

---

## API Test Template

```typescript
describe('POST /api/users', () => {
  // 201 - Created
  it('creates user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ email: 'test@example.com', name: 'John' });

    expect(response.status).toBe(201);
    expect(response.body).toMatchObject({
      id: expect.any(String),
      email: 'test@example.com',
      name: 'John',
    });

    // Verify DB state
    const dbUser = await testDb.users.findById(response.body.id);
    expect(dbUser.email).toBe('test@example.com');
  });

  // 400 - Validation
  describe('validation errors', () => {
    it.each([
      ['empty email', { email: '', name: 'John' }, 'Email is required'],
      ['invalid email', { email: 'invalid', name: 'John' }, 'Invalid email format'],
      ['missing name', { email: 'test@example.com' }, 'Name is required'],
    ])('returns 400 for %s', async (_, body, message) => {
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${validToken}`)
        .send(body);

      expect(response.status).toBe(400);
      expect(response.body).toEqual({
        error: 'VALIDATION_ERROR',
        message: expect.stringContaining(message),
      });
    });
  });

  // 401 - Unauthorized
  describe('authentication', () => {
    it('returns 401 without token', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({ email: 'test@example.com', name: 'John' });

      expect(response.status).toBe(401);
      expect(response.body.error).toBe('UNAUTHORIZED');
    });

    it('returns 401 with invalid token', async () => {
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', 'Bearer invalid-token')
        .send({ email: 'test@example.com', name: 'John' });

      expect(response.status).toBe(401);
    });

    it('returns 401 with expired token', async () => {
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${expiredToken}`)
        .send({ email: 'test@example.com', name: 'John' });

      expect(response.status).toBe(401);
    });
  });

  // 403 - Forbidden
  it('returns 403 for non-admin user', async () => {
    const response = await request(app)
      .post('/api/users')
      .set('Authorization', `Bearer ${userToken}`)  // not admin
      .send({ email: 'test@example.com', name: 'John' });

    expect(response.status).toBe(403);
    expect(response.body.error).toBe('FORBIDDEN');
  });

  // 409 - Conflict
  it('returns 409 for duplicate email', async () => {
    await testDb.createUser({ email: 'existing@example.com' });

    const response = await request(app)
      .post('/api/users')
      .set('Authorization', `Bearer ${validToken}`)
      .send({ email: 'existing@example.com', name: 'John' });

    expect(response.status).toBe(409);
    expect(response.body.error).toBe('CONFLICT');
    expect(response.body.message).toBe('Email already exists');
  });
});

describe('GET /api/users/:id', () => {
  // 200 - Success
  it('returns user by ID', async () => {
    const user = await testDb.createUser({ email: 'test@example.com' });

    const response = await request(app)
      .get(`/api/users/${user.id}`)
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(200);
    expect(response.body.email).toBe('test@example.com');
  });

  // 200 - Empty list
  it('returns empty array when no users', async () => {
    const response = await request(app)
      .get('/api/users')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(200);
    expect(response.body).toEqual([]);
  });

  // 404 - Not found
  it('returns 404 for non-existent user', async () => {
    const response = await request(app)
      .get('/api/users/nonexistent-id')
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(404);
    expect(response.body.error).toBe('NOT_FOUND');
  });
});

describe('DELETE /api/users/:id', () => {
  // 204 - Deleted
  it('deletes user and returns 204', async () => {
    const user = await testDb.createUser({ email: 'test@example.com' });

    const response = await request(app)
      .delete(`/api/users/${user.id}`)
      .set('Authorization', `Bearer ${validToken}`);

    expect(response.status).toBe(204);

    // Verify deleted from DB
    const dbUser = await testDb.users.findById(user.id);
    expect(dbUser).toBeNull();
  });
});
```

---

## Response Verification

```typescript
// ✅ Verify exact response shape
expect(response.body).toEqual({
  id: expect.any(String),
  email: 'test@example.com',
  name: 'John',
  createdAt: expect.any(String),
});

// ✅ Verify no extra fields (no data leakage)
const allowedFields = ['id', 'email', 'name', 'createdAt'];
expect(Object.keys(response.body).sort()).toEqual(allowedFields.sort());

// ✅ Verify DB state after mutation
const dbUser = await testDb.users.findById(response.body.id);
expect(dbUser.email).toBe('test@example.com');
```

---

## Pagination Test

```typescript
it('paginates results', async () => {
  await testDb.createUsers(25);  // Create 25 users

  const page1 = await request(app)
    .get('/api/users?page=1&limit=10')
    .set('Authorization', `Bearer ${validToken}`);

  expect(page1.status).toBe(200);
  expect(page1.body.data).toHaveLength(10);
  expect(page1.body.meta).toEqual({
    total: 25,
    page: 1,
    limit: 10,
    totalPages: 3,
  });

  const page3 = await request(app)
    .get('/api/users?page=3&limit=10')
    .set('Authorization', `Bearer ${validToken}`);

  expect(page3.body.data).toHaveLength(5);  // Last page
});
```

---

## Idempotency Test

```typescript
it('handles duplicate requests idempotently', async () => {
  const idempotencyKey = 'unique-key-123';

  const response1 = await request(app)
    .post('/api/payments')
    .set('Idempotency-Key', idempotencyKey)
    .send({ amount: 100 });

  const response2 = await request(app)
    .post('/api/payments')
    .set('Idempotency-Key', idempotencyKey)
    .send({ amount: 100 });

  expect(response1.body.id).toBe(response2.body.id);  // Same result

  const payments = await testDb.payments.findAll();
  expect(payments).toHaveLength(1);  // Only one created
});
```

---

## Checklist

```
□ All endpoints tested (compare to spec)
□ Success responses (200/201/204)
□ Empty result (200 with [])
□ Validation errors (400)
□ Unauthorized - no token (401)
□ Unauthorized - invalid token (401)
□ Unauthorized - expired token (401)
□ Forbidden - wrong role (403)
□ Not found (404)
□ Conflict - duplicate (409)
□ DB state verified after mutations
□ No extra fields in response
□ Pagination tested (if applicable)
□ Real database used (no mocks)
□ Tests are isolated (no shared state)
```
