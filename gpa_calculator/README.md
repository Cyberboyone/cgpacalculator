# GPA / CGPA Calculator (Flutter, Android)

A fully offline GPA and CGPA calculator with semester-by-semester tracking,
credit-weighted averages, and support for multiple grading systems
(4.0, 5.0, percentage, or your own custom scale).

## Features

- **GPA per semester + CGPA across all semesters**, recalculated live.
- **Credit-weighted** — each course's grade is weighted by its credit units.
- **Multiple grading scales**: 4.0 (US-style), 5.0 (Nigerian-style),
  percentage, or build your own custom letter→point mapping.
- **Fully offline**: all data is stored on-device via `shared_preferences`
  (local key-value storage). No account, no server, no sync — nothing
  leaves the phone except AdMob's own ad requests.
- **Banner ads** via `google_mobile_ads`, wired up with Google's official
  test ad unit IDs so the app runs safely out of the box.

## Before you publish: swap in your real AdMob IDs

Right now the app uses Google's **test** IDs everywhere, which is required
during development (using your live IDs before the app is approved can get
your AdMob account flagged).

1. Create an app in your [AdMob console](https://apps.admob.com) and get
   your **App ID** and a **Banner ad unit ID**.
2. Replace the App ID in
   `android/app/src/main/AndroidManifest.xml` (the
   `com.google.android.gms.ads.APPLICATION_ID` meta-data value).
3. Replace the banner unit ID in `lib/services/ad_service.dart`
   (`AdService.bannerAdUnitId`).
4. Only switch these over once your app is live/approved — test with the
   defaults until then.

## Project structure

```
lib/
  models/
    grading_scale.dart   # GradeLevel, GradingScale (presets + custom)
    course.dart           # A single course: name, credits, grade/score
    semester.dart          # A semester: name + list of courses
  services/
    app_state.dart         # Central state (Provider/ChangeNotifier)
    storage_service.dart   # SharedPreferences persistence (offline)
    gpa_calculator.dart    # Pure GPA/CGPA math, unit-testable
    ad_service.dart        # AdMob init + banner factory
  screens/
    home_screen.dart              # CGPA overview + semester list
    semester_detail_screen.dart   # Add/edit courses in a semester
    scale_settings_screen.dart    # Pick preset or build custom scale
  widgets/
    banner_ad_widget.dart  # Reusable banner ad slot
  main.dart
```

## How the math works

For each course: `quality points = grade points × credit units`.

- **Semester GPA** = sum(quality points in semester) / sum(credit units in semester)
- **CGPA** = sum(quality points across ALL semesters) / sum(credit units across ALL semesters)

This is the standard weighted-average method used by most universities.
Switching grading scale changes how each grade is converted to points; it's
applied uniformly across all your saved semesters.

For percentage-scale mode, "grade points" is just the raw score (0–100), so
GPA/CGPA becomes a straightforward credit-weighted percentage average.

## Running it

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK and an Android device/emulator. This was built and
tested for Android; iOS should work with minimal changes (add the iOS
AdMob App ID to `ios/Runner/Info.plist` if you build for iOS later).

## Custom grading scales

From the scale settings screen (tune icon on the home screen), tap **New**
under "Your custom scales" to define your own grade labels and point
values — useful for schools with a grading system outside the built-in
4.0 / 5.0 / percentage presets. Custom scales are saved locally and persist
across app restarts, same as everything else.
