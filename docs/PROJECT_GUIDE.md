# Habitry: Project Guide

A daily habit tracker built with Flutter, Firebase and clean architecture.
Users create habits, tick them off each day, earn points, and see a 7-day
streak for every habit.

| | |
| --- | --- |
| **App name** | Habitry |
| **Dart package** | `habit_tracker` |
| **Platforms** | Android (built and run on a physical phone), iOS (configured, not built) |
| **Backend** | Firebase: Cloud Firestore + Anonymous Authentication |
| **State management** | `flutter_bloc` |
| **Architecture** | Clean architecture: presentation, domain, data |
| **Firebase project** | `habit-tracker-assignment-9217` |

---

## Status (18 October 2026)

| Item | State |
| --- | --- |
| Three screens, Firestore data, anonymous auth | Done. Run on a physical Android phone. |
| Redesign (classical look), splash, icon, app name | Done. Splash and icon need a fresh install to see on the phone. |
| Automated tests | About 410 tests in 41 files. At the last full run, 409 passed and one splash timing test failed; that test has since been corrected. Rerun `flutter test` to confirm. |
| Static analysis | Last known: clean, after the fixes listed in the AI section. Rerun `flutter analyze`. |
| iOS | Configured only (icon, launch screen, iOS 15 target). Never built or run. |
| App name "Habitry" | Not yet checked against the Play Store or App Store. |
| Still to produce | Final screenshots, demo video, walkthrough video, GitHub link (see section 14). |

---

## 1. What the app does

### Screen 1: Today
- Editorial header with the date, the title "Today", the points earned today,
  "X of Y done", and a thin animated progress line.
- One row per habit: an animated check circle, the habit name, a mini 7-day
  streak bar with a "N-day streak" label, and the habit's points.
- Tap the check circle to mark a habit done or not done. A small toast shows
  "+10 points" or "-10 points".
- Tap a row to open the habit. Swipe a row left to delete it (with a
  confirmation dialog).
- A "New habit" button is docked at the bottom.
- Designed loading, empty and error states.

### Screen 2: Add Habit
- Form with a name, an optional description and a point value.
- The point value has a stepper, a numeric field and quick picks (5, 10, 15,
  20, 25). Allowed range is 1 to 1000.
- Inline validation messages. A loading state on the save button.

### Screen 3: Habit Detail
- The habit's name, description and point value.
- The last 7 days as a week strip: done, missed, today still open, or before
  the habit existed.
- The current streak, "X of 7 days", and the points earned this week.
- A button to mark today done or not done.

### Extras around the three screens
- Animated splash screen with the app mark, a native splash on both platforms
  and an app icon.
- Screen-reader labels, 48dp touch targets, and layouts tested at 2x text size.
- Animations that respect the system "reduce motion" setting.
- The day rolls over correctly if the app stays open past midnight.

---

## 2. Tech stack

### Required by the assignment
| Package | Used for |
| --- | --- |
| `flutter_bloc` | Screen state (Today, Add Habit, Habit Detail) |
| `freezed` / `freezed_annotation` | Immutable entities, events, states and the `Failure` type |
| `fpdart` | `Either<Failure, T>` return type for every repository call |
| `get_it` | Dependency injection (the composition root) |
| `go_router` | Navigation and route parameters |
| `cloud_firestore` | The only data source |

### Added, and why
| Package | Why |
| --- | --- |
| `firebase_core`, `firebase_auth` | Firebase start-up and anonymous sign-in, so each device has its own private data |
| `rxdart` | Combine the habits and completions streams inside use cases |
| `bloc_concurrency` | `restartable()`, so re-subscribing cancels the previous stream |
| `bloc_test`, `mocktail`, `fake_cloud_firestore` (dev) | Testing |

`cloud_firestore` is on the 6.x line because `fake_cloud_firestore` does not
support 7.x yet.

Fonts (Cormorant Garamond and Lora) are bundled as app assets under the SIL
Open Font License, so nothing is downloaded at runtime.

---

## 3. Architecture

### The dependency rule
Dependencies point inward. The domain layer knows nothing about Flutter,
Firebase or any other layer.

```
  presentation  ───────►   domain   ◄───────  data
  (pages, blocs,       (entities, use cases,   (Firestore data source,
   widgets)             repository interface,   models, repository
                        streak calculator)      implementation)
        ▲                                             ▲
        └───────────── get_it wires them ─────────────┘
```

