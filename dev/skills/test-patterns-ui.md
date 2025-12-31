---
name: test-patterns-ui
description: UI and E2E test patterns - browser testing, selectors, viewports, accessibility
---

# UI & E2E Test Patterns

## Key Differences

| Aspect | UI Test | E2E Test |
|--------|---------|----------|
| Backend | Mocked/Stubbed | Real |
| Database | None | Real (test DB) |
| Scope | Component in browser | Full user journey |
| Speed | Medium | Slower |
| Purpose | Visual + interaction | Complete flow |

---

## Element Selectors (PRIORITY ORDER)

```typescript
// ✅ PRIORITY 1: data-testid (most stable)
await page.locator('[data-testid="email-input"]').fill('test@example.com');
await page.locator('[data-testid="submit-button"]').click();

// ✅ PRIORITY 2: id
await page.locator('#email-input').fill('test@example.com');

// ⚠️ PRIORITY 3: role + name (use sparingly)
await page.getByRole('button', { name: 'Submit' }).click();

// ❌ BLOCKED: text content (fragile, breaks with i18n)
await page.getByText('Submit').click();

// ❌ BLOCKED: CSS selectors (fragile, breaks with styling changes)
await page.locator('.btn-primary').click();
await page.locator('button.submit').click();

// ❌ BLOCKED: XPath (fragile, complex)
await page.locator('//button[@type="submit"]').click();
```

**Add to components:**
```tsx
<Button data-testid="submit-button">Submit</Button>
<Input data-testid="email-input" id="email" />
<div data-testid="user-list">...</div>
```

---

## Viewports (REQUIRED)

```typescript
const viewports = {
  mobile: { width: 375, height: 667 },
  tablet: { width: 768, height: 1024 },
  desktop: { width: 1280, height: 800 },
};

describe('responsive design', () => {
  Object.entries(viewports).forEach(([name, size]) => {
    it(`renders correctly on ${name}`, async () => {
      await page.setViewportSize(size);
      await page.goto('/dashboard');
      await expect(page).toHaveScreenshot(`dashboard-${name}.png`);
    });
  });
});
```

---

## Cross-Browser (REQUIRED)

```typescript
// playwright.config.ts
export default {
  projects: [
    { name: 'chromium', use: { browserName: 'chromium' } },
    { name: 'firefox', use: { browserName: 'firefox' } },
    { name: 'webkit', use: { browserName: 'webkit' } },  // Safari
  ],
};

// Run all browsers
// npx playwright test
```

---

## UI Test Template

```typescript
describe('UserForm', () => {
  beforeEach(async () => {
    await page.goto('/users/new');
  });

  // RENDER
  it('displays form fields', async () => {
    await expect(page.locator('[data-testid="email-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="name-input"]')).toBeVisible();
    await expect(page.locator('[data-testid="submit-button"]')).toBeVisible();
  });

  // SUCCESS - Submit
  it('submits form with valid data', async () => {
    await page.locator('[data-testid="email-input"]').fill('test@example.com');
    await page.locator('[data-testid="name-input"]').fill('John');
    await page.locator('[data-testid="submit-button"]').click();

    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
  });

  // LOADING STATE
  it('shows loading state during submit', async () => {
    await page.locator('[data-testid="email-input"]').fill('test@example.com');
    await page.locator('[data-testid="submit-button"]').click();

    await expect(page.locator('[data-testid="loading-spinner"]')).toBeVisible();
  });

  // ERROR STATE
  it('shows error on failed submit', async () => {
    // Mock API failure
    await page.route('/api/users', route => route.fulfill({ status: 500 }));

    await page.locator('[data-testid="email-input"]').fill('test@example.com');
    await page.locator('[data-testid="submit-button"]').click();

    await expect(page.locator('[data-testid="error-message"]')).toBeVisible();
  });

  // EMPTY STATE
  it('shows empty state when no data', async () => {
    await page.goto('/users');
    await expect(page.locator('[data-testid="empty-state"]')).toBeVisible();
    await expect(page.locator('[data-testid="empty-state"]')).toContainText('No users found');
  });

  // VALIDATION
  it('shows validation error for invalid email', async () => {
    await page.locator('[data-testid="email-input"]').fill('invalid');
    await page.locator('[data-testid="submit-button"]').click();

    await expect(page.locator('[data-testid="email-error"]')).toBeVisible();
    await expect(page.locator('[data-testid="email-error"]')).toContainText('Invalid email');
  });

  // HOVER/FOCUS STATES
  it('shows hover state on button', async () => {
    await page.locator('[data-testid="submit-button"]').hover();
    await expect(page).toHaveScreenshot('button-hover.png');
  });

  // DISABLED STATE
  it('disables submit when form is incomplete', async () => {
    await expect(page.locator('[data-testid="submit-button"]')).toBeDisabled();
  });
});
```

---

## E2E Test Template

