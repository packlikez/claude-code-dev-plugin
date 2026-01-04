---
name: ui-mockup
description: Text-based UI mockups and screen specifications for frontend implementation
---

# UI Mockup Specification

**Every screen fully described. No design decisions left to implementer.**

## The Problem with Vague UI Specs

```markdown
❌ VAGUE (causes inconsistency):
| Route | Page | Purpose |
| /users | UsersPage | List users |

❓ What's the layout?
❓ What components are needed?
❓ What happens on loading/error/empty?
❓ How do interactions work?
```

```markdown
✅ DETAILED (consistent implementation):
- ASCII layout mockup
- Component list (existing vs new)
- All states (loading, error, empty, success)
- All interactions with expected behavior
- Responsive breakpoints
- Accessibility requirements
```

---

## Screen Specification Template

### For Each Screen, Specify:

```markdown
## Screen: {ScreenName}

### Meta
- **Route:** /path/:param
- **Title:** "Page Title | App Name"
- **Auth Required:** Yes/No
- **Roles Allowed:** admin, user, guest

### Layout (ASCII Mockup)

```
┌─────────────────────────────────────────────────┐
│ [Logo]                    [User Menu ▼]         │
├─────────────────────────────────────────────────┤
│                                                 │
│   Page Title                    [+ Add New]     │
│                                                 │
│   ┌─────────────────────────────────────────┐  │
│   │ 🔍 Search...                            │  │
│   └─────────────────────────────────────────┘  │
│                                                 │
│   ┌─────────────────────────────────────────┐  │
│   │ Item 1                        [Edit][🗑]│  │
│   ├─────────────────────────────────────────┤  │
│   │ Item 2                        [Edit][🗑]│  │
│   ├─────────────────────────────────────────┤  │
│   │ Item 3                        [Edit][🗑]│  │
│   └─────────────────────────────────────────┘  │
│                                                 │
│   [< Prev]  Page 1 of 5  [Next >]              │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Components

| Component | Source | Props |
|-----------|--------|-------|
| Header | existing: src/components/Header | - |
| Button | existing: src/components/ui/Button | variant, size, onClick |
| SearchInput | NEW | value, onChange, placeholder |
| DataTable | NEW | columns, data, onSort, onRowClick |
| Pagination | existing: src/components/ui/Pagination | page, totalPages, onChange |
| ConfirmDialog | existing: src/components/ui/ConfirmDialog | title, message, onConfirm, onCancel |

### States

| State | Condition | Display |
|-------|-----------|---------|
| Loading | Initial fetch | Skeleton table (5 rows) |
| Empty | data.length === 0 | EmptyState with "No items yet" + Add button |
| Error | fetch failed | ErrorState with retry button |
| Success | data.length > 0 | Data table with items |
| Deleting | delete in progress | Row faded + spinner |

### Interactions

| Element | Event | Behavior |
|---------|-------|----------|
| Search input | onChange (debounced 300ms) | Filter table, update URL params |
| Add button | click | Navigate to /items/new |
| Edit button | click | Navigate to /items/:id/edit |
| Delete button | click | Show confirm dialog |
| Confirm delete | click | Delete item, show toast, refresh list |
| Row | click | Navigate to /items/:id |
| Pagination | page change | Fetch page, update URL |

### Responsive Behavior

| Breakpoint | Changes |
|------------|---------|
| Mobile (<640px) | Stack layout, hide columns 3-5, full-width buttons |
| Tablet (640-1024px) | 2-column layout, show all columns |
| Desktop (>1024px) | Full layout as shown |

### Accessibility

