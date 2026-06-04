# Plan: 100% Test Pass Rate — 100 remaining failures in 10 files

## File-by-file analysis

| # | File | Fails | Root cause |
|---|------|-------|-----------|
| 1 | `study-detail.component.spec.ts` | 50 | ALL fail — one shared root cause (mock service, route, or TestBed setup) |
| 2 | `reports-dashboard.component.spec.ts` | 12 | ALL fail — `ReportsService` mock doesn't match real service |
| 3 | `event-editor.component.spec.ts` | 9 | Stubs missing new inputs/outputs after AI scribe integration |
| 4 | `event-detail.component.spec.ts` | 8 | Stubs missing required inputs; spinner assertions stale |
| 5 | `ai-scribe.component.spec.ts` | 4 | My rewrite — missing ApiService/ClinicalTemplateStore mocks |
| 6 | `rips-preview.component.spec.ts` | 1 | `getStatusClass` assertion on shallow render |
| 7 | `rips-list.component.spec.ts` | 1 | Year filter assertion stale |
| 8 | `users-list.component.spec.ts` | 1 | Username/password field count assertion |
| 9 | `echocardiography-form.component.spec.ts` | 1 | Missing ReactiveFormsModule |
| 10 | `dispatch-form.component.spec.ts` | 1 | Missing patient mock |
| 11 | `clinical-record-list.component.spec.ts` | 1 | Event type filter DOM query stale |

## Strategy

1. Fix files 8-11 first (4 quick fixes, ~5 min each)
2. Fix study-detail (50 fails, find shared root cause)
3. Fix reports-dashboard (12 fails, mock service)
4. Fix event-editor + event-detail (stub updates)
5. Fix ai-scribe remaining 4
