# In-app splash report

## Files added
- `lib/core/brand.dart`: `appName`, single source for the product name (now `Habitry`, set by the parent session; not reverted).
- `lib/features/habits/presentation/widgets/brand_mark.dart`: `BrandMark` widget and `BrandMarkPainter` (CustomPainter, no image asset). 560 x 620 design box scaled to 112 px wide. Ring sweep and tint fade 0 to 0.45, check drawn with `PathMetric.extractPath` 0.35 to 0.75, seven segments staggered 0.7 to 1.0 (last three turn from grey to gold). At progress 1 the ring, check and segments are drawn as whole shapes, so it is the static mark. Painted shapes are excluded from semantics.
- `lib/features/habits/presentation/widgets/splash_view.dart`: `SplashView`. Paper background, mark vertically centred (fixed position, never shifts), wordmark (`appName`, Cormorant Garamond 30 sp from `displayTitle`) and `DAILY HABITS` kicker positioned absolutely below the mark and faded in. One 900 ms run, `easeOutCubic`, no loop. Reduced motion jumps to the final state. One semantics label: `appName`.
- `test/features/habits/presentation/widgets/brand_mark_test.dart`.

## Files changed
- `lib/app.dart`: `BootstrapGate` rewritten without `FutureBuilder`. Phases loading, ready, failed. The spinner shell and `_BootstrapLoader` are gone. Both `MaterialApp` titles use `appName`.
- `lib/core/theme/app_motion.dart`: added `AppMotion.splash` (900 ms).
- `test/app_test.dart`: see tests below.
- `README.md`: new "App icon and splash" section (the title change to Habitry was done by the parent).

## Decisions
- Grey `#C9C4C4` is not a token. The empty streak segments use `tokens.track` (`#D7D3D3`), which is slightly lighter. The Flutter mark therefore differs a little from the native one on those four segments. If an exact match matters, add a dedicated token in `app_tokens.dart`.
- Minimum duration: on first launch a 900 ms `Timer` starts in `didChangeDependencies`. The app shows only when bootstrap succeeded AND the timer elapsed. A failure shows the error screen immediately. Retry cancels the timer and marks the minimum as elapsed, so retries add no delay. A stale attempt counter ignores results from superseded bootstrap calls.
- Reduced motion: `BootstrapGate` sits above `MaterialApp`, so there is usually no `MediaQuery`. It uses `MediaQuery.maybeOf`, falling back to `View.of(context).platformDispatcher.accessibilityFeatures`. With reduced motion there is no timer and the crossfade duration is zero. `SplashView` itself uses `reduceMotion(context)` from `app_motion.dart`.
- Crossfade: `AnimatedSwitcher` with `AppMotion.base` (240 ms) and a `StackFit.expand` layout. Keys: splash, error, app.
- `SplashView` is placed in a `Scaffold` without `SafeArea`, so its centre matches the full-screen native splash. The error view keeps its `SafeArea`.
- The old test `shows the loader until bootstrap completes` asserted the spinner and "Opening your habits." text. Those no longer exist, so it became `shows the splash until bootstrap completes`. The retry, BootstrapException and navigation tests are unchanged.

## Tests added
`test/app_test.dart`:
- splash shown while bootstrap is pending (wordmark, kicker, semantics label, no spinner), then the app after completion
- splash held until the minimum even when bootstrap is instant (fake time)
- slow bootstrap: still splash after the minimum, app on completion
- error shown without waiting for the minimum
- retry shows the splash again and the app follows without extra delay
- reduced motion (`MediaQuery disableAnimations`): final mark (`progress == 1`), wordmark fully opaque, app appears without waiting
- intro animates the mark from near 0 to 1 when motion is allowed

`test/features/habits/presentation/widgets/brand_mark_test.dart` (font independent, pixel sampling of a `PictureRecorder` render at 1:1):
- widget builds at progress 0, 0.5, 1 with size 112 x 124.4
- hidden from semantics without a label; labelled when given one
- progress 0 paints nothing
- progress 1: ring colour, tint fill, check vertex colour, seven segments (4 track, 3 accent), square segment ends, transparent outside
- progress above 1 equals progress 1
- progress 0.5: full ring, partial check, no segments
- progress 0.85: first segment in, last not yet
- `shouldRepaint`

## Manual review done (no tooling)
Re-read all changed files for compile errors, unused imports, `prefer_single_quotes`, `prefer_const_constructors`, `unawaited_futures` (only fires in async bodies; none apply), `always_declare_return_types`. Searched the new lib files for `Colors.`, `Color(0x` and en or em dashes (none), so `design_rules_test.dart` and the architecture test (presentation imports no data or Firebase) should pass. Fixed two over-80-column lines by hand.

## NOT RUN
`dart format lib test`, `flutter analyze` and `flutter test` were NOT RUN. The Flutter SDK scripts fail in this sandbox with "Operation not permitted" writing `bin/cache/engine.stamp`. Per instruction I did not work around it. So there is no test count, and these are unconfirmed:
- formatting (run `dart format lib test`; a few lines may still reflow)
- analyzer cleanliness
- all tests, in particular: the reduced-motion test relies on `MaterialApp` honouring a `MediaQuery` placed above it; the pump sequences around the 240 ms crossfade were reasoned through, not executed; the pixel tests rely on `toImage` under `runAsync`
- real device look, and the native-to-Flutter handover alignment (mark position and size, wordmark placement). That needs screenshots from the phone. Check also that the wordmark and kicker appear below the mark on the real screen.
