# Implementation Plan: Classical (light-only, serif) redesign of habit_tracker

Project: `/Users/macbook/Desktop/Assignment` (package `habit_tracker`, Flutter 3.41.9 / Dart 3.11). No git worktree. **Do NOT run `git commit`.**
This plan REPLACES an older plan that described a vermilion/Geist design. Ignore anything else you find about that design.

Baseline measured while planning: `flutter test` = **356 passing**, `flutter analyze` = clean.
Spec source: the 13 Dart files in `design_reference/new_ui` (all read). It is a standalone Riverpod prototype. Do not import from it, modify it, or port Riverpod, `google_fonts`, `intl`, its data/domain/providers/`main.dart` or its `Habit` model. `analysis_options.yaml` already excludes `design_reference/**`.

Execution is split into FEATs (artifacts in `.agents/tasks/task-classical-redesign/`), then a review loop. This file is the master plan. Each FEAT file lists its own steps.

---
## 0. Findings from exploration (ground truth)

- Layers (enforced by `test/architecture_test.dart`): presentation -> domain <- data. Presentation must not import `/data/` or Firebase packages. Keep that.
- Stack to keep: `go_router` (`lib/core/router/app_router.dart`, `app_transitions.dart`), `flutter_bloc` (`TodayBloc`, `HabitDetailBloc`, `AddHabitBloc`), `get_it` (`lib/core/di/injection.dart`).
- Current theme: `lib/core/theme/app_tokens.dart` (`AppTokens` ThemeExtension with `light`+`dark`, vermilion accent, Geist `AppTextTokens`, `AppSpacing`, `AppRadii` pill/surface/small), `app_theme.dart` (`AppTheme.light()/dark()`, `overlayStyle`), `app_motion.dart` (`reduceMotion`, `AppMotion.of(context, d)`; keep as is).
- `context.tokens` falls back to the built-in token set when the theme has no extension. Many widget tests pump a bare `MaterialApp`. KEEP that fallback (now always the single light set).
- `lib/app.dart` has `BootstrapGate`, `HabitTrackerApp`, `_BootstrapShell`; all three set `theme` + `darkTheme`; uses `PhosphorIconsRegular.cloudSlash`.
- Phosphor is used in: `app.dart`, `habit_detail_page.dart`, `app_top_bar.dart`, `habit_tile.dart`, `day_chip.dart`, `animated_check.dart`, `points_picker.dart`, `new_habit_button.dart`, `state_views.dart`, and tests `state_views_test`, `streak_row_test`, `habit_detail_page_test`.
- Domain: `WatchTodayOverview(repository, clock)` currently calls `watchCompletions(from: today, to: today)` and builds `HabitWithStatus(habit, isDone)`. `WatchHabitDetail(repository, clock, calculator)` already shows the pattern (`windowStart = today.minusDays(StreakCalculator.defaultWindowDays - 1)`, `calculator.calculate(habit:, completions:, today:)`). `StreakCalculator` is pure and registered in DI (`injection.dart:63`).
- `HabitWithStatus(` is constructed in tests: `accessibility_test`, `accessibility_themed_test`, `today_bloc_test`, `today_page_test`, `progress_header_test`; `WatchTodayOverview(` in `injection.dart:55` and `watch_today_overview_test.dart`. `app_test.dart` only mocks the use case.
- `HabitRules` (`domain/usecases/add_habit.dart`): points 1..1000, name required (max 60), description max 200. The prototype only offers 5 chips; the real app keeps the numeric field + stepper + quick picks.
- Existing detail strings/semantics that must survive: 'Mark today done' / 'Mark today not done', 'Current streak: N day(s)', week cell labels 'Today, done', 'Friday, missed', 'Today, not done yet', 'before this habit was created', custom screen-reader action 'Delete habit' on rows, ErrorView/Bootstrap 'Retry'.
- Device: required device id is `10BF3A1CM30013Z`. At planning time `adb devices` showed ONLY `emulator-5554`. See section 9 for the fallback rule.
- Lint rules (`analysis_options.yaml`): `prefer_single_quotes`, `prefer_const_constructors`, `prefer_const_declarations`, `unawaited_futures`, `always_declare_return_types`, `avoid_print`. Wrap `HapticFeedback.*` in `unawaited(...)`.

---
## 1. Design tokens (exact set)

Light only. All hex values live ONLY in `lib/core/theme/app_tokens.dart`.

