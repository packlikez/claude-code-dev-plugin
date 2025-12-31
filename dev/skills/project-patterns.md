---
name: project-patterns
description: Learn and follow existing project patterns - never invent new ones
---

# Project Patterns

Learn existing patterns from the project and follow them exactly.

## Pattern Discovery

Run `/dev:init` to discover and document patterns in `.claude/project.md`.

### What to Discover

```markdown
## Project Patterns

### 1. File Naming
- Components: {pattern} (e.g., PascalCase.tsx)
- Utilities: {pattern} (e.g., camelCase.ts)
- Tests: {pattern} (e.g., *.test.ts, *.spec.ts)
- Types: {pattern} (e.g., types.ts, *.types.ts)

### 2. Folder Structure
- Features: {pattern}
- Components: {pattern}
- Shared: {pattern}

### 3. Import Order
1. External packages
2. Internal aliases (@/)
3. Relative imports
4. Types
5. Styles

### 4. Export Style
- Default exports: {when used}
- Named exports: {when used}

### 5. Error Handling
- Pattern: {description}
- Error class: {location}
- Handler function: {location}

### 6. Validation
- Library: {zod/yup/joi/custom}
- Schema location: {path}
- Validation pattern: {description}

### 7. API Structure
- Route pattern: {description}
- Controller pattern: {description}
- Service pattern: {description}

### 8. State Management
- Library: {redux/zustand/context/etc}
- Pattern: {description}

### 9. Testing
- Framework: {jest/vitest/etc}
- Structure: {describe/it pattern}
- Mocking: {approach}

### 10. Styling
- Approach: {tailwind/css modules/styled/etc}
- Pattern: {description}

### 11. Security
- Auth middleware: {location}
- Auth check pattern: {description}
- Input sanitization: {library/pattern}
- CSRF handling: {approach}

### 12. Logging
- Library: {winston/pino/console/etc}
- Log format: {json/text}
- Log location: {pattern}
- Log levels used: {error/warn/info/debug}

### 13. Environment Config
- Config location: {.env/config/}
- Access pattern: {process.env/config object}
- Validation: {zod/joi/manual}
```

---

## Pattern Detection Commands

Run these to discover existing patterns:

### File Structure
```bash
# Find component patterns
find src -name "*.tsx" | head -20

# Find service patterns
find src -name "*Service*" -o -name "*service*"

# Find test patterns
find . -name "*.test.*" -o -name "*.spec.*" | head -10
```

### Import Patterns
```bash
# Check import order
head -30 src/components/*.tsx | grep "import"

# Find alias usage
grep -r "@/" src/ | head -10
```

### Error Handling
```bash
# Find error classes
grep -r "class.*Error" src/

# Find error handling patterns
grep -r "catch\|throw\|Result<" src/ | head -20
```

### Validation
```bash
# Find validation library
grep -r "zod\|yup\|joi\|ajv" package.json src/

# Find schema patterns
find src -name "*schema*" -o -name "*Schema*"
```

### Auth Patterns
```bash
# Find auth middleware
grep -r "middleware\|auth\|authorize" src/ | head -10

# Find auth checks
grep -r "isAuthenticated\|requireAuth\|protect" src/
```

### Logging Patterns
```bash
# Find logging library
grep -r "winston\|pino\|bunyan\|console\." package.json src/

# Find log usage
grep -r "logger\.\|console\.\|log\." src/ | head -20
```

### Test Patterns
```bash
# Find test structure
head -50 tests/**/*.test.ts | grep -E "describe|it|test"

# Find mock patterns
grep -r "jest\.mock\|vi\.mock\|mockImplementation" tests/
```

---

## Pattern Examples

### Error Handling Patterns

#### Pattern A: Error Classes
```typescript
// If project uses error classes:
import { NotFoundError, ValidationError } from '@/lib/errors';

throw new NotFoundError('User not found');
throw new ValidationError('Invalid email format');
```

#### Pattern B: Error Factory
```typescript
// If project uses error factory:
import { createError } from '@/lib/errors';

throw createError('NOT_FOUND', 'User not found');
throw createError('VALIDATION', 'Invalid email format');
```

#### Pattern C: Result Type
```typescript
// If project uses Result type:
import { ok, err, Result } from '@/lib/result';

const findUser = (id: string): Result<User, Error> => {
  const user = db.find(id);
  if (!user) return err(new Error('Not found'));
  return ok(user);
};
```

