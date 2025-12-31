---
name: test-patterns-unit
description: Unit test patterns - backend and frontend unit tests
---

# Unit Test Patterns

## Required Test Scenarios

| State | Description | Example |
|-------|-------------|---------|
| **Success** | Valid input, happy path | Create user with valid data |
| **Failed** | Validation, business rule | Invalid email format |
| **Empty** | No data, empty input | Empty array, empty string |
| **Error** | Exception, failure | DB connection failed |

## Input Edge Cases

| Category | Test Cases |
|----------|------------|
| **Empty** | `""`, `[]`, `{}`, `null`, `undefined` |
| **Boundary** | Min, max, zero, negative, exactly at limit |
| **Format** | Invalid format, wrong type |
| **Size** | Too short, too long |

---

## Strong Assertions (REQUIRED)

```typescript
// ❌ BLOCKED - Weak
expect(result).toBeDefined();
expect(result).toBeTruthy();
expect(mockFn).toHaveBeenCalled();

// ✅ REQUIRED - Strong
expect(user.email).toBe('john@example.com');
expect(result).toEqual({
  id: expect.any(String),
  email: 'john@example.com',
  createdAt: mockDate,
});
expect(mockFn).toHaveBeenCalledWith({ email: 'john@example.com' });
```

---

## AAA Pattern

```typescript
it('creates user with valid data', async () => {
  // Arrange
  const input = createUserFixture({ email: 'test@example.com' });

  // Act
  const result = await createUser(input);

  // Assert
  expect(result.email).toBe('test@example.com');
});
```

---

## Backend Unit Test Template

```typescript
describe('UserService', () => {
  // SUCCESS
  it('creates user with valid data', async () => {
    const result = await userService.create(validData);
    expect(result.email).toBe(validData.email);
  });

  // EMPTY
  it('returns empty array when no match', async () => {
    const result = await userService.findByName('nonexistent');
    expect(result).toEqual([]);
  });

  // FAILED - Validation
  describe('validation', () => {
    it.each([
      ['empty email', { email: '' }, 'Email is required'],
      ['null email', { email: null }, 'Email is required'],
      ['invalid format', { email: 'invalid' }, 'Invalid email format'],
    ])('rejects %s', async (_, data, error) => {
      await expect(userService.create({ ...validData, ...data }))
        .rejects.toThrow(error);
    });
  });

  // FAILED - Not found
  it('throws when user not found', async () => {
    await expect(userService.getById('nonexistent'))
      .rejects.toThrow('User not found');
  });

  // FAILED - Conflict
  it('throws on duplicate email', async () => {
    await userService.create(validData);
    await expect(userService.create(validData))
      .rejects.toThrow('Email already exists');
  });

  // BOUNDARY
  describe('boundary values', () => {
    it('accepts min length (1)', async () => {
      const result = await userService.create({ ...validData, name: 'A' });
      expect(result.name).toBe('A');
    });

    it('accepts max length (255)', async () => {
      const name = 'A'.repeat(255);
      const result = await userService.create({ ...validData, name });
      expect(result.name).toBe(name);
    });

    it('rejects over max (256)', async () => {
      await expect(userService.create({ ...validData, name: 'A'.repeat(256) }))
        .rejects.toThrow('Name too long');
    });
  });

  // ERROR
  it('handles database error', async () => {
    mockDb.mockRejectedValue(new Error('Connection failed'));
    await expect(userService.create(validData))
      .rejects.toThrow('Database error');
  });
});
```

---

## Frontend Unit Test Template

```typescript
describe('UserForm', () => {
  // SUCCESS - Render
  it('renders form fields', () => {
    render(<UserForm onSubmit={mockSubmit} />);
    expect(screen.getByLabelText('Email')).toBeInTheDocument();
    expect(screen.getByLabelText('Name')).toBeInTheDocument();
  });

  // SUCCESS - Submit
  it('calls onSubmit with form data', async () => {
    render(<UserForm onSubmit={mockSubmit} />);
    await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');
    await userEvent.type(screen.getByLabelText('Name'), 'John');
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    expect(mockSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      name: 'John',
    });
  });

  // LOADING STATE
  it('shows loading state', () => {
    render(<UserForm loading={true} />);
    expect(screen.getByTestId('loading-skeleton')).toBeInTheDocument();
  });

  // ERROR STATE
  it('shows error message', () => {
    render(<UserForm error="Failed to load" />);
    expect(screen.getByText('Failed to load')).toBeInTheDocument();
  });

  // EMPTY STATE
  it('shows empty state', () => {
    render(<UserList users={[]} />);
    expect(screen.getByText('No users found')).toBeInTheDocument();
  });

  // VALIDATION
  it('shows validation error on invalid email', async () => {
    render(<UserForm onSubmit={mockSubmit} />);
    await userEvent.type(screen.getByLabelText('Email'), 'invalid');
    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    expect(screen.getByText('Invalid email format')).toBeInTheDocument();
    expect(mockSubmit).not.toHaveBeenCalled();
  });

  // DISABLED STATE
  it('disables submit when loading', () => {
    render(<UserForm loading={true} />);
    expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
  });
});
```

---

## Fixtures & Factories

```typescript
export const createUserFixture = (overrides = {}) => ({
  email: 'test@example.com',
  name: 'Test User',
  ...overrides,
});

let counter = 0;
export const createUniqueUser = (overrides = {}) => ({
  email: `user-${++counter}@test.com`,
  ...overrides,
});
```

---

## Mock Dates & Random

```typescript
const mockDate = new Date('2024-01-15T10:00:00Z');
jest.useFakeTimers().setSystemTime(mockDate);
expect(user.createdAt).toEqual(mockDate);
jest.useRealTimers();

const mockUuid = '123e4567-e89b-12d3-a456-426614174000';
jest.spyOn(crypto, 'randomUUID').mockReturnValue(mockUuid);
expect(user.id).toBe(mockUuid);
```

---

## Accessibility (Frontend)

```typescript
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

it('has no accessibility violations', async () => {
  const { container } = render(<Component />);
  expect(await axe(container)).toHaveNoViolations();
});

it('is keyboard navigable', async () => {
  render(<UserForm />);
  await userEvent.tab();
  expect(screen.getByLabelText('Email')).toHaveFocus();
});
```

---

## Checklist

```
□ Success case tested
□ Empty result tested
□ Validation errors (empty, null, invalid)
□ Not found (if applicable)
□ Conflict/duplicate (if unique)
□ Boundary values (min, max)
□ Error handling (exceptions)
□ Loading state (frontend)
□ Error state (frontend)
□ Empty state (frontend)
□ Accessibility (frontend)
```