| Token (AppTokens member) | Value | Source / use | Contrast on paper `#F3F2F2` |
|---|---|---|---|
| `paper` | `#F3F2F2` | ground, scaffold, dialogs, bottom bar | n/a |
| `ink` | `#201F1D` | primary text | about 15:1 |
| `inkMuted` | `#605D5D` | secondary text (prototype n700) | about 5.9:1 |
| `inkStrong` | `#2D2B2B` | toast background (prototype n900) | text `paper` on it >= 12:1 |
| `track` | `#D7D3D3` | progress track, empty streak segments (prototype n300), decorative | decorative only |
| `outline` | `#8A8686` | unchecked circle, input borders, picker borders. Prototype n500 `#9B9797` is only about 2.6:1, so darkened, same neutral family | **>= 3:1 (about 3.2:1)** |
| `hairline` | `#201F1D` at 16% = `Color(0x29201F1D)` | dividers, decorative | decorative |
| `accent` | `#B68235` | gold. STROKES and BARS ONLY (check outline, progress fill, streak segments, focus ring, button border). Never small text | >= 3:1 (about 3.0:1, test must assert 3.0; if it fails by rounding, darken minimally and record) |
| `accentTint` | `#FFF3E4` | done fill of check, selected picker option | n/a |
| `accentInk` | `#7D5411` | all accent TEXT and checkmark glyph, kicker, button label | about 5.9:1 on paper, higher on tint |
| `danger` | `#9A3B2C` | delete, errors, validation | about 6:1 |

Removed token members: `raised`, `onInk`, `onAccent`, `accentSoft`, `skeleton`, `shadow`, `inkFaint`, the whole `AppTokens.dark`, `AppRadii.pill/surface/small`. If a surface needs a muted block (skeleton) use `track`.

Other token groups in `AppTokens`:
- `AppSpacing`: keep the 4-based scale, `screenMargin = 26` (prototype).
- `AppRadii`: `control = 4` (inputs, buttons, dialogs, picker, badge). `strip = 20` for the week-strip cell only (the prototype shape). Toast radius 30 lives in the snackbar theme only.
- `AppTextTokens` (family constants `heading = 'CormorantGaramond'`, `body = 'Lora'`; tabular figures on every numeral; never bake colour in except where noted):
  - `kicker`: Lora 11 / w500 / letterSpacing 1.8 (colour `accentInk` by default; muted variant via copyWith)
  - `displayTitle`: Cormorant 46 / w400 / height 1.05 ("Today")
  - `displayNumeral`: Cormorant 64 / w400 (earned points)
  - `headline`: Cormorant 42 / w400 / height 1.02 (habit name on Detail; "New habit" uses 44)
  - `dialogTitle`: Cormorant 26 / w600
  - `streakNumeral`: Cormorant 48 / w400 (detail streak count)
  - `rowTitle`: Cormorant 21 / w600 (habit row name)
  - `numeral`: Cormorant 24 / w600 (row points, picker numbers use 20 / w600 via copyWith)
  - `numeralSmall`: Cormorant 26 / w600 ("X" in "X of Y done")
  - `emptyState`: Cormorant 22 / italic
  - `body`: Lora 15 / height 1.5; `bodySmall`: Lora 13 / 1.4; `caption`: Lora 12; `tiny`: Lora 10 + letterSpacing 1.2 ("PTS")
  - `button`: Lora 16 / w500
  - `italicNote`: Lora 14 / italic ("per completion")

---
## 2. Fonts to bundle (no runtime fetch)

`google/fonts` on GitHub only ships VARIABLE fonts for these two families (verified via the contents API: `ofl/cormorantgaramond/CormorantGaramond[wght].ttf`, `ofl/lora/Lora[wght].ttf`), so true static TTFs are not in that repo. Use the upstream OFL repos that google/fonts references (`upstream_info.md`) for the static TTFs, and the google/fonts copies for the licences. All URLs below were checked (HTTP 200; first bytes `00 01 00 00` = TrueType).

| Asset path | Download URL |
|---|---|
| `assets/fonts/CormorantGaramond-Regular.ttf` (w400) | `https://raw.githubusercontent.com/CatharsisFonts/Cormorant/master/fonts/ttf/CormorantGaramond-Regular.ttf` |
| `assets/fonts/CormorantGaramond-SemiBold.ttf` (w600) | `https://raw.githubusercontent.com/CatharsisFonts/Cormorant/master/fonts/ttf/CormorantGaramond-SemiBold.ttf` |
| `assets/fonts/CormorantGaramond-Italic.ttf` (w400 italic) | `https://raw.githubusercontent.com/CatharsisFonts/Cormorant/master/fonts/ttf/CormorantGaramond-Italic.ttf` |
| `assets/fonts/Lora-Regular.ttf` (w400) | `https://raw.githubusercontent.com/cyrealtype/Lora-Cyrillic/main/fonts/ttf/Lora-Regular.ttf` |
| `assets/fonts/Lora-Medium.ttf` (w500) | `https://raw.githubusercontent.com/cyrealtype/Lora-Cyrillic/main/fonts/ttf/Lora-Medium.ttf` |
| `assets/fonts/Lora-Italic.ttf` (w400 italic) | `https://raw.githubusercontent.com/cyrealtype/Lora-Cyrillic/main/fonts/ttf/Lora-Italic.ttf` |
| `assets/fonts/OFL-CormorantGaramond.txt` | `https://raw.githubusercontent.com/google/fonts/main/ofl/cormorantgaramond/OFL.txt` |
| `assets/fonts/OFL-Lora.txt` | `https://raw.githubusercontent.com/google/fonts/main/ofl/lora/OFL.txt` |

