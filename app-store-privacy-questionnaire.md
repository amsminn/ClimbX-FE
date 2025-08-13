# ClimbX App Store Privacy Questionnaire 작성 가이드

## 개요
App Store Connect에서 앱 심사 전에 필수로 작성해야 하는 개인정보보호 설문지입니다. ClimbX 앱의 데이터 수집 및 사용 현황에 맞춰 작성해야 합니다.

## 1. Data Collection (데이터 수집 여부)

### Does this app collect data? 
**답변: Yes**

ClimbX는 사용자의 OAuth2 로그인 정보, 프로필 정보, 영상 등을 수집합니다.

## 2. Data Types (수집하는 데이터 유형)

### Contact Info (연락처 정보)
- **Email Address**: ✅ Yes
  - **Used for**: App Functionality (고객 지원, 계정 식별)
  - **Linked to User**: Yes
  - **Used for Tracking**: No

### Identifiers (식별자)
- **User ID**: ✅ Yes
  - **Used for**: App Functionality
  - **Linked to User**: Yes
  - **Used for Tracking**: No

### Usage Data (사용 데이터)
- **Product Interaction**: ✅ Yes
  - **Used for**: App Functionality (기능 제공 및 안정화)
  - **Linked to User**: Yes
  - **Used for Tracking**: No

### User Content (사용자 콘텐츠)
- **Photos**: ✅ Yes (프로필 이미지 및 제출 관련 이미지)
- **Videos**: ✅ Yes
  - **Used for**: App Functionality
  - **Linked to User**: Yes
  - **Used for Tracking**: No
- **Other User Content**: ✅ Yes (클라이밍 문제 제출 정보)
  - **Used for**: App Functionality
  - **Linked to User**: Yes
  - **Used for Tracking**: No

### Diagnostics (진단 정보)
- **Crash Data**: ❌ No (현재 크래시 리포팅 도구 미사용)
- **Performance Data**: ❌ No
- **Other Diagnostic Data**: ❌ No

## 3. Data Use Purposes (데이터 사용 목적)

### App Functionality (앱 기능)
ClimbX는 다음 목적으로 데이터를 사용합니다:
- 사용자 인증 및 계정 관리
- 클라이밍 문제 제출 및 관리
- 랭킹 및 통계 서비스 제공
- 영상 업로드 및 스트리밍

### Analytics (분석)
- 현재 앱 내 별도의 제3자 분석 SDK는 사용하지 않습니다.
- 서비스 품질 향상을 위한 최소한의 이용 통계는 서버 측에서 집계될 수 있으나, 추적 목적은 없습니다.

## 4. Third Party Partners (제3자 파트너)

### Social Login Providers
- **Kakao**: OAuth2 인증
- **Google**: OAuth2 인증  
- **Apple**: OAuth2 인증

### Cloud Service Providers
- **Amazon Web Services (AWS)**: 영상 저장 및 스트리밍

## 5. Data Retention and Deletion (데이터 보존 및 삭제)

### User Control
사용자는 다음을 통해 데이터를 관리할 수 있습니다:
- 앱 내 프로필 설정에서 개인정보 수정
- 계정 삭제 요청
- 업로드한 영상 개별 삭제

### Retention Policy
- 계정 삭제 요청 시 즉시 비활성화(소프트 삭제)되며, 최대 14일 내 영구 삭제 처리됩니다.
- 영상/이미지 파일 등 대용량 데이터는 시스템 백업 정책에 따라 최대 30일 이내 순차 삭제될 수 있습니다.
- 법령상 의무가 있는 데이터는 해당 법정 보존기간 동안 예외적으로 보관 후 파기됩니다.

### Account Deletion (계정 삭제 경로)
- 앱 내: 설정 > 계정 > 계정 삭제(2단계 확인)
- 앱 접근이 불가한 사용자: `privacy@climbx.com` 으로 요청

## 6. Data Security (데이터 보안)

### Security Measures
- 데이터 전송 시 암호화 (HTTPS/TLS)
- 민감한 개인정보 암호화 저장
- 접근 권한 관리
- AWS 보안 표준 준수

## 7. 추천 설정값 요약

```
Data Collection: Yes

Collected Data Types:
- Contact Info → Email Address: Yes
- Identifiers → User ID: Yes  
- Usage Data → Product Interaction: Yes
- User Content → Photos: Yes
- User Content → Videos: Yes
- User Content → Other User Content: Yes

Data Linked to User: Yes (모든 수집 데이터)

Used for Tracking: No (모든 데이터)

Purposes:
- App Functionality: Yes
- Analytics: No (제3자 분석 SDK 미사용)

Third-Party Partners:
- Social login providers (Kakao, Google, Apple)
- AWS (Cloud services, ap-northeast-2)

Account Deletion:
- In-app deletion available; external URL/email provided for users without app access
```

## 8. 작성 시 주의사항

1. **정확성 중요**: 실제 앱에서 수집하지 않는 데이터를 'Yes'로 표시하면 안됩니다.
2. **업데이트 필수**: 앱 기능 변경 시 설문지도 함께 업데이트해야 합니다.
3. **심사 지연 방지**: 부정확한 정보는 앱 심사 지연의 원인이 됩니다.
4. **개발팀 확인**: 개발팀과 실제 수집 데이터를 재확인하고 작성하세요.

## 9. 향후 기능 추가 시 고려사항

### 추가될 가능성이 있는 데이터 수집
- **Health & Fitness**: 클라이밍 운동 데이터 추가 시
- **Location**: 클라이밍 짐 위치 기반 서비스 추가 시
- **Crash Data**: 앱 안정성 개선을 위한 크래시 리포팅 도구 도입 시

### 광고 추가 시
- **Advertising Data** 카테고리 추가 필요
- **Used for Tracking**: Yes로 변경 필요한 데이터 있을 수 있음