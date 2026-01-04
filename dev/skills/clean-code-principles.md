---
name: clean-code-principles
description: Fail-fast, reusable, clean code patterns for API and UI development
---

# Clean Code Principles

Apply these from day 1. No exceptions.

## 1. Fail Fast (API)

### Validate at Boundary

```typescript
// ✅ GOOD: Validate immediately, fail fast
export const createUser = async (req: Request, res: Response) => {
  // 1. Validate input FIRST
  const parsed = createUserSchema.safeParse(req.body);
  if (!parsed.success) {
    return res.status(400).json({
      error: 'VALIDATION_ERROR',
      message: formatZodError(parsed.error),
    });
  }

  // 2. Check auth SECOND
  if (!req.user) {
    return res.status(401).json({ error: 'UNAUTHORIZED' });
  }

  // 3. Check permissions THIRD
  if (!req.user.canCreateUsers) {
    return res.status(403).json({ error: 'FORBIDDEN' });
  }

  // 4. Business logic LAST (after all guards pass)
  const user = await userService.create(parsed.data);
  return res.status(201).json(user);
};

// ❌ BAD: Validation buried in business logic
export const createUser = async (req: Request, res: Response) => {
  const user = await userService.create(req.body); // Might fail deep inside
  return res.status(201).json(user);
};
```

### Guard Clause Pattern

```typescript
// ✅ GOOD: Early returns, flat structure
const processOrder = async (orderId: string, userId: string) => {
  const order = await orderRepo.find(orderId);
  if (!order) throw new NotFoundError('Order not found');

  if (order.userId !== userId) throw new ForbiddenError('Not your order');

  if (order.status === 'completed') throw new ConflictError('Already completed');

  if (order.status === 'cancelled') throw new ConflictError('Order cancelled');

  // Happy path - no nesting
  return processPayment(order);
};

// ❌ BAD: Nested conditionals
const processOrder = async (orderId: string, userId: string) => {
  const order = await orderRepo.find(orderId);
  if (order) {
    if (order.userId === userId) {
      if (order.status !== 'completed') {
        if (order.status !== 'cancelled') {
          return processPayment(order);
        }
      }
    }
  }
};
```

## 2. Fail Fast (UI)

### Validate Before Submit

```tsx
// ✅ GOOD: Validate on blur, block submit if invalid
const Form = () => {
  const [errors, setErrors] = useState({});

  const validateField = (name: string, value: string) => {
    const error = schema.pick({ [name]: true }).safeParse({ [name]: value });
    setErrors(prev => ({ ...prev, [name]: error.success ? null : error.error }));
  };

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();

    // Validate ALL fields before submit
    const result = schema.safeParse(formData);
    if (!result.success) {
      setErrors(formatErrors(result.error));
      focusFirstError();
      return; // FAIL FAST - don't call API
    }

    submitToApi(result.data);
  };

  return (
    <form onSubmit={handleSubmit}>
      <Input onBlur={(e) => validateField('email', e.target.value)} />
    </form>
  );
};
```

### Handle Error States First

```tsx
// ✅ GOOD: Error/loading states handled first
const UserProfile = ({ userId }: Props) => {
  const { data, error, isLoading } = useUser(userId);

  // Handle edge cases FIRST
  if (isLoading) return <Skeleton />;
  if (error) return <ErrorState error={error} onRetry={refetch} />;
  if (!data) return <EmptyState />;

  // Happy path - clean render
  return <ProfileCard user={data} />;
};

// ❌ BAD: Conditions scattered throughout render
const UserProfile = ({ userId }: Props) => {
  const { data, error, isLoading } = useUser(userId);

  return (
    <div>
      {isLoading && <Spinner />}
      {error && <div>Error</div>}
      {data && <ProfileCard user={data} />}
      {!data && !isLoading && !error && <div>No data</div>}
    </div>
  );
};
```

## 3. Reusable (API)

### Extract Shared Logic

```typescript
// ✅ GOOD: Reusable validation middleware
const validate = (schema: ZodSchema) => (req: Request, res: Response, next: NextFunction) => {
  const result = schema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ error: 'VALIDATION_ERROR', message: formatError(result.error) });
  }
  req.validated = result.data;
  next();
};

// Use everywhere
app.post('/users', validate(createUserSchema), createUser);
app.post('/orders', validate(createOrderSchema), createOrder);

// ❌ BAD: Validation logic duplicated in every handler
app.post('/users', (req, res) => {
  const result = createUserSchema.safeParse(req.body);
  if (!result.success) { /* same error handling */ }
});
app.post('/orders', (req, res) => {
  const result = createOrderSchema.safeParse(req.body);
  if (!result.success) { /* same error handling again */ }
});
```

### Shared Error Handler

```typescript
// ✅ GOOD: Centralized error handling
// src/middleware/errorHandler.ts
export const errorHandler = (err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof ValidationError) {
    return res.status(400).json({ error: 'VALIDATION_ERROR', message: err.message });
  }
  if (err instanceof NotFoundError) {
    return res.status(404).json({ error: 'NOT_FOUND', message: err.message });
  }
  if (err instanceof ConflictError) {
    return res.status(409).json({ error: 'CONFLICT', message: err.message });
  }

  logger.error('Unhandled error', { error: err });
  return res.status(500).json({ error: 'INTERNAL_ERROR', message: 'Something went wrong' });
};

// Handlers just throw, middleware handles response
const createUser = async (req: Request, res: Response) => {
  if (await userExists(req.body.email)) throw new ConflictError('Email exists');
  const user = await userService.create(req.body);
  return res.status(201).json(user);
};
```