Procedure: `curl -fsSL -o <path> <url>` for each. Then verify each TTF with `file` (must say TrueType) and `xxd -l 4` (`0001 0000`), and size > 50 KB. Delete anything that is an HTML/404 body. Licence files must contain "SIL OPEN FONT LICENSE". Note: `curl -w`/`-o` combined with `-s` printed misleading output in the planning shell. Use `curl -fSL` and check the exit code, then verify with `file`.

Fallback chain if a download fails: (1) cut statics from the google/fonts variable files with `pip install fonttools` + `fonttools varLib.instancer "<file>[wght].ttf" wght=400 -o ...` (source URLs `https://raw.githubusercontent.com/google/fonts/main/ofl/cormorantgaramond/CormorantGaramond%5Bwght%5D.ttf`, `.../ofl/lora/Lora%5Bwght%5D.ttf`); (2) only if bundling is impossible, `flutter pub add google_fonts` and report the deviation loudly.

pubspec `flutter:` section (replace the Geist block, keep `uses-material-design: true`):
```yaml
  fonts:
    - family: CormorantGaramond
      fonts:
        - asset: assets/fonts/CormorantGaramond-Regular.ttf
        - asset: assets/fonts/CormorantGaramond-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/CormorantGaramond-Italic.ttf
          style: italic
    - family: Lora
      fonts:
        - asset: assets/fonts/Lora-Regular.ttf
        - asset: assets/fonts/Lora-Medium.ttf
          weight: 500
        - asset: assets/fonts/Lora-Italic.ttf
          style: italic
  assets:
    - assets/fonts/OFL-CormorantGaramond.txt
    - assets/fonts/OFL-Lora.txt
```
Delete `assets/fonts/Geist-Regular.ttf`, `Geist-Medium.ttf`, `Geist-SemiBold.ttf`, `OFL.txt` (Geist licence). Only weights 400/500/600 and italic are used anywhere. The prototype sets `fontFeatures: [tabularFigures]` on headings. Keep it; if the bundled face lacks `tnum` it is a harmless no-op (note in findings).

---
## 3. Packages

- Remove: `flutter pub remove phosphor_flutter` (use Material icons: `Icons.arrow_back`, `Icons.close`, `Icons.check`, `Icons.add`, `Icons.remove`, `Icons.delete_outline`, `Icons.cloud_off_outlined`, `Icons.error_outline`, `Icons.undo`).
- Add: none. Do NOT add `intl`, `google_fonts` (unless fonts cannot be bundled), `flutter_riverpod`.
- Run `flutter pub get` and confirm `pubspec.lock` no longer lists `phosphor_flutter`.

---
## 4. Domain extension (the ONLY permitted domain change)

1. `lib/features/habits/domain/entities/habit_with_status.dart`: add `required HabitStreak streak` (import `habit_streak.dart`). Keep `habit` and `isDone`.
2. `lib/features/habits/domain/usecases/watch_today_overview.dart`: constructor becomes `WatchTodayOverview(this._repository, this._clock, this._calculator)` (same shape as `WatchHabitDetail`). In `call`: `windowStart = today.minusDays(StreakCalculator.defaultWindowDays - 1)`; combine `watchHabits()` with `watchCompletions(from: windowStart, to: today)`. `isDone` keeps the existing derivation (a completion for that habit with `dateKey == today`); add `streak: _calculator.calculate(habit: habit, completions: completions, today: today)`. No data-layer or repository change (`watchCompletions` already takes any range; no index needed).
3. `lib/core/di/injection.dart` line 55: pass `getIt<StreakCalculator>()` (registration only; `StreakCalculator` is already registered at line 63, make sure order does not matter for lazy singletons).
4. Regenerate: `dart run build_runner build --delete-conflicting-outputs` (updates `habit_with_status.freezed.dart`).
5. Tests touched:
   - `test/features/habits/domain/usecases/watch_today_overview_test.dart`: construct with `const StreakCalculator()`; stubs now use `from: today.minusDays(6), to: today`; keep every existing assertion; ADD tests for: per-habit streak days (7 days, oldest first, last is today), `currentStreak` with a run ending yesterday while today open, other habits' completions ignored, completions outside the window ignored, `notApplicable` before `createdDateKey`, `isDone` still true only for today.
   - `test/helpers/builders.dart`: add `buildStreak({...})` (move the helper from `streak_row_test.dart`) and `buildItem(...)` to build a `HabitWithStatus` with a streak.
   - Update constructions in `accessibility_test`, `accessibility_themed_test`, `today_bloc_test`, `today_page_test`, `progress_header_test` to pass `streak:`.
   - `test/features/habits/domain/services/streak_calculator_test.dart` must stay unchanged and green.
