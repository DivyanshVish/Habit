# Habitry

A Flutter app to create daily habits, tick them off, earn points and see a
7-day streak for each habit. Built with clean architecture, `flutter_bloc` and
Firebase (Firestore + anonymous auth).

| | |
| --- | --- |
| **Platforms** | Android (built and run on a physical phone), iOS (configured, not built) |
| **Backend** | Firebase: Cloud Firestore + Anonymous Authentication |
| **State management** | `flutter_bloc` |
| **Architecture** | Clean architecture: presentation, domain, data |

## Features

- **Today's Habits**: live list with a tappable done toggle, points per habit,
  and a header showing points earned and completion count. Swipe a habit to
  delete it (with confirmation).
- **Add Habit**: form with name, description and point value (1 to 1000).
- **Habit Detail**: name, description, points, a row of the last 7 days
  (done, missed, or before the habit existed) with a current-streak count, and
  a button to mark today done or not done.
- Loading, error and empty states, offline-friendly writes, screen reader
  labels, and layouts tested at 2x text size.

All data comes from Firestore. There is no mock or hardcoded data.

## Design

A light-only "classical" design: near-white ground, ink text, and a single gold
accent used for strokes and bars. Hairlines separate content instead of boxed
cards, buttons are outlined (never filled), and numerals use tabular figures.

- Headings and numerals: Cormorant Garamond. Body text: Lora. Both are bundled
  as app assets under `assets/fonts/` (SIL Open Font License, licence files
  included), so nothing is fetched at runtime.
- Design tokens (colours, spacing, radii, text styles) live in
  `lib/core/theme/`. Widgets read them from the theme; there are no hard-coded
  colours elsewhere.
- Each Today row shows a mini 7-day streak bar and a "N-day streak" label.
  The Today use case fetches the last 7 days of completions and reuses the
  pure `StreakCalculator` from the domain layer.
- Animations are short and respect the system reduced-motion setting.
- `design_reference/new_ui/` is the original standalone prototype this look was
  taken from. It is a separate Riverpod app kept for reference only; it is not
  compiled, imported or analysed as part of the app.

Tapping a check shows a short "+N points" or "-N points" toast.
`test/design_rules_test.dart` fails if a widget hard-codes a colour.

## App icon and splash

The mark is the app's own done-check: a gold ring around a check, with seven
streak segments underneath (four empty, three gold). The native assets are
generated from it by `python3 tool/brand/generate_brand_assets.py`, which needs
`brew install librsvg`. They cover the Android adaptive and themed icon, the
Android 12 splash, the iOS icon and the iOS launch image.

Once Flutter starts, `SplashView` takes over from the native splash with the
same mark in the same place (`BrandMark`, drawn with a `CustomPainter`). The
ring sweeps, the check draws and the streak segments appear, then the wordmark
fades in. The splash stays for at least 900 ms on launch, never delays the
error and Retry screen, and shows the final mark at once when the system asks to
reduce motion. The name is set in `lib/core/brand.dart`.

## Architecture

Dependencies point inward: `presentation -> domain <- data`.

```
lib/
  core/            di (get_it), router (go_router), theme, error (Failure),
                   time (Clock, DateKey), usecase base, auth, brand
  features/habits/
    domain/        entities, repository interface, use cases, StreakCalculator
    data/          Firestore data source, models, repository implementation
    presentation/  blocs, pages, widgets
test/              mirrors lib/, plus architecture and design rule tests
tool/brand/        script that generates the app icon and splash images
docs/              PROJECT_GUIDE.md (full project guide)
design_reference/  original design prototype (reference only)
```

Rules:

- `domain` is pure Dart: no Flutter, Firebase, data or presentation imports.
- Repositories return `Either<Failure, T>` (fpdart) and never throw.
- Blocs depend only on use cases. `presentation` never imports `data`.
- `get_it` is the only place that knows the concrete classes
  (`lib/core/di/injection.dart`).

`test/architecture_test.dart` scans every import in `lib/` and fails if a rule
is broken. It also tests the checker itself against synthetic violations.

### Firestore model

```
users/{uid}/habits/{habitId}
  name, description, points, createdAt (Timestamp), createdDateKey ("yyyy-MM-dd")
users/{uid}/completions/{habitId}_{yyyy-MM-dd}
  habitId, dateKey ("yyyy-MM-dd"), completedAt (server timestamp)
```

- Completion ids are deterministic, so marking done is a `set`, undoing is a
  `delete`, and neither needs a read first.
- The 7-day streak and Today screen query only a range on `dateKey`, which
  uses Firestore's automatic single-field index (no composite index to deploy).
- Dates are local calendar days stored as `yyyy-MM-dd`, so streaks do not
  shift with time zones or DST.
- Security rules (`firestore.rules`) let a user read and write only
  `users/{their uid}/**`.

### Design notes

- Streak rule: the window is the last 7 days ending today. Today not being
  done yet does not break the streak; it only breaks once the day passes. The
  current-streak count only looks inside the 7-day window.
- Writes complete only when the server acknowledges them, which never happens
  offline. Writes wait a few seconds, then treat a timeout as "queued"; the UI
  is driven by Firestore snapshot streams, which update immediately from the
  local cache.
- If the app stays open past midnight, Today and Detail re-subscribe when the
  app returns to the foreground.

## Packages

Required: `flutter_bloc`, `freezed`, `fpdart`, `get_it`, `go_router`,
`cloud_firestore`.

Added beyond the required list:

| Package | Why |
| --- | --- |
| `firebase_core`, `firebase_auth` | Firebase init and anonymous sign-in, so each device has its own data under `users/{uid}` |
| `rxdart` | Combine the habits and completions streams in use cases |
| `bloc_concurrency` | `restartable()` so re-subscribing cancels the old stream |
| `bloc_test`, `mocktail`, `fake_cloud_firestore` (dev) | Tests |

`cloud_firestore` is on the 6.x line because `fake_cloud_firestore` does not
support 7.x yet.

## Run it

Prerequisites: Flutter 3.41+, the Firebase CLI and the FlutterFire CLI.

1. Create a Firebase project (or pick one).
2. In the Firebase console:
   - **Authentication > Sign-in method**: enable **Anonymous**.
   - **Firestore Database**: create a database.
3. Generate the Firebase config for this app (this overwrites the placeholder
   `lib/firebase_options.dart` and adds the Android and iOS config files):

   ```sh
   flutterfire configure --platforms=android,ios
   ```

4. Deploy the security rules:

   ```sh
   firebase deploy --only firestore:rules
   ```

5. Run:

   ```sh
   flutter pub get
   flutter run
   ```

Until step 3 is done the app shows a "Firebase is not configured" screen with
a retry button.

Android needs a connection on first launch for anonymous sign-in. iOS targets
iOS 15 or later (required by the Firebase plugins).

## Test

```sh
flutter analyze
flutter test
```

There are about 410 tests in 41 files. The suite covers the use cases, the streak calculator (table-driven, including
month, year and leap-day boundaries), Firestore data source and repository
(with `fake_cloud_firestore`), blocs (`bloc_test`), pages and widgets, the
splash and app mark, text scale overflow, and the architecture and design
rules.

## Known limitations

- No edit-habit flow.
- iOS is configured (icon, launch screen, iOS 15 target) but was never built
  or run.
- No "not synced" indicator for offline writes.
- The streak is limited to the 7-day window, so its maximum is 7.

Generated `*.freezed.dart` files are committed so the project builds on clone.
To regenerate after changing a freezed class:

```sh
dart run build_runner build
```
