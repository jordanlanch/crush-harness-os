# API Catalog — All Endpoints

Base URL: `/api/v1`

## Health & Metrics (No Auth)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/health` | HealthHandler.Health | Basic health check |
| GET | `/health/ready` | HealthHandler.Ready | Readiness probe |
| GET | `/health/live` | HealthHandler.Live | Liveness probe |
| GET | `/metrics` | MetricsHandler | Prometheus metrics |
| GET | `/api/v1` | (inline) | API info (name, version, status) |

## Authentication (No Auth)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/api/v1/auth/login` | AuthHandler.Login | Staff login → JWT tokens |
| POST | `/api/v1/auth/register` | AuthHandler.Register | Staff registration |
| POST | `/api/v1/auth/refresh` | AuthHandler.Refresh | Refresh access token |
| POST | `/api/v1/auth/logout` | AuthHandler.Logout | Invalidate tokens |
| GET | `/api/v1/auth/me` | AuthHandler.Me | Current user info |

## Patients (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/patients` | PatientHandler.List | Paginated patient list |
| POST | `/patients` | PatientHandler.Create | Create patient |
| GET | `/patients/search` | PatientHandler.Search | Advanced search (name, doc, etc) |
| GET | `/patients/document/:type/:number` | PatientHandler.GetByDocument | Find by document |
| GET | `/patients/:id` | PatientHandler.GetByID | Get patient by ID |
| PUT | `/patients/:id` | PatientHandler.Update | Update patient |
| DELETE | `/patients/:id` | PatientHandler.Delete | Soft delete patient |

## Clinical Events (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/patients/:patientId/events` | PatientEventHandler.List | List events for patient |
| POST | `/patients/:patientId/events` | PatientEventHandler.Create | Create clinical event |
| GET | `/events/:id` | PatientEventHandler.GetByID | Get event by ID |
| PUT | `/events/:id` | PatientEventHandler.Update | Update event |
| DELETE | `/events/:id` | PatientEventHandler.Delete | Delete event |
| POST | `/events/:id/sign` | PatientEventHandler.Sign | Digitally sign event |

## Appointments (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/appointments` | AppointmentHandler.ListByDateRange | List by date range |
| POST | `/appointments` | AppointmentHandler.Create | Create appointment |
| GET | `/appointments/:id` | AppointmentHandler.GetByID | Get appointment |
| PUT | `/appointments/:id` | AppointmentHandler.Update | Update appointment |
| DELETE | `/appointments/:id` | AppointmentHandler.Delete | Delete appointment |
| PATCH | `/appointments/:id/status` | AppointmentHandler.UpdateStatus | Change status |
| GET | `/patients/:patientId/appointments` | AppointmentHandler.ListByPatient | Patient's appointments |
| GET | `/providers/:providerId/appointments` | AppointmentHandler.ListByProviderAndDate | Provider's appointments |
| GET | `/facilities/:facilityId/appointments` | AppointmentHandler.ListByFacilityAndDate | Facility's appointments |

## Schedules (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/schedules` | ScheduleHandler.Create | Create schedule |
| GET | `/schedules/:id` | ScheduleHandler.GetByID | Get schedule |
| PUT | `/schedules/:id` | ScheduleHandler.Update | Update schedule |
| DELETE | `/schedules/:id` | ScheduleHandler.Delete | Delete schedule |
| GET | `/providers/:providerId/schedules` | ScheduleHandler.ListByProvider | Provider's schedules |
| GET | `/providers/:providerId/availability` | ScheduleHandler.GetAvailableSlots | Available time slots |

## Schedule Blocks (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/schedule-blocks` | ScheduleHandler.CreateBlock | Block time slot |
| GET | `/schedule-blocks/:id` | ScheduleHandler.GetBlockByID | Get block |
| DELETE | `/schedule-blocks/:id` | ScheduleHandler.DeleteBlock | Remove block |
| GET | `/providers/:providerId/schedule-blocks` | ScheduleHandler.ListBlocksByProviderAndDate | Provider's blocks |