6. Bloc public events/states are NOT changed. `TodayOverview` and the blocs recompile unchanged.

---
## 5. Files to change / create / remove

### Theme and app shell
- REWRITE `lib/core/theme/app_tokens.dart` (section 1; delete `dark`; keep `ThemeExtension`, `copyWith`, `lerp`; keep `context.tokens` with the light fallback).
- REWRITE `lib/core/theme/app_theme.dart`: single `AppTheme.light()`; delete `dark()`; `overlayStyle()` becomes light only (dark icons, transparent bars). Theme contents: `ColorScheme.light` mapped from tokens (primary `accent`, onSurface `ink`, error `danger`, outline `outline`, outlineVariant `hairline`, surfaceTint transparent), `scaffoldBackgroundColor: paper`, `fontFamily: Lora`, textTheme from tokens, **no `filledButtonTheme`** (outlined buttons only), `outlinedButtonTheme` (foreground `accentInk`, side `accent` 1.5dp, `RoundedRectangleBorder(4)`, min size `Size.fromHeight(52)`, text `button`, overlay accent @10%), `textButtonTheme` (muted label, 48dp min, 4dp), `iconButtonTheme` (48x48), `inputDecorationTheme` (outline borders radius 4 colour `outline`; focused `accent` width 2; error `danger`; floating label muted kicker style; hint muted; contentPadding 14), `snackBarTheme` (bg `inkStrong`, floating, text Lora 14 colour `paper`, `StadiumBorder`-like radius 30, elevation 0), `dialogTheme` (bg `paper`, no tint, radius 4 with hairline border, title `dialogTitle`), `dividerTheme` (hairline, 1), `progressIndicatorTheme` (colour `accent`, strokeWidth 2), `tooltipTheme` (`inkStrong` bg, `paper` text, radius 4), `textSelectionTheme` (cursor `ink`, selection accent @30%), `splashFactory: InkRipple`.
- KEEP `lib/core/theme/app_motion.dart` unchanged.
- EDIT `lib/core/router/app_transitions.dart`: only rename token uses if any; keep the subtle slide/fade and the `reduceMotion` short-circuit (page simply appears).
- EDIT `lib/app.dart`: remove `darkTheme`, set `themeMode: ThemeMode.light` on both `MaterialApp.router` and the bootstrap shell, remove phosphor import (use `Icons.cloud_off_outlined`), overlay style light only. Loader and error screens restyled (section 7).
- DELETE `assets/fonts/Geist-*.ttf`, `assets/fonts/OFL.txt`; ADD fonts (section 2); EDIT `pubspec.yaml` (and `pubspec.lock` via pub).