| Layer | Contains | May import |
| --- | --- | --- |
| **domain** | Entities, repository interface, use cases, `StreakCalculator` | Pure Dart only (`fpdart`, `freezed_annotation`, `rxdart`) |
| **data** | Firestore data source, models, repository implementation, exception mapper | domain |
| **presentation** | Pages, widgets, blocs | domain (never data, never Firebase) |

### How the rule is enforced
`test/architecture_test.dart` reads every import in `lib/` and fails if a
rule is broken: domain importing Flutter, Firebase, data or presentation;
presentation importing data or Firebase; data importing presentation. The test
also checks itself against synthetic violations, so it cannot silently stop
working.

### Folder structure
```
lib/
  main.dart, app.dart, bootstrap.dart      start-up, splash gate
  core/
    di/            get_it registrations (the only place that knows concrete classes)
    router/        go_router routes and transitions
    theme/         design tokens, theme, motion rules
    error/         Failure (freezed), exceptions
    data/          exception -> Failure mapper
    time/          Clock, DateKey
    auth/          UserIdProvider and its Firebase implementation
    usecase/       UseCase and StreamUseCase base types
    brand.dart     the app name (single source of truth)
  features/habits/
    domain/        entities, repositories, services, usecases
    data/          datasources, models, repositories
    presentation/  bloc, pages, widgets, utils
test/              mirrors lib/, plus the architecture and design rule tests
tool/brand/        script that generates the app icon and splash images
design_reference/  the original standalone design prototype (reference only)
```

### Error handling
Repositories never throw. Every call returns `Either<Failure, T>`; streams emit
`Either` values. The data layer converts Firebase and other exceptions into a
small set of domain failures, so the UI never sees a framework exception.

| Failure | Typical cause |
| --- | --- |
| `network` | Firestore `unavailable`, `deadline-exceeded`, timeouts |
| `notFound` | Habit deleted while its screen was open |
| `unauthenticated` | No signed-in user, permission denied |
| `validation` | Invalid input (blank name, points out of range) |
| `server` | Other Firestore errors, malformed documents |
| `unknown` | Anything unexpected |

---

## 4. Data and backend

### Firestore model
```
users/{uid}/habits/{habitId}
    name, description, points,
    createdAt (Timestamp), createdDateKey ("yyyy-MM-dd")

users/{uid}/completions/{habitId}_{yyyy-MM-dd}
    habitId, dateKey ("yyyy-MM-dd"), completedAt (server timestamp)
```

### Why it is shaped this way
- **Deterministic completion IDs.** Marking a habit done is a `set`, undoing it
  is a `delete`. Both are safe to repeat and need no read first.
- **No composite index.** The Today and Detail screens only query a range on
  `dateKey`, which Firestore indexes automatically. One stream of recent
  completions serves both screens.
- **Date keys, not timestamps.** Streaks are calendar-day logic. A local
  `yyyy-MM-dd` string avoids time zone and daylight saving bugs. Day
  arithmetic goes through the calendar, never through `Duration(days: n)`.
- **Client-side IDs and timestamps.** `createdAt` comes from the app's clock,
  not `serverTimestamp()`, which is null in local snapshots.

### Security
`firestore.rules` lets a signed-in user read and write only their own subtree:

```
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

The app signs users in **anonymously**. There is no login screen, but every
device gets its own private `users/{uid}` partition.

### Offline behaviour
The UI is driven by Firestore snapshot streams, which update immediately from
the local cache. Firestore only completes a write once the server acknowledges
it, which never happens offline. So writes wait a few seconds and then treat a
timeout as "queued". Real errors, such as permission denied, still surface as
messages.

---

## 5. Domain logic

### Use cases
| Use case | Responsibility |
| --- | --- |
| `AddHabit` | Trims and validates input (name 1 to 60 characters, description up to 200, points 1 to 1000), stamps `createdAt` from the clock, saves |
| `ToggleHabitCompletion` | Marks a habit done or not done for the day the user is looking at |
| `DeleteHabit` | Deletes the habit and all of its completions in batched writes (400 per batch) |
| `WatchTodayOverview` | Combines habits with the last 7 days of completions into today's list, totals and a streak per habit |
| `WatchHabitDetail` | Combines one habit with its completions into the detail view and 7-day streak |

### Streak rules (`StreakCalculator`, pure Dart)
- The window is the last 7 days ending today.
- Each day is **done**, **missed**, or **not applicable** (before the habit was
  created). Today, when not yet done, is shown as open rather than missed.
- The **current streak** counts consecutive done days walking back from today.
  If today is not done yet it starts from yesterday, so the streak does not
  look broken until the day actually passes.
- The streak only looks inside the 7-day window, so its maximum is 7.

### Time
`Clock` is injected everywhere "now" matters, so tests can fix the date.
`DateKey` is an immutable calendar-day value (comparison, safe day arithmetic).

---

## 6. State management

Each screen has one bloc with freezed events and states.

| Bloc | Events | States |
| --- | --- | --- |
| `TodayBloc` | `started`, `habitToggled`, `habitDeleted`, `resumed` | `loading`, `loaded`, `failure` |
| `HabitDetailBloc` | `started`, `todayToggled`, `resumed` | `loading`, `loaded`, `failure` |
| `AddHabitBloc` | `submitted` | `initial`, `submitting`, `success`, `failure` |

Design decisions:
- **No manual optimistic updates.** Firestore's local cache already updates the
  stream instantly, so the bloc just listens.
- **One-shot messages.** A failed toggle or delete is emitted once inside the
  loaded state and cleared immediately, so a snackbar fires exactly once.
- **`restartable()`** on `started`, so a refresh replaces the old subscription.
- **`resumed`** re-checks the date when the app returns to the foreground and
  re-subscribes if the day changed.

---

## 7. Design system

The look follows a "classical" design taken from the author's own prototype
(`design_reference/new_ui`): near-white paper, ink text, one gold accent,
hairlines instead of cards, outlined buttons and serif type.

| Token | Value | Use |
| --- | --- | --- |
| `paper` | `#F3F2F2` | Background |
| `ink` | `#201F1D` | Text |
| `inkMuted` | `#605D5D` | Secondary text |
| `track` | `#D7D3D3` | Empty bars |
| `outline` | `#8A8686` | Unchecked circle (darkened to pass 3:1 contrast) |
| `accent` | `#B68235` | Strokes and bars, never small text |
| `accentTint` | `#FFF3E4` | Done state fill |
| `accentInk` | `#7D5411` | Gold text and the check mark |
| `danger` | `#9A3B2C` | Validation errors |

- **Fonts:** Cormorant Garamond for headings and numerals, Lora for body text.
- **Tokens, not literals.** All colours, spacing and type styles live in
  `lib/core/theme/`. `test/design_rules_test.dart` fails if a widget hard-codes
  a colour.
- **Motion:** short and purposeful (progress line, count changes, check
  animation, route transitions). `AppMotion` shortens or skips animation when
  the system asks to reduce motion.
- **Accessibility:** touch targets of at least 48dp, semantic labels (for
  example "Today, done"), a custom screen-reader action to delete a habit, and
  text contrast checks.

---

## 8. Navigation and start-up

| Route | Screen |
| --- | --- |
| `/` | Today |
| `/habits/new` | Add Habit |
| `/habits/:id` | Habit Detail (the id is a path parameter) |

Start-up (`BootstrapGate`):
1. Native splash (mark on paper) while the engine starts.
2. Flutter splash: the mark animates in and the wordmark fades up. It stays at
   least 0.9 seconds so the intro is not cut off.
3. Meanwhile Firebase initialises and the user is signed in anonymously.
4. The app cross-fades in. On failure, an error screen with Retry appears
   immediately; Retry adds no extra delay. With reduced motion there is no
   minimum time.

---

## 9. App identity

- **Name:** Habitry (`lib/core/brand.dart`).
- **Icon:** the app's own "done" check: a gold ring with a pale tint, a
  dark-gold check, and seven streak segments underneath (the last three gold).
  Android has adaptive and themed (Android 13) icons; iOS has the full icon set.
- **Splash:** Android 12+ system splash, pre-12 launch screen, iOS launch
  screen, and the animated in-app splash.
- **Regenerate:** `python3 tool/brand/generate_brand_assets.py` (needs
  `brew install librsvg`).

---

## 10. Testing

About 410 automated tests in 41 files. At the last full run 409 passed and one
splash timing test failed because it needed a second animation frame; that test
was corrected afterwards. Rerun `flutter test` to confirm a fully green suite.