## Billing — Accounts (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/accounts` | BillingHandler.CreateAccount | Create billing account |
| GET | `/accounts/:id` | BillingHandler.GetAccount | Get account |
| GET | `/accounts/by-number/:number` | BillingHandler.GetAccountByNumber | Find by number |
| PUT | `/accounts/:id` | BillingHandler.UpdateAccount | Update account |
| PATCH | `/accounts/:id/close` | BillingHandler.CloseAccount | Close (generate invoice) |
| PATCH | `/accounts/:id/cancel` | BillingHandler.CancelAccount | Cancel account |
| GET | `/accounts/:id/items` | BillingHandler.GetAccountItems | List account items |
| POST | `/accounts/:id/items` | BillingHandler.AddAccountItem | Add item to account |
| DELETE | `/accounts/:id/items/:item_id` | BillingHandler.DeleteAccountItem | Remove item |
| GET | `/accounts/:id/payments` | BillingHandler.ListPaymentsByAccount | List payments |
| POST | `/accounts/:id/payments` | BillingHandler.CreatePayment | Process payment |
| GET | `/patients/:patient_id/accounts` | BillingHandler.ListAccountsByPatient | Patient's accounts |
| GET | `/facilities/:facility_id/accounts` | BillingHandler.ListAccountsByFacility | Facility's accounts |

## Billing — Payments (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/payments/:id` | BillingHandler.GetPayment | Get payment |
| PATCH | `/payments/:id/cancel` | BillingHandler.CancelPayment | Cancel payment |

## Billing — Service Catalog (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/services` | BillingHandler.ListServices | List all services |
| POST | `/services` | BillingHandler.CreateService | Create service |
| GET | `/services/search` | BillingHandler.SearchServices | Search services |
| GET | `/services/:id` | BillingHandler.GetService | Get service |
| GET | `/services/by-code/:code` | BillingHandler.GetServiceByCode | Find by CUPS code |
| PUT | `/services/:id` | BillingHandler.UpdateService | Update service |

## Inventory — Warehouses (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/warehouses` | InventoryHandler.ListWarehouses | List warehouses |
| POST | `/warehouses` | InventoryHandler.CreateWarehouse | Create warehouse |
| GET | `/warehouses/:id` | InventoryHandler.GetWarehouse | Get warehouse |
| PUT | `/warehouses/:id` | InventoryHandler.UpdateWarehouse | Update warehouse |
| GET | `/warehouses/:id/stock` | InventoryHandler.ListWarehouseStock | All stock levels |
| GET | `/warehouses/:id/stock/:material_id` | InventoryHandler.GetWarehouseStock | Single material stock |
| GET | `/warehouses/:id/low-stock` | InventoryHandler.GetLowStockAlerts | Low stock alerts |
| GET | `/warehouses/:id/entries` | InventoryHandler.ListEntriesByWarehouse | Entry history |
| GET | `/warehouses/:id/dispatches` | InventoryHandler.ListDispatchesByWarehouse | Dispatch history |
| GET | `/warehouses/:id/counts` | InventoryHandler.ListCountsByWarehouse | Count history |
| GET | `/facilities/:facility_id/warehouses` | InventoryHandler.ListWarehousesByFacility | Facility warehouses |

## Inventory — Materials (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/materials` | InventoryHandler.ListMaterials | List materials |
| POST | `/materials` | InventoryHandler.CreateMaterial | Create material |
| GET | `/materials/search` | InventoryHandler.SearchMaterials | Search materials |
| GET | `/materials/:id` | InventoryHandler.GetMaterial | Get material |
| GET | `/materials/by-code/:code` | InventoryHandler.GetMaterialByCode | Find by code |
| GET | `/materials/by-barcode/:barcode` | InventoryHandler.GetMaterialByBarcode | Find by barcode |
| PUT | `/materials/:id` | InventoryHandler.UpdateMaterial | Update material |

## Inventory — Entries (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/inventory/entries` | InventoryHandler.CreateEntry | Create stock entry |
| GET | `/inventory/entries/:id` | InventoryHandler.GetEntry | Get entry |
| PATCH | `/inventory/entries/:id/apply` | InventoryHandler.ApplyEntry | Apply to stock |

## Inventory — Dispatches (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/inventory/dispatches` | InventoryHandler.CreateDispatch | Create dispatch |
| GET | `/inventory/dispatches/:id` | InventoryHandler.GetDispatch | Get dispatch |
| PATCH | `/inventory/dispatches/:id/apply` | InventoryHandler.ApplyDispatch | Apply to stock |