### Presentation widgets (`lib/features/habits/presentation/widgets/`)
- NEW `check_toggle.dart` - `CheckToggle({done, onPressed, tooltip})`. 48x48 hit area (`SizedBox.square(48)` + `InkResponse`), visible 34dp circle with 7dp inset. Outline 1.5dp `outline` when open; when done: border `accent`, fill `accentTint`, `Icons.check` size 18 colour `accentInk`. Animates 200 ms via `AppMotion.of`. Keeps `Tooltip` + `Semantics(button, checked, label)`. Replaces `animated_check.dart`.
- DELETE `animated_check.dart` (+ migrate `animated_check_test.dart` to `check_toggle_test.dart`, keep all behaviours: tap, semantics, 48dp, reduced motion).
- NEW `hairline.dart` - `Hairline()` = `Divider(height: 1, thickness: 1)` using the hairline token.
- NEW `bottom_action.dart` - `BottomAction({child})`: `paper` background, top border hairline, `SafeArea(top: false)`, padding `fromLTRB(26, 16, 26, 12)`.
- NEW `toast.dart` - `showToast(BuildContext, String)` and `showErrorSnackBar(BuildContext, String)` (section 6).
- NEW `streak_bar.dart` - `MiniStreakBar({HabitStreak streak})`: 7 segments 14x3 with 3dp gap, `accent` when `DayStatus.done`, else `track`, then streak text via `Wrap` so it can drop below at 2x text. Whole thing is `ExcludeSemantics` under one label on the row (see habit_tile). Text: `streak.currentStreak > 0 ? '${n}-day streak' : 'No streak'`.
- REWRITE `habit_tile.dart` (prototype row): `InkWell` row (min height 72, vertical padding 11) `[CheckToggle] [Expanded: name (rowTitle, w600, dimmed `inkMuted` + strikethrough when done, maxLines 3, ellipsis) + MiniStreakBar] [points numeral (right aligned, FittedBox) over tiny 'PTS']`. Keep: `Dismissible(endToStart)` with `confirmDismiss` that asks via `confirmDeleteHabit` and always returns false (row disappears only when the stream drops it), custom semantics action `'Delete habit'`, `Key('dismiss-<id>')`. Swipe background: `paper` with a `danger` `Icons.delete_outline` and a hairline, no fill. Description line is dropped from the row (the prototype has none). It stays on Detail.
- REWRITE `progress_header.dart` (prototype header, no card): kicker via `formatKicker(overview.date)`; 'Today' (`displayTitle`, 46); earned numeral (`AnimatedCount`, 64) + '/ N points' on a baseline row inside `FittedBox(scaleDown)`; 'X of Y done' (X in `numeralSmall`) in a `Wrap` with `spaceBetween` so it wraps under at large scale; 3dp progress: `track` bar + `AnimatedFractionallySizedBox`/`TweenAnimationBuilder` `accent` fill, 400 ms via `AppMotion.of`, key `Key('progress-bar')` kept. Keep the summary `Semantics(label: 'Today: <earned> of <total> points, <done> of <count> habits done')`. Empty list: header still shows the kicker and 'Today' but no numeral/track.
- DELETE `new_habit_button.dart` (replaced by `BottomAction` + `OutlinedButton.icon(Icons.add, 'New habit')` in the page).
- REWRITE `day_chip.dart` + keep `streak_row.dart` (restyle only): column = weekday initial (kicker-like, `accentInk` for today else `inkMuted`), 38x52 cell radius 20 (`AppRadii.strip`), done = `accent` border + `accentTint` fill + `Icons.check` size 16 `accentInk`; missed = `outline`-ish neutral border (use `track`-darker `outline` at 1dp), empty; today gets the prototype double ring (paper gap + `accent` ring) and key `Key('today-ring')`; notApplicable stays a small dot. Day number below (`caption`, muted). Semantics labels unchanged ('Today, done', 'Friday, missed', ...). Must use `Flexible`/`FittedBox` so 7 cells fit 320dp at 2x.
- REWRITE `points_picker.dart` (keep field + stepper + quick picks and all validation; same keys `points-field`, `points-chip-N`, tooltips 'Decrease points'/'Increase points'): `Icons.remove`/`Icons.add` icon buttons (48dp), outlined 4dp numeric field, quick picks as ONE prototype-style segmented row (4dp container with hairline border, each option 48dp high `Expanded`, selected = `accentTint` fill + 2dp `accent` bottom border + `accentInk` numeral, numerals Cormorant 20 / w600). At narrow width or large text the row may wrap via `Wrap` of equal cells; no overflow. Keep per-chip `Semantics(button, selected, label: 'N points')`.
- REWRITE `state_views.dart`: skeletons stay (keys `today-skeleton` / `detail-skeleton`, 'Loading' live region, reduced motion fade) but shapes follow the new layout and use `track` flat blocks with radius 2 (no pills, no circles except the check placeholder). `ErrorView`: kicker 'SOMETHING WENT WRONG' optional, serif title (`dialogTitle`/`headline`), muted Lora message, `Icons.cloud_off_outlined`/`Icons.error_outline` in `danger`, outlined retry button (keeps `title`, `message`, `actionLabel`, `icon`, `onRetry`). `EmptyView({required message})`: centred italic serif `emptyState`; Today passes `'No habits yet. Begin with one.'`.
- REWRITE `confirm_delete_dialog.dart`: `AlertDialog` per theme (4dp, hairline), title serif 'Delete habit?', content `"<name>" and its history will be removed. This cannot be undone.`, actions: `TextButton('Cancel')` muted + `OutlinedButton('Delete')` with `danger` text and `danger` border; both >= 48dp; `showDialog(animationStyle: reduceMotion ? AnimationStyle.noAnimation : null)`.
- EDIT `app_top_bar.dart`: `Icons.arrow_back`/`Icons.close`, 48dp, tooltips 'Back'/'Close' unchanged.
- KEEP `animated_count.dart`, `fade_slide_in.dart`, `resume_observer.dart` (only token renames if any).

