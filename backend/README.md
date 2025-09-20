# 🍽️ Eatfolio Backend

Flutter 앱과 연동되는 FastAPI 백엔드 서버입니다. Google Gemini API를 사용하여 음식 이미지 분석 기능을 제공합니다.

## 🚀 주요 기능

- **이중 AI 분석 시스템**: YOLOv3 + ResNet 기반 음식 분석 우선, Gemini API 폴백
- **식단 분석**: 음식 인식 및 영양 정보 제공
- **RESTful API**: Flutter 앱에서 쉽게 호출할 수 있는 API 엔드포인트
- **CORS 지원**: 웹 및 모바일 앱에서 접근 가능
- **자동 API 문서**: FastAPI의 자동 문서 생성 기능
- **비동기 처리**: 고성능 비동기 이미지 분석

## 📁 프로젝트 구조

```
backend/
├── main.py                 # FastAPI 애플리케이션 메인 파일
├── requirements.txt        # Python 의존성 목록
├── setup.sh               # macOS/Linux 자동 설정 스크립트
├── setup.bat              # Windows 자동 설정 스크립트
├── prompts/               # AI 프롬프트 템플릿
│   ├── food_nutrition.txt # 음식 영양 분석 프롬프트
│   └── prompt_analyze.txt # 식단 분석 프롬프트
├── venv/                  # Python 가상환경 (자동 생성)
└── README.md              
```

## 🤖 AI 분석 시스템 구조

### **1차 AI 모델 (우선 사용)**
- **YOLOv3**: 음식 객체 탐지 및 분류
  - 음식 종류 식별
  - 이미지 내 음식 위치 탐지
  - 다중 음식 객체 처리
- **ResNet**: 양(portion) 추정
  - 이미지 기반 양 분석
  - 그램 단위 무게 추정
  - 칼로리 계산 지원

### **2차 AI 모델 (폴백)**
- **Google Gemini 2.5 Flash**: 
  - 1차 모델 실패 시 사용
  - 이미지 기반 음식 분석
  - 구조화된 JSON 응답 생성
  - 자연어 기반 영양 정보 추출

### **분석 플로우**
```
이미지 업로드 → 1차 AI 모델(YOLOv3+ResNet) → 성공 시 결과 반환
                                    ↓
                              실패 시 2차 AI 모델(Gemini) → 결과 반환
```

## 📊 AI 모델 학습 데이터 및 참고 자료

