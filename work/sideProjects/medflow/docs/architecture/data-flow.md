# Data Flow & Integration Pipelines

## RIPS Workflow (Resoluciones 3374/2000 + 866/2021)

RIPS (Registro Individual de Prestacion de Servicios) generates regulatory report files for Colombian healthcare authorities.

### RIPS File Types

| Code | Name | Content |
|------|------|---------|
| US | Usuarios | Patient demographics per encounter |
| AC | Consultas | Medical consultations |
| AP | Procedimientos | Procedures performed |
| AU | Urgencias | Emergency visits |
| AH | Hospitalizacion | Hospital admissions |
| AN | Recien Nacidos | Newborn records |
| AM | Medicamentos | Medications dispensed |
| AT | Otros Servicios | Other services |
| CT | Control | Batch control file (totals/checksums) |

### RIPS Generation Flow

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Create  │────▶│   Validate   │────▶│   Generate   │────▶│   Download   │
│  Batch   │     │   Batch      │     │   Files      │     │   ZIP        │
└──────────┘     └──────────────┘     └──────────────┘     └──────────────┘
     │                  │                    │                     │
     ▼                  ▼                    ▼                     ▼
 POST /rips/       POST /rips/          POST /rips/          GET /rips/
 batches           batches/:id/         batches/:id/         batches/:id/
                   validate             generate             download
     │                  │                    │
     ▼                  ▼                    ▼
  Status:           Status:              Status:
  DRAFT          VALIDATING →         VALID → GENERATED
                 VALID/INVALID

┌─────────────────────────────────────────────────────────────────────────┐
│                        RIPS Batch Lifecycle                             │
│                                                                         │
│  DRAFT ──▶ VALIDATING ──┬──▶ VALID ──▶ GENERATED ──▶ SUBMITTED        │
│                          │                                              │
│                          └──▶ INVALID (fix errors, re-validate)        │
│                                                                         │
│  Preview:  GET /rips/batches/:id/preview   (view before generating)    │
│  Errors:   GET /rips/batches/:id/errors    (validation error details)  │
│  Submit:   PATCH /rips/batches/:id/submit  (mark as sent to authority) │
└─────────────────────────────────────────────────────────────────────────┘
```

### RIPS Data Collection

```
┌────────────────────────────────────────────────────────────┐
│  Source Data (per facility, per period)                     │
│                                                            │
│  Patients ──────────────────────────────────▶ US file      │
│  PatientEvents (type=consultation) ──────────▶ AC file     │
│  PatientEvents (type=procedure) ─────────────▶ AP file     │
│  PatientEvents (type=emergency) ─────────────▶ AU file     │
│  PatientEvents (type=hospitalization) ───────▶ AH file     │
│  PatientEvents (type=newborn) ───────────────▶ AN file     │
│  Inventory movements (medications) ──────────▶ AM file     │
│  Studies + other services ───────────────────▶ AT file     │
│  Totals/checksums ───────────────────────────▶ CT file     │
└────────────────────────────────────────────────────────────┘
```

---

## FHIR R4 Integration (Resolución 1888/2025)

FHIR (Fast Healthcare Interoperability Resources) R4 for Colombian healthcare interoperability.

### Supported FHIR Resources

| FHIR Resource | Source Entity | Mapping |
|---------------|---------------|---------|
| Patient | `domain/patient` | Demographics, identifiers, contact |
| Encounter | `domain/patient_event` | Clinical encounters |
| Condition | PatientEvent.diagnoses | CIE-10 coded conditions |
| Observation | PatientEvent.vitals | Vital signs measurements |
| MedicationRequest | PatientEvent.prescriptions | Medication orders |
| Bundle | (composite) | Collection of resources |

### FHIR Transformation Pipeline

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│   Domain     │────▶│  FHIR            │────▶│   JSON       │
│   Entity     │     │  Transformer     │     │   Response   │
│              │     │  (infrastructure/ │     │   (R4 spec)  │
│  Patient     │     │   fhir/)         │     │              │
│  PatientEvent│     │                  │     │  { resource  │
│              │     │  Maps fields to  │     │    Type:     │
│              │     │  FHIR R4 spec    │     │    "Patient" │
│              │     │                  │     │    ... }     │
└──────────────┘     └──────────────────┘     └──────────────┘
```

### FHIR Endpoints

```
GET /api/v1/fhir/metadata              # Capability statement
GET /api/v1/fhir/Patient/:id           # Patient resource
GET /api/v1/fhir/Encounter/:id         # Encounter resource
GET /api/v1/fhir/Patient/:id/$everything  # All data for a patient (Bundle)
```

