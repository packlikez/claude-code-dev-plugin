---
name: ux-patterns
description: UX best practices for frontend implementation - accessibility, responsive, forms, errors
---

# UX Patterns

## Quick Reference

| Category | Priority |
|----------|----------|
| Accessibility | REQUIRED |
| Loading States | REQUIRED |
| Error Handling | REQUIRED |
| Empty States | REQUIRED |
| Form UX | REQUIRED |
| Responsive | REQUIRED |
| Optimistic Updates | RECOMMENDED |
| Animations | RECOMMENDED |
| Keyboard Shortcuts | RECOMMENDED |

---

## Accessibility (REQUIRED)

### ARIA Labels

```tsx
// ❌ No label
<button><TrashIcon /></button>

// ✅ Screen reader accessible
<button aria-label="Delete user John Doe">
  <TrashIcon aria-hidden="true" />
</button>

// ✅ With visible label
<button>
  <TrashIcon aria-hidden="true" />
  <span>Delete</span>
</button>
```

### Live Regions (Dynamic Content)

```tsx
// Announce changes to screen readers
<div aria-live="polite" aria-atomic="true">
  {successMessage && <p>{successMessage}</p>}
</div>

<div aria-live="assertive">
  {errorMessage && <p role="alert">{errorMessage}</p>}
</div>
```

### Focus Trap (Modals)

```tsx
// ❌ Focus escapes modal
<Dialog open={isOpen}>
  <DialogContent>{children}</DialogContent>
</Dialog>

// ✅ Focus trapped inside modal
<Dialog open={isOpen}>
  <FocusTrap>
    <DialogContent>
      {children}
      <Button onClick={close}>Close</Button>
    </DialogContent>
  </FocusTrap>
</Dialog>
```

### Skip Links

```tsx
// First element in body
<a href="#main-content" className="sr-only focus:not-sr-only">
  Skip to main content
</a>

<main id="main-content">
  {/* Content */}
</main>
```

### Form Accessibility

```tsx
// ❌ No association
<label>Email</label>
<input type="email" />

// ✅ Properly associated
<label htmlFor="email">Email</label>
<input
  id="email"
  type="email"
  aria-describedby="email-error email-hint"
  aria-invalid={!!errors.email}
/>
<p id="email-hint" className="text-muted">We'll never share your email</p>
{errors.email && <p id="email-error" role="alert">{errors.email}</p>}
```

### Color Contrast

```tsx
// ❌ Low contrast
<p className="text-gray-400 bg-white">Hard to read</p>

// ✅ WCAG AA compliant (4.5:1 ratio)
<p className="text-gray-700 bg-white">Easy to read</p>

// Check color contrast with:
// - Chrome DevTools: Inspect element > Styles > Color contrast
// - https://webaim.org/resources/contrastchecker/
```

---

## Responsive Design (REQUIRED)

### Breakpoint Strategy

```tsx
// Mobile-first approach
<div className="
  flex flex-col          // Mobile: stack
  md:flex-row            // Tablet+: row
  lg:grid lg:grid-cols-3 // Desktop: grid
">

// Standard breakpoints
// sm: 640px  (large phones)
// md: 768px  (tablets)
// lg: 1024px (laptops)
// xl: 1280px (desktops)
```

### Touch Targets

```tsx
// ❌ Too small for touch (< 44px)
<button className="p-1">×</button>

// ✅ Minimum 44x44px touch target
<button className="p-3 min-w-[44px] min-h-[44px]">
  <XIcon className="h-4 w-4" />
</button>
```

### Responsive Tables

```tsx
// ❌ Horizontal scroll on mobile
<table>...</table>

// ✅ Card layout on mobile
<div className="hidden md:block">
  <Table>{/* Desktop table */}</Table>
</div>
<div className="md:hidden space-y-4">
  {items.map(item => (
    <Card key={item.id}>
      <CardContent>
        <div className="flex justify-between">
          <span className="font-medium">Name</span>
          <span>{item.name}</span>
        </div>
        {/* More fields */}
      </CardContent>
    </Card>
  ))}
</div>
```

### Responsive Navigation

```tsx
// Desktop: full nav | Mobile: hamburger menu
<nav>
  <div className="hidden md:flex gap-4">
    <NavLink href="/dashboard">Dashboard</NavLink>
    <NavLink href="/settings">Settings</NavLink>
  </div>
  <Sheet className="md:hidden">
    <SheetTrigger><MenuIcon /></SheetTrigger>
    <SheetContent>
      <NavLink href="/dashboard">Dashboard</NavLink>
      <NavLink href="/settings">Settings</NavLink>
    </SheetContent>
  </Sheet>
</nav>
```

