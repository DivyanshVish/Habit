# FEAT-004 on-device verification

## Device actually used
The required device 10BF3A1CM30013Z (vivo I2221, Android 16, API 36) was used, over USB. No fallback was needed.

Why it was missed at first: `adb` in the sandbox could not see the USB device, although it was attached (`ioreg` showed serial 10BF3A1CM30013Z). Setting `ADB_LIBUSB=1` fixed it.

The phone had a pre-existing `wm size` override of 1080x2400 (physical 1260x2800). Restore therefore used `wm size 1080x2400`, not `wm size reset`.

## Build and install (sandbox workarounds, no project files changed)
- The Flutter SDK dir and `~/.gradle` are read-only in the sandbox. I used a symlink copy of the SDK at `/tmp/fsdk` (with a writable copy of `packages/flutter_tools/gradle`).
- Gradle 8.14 ran from a copy in `/tmp/gh`, with `GRADLE_RO_DEP_CACHE` pointing at `~/.gradle/caches`.
- Flutter's JDK was set to openjdk@17, because the bundled JDK 25 is unsupported.
- `ANDROID_USER_HOME=/Users/macbook/.android` kept the real debug keystore. This matters: the first APK was signed with a fresh keystore and was rejected with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`. I did not uninstall, so app data was kept.
- `flutter build apk --debug --no-pub`: exit 0 (three builds, the last after the fixes below). `adb install -r`: Success.
- `android/local.properties` was rewritten by the build and restored to its original content.

## Gates (final)
- `dart format --set-exit-if-changed .`: clean (140 files, 0 changed).
- `flutter analyze --no-pub`: No issues found.
- `flutter test --no-pub`: 394 passed. This is 391 before plus 1 new theme test plus 2 re-greened ones.
- `flutter test test/architecture_test.dart`: 6 passed.
- Leftover grep (`phosphor|Geist|darkTheme|AppTokens.dark|AppTheme.dark|FilledButton`) in `lib/` and `pubspec.yaml`: nothing.
- No commit. No temp files left in the project. `design_reference/` untouched.

## Screenshots (all 1080x2400 unless noted, each viewed)
- 01-loading-skeleton: Today skeleton while loading. The bootstrap loader itself was too quick to catch. It is covered by widget tests (app_test.dart).
- 02-today-current: kicker 'SUNDAY · 18 OCTOBER', 'Today', 64-style numeral '/ 110 points', '1 of 2 done', gold progress, hairline rows, streak bars with '2-day streak' and '1-day streak', 'PTS', docked outlined 'New habit', no FAB. The account already has real habits, so the empty state could not be shown on the device. Empty state is covered by tests.
- 03-add-blank: ADD / 'New habit', NAME, DESCRIPTION and POINTS PER COMPLETION labels, picker with quick-pick segments, helper text, 'Save habit'.
- 04-add-errors: 'Please enter a name' in danger red on a red-bordered field. A points error (0 or 1001) was not shown on the device. It is covered by tests.
- 05-add-keyboard: keyboard open, 'Save habit' still reachable above it.
- 06-today-with-habits: 6 habits including a 3-line long name that wraps with no overflow, a mix of done and not done, 'No streak', and points.
- 07-toast-plus: '+10 points', small dark rounded toast about 190 wide.
- 08-toast-minus: '-10 points', progress back to 1 of 6.
- 09-detail-open: 7-day strip, today ring, streak numeral, footer stats, 'Mark today done'.
- 10-detail-done: check in today cell, '1 day streak', '10 points this week', 'Mark today not done'.
- 11-delete-confirm: restyled dialog, serif title, outlined danger 'Delete'. Cancel kept the row. Delete removed it live (5 habits left, points denominator 165 to 160).
- 13-today-2x-320dp (720x1440) and 13b (scrolled): 2.0x font at 320dp. No overflow stripes. The header takes most of the first screen and scrolls. Long underscore names break mid-word.
- 14-detail-2x-320dp and 14b (scrolled): no overflow. The streak header stacks. The 'Mark today not done' button wraps to two lines.
- 15-add-2x-320dp and 15b-add-errors-2x-320dp: no overflow. Fields scroll under the docked button.

No filled buttons, no purple or blue tints, and no pills except the toast were seen in any screenshot. The gold and paper contrast read fine. The page ground reads as a light neutral grey from the paper token.

## Defects found and fixed (presentation/theme only)
1. **Validation text ellipsized at 2.0x on 320dp**: 'Please enter a na…' (15b, first capture). Fix: `errorMaxLines: 3` and `helperMaxLines: 3` in `InputDecorationTheme` in `lib/core/theme/app_theme.dart`, plus a test in `app_theme_test.dart`. After the rebuild the message wraps ('Please enter a / name'). The second line sits below the docked button until the form is scrolled, which is normal scrolling behaviour.
2. **Detail overflow in tests**: 8 failing tests (RenderFlex overflow, 7.8px at 1.5x and 97px at 2.0x), found when I re-ran the suite. The failure came from the streak row in the stacked branch of `BaselineSplit`. `BaselineSplit`, `measureTextWidth` and the related edits in `habit_detail_page`, `day_chip`, `progress_header` and `app_tokens` were already in the tree from 00:32 to 00:33. They were not made by this step and appear to be from someone else. Fix: the 'day streak' unit in `habit_detail_page.dart` is now `Flexible`, so it wraps instead of overflowing. All tests green afterwards.

## Observations, not changed (product decisions)
- The 'Please enter a name' error stays visible after valid text is typed, until the form is next submitted. This is the Flutter default (no autovalidate). Switching to `AutovalidateMode.onUserInteraction` would change behaviour.
- At 2.0x on 320dp the Today header takes most of the first screen before the rows.

## NOT verified
- Error snackbar replacing the toast (item 10): not reproduced (no airplane-mode run). Covered by tests.
- Bootstrap error screen (01b), TalkBack (item 14), midnight resume (item 13, covered by bloc and domain tests).
- Other screen sizes beyond 1080x2400 at 1.0x and 720x1440 at 2.0x.

## Device settings
After every 2.0x run I set `font_scale` 1.0, `wm size 1080x2400` (the pre-existing override) and `wm density reset`. The last reading was font_scale 1.0, Override size 1080x2400, Physical density 420, and animator, transition and window scales all 1.0.

## Test data left on the phone's account
The QA habits I created are still in the app's real Firestore data: `QA_Read` (done today), `QA_Meditate`, and `QA_A_very_long_habit_name_...`. `QA_Walk` was deleted. The pre-existing habits 'Divyansh' (done) and 'Drink' were never changed. The QA habits should be removed (swipe left, Delete). The device disconnected before I could do that.

## Follow-up run on the EMULATOR (emulator-5554, Android 17, 1080x2400, 420dpi)
This part was NOT on the required physical device. After the phone disconnected, the user started an emulator. I used it for the items the phone run missed. It has its own fresh anonymous Firestore account, so none of the phone's data is visible there.
- 02b-today-empty-EMULATOR: empty state. Italic 'No habits yet. Begin with one.', kicker date, 'Today', docked outlined 'New habit', no FAB. Confirmed.
- 01b-native-splash-EMULATOR: this is only the Android native splash (Flutter logo), not the in-app bootstrap loader. The bootstrap loader remains uncaptured. It is covered by widget tests.
- Reduced motion (animator, transition and window scales set to 0): 16a shows the Add page in the 'Saving' state with a gold spinner in the button. 16b shows the '+10 points' toast appearing at once. 16c shows Detail opening straight into the done state ('1 day streak', 'Mark today not done'). No crash, no half-animated frames. The Firestore write on the emulator was slow, so the row's check lagged the toast by a moment. That is latency, not an animation issue.
- Settings restored: animator, transition and window scales 1.0, font_scale 1.0, no wm override.
- Cleanup: the RM_Test habit created on the emulator was deleted through the UI (swipe, Delete). The emulator is back to an empty Today.
- Bootstrap error screen (01c-bootstrap-error-EMULATOR): app data cleared, airplane mode on, cold start. Shows the cloud-off icon in danger red, kicker 'OFFLINE', serif 'Can't connect', the real message 'No connection. Check your internet and try again.' and an outlined 'Retry'. No overflow. After airplane mode was turned off, 'Retry' loaded Today. Confirmed.
- Error snackbar (item 10): not reproducible. With airplane mode on, a toggle succeeds locally from the Firestore cache. The '+10 points' toast showed and the check animated in (12a, 12b), and no error snackbar appeared. The error path remains covered by tests only. Skipped on the user's instruction.
- Both airplane mode toggles were reverted. Err_Test (the habit created for this) was deleted. The emulator ends on an empty Today with all animation scales 1.0, font_scale 1.0, airplane mode off.
- Still not verified: TalkBack, midnight resume (test-covered), the in-app bootstrap loader (too quick to capture).

## Final run on the PHYSICAL phone (10BF3A1CM30013Z), after it was reconnected
- The app had been uninstalled from the phone, so its old anonymous Firestore user is gone from the device. The QA habits created earlier (QA_Read, QA_Meditate, the long-named one) and the user's older habits (Divyansh, Drink) are still stored in Firestore under that old user. They can no longer be reached from the app. Removing them needs the Firebase console, if wanted.
- I reinstalled the latest debug build (all fixes included) on the phone, with `adb install -r`. The phone now has a new anonymous account.
- 01-bootstrap-loader-phone: the in-app bootstrap loader, captured on the phone. Kicker 'HABIT TRACKER', a small gold spinner and the italic 'Opening your habits.' on the paper ground. Confirmed.
- 02-today-empty-phone: empty Today on the phone. Italic 'No habits yet. Begin with one.', kicker date, 'Today', docked outlined 'New habit', no FAB. Confirmed.
- No test data was created on the new account. No device settings were touched.
- Still not verified anywhere: TalkBack and midnight resume (test-covered). The error snackbar was skipped on the user's instruction (test-covered).

## Closing note: gates after concurrent edits (not part of FEAT-004)
My last fully green gate run was: format clean (140 files), analyze clean, 394 tests passed, architecture test 6 passed.

At the very end of FEAT-004 (about 02:49 to 02:52), someone else added a splash and brand mark feature: `lib/core/brand.dart`, `widgets/brand_mark.dart`, `widgets/splash_view.dart`, edits to `lib/app.dart` and `test/app_test.dart`, and a new `brand_mark_test.dart`. It is still in progress, and I did not touch it. With it in the tree, the gates are:
- `dart format`: clean (144 files).
- `flutter analyze`: 3 issues. `use_null_aware_elements` at app.dart:128, `prefer_const_declarations` at splash_view.dart:62, and an undefined `ByteData` in brand_mark_test.dart:23.
- `flutter test`: 389 passed, 12 failed. 11 are in `app_test.dart` (the splash, bootstrap and Today-navigation tests) and `brand_mark_test.dart` fails to load.
- `flutter test test/architecture_test.dart`: 6 passed.

These failures come from the new splash work, not from the redesign or the FEAT-004 fixes. The phone's installed build predates that work, so the loader and empty-state captures reflect the redesign as it was at 02:49.

## Re-test on the physical phone: create habits and confirm they persist (requested by the user)
Done on 10BF3A1CM30013Z with the build installed at about 02:50. That build predates the splash work added by someone else. Habits were created through the app's own Add screen, with the keyboard and taps.
- Created, in order: Divyansh (10 pts), Drink (100 pts, typed into the points field), QA_Read (10), QA_Meditate (15, quick pick) and QA_A_very_long_habit_name_that_should_wrap_or_truncate_gracefully_on_small_screens (25, quick pick). Today then showed '0 of 5 done' and '/ 160 points'. This is `17-phone-recreated-habits.png`. 'Drink' has no wine glass emoji, because `adb input text` cannot type emoji.
- Marked Divyansh done. Today showed '10 / 160 points', '1 of 5 done' and a '1-day streak'.
- Force-stopped and relaunched the app. All 5 habits came back with Divyansh still done and the same totals (`18-phone-after-relaunch-persisted.png`). `adb logcat` held no Firestore errors, permission-denied or unavailable lines during the run.
- What this does and does not prove: the habits survive an app restart. Firestore also keeps a local offline cache, so this alone does not prove the documents reached the server. The server side can only be confirmed in the Firebase console, under this anonymous user's habits collection.
- Test data is on the new anonymous account on the phone: QA_Read, QA_Meditate and the long-named QA habit are there now, along with Divyansh and Drink. The older, orphaned set from the previous install is still in Firestore under the old user.
- I changed the phone's `screen_off_timeout` to 10 minutes during this run, without recording the original value first. I set it to 60000 ms afterwards, so it may differ from what you had. Nothing else on the phone was changed.