---

## AI Features Pipeline

### AI Gateway Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                        AI Gateway                              │
│                   (infrastructure/ai/)                          │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    AIGateway                              │  │
│  │                                                           │  │
│  │  Methods:                                                 │  │
│  │  ├── Transcribe(audio) → text                            │  │
│  │  ├── GenerateSOAP(transcript) → SOAP note                │  │
│  │  ├── SuggestDiagnosis(symptoms) → diagnoses[]            │  │
│  │  ├── CheckMedicationInteractions(meds) → interactions[]  │  │
│  │  ├── RecommendStudies(findings) → studies[]              │  │
│  │  ├── CalculateRisk(patient) → risk score                 │  │
│  │  └── ChatbotMessage(msg, history) → response             │  │
│  └───────────────────────────┬──────────────────────────────┘  │
│                              │                                  │
│              ┌───────────────┼───────────────┐                 │
│              │               │               │                 │
│              ▼               ▼               ▼                 │
│    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐         │
│    │   OpenAI     │ │  Anthropic   │ │  Local LLM   │         │
│    │   GPT-4o     │ │  Claude      │ │  Llama 3.2   │         │
│    │              │ │              │ │  (on-premise) │         │
│    └──────────────┘ └──────────────┘ └──────────────┘         │
└────────────────────────────────────────────────────────────────┘
```

### AI Medical Scribe Flow

```
┌──────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Doctor  │────▶│    Start     │────▶│   Process    │────▶│   Generate   │
│  speaks  │     │  Transcription│     │   Audio      │     │   SOAP Note  │
│          │     │  Session     │     │   Chunks     │     │              │
└──────────┘     └──────────────┘     └──────────────┘     └──────────────┘
                       │                     │                     │
                       ▼                     ▼                     ▼
                  POST /ai/            POST /ai/            POST /ai/
                  transcription/       transcription/       soap/generate
                  start                :session_id/audio

┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Refine     │────▶│    Apply     │────▶│   Save to    │
│   SOAP Note  │     │  to Event    │     │   Patient    │
│   (optional) │     │              │     │   Record     │
└──────────────┘     └──────────────┘     └──────────────┘
      │                     │
      ▼                     ▼
 POST /ai/            POST /ai/
 soap/refine          transcription/
                      :session_id/apply
```

### CDSS (Clinical Decision Support)

```
┌────────────────────────────────────────────────────────────┐
│                    CDSS Endpoints                           │
│                                                            │
│  POST /ai/cdss/diagnoses/suggest                           │
│  ├── Input: symptoms, vitals, patient history              │
│  └── Output: ranked diagnosis list with confidence scores  │
│                                                            │
│  POST /ai/cdss/interactions/check                          │
│  ├── Input: medication list                                │
│  └── Output: interactions, contraindications, warnings     │
│                                                            │
│  POST /ai/cdss/studies/recommend                           │
│  ├── Input: clinical findings, suspected diagnosis         │
│  └── Output: recommended lab/imaging studies               │
│                                                            │
│  POST /ai/cdss/risk/calculate                              │
│  ├── Input: patient demographics, history, vitals          │
│  └── Output: risk scores (cardiovascular, diabetes, etc)   │
│                                                            │
│  GET  /ai/cdss/patients/:patient_id/alerts                 │
│  └── Output: active clinical alerts for patient            │
│                                                            │
│  POST /ai/cdss/analyze                                     │
│  ├── Input: all patient data                               │
│  └── Output: comprehensive clinical analysis               │
└────────────────────────────────────────────────────────────┘
```

### AI Chatbot / Triage

```
Patient (Portal)
      │
      ├── POST /ai/chatbot/message
      │   ├── Input: message, conversation_id
      │   └── Output: AI response
      │
      ├── POST /ai/triage/start
      │   ├── Input: symptoms description
      │   └── Output: triage_id, initial questions
      │
      └── GET  /ai/triage/:triage_id/result
          └── Output: urgency level, recommended specialty, suggested actions
