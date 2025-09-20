import base64
import re
import io
import logging
import traceback
from string import Template
from typing import List, Optional
from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pathlib import Path
import shutil, uuid
from pydantic import BaseModel, Field
import os
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime, timedelta, timezone
import json
import httpx
from google import genai
from google.genai import types

# HTTP 클라이언트 라이브러리들의 로그 레벨을 WARNING으로 설정
logging.getLogger("httpcore").setLevel(logging.WARNING)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("urllib3").setLevel(logging.WARNING)
logging.getLogger("google_genai").setLevel(logging.WARNING)

# 로깅 설정
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# .env 파일 로드
logger.info("환경변수 로드 시작")
load_dotenv()
logger.info("환경변수 로드 완료")

# --- Firebase Admin SDK 초기화 ---
logger.info("Firebase Admin SDK 초기화 시작")
b64 = os.getenv("FIREBASE_CREDENTIALS_B64")
if not b64:
    logger.error("FIREBASE_CREDENTIALS_B64 환경변수가 설정되지 않음")
    raise ValueError("FIREBASE_CREDENTIALS_B64 env missing")

try:
    info = json.loads(base64.b64decode(b64).decode("utf-8"))
    logger.info("Firebase 인증 정보 디코딩 성공")
    cred = credentials.Certificate(info)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
        logger.info("Firebase 앱 초기화 성공")
    db = firestore.client()
    logger.info("Firestore 클라이언트 생성 성공")
except Exception as e:
    logger.error(f"Firebase 초기화 실패: {str(e)}")
    logger.error(f"상세 오류: {traceback.format_exc()}")
    raise
# ---------------------------------