- [ ] All buttons have aria-label
- [ ] Table has proper headers
- [ ] Focus trap in confirm dialog
- [ ] Keyboard navigation (Tab through rows, Enter to select)
- [ ] Screen reader announces loading/error states
```

---

## ASCII Mockup Patterns

### Form Layout

```
┌─────────────────────────────────────────┐
│           Create New Item               │
├─────────────────────────────────────────┤
│                                         │
│  Title *                                │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│  ⚠ Title is required                   │
│                                         │
│  Description                            │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │                                 │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│  0/500 characters                       │
│                                         │
│  Category *                             │
│  ┌─────────────────────────────┐ [▼]   │
│  │ Select category...          │       │
│  └─────────────────────────────┘       │
│                                         │
│  [Cancel]              [Create Item]    │
│                                         │
└─────────────────────────────────────────┘
```

### Card Grid Layout

```
┌───────────────────────────────────────────────────┐
│  Items                              [+ Add New]   │
├───────────────────────────────────────────────────┤
│                                                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │   [Image]   │ │   [Image]   │ │   [Image]   │ │
│  │             │ │             │ │             │ │
│  │ Item Title  │ │ Item Title  │ │ Item Title  │ │
│  │ $19.99      │ │ $29.99      │ │ $39.99      │ │
│  │ [Add Cart]  │ │ [Add Cart]  │ │ [Add Cart]  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ │
│                                                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ │
│  │   [Image]   │ │   [Image]   │ │   [Image]   │ │
│  │             │ │             │ │             │ │
│  │ Item Title  │ │ Item Title  │ │ Item Title  │ │
│  │ $49.99      │ │ $59.99      │ │ $69.99      │ │
│  │ [Add Cart]  │ │ [Add Cart]  │ │ [Add Cart]  │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ │
│                                                   │
└───────────────────────────────────────────────────┘
```

### Modal Dialog

```
┌─────────────────────────────────────────┐
│ ✕                                       │
│                                         │
│         🗑️ Delete Item?                 │
│                                         │
│   Are you sure you want to delete       │
│   "Item Name"? This action cannot       │
│   be undone.                            │
│                                         │
│   [Cancel]              [Delete]        │
│                                         │
└─────────────────────────────────────────┘
```

### Navigation Sidebar

```
┌────────────────┬────────────────────────────────┐
│                │                                │
│  [Logo]        │  Page Content                  │
│                │                                │
│  ────────────  │                                │
│                │                                │
│  📊 Dashboard  │                                │
│  👥 Users      │                                │
│  📦 Products   │                                │
│  📋 Orders     │                                │
│                │                                │
│  ────────────  │                                │
│                │                                │
│  ⚙️ Settings   │                                │
│  🚪 Logout     │                                │
│                │                                │
└────────────────┴────────────────────────────────┘
```

---

## State Specifications

### Loading State

```markdown
**Loading State:**
- Show: Skeleton matching content layout
- Duration: Until data loads
- Minimum: 300ms (prevent flash)

**Skeleton Pattern:**
```
┌─────────────────────────────────────┐
│ ████████████                        │  <- Title skeleton
├─────────────────────────────────────┤
│ ████████████████████████████        │  <- Row skeleton
│ ████████████████████████████        │
│ ████████████████████████████        │
└─────────────────────────────────────┘
```
```

### Empty State

```markdown
**Empty State:**
- Show: When data.length === 0 (not on initial load)
- Content:
  - Icon: Relevant empty icon (📭 for no messages, 📋 for no items)
  - Title: "No {items} yet"
  - Description: Helpful text about adding first item
  - Action: Primary button to create first item

**Layout:**
```
┌─────────────────────────────────────┐
│                                     │
│              📋                     │
│                                     │
│       No items yet                  │
│                                     │
│   Get started by creating your      │
│   first item.                       │
│                                     │
│        [+ Create Item]              │
│                                     │
└─────────────────────────────────────┘
```
```

### Error State

```markdown
**Error State:**
- Show: When fetch/action fails
- Content:
  - Icon: ⚠️ or ❌
  - Title: Specific error (not generic)
  - Description: What user can do
  - Actions: Retry button, optional secondary action

**Layout:**
```
┌─────────────────────────────────────┐
│                                     │
│              ⚠️                     │
│                                     │
│   Unable to load items              │
│                                     │
│   Please check your connection      │
│   and try again.                    │
│                                     │
│   [Try Again]   [Go Back]           │
│                                     │
└─────────────────────────────────────┘
```
```

---

## Interaction Specifications

### Form Field Interaction

```markdown
**Email Field:**
| Event | Behavior |
|-------|----------|
| focus | Show hint text below field |
| blur | Validate format, show error if invalid |
| change | Clear error if previously invalid and now valid |
| submit | Re-validate all fields |

**Error Display:**
- Position: Below field
- Color: Red (text-red-500)
- Icon: ⚠️ prefix
- Animation: Fade in 150ms
```

### Button States

```markdown
**Submit Button:**
| State | Appearance |
|-------|------------|
| default | Primary color, enabled |
| hover | Slightly darker, cursor pointer |
| disabled | Grayed out, cursor not-allowed |
| loading | Show spinner, disable click |
| success | Green checkmark (1s), then reset |
| error | Shake animation, reset |

**Loading State:**
```
[ ◌ Saving... ]  <- Spinner + "Saving..." text
```
```

### Table Row Interaction

```markdown
**Row Hover:**
- Background: Light gray (bg-gray-50)
- Cursor: Pointer (if clickable)
- Actions: Show edit/delete buttons

**Row Selection:**
- Checkbox: Show in first column
- Selected: Light blue background (bg-blue-50)
- Bulk Actions: Appear in toolbar when 1+ selected

