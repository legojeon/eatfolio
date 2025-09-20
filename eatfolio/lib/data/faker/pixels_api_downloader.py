# pexels_api_downloader.py
# pip install requests tqdm python-dotenv

import os
import requests
from tqdm import tqdm
from dotenv import load_dotenv
import subprocess

# .env 파일 로드
load_dotenv()

# API 키 설정 (.env에서 불러오기)
API_KEY = os.getenv('PIXELS_API_KEY')
if not API_KEY:
    raise ValueError("PIXELS_API_KEY가 .env 파일에 설정되지 않았습니다.")
QUERY = "food"     # 검색 키워드
MAX_IMAGES = 100
OUT_DIR = "fake_images"  # 로컬에서 이미지 다운로드

def search_images(query, per_page=80, page=1):
    """Pexels API를 사용해 이미지 URL 목록 가져오기"""
    url = "https://api.pexels.com/v1/search"
    headers = {"Authorization": API_KEY}
    params = {"query": query, "per_page": per_page, "page": page}
    r = requests.get(url, headers=headers, params=params)
    r.raise_for_status()
    data = r.json()
    return [photo["src"]["original"] for photo in data.get("photos", [])]

def download_image(url, filename):
    """이미지 다운로드"""
    r = requests.get(url, stream=True, timeout=15)
    r.raise_for_status()
    with open(filename, "wb") as f:
        for chunk in r.iter_content(8192):
            if chunk:
                f.write(chunk)

def push_to_emulator():
    """로컬 이미지를 에뮬레이터로 푸시"""
    print("📱 에뮬레이터로 이미지 전송 중...")
    try:
        # ADB 디바이스 확인
        result = subprocess.run(['adb', 'devices'], capture_output=True, text=True, check=True)
        if 'emulator' not in result.stdout:
            print("❌ 에뮬레이터가 실행되지 않았습니다. 에뮬레이터를 먼저 실행하세요.")
            return False
        
        # 이미지를 에뮬레이터로 전송 (폴더가 아닌 개별 파일들)
        print("📁 에뮬레이터로 이미지 전송 중...")
        for i in range(100):
            local_file = f'fake_images/fake_{i}.jpg'
            if os.path.exists(local_file):
                try:
                    subprocess.run([
                        'adb', 'push', local_file, 
                        '/storage/emulated/0/Android/data/com.example.eatfolio/files/'
                    ], check=True, capture_output=True)
                except subprocess.CalledProcessError:
                    print(f"⚠️ fake_{i}.jpg 전송 실패")
        
        # 파일 권한 설정 (개별 파일에 대해)
        print("🔐 파일 권한 설정 중...")
        for i in range(100):
            try:
                subprocess.run([
                    'adb', 'shell', 'chmod', '644', 
                    f'/storage/emulated/0/Android/data/com.example.eatfolio/files/fake_{i}.jpg'
                ], check=True, capture_output=True)
            except subprocess.CalledProcessError:
                # 일부 파일이 없을 수 있으므로 무시
                pass
        
        print("✅ 에뮬레이터로 이미지 전송 완료!")
        print("📁 저장 경로: /storage/emulated/0/Android/data/com.example.eatfolio/files/")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ 에뮬레이터 전송 실패: {e}")
        print("💡 해결 방법:")
        print("   1. Android 에뮬레이터가 실행 중인지 확인")
        print("   2. ADB가 설치되어 있는지 확인")
        print("   3. 에뮬레이터에 쓰기 권한이 있는지 확인")
        return False
    except FileNotFoundError:
        print("❌ ADB가 설치되지 않았습니다.")
        print("💡 Android SDK Platform Tools를 설치하세요.")
        return False

def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    urls = []
    page = 1

    # API를 페이지 단위로 요청하여 URL 수집
    while len(urls) < MAX_IMAGES:
        batch = search_images(QUERY, per_page=80, page=page)
        if not batch:
            break
        urls.extend(batch)
        page += 1

    urls = urls[:MAX_IMAGES]  # 정확히 100장만 사용

    print(f"총 {len(urls)}개의 이미지 URL 수집 완료. 다운로드 시작...")
    for i, url in enumerate(tqdm(urls, desc="Downloading")):
        filename = os.path.join(OUT_DIR, f"fake_{i}.jpg")
        try:
            download_image(url, filename)
        except Exception as e:
            print(f"[오류] {filename}: {e}")

    print(f"다운로드 완료! 저장 경로: {OUT_DIR}")
    
    # 에뮬레이터로 이미지 전송 시도
    print("\n🚀 에뮬레이터 전송을 시도합니다...")
    push_to_emulator()

if __name__ == "__main__":
    main()
