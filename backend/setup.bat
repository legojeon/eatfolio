@echo off
echo 🍽️ Eatfolio Backend 설정을 시작합니다...

REM Python 가상환경 생성
echo 📦 Python 가상환경을 생성합니다...
python -m venv venv

REM 가상환경 활성화
echo 🔧 가상환경을 활성화합니다...
call venv\Scripts\activate.bat

REM pip 업그레이드
echo ⬆️ pip을 최신 버전으로 업그레이드합니다...
python -m pip install --upgrade pip

REM 의존성 설치
echo 📚 필요한 패키지들을 설치합니다...
pip install -r requirements.txt

echo ✅ 설정이 완료되었습니다!
echo.
echo 다음 단계:
echo 1. .env 파일을 생성하고 GOOGLE_API_KEY를 설정하세요
echo 2. 'venv\Scripts\activate.bat'로 가상환경을 활성화하세요
echo 3. 'python main.py'로 서버를 실행하세요
echo.
echo 또는 'python -m uvicorn main:app --reload'로 개발 모드로 실행할 수 있습니다.
pause 