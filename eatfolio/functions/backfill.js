// 이 스크립트는 Cloud Function이 아닙니다.
// 로컬 컴퓨터에서 node 명령어로 직접 실행하여
// 기존 Photos 데이터를 기반으로 user_stats를 생성하는 일회성 스크립트입니다.

// 1. Firebase Admin SDK 가져오기
const admin = require("firebase-admin");

// 2. 서비스 계정 키 파일 설정
// Firebase 콘솔에서 다운로드한 서비스 계정 키 파일의 경로를 입력하세요.
// 이 스크립트 파일과 같은 위치에 키 파일을 두는 것이 편리합니다.
const serviceAccount = require("./eatfolio-a4334-firebase-adminsdk-fbsvc-ec63b8d583.json"); // 👈 본인의 키 파일명으로 변경하세요!

// 3. Firebase Admin 앱 초기화
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue; // FieldValue를 사용하기 쉽게 변수로 선언

// --- 상수 정의 (Cloud Function과 동일하게 유지) ---
const SODIUM_PER_RAMEN_MG = 1800;
const PROTEIN_PER_EGG_G = 6;

async function backfillUserStats() {
  console.log("기존 Photo 데이터로 통계 백필을 시작합니다...");

  const allUserStats = {}; // 모든 유저의 통계를 임시 저장할 객체

  // 4. Photos 컬렉션의 모든 문서 가져오기
  const photosSnapshot = await db.collection("Photos").get();

  if (photosSnapshot.empty) {
    console.log("Photos 컬렉션에 데이터가 없습니다. 스크립트를 종료합니다.");
    return;
  }

  console.log(`${photosSnapshot.size}개의 Photo 문서를 처리합니다.`);

  // 5. 각 문서를 순회하며 사용자별로 데이터 누적
  photosSnapshot.forEach(doc => {
    const photoData = doc.data();
    const userId = photoData.user_id;

    if (!userId) return; // user_id가 없는 데이터는 건너뛰기

    // 해당 유저의 통계 객체가 없으면 초기화
    if (!allUserStats[userId]) {
      allUserStats[userId] = {
        user_id: userId,
        meal_time_stats: {
            breakfast: { total_minutes: 0, count: 0 },
            lunch: { total_minutes: 0, count: 0 },
            dinner: { total_minutes: 0, count: 0 },
        },
        total_calories: 0,
        meal_count: 0,
        total_weight_g: 0,
        macros_total_g: { carbohydrate: 0, protein: 0, fat: 0 },
        sodium_total_mg: 0,
      };
    }

    const stats = allUserStats[userId];

    // 값 누적
    stats.meal_count += 1;
    stats.total_calories += photoData.calories || 0;
    stats.total_weight_g += photoData.weight_g || 0;

    if (photoData.nutrition_info) {
        stats.macros_total_g.carbohydrate += photoData.nutrition_info.carbohydrate || 0;
        stats.macros_total_g.protein += photoData.nutrition_info.protein || 0;
        stats.macros_total_g.fat += photoData.nutrition_info.fat || 0;
        stats.sodium_total_mg += photoData.nutrition_info.sodium || 0;
    }

    // 평균 식사 시간 계산을 위한 데이터 누적
    const mealType = photoData.meal_time;
    if (mealType && stats.meal_time_stats[mealType] && photoData.created_at) {
        const createdAtDate = new Date(photoData.created_at);
        const hours = createdAtDate.getUTCHours();
        const minutes = createdAtDate.getUTCMinutes();
        stats.meal_time_stats[mealType].total_minutes += (hours * 60 + minutes);
        stats.meal_time_stats[mealType].count += 1;
    }
  });

  console.log("모든 데이터 누적 완료. 최종 통계 계산 및 저장을 시작합니다...");

  // 6. 누적된 데이터를 기반으로 최종 통계 계산 및 Firestore에 저장
  const promises = Object.keys(allUserStats).map(async (userId) => {
    const stats = allUserStats[userId];

    // 최종 계산 (평균, 비율 등)
    stats.protein_total_g = stats.macros_total_g.protein;
    stats.avg_calories = stats.total_calories / stats.meal_count;
    stats.sodium_ramen_equiv = stats.sodium_total_mg / SODIUM_PER_RAMEN_MG;
    stats.protein_egg_equiv = stats.protein_total_g / PROTEIN_PER_EGG_G;

    // 탄단지 비율
    const { carbohydrate, protein, fat } = stats.macros_total_g;
    const intCarb = Math.round(carbohydrate);
    const intProtein = Math.round(protein);
    const intFat = Math.round(fat);
    if (intCarb > 0 || intProtein > 0 || intFat > 0) {
        const values = [intCarb, intProtein, intFat];
        const minValue = Math.min(...values.filter(v => v > 0));
        if (minValue > 0) {
            stats.macro_ratio_string = `${(intCarb / minValue).toFixed(1)}:${(intProtein / minValue).toFixed(1)}:${(intFat / minValue).toFixed(1)}`;
        } else {
            stats.macro_ratio_string = `${intCarb}:${intProtein}:${intFat}`;
        }
    } else {
        stats.macro_ratio_string = "0:0:0";
    }

    // 평균 식사 시간
    stats.avg_meal_time = {};
    for (const mealType of ['breakfast', 'lunch', 'dinner']) {
        const timeStats = stats.meal_time_stats[mealType];
        if (timeStats.count > 0) {
            const avgMinutes = timeStats.total_minutes / timeStats.count;
            const avgHours = Math.floor(avgMinutes / 60);
            const avgMinutePart = Math.round(avgMinutes % 60);
            stats.avg_meal_time[mealType] = `${String(avgHours).padStart(2, '0')}:${String(avgMinutePart).padStart(2, '0')}`;
        } else {
            stats.avg_meal_time[mealType] = "N/A";
        }
    }
    
    // ✨ 수정된 부분: admin.firestore.FieldValue.serverTimestamp() 사용
    stats.updated_at = FieldValue.serverTimestamp();

    // Firestore에 저장
    await db.collection("user_stats").doc(userId).set(stats);
    console.log(`${userId}의 통계 생성을 완료했습니다.`);
  });

  await Promise.all(promises);
  console.log("백필 작업이 모두 완료되었습니다!");
}

// 스크립트 실행
backfillUserStats().catch(console.error);