## Inventory — Counts (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/inventory/counts` | InventoryHandler.CreateCount | Start physical count |
| GET | `/inventory/counts/:id` | InventoryHandler.GetCount | Get count |
| PATCH | `/inventory/counts/:id/items/:item_id` | InventoryHandler.UpdateCountItem | Update count item |
| PATCH | `/inventory/counts/:id/complete` | InventoryHandler.CompleteCount | Complete and adjust |

## Studies (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/studies/search` | StudyHandler.SearchStudies | Search studies |
| POST | `/studies` | StudyHandler.CreateStudy | Create study order |
| GET | `/studies/:id` | StudyHandler.GetStudy | Get study |
| GET | `/studies/by-number/:number` | StudyHandler.GetStudyByNumber | Find by number |
| PUT | `/studies/:id` | StudyHandler.UpdateStudy | Update study |
| PATCH | `/studies/:id/sign` | StudyHandler.SignStudy | Sign study results |
| PATCH | `/studies/:id/deliver` | StudyHandler.DeliverStudy | Mark as delivered |
| GET | `/studies/:id/items` | StudyHandler.GetStudyItems | Study line items |
| POST | `/studies/:id/items` | StudyHandler.AddStudyItem | Add study item |
| PUT | `/studies/:id/items/:item_id` | StudyHandler.UpdateStudyItem | Update item |
| DELETE | `/studies/:id/items/:item_id` | StudyHandler.DeleteStudyItem | Remove item |
| GET | `/studies/:id/attachments` | StudyHandler.GetStudyAttachments | Study files |
| POST | `/studies/:id/attachments` | StudyHandler.AddStudyAttachment | Upload file |
| DELETE | `/studies/:id/attachments/:attachment_id` | StudyHandler.DeleteStudyAttachment | Remove file |
| GET | `/patients/:patient_id/studies` | StudyHandler.ListStudiesByPatient | Patient's studies |
| GET | `/facilities/:facility_id/studies` | StudyHandler.ListStudiesByFacility | Facility studies |
| GET | `/facilities/:facility_id/studies/pending` | StudyHandler.ListPendingStudies | Pending studies |

## Study Categories & Templates (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/study-categories` | StudyHandler.ListCategories | List categories |
| POST | `/study-categories` | StudyHandler.CreateCategory | Create category |
| GET | `/study-categories/:id` | StudyHandler.GetCategory | Get category |
| GET | `/study-categories/by-code/:code` | StudyHandler.GetCategoryByCode | Find by code |
| PUT | `/study-categories/:id` | StudyHandler.UpdateCategory | Update category |
| GET | `/study-categories/:id/templates` | StudyHandler.ListTemplatesByCategory | Category templates |
| POST | `/study-templates` | StudyHandler.CreateTemplate | Create template |
| GET | `/study-templates/:id` | StudyHandler.GetTemplate | Get template |
| PUT | `/study-templates/:id` | StudyHandler.UpdateTemplate | Update template |

## RIPS (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/rips/batches` | RIPSHandler.CreateBatch | Create RIPS batch |
| GET | `/rips/batches/:id` | RIPSHandler.GetBatch | Get batch |
| GET | `/rips/batches/by-number/:number` | RIPSHandler.GetBatchByNumber | Find by number |
| PUT | `/rips/batches/:id` | RIPSHandler.UpdateBatch | Update batch |
| DELETE | `/rips/batches/:id` | RIPSHandler.DeleteBatch | Delete batch |
| GET | `/rips/batches/:id/errors` | RIPSHandler.GetValidationErrors | Validation errors |
| POST | `/rips/batches/:id/validate` | RIPSHandler.ValidateBatch | Run validation |
| POST | `/rips/batches/:id/generate` | RIPSHandler.GenerateRIPS | Generate files |
| GET | `/rips/batches/:id/preview` | RIPSHandler.PreviewRIPS | Preview before gen |
| GET | `/rips/batches/:id/download` | RIPSHandler.DownloadRIPS | Download ZIP |
| PATCH | `/rips/batches/:id/submit` | RIPSHandler.MarkAsSubmitted | Mark submitted |
| GET | `/facilities/:facility_id/rips/batches` | RIPSHandler.ListBatches | Facility batches |