### Pages (`lib/features/habits/presentation/pages/`)
- `today_page.dart`: `Scaffold > SafeArea(bottom: false) > Column[ ProgressHeader, Hairline, Expanded(body), BottomAction(OutlinedButton.icon 'New habit' -> context.push(AppRoutes.addHabit)) ]`. Loaded body = `ListView.separated` (padding horizontal 26, `Hairline` separators; `FadeSlideIn` stagger kept) or `EmptyView`. `LoadingView`/`ErrorView(onRetry: started)` as before. Remove `floatingActionButton`. Keep `ResumeObserver`, `listenWhen`/listener (see toast rules), `ValueKey('row-<id>')`.
- `habit_detail_page.dart` (prototype detail): `AppTopBar`, scroll body padding 26: kicker 'HABIT'; name (`headline`, `Semantics(header)`); description (`body`, `inkMuted`, left aligned; justify is hard to read at 320dp, so use start alignment; 'No description' fallback kept); a 4dp-outlined `accent` badge '<N> points' + italic 'per completion' in a `Wrap`; `Hairline`; row with kicker 'LAST 7 DAYS' (header semantics) and streak numeral (`AnimatedCount`, key `streak-count`) + 'day streak' (use 'day'/'days' by count) in a `Wrap`/FittedBox; `StreakRow`; `Hairline`; footer `'<doneCount> of <days.length> days'` and `'<doneCount*points> points this week'` in a `Wrap` (spaceBetween). `Semantics(label: 'Current streak: N day(s)')` kept. Bottom `BottomAction(OutlinedButton)` with label 'Mark today done' / 'Mark today not done' (done state uses `outline` border + `ink` text, per prototype) and `Icons.check` / `Icons.undo`; keeps `HapticFeedback` + `todayToggled` event. NotFound handling kept (snackbar + pop).
- `add_habit_page.dart` (prototype add): `AppTopBar(close: true)`; header kicker 'ADD' + 'New habit' (44, `Semantics(header)`), `Hairline`, scroll form padding 26 with muted kicker labels ('NAME', 'DESCRIPTION', 'POINTS PER COMPLETION') above 4dp-outlined `TextFormField`s (keys `name-field`, `description-field` kept; validators and `HabitRules` max lengths unchanged; counter only near limit), `PointsPicker`, helper text 'Earned each time you mark it done.'. Bottom `BottomAction(OutlinedButton 'Save habit')`; submitting shows the 18dp 2dp-stroke `accent` spinner with 'Saving' live-region semantics. Success: `context.pop()` then `showToast(context, 'Habit added')`. Failure: `showErrorSnackBar`.
- `lib/core/router/app_router.dart`: no structural change.

### Utils
- `utils/date_formatters.dart`: ADD `formatKicker(DateKey)` = `'SATURDAY · 17 OCTOBER'` (weekday name + ` \u00B7 ` + day + full month name, upper case; add a `_monthNames` list). Keep `weekdayName`, `weekdayInitial`, `weekdayShort`, `formatLongDate` only if still referenced (grep), else remove with their tests. Remove `formatMonthDay` if unreferenced. Add `test/features/habits/presentation/utils/date_formatters_test.dart` (kicker for Sat 17 Oct 2026, a single-digit day, 1 Jan, and Dec).

---
## 6. Toast behaviour (presentation only)