### **AI Hub 음식 이미지 데이터셋 참고**
본 프로젝트의 AI 모델은 [AI Hub의 음식 이미지 및 영양정보 텍스트 데이터셋](https://aihub.or.kr/aihubdata/data/view.do?currMenu=115&topMenu=100&aihubDataSe=realm&dataSetSn=74)을 참고하여 설계되었습니다.

**참고 데이터셋 특징:**
- **구축 목적**: 한국인 다빈도 섭취 외식메뉴와 한식메뉴 400종 선정
- **데이터 규모**: 84.5만장의 고품질 이미지 (500만 화소 이상)
- **영양 정보**: 칼로리, 염분, 당도 등 상세 영양성분 포함
- **어노테이션**: 100건 이상의 정밀 어노테이션 수행

**프로젝트 적용:**
- AI Hub 데이터셋의 음식 분류 체계를 참고하여 모델 아키텍처 설계
- 한국인 식습관에 특화된 음식 인식 모델 구축
- 영양정보 메타데이터 구조를 참고하여 API 응답 형식 설계

**프로젝트의 고유한 특징:**
- **이중 AI 시스템**: YOLOv3+ResNet 기반 전용 모델과 Gemini API의 하이브리드 접근
- **실시간 분석**: FastAPI 기반의 고성능 비동기 처리로 빠른 응답 속도
- **Flutter 연동**: 모바일 앱과의 원활한 연동을 위한 RESTful API 설계
- **Firebase 통합**: 실시간 데이터베이스 연동으로 사용자별 식단 이력 관리


## 🛠️ 설치 및 설정

### 1. 저장소 클론
```bash
git clone <repository-url>
cd eatfolio/backend
```

### 2. 자동 설정 (권장)

**macOS/Linux:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows:**
```cmd
setup.bat
```

### 3. 수동 설정

**가상환경 생성:**
```bash
python3 -m venv venv
```

**가상환경 활성화:**
```bash
# macOS/Linux
source venv/bin/activate

# Windows
venv\Scripts\activate.bat
```

**의존성 설치:**
```bash
pip install -r requirements.txt
```

### 4. 환경변수 설정

1. `env.example` 파일을 `.env`로 복사
2. 필요한 API 키들을 설정

```bash
cp env.example .env
```

`.env` 파일 편집 (필수 환경변수):
```env
# Firebase Admin SDK 인증 정보 (Base64 인코딩)
FIREBASE_CREDENTIALS_B64="your_base64_encoded_firebase_credentials_here"

# Google Gemini API 키
GOOGLE_API_KEY="your_google_gemini_api_key_here"

# AI 모델 API URL (YOLOv3 + ResNet 기반)
MODEL_API_URL="http://localhost:8001"
```

**API Key 발급 방법:**

**Google Gemini API:**
1. [Google AI Studio](https://makersuite.google.com/app/apikey) 방문
2. API Key 생성
3. 생성된 키를 `.env` 파일의 `GOOGLE_API_KEY`에 입력

**Firebase Admin SDK:**
1. [Firebase Console](https://console.firebase.google.com/) 방문
2. 프로젝트 설정 > 서비스 계정 > 새 비공개 키 생성
3. 다운로드된 JSON 파일을 Base64로 인코딩:
   ```bash
   cat firebase-credentials.json | base64 -w 0
   ```
4. 인코딩된 문자열을 `.env` 파일의 `FIREBASE_CREDENTIALS_B64`에 입력

**AI 모델 API URL:**
- YOLOv3 + ResNet 기반 음식 분석 모델 서버 주소 설정
- 로컬 개발 시: `http://localhost:8001`
- 클라우드 배포 시: 실제 서버 URL

## 🚀 서버 실행

### 개발 모드 (권장)
```bash
# 가상환경 활성화 후
source venv/bin/activate  # macOS/Linux
# 또는
venv\Scripts\activate.bat # Windows

# 서버 실행
python3 -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## 📚 API 엔드포인트

### 기본 엔드포인트

#### GET `/`
- **설명**: 서버 상태 확인
- **응답**: `{"message": "Eatfolio Backend API is running!"}`

#### GET `/health`
- **설명**: 헬스 체크
- **응답**: `{"status": "healthy", "service": "eatfolio-backend"}`

### 핵심 기능 엔드포인트

#### POST `/request_analysis`
- **설명**: 음식 이미지 분석 및 영양 정보 제공
- **Content-Type**: `multipart/form-data`
- **요청 파라미터**:
  - `file`: 이미지 파일 (jpg, png, webp 지원)
  - `record_id`: 분석 기록 ID
  - `user_id`: 사용자 ID
- **AI 분석 플로우**:
  1. **1차**: YOLOv3 + ResNet 기반 AI 모델 API 호출
     - YOLOv3: 음식 분류 및 객체 탐지
     - ResNet: 양(portion) 추정
  2. **2차**: AI 모델 실패 시 Gemini API 폴백
     - Google Gemini 2.5 Flash 모델 사용
     - 구조화된 JSON 응답 생성
- **응답**: 
```json
{
  "record_id": "12345",
  "user_id": "user123",
  "predicted_food_name": "김치찌개",
  "nutrition_info": {
    "carbohydrate": 25.5,
    "sugars": 3.2,
    "fat": 12.0,
    "protein": 15.8,
    "calcium": 120.0,
    "phosphorus": 180.0,
    "sodium": 850.0,
    "potassium": 320.0,
    "magnesium": 45.0,
    "iron": 2.5,
    "zinc": 1.8,
    "cholesterol": 45.0,
    "trans_fat": 0.0
  },
  "calories": 350,
  "weight_g": 250
}
```

#### POST `/nutritional-analysis`
- **설명**: 사용자별 주간 영양 분석
- **요청**: `{"user_id": "사용자ID"}`
- **응답**: 평균 영양소, 긍정/부정 분석, 피드백, 추천 식사, 점수
