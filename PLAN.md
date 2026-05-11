# Medicalic — Mobile Health Dashboard & Doctor Booking App

A Flutter mobile app where patients view their health metrics, browse doctors, book appointments via a calendar, and receive reminders.

---

## What This System Does

Medicalic lets patients monitor real-time health data (glucose, heart rate, cholesterol), find and view detailed doctor profiles, schedule appointments through an interactive calendar, and get push-notification reminders. A FastAPI backend serves all data, handles auth, and manages bookings.

---

## Architecture Diagram

```
┌──────────────────┐        HTTPS         ┌──────────────────┐
│  Flutter App      │ ──────────────────→ │  FastAPI Backend   │
│  (iOS / Android)  │ ←────────────────── │  (Python 3.11+)    │
└──────────────────┘                      └────────┬───────────┘
                                                   │
                                                   ▼
                                          ┌──────────────────┐
                                          │  SQLite / PostgreSQL│
                                          └──────────────────┘
```

For tonight: SQLite. Swap to PostgreSQL later if needed.

---

## Core Flows

### Flow 1 — Patient Views Health Dashboard
```
Patient opens app
    │
    ▼
Flutter requests GET /health/{patient_id}
    │
    ▼
FastAPI returns glucose, heart rate, cholesterol data
    │
    ▼
Flutter renders metric cards with bar charts
```

### Flow 2 — Patient Books an Appointment
```
Patient taps doctor → views profile
    │
    ▼
Patient picks date on calendar → POST /appointments
    │
    ▼
FastAPI validates slot, saves booking
    │
    ▼
Flutter shows confirmation + adds to reminders
```

### Flow 3 — Patient Browses Doctors
```
Patient swipes category tabs (Doctors / Therm / EHR)
    │
    ▼
Flutter requests GET /doctors?category=X
    │
    ▼
FastAPI returns list with name, specialty, rating, experience
    │
    ▼
Flutter renders doctor cards
```

---

## User Roles

- **Patient** — views health data, browses doctors, books appointments, receives reminders
- **Admin** (stretch) — manages doctor listings, views all appointments

---

## Folder Structure

```
medicalic/
├── backend/
│   ├── main.py                  # FastAPI app entry point
│   ├── requirements.txt
│   ├── app/
│   │   ├── routers/
│   │   │   ├── auth.py          # login/register
│   │   │   ├── doctors.py       # doctor listing + detail
│   │   │   ├── health.py        # health metrics CRUD
│   │   │   ├── appointments.py  # booking + calendar slots
│   │   │   └── reminders.py     # reminder CRUD
│   │   ├── models.py            # SQLAlchemy models
│   │   ├── schemas.py           # Pydantic request/response
│   │   ├── database.py          # DB engine + session
│   │   └── seed.py              # demo data loader
│   └── medicalic.db             # SQLite file (auto-created)
│
├── frontend/
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/              # data classes
│   │   │   ├── doctor.dart
│   │   │   ├── health_metric.dart
│   │   │   └── appointment.dart
│   │   ├── screens/
│   │   │   ├── home_screen.dart         # dashboard with metrics
│   │   │   ├── doctor_list_screen.dart  # category tabs
│   │   │   ├── doctor_detail_screen.dart# profile + calendar
│   │   │   ├── schedule_screen.dart     # calendar view
│   │   │   ├── message_screen.dart      # placeholder
│   │   │   └── profile_screen.dart      # placeholder
│   │   ├── widgets/
│   │   │   ├── metric_card.dart         # glucose/heart rate card
│   │   │   ├── doctor_card.dart         # doctor summary tile
│   │   │   ├── bar_chart_widget.dart    # mini bar charts
│   │   │   ├── category_tabs.dart       # Doctors/Therm/EHR tabs
│   │   │   └── calendar_widget.dart     # date picker grid
│   │   ├── services/
│   │   │   └── api_service.dart         # HTTP calls to backend
│   │   └── theme/
│   │       └── app_theme.dart           # blue/white/dark theme
│   └── pubspec.yaml
```