---

## Error Handling UX (REQUIRED)

### Error Message Types

| Type | When | Example |
|------|------|---------|
| Inline | Field validation | "Email is required" below field |
| Toast | Action feedback | "Failed to save changes" |
| Banner | Page-level | "Service temporarily unavailable" |
| Full page | Fatal error | 500 error page |

### Inline Form Errors

```tsx
// ❌ Vague error
<p className="text-red-500">Invalid</p>

// ✅ Specific, actionable error
<p className="text-red-500" role="alert">
  Email must be in format: name@example.com
</p>
```

### Error Recovery

```tsx
// ❌ Dead end
<ErrorPage message="Something went wrong" />

// ✅ Recovery options
<ErrorPage
  message="Failed to load users"
  actions={[
    { label: 'Try again', onClick: refetch },
    { label: 'Go back', onClick: () => router.back() },
    { label: 'Contact support', href: '/support' },
  ]}
/>
```

### Network Error Handling

```tsx
const { data, error, refetch } = useQuery(['users'], fetchUsers);

if (error) {
  return (
    <Alert variant="destructive">
      <AlertTitle>Failed to load users</AlertTitle>
      <AlertDescription>
        {error.message}
        <Button variant="link" onClick={() => refetch()}>
          Try again
        </Button>
      </AlertDescription>
    </Alert>
  );
}
```

---

## Form UX (REQUIRED)

### Validation Timing

```tsx
// ❌ Validate on every keystroke (annoying)
<input onChange={e => validate(e.target.value)} />

// ✅ Validate on blur, re-validate on change after error
const [touched, setTouched] = useState(false);
const [hasError, setHasError] = useState(false);

<input
  onBlur={() => {
    setTouched(true);
    setHasError(!isValid(value));
  }}
  onChange={e => {
    setValue(e.target.value);
    if (touched && hasError) {
      setHasError(!isValid(e.target.value));
    }
  }}
/>
```

### Submit Button States

```tsx
<Button
  type="submit"
  disabled={!isValid || isSubmitting}
>
  {isSubmitting ? (
    <>
      <Spinner className="mr-2 h-4 w-4" />
      Saving...
    </>
  ) : (
    'Save Changes'
  )}
</Button>
```

### Multi-Step Forms

```tsx
// Progress indicator
<div className="flex gap-2">
  {steps.map((step, i) => (
    <div
      key={step.id}
      className={cn(
        "h-2 flex-1 rounded",
        i < currentStep ? "bg-primary" :
        i === currentStep ? "bg-primary/50" : "bg-muted"
      )}
    />
  ))}
</div>

// Step navigation
<div className="flex justify-between">
  <Button
    variant="outline"
    onClick={prevStep}
    disabled={currentStep === 0}
  >
    Back
  </Button>
  <Button onClick={nextStep}>
    {currentStep === steps.length - 1 ? 'Submit' : 'Next'}
  </Button>
</div>
```

### Password Fields

```tsx
const [showPassword, setShowPassword] = useState(false);

<div className="relative">
  <Input
    type={showPassword ? 'text' : 'password'}
    aria-describedby="password-requirements"
  />
  <Button
    type="button"
    variant="ghost"
    size="icon"
    className="absolute right-2 top-1/2 -translate-y-1/2"
    onClick={() => setShowPassword(!showPassword)}
    aria-label={showPassword ? 'Hide password' : 'Show password'}
  >
    {showPassword ? <EyeOffIcon /> : <EyeIcon />}
  </Button>
</div>
<ul id="password-requirements" className="text-sm text-muted">
  <li className={hasMinLength ? 'text-green-600' : ''}>
    ✓ At least 8 characters
  </li>
  <li className={hasNumber ? 'text-green-600' : ''}>
    ✓ Contains a number
  </li>
</ul>
```

---

## Animations (RECOMMENDED)

### Micro-interactions

```tsx
// Button hover/press feedback
<Button className="
  transition-all duration-150
  hover:scale-105
  active:scale-95
">
  Click me
</Button>

// Loading spinner
<div className="animate-spin h-4 w-4 border-2 border-primary border-t-transparent rounded-full" />
```

### Page Transitions

```tsx
// Framer Motion example
<AnimatePresence mode="wait">
  <motion.div
    key={pathname}
    initial={{ opacity: 0, y: 20 }}
    animate={{ opacity: 1, y: 0 }}
    exit={{ opacity: 0, y: -20 }}
    transition={{ duration: 0.2 }}
  >
    {children}
  </motion.div>
</AnimatePresence>
```

### Respect Motion Preferences

