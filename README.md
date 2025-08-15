# ClimbX-FE

ClimbX는 클라이밍 동작 분석을 위한 Flutter 기반 모바일 애플리케이션입니다.

## 🚀 실행 방법

### 사전 요구 사항

#### 공통 요구 사항
- **Flutter SDK**: 3.8.1 이상
- **Dart SDK**: 3.8.1 이상
- **Git**

#### iOS 개발 (macOS 전용)
- **Xcode**: 15.0 이상
- **iOS Deployment Target**: 13.0 이상 (카카오 로그인 요구사항)
- **CocoaPods**: 최신 버전
  ```bash
  # CocoaPods 설치
  sudo gem install cocoapods
  
  # CocoaPods 업데이트
  pod repo update
  ```

#### Android 개발
- **Android Studio**: 최신 버전
- **Android SDK**: API 레벨 36
- **NDK**: 27.0.12077973 (네이버 지도 요구사항)
- **Java**: JDK 11
- **Kotlin**: 최신 버전
- **최소 SDK**: API 레벨 23 (Android 6.0)
- **타겟 SDK**: API 레벨 36

### 설치 및 실행

#### 1. 저장소 클론
```bash
git clone https://github.com/your-repo/ClimbX-FE.git
cd ClimbX-FE
```

#### 2. 의존성 설치
```bash
# Flutter 패키지 의존성 설치
flutter pub get
```

#### 3. 환경 변수 설정
```bash
# .env 파일을 프로젝트 루트에 생성하고 필요한 API 키들을 설정
cp .env.example .env  # .env.example 파일이 있는 경우
# 또는 .env 파일을 직접 생성하여 API 키들을 설정
```

#### 4. 플랫폼별 추가 설정

##### iOS 설정
```bash
# iOS 디렉토리로 이동
cd ios

# CocoaPods 의존성 설치
pod install

# 프로젝트 루트로 돌아가기
cd ..
```

**iOS 추가 설정 요구사항:**
- `ios/Runner/Info.plist`에서 `KAKAO_NATIVE_APP_KEY` 및 `GOOGLE_LOGIN_KEY` 환경변수 설정 필요
- Xcode에서 Runner.xcworkspace 파일로 프로젝트 열기
- Apple Developer 계정으로 서명 설정
- 카메라, 갤러리, 위치 접근 권한 설정됨

##### Android 설정
```bash
# Android 디렉토리 확인
cd android

# Gradle 동기화 (Android Studio에서 자동으로 처리됨)
./gradlew build

# 프로젝트 루트로 돌아가기
cd ..
```

**Android 추가 설정 요구사항:**
- SDK 36, NDK 27.0.12077973 설치 확인
- 카메라, 저장소, 위치 접근 권한 설정됨
- 카카오 로그인을 위한 키 해시 등록 필요

#### 5. 애플리케이션 실행

##### 개발 모드 실행
```bash
# 연결된 기기 확인
flutter devices

# iOS 시뮬레이터에서 실행
flutter run -d "iOS Simulator"

# Android 에뮬레이터에서 실행
flutter run -d "Android Emulator"

# 특정 기기에서 실행
flutter run -d [device-id]
```

##### 릴리스 모드 빌드
```bash
# iOS 릴리스 빌드
flutter build ios --release

# Android APK 빌드
flutter build apk --release

# Android App Bundle 빌드
flutter build appbundle --release
```

### 🔧 주요 의존성

#### 핵심 기능
- **flutter_naver_map**: 네이버 지도 연동
- **kakao_flutter_sdk**: 카카오 로그인
- **google_sign_in**: 구글 로그인  
- **sign_in_with_apple**: 애플 로그인

#### 미디어 처리
- **image_picker**: 이미지/비디오 선택
- **video_player**: 비디오 재생
- **light_compressor**: 비디오 압축
- **photo_manager**: 갤러리 접근

#### 네트워킹 및 상태 관리
- **dio**: HTTP 클라이언트
- **fquery**: 데이터 페칭 (React Query 스타일)
- **flutter_hooks**: 상태 관리

#### UI 및 유틸리티
- **fl_chart**: 차트 표시
- **flutter_secure_storage**: 보안 저장소
- **permission_handler**: 권한 관리

### 🛠 개발 도구

#### 코드 분석 및 테스트
```bash
# 코드 분석
flutter analyze

# 테스트 실행
flutter test

# 테스트 커버리지
flutter test --coverage
```

#### 플랫폼별 개발 도구
```bash
# iOS 시뮬레이터 열기
open -a Simulator

# Android 에뮬레이터 목록
emulator -list-avds

# Android 에뮬레이터 실행
emulator -avd [avd_name]
```

### 📱 지원 플랫폼

- **iOS**: 13.0 이상
- **Android**: API 23 (Android 6.0) 이상

### ⚠️ 주의사항

1. **iOS**: Xcode에서 Runner.xcworkspace 파일로 열어야 함 (.xcodeproj 아님)
2. **Android**: compileSdk 36, NDK 27.0.12077973이 설치되어 있어야 함
3. **카카오 로그인**: iOS/Android 모두 네이티브 앱 키 설정 필요
4. **네이버 지도**: 클라이언트 ID 설정 필요
5. **권한**: 카메라, 갤러리, 위치 권한이 런타임에 요청됨

### 🔑 API 키 설정

프로젝트 실행 전 다음 API 키들을 설정해야 합니다:
- 카카오 네이티브 앱 키
- 구글 로그인 키  
- 네이버 지도 클라이언트 ID
- (필요시) 애플 개발자 계정 설정