---

## Database Schema

```sql
CREATE TABLE patients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    avatar_url TEXT,
    location TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE doctors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    specialty TEXT NOT NULL,         -- 'Psychology Specialist', 'Thermologist', etc.
    category TEXT NOT NULL,          -- 'Doctors', 'Therm', 'EHR'
    experience_years INTEGER,
    rating REAL DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    patient_count INTEGER DEFAULT 0,
    location TEXT,
    avatar_url TEXT
);

CREATE TABLE health_metrics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER NOT NULL REFERENCES patients(id),
    metric_type TEXT NOT NULL,       -- 'glucose', 'heart_rate', 'cholesterol'
    value REAL NOT NULL,
    unit TEXT NOT NULL,              -- 'mg/dL', 'Bpm', '%'
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE appointments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER NOT NULL REFERENCES patients(id),
    doctor_id INTEGER NOT NULL REFERENCES doctors(id),
    date TEXT NOT NULL,              -- 'YYYY-MM-DD'
    time_slot TEXT,                  -- '10:00 AM'
    status TEXT DEFAULT 'booked',    -- 'booked', 'completed', 'cancelled'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reminders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    patient_id INTEGER NOT NULL REFERENCES patients(id),
    appointment_id INTEGER REFERENCES appointments(id),
    title TEXT NOT NULL,
    remind_at TIMESTAMP NOT NULL,
    seen INTEGER DEFAULT 0
);
```

---

## API Endpoints

| Method | Endpoint                     | Role    | What It Does                              |
|--------|------------------------------|---------|-------------------------------------------|
| POST   | `/auth/register`             | any     | Create patient account                    |
| POST   | `/auth/login`                | any     | Returns JWT token                         |
| GET    | `/doctors`                   | patient | List doctors, filter by `?category=`      |
| GET    | `/doctors/{id}`              | patient | Doctor detail: bio, rating, experience    |
| GET    | `/health/{patient_id}`       | patient | All recent metrics for dashboard          |
| POST   | `/health`                    | patient | Log a new health reading                  |
| GET    | `/health/{patient_id}/chart` | patient | Last 7 readings for bar chart             |
| GET    | `/appointments/{patient_id}` | patient | Patient's upcoming appointments           |
| POST   | `/appointments`              | patient | Book a slot with a doctor                 |
| DELETE | `/appointments/{id}`         | patient | Cancel appointment                        |
| GET    | `/reminders/{patient_id}`    | patient | List active reminders                     |
| POST   | `/reminders`                 | patient | Create reminder for an appointment        |

---

## Build Order