| Area | What is covered |
| --- | --- |
| Domain | Every use case, including validation tables; the streak calculator across month, year and leap-day boundaries |
| Data | Firestore data source and repository against `fake_cloud_firestore`: per-user isolation, range queries, idempotent writes, cascade delete, error mapping |
| Blocs | State sequences with `bloc_test`, including one-shot failures and day rollover |
| Presentation | Pages and widgets: validation, toggling, delete confirmation, snackbars |
| Accessibility | No overflow at 1.0x, 1.5x and 2.0x text on a 320dp screen; semantic labels; reduced motion |
| Architecture | `architecture_test.dart` import rules; `design_rules_test.dart` token rules |
| Splash | Timing (minimum, error, retry), reduced motion, and a pixel-level check of the mark |

Run them:
```sh
dart format lib test
flutter analyze
flutter test
```

---

## 11. Run it

Prerequisites: Flutter 3.41+, the Firebase CLI and the FlutterFire CLI.

1. Create a Firebase project.
2. In the console, enable **Anonymous** sign-in (Authentication) and create a
   Firestore database.
3. Generate config for your project (overwrites `lib/firebase_options.dart`):
   ```sh
   flutterfire configure --platforms=android,ios
   ```
4. Deploy the rules: `firebase deploy --only firestore:rules`
5. `flutter pub get`, then `flutter run`.

Anonymous accounts live on the device. Uninstalling the app or clearing its
data starts a new, empty account; the old data stays in Firestore but is
unreachable from the app.

---

## 12. Decisions and trade-offs

| Decision | Reason | Trade-off |
| --- | --- | --- |
| Anonymous auth | No login screen needed, still private per device | Data is tied to the install |
| Completions as a top-level collection | One query serves Today and Detail | Cascade delete needs a query by `habitId` |
| 7-day window only | Matches the brief and keeps queries cheap | The streak count cannot exceed 7 |
| `Either` everywhere | Failures are explicit and testable | A little more code per call |
| Manual `get_it`, no code generation for DI | Fewer moving parts | Registrations are written by hand |
| Port a Riverpod prototype's *look*, not its code | The assignment requires the bloc stack and clean architecture | The prototype is kept only as a reference |

### Known limitations
- No edit-habit flow (out of scope for the assignment).
- iOS is configured (icon, launch screen, deployment target 15) but was never
  built or run.
- There is no "not synced" indicator for offline writes.
- A habit's completions are only guaranteed to be deleted if they can be read;
  offline, only cached completions are removed.
- The name "Habitry" has not been checked against the app stores.

---

## 13. How AI was used (material for the walkthrough)

This project was built with an AI coding agent (Kiro), using sub-agents for
coding and review, plus a design skill for the visual redesign. The
points below are real events from the build and can be adapted for the
walkthrough video.

### Where the AI had to be corrected or guided
- **Requirement conflict:** the supplied prototype used Riverpod, which the
  assignment forbids. The agent pushed back and ported the design instead of
  swapping the stack.
- **Stream bug:** a first stream wrapper used an `async*` generator, which
  ignores cancellation until its next value. A test hung for 30 seconds,
  exposing it, and it was rewritten with `rxdart`.
- **Test timing:** an animation test needed two full frame durations, not one;
  the first fix was wrong and was corrected.
- **Readability:** old-style digits in the serif font made "10" read as "IO".
  Found by looking at the phone, not by tests; fixed with lining figures.


### How clean architecture was verified
- `test/architecture_test.dart` fails the build on any layer violation.
- Repositories return `Either`, so the domain tests need no Firebase.
- Presentation tests use mocked use cases, proving blocs depend only on the
  domain.
- The data layer is tested against a fake Firestore, never mocks of sealed
  Firebase classes.

### Code optimization

The AI was asked to keep the code lean as well as working. These are the
concrete optimizations made during the build, each one reviewed by running the
analyzer and tests afterwards.

Designed in from the start:

| Area | What was done | Benefit |
| --- | --- | --- |
| Firestore queries | One range query on `dateKey` serves both Today and Detail | Fewer reads, no composite index to deploy |
| Writes | Deterministic IDs (`{habitId}_{date}`): `set` to mark done, `delete` to undo | No read before a write, and repeating a write is safe |
| Deleting a habit | Batched deletes, 400 per batch | Stays under Firestore's 500-write limit, fewer round trips |
| Streak logic | One pure `StreakCalculator` reused by Today and Detail | One place to test and fix |
| Re-subscribing | `restartable()` on `started` | Only one live subscription per screen |