## Reports & Statistics (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/reports/templates` | ReportHandler.GetTemplates | Available templates |
| GET | `/reports/templates/:code` | ReportHandler.GetTemplate | Get template |
| POST | `/reports/generate` | ReportHandler.GenerateReport | Generate report |
| GET | `/reports/jobs` | ReportHandler.GetJobs | Report job queue |
| GET | `/reports/jobs/:id` | ReportHandler.GetJob | Job status |
| GET | `/reports/jobs/:id/download` | ReportHandler.DownloadReport | Download result |
| GET | `/reports/stats/dashboard` | ReportHandler.GetDashboardStats | Dashboard KPIs |
| GET | `/reports/stats/patients` | ReportHandler.GetPatientStats | Patient statistics |
| GET | `/reports/stats/appointments` | ReportHandler.GetAppointmentStats | Appointment stats |
| GET | `/reports/stats/billing` | ReportHandler.GetBillingStats | Billing stats |
| GET | `/reports/stats/diagnoses` | ReportHandler.GetDiagnosisStats | Diagnosis stats |

## Admin (Auth + Admin Role Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/admin/users` | AdminHandler.GetUsers | List users |
| POST | `/admin/users` | AdminHandler.CreateUser | Create user |
| GET | `/admin/users/:id` | AdminHandler.GetUser | Get user |
| PUT | `/admin/users/:id` | AdminHandler.UpdateUser | Update user |
| DELETE | `/admin/users/:id` | AdminHandler.DeleteUser | Delete user |
| POST | `/admin/users/:id/reset-password` | AdminHandler.ResetUserPassword | Reset password |
| GET | `/admin/users/:id/permissions` | AdminHandler.GetUserPermissions | User permissions |
| GET | `/admin/permissions` | AdminHandler.GetPermissions | All permissions |
| GET | `/admin/roles/:role/permissions` | AdminHandler.GetRolePermissions | Role permissions |
| GET | `/admin/settings` | AdminHandler.GetSettings | System settings |
| GET | `/admin/settings/:key` | AdminHandler.GetSetting | Get setting |
| PUT | `/admin/settings/:key` | AdminHandler.UpdateSetting | Update setting |
| GET | `/admin/audit-log` | AdminHandler.GetAuditLogs | Audit trail |
| GET | `/admin/facilities` | AdminHandler.GetFacilities | List facilities |
| POST | `/admin/facilities` | AdminHandler.CreateFacility | Create facility |
| GET | `/admin/facilities/:id` | AdminHandler.GetFacility | Get facility |
| PUT | `/admin/facilities/:id` | AdminHandler.UpdateFacility | Update facility |
| DELETE | `/admin/facilities/:id` | AdminHandler.DeleteFacility | Delete facility |
| GET | `/admin/reviews/pending` | ProviderReviewHandler.ListPending | Pending reviews |
| POST | `/admin/reviews/:id/approve` | ProviderReviewHandler.Approve | Approve review |
| POST | `/admin/reviews/:id/reject` | ProviderReviewHandler.Reject | Reject review |

## AI Features (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/ai/status` | AIHandler.GetStatus | AI service status |
| POST | `/ai/transcription/start` | AIHandler.StartTranscription | Start session |
| GET | `/ai/transcription/:session_id` | AIHandler.GetTranscriptionSession | Get session |
| POST | `/ai/transcription/:session_id/audio` | AIHandler.ProcessAudioChunk | Send audio |
| POST | `/ai/transcription/:session_id/stop` | AIHandler.StopTranscription | End session |
| POST | `/ai/transcription/:session_id/apply` | AIHandler.ApplyTranscription | Apply to record |
| POST | `/ai/soap/generate` | AIHandler.GenerateSOAP | Generate SOAP note |
| POST | `/ai/soap/refine` | AIHandler.RefineSOAP | Refine SOAP note |
| POST | `/ai/cdss/diagnoses/suggest` | AIHandler.SuggestDiagnoses | Suggest diagnoses |
| POST | `/ai/cdss/interactions/check` | AIHandler.CheckInteractions | Drug interactions |
| POST | `/ai/cdss/studies/recommend` | AIHandler.RecommendStudies | Recommend studies |
| POST | `/ai/cdss/risk/calculate` | AIHandler.CalculateRisk | Calculate risk |
| GET | `/ai/cdss/patients/:patient_id/alerts` | AIHandler.GetPatientAlerts | Patient alerts |
| POST | `/ai/cdss/analyze` | AIHandler.GetFullAnalysis | Full analysis |
| POST | `/ai/chatbot/message` | AIHandler.ChatbotMessage | Chatbot message |
| GET | `/ai/chatbot/conversations/:conversation_id` | AIHandler.GetConversation | Get conversation |
| POST | `/ai/triage/start` | AIHandler.StartTriage | Start triage |
| GET | `/ai/triage/:triage_id/result` | AIHandler.GetTriageResult | Triage result |