```
PHASE 1 — Backend boots, returns dummy data                     (30 min)
──────────────────────────────────────────────────────────────────
  1. mkdir backend && pip install fastapi uvicorn sqlalchemy      → installs clean
  2. Create main.py with a GET /ping route                       → curl returns {"status":"ok"}
  3. Create database.py + models.py with all 5 tables            → DB file auto-created on startup
  4. Create seed.py with 3 doctors + 1 patient + sample metrics  → python seed.py populates DB
  5. Create routers/doctors.py with GET /doctors, GET /doctors/1  → curl returns doctor JSON
  6. Create routers/health.py with GET /health/1                 → curl returns glucose + heart rate

PHASE 2 — All API endpoints live (HARDEST — most endpoints)     (45 min)
──────────────────────────────────────────────────────────────────
  1. Create routers/auth.py with POST /register and /login       → curl gets JWT back
  2. Add JWT middleware to protect patient routes                 → unauthenticated calls return 401
  3. Create routers/appointments.py POST + GET + DELETE           → curl books and retrieves slots
  4. Create routers/reminders.py POST + GET                      → curl creates reminder
  5. Create GET /health/{id}/chart returning last 7 values       → curl returns chart-ready array
  6. Test every endpoint with curl or Swagger UI                 → all 12 endpoints green

PHASE 3 — Flutter scaffold + navigation                         (30 min)
──────────────────────────────────────────────────────────────────
  1. flutter create frontend && add http, provider to pubspec    → app runs on emulator
  2. Create app_theme.dart: blue primary, white bg, dark cards   → theme matches screenshot
  3. Create bottom nav bar: Home, Schedule, Message, Profile     → tapping switches pages
  4. Create api_service.dart with base URL + GET/POST helpers    → print response in console

PHASE 4 — Home screen with health metrics                       (40 min)
──────────────────────────────────────────────────────────────────
  1. Create metric_card.dart: big number + unit + subtitle       → matches glucose/heart rate card
  2. Create bar_chart_widget.dart: 7 blue bars from data         → matches screenshot bar charts
  3. Create home_screen.dart: doctor card on top + metric list   → scrollable dashboard renders
  4. Wire api_service to fetch /health/1 and /doctors            → real data populates cards

PHASE 5 — Doctor list + detail + booking calendar                (45 min)
──────────────────────────────────────────────────────────────────
  1. Create category_tabs.dart: Doctors / Therm / EHR pills      → tapping filters list
  2. Create doctor_card.dart: avatar, name, specialty, rating     → matches screenshot cards
  3. Create doctor_list_screen.dart using tabs + cards             → scrollable doctor list works
  4. Create doctor_detail_screen.dart: profile + stats + calendar  → matches right panel screenshot
  5. Create calendar_widget.dart: month grid, tappable dates      → selected date highlights blue
  6. Wire POST /appointments on date tap + confirmation dialog    → booking saves to DB

PHASE 6 — Reminders + polish                                    (20 min)
──────────────────────────────────────────────────────────────────
  1. Add reminders section below calendar on detail screen        → "Doctor Reminders" card shows
  2. Wire GET /reminders to display upcoming reminders            → list renders from API
  3. Add "View Details" links on metric cards                     → navigates to detail view
  4. Final UI pass: spacing, fonts, shadows match screenshot      → pixel-close to design

PHASE 7 — Only if time: stretch goals
──────────────────────────────────────────────────────────────────
  1. Add local push notifications for reminders (flutter_local_notifications)
  2. Add search bar on home screen (filter doctors by name)
  3. Message screen placeholder with chat bubbles
  4. Profile screen with patient info + logout
```

---

## Critical Feature Detail — Phase 5: Doctor Detail + Calendar Booking

```
When patient opens doctor detail screen:
1. Flutter calls GET /doctors/{id} → populate header (name, rating, experience, patients)
2. Render category tabs below profile (Doctors / Therm / EHR) — informational only
3. Render heart rate + checkups row from GET /health/{patient_id}
4. Render calendar grid for current month
5. Available dates fetched from GET /appointments/available/{doctor_id}?month=YYYY-MM
6. Patient taps a blue date → confirmation bottom sheet appears
7. On confirm → POST /appointments { patient_id, doctor_id, date }
8. Calendar refreshes — booked date turns solid blue circle
9. Reminder auto-created via POST /reminders
```

---

## Minimum Viable Demo

- Patient sees a dashboard with glucose level (168.93 mg/dL) and heart rate (24.32 Bpm) with bar charts
- Patient taps "Doctors" tab and sees a list of doctor cards with name, specialty, rating
- Patient taps a doctor → sees full profile with experience, reviews, and a calendar
- Patient picks a date → appointment is saved and appears in schedule

---

## Anti-Mistake Habits

- Git commit after every working phase, not just at the end
- Test every FastAPI route with Swagger (`/docs`) before touching Flutter
- Hardcode the patient_id as 1 everywhere — auth polish is Phase 7 territory
- If a widget looks 80% right, move on — pixel-perfection is a Phase 6 task
- Keep one terminal for `uvicorn`, one for `flutter run` — never mix
- If stuck on a chart library for more than 10 min, use fl_chart and move on

<!-- test -->