**Row Actions:**
| Action | Trigger | Behavior |
|--------|---------|----------|
| View | Click row | Navigate to detail page |
| Edit | Click edit button | Navigate to edit page |
| Delete | Click delete button | Show confirm dialog |
```

---

## Responsive Specification

### Breakpoint Definitions

```markdown
| Breakpoint | Width | Typical Device |
|------------|-------|----------------|
| xs | <480px | Small phone |
| sm | 480-639px | Large phone |
| md | 640-767px | Small tablet |
| lg | 768-1023px | Tablet |
| xl | 1024-1279px | Laptop |
| 2xl | ≥1280px | Desktop |
```

### Responsive Component Changes

```markdown
**Navigation:**
| Breakpoint | Behavior |
|------------|----------|
| <768px | Hamburger menu, slide-out drawer |
| ≥768px | Horizontal nav bar |
| ≥1024px | Horizontal nav + sidebar |

**Data Table:**
| Breakpoint | Behavior |
|------------|----------|
| <640px | Card layout, stack columns |
| 640-1023px | Table, hide low-priority columns |
| ≥1024px | Full table with all columns |

**Form:**
| Breakpoint | Behavior |
|------------|----------|
| <640px | Single column, full-width inputs |
| ≥640px | Two-column layout for short fields |
```

---

## Accessibility Checklist

For each screen, verify:

```markdown
## Accessibility Requirements

### Keyboard Navigation
- [ ] All interactive elements focusable via Tab
- [ ] Focus order matches visual order
- [ ] Focus visible (outline or highlight)
- [ ] Escape closes modals/dropdowns
- [ ] Enter/Space activates buttons
- [ ] Arrow keys navigate lists/menus

### Screen Reader
- [ ] Page has descriptive <title>
- [ ] Headings in logical order (h1 → h2 → h3)
- [ ] Images have alt text
- [ ] Form fields have labels
- [ ] Error messages linked to fields (aria-describedby)
- [ ] Live regions for dynamic content (aria-live)

### Visual
- [ ] Color contrast ≥ 4.5:1 for text
- [ ] Don't rely on color alone for meaning
- [ ] Text resizable to 200% without breaking
- [ ] Touch targets ≥ 44x44px

### Forms
- [ ] Required fields marked (visual + aria-required)
- [ ] Error messages clear and specific
- [ ] Focus moves to first error on submit
```

---

## Complete Screen Example

```markdown
## Screen: User Registration

### Meta
- **Route:** /register
- **Title:** "Create Account | MyApp"
- **Auth Required:** No (redirect if already logged in)

### Layout

```
┌─────────────────────────────────────────────────┐
│                    [Logo]                        │
├─────────────────────────────────────────────────┤
│                                                 │
│              Create your account                │
│                                                 │
│  Email *                                        │
│  ┌─────────────────────────────────────────┐   │
│  │ you@example.com                          │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Password *                                     │
│  ┌─────────────────────────────────────────┐   │
│  │ ••••••••••••                        [👁]│   │
│  └─────────────────────────────────────────┘   │
│  Strength: [████████░░] Strong                 │
│                                                 │
│  Full Name *                                    │
│  ┌─────────────────────────────────────────┐   │
│  │ John Doe                                 │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ☑ I agree to the Terms of Service             │
│                                                 │
│  [          Create Account          ]           │
│                                                 │
│  Already have an account? Log in               │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Components

| Component | Source | Props |
|-----------|--------|-------|
| Logo | existing | size="lg" |
| FormField | existing | label, error, required |
| Input | existing | type, value, onChange |
| PasswordInput | NEW | value, onChange, showToggle |
| PasswordStrength | NEW | password, showLabel |
| Checkbox | existing | checked, onChange, label |
| Button | existing | variant="primary", fullWidth, loading |
| Link | existing | href="/login" |

### States

| State | Trigger | Display |
|-------|---------|---------|
| Initial | Page load | Empty form, submit disabled |
| Validating | Field blur | Show field-specific error if invalid |
| Valid | All fields valid | Enable submit button |
| Submitting | Form submit | Button shows spinner, fields disabled |
| Error (validation) | API returns 400 | Show field errors, focus first |
| Error (conflict) | API returns 409 | Show "email exists" error with login link |
| Error (network) | Network failure | Show toast, keep form data |
| Success | API returns 201 | Redirect to /dashboard |

### Interactions

| Element | Event | Behavior |
|---------|-------|----------|
| Email | blur | Validate format, show error |
| Password | input | Update strength indicator |
| Password toggle | click | Show/hide password |
| Checkbox | change | Enable/disable submit |
| Submit | click | Validate all → API call → handle response |
| Login link | click | Navigate to /login |

### Responsive

| Breakpoint | Changes |
|------------|---------|
| Mobile | Full-width form, padding 16px |
| Desktop | Centered card, max-width 400px |

### Accessibility

- [ ] Form has aria-label="Registration form"
- [ ] Required fields have aria-required="true"
- [ ] Password toggle has aria-label="Show/Hide password"
- [ ] Errors linked via aria-describedby
- [ ] Submit button disabled state announced
```

This level of detail ensures pixel-perfect, consistent implementation.