## Public Routes (No Auth)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/public/providers/search` | PublicProviderHandler.Search | Search providers |
| GET | `/public/providers/featured` | PublicProviderHandler.GetFeatured | Featured providers |
| GET | `/public/providers/id/:id` | PublicProviderHandler.GetByID | Provider by ID |
| GET | `/public/providers/:slug` | PublicProviderHandler.GetBySlug | Provider by slug |
| GET | `/public/providers/:id/availability` | PublicProviderHandler.GetAvailability | Available slots |
| GET | `/public/specialties` | PublicProviderHandler.GetSpecialties | All specialties |
| GET | `/public/cities` | PublicProviderHandler.GetCities | All cities |
| GET | `/public/insurances` | PublicProviderHandler.GetInsurances | All insurances |
| GET | `/public/providers/:id/reviews` | ProviderReviewHandler.ListByProvider | Provider reviews |
| POST | `/public/reviews/:id/helpful` | ProviderReviewHandler.MarkHelpful | Mark review helpful |

## Patient Portal — Auth (No Auth)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/patient-portal/auth/register` | PatientPortalHandler.Register | Patient registration |
| POST | `/patient-portal/auth/login` | PatientPortalHandler.Login | Patient login |
| POST | `/patient-portal/auth/forgot-password` | PatientPortalHandler.ForgotPassword | Password reset request |
| POST | `/patient-portal/auth/reset-password` | PatientPortalHandler.ResetPassword | Reset password |

## Patient Portal — Authenticated (Patient Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/patient-portal/profile` | PatientPortalHandler.GetProfile | Get profile |
| PATCH | `/patient-portal/profile/notifications` | PatientPortalHandler.UpdateNotifications | Notification prefs |
| POST | `/patient-portal/auth/change-password` | PatientPortalHandler.ChangePassword | Change password |
| GET | `/patient-portal/appointments/upcoming` | PatientPortalHandler.GetUpcomingBookings | Upcoming appts |
| GET | `/patient-portal/appointments/past` | PatientPortalHandler.GetPastBookings | Past appts |
| GET | `/patient-portal/appointments/code/:code` | PatientPortalHandler.GetBookingByCode | Find by code |
| POST | `/patient-portal/appointments` | PatientPortalHandler.CreateBooking | Book appointment |
| POST | `/patient-portal/appointments/:id/cancel` | PatientPortalHandler.CancelBooking | Cancel booking |
| POST | `/patient-portal/appointments/:id/check-in` | PatientPortalHandler.CheckInOnline | Online check-in |
| POST | `/patient-portal/reviews` | ProviderReviewHandler.Create | Write review |
| GET | `/patient-portal/providers/:id/can-review` | ProviderReviewHandler.CanReview | Can review? |

## FHIR R4 (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| GET | `/fhir/metadata` | FHIRHandler.GetMetadata | Capability statement |
| GET | `/fhir/Patient/:id` | FHIRHandler.GetPatient | FHIR Patient resource |
| GET | `/fhir/Encounter/:id` | FHIRHandler.GetEncounter | FHIR Encounter resource |
| GET | `/fhir/Patient/:id/$everything` | FHIRHandler.GetEverything | All patient data (Bundle) |

## Provider Reviews (Auth Required)

| Method | Path | Handler | Description |
|--------|------|---------|-------------|
| POST | `/providers/:providerId/reviews/:id/response` | ProviderReviewHandler.AddProviderResponse | Provider responds |

---

**Total: 200+ endpoints across 18 handlers**
