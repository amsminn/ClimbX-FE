# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
```bash
# Get dependencies
flutter pub get

# Generate code for Freezed/json_serializable
dart run build_runner build --delete-conflicting-outputs

# Run app in debug mode
flutter run

# Run on specific device
flutter run -d "device-id"

# Run iOS simulator
flutter run -d "iOS Simulator"

# Run Android emulator  
flutter run -d "Android Emulator"
```

### Build & Release
```bash
# Build iOS release
flutter build ios --release

# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle --release
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Platform Tools
```bash
# iOS simulator
open -a Simulator

# Android emulator list
emulator -list-avds

# Android emulator run
emulator -avd [avd_name]
```

## Architecture Overview

This is a Flutter climbing analysis app following functional monadic patterns for API calls and clean architecture principles.

### Project Structure
```
lib/
├── main.dart                    # App entry point with SDK initialization
├── features/                    # Feature-based modules
│   └── gym_map/                # Naver Maps integration feature
└── src/
    ├── api/                    # API modules (functional monadic style)
    │   ├── util/               # API utilities (client, interceptors, error handling)
    │   ├── auth.dart           # Authentication API
    │   ├── user.dart           # User API
    │   └── gym.dart            # Climbing gym API
    ├── models/                 # Data models with JSON serialization
    ├── screens/                # UI screens/pages
    ├── utils/                  # Utility functions and constants
    └── widgets/                # Reusable UI components
```

### Key Technologies
- **State Management**: Flutter Hooks + fquery (React Query style)
- **HTTP Client**: Dio with interceptors for auth/error handling
- **Authentication**: Kakao, Google, Apple Sign In
- **Maps**: Naver Maps SDK
- **Media**: image_picker, video_player, light_compressor
- **Storage**: flutter_secure_storage for tokens

### API Pattern (Functional Monadic)
API calls follow a functional monadic pattern with `.then()` chaining:

```dart
class UserApi {
  static final _dio = ApiClient.instance.dio;
  
  static final getCurrentUserProfile = () {
    return _dio.get('/api/users/current')
      .then((response) => response.data as ApiResponse<dynamic>)
      .then((apiResponse) {
        if (!apiResponse.success || apiResponse.data == null) {
          throw Exception(apiResponse.error ?? 'Profile fetch failed');
        }
        return apiResponse.data as Map<String, dynamic>;
      })
      .then((data) => UserProfile.fromJson(data))
      .catchError((e) {
        throw Exception('Unable to load profile: $e');
      });
  };
}
```

### Query Parameters
Use `QueryParamsBuilder` for type-safe query parameter handling:

```dart
// QueryParamsBuilder - null 값 자동 필터링
queryParameters: QueryParamsBuilder()
  .add('latitude', 37.5665)
  .add('longitude', 126.9780)
  .add('cursor', cursor)  // null이면 자동으로 제외됨
  .build()
```

**권장**: QueryParamsBuilder를 사용하면 null 값이 자동으로 필터링되고 모든 값이 String으로 안전하게 변환됩니다.

### Authentication Flow
- Automatic token management via AuthInterceptor
- Token stored in flutter_secure_storage
- 401 responses trigger automatic logout with user notification
- Global navigator key for auth popups

### Environment Setup
Required `.env` variables:
- `NAVER_MAP_CLIENT_ID`: Naver Maps API key
- `KAKAO_NATIVE_APP_KEY`: Kakao SDK key
- Additional OAuth keys for Google/Apple Sign In

### Code Style
- Uses `flutter_lints` with custom rules in `analysis_options.yaml`
- Strict null safety enabled
- Prefer const constructors and final variables
- Single quotes for strings
- Trailing commas required

### Development Notes
- iOS: Use `.xcworkspace` file, not `.xcodeproj`
- Android: Requires API 36, NDK 27.0.12077973
- Camera/gallery/location permissions handled at runtime
- Video compression maintains aspect ratio via light_compressor

이 프로젝트에서 사용자가 코드 예시, 설치/설정 단계, 라이브러리/API 문서를 요청하면 반드시 Context7 MCP를 사용해 최신 정보를 우선 조회하세요.

