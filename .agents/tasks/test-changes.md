# Test changes (classical redesign)

Every removed or replaced case is listed with a reason. Baseline was 364 passing tests (356 original + 8 added in FEAT-001). After FEAT-002: 326 passing. After FEAT-003: 391 passing.

## FEAT-002

Removed (dark theme no longer exists, the app is light only):
- `test/features/habits/presentation/accessibility_themed_test.dart`: the whole `dark` pass of the brightness x scale loop (31 cases: every screen at 1.0x, 1.5x and 2.0x). The same 31 cases still run for light. Test names lost the brightness prefix (`1.0x` instead of `light 1.0x`).
- `test/features/habits/presentation/widgets/streak_row_test.dart`: the 3 dark overflow cases (1.0x, 1.5x, 2.0x). Light cases kept.
- `test/features/habits/presentation/widgets/points_picker_test.dart`: the dark overflow case. Light case kept.
- `test/core/theme/app_theme_test.dart`: the `dark` group (replaced by a single light group). Old light assertions that no longer apply were replaced, not dropped: ink filled pill primary button (now: no filled button style, outlined 4dp gold button, min height 52), underline inputs (now 4dp outline inputs), Geist body font (now Lora body, Cormorant headings), flipping overlay style (now light only overlay).
- `test/core/theme/app_tokens_test.dart`: the `dark` contrast group, the dark `lerp` operand, the dark `context.tokens` fallback test (`ThemeData.dark()`), the `AppTheme.dark()` extension test, and the "warm, not blue grey" palette test (the new neutral palette is intentionally cool grey, so the rule no longer holds). Contrast assertions were rewritten for the new tokens (ink, inkMuted, accentInk, danger on paper; accentInk on accentTint; paper on inkStrong; outline and accent >= 3:1). Geist text token test replaced by one for the Cormorant Garamond / Lora tokens. Exact palette, spacing and radii tests added.
- `test/design_rules_test.dart`: the "Material Icons are banned" rule and its self-test (Material `Icons.*` is now the icon set). Replaced by a rule banning icon packs, `FilledButton`/`ElevatedButton` and dark themes, plus a self-test and an "allows Material icons" self-test. Full rewrite is FEAT-003.

Replaced (not dropped):
- `PhosphorIconsRegular` finders in `habit_detail_page_test` (`check`, `arrowCounterClockwise` -> `Icons.check`, `Icons.undo`), `state_views_test` (`cloudSlash` -> `Icons.cloud_off_outlined`), `streak_row_test` (`check`, `x` -> `Icons.check`, `Icons.close`).
- `points_picker_test`: selected chip fill `ink` -> `accentTint`.
- `animated_check_test`: checked fill `accent` -> `accentTint` (test renamed "fills with the accent tint when checked").
- `add_habit_page_test`: `FilledButton` finder -> `OutlinedButton`.
- `test/helpers/pump_app.dart`: `brightness` parameter and `darkTheme` removed, `themeMode: ThemeMode.light`.

## FEAT-003

Test counts: baseline 356 original, 364 after FEAT-001, 326 after FEAT-002, **391 after FEAT-003** (`flutter test`, all green). Net effect of FEAT-003 alone: +65 cases (new widgets, toast, design rules, accessibility). No case was deleted without a replacement listed here.

Removed or replaced assertions (each with the reason):
- `widgets/animated_check_test.dart` renamed to `widgets/check_toggle_test.dart`: `AnimatedCheck(checked:)` became `CheckToggle(done:)` (the widget was replaced). All 7 original cases kept (hidden/shown check, accent tint fill, 48dp target, tap, semantics, reduced motion, animates with motion). Two cases added (34dp circle with `outline` border when open, gold border and `accentInk` check when done).
- `pages/today_page_test.dart`:
  - "lists every habit with its points": the `find.text('Before bed')` expectation was replaced by `findsNothing` because the description line is dropped from the row (it stays on Detail). `'+10'`, `'+20'`, `'+15'` finders were replaced by the plain numerals plus three `PTS` labels (the row now shows the points over "PTS" instead of "+N").
  - "shows the progress header...": `'of 45 pts'` is now `'/ 45 points'`, `'Saturday'` and `'Oct 17'` are now the kicker `'SATURDAY \u00B7 17 OCTOBER'` and `'Today'`; the earned numeral is searched inside the `ProgressHeader` because row points can also read `10`.
  - "shows an empty state without habits": title `'No habits yet'` plus hint replaced by the single italic copy `'No habits yet. Begin with one.'`; the weekday text became the kicker; added "no FAB" and "no progress bar" checks.
  - The FAB is gone (bottom-docked outlined `New habit`); the "add button opens the add screen" case is unchanged and still passes.