```

---

## Email System

### Architecture

```
┌────────────────────────────────────────────────────────────┐
│                    Email Service                            │
│                 (infrastructure/email/)                      │
│                                                            │
│  EmailUseCase                                              │
│  ├── SendWelcome(data)                                     │
│  ├── SendPasswordReset(data)                               │
│  ├── SendAppointmentConfirmation(data)                     │
│  ├── SendAppointmentReminder(data)                         │
│  ├── SendAppointmentCancellation(data)                     │
│  ├── SendBookingConfirmation(data)                         │
│  ├── SendReviewModeration(data)                            │
│  ├── SendStudyResult(data)                                 │
│  ├── SendInvoice(data)                                     │
│  └── SendCustom(data)                                      │
│                              │                              │
│              ┌───────────────┼───────────────┐             │
│              │               │               │             │
│              ▼               ▼               │             │
│    ┌──────────────┐ ┌──────────────┐        │             │
│    │   Resend     │ │     Log      │        │             │
│    │  (Production)│ │ (Development)│        │             │
│    │  API key     │ │ Prints to    │        │             │
│    │  required    │ │ stdout       │        │             │
│    └──────────────┘ └──────────────┘        │             │
└────────────────────────────────────────────────────────────┘
```

### Email Types

| Type | Trigger | Template Data |
|------|---------|---------------|
| Welcome | New user registration | Name, login URL |
| Password Reset | Forgot password request | Reset link, expiry |
| Appointment Confirmation | Appointment created | Date, time, provider, location |
| Appointment Reminder | 24h before appointment | Same as confirmation |
| Appointment Cancellation | Appointment cancelled | Reason, reschedule link |
| Booking Confirmation | Patient portal booking | Confirmation code, details |
| Review Moderation | Review submitted for review | Review content, approve/reject links |
| Study Result | Study completed/signed | Study type, result summary, view link |
| Invoice | Account closed | Invoice number, total, download link |

---

## Billing Flow

```
┌────────────┐    ┌────────────┐    ┌────────────┐    ┌────────────┐
│   Create   │───▶│  Add Items │───▶│  Process   │───▶│   Close    │
│  Account   │    │  (Services)│    │  Payments  │    │  Account   │
└────────────┘    └────────────┘    └────────────┘    └────────────┘
     │                  │                 │                  │
     ▼                  ▼                 ▼                  ▼
 POST /accounts   POST /accounts/   POST /accounts/   PATCH /accounts/
                  :id/items         :id/payments      :id/close

┌─────────────────────────────────────────────────────────────────┐
│                    Account Lifecycle                             │
│                                                                 │
│  OPEN ──────────────────────────────────▶ CLOSED                │
│   │  (add items, process payments)         │ (generates invoice)│
│   │                                        │                    │
│   └───────────────────────────────────▶ CANCELLED               │
│      PATCH /accounts/:id/cancel            (no invoice)         │
│                                                                 │
│  Account items link to Service catalog (CUPS codes)             │
│  Payments: cash, card, transfer, insurance                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Inventory Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    Inventory Operations                       │
│                                                              │
│  ENTRY (stock in)                                            │
│  POST /inventory/entries                                     │
│  ├── Creates entry record (warehouse, items, quantities)     │
│  └── PATCH /inventory/entries/:id/apply → updates stock      │
│                                                              │
│  DISPATCH (stock out)                                        │
│  POST /inventory/dispatches                                  │
│  ├── Creates dispatch record (warehouse, items, quantities)  │
│  └── PATCH /inventory/dispatches/:id/apply → reduces stock   │
│                                                              │
│  COUNT (physical inventory)                                  │
│  POST /inventory/counts                                      │
│  ├── Creates count record (warehouse, expected vs actual)    │
│  ├── PATCH /inventory/counts/:id/items/:item_id → update     │
│  └── PATCH /inventory/counts/:id/complete → adjusts stock    │
│                                                              │
│  ALERTS                                                      │
│  GET /warehouses/:id/low-stock → materials below reorder     │
└──────────────────────────────────────────────────────────────┘
```

---

## Study (Lab/Pathology) Flow

```
┌──────────┐    ┌──────────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────┐
│  Order   │───▶│  Process     │───▶│   Complete   │───▶│   Sign   │───▶│  Deliver │
│  Study   │    │  (add items, │    │   (results)  │    │  (doctor)│    │  (patient│
│          │    │  attachments)│    │              │    │          │    │   gets)  │
└──────────┘    └──────────────┘    └──────────────┘    └──────────┘    └──────────┘
     │                │                    │                  │              │
     ▼                ▼                    ▼                  ▼              ▼
 POST /studies   POST /studies/      PUT /studies/      PATCH /studies/ PATCH /studies/
                 :id/items           :id                :id/sign       :id/deliver
                 :id/attachments

Status: ordered → in_progress → completed → signed → delivered
```