app = FastAPI(title="Eatfolio Backend API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ 모든 JSON 응답에 charset=utf-8 강제 추가 (오류 응답 포함)
@app.middleware("http")
async def add_charset_to_json(request, call_next):
    response = await call_next(request)
    ct = response.headers.get("content-type")
    if ct and ct.startswith("application/json") and "charset=" not in ct.lower():
        response.headers["content-type"] = "application/json; charset=utf-8"
    return response

# --- Google Gen AI 클라이언트 설정 ---
logger.info("Google Gen AI 클라이언트 설정 시작")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    logger.error("GOOGLE_API_KEY 환경변수가 설정되지 않음")
    raise ValueError("GOOGLE_API_KEY 환경변수가 설정되지 않았습니다.")
try:
    client = genai.Client(api_key=GOOGLE_API_KEY)
    logger.info("Google Gen AI 클라이언트 생성 성공")
except Exception as e:
    logger.error(f"Google Gen AI 클라이언트 생성 실패: {str(e)}")
    logger.error(f"상세 오류: {traceback.format_exc()}")
    raise
# ----------------------------------------------------------

# --- AI 모델 API 설정 ---
logger.info("AI 모델 API 설정 로드 시작")
MODEL_API_URL = os.getenv("MODEL_API_URL")
if not MODEL_API_URL:
    logger.error("MODEL_API_URL 환경변수가 설정되지 않음")
    raise ValueError("MODEL_API_URL 환경변수가 설정되지 않았습니다.")
logger.info(f"AI 모델 API URL: {MODEL_API_URL}")

# --- Gemini API 스키마 정의 ---
class NutritionInfo(BaseModel):
    carbohydrates: float = Field(..., description="g")
    sugars: float = Field(..., description="g")
    fat: float = Field(..., description="g")
    protein: float = Field(..., description="g")
    calcium: float = Field(..., description="mg")
    phosphorus: float = Field(..., description="mg")
    sodium: float = Field(..., description="mg")
    potassium: float = Field(..., description="mg")
    magnesium: float = Field(..., description="mg")
    iron: float = Field(..., description="mg")
    zinc: float = Field(..., description="mg")
    cholesterol: float = Field(..., description="mg")
    transfat: float = Field(..., description="g")

class FoodEstimate(BaseModel):
    food_name: str
    weight_g: float
    calories: float
    nutrition_info: NutritionInfo

async def _call_gemini_food_analysis(image_path: Path, original_img_bytes: bytes) -> Optional[dict]:
    """Gemini API를 사용하여 음식 이미지 분석"""
    try:
        # 프롬프트 파일 읽기
        prompt_file_path = os.path.join(os.path.dirname(__file__), "prompts", "food_nutrition.txt")
        if not os.path.exists(prompt_file_path):
            logger.error(f"프롬프트 파일을 찾을 수 없음: {prompt_file_path}")
            return None
        
        with open(prompt_file_path, "r", encoding="utf-8") as f:
            prompt_text = f.read()
        
        # Gemini API 호출
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                types.Part.from_bytes(
                    data=original_img_bytes,
                    mime_type='image/jpeg',
                ), 
                prompt_text
            ],
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                response_schema=FoodEstimate,
            ),
        )
        
        # 응답 파싱
        if response.text:
            try:
                # JSON 문자열을 파싱
                parsed_data = json.loads(response.text)
                
                # FoodEstimate 형식으로 변환
                food_estimate = FoodEstimate(**parsed_data)
                
                # main.py에서 사용하는 형식으로 변환
                result = {
                    "success": True,
                    "food_name": food_estimate.food_name,
                    "food_code": "00000000",  # Gemini는 food_code를 제공하지 않으므로 기본값
                    "nutrition_info": {
                        "food_name": food_estimate.food_name,
                        "weight_g": food_estimate.weight_g,
                        "calories": food_estimate.calories,
                        "carbohydrates": food_estimate.nutrition_info.carbohydrates,
                        "sugars": food_estimate.nutrition_info.sugars,
                        "fat": food_estimate.nutrition_info.fat,
                        "protein": food_estimate.nutrition_info.protein,
                        "calcium": food_estimate.nutrition_info.calcium,
                        "phosphorus": food_estimate.nutrition_info.phosphorus,
                        "sodium": food_estimate.nutrition_info.sodium,
                        "potassium": food_estimate.nutrition_info.potassium,
                        "magnesium": food_estimate.nutrition_info.magnesium,
                        "iron": food_estimate.nutrition_info.iron,
                        "zinc": food_estimate.nutrition_info.zinc,
                        "cholesterol": food_estimate.nutrition_info.cholesterol,
                        "transfat": food_estimate.nutrition_info.transfat
                    },
                    "quantity_prediction": "",  # Gemini는 quantity를 제공하지 않으므로 기본값
                    "quantity_probability": 0.0,  # Gemini는 probability를 제공하지 않으므로 기본값
                    "error_message": None
                }
                
                return result
                
            except json.JSONDecodeError as e:
                logger.error(f"Gemini API 응답 JSON 파싱 실패: {e}")
                return None
            except Exception as e:
                logger.error(f"Gemini API 응답 처리 실패: {e}")
                return None
        else:
            logger.error("Gemini API 응답이 비어있음")
            return None
            
    except Exception as e:
        logger.error(f"Gemini API 호출 중 예외 발생: {str(e)}")
        return None



def _to_float_or_empty(v) -> Optional[float]:
    try:
        if v in (None, "", "null"):
            return ""
        return float(v)
    except (TypeError, ValueError):
        return ""