- `widgets/progress_header_test.dart`: `'Saturday'`, `'Oct 17'`, `'of 45 pts'` replaced by the kicker, `'Today'` and `'/ 45 points'`; the empty variant check `textContaining('pts')` is now `textContaining('points')`. The progress bar still ends on `overview.progress` and still animates up from empty.
- `pages/habit_detail_page_test.dart`: `'15 pts'` became `'15 points'` (badge copy), `'Last 7 days'` became `'LAST 7 DAYS'` (kicker), `'4 of 7 days done'` became `'4 of 7 days'` (plus a new `'60 points this week'` check), the separate `'day'` / `'days'` unit finders became `'day streak'`. The decision: the unit now always reads "day streak" (as in the prototype); the singular/plural form stays in the `Current streak: N day(s)` semantics label, which is unchanged and still tested.
- `pages/add_habit_page_test.dart` and `accessibility_themed_test.dart`: `widgetWithText(TextFormField, 'Name' | 'Description' | 'Points')` finders became the stable keys `name-field`, `description-field`, `points-field` because the labels are now separate kicker texts above the fields (no `labelText` on name and description). The quick pick tap now calls `ensureVisible` first because the docked "Save habit" bar covers part of the scrolling form on the 800x600 test surface.
- `widgets/points_picker_test.dart`: the chip fill helper reads `BoxDecoration` instead of `ShapeDecoration` (quick picks are now a segmented row of square cells, not stadium pills). All 11 original cases kept.
- `widgets/state_views_test.dart`: the `EmptyView` case used `title:` and `message:`; the widget now takes only `message` (italic serif), so the case was rewritten for the new API (still asserts no icon and no spinner). All `ErrorView` and `LoadingView` cases kept.
- `widgets/streak_row_test.dart`: "done days show a check, missed past days show a mark" asserted five `Icons.close` marks for missed days. Missed cells are now empty outlined cells (plan: "semantics labels instead of X icons"), so the case now asserts no X icons, five `', missed'` semantics labels and the gold done cell. "days before the habit existed render no pill" was renamed to "...no cell"; assertions unchanged.
- `test/app_test.dart`: `find.text('Saturday')` became the kicker and `'Today'`; "shows the skeleton loader until bootstrap completes" (asserted `today-skeleton` and no spinner) became "shows the loader until bootstrap completes" (asserts the `HABIT TRACKER` kicker, 'Opening your habits.', one gold spinner, the 'Loading' semantics label, then Today). The add form navigation case looks for `'NAME'` instead of `'Name'`. Error case also asserts the `Can't connect` title.
- `test/design_rules_test.dart`: rewritten per plan section 9. The FEAT-002 version (icon packs, filled buttons, dark themes, hex, named colours, dashes) is superseded by: filled/elevated buttons, dark themes (precise patterns, `statusBarIconBrightness: Brightness.dark` is allowed because it means dark icons), phosphor/google_fonts/riverpod/intl imports, hex only in `app_tokens.dart`, `Colors.*` except transparent, em/en dashes, Geist; plus pubspec checks (families, six TrueType files with magic bytes, two OFL files containing the licence text, no Geist file in `assets/`, token family constants match the pubspec) and self-tests for each rule and for the pubspec parser. The scan now also covers `lib/core/theme`.

Added (new coverage):
- `presentation/utils/date_formatters_test.dart` (kicker for Saturday 17 October, single digit day, 1 January, December, all month names, weekday helpers).
- `widgets/streak_bar_test.dart`, `widgets/toast_test.dart`, `widgets/docked_widgets_test.dart` (Hairline, BottomAction).
- `today_page_test`: streak segments and texts, hairlines, no FAB, toast `+N points` / `-N points` from the pre-toggle state, toast replaced by the error snackbar, pill is 190dp wide and sits above the docked button.
- `habit_detail_page_test`: the same three toast cases, outlined action without FAB.
- `add_habit_page_test`: labels and helper text, outlined 48dp save button, 'Saving' announcement, 'Habit added' toast after closing.
- `reduced_motion_test`: check toggle, progress bar, delete dialog (with and without motion). The toast reduced-motion case lives in `toast_test`.
- `accessibility_themed_test`: 48dp targets (Today rows, checks, New habit; Add close, stepper, quick picks, save; Detail back and action; delete dialog buttons), delete dialog and Today header with big numbers at 1.0x, 1.5x, 2.0x on 320dp.
- `progress_header_test`, `points_picker_test`, `streak_row_test`: styling (64 serif numeral, gold bar, gold selected bottom border, 38x52 cell with 20dp radius and double ring) and no overflow at 1.0x, 1.5x and 2.0x.

Helper formatters removed from `date_formatters.dart` because nothing used them any more: `formatLongDate`, `weekdayShort`, `formatMonthDay` (no tests referenced them). Spacing tokens `s2` and `s64` were removed from `AppSpacing` (unused, no tests referenced them).