```typescript
describe('User Registration Flow', () => {
  beforeEach(async () => {
    await testDb.clean();  // Real DB cleanup
  });

  // HAPPY PATH - Complete journey
  it('completes full registration flow', async () => {
    // Step 1: Navigate to registration
    await page.goto('/register');
    await expect(page.locator('[data-testid="register-form"]')).toBeVisible();

    // Step 2: Fill form
    await page.locator('[data-testid="email-input"]').fill('newuser@example.com');
    await page.locator('[data-testid="password-input"]').fill('SecurePass123');
    await page.locator('[data-testid="name-input"]').fill('John Doe');

    // Step 3: Submit
    await page.locator('[data-testid="submit-button"]').click();

    // Step 4: Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]'))
      .toContainText('Welcome, John');

    // Step 5: Verify DB state
    const user = await testDb.users.findByEmail('newuser@example.com');
    expect(user).not.toBeNull();
    expect(user.name).toBe('John Doe');
  });

  // ERROR RECOVERY
  it('recovers from validation error', async () => {
    await page.goto('/register');

    // Submit with invalid email
    await page.locator('[data-testid="email-input"]').fill('invalid');
    await page.locator('[data-testid="submit-button"]').click();

    // See error
    await expect(page.locator('[data-testid="email-error"]')).toBeVisible();

    // Fix and resubmit
    await page.locator('[data-testid="email-input"]').clear();
    await page.locator('[data-testid="email-input"]').fill('valid@example.com');
    await page.locator('[data-testid="password-input"]').fill('SecurePass123');
    await page.locator('[data-testid="name-input"]').fill('John');
    await page.locator('[data-testid="submit-button"]').click();

    // Success
    await expect(page).toHaveURL('/dashboard');
  });

  // NETWORK FAILURE
  it('handles network failure gracefully', async () => {
    await page.goto('/register');
    await page.locator('[data-testid="email-input"]').fill('test@example.com');
    await page.locator('[data-testid="password-input"]').fill('SecurePass123');

    // Simulate offline
    await page.context().setOffline(true);
    await page.locator('[data-testid="submit-button"]').click();

    await expect(page.locator('[data-testid="network-error"]')).toBeVisible();

    // Restore network
    await page.context().setOffline(false);
    await page.locator('[data-testid="retry-button"]').click();

    await expect(page).toHaveURL('/dashboard');
  });

  // CONFLICT
  it('shows error for existing email', async () => {
    // Pre-create user
    await testDb.createUser({ email: 'existing@example.com' });

    await page.goto('/register');
    await page.locator('[data-testid="email-input"]').fill('existing@example.com');
    await page.locator('[data-testid="password-input"]').fill('SecurePass123');
    await page.locator('[data-testid="name-input"]').fill('John');
    await page.locator('[data-testid="submit-button"]').click();

    await expect(page.locator('[data-testid="email-error"]'))
      .toContainText('Email already exists');
  });
});
```

---

## Accessibility Tests

```typescript
import { injectAxe, checkA11y } from 'axe-playwright';

describe('accessibility', () => {
  it('has no violations on registration page', async () => {
    await page.goto('/register');
    await injectAxe(page);
    await checkA11y(page);  // Throws if violations found
  });

  it('is keyboard navigable', async () => {
    await page.goto('/register');

    // Tab through form
    await page.keyboard.press('Tab');
    await expect(page.locator('[data-testid="email-input"]')).toBeFocused();

    await page.keyboard.press('Tab');
    await expect(page.locator('[data-testid="password-input"]')).toBeFocused();

    await page.keyboard.press('Tab');
    await expect(page.locator('[data-testid="name-input"]')).toBeFocused();

    await page.keyboard.press('Tab');
    await expect(page.locator('[data-testid="submit-button"]')).toBeFocused();

    // Submit with Enter
    await page.keyboard.press('Enter');
  });

  it('announces errors to screen readers', async () => {
    await page.goto('/register');
    await page.locator('[data-testid="submit-button"]').click();

    const errorRegion = page.locator('[role="alert"]');
    await expect(errorRegion).toBeVisible();
  });
});
```

---

## Visual Regression

```typescript
it('matches visual baseline', async () => {
  await page.goto('/dashboard');
  await expect(page).toHaveScreenshot('dashboard.png');
});

it('matches component snapshot', async () => {
  await expect(page.locator('[data-testid="user-card"]'))
    .toHaveScreenshot('user-card.png');
});
```

---

## Test Stability

```typescript
// ✅ Wait for specific element (stable)
await page.locator('[data-testid="success-message"]').waitFor();

// ✅ Wait for network idle
await page.waitForLoadState('networkidle');

// ❌ AVOID: Fixed timeouts (flaky)
await page.waitForTimeout(2000);
```

---

## Checklist

```
□ data-testid used for all selectors
□ No CSS/XPath selectors
□ Mobile viewport (375px) tested
□ Tablet viewport (768px) tested
□ Desktop viewport (1280px) tested
□ Chrome tested
□ Firefox tested
□ Safari/WebKit tested
□ Success flow tested
□ Loading state tested
□ Error state tested
□ Empty state tested
□ Validation errors tested
□ Keyboard navigation tested
□ axe accessibility audit passes
□ Visual regression baseline created
□ Network failure tested (E2E)
□ DB state verified (E2E)
□ Tests run 3x without flakes
```
