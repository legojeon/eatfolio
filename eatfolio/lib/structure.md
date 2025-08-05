lib/
├── main.dart
│
├── core/                   # 앱의 핵심 기능, 유틸리티
│   ├── constants/          # (신규) 상수(색상, 스타일 등) 폴더
│   │   └── app_colors.dart
│   └── usecases/           # (선택) 비즈니스 로직 정의
│
├── data/                   # 데이터 소스 및 관리
│   ├── models/             # (신규) 데이터 모델 폴더
│   │   ├── user_model.dart
│   │   └── food_model.dart
│   │
│   └── repositories/       # (신규) 데이터 입출력 구현체 (API 호출 등)
│       └── food_repository.dart
│
├── presentation/           # UI와 관련된 모든 것
│   ├── screens/            # (신규) 화면 단위 폴더
│   │   ├── home/           # (선택) 기능별로 하위 폴더 구성 가능
│   │   │   └── home_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   └── widgets/            # (신규) 공통 위젯 폴더
│       ├── bottom_nav_bar.dart
│       └── primary_button.dart
│
└── routes/                 # 화면 라우팅(경로) 관리
    └── app_router.dart     # GoRouter 등 라이브러리 설정