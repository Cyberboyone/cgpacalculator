# CGPA Calculator

Flutter source for the GPA / CGPA Calculator is in [`gpa_calculator/`](gpa_calculator/).

## Android builds

After moving [`github-actions-build-android.yml`](github-actions-build-android.yml) to `.github/workflows/build-android.yml`, GitHub Actions runs **Build Android app** whenever the app source changes or when it is manually dispatched from the **Actions** tab. A completed run supplies two downloadable artifacts:

- `gpa-calculator-apk` — installable Android release APK
- `gpa-calculator-aab` — Android App Bundle for Google Play Console upload

The uploaded source did not include the generated Android Gradle scaffold, so CI recreates that standard Flutter scaffold before compiling. The app source and the included Android manifest are retained.

## Local development

```bash
cd gpa_calculator
flutter create --platforms=android .
flutter pub get
flutter run
```