def _transform_ai_response(ai_json: dict) -> dict:
    """
    Transform AI model response to:
    {
      "predicted_food_name": <string>,
      "nutrition_info": {...},  # calories, weight_g 제외
      "calories": <float>,      # 별도 필드로 추가
      "weight_g": <float>       # 별도 필드로 추가
    }
    """
    food_name = ai_json.get("food_name", "음식")
    nutrition_info_raw = ai_json.get("nutrition_info", {})

    # food_mapping.json 형식에 맞춰 영양소 정보 구성
    # calories와 weight_g는 제외하고 기본 영양소만 포함
    nutrition_info = {
        "carbohydrate": _to_float_or_empty(nutrition_info_raw.get("carbohydrates")),  # carbohydrates
        "sugars": _to_float_or_empty(nutrition_info_raw.get("sugars")),
        "fat": _to_float_or_empty(nutrition_info_raw.get("fat")),
        "protein": _to_float_or_empty(nutrition_info_raw.get("protein")),
        "calcium": _to_float_or_empty(nutrition_info_raw.get("calcium")),
        "phosphorus": _to_float_or_empty(nutrition_info_raw.get("phosphorus")),
        "sodium": _to_float_or_empty(nutrition_info_raw.get("sodium")),
        "potassium": _to_float_or_empty(nutrition_info_raw.get("potassium")),
        "magnesium": _to_float_or_empty(nutrition_info_raw.get("magnesium")),
        "iron": _to_float_or_empty(nutrition_info_raw.get("iron")),
        "zinc": _to_float_or_empty(nutrition_info_raw.get("zinc")),
        "cholesterol": _to_float_or_empty(nutrition_info_raw.get("cholesterol")),
        "trans_fat": _to_float_or_empty(nutrition_info_raw.get("transfat"))  # transfat
    }
    
    # calories와 weight_g를 AI 모델 응답의 nutrition_info에서 추출
    calories_value = ai_json.get("nutrition_info", {}).get("calories")
    weight_g_value = ai_json.get("nutrition_info", {}).get("weight_g")
    
    # None 값인 경우 빈 문자열로 처리 (Firebase 저장 시 문제 방지)
    if calories_value is None:
        calories_value = ""
    if weight_g_value is None:
        weight_g_value = ""

    result = {
        "predicted_food_name": food_name,
        "nutrition_info": nutrition_info,
        "calories": calories_value,
        "weight_g": weight_g_value
    }
    
    return result

async def _call_ai_model(image_path: Path, image_bytes: bytes) -> Optional[dict]:
    """AI 모델 API 호출"""
    try:
        # 이미지 파일 존재 확인
        if not image_path.exists():
            logger.error(f"이미지 파일이 존재하지 않음: {image_path}")
            return None
        
        # multipart/form-data로 이미지 전송
        files = {'file': (image_path.name, image_bytes, 'image/jpeg')}
        
        async with httpx.AsyncClient(timeout=60) as client_http:
            r = await client_http.post(
                f"{MODEL_API_URL}/upload",
                files=files
            )
                
        if r.status_code != 200:
            logger.warning(f"AI 모델 API 오류: {r.status_code} - {r.text}")
            return None
        
        response_json = r.json()
        
        if response_json.get("success"):
            return response_json
        else:
            return None
        
    except Exception as e:
        logger.warning(f"AI 모델 API 호출 중 예외 발생: {str(e)}")
        return None

# --- 요청/응답 모델 ---
class NutritionalAnalysisRequest(BaseModel):
    user_id: str

class StructuredAnalysisResponse(BaseModel):
    avg_nutrients: List[str]
    pos_analysis: str
    neg_analysis: str
    feedback: str
    rec_meal: List[str]
    score: int = Field(ge=0, le=100)
# ----------------------

@app.get("/")
async def root():
    logger.info("루트 엔드포인트 호출됨")
    return {"message": "Eatfolio Backend API is running!"}

@app.get("/health")
async def health_check():
    logger.info("헬스체크 엔드포인트 호출됨")
    return {"status": "healthy", "service": "eatfolio-backend"}

@app.get("/debug/env")
async def debug_env():
    """환경변수 디버깅용 엔드포인트 (개발용)"""
    logger.info("환경변수 디버깅 엔드포인트 호출됨")
    env_vars = {
        "FIREBASE_CREDENTIALS_B64": "설정됨" if os.getenv("FIREBASE_CREDENTIALS_B64") else "설정되지 않음",
        "GOOGLE_API_KEY": "설정됨" if os.getenv("GOOGLE_API_KEY") else "설정되지 않음",
        "FATSECRET_CLIENT_ID": "설정됨" if os.getenv("FATSECRET_CLIENT_ID") else "설정되지 않음",
        "FATSECRET_CLIENT_SECRET": "설정됨" if os.getenv("FATSECRET_CLIENT_SECRET") else "설정되지 않음",
        "FATSECRET_REGION": os.getenv("FATSECRET_REGION", "KR"),
        "FATSECRET_LANGUAGE": os.getenv("FATSECRET_LANGUAGE", "ko"),
    }
    logger.info(f"환경변수 상태: {env_vars}")
    return {"environment_variables": env_vars}

