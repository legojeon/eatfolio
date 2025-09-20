#!/usr/bin/env python3
"""
환경변수를 실제 값으로 치환하는 스크립트
빌드 전에 실행하여 Firebase 설정 파일을 생성합니다.
"""

import os
import re
import sys
from pathlib import Path

def load_env_file(env_file):
    """환경변수 파일을 로드합니다."""
    env_vars = {}
    if os.path.exists(env_file):
        with open(env_file, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key] = value
    return env_vars

def replace_env_vars_in_file(file_path, env_vars):
    """파일에서 환경변수를 실제 값으로 치환합니다."""
    if not os.path.exists(file_path):
        print(f"⚠️  파일을 찾을 수 없습니다: {file_path}")
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # 환경변수 치환
        original_content = content
        for key, value in env_vars.items():
            placeholder = f"${{{key}}}"
            if placeholder in content:
                content = content.replace(placeholder, value)
                print(f"✅ {key} = {value[:20]}...")
        
        # 변경사항이 있으면 파일에 저장
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ 파일 업데이트 완료: {file_path}")
            return True
        else:
            print(f"ℹ️  변경사항 없음: {file_path}")
            return True
            
    except Exception as e:
        print(f"❌ 오류 발생: {file_path} - {e}")
        return False

def main():
    """메인 함수"""
    print("🚀 Firebase 설정 파일 환경변수 치환 시작...")
    
    # 프로젝트 루트 디렉토리
    project_root = Path(__file__).parent.parent
    env_file = project_root / ".env"
    
    # 환경변수 로드
    print(f"📁 환경변수 파일 로드: {env_file}")
    env_vars = load_env_file(env_file)
    
    if not env_vars:
        print("❌ 환경변수를 찾을 수 없습니다. .env 파일을 확인하세요.")
        sys.exit(1)
    
    print(f"✅ {len(env_vars)}개의 환경변수 로드 완료")
    
    # 치환할 파일들
    files_to_replace = [
        project_root / "android" / "app" / "google-services.json",
        project_root / "ios" / "Runner" / "GoogleService-Info.plist",
    ]
    
    success_count = 0
    for file_path in files_to_replace:
        print(f"\n📝 처리 중: {file_path.name}")
        if replace_env_vars_in_file(file_path, env_vars):
            success_count += 1
    
    print(f"\n🎉 완료! {success_count}/{len(files_to_replace)} 파일 처리 성공")
    
    if success_count == len(files_to_replace):
        print("✅ 모든 Firebase 설정 파일이 환경변수로 업데이트되었습니다.")
        print("🚀 이제 Flutter 앱을 빌드할 수 있습니다!")
    else:
        print("⚠️  일부 파일 처리에 실패했습니다. 오류를 확인하세요.")
        sys.exit(1)

if __name__ == "__main__":
    main()