### Component Patterns

#### Pattern A: Functional with Props Interface
```typescript
interface ButtonProps {
  variant: 'primary' | 'secondary';
  onClick: () => void;
  children: React.ReactNode;
}

export const Button = ({ variant, onClick, children }: ButtonProps) => {
  return <button className={styles[variant]} onClick={onClick}>{children}</button>;
};
```

#### Pattern B: forwardRef with Types
```typescript
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', ...props }, ref) => {
    return <button ref={ref} className={styles[variant]} {...props} />;
  }
);
```

### Service Patterns

#### Pattern A: Class-based
```typescript
export class UserService {
  constructor(private db: Database) {}

  async create(data: CreateUserDto): Promise<User> {
    return this.db.users.create(data);
  }
}
```

#### Pattern B: Function-based
```typescript
export const createUserService = (db: Database) => ({
  create: async (data: CreateUserDto): Promise<User> => {
    return db.users.create(data);
  },
});
```

#### Pattern C: Standalone Functions
```typescript
export const createUser = async (data: CreateUserDto): Promise<User> => {
  return db.users.create(data);
};
```

### Security Patterns

#### Pattern A: Middleware Auth
```typescript
// If project uses middleware:
app.use('/api/protected', authMiddleware);

export const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'UNAUTHORIZED' });
  req.user = verifyToken(token);
  next();
};
```

#### Pattern B: Decorator Auth
```typescript
// If project uses decorators:
@UseGuards(AuthGuard)
@Controller('users')
export class UsersController {
  @Get(':id')
  @Roles('admin', 'user')
  async getUser(@Param('id') id: string) {}
}
```

#### Pattern C: HOC Auth
```typescript
// If project uses HOCs (frontend):
export const withAuth = (Component: React.FC) => {
  return (props: any) => {
    const { user, loading } = useAuth();
    if (loading) return <Loading />;
    if (!user) return <Redirect to="/login" />;
    return <Component {...props} />;
  };
};
```

### Logging Patterns

#### Pattern A: Structured Logger
```typescript
// If project uses structured logging:
import { logger } from '@/lib/logger';

logger.info('User created', { userId: user.id, email: user.email });
logger.error('Failed to create user', { error: err.message, stack: err.stack });
```

#### Pattern B: Request Logger Middleware
```typescript
// If project logs requests:
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    logger.info('Request completed', {
      method: req.method,
      path: req.path,
      status: res.statusCode,
      duration: Date.now() - start,
    });
  });
  next();
});
```

#### Pattern C: Console Wrapper
```typescript
// If project uses console wrapper:
const log = {
  info: (msg: string, data?: object) => console.log(`[INFO] ${msg}`, data),
  error: (msg: string, data?: object) => console.error(`[ERROR] ${msg}`, data),
  warn: (msg: string, data?: object) => console.warn(`[WARN] ${msg}`, data),
};
```

### Input Validation Patterns

#### Pattern A: Zod Schemas
```typescript
// If project uses Zod:
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(1).max(255),
});

type CreateUserInput = z.infer<typeof createUserSchema>;
```

#### Pattern B: Class Validator
```typescript
// If project uses class-validator:
import { IsEmail, MinLength, MaxLength } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @MinLength(8)
  password: string;

  @MinLength(1)
  @MaxLength(255)
  name: string;
}
```

---

## Pattern Compliance Rules

### DO
- Study existing code before writing new
- Match naming conventions exactly
- Follow established folder structure
- Use same libraries and approaches
- Copy error handling pattern
- Match test structure

### DON'T
- Invent new patterns
- Use different naming conventions
- Create new folder structures
- Introduce new libraries without discussion
- Create different error handling
- Use different test patterns

---

## Pattern Validation

Before completing implementation:

```
□ File names match project convention
□ Folder structure matches project
□ Import order matches project
□ Export style matches project
□ Error handling matches project
□ Validation matches project
□ API structure matches project
□ Test structure matches project
□ Styling matches project
```

---

## Pattern File

Store discovered patterns in: `.claude/project.md`

This file should be:
- Created by `/dev:init`
- Referenced before any implementation
- Updated when new patterns discovered
- Used by all agents for consistency
