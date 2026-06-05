# Frontend UI Patterns

This document describes standardized UI patterns for loading states, error handling, and empty states in the MedNext Angular application.

## Shared Components

### Skeleton Loader Components

Located in `frontend/src/app/shared/components/skeleton-loader/`.

#### `SkeletonLoaderComponent`

Basic skeleton with configurable variant, width, height, and lines.

```typescript
import { SkeletonLoaderComponent } from '../../shared/components/skeleton-loader/skeleton-loader.component';

// In template:
<app-skeleton-loader variant="text" width="100%" lines="3" />
```

**Inputs:**
- `variant: 'text' | 'circular' | 'rectangular' | 'rounded'` (default 'text')
- `width: string` (default '100%')
- `height: string` (default 'auto')
- `lines: number` (default 1) – only for variant='text'

#### `SkeletonTableComponent`

Pre‑styled table skeleton with configurable row count and columns.

```html
<app-skeleton-table rowCount="5" />
```

**Inputs:**
- `rowCount: number` (default 5)
- `columns: Array<{ flex?: string; width?: string; type?: 'text' | 'avatar' }>` (default includes one avatar column and four text columns)

#### `SkeletonCardComponent`

Card‑style skeleton with optional header and footer.

```html
<app-skeleton-card [showHeader]="true" [showFooter]="false" [lineCount]="3" />
```

**Inputs:**
- `showHeader: boolean` (default true)
- `showFooter: boolean` (default false)
- `lineCount: number` (default 3)

### Empty‑State Component

Located in `frontend/src/app/shared/components/empty-state/`.

```typescript
import { EmptyStateComponent } from '../../shared/components/empty-state/empty-state.component';

// In template:
<app-empty-state
  [title]="'No hay datos'"
  [description]="'No se encontraron registros.'"
  [icon]="''"
  [actionText]="'Crear nuevo'"
  (action)="createNew()"
/>
```

**Inputs:**
- `title: string` (default 'No hay datos')
- `description: string` (default '')
- `icon: string` – SVG markup (optional, falls back to a generic icon)
- `actionText: string` – label for the action button (optional)
- `actionIcon: string` – SVG markup for the button icon (optional)
- `containerClass: string` – additional CSS classes for the container

**Output:**
- `action: EventEmitter<void>` – emitted when the action button is clicked

## Loading‑State Pattern with NgRx Signal Store

Components that consume a Signal Store should expose `loading()`, `error()`, and data signals (e.g., `patients()`, `appointments()`). The template follows a consistent control‑flow order:

1. **Loading state** – show a skeleton component.
2. **Error state** – show an empty‑state component with the error message.
3. **Empty data state** – show an empty‑state component with a helpful message and optional creation action.
4. **Data state** – render the actual list/table.

### Example Component Structure

```typescript
@Component({
  selector: 'app-example-list',
  standalone: true,
  imports: [CommonModule, SkeletonTableComponent, EmptyStateComponent],
  template: `
    @if (store.loading()) {
      <app-skeleton-table rowCount="5" />
    } @else if (store.error()) {
      <app-empty-state
        title="Error loading data"
        [description]="store.error()"
        actionText="Reintentar"
        (action)="store.loadData()"
      />
    } @else if (store.isEmpty()) {
      <app-empty-state
        title="No data found"
        description="Start by creating your first item."
        actionText="Create Item"
        (action)="createItem()"
      />
    } @else {
      <!-- Regular data presentation -->
      @for (item of store.items(); track item.id) {
        <!-- item row -->
      }
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ExampleListComponent {
  readonly store = inject(ExampleStore);

  createItem(): void {
    // navigation or dialog logic
  }
}
```

### Store Contract

Signal Stores that support this pattern should implement at least:

```typescript
export interface LoadableStore {
  loading: Signal<boolean>;
  error: Signal<string | null>;
  // plus data‑specific signals, e.g.:
  // items: Signal<Item[]>;
  // isEmpty: Signal<boolean>;
}
```

Existing stores (`PatientStore`, `AppointmentStore`, etc.) already conform to this contract.

## Error‑State Handling

- **Global errors** are caught by the `apiInterceptor` and displayed via `ToastService`. Component‑level errors are shown inline using the empty‑state component.
- When an error occurs, the component should display a user‑friendly message and offer a retry action that re‑triggers the failing operation (e.g., `store.loadPatients()`).
- For validation errors (e.g., form submissions), use field‑level error messages and keep the empty‑state pattern for load‑time errors only.

## Responsive Considerations

- Skeleton components use Tailwind’s `animate‑pulse` class for a subtle shimmer effect.
- Empty‑state components are centered and work on all screen sizes.
- Tables switch to card layouts on mobile; skeleton tables adapt accordingly.

## Testing

- Each component that uses skeleton/empty‑state patterns should have unit tests verifying that the correct UI is shown for each state (loading, error, empty, data).
- Use `data‑testid` attributes (already present on the shared components) to target elements in tests.

## Examples in Codebase

- **Patient list:** `frontend/src/app/features/patients/patient-list/patient-list.component.ts`
- **Appointment list:** `frontend/src/app/features/appointments/appointment-list/appointment-list.component.ts`
- **Shared components:** `frontend/src/app/shared/components/skeleton-loader/` and `frontend/src/app/shared/components/empty-state/`

## Summary

- Always use the shared skeleton components for loading states.
- Use the empty‑state component for error and empty‑data scenarios.
- Follow the loading → error → empty → data control‑flow order.
- Keep action labels consistent (e.g., “Reintentar” for retry, “Crear nuevo” for creation).
- Update component tests to cover all states.