- `showToast(context, message)`: `ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Center(heightFactor: 1, child: Text(message, textAlign: center, maxLines: 2)), duration: 1400 ms, width: 190, behavior: floating))`. The theme supplies dark `inkStrong` bg, `paper` Lora 14 text and the pill shape. For reduced motion pass `snackBarAnimationStyle: AnimationStyle.noAnimation` when `reduceMotion(context)` (verify the parameter exists on `ScaffoldMessengerState.showSnackBar` in Flutter 3.41; if not, use `SnackBar.animation`/duration only and note it).
- `showErrorSnackBar(context, message)`: hide current, show a normal floating snackbar (no fixed width, radius 4, message text). Used for all bloc `actionFailure`, NotFound, add failure, so those four inline `ScaffoldMessenger` blocks become one helper.
- Today toggle: in the page, the row's `onToggle` computes the toast from the item's PRE-toggle state: `item.isDone ? '-${points} points' : '+${points} points'` (ASCII hyphen-minus), calls `showToast`, then dispatches `TodayEvent.habitToggled(id)`. Same on Detail: pre-toggle `streak.isDoneToday` and `habit.points`.
- Failure: the existing listener on `TodayLoaded.actionFailure != null` (and Detail's equivalent) first calls `hideCurrentSnackBar()` explicitly, then shows `showErrorSnackBar(failure.message)`, so the toast is replaced by the error and never both.
- Swipe-delete shows no toast. Add success shows 'Habit added'.
- Tests: `today_page_test` (toast text '+20 points' on open habit, '-10 points' on done habit, toast replaced by the error snackbar when the toggle use case fails, toast gone after 1.4 s + settle), `habit_detail_page_test` (same), `add_habit_page_test` ('Habit added' not required to be asserted if the route pop makes it hard; assert no overflow and pop).

---
## 7. Per-screen restyle summary (what the user should see)

- **Bootstrap loader**: `paper` ground, centred small `accent` 2dp spinner, below it serif italic 'Opening your habits.' (kicker 'HABIT TRACKER' above). `Semantics(label: 'Loading', liveRegion)`. (Replaces the skeleton for the bootstrap shell only; `LoadingView` stays for Today/Detail.)
- **Bootstrap error**: kicker 'OFFLINE'-style, serif title "Can't connect", the real `BootstrapException.message` (muted Lora), `Icons.cloud_off_outlined` in `danger`, outlined 'Retry'. Left aligned, hairline above button area not needed.
- **Today**: kicker date, 'Today' 46, 64 numeral + '/ N points', 'X of Y done', 3dp gold progress, hairline, rows separated by hairlines, bottom docked outlined 'New habit'. Empty: italic 'No habits yet. Begin with one.'. Loading: skeleton. Error: ErrorView.
- **Detail**: layout in section 5. Loading skeleton; error view; not-found pops with an error snackbar.
- **Add**: layout in section 5, validation messages unchanged ('Please enter a name', points messages), validation colour `danger`.
- **Delete confirmation**: serif title, hairline-bordered 4dp dialog, Cancel + outlined danger Delete.
- No cards, no gradients, no purple, no filled buttons, no shadows, no pills except the toast.

---
## 8. Reduced motion and accessibility

Reduced motion (`MediaQuery.disableAnimationsOf || accessibleNavigation`, helper `reduceMotion`):
- `CheckToggle` 200 ms, progress fill 400 ms, `AnimatedCount`, `FadeSlideIn`, skeleton fade, picker cell transitions: all go through `AppMotion.of(context, d)` so they become `Duration.zero`.
- go_router transitions stay subtle (4 to 8 percent slide + fade) and `buildAppPage` returns the bare page when reduced.
- Dialog: `animationStyle: AnimationStyle.noAnimation`; toast: `snackBarAnimationStyle` noAnimation.
- Tests: extend `reduced_motion_test.dart` to cover CheckToggle, progress bar (no tween frames), toast, and transitions.

Accessibility:
- All interactive targets >= 48dp: CheckToggle 48x48, icon buttons 48x48, picker cells 48 high, outlined buttons min 52, `TextButton` min 48, row `InkWell` min 72. Assert in tests with `tester.getSize`.
- Text >= 4.5:1: ink, inkMuted, accentInk (on paper and `accentTint`), danger, `paper` on `inkStrong`. Non-text >= 3:1: `outline` (unchecked circle, input borders), `accent` strokes. `accent` never used for text. Streak segments' state is duplicated in text ('N-day streak').
- Semantics kept: row custom action 'Delete habit', check semantics (button + checked), week cell labels, summary label, 'Current streak', header semantics, 'Loading' live region, 'Saving'.
- No overflow at 2.0x on a 320dp-wide screen (`useSmallPhone` + `textScale: 2`): `accessibility_themed_test` loops stay for light only; add cases for the new header, row with long name, detail with long name/description, add page with errors.

---
## 9. Tests

Order of work: update tests in the same FEAT as the code they cover; every FEAT ends green.

Rewrite / update:
- `test/design_rules_test.dart` REWRITE: scanner over `lib/` (presentation, router, app.dart, and `lib/core/theme` except `app_tokens.dart`) for: no `Color(0x` hex and no `Colors.*` except `Colors.transparent`; no em/en dashes; no `Brightness.dark`/`darkTheme`/`ThemeMode.dark`; no `FilledButton`/`ElevatedButton` (outlined only); no `phosphor`, `google_fonts`, `flutter_riverpod`, `package:intl` imports; Material `Icons.` is now ALLOWED. Add: pubspec declares families `CormorantGaramond` and `Lora`, every listed font asset and licence file exists and the TTFs start with `00 01 00 00`; no `Geist` anywhere in `lib/`, `pubspec.yaml`, `assets/`; `AppTextTokens` family constants match the pubspec families. Keep the self-tests of the checker (updated for the new rules).
- `test/core/theme/app_tokens_test.dart` REWRITE: new palette exact values, WCAG ratios (section 1), `copyWith`/`lerp`, text tokens use the two families and tabular figures, `context.tokens` fallback.
- `test/core/theme/app_theme_test.dart` REWRITE: only `AppTheme.light()`; Material 3; paper scaffold; Lora body; outlined buttons 4dp, min height >= 48, never a `filledButtonTheme` style; icon button 48; inputs 4dp outline borders; snackbar dark + floating; overlay style light only.
- `test/helpers/pump_app.dart`: drop `brightness`, `darkTheme`; `themedApp` stays with `textScale`, `disableAnimations`, `accessibleNavigation`; set `themeMode: ThemeMode.light`. Update all callers.
- `app_test.dart`: expect kicker/'Today' and 'New habit'; error path still shows the real `BootstrapException` message and 'Retry'.
- Page/widget tests listed in section 4 and 5 (`today_page_test`, `habit_detail_page_test`, `add_habit_page_test`, `points_picker_test`, `progress_header_test`, `state_views_test`, `streak_row_test`, `animated_count_test`, `fade_slide_in_test`, `reduced_motion_test`, `accessibility_test`, `accessibility_themed_test`, `check_toggle_test` (renamed from `animated_check_test`)) are UPDATED to the new strings/icons/structures. Never delete or weaken an assertion without a recorded reason.

Allowed removals only (each MUST be listed with a reason in `.agents/tasks/test-changes.md`, created in FEAT-003): the `dark` group/loop in `app_theme_test`, `app_tokens_test`, `accessibility_themed_test`; Geist/vermilion/warm-palette/pill/`ink`-filled-button assertions; `PhosphorIcons` finders (replaced by `Icons.*` equivalents, not dropped); the `Icons.` ban test in `design_rules_test`; the `x` icon count for missed week cells (replaced with semantics-label assertions); the `NewHabitButton`-specific cases (replaced by 'New habit' outlined button tests). For each: say what was removed/replaced and why. Final test count must be >= 356 minus the dark-only cases, plus the new ones. Report the exact numbers.

Gate commands (project root): `dart format .`, `flutter analyze`, `flutter test test/architecture_test.dart`, `flutter test`.

---
## 10. On-device verification + screenshots (FEAT-004)

Screenshots go in `/Users/macbook/Desktop/Assignment/screenshots/` (create it; it does not exist yet). Notes go in `.agents/tasks/verification.md`.

Device: `10BF3A1CM30013Z`. First run `adb devices -l` and `flutter devices`. If that serial is missing, do NOT stall: wait one retry (`adb reconnect`, `adb wait-for-device` with a 30 s timeout), then use the one connected Android device (at planning time `emulator-5554`), and say so at the top of `verification.md` in plain words ("required device 10BF3A1CM30013Z was not connected; verified on <id>"). Never claim the physical device was used if it was not.

Procedure: `flutter pub get && flutter build apk --debug` (or `flutter run -d <id>`), `adb -s <id> install -r build/app/outputs/flutter-apk/app-debug.apk`, `adb -s <id> shell am start -n <package>/.MainActivity` (read the package from `android/app/build.gradle*`). Capture with `adb -s <id> exec-out screencap -p > screenshots/<NN>-<name>.png`. Look at every PNG with the image reader and note defects. The app uses anonymous sign-in at bootstrap; if the project has it disabled the bootstrap error screen shows the real message. Capture that as screenshot 01b and, if it persists, report it to the user as an environment issue (do not change auth code).

Checklist (screenshot name -> what to confirm):
1. `01-bootstrap-loader` (grab right after launch; if too fast, record "too fast to capture" with the widget-test evidence) and `01b-bootstrap-error` if reachable (real message, Retry).
2. `02-today-empty` - italic 'No habits yet. Begin with one.', kicker, 'Today', bottom outlined 'New habit', no FAB.
3. `03-add-blank` - kicker 'ADD', 'New habit', labelled fields, picker, bottom 'Save habit'.
4. `04-add-errors` - submit blank: 'Please enter a name' in `danger`; also a points value 0 or 1001 error.
5. `05-add-keyboard` - keyboard open, bottom action still reachable.
6. `06-today-with-habits` - at least 4 habits (one long name), some done, streak bars + 'N-day streak'/'No streak', points + 'PTS', progress bar gold.
7. `07-toast-plus` and `08-toast-minus` - tap check right before `screencap` (toast lives 1.4 s): '+N points' then '-N points', small dark pill about 190 wide.
8. `09-detail-open` and `10-detail-done` - 7-day strip, today ring, streak numeral, footer stats, button label 'Mark today done' then 'Mark today not done'.
9. `11-delete-confirm` - swipe a row left: restyled dialog; Cancel keeps it; Delete removes it live.
10. `12-error-snackbar` - if reproducible (airplane mode then toggle), the error snackbar replaces the toast; otherwise cover by test and say so.
11. `13-today-2x-320dp`, `14-detail-2x-320dp`, `15-add-2x-320dp`: `adb shell settings put system font_scale 2.0` and `adb shell wm size 720x1440; adb shell wm density 360` (= 320dp wide). No overflow stripes, nothing clipped. ALWAYS restore: `adb shell settings put system font_scale 1.0; adb shell wm size reset; adb shell wm density reset`.
12. `16-reduced-motion` - `adb shell settings put global animator_duration_scale 0` (and `transition_animation_scale 0`): transitions/toast/check instant, no crash; restore to `1.0`.
13. Resume-after-midnight cannot be done on a device; cite the existing bloc test and the domain test as evidence.
14. TalkBack optional: if time allows, confirm check buttons read 'Mark as done'/'Mark as not done', rows expose 'Delete habit'.

`verification.md` must list: commands run and exit codes, screenshot list with one-line findings, device used, any defects found and fixed, anything not verifiable.

---
## 11. Final gates (before `review.json`)

- `dart format --set-exit-if-changed .` clean; `flutter analyze` no issues; `flutter test` all green (report count); `flutter test test/architecture_test.dart` green.
- `grep -rn "phosphor\|Geist\|darkTheme\|AppTokens.dark\|AppTheme.dark\|FilledButton" lib test pubspec.yaml` returns nothing (documentation excluded).
- `git status` shows no changes under `lib/features/habits/data`, `lib/core/{error,time,usecase,auth}`, repository interfaces, `design_reference/`; the only `lib/core/di` change is the one registration line.
- No dead code: every widget file listed in section 5 is referenced; removed widgets are gone; no unused tokens (each `AppTokens` member is read somewhere in `lib/`).
- No commit created.
