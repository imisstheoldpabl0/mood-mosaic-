System Architecture (high level)

Presentation: SwiftUI feature modules (Logging, Insights, Habits, Settings, Paywall)

Domain layer: Use cases (LogEmotion, FetchCorrelations, GenerateWeeklyReport, etc.)

Data layer: Repositories (HealthRepo, MoodRepo, WeatherRepo, ScreenTimeRepo)

Services: HealthKitService, WeatherKitService, LocationService, SpeechService, ScreenTimeService, NotificationService, SubscriptionService

Correlation Engine (local): Rolling window stats (Pearson/Spearman; time-lagged correlations; simple regression), cached daily

Sync: CloudKit private DB for entries/settings (optional: can v1 be local-only)

Feature Epics → Stories → Acceptance
Epic A — Emotion & Context Logging

A1: Hourly emotion slider + emoji palette + color wheel
Accept: 0–100 slider, 1–3 emotion tags, optional note (<= 140 chars)

A2: Quick “situational” buttons (friend mean, mom yelled, spilled coffee, etc.)
Accept: 1-tap capture with timestamp; editable within 10 min

A3: Speech-to-Text journaling (unlimited)
Accept: Tap mic → streaming transcript → save to entry; on-device when possible

A4: Daily habit tracker: caffeine (mg or servings), alcohol (units), food notes, exercise (manual)
Accept: Persisted defaults; inline pickers; day summary chip

A5: Notifications: configurable hourly prompts (quiet hours)
Accept: 95% delivery within hour; respects Focus modes

A6: Offline-first; auto-merge when online
Accept: No data loss on force-quit; conflict resolution deterministic

Epic B — Apple Health & Watch

B1: HealthKit auth flow (sleep, HRV, workouts, steps)
Accept: Granular toggles; explainer screens; denial fallback

B2: Sleep import (duration & quality/stages if granted)
Accept: Daily aggregation visible; mismatch banners if data missing

B3: Activity import (steps, workouts, active energy)
Accept: Show “Today” tiles + 7-day spark lines

B4: HRV & resting HR (stress proxy)
Accept: Min/Max/Avg per day; unit tests for transforms

B5: watchOS companion: wrist nudge + quick mood log
Accept: 2-tap logging on Watch; sync to iPhone < 10s via WatchConnectivity

Epic C — Environment, Screen Time, TV

C1: WeatherKit + CoreLocation → local weather, UV index, daylight duration
Accept: Retry on denied location; allow manual city

C2: “Time outside” proxy
Approach: Combine daylight hours + detected walking workouts + step bursts; ask user to confirm when uncertain
Accept: Daily estimate band (e.g., 20–40 min) + manual adjust

C3: Screen Time (category aggregates)
Accept: Daily total + top categories; correlates with mood

C4: TV time logging (manual or Apple TV activity if available)
Accept: Quick-add 15/30/60 min; daily total in insights

Epic D — Insights & Correlations

D1: Daily insight card (“sleep < 6h → +42% irritability”)
Accept: Computed locally, explainable chips (“based on 21 days”)

D2: Weekly report: trends, top drivers, habit deltas, suggested goals
Accept: PDF export; share sheet; private by default

D3: Time-lag analysis (yesterday’s sleep → today afternoon mood)
Accept: 1-day lag charts; confidence badges (low/med/high)

D4: Goal tracking (e.g., caffeine cutoff 2pm; 20 min sun)
Accept: Goal set → nudges → goal impact chart after 7 days

Epic E — Monetization & Accounts

E1: StoreKit 2 subscriptions (Monthly, Annual) + Intro trial
Accept: Local receipt validation; grace periods; family sharing awareness

E2: Paywall variants (A/B) with feature gating
Accept: Free: 3 logs/day + basic daily card; Paid: unlimited + correlations + weekly report

E3: Restore purchases, account deletion/export (GDPR)
Accept: Export JSON/CSV; full delete within app

Epic F — Privacy, Security, Compliance

F1: Data minimization: on-device processing by default
Accept: No PII leaves device without opt-in; clear privacy copy

F2: Encryption at rest (NSPersistentStoreFileProtectionComplete)
Accept: Keychain for secrets; background access respects user lock state

F3: App Store privacy nutrition labels & ATT (if any 3rd-party SDKs)
Accept: Pass App Review on first attempt

Data Model (Core Data, simplified)

MoodEntry: id, timestamp, intensity(0–100), emotions [String], note, source(manual/watch), tags [String]

HabitEntry: date, caffeineMg, alcoholUnits, mealsNotes, exerciseType, exerciseMinutes

SleepRecord: date, durationMin, efficiency, stageSummary?

ActivityRecord: date, steps, activeEnergy, workouts [type, minutes]

PhysioRecord: date, hrvMs, restingHR

EnvironmentRecord: date, uvIndex, temp, precipitation, daylightMinutes, outsideEstimateMin

ScreenTimeRecord: date, totalMinutes, categories [{name, minutes}]

Goal: id, type, target, window, startDate, status

Insight: id, date, type, text, confidence, dataRefs

SubscriptionState: tier, expiry, isTrial

Permissions Matrix & First-Run Flow

Welcome → value prop (science-based, private by design)

Choose cadence (hourly nudges on/off; quiet hours)

Request: Notifications → Location (While Using) → HealthKit (checkboxes for Sleep, Activity, HRV) → Speech → Screen Time (explain limits)

Engineering To-Do Checklist (sequenced)

Sprint 1 (Scaffold)

 Project setup (targets: iOS, watchOS), modules, SwiftLint

 App theme, typography, color tokens

 Core Data stack + lightweight migrations

 Navigation shell (TabView: Log, Insights, Habits, Settings)

 Feature flags (remote JSON)

Sprint 2 (Logging & Journaling)

 Emotion slider component + tag picker

 Situational quick-log buttons (configurable list)

 Speech-to-Text service (permissions, streaming UI)

 Hourly notification scheduler + quiet hours

 Offline queue & deduping

Sprint 3 (Health & Watch)

 HealthKit auth UI

 Sleep reader (HKCategory/Quantity samples)

 Steps/Active energy/workouts reader

 HRV/resting HR reader

 watchOS app: quick log + haptic; WC session

Sprint 4 (Environment & Screen Time)

 Location + WeatherKit client

 Daylight computation; outside estimate heuristic

 Screen Time aggregate fetch (DeviceActivity/FamilyControls where permissible)

 Manual TV logging UI

Sprint 5 (Insights & Correlation Engine)

 Aggregators (daily rollups)

 Correlation service (Pearson/Spearman; lagged windows)

 Daily insight card + explanation chips

 Weekly report composer (PDF export)

Sprint 6 (Monetization & Settings)

 StoreKit 2 products, purchase, restore

 Paywall variants + gating

 Data export/delete; privacy center

 Telemetry hooks; crash reporting

Sprint 7 (Polish & Beta)

 Haptics, animations, empty states

 Accessibility (Dynamic Type, VoiceOver labels)

 Unit/UI tests; TestFlight 500 users

 App Store metadata, screenshots, privacy labels

Phase 3 (Post-3 months)

 Consent + redaction layer for AI

 Claude API integration (summaries, suggestions)

 Predictive hints + feedback thumbs