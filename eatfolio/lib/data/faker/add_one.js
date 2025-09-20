// add_one.js
import { faker } from '@faker-js/faker/locale/ko'; // 한글 데이터를 위해 'ko' 로케일 사용
import admin from 'firebase-admin';
import dotenv from 'dotenv';
import path from 'path';

// 루트 폴더의 .env 파일 로드
const rootDir = path.resolve('../../..');
dotenv.config({ path: path.join(rootDir, '.env') });

// Firebase Admin SDK 초기화
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
const collectionRef = db.collection('Photos');

/**
 * 현재 시간으로 식사 데이터 하나를 생성합니다.
 * @returns {Object} - 생성된 식사 데이터
 */
function generateCurrentMealData() {
  // 현재 시간 가져오기
  const now = new Date();
  const hour = now.getHours();
  const minute = now.getMinutes();
  
  // 식사 시간 판단
  let mealTime;
  if (hour >= 6 && hour < 11) {
    mealTime = 'breakfast';
  } else if (hour >= 11 && hour < 16) {
    mealTime = 'lunch';
  } else if (hour >= 16 && hour < 22) {
    mealTime = 'dinner';
  } else {
    mealTime = 'midnight snack';
  }

  // 이미지 인덱스는 현재 시간 기반으로 생성 (중복 방지)
  const imageIndex = 102

  const meal = {
    record_id: faker.string.alphanumeric(20),
    user_id: 'LPK07O0YrBhpvU1lZ0MUWBxq5g62',
    rating: faker.number.int({ min: 1, max: 5 }),
    memo: faker.lorem.sentence(),
    image_path: `/storage/emulated/0/Android/data/com.example.eatfolio/files/fake_${imageIndex}.jpg`,
    created_at: now.toISOString(),
    analyze: true,
    food_category: faker.helpers.arrayElement(['중식', '양식', '한식', '일식']),
    food_name: faker.commerce.productName(),
    location: {
      latitude: faker.location.latitude({ min: 37.0, max: 38.0 }),
      longitude: faker.location.longitude({ min: 126.0, max: 127.0 }),
    },
    meal_time: mealTime,
    calories: faker.number.int({ min: 200, max: 1200 }),
    weight_g: faker.number.int({ min: 50, max: 500 }),
    nutrition_info: {
      carbohydrate: faker.number.int({ min: 20, max: 150 }),
      sugars: faker.number.int({ min: 0, max: 50 }),
      fat: faker.number.int({ min: 5, max: 80 }),
      protein: faker.number.int({ min: 10, max: 100 }),
      calcium: faker.number.int({ min: 10, max: 1000 }),
      phosphorus: faker.number.int({ min: 10, max: 1000 }),
      sodium: faker.number.int({ min: 10, max: 2000 }),
      potassium: faker.number.int({ min: 10, max: 2000 }),
      magnesium: faker.number.int({ min: 5, max: 500 }),
      iron: faker.number.int({ min: 1, max: 50 }),
      zinc: faker.number.int({ min: 1, max: 30 }),
      cholesterol: faker.number.int({ min: 0, max: 300 }),
      trans_fat: faker.number.float({ min: 0, max: 5, precision: 0.1 }),
    },
  };

  return meal;
}

/**
 * 생성된 식사 데이터를 Firestore에 업로드합니다.
 * @param {Object} mealData - 업로드할 식사 데이터
 */
async function uploadMealData(mealData) {
  console.log('🍽️ 식사 데이터 업로드를 시작합니다...');
  console.log(`📅 생성 시간: ${mealData.created_at}`);
  console.log(`🍴 식사 시간: ${mealData.meal_time}`);
  console.log(`🍜 음식: ${mealData.food_name} (${mealData.food_category})`);

  try {
    // record_id를 문서 ID로 사용
    await collectionRef.doc(mealData.record_id).set(mealData);
    console.log('✅ 업로드 완료!');
    console.log(`📁 Firestore 컬렉션: Photos`);
    console.log(`🆔 문서 ID: ${mealData.record_id}`);
    console.log(`👤 사용자 ID: ${mealData.user_id}`);

  } catch (error) {
    console.error('❌ 업로드 실패:', error.message);
  }
}

/**
 * 메인 실행 함수
 */
async function main() {
  try {
    // 현재 시간으로 식사 데이터 생성
    const mealData = generateCurrentMealData();
    console.log('🎯 현재 시간으로 식사 데이터를 생성했습니다.');
    
    // Firestore에 업로드
    await uploadMealData(mealData);
    
  } catch (error) {
    console.error('❌ 실행 중 오류 발생:', error.message);
  } finally {
    // Firebase 연결 종료
    await admin.app().delete();
    process.exit(0);
  }
}

// 실행
main(); 