Found and improved during the build:

| Area | Before | After |
| --- | --- | --- |
| Streams | A hand-written `async*` wrapper that kept the Firestore listener alive after a cancel (a test hung for 30 seconds) | An `rxdart` pipeline that cancels at once |
| Layout | Rows that overflowed at large text sizes | `Wrap`, `FittedBox` and baseline layouts; no overflow at 2x text on a 320dp screen |
| App name | The literal string repeated in several places | One `appName` constant |
| Dead code | The vermilion theme, Geist fonts, Phosphor icons, dark theme and unused widgets | Removed when the design changed |
| Lint rules | Flutter's default set | Stricter rules in `analysis_options.yaml` (single quotes, `const`, `unawaited_futures`, explicit return types), so the analyzer flags slips |
| Analyzer hints | `if (x != null) x` and a `final` that could be `const` | Null-aware element (`?x`) and `const`, as the analyzer suggested |
| Colours and type | Design values read from one token set in `lib/core/theme` | A test fails if a widget hard-codes a colour |

How the AI was prompted for this: after each feature it was told to run
`dart format`, `flutter analyze` and `flutter test`, and to fix every finding
before reporting done. It was also told never to delete or weaken a test to
make a change pass.

What was not optimized, on purpose: there is no caching layer or pagination.
Firestore's offline cache already covers the first, and a personal habit list is
small enough that the second would be needless complexity.

### Writing the test cases

Tests were written with the AI alongside each feature, not at the end. Each
task in the original plan ended with a demo and its tests, and was not accepted
while the suite was red. The later splash and polish work was written when
Flutter could not run in the agent's environment, so it was checked afterwards
on the author's machine.

**The test pyramid used** (about 410 test cases across 41 files)

| Layer | Tool | Typical cases |
| --- | --- | --- |
| Pure domain logic | `flutter_test` | Streak calculator: new habit, gaps, today still open, all 7 days, month, year and leap-day boundaries |
| Use cases | `mocktail` | Validation tables (blank name, 61-character name, 0 and 1001 points), failures passed through |
| Data layer | `fake_cloud_firestore` | Each user sees only their own data, range queries, repeated writes, cascade delete across batches |
| Repositories | `mocktail` | Every Firebase error code maps to the right `Failure` |
| Blocs | `bloc_test` | Exact state sequences, a failure message emitted once then cleared, day rollover, restart |
| Widgets and pages | `flutter_test` with mocked blocs | Validation messages, toggling, swipe-to-delete confirmation, snackbars |
| Accessibility | `flutter_test` | No overflow at 1.0x, 1.5x and 2.0x text; semantic labels; reduced motion |
| Architecture | Import-scanning test | Layer rules, with the checker tested against deliberate violations |
| Design rules | Token test | No hard-coded colours; contrast checks on the palette |
| Visuals | Pixel sampling | The app mark paints the right colours at each animation step |

**Techniques the AI used**
- **Table-driven tests** for the streak calculator and input validation, so one
  test body covers many cases and a new case is one line.
- **Fixed clock.** A `FixedClock` replaces "now", so date tests never depend on
  the day they run.
- **A fake database instead of mocks** for Firestore, because the Firebase
  classes are sealed and cannot be mocked.
- **Test the checker too.** The architecture test is itself tested against
  synthetic violations, so it cannot silently pass.
- **Test the unhappy path:** offline writes, malformed documents, a habit
  deleted while its screen is open, a failed toggle.

**Bugs the tests and tools found**
- Tests: a retry handler returned a `Future` into `setState`, which Flutter
  rejects.
- Tests: the first stream wrapper ignored cancellation, and the test hung for
  30 seconds.
- Tests: the progress header and detail screen overflowed at large text sizes.
- Tests: an animation test needed two full frame durations, not one.
- Analyzer: a missing `dart:typed_data` import in a test.
- Running the app: a missing `Directionality` above the `MaterialApp`, shown as
  an exception in the console.

**How the AI was kept honest**
- Tests had to be updated when the UI changed, never deleted or weakened; any
  removed test had to be listed with a reason.
- Two bugs (the "IO" digits and the stray gold block in the week strip) passed
  every test and were only seen on the real phone. So tests were treated as
  necessary but not sufficient, and each design change was also checked by eye.
- The AI could not run Flutter in some sandboxes. Rather than claim success it
  reported "not run", and the commands were run on the author's machine.

---
