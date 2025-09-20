// upload.js
import admin from 'firebase-admin';
import fs from 'fs';
import dotenv from 'dotenv';
import path from 'path';

// 루트 폴더의 .env 파일 로드
const rootDir = path.resolve('../../..');
dotenv.config({ path: path.join(rootDir, '.env') });

// Firebase Admin SDK 초기화
// .env 파일에서 Firebase 키 정보를 가져옵니다
const serviceAccount = {
  type: 'service_account',
  project_id: process.env.FIREBASE_PROJECT_ID,
  private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
  private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  client_id: process.env.FIREBASE_CLIENT_ID,
  auth_uri: 'https://accounts.google.com/o/oauth2/auth',
  token_uri: 'https://oauth2.googleapis.com/token',
  auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
  client_x509_cert_url: process.env.FIREBASE_CLIENT_X509_CERT_URL,
};

// 필수 환경변수 확인
if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_PRIVATE_KEY || !process.env.FIREBASE_CLIENT_EMAIL) {
  console.error('❌ .env 파일에 Firebase 키 정보가 누락되었습니다.');
  console.log('💡 루트 폴더의 .env 파일에 다음 정보를 추가하세요:');
  console.log('   FIREBASE_PRIVATE_KEY_ID=your-private-key-id');
  console.log('   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"');
  console.log('   FIREBASE_CLIENT_EMAIL=your-client-email');
  console.log('   FIREBASE_CLIENT_ID=your-client-id');
  console.log('   FIREBASE_CLIENT_X509_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/...');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const collectionRef = db.collection('Photos'); // 'Photos' 컬렉션에 저장 (register_page.dart와 동일)

/**
 * generate.js로 생성된 가짜 식사 데이터를 Firestore에 업로드합니다.
 */
async function uploadMealData() {
  console.log('🍽️ 가짜 식사 데이터 업로드를 시작합니다...');

  try {
    // fake-meal-data.json 파일 읽기
    const fakeData = JSON.parse(fs.readFileSync('./fake-meal-data.json', 'utf8'));
    console.log(`📊 총 ${fakeData.length}개의 데이터를 업로드합니다.`);

    let successCount = 0;
    let errorCount = 0;

    for (const mealData of fakeData) {
      try {
        // record_id를 문서 ID로 사용 (register_page.dart와 동일한 방식)
        await collectionRef.doc(mealData.record_id).set(mealData);
        successCount++;
        console.log(`✅ ${mealData.record_id} 업로드 완료`);
      } catch (error) {
        errorCount++;
        console.error(`❌ ${mealData.record_id} 업로드 실패:`, error.message);
      }
    }

    console.log('\n🎉 업로드 완료!');
    console.log(`✅ 성공: ${successCount}개`);
    console.log(`❌ 실패: ${errorCount}개`);
    console.log(`📁 Firestore 컬렉션: Photos`);
    console.log(`👤 사용자 ID: ${fakeData[0]?.user_id || 'N/A'}`);

  } catch (error) {
    console.error('❌ 파일 읽기 실패:', error.message);
    console.log('💡 먼저 generate.js를 실행하여 fake-meal-data.json 파일을 생성하세요.');
  }
}

// 실행
uploadMealData();