@app.get("/debug/photos/{user_id}")
async def debug_user_photos(user_id: str):
    """특정 사용자의 Photos 데이터 확인용 엔드포인트 (개발용)"""
    logger.info(f"사용자 Photos 데이터 확인: user_id={user_id}")
    
    try:
        # 한국 시간 기준으로 날짜 계산
        kst = timezone(timedelta(hours=9))
        end_date_dt = datetime.now(kst)
        start_date_dt = end_date_dt - timedelta(days=7)
        
        # ISO 형식 문자열로 변환
        start_date_str = start_date_dt.strftime("%Y-%m-%dT%H:%M:%S.%f")
        end_date_str = end_date_dt.strftime("%Y-%m-%dT%H:%M:%S.%f")
        
        photos_ref = db.collection("Photos")
        query = (
            photos_ref.where("user_id", "==", user_id)
                    .where("created_at", ">=", start_date_str)
                    .where("created_at", "<=", end_date_str)
                    .order_by("created_at")
        )
        
        docs = query.stream()
        
        photos_data = []
        for doc in docs:
            data = doc.to_dict()
            photo_info = {
                "id": doc.id,
                "created_at": data.get("created_at"),
                "calories": data.get("calories"),
                "weight_g": data.get("weight_g"),
                "nutrition_info": data.get("nutrition_info"),
                "analyze": data.get("analyze"),
                "predicted_food_name": data.get("predicted_food_name")
            }
            photos_data.append(photo_info)
        
        return {
            "user_id": user_id,
            "query_period": {
                "start": start_date_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "end": end_date_dt.strftime("%Y-%m-%d %H:%M:%S"),
                "start_str": start_date_str,
                "end_str": end_date_str
            },
            "total_photos": len(photos_data),
            "photos": photos_data
        }
        
    except Exception as e:
        logger.error(f"Photos 데이터 확인 중 오류: {str(e)}")
        return {
            "error": str(e),
            "traceback": traceback.format_exc()
        }