### Shared Service Layer

```typescript
// ✅ GOOD: Service shared across handlers
// src/services/userService.ts
export const userService = {
  create: async (data: CreateUserInput): Promise<User> => {
    // Reusable by any handler or cron job
    return db.users.create(data);
  },

  findById: async (id: string): Promise<User | null> => {
    return db.users.findUnique({ where: { id } });
  },
};

// Used by REST handler
app.post('/users', async (req, res) => {
  const user = await userService.create(req.validated);
  res.json(user);
});

// Used by GraphQL resolver
const resolvers = {
  Mutation: {
    createUser: (_, args) => userService.create(args.input),
  },
};
```

## 4. Reusable (UI)

### Shared Components

```tsx
// ✅ GOOD: Reusable form field component
// src/components/ui/FormField.tsx
interface FormFieldProps {
  label: string;
  name: string;
  error?: string;
  children: React.ReactNode;
}

export const FormField = ({ label, name, error, children }: FormFieldProps) => (
  <div className="form-field">
    <label htmlFor={name}>{label}</label>
    {children}
    {error && <p role="alert" className="error">{error}</p>}
  </div>
);

// Use everywhere
<FormField label="Email" name="email" error={errors.email}>
  <Input id="email" type="email" {...register('email')} />
</FormField>
```

### Shared Hooks

```tsx
// ✅ GOOD: Reusable data fetching hook
// src/hooks/useApi.ts
export const useApi = <T>(fetcher: () => Promise<T>) => {
  const [data, setData] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  const execute = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const result = await fetcher();
      setData(result);
    } catch (err) {
      setError(err as Error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { execute(); }, []);

  return { data, error, isLoading, refetch: execute };
};

// Use everywhere
const { data, error, isLoading } = useApi(() => userApi.getById(id));
```

### Shared API Client

```typescript
// ✅ GOOD: Centralized API client with error handling
// src/lib/apiClient.ts
class ApiClient {
  private baseUrl: string;

  async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${getToken()}`,
        ...options?.headers,
      },
    });

    if (!response.ok) {
      const error = await response.json();
      throw new ApiError(response.status, error);
    }

    return response.json();
  }

  get<T>(endpoint: string) { return this.request<T>(endpoint); }
  post<T>(endpoint: string, data: unknown) { return this.request<T>(endpoint, { method: 'POST', body: JSON.stringify(data) }); }
  put<T>(endpoint: string, data: unknown) { return this.request<T>(endpoint, { method: 'PUT', body: JSON.stringify(data) }); }
  delete<T>(endpoint: string) { return this.request<T>(endpoint, { method: 'DELETE' }); }
}

export const api = new ApiClient();
```

## 5. Clean Code Rules

### Single Responsibility

```typescript
// ✅ GOOD: Each function does ONE thing
const validateEmail = (email: string): boolean => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
const hashPassword = (password: string): string => bcrypt.hashSync(password, 10);
const createUser = (data: UserInput): User => db.users.create(data);
const sendWelcomeEmail = (user: User): void => mailer.send(user.email, 'welcome');

// ❌ BAD: Function does too many things
const registerUser = async (email: string, password: string) => {
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new Error('Invalid');
  const hash = bcrypt.hashSync(password, 10);
  const user = await db.users.create({ email, password: hash });
  await mailer.send(email, 'welcome', { name: user.name });
  await analytics.track('user_registered', { userId: user.id });
  return user;
};
```

### Small Functions (≤20 lines)

```typescript
// ✅ GOOD: Small, focused functions
const parseOrderItems = (items: unknown[]): OrderItem[] => {
  return items.map(item => ({
    productId: item.productId,
    quantity: item.quantity,
    price: item.price,
  }));
};

const calculateTotal = (items: OrderItem[]): number => {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
};

const applyDiscount = (total: number, discount: number): number => {
  return total * (1 - discount / 100);
};

const createOrder = async (input: OrderInput): Promise<Order> => {
  const items = parseOrderItems(input.items);
  const subtotal = calculateTotal(items);
  const total = applyDiscount(subtotal, input.discountPercent ?? 0);
  return db.orders.create({ ...input, items, total });
};
```

### Clear Naming

```typescript
// ✅ GOOD: Names describe what/why
const isEmailValid = (email: string) => EMAIL_REGEX.test(email);
const getUserById = (id: string) => db.users.findUnique({ where: { id } });
const formatCurrency = (amount: number) => `$${amount.toFixed(2)}`;
const hasUserPermission = (user: User, permission: string) => user.permissions.includes(permission);

// ❌ BAD: Unclear names
const check = (e: string) => REGEX.test(e);
const get = (id: string) => db.users.findUnique({ where: { id } });
const fmt = (n: number) => `$${n.toFixed(2)}`;
const has = (u: User, p: string) => u.permissions.includes(p);
```

## Quick Checklist

### Before Writing Code

```
□ Can I reuse existing utility/component?
□ Where should validation happen? (boundary!)
□ What are all the failure cases?
□ Is this function doing ONE thing?
```

### After Writing Code

```
□ All validations at boundary (not buried)
□ Early returns for error cases
□ No nested conditionals (≤2 levels)
□ Functions ≤20 lines
□ No duplicated logic
□ Clear, descriptive names
□ Error states handled first in UI
```
