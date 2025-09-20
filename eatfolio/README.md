# Eatfolio

Eatfolio는 Flutter로 제작된 모바일 애플리케이션으로, 사용자가 식사를 기록하고 영양을 분석하며 AI 기반의 식단 피드백을 받을 수 있도록 돕습니다. 이 프로젝트는 프론트엔드(Flutter), 백엔드(Python), 그리고 Firebase Cloud Functions(Node.js)로 구성되어 있습니다.

## 프로젝트 구조

```
eatfolio/
├─ backend/                    # Python 백엔드 (backend 문서참조)
│
├─ eatfolio/                   # Flutter 프론트엔드
│  ├─ lib/
│  │  ├─ core/                # 코어 유틸리티, 테마/폰트, 프로바이더
│  │  │  ├─ fonts.dart        # 앱 전체 폰트 스타일 정의
│  │  │  ├─ provider_nav.dart # 네비게이션 상태 관리
│  │  │  └─ provider_auth.dart # 인증 상태 관리 (Firebase Auth)
│  │  ├─ data/                # 데이터 층
│  │  │  ├─ repositories/     # 데이터 접근 계층
│  │  │  │  └─ photo_repository.dart # 사진 업로드/관리
│  │  │  └─ faker/            # 테스트 데이터 생성 스크립트
│  │  ├─ presentation/        # UI 화면 & 위젯
│  │  │  ├─ screens/          # 주요 화면들
│  │  │  │  ├─ splash_page.dart       # 앱 시작/세션 체크 (로고/초기화)
│  │  │  │  ├─ home_page.dart         # 메인 홈 화면 (최근 식사 기록)
│  │  │  │  ├─ camera_page.dart       # 카메라 촬영 UI
│  │  │  │  ├─ register_page.dart     # 식단 등록 (사진, 음식명, 카테고리, 메모)
│  │  │  │  ├─ search_page.dart       # 음식명 검색 기능
│  │  │  │  ├─ detail_page.dart       # 식사 기록 상세 (사진, 영양소, 별점 등)
│  │  │  │  ├─ calendar_page.dart     # 날짜별 식사 기록 캘린더 뷰
│  │  │  │  ├─ profile_page.dart      # 사용자 통계 요약
│  │  │  │  ├─ report_page.dart       # 주간 리포트 + AI 피드백 + 추천
│  │  │  │  ├─ login_page.dart        # 로그인 UI
│  │  │  │  └─ signup_page.dart       # 회원가입 UI
│  │  │  └─ widgets/          # 재사용 가능한 UI 컴포넌트
│  │  │     ├─ buttons.dart   # 커스텀 버튼들
│  │  │     └─ cards.dart     # 카드 형태 UI 컴포넌트
│  │  └─ main.dart            # 앱 엔트리 포인트
│  ├─ android/                # Android 네이티브 설정
│  ├─ ios/                    # iOS 네이티브 설정
│  ├─ assets/                 # 이미지, 폰트, 아이콘
│  └─ pubspec.yaml            # Flutter 의존성
│
├─ functions/                  # Firebase Cloud Functions (Node.js 22, 2nd Gen)
│  ├─ index.js                # 메인 함수들 (Firestore 트리거, 통계 계산)
│  ├─ backfill.js             # 기존 데이터 백필 스크립트
│  └─ package.json            # Node.js 의존성
│
└─ README.md                   # 프로젝트 설명서
```

## 주요 기능

### 1. 식사 기록 시스템
- **카메라 촬영**: 사진 촬영 후 자동 크롭 및 최적화
- **음식 정보 입력**: 음식명(필수), 카테고리, 메모 입력
- **자동 메타데이터**: 위치(GPS), 시간 자동 저장
- **AI 영양소 분석**: 업로드된 사진을 백엔드로 전송하여 영양소 자동 분석

### 2. 영양 분석 & AI 피드백
- **실시간 영양소 계산**: 칼로리, 탄수화물, 단백질, 지방 등
- **AI 기반 분석**: 긍정/부정적 식단 패턴 분석
- **개인화된 피드백**: 사용자 식단 패턴에 맞는 맞춤형 조언
- **추천 시스템**: 다음 식사 메뉴 AI 추천