# --- 이미지 업로드 및 FatSecret 영양 분석 요청 ---
@app.post("/request_analysis")
async def request_analysis(
    file: UploadFile = File(...),
    record_id: str = Form(...),
    user_id: str = Form(...),
):
    logger.info(f"이미지 분석 요청 시작: record_id={record_id}, user_id={user_id}")
    logger.info(f"업로드된 파일: {file.filename}, content_type={file.content_type}, size={file.size}")
    
    try:
        # (A) Validate content-type
        logger.info("파일 타입 검증 중...")
        allowed = {"image/jpeg", "image/png", "image/webp"}
        if file.content_type not in allowed:
            logger.warning(f"지원하지 않는 파일 타입: {file.content_type}")
            return JSONResponse(
                {"error": f"Unsupported content-type: {file.content_type}"},
                status_code=415,
            )
        logger.info("파일 타입 검증 통과")

        # (B) Save uploaded image locally (optional but handy for debugging)
        logger.info("업로드된 이미지 저장 중...")
        uploads_dir = Path("uploads")
        uploads_dir.mkdir(parents=True, exist_ok=True)
        ext = Path(file.filename).suffix or ".jpg"
        saved_name = f"{record_id}_{uuid.uuid4().hex}{ext}"
        saved_path = uploads_dir / saved_name
        logger.info(f"저장 경로: {saved_path}")
        
        with saved_path.open("wb") as out:
            shutil.copyfileobj(file.file, out)
        logger.info("이미지 저장 완료")

        # (C) Read bytes for different APIs
        original_img_bytes = saved_path.read_bytes()
        original_size = len(original_img_bytes)

        # (D) 먼저 AI 모델 API 호출 시도 (원본 이미지 사용, detect_cls.py에서 자동 리사이징)
        ai_result = await _call_ai_model(saved_path, original_img_bytes)
        
        if ai_result and ai_result.get("success"):
            # AI 모델 분석 성공 시
            logger.info("AI 모델 분석 성공")
            transformed = _transform_ai_response(ai_result)
        else:
            # AI 모델 실패 시 Gemini API 사용 (원본 이미지 사용)
            logger.info("AI 모델 분석 실패, Gemini API 사용")
            
            gemini_result = await _call_gemini_food_analysis(saved_path, original_img_bytes)
            if gemini_result and gemini_result.get("success"):
                logger.info("Gemini API 분석 성공")
                transformed = _transform_ai_response(gemini_result)
            else:
                logger.error("Gemini API 분석도 실패")
                # 기본 응답 생성
                transformed = {
                    "predicted_food_name": "음식",
                    "nutrition_info": {},
                    "calories": "",
                    "weight_g": ""
                }
        # AI 모델 API 호출 후 즉시 이미지 파일 삭제
        try:
            if saved_path.exists():
                saved_path.unlink()
            else:
                logger.warning(f"삭제할 이미지 파일이 존재하지 않음: {saved_path}")
        except Exception as e:
            logger.warning(f"이미지 파일 삭제 실패 (무시): {str(e)}")
            # 이미지 삭제 실패는 전체 요청 실패로 처리하지 않음
        # (E) Update Firestore document
        try:
            # transformed 결과에서 nutrition_info 데이터를 직접 추출
            nutrition_data = transformed["nutrition_info"]
            predicted_food_name = transformed["predicted_food_name"]
            
            # calories와 weight_g를 transformed 결과의 최상위 레벨에서 추출
            calories_value = transformed["calories"]
            weight_g_value = transformed["weight_g"]
            
            update_data = {
                "analyze": True,
                "predicted_food_name": predicted_food_name,
                "nutrition_info": nutrition_data,
                "calories": calories_value,
                "weight_g": weight_g_value
            }

            logger.info(f"Firebase 업데이트 데이터: {update_data}")
            db.collection("Photos").document(record_id).update(update_data)
            logger.info("Firebase 문서 업데이트 완료")
        except Exception as e:
            logger.error(f"Firebase 업데이트 실패: {str(e)}")
            logger.error(f"상세 오류: {traceback.format_exc()}")
            # Log but don't fail the request solely due to Firestore update issues
            print(f"Firestore update failed for {record_id}: {e}")

        # (F) Return response in your requested format
        response_data = {
            "record_id": record_id,
            "user_id": user_id,
            **transformed,
        }
        
        return JSONResponse(
            response_data,
            status_code=200,
        )
        
    except HTTPException as http_exc:
        logger.error(f"HTTP 예외 발생: {http_exc.status_code} - {http_exc.detail}")
        raise http_exc
    except Exception as e:
        logger.error(f"이미지 분석 중 예외 발생: {str(e)}")
        logger.error(f"상세 오류: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"이미지 분석 중 오류가 발생했습니다: {str(e)}")

# --- 주간 요약 영양 분석 (기존 기능 유지) ---
@app.post("/nutritional-analysis", response_model=StructuredAnalysisResponse)
async def analyze_nutrition(request: NutritionalAnalysisRequest):
    """
    사용자 ID를 기반으로 Firestore에서 지난 7일간의 음식 데이터를 가져와
    구조화된 JSON 형태로 영양 분석을 제공합니다.
    """
    try:
        user_id = request.user_id
        logger.info(f"영양 분석 시작: user_id={user_id}")

        # 한국 시간 기준으로 날짜 계산
        kst = timezone(timedelta(hours=9))
        end_date_dt = datetime.now(kst)
        start_date_dt = end_date_dt - timedelta(days=7)
        
        logger.info(f"조회 기간: {start_date_dt.strftime('%Y-%m-%d %H:%M:%S')} ~ {end_date_dt.strftime('%Y-%m-%d %H:%M:%S')}")
        
        # ISO 형식 문자열로 변환 (Firestore 쿼리용)
        start_date_str = start_date_dt.strftime("%Y-%m-%dT%H:%M:%S.%f")
        end_date_str = end_date_dt.strftime("%Y-%m-%dT%H:%M:%S.%f")
        
        logger.info(f"쿼리용 날짜 문자열: {start_date_str} ~ {end_date_str}")

        photos_ref = db.collection("Photos")
        query = (
            photos_ref.where("user_id", "==", user_id)
                    .where("created_at", ">=", start_date_str)   # 문자열 기반 비교
                    .where("created_at", "<=", end_date_str)     # 문자열 기반 비교
                    .order_by("created_at")
        )

        logger.info(f"Firestore 쿼리 실행: user_id={user_id}")
        docs = query.stream()

        food_data_list = []
        total_docs = 0
        skipped_docs = 0
        
        for doc in docs:
            total_docs += 1
            data = doc.to_dict()
            if not data:
                skipped_docs += 1
                continue

            logger.debug(f"문서 {doc.id}: created_at={data.get('created_at')}, calories={data.get('calories')}, nutrition_info={data.get('nutrition_info')}")

            if data.get("calories") is None or data.get("nutrition_info") is None:
                logger.debug(f"문서 {doc.id}: 필수 필드 누락으로 스킵")
                skipped_docs += 1
                continue

            info = data.get("nutrition_info")
            if not isinstance(info, dict):
                logger.debug(f"문서 {doc.id}: nutrition_info가 딕셔너리가 아님")
                skipped_docs += 1
                continue

            created_at_val = data.get("created_at")
            created_at_str_formatted = "날짜 정보 없음"
            
            if isinstance(created_at_val, str):
                try:
                    # ISO 형식 문자열 처리 (예: "2025-08-22T17:01:15.492790")
                    if created_at_val.endswith('Z'):
                        # UTC 시간인 경우
                        dt_object = datetime.fromisoformat(created_at_val.replace("Z", "+00:00"))
                    else:
                        # 로컬 시간인 경우
                        dt_object = datetime.fromisoformat(created_at_val)
                    
                    created_at_str_formatted = dt_object.strftime("%Y-%m-%d")
                    logger.debug(f"문서 {doc.id}: 문자열 날짜 파싱 성공 - {created_at_str_formatted}")
                except ValueError as e:
                    logger.warning(f"문서 {doc.id}: 날짜 파싱 실패 - {created_at_val}, 오류: {e}")
                    # 파싱 실패해도 계속 진행
                    created_at_str_formatted = "날짜 파싱 실패"
            elif isinstance(created_at_val, datetime):
                dt_object = (
                    created_at_val
                    if created_at_val.tzinfo
                    else created_at_val.replace(tzinfo=timezone.utc)
                )
                created_at_str_formatted = dt_object.strftime("%Y-%m-%d")
                logger.debug(f"문서 {doc.id}: datetime 객체 처리 성공 - {created_at_str_formatted}")
            else:
                logger.warning(f"문서 {doc.id}: 예상치 못한 created_at 타입 - {type(created_at_val)}, 값: {created_at_val}")
                created_at_str_formatted = "타입 오류"

            nutrition_details = [
                f"{key}: {round(value, 2)}"
                for key, value in info.items()
                if isinstance(value, (int, float))
            ]
            nutrition_str = ", ".join(nutrition_details)

            food_entry = (
                f"- 날짜: {created_at_str_formatted}, "
                f"칼로리: {data.get('calories', 'N/A')}kcal, "
                f"무게: {data.get('weight_g', 'N/A')}g, "
                f"영양정보: ({nutrition_str})"
            )
            food_data_list.append(food_entry)
            logger.debug(f"문서 {doc.id}: 음식 데이터 추가됨")

        logger.info(f"데이터 처리 완료: 총 {total_docs}개 문서, 처리됨 {len(food_data_list)}개, 스킵됨 {skipped_docs}개")

        if not food_data_list:
            logger.info("주간 음식 데이터가 없음 - 기본 응답 생성")
            return StructuredAnalysisResponse(
                avg_nutrients=["calories: 0 kcal", "protein: 0g", "fat: 0g", "carbohydrate: 0g"],
                pos_analysis="아직 데이터가 부족해요. 이번 주도 기록을 이어가 볼까요?",
                neg_analysis="데이터가 부족해 세부 분석이 어려워요.",
                feedback="하루 한 번만 기록해도 분석 품질이 좋아져요!",
                rec_meal=[],
                score=0,
            )

        weekly_data_str = "\n".join(food_data_list)
        logger.info(f"주간 데이터 문자열 길이: {len(weekly_data_str)}")
        logger.debug(f"주간 데이터 샘플: {weekly_data_str[:200]}...")
        
        encouragement_message = ""
        if len(food_data_list) < 4:
            encouragement_message = (
                "이번 주 식사 기록이 아직 많지 않네요! 꾸준한 기록은 더 정확한 분석에 큰 도움이 된답니다. "
                "앞으로 조금 더 자주 사진을 찍어서 식단을 채워보는 건 어떨까요? 화이팅! 💪"
            )

        prompt_file_path = os.path.join(os.path.dirname(__file__), "prompts", "prompt_analyze.txt")
        if not os.path.exists(prompt_file_path):
            raise HTTPException(status_code=500, detail="프롬프트 파일을 찾을 수 없습니다.")

        with open(prompt_file_path, "r", encoding="utf-8") as f:
            prompt_template = Template(f.read())

        full_prompt = prompt_template.substitute(
            weekly_data=weekly_data_str, encouragement_message=encouragement_message
        )

        logger.info(f"Gemini API 호출 시작 - 프롬프트 길이: {len(full_prompt)}")

        # New SDK: structured JSON via response_schema
        generate_config = types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=StructuredAnalysisResponse,  # Pydantic -> JSON schema 자동 변환
        )

        response = client.models.generate_content(
            model="gemini-2.5-flash-lite",
            contents=full_prompt,
            config=generate_config,
        )

        # The SDK guarantees JSON text for response_mime_type='application/json'
        analysis_data = json.loads(response.text)
        logger.info(f"Gemini API 응답 받음: {json.dumps(analysis_data, ensure_ascii=False, indent=2)}")

        # ---------- Backward-compat normalization ----------
        def _split_sentences(s: str):
            parts = [p.strip() for p in re.split(r'(?<=[.!?])\s+', s) if p.strip()]
            return parts

        if "pos_analysis" not in analysis_data or "neg_analysis" not in analysis_data:
            val = analysis_data.get("analysis")
            pos = analysis_data.get("pos_analysis", "").strip() if isinstance(analysis_data.get("pos_analysis"), str) else ""
            neg = analysis_data.get("neg_analysis", "").strip() if isinstance(analysis_data.get("neg_analysis"), str) else ""

            if isinstance(val, str):
                parts = _split_sentences(val)
                if len(parts) >= 2:
                    pos, neg = parts[0], parts[1]
                else:
                    cand = parts[0] if parts else val
                    neg = cand
                    pos = pos or "일부 식사에서 균형 잡힌 선택이 관찰됩니다."
            elif isinstance(val, list):
                only = [str(s).strip() for s in val if isinstance(s, str) and str(s).strip()]
                if len(only) >= 2:
                    pos, neg = only[0], only[1]
                elif len(only) == 1:
                    parts = _split_sentences(only[0])
                    if len(parts) >= 2:
                        pos, neg = parts[0], parts[1]
                    else:
                        neg = only[0]
                        pos = pos or "일부 식사에서 균형 잡힌 선택이 관찰됩니다."

            if not pos:
                pos = "일부 식사에서 균형 잡힌 선택이 관찰됩니다."
            if not neg:
                neg = "일부 영양소가 권장 범위를 벗어나 조정이 필요합니다."

            analysis_data["pos_analysis"] = pos
            analysis_data["neg_analysis"] = neg
            analysis_data.pop("analysis", None)

        if "score" not in analysis_data:
            analysis_data["score"] = 0  # safe default

        # avg_nutrients 처리 개선 - 빈 배열인 경우 기본값 제공
        if not isinstance(analysis_data.get("avg_nutrients"), list) or len(analysis_data.get("avg_nutrients", [])) == 0:
            logger.info("avg_nutrients가 비어있거나 잘못된 형식 - 기본값 설정")
            analysis_data["avg_nutrients"] = ["calories: 0 kcal", "protein: 0g", "fat: 0g", "carbohydrate: 0g"]
        
        logger.info(f"최종 분석 데이터: {json.dumps(analysis_data, ensure_ascii=False, indent=2)}")

        return StructuredAnalysisResponse(**analysis_data)

    except HTTPException as http_exc:
        raise http_exc
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"영양 분석 중 오류가 발생했습니다: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

# === Ping Test ===
# @app.get("/genai-ping")
# async def genai_ping():
#     try:
#         res = client.models.generate_content(
#             model="gemini-2.5-pro",
#             contents="Reply with the single word: pong",
#         )
#         return {"ok": True, "text": res.text}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"GenAI ping failed: {e}")
