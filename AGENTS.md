# Repository Guidelines

## Project Structure & Module Organization
- `lib/`: Dart source. Entry at `lib/main.dart`; features under `lib/src/`:
  - `api/` (network/services), `models/` (data/state), `screens/` (pages), `widgets/` (reusable UI), `utils/` (helpers).
- `assets/`: images/fonts; declare in `pubspec.yaml`.
- `test/`: unit/widget tests (e.g., `test/unit/history_data_test.dart`).
- Platform folders: `android/`, `ios/`, `web/`, `macos/`, `windows/`, `linux/`.
- Config: `pubspec.yaml` (deps/assets), `analysis_options.yaml` (lints).

## Build, Test, and Development Commands
- `flutter pub get`: installs dependencies from `pubspec.yaml`.
- `flutter run -d <device>`: runs the app locally (emulator or device).
- `flutter test`: runs all tests under `test/`.
- `flutter analyze`: static analysis using project lints.
- `dart format .`: formats code to Dart style.
- `flutter build apk --release` | `flutter build ios --release`: production builds (iOS requires codesign).

## Coding Style & Naming Conventions
- Indentation: 2 spaces; enforce null-safety and avoid dynamic where possible.
- Files: `snake_case.dart` (e.g., `user_profile_screen.dart`, `climb_card_widget.dart`).
- Types: classes/enums `PascalCase`; variables/functions `lowerCamelCase`; constants `SCREAMING_SNAKE_CASE`.
- Structure: keep UI in `screens/` and `widgets/`; business logic in `models/`/`utils/`; API calls in `api/`.
- Linting/formatting: run `flutter analyze` and `dart format .` before PRs.

## Testing Guidelines
- Framework: `flutter_test`/`test` with files named `*_test.dart`.
- Organization: group by type (e.g., `test/unit/`, `test/widget/`); mirror `lib/src/` paths when possible.
- Commands: `flutter test --coverage` generates `coverage/lcov.info` (optional check in CI).
- Aim for meaningful coverage of models/utils and critical widget behavior.

## Commit & Pull Request Guidelines
- Commit style: `[SWM-123] <type>: concise change` (types: `feat`, `fix`, `refact`, `chore`). Example: `[SWM-289] fix: handle null nickname in history`.
- Branch naming: `feat/SWM-123`, `fix/SWM-295`, `chore/SWM-301`.
- PRs: clear summary, linked ticket, screenshots/gifs for UI changes, test plan (`flutter test` output), and any platform notes.
- Keep changes focused; update `pubspec.yaml`/assets and docs when structure or APIs change.

## Security & Configuration Tips
- Do not commit secrets; prefer placeholders in `.env` and secure injection in CI.
- Validate API keys/domains per environment; avoid hardcoding in `lib/`.

# Always respond in Korean