```tsx
// CSS
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}

// React hook
const prefersReducedMotion = useMediaQuery('(prefers-reduced-motion: reduce)');

<motion.div
  animate={prefersReducedMotion ? {} : { scale: 1.1 }}
>
```

### Skeleton Loading Animation

```tsx
<div className="animate-pulse space-y-4">
  <div className="h-4 bg-muted rounded w-3/4" />
  <div className="h-4 bg-muted rounded w-1/2" />
  <div className="h-32 bg-muted rounded" />
</div>
```

---

## Optimistic Updates

```typescript
const handleDelete = async (id: string) => {
  // Immediately update UI
  queryClient.setQueryData(['users'], (old) =>
    old.filter(user => user.id !== id)
  );

  try {
    await deleteUser(id);
  } catch (error) {
    // Rollback on error
    queryClient.invalidateQueries(['users']);
    toast.error('Failed to delete');
  }
};
```

---

## Confirmation Dialogs

```tsx
// ❌ NEVER use native
confirm('Delete?');
alert('Done');

// ✅ Use UI library
<AlertDialog>
  <AlertDialogTrigger>Delete</AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogTitle>Are you sure?</AlertDialogTitle>
    <AlertDialogDescription>
      This cannot be undone.
    </AlertDialogDescription>
    <AlertDialogCancel>Cancel</AlertDialogCancel>
    <AlertDialogAction onClick={handleDelete}>
      Delete
    </AlertDialogAction>
  </AlertDialogContent>
</AlertDialog>
```

---

## Undo Support

```typescript
const handleArchive = async (id: string) => {
  await archiveUser(id);

  toast.success('User archived', {
    action: {
      label: 'Undo',
      onClick: () => unarchiveUser(id),
    },
    duration: 5000,
  });
};
```

---

## Loading States (Skeleton)

```tsx
// ❌ Generic spinner
if (isLoading) return <Spinner />;

// ✅ Skeleton matching layout
if (isLoading) {
  return (
    <div className="space-y-4">
      <Skeleton className="h-12 w-full" />
      <div className="grid grid-cols-3 gap-4">
        <Skeleton className="h-32" />
        <Skeleton className="h-32" />
        <Skeleton className="h-32" />
      </div>
    </div>
  );
}
```

---

## Empty States

```tsx
if (!users?.length) {
  return (
    <EmptyState
      icon={<UsersIcon />}
      title="No users yet"
      description="Create your first user"
      action={<Button onClick={openCreate}>Create User</Button>}
    />
  );
}
```

---

## Form Protection

```typescript
// Auto-save drafts
useEffect(() => {
  const timeout = setTimeout(() => {
    localStorage.setItem(`draft-${formId}`, JSON.stringify(formData));
  }, 1000);
  return () => clearTimeout(timeout);
}, [formData]);

// Unsaved changes warning
useEffect(() => {
  const handleBeforeUnload = (e: BeforeUnloadEvent) => {
    if (isDirty) {
      e.preventDefault();
      e.returnValue = '';
    }
  };
  window.addEventListener('beforeunload', handleBeforeUnload);
  return () => window.removeEventListener('beforeunload', handleBeforeUnload);
}, [isDirty]);
```

---

## Focus Management

```typescript
// Focus first error
const onError = (errors) => {
  const firstField = Object.keys(errors)[0];
  document.querySelector(`[name="${firstField}"]`)?.focus();
};

// Focus on modal open
useEffect(() => {
  if (isOpen) inputRef.current?.focus();
}, [isOpen]);

// Return focus on close
const handleClose = () => {
  setIsOpen(false);
  triggerRef.current?.focus();
};
```

---

## No Native Components

| Native | Use Instead |
|--------|-------------|
| `<select>` | Select from UI library |
| `<input type="date">` | DatePicker |
| `<input type="file">` | FileUpload/Dropzone |
| `alert()` | Toast |
| `confirm()` | AlertDialog |
| `prompt()` | Dialog with input |

---

## Keyboard Shortcuts

```typescript
useHotkeys('ctrl+k', () => openSearch(), []);
useHotkeys('ctrl+n', () => openCreate(), []);
useHotkeys('escape', () => closeModal(), [isOpen]);

<Tooltip>
  <TooltipTrigger><Button>Search</Button></TooltipTrigger>
  <TooltipContent>Search <kbd>Ctrl+K</kbd></TooltipContent>
</Tooltip>
```

---

## Network Awareness

```tsx
const isOnline = useNetworkStatus();

{!isOnline && (
  <Banner variant="warning">
    You're offline. Changes will sync when reconnected.
  </Banner>
)}

<Button disabled={!isOnline || isSubmitting}>
  {!isOnline ? 'Offline' : 'Submit'}
</Button>
```
