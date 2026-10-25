# Habitry Cheat Sheet (live walkthrough)

Full detail: `docs/CODE_WALKTHROUGH.md`

## 1. 30-second pitch
Habitry is a daily habit tracker in Flutter. I add habits with points, tick them off each day, and see progress and a 7-day streak. Data lives in Firestore (anonymous sign-in, per-user), so the UI updates live and works offline from cache. Built with clean architecture, `flutter_bloc`, `freezed`, and `get_it`, with tests enforcing the layer rules.

## 2. Architecture
- Layers: `presentation -> domain <- data`, plus `core`. Domain is pure Dart.
- State: `flutter_bloc`, one bloc per screen, created in the router from `get_it`.
- Errors: `Either<Failure, T>` (fpdart), never thrown past the repository.
- Persistence: Firestore `users/{uid}/habits` and `users/{uid}/completions/{habitId}_{yyyy-MM-dd}`.
- Single source of truth: writes go to Firestore, the stream re-emits, the bloc emits state.

```
lib/main.dart, app.dart, bootstrap.dart        startup + splash/error gate
lib/core/di/injection.dart                     get_it wiring
lib/core/router/app_router.dart                3 routes + BlocProviders
lib/core/theme/app_tokens.dart, app_theme.dart design system
lib/features/habits/
  domain/services/streak_calculator.dart       streak logic
  domain/usecases/                             add / toggle / delete / watch_*
  data/datasources/habit_remote_data_source.dart
  data/repositories/habit_repository_impl.dart
  presentation/bloc/today/today_bloc.dart
  presentation/pages/today_page.dart
  presentation/widgets/brand_mark.dart
```

## 3. If asked about X, open Y, say Z
| Topic | Open | Say |
| --- | --- | --- |
| Startup | `lib/main.dart`, `lib/app.dart`, `lib/bootstrap.dart` | `BootstrapGate` shows splash, runs `bootstrap()` (Firebase init, DI, anonymous sign-in), shows Retry on failure, then the router app. |
| State management | `presentation/bloc/today/today_bloc.dart` | Freezed events/states; `restartable()` + `emit.forEach` on the use-case stream. |
| Persistence | `data/datasources/habit_remote_data_source.dart` | Firestore under `users/{uid}`; local cache for offline; `awaitWriteAck` treats a 3s timeout as queued. |
| Add habit | `domain/usecases/add_habit.dart`, `bloc/add_habit/add_habit_bloc.dart`, `pages/add_habit_page.dart` | Form validates, bloc calls `AddHabit`, which trims, re-validates, saves; success pops and toasts. |
| Mark complete | `today_bloc.dart` (`_onToggled`), `data_source.setCompletion` | Done is a `set` on `habitId_date`, undone is a `delete`. UI updates from the stream. |
| Streak / progress | `domain/services/streak_calculator.dart`, `domain/entities/today_overview.dart` | 7-day window; days before creation are not counted; open today does not break the streak. Progress = earned / total points. |
| Validation | `domain/usecases/add_habit.dart`, `points_picker.dart` | Form for instant feedback, domain as the guard. Name max 60, description max 200, points 1 to 1000. |
| Theme / brand mark | `core/theme/app_tokens.dart`, `widgets/brand_mark.dart`, `core/brand.dart` | `AppTokens` is a ThemeExtension; mark is a `CustomPainter` driven by `progress` 0 to 1. |
| Tests | `test/architecture_test.dart`, `test/features/habits/domain/services/streak_calculator_test.dart` | Pure-Dart domain tests, `fake_cloud_firestore` for data, `bloc_test` for blocs, widget and accessibility tests. |

## 4. Demo script (about 5 min)
1. Cold start the app: splash, then Today. Point at the header (points, "X of Y done").
2. Tap **New habit**, tap save empty to show validation, enter "Drink 2L water", pick 15 points, tap **Save habit**. Toast "Habit added".
3. Tap the circle on the new row: toast "+15 points", progress animates. Tap again to undo.
4. Tap the row to open Detail: 7-day strip, streak, then **Mark today done** / **Mark today not done**. Back.
5. Swipe the row left, confirm **Delete** in the dialog. Optional: show `streak_calculator.dart` in the IDE.

## 5. Commands
```sh
flutter pub get
flutter devices
flutter run                       # or: flutter run -d <device-id>
flutter test                      # single run
flutter analyze
dart run build_runner build       # only after editing a freezed class
```

## 6. Top 8 questions
1. Why clean architecture? Business rules stay independent of Flutter/Firebase and easy to test; `architecture_test.dart` enforces it.
2. Why bloc? Explicit events and states, easy to trace and test with `bloc_test`; cost is boilerplate.
3. Why does a write not update the UI directly? The Firestore stream is the single source of truth.
4. How does offline work? Firestore cache serves reads and queues writes; `awaitWriteAck` times out at 3s. Gap: no "not synced" indicator.
5. Why `yyyy-MM-dd` `DateKey` instead of timestamps? Avoids time zone and DST problems; enables deterministic doc ids.
6. How is the streak computed? Consecutive done days back from today within a 7-day window, so the max is 7.
7. Why `Either<Failure, T>`? Failures are in the type signature; `mapExceptionToFailure` keeps Firebase out of the domain.
8. What would you improve? Edit habit, sync indicator, streaks over 7 days, field-validating Firestore rules, account linking, iOS build.

## 7. Pre-call checklist
- [ ] IDE open on the project, large font, key tabs open
- [ ] Emulator or phone booted (`flutter devices`), app running and past splash
- [ ] Firebase configured, Anonymous auth on; 2 or 3 demo habits, one done
- [ ] Screen share tested (IDE + emulator), notifications off
- [ ] Stable internet, hotspot as backup
- [ ] Microphone and camera checked