### 3. 사용자 프로필 & 통계
- **식사 통계**: 평균 칼로리, 총 식사 횟수, 평균 식사 시간
- **영양소 비율**: 탄수화물:단백질:지방 비율 시각화
- **재미 요소**: 
  - 총 단백질 → 계란 개수 환산
  - 총 나트륨 → 라면 개수 환산
- **시간별 분석**: 아침/점심/저녁별 식사 패턴

### 4. 리포트 & 인사이트
- **주간 리포트**: 7일간의 식단 종합 분석
- **점수 시스템**: 0-100점 식단 건강도 점수
- **진행률 표시**: 권장 영양소 대비 섭취량 시각화
- **트렌드 분석**: 시간에 따른 식단 변화 추적

## 기술 스택

### Frontend
- **Flutter**: 크로스 플랫폼 모바일 앱 개발
- **Provider**: 상태 관리
- **Firebase**: 인증, 데이터베이스, 클라우드 함수
- **Camera Plugin**: 네이티브 카메라 기능
- **Geolocator**: 위치 정보 수집

### Backend
- **Python FastAPI**: AI 분석 서버
- **OpenAI GPT**: 영양소 분석 및 피드백 생성
- **Image Processing**: 이미지 전처리 및 최적화

### Infrastructure
- **Firebase Firestore**: NoSQL 데이터베이스
- **Firebase Auth**: 사용자 인증
- **Firebase Cloud Functions**: 서버리스 백엔드 로직
- **Firebase Storage**: 이미지 저장

## 데이터 플로우

### 1. 식사 기록 플로우
```
사용자 카메라 촬영 → 이미지 크롭/최적화 → Firebase Storage 업로드 → 
백엔드 AI 분석 요청 → 영양소 분석 결과 → Firestore 저장 → 
프론트엔드 업데이트 → 통계 자동 계산
```

### 2. AI 분석 플로우
```
사진 업로드 → Python 백엔드로 전송 → AI 모델로 영양소 분석 → 
구조화된 데이터 반환 → Firebase 업데이트 → 
Cloud Functions 트리거 → 통계 재계산
```

### 3. 통계 계산 플로우
```
새 식사 기록 추가 → Firestore 트리거 → Cloud Functions 실행 → 
사용자 통계 집계 (평균, 총합, 비율 등) → 
user_stats 컬렉션 업데이트 → 주간 리포트 생성
```

### 데이터 구조

#### Firestore 컬렉션
- **`users`**: 사용자 기본 정보
- **`meals`**: 개별 식사 기록 (사진, 영양소, 메타데이터)
- **`user_stats`**: 사용자별 통계 집계 (실시간 업데이트)
- **`user_reports`**: 주간 리포트 및 AI 피드백

#### 주요 통계 계산
- **평균 칼로리**: `total_calories / meal_count`
- **매크로 비율**: 탄수화물:단백질:지방 비율 계산
- **식사 시간 통계**: 아침/점심/저녁별 평균 시간
- **영양소 총합**: 모든 식사의 영양소 합계

---

## Firebase Cloud Functions

Firebase Cloud Functions는 서버리스 백엔드 서비스로, Firestore 데이터베이스의 변화를 감지하여 자동으로 실행됩니다.

### 작동 방식
- **자동 트리거**: 사용자가 식사를 추가/수정/삭제할 때마다 자동 실행
- **실시간 통계**: 식사 데이터가 변경될 때마다 사용자 통계를 자동으로 재계산
- **주간 리포트**: 매주 일요일 자정에 모든 사용자의 주간 리포트를 자동 생성
- **AI 분석 연동**: Python 백엔드와 연동하여 AI 기반 식단 분석 수행

### 주요 역할
- 사용자 통계 실시간 업데이트
- 영양소 총합 및 평균값 계산
- 매크로 비율 자동 계산
- 주간 리포트 자동 생성
- 데이터 일관성 유지
