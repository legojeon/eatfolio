// generate.js
import { faker } from '@faker-js/faker/locale/ko'; // 한글 데이터를 위해 'ko' 로케일 사용
import fs from 'fs';

/**
 * 지정된 개수만큼 가짜 식사 데이터를 생성합니다.
 * 하루에 최대 3개씩만 생성되며, 항상 정확한 개수를 생성합니다.
 * @param {number} count - 생성할 데이터의 개수
 * @returns {Array} - 생성된 식사 데이터 배열
 */
function generateMealData(count) {
  const mealData = [];

  // 날짜 범위 설정 (2025년 7월 1일 ~ 8월 10일)
  const startDate = new Date('2025-07-01T00:00:00.000Z');
  const endDate = new Date('2025-08-10T23:59:59.999Z');

  // 사용 가능한 날짜들을 미리 계산
  const availableDates = [];
  const currentDate = new Date(startDate);
  while (currentDate <= endDate) {
    availableDates.push(new Date(currentDate));
    currentDate.setDate(currentDate.getDate() + 1);
  }
  
  // 날짜별로 생성된 데이터 개수를 추적하는 Map
  const dateCounts = new Map();
  let imageIndex = 0;

  // ✨ FIX: 목표 개수(count)에 도달할 때까지 데이터를 생성하는 방식으로 변경
  while (mealData.length < count) {
    // 사용 가능한 전체 날짜 중에서 무작위로 하나를 선택
    const randomDateIndex = Math.floor(Math.random() * availableDates.length);
    const selectedDate = availableDates[randomDateIndex];
    const dateKey = selectedDate.toISOString().split('T')[0];

    // 해당 날짜에 이미 생성된 데이터 개수를 가져옴 (없으면 0)
    const currentDailyCount = dateCounts.get(dateKey) || 0;

    // 하루 최대 3개 제한을 확인
    if (currentDailyCount < 3) {
      // 해당 날짜의 카운트를 1 증가시킴
      dateCounts.set(dateKey, currentDailyCount + 1);

      // --- 데이터 생성 로직 ---
      const date = new Date(dateKey);
      const hour = faker.number.int({ min: 6, max: 21 });
      const minute = faker.number.int({ min: 0, max: 59 });
      date.setUTCHours(hour, minute, 0, 0);

      let mealTime;
      if (hour >= 6 && hour < 11) {
        mealTime = 'breakfast';
      } else if (hour >= 11 && hour < 16) {
        mealTime = 'lunch';
      } else if (hour >= 16 && hour < 22) { // 21시 포함
        mealTime = 'dinner';
      } else {
        mealTime = 'midnight snack';
      }

      // const analyze = faker.datatype.boolean();
      const analyze = true;
      const meal = {
        record_id: faker.string.alphanumeric(20),
        user_id: 'LPK07O0YrBhpvU1lZ0MUWBxq5g62',
        rating: faker.number.int({ min: 1, max: 5 }),
        memo: faker.lorem.sentence(),
        image_path: `/storage/emulated/0/Android/data/com.example.eatfolio/files/fake_${imageIndex}.jpg`,
        created_at: date.toISOString(),
        analyze: analyze,
        food_category: faker.helpers.arrayElement(['중식', '양식', '한식', '일식']),
        food_name: faker.commerce.productName(),
        location: {
          latitude: faker.location.latitude({ min: 37.0, max: 38.0 }),
          longitude: faker.location.longitude({ min: 126.0, max: 127.0 }),
        },
        meal_time: mealTime,
        calories: analyze ? faker.number.int({ min: 200, max: 1200 }) : null,
        weight_g: analyze ? faker.number.int({ min: 50, max: 500 }) : null,        // 중량 (g)
        nutrition_info: analyze ? {
          carbohydrate: faker.number.int({ min: 20, max: 150 }),    // Carbohydrate (g)
          sugars: faker.number.int({ min: 0, max: 50 }),            // Sugars (g)
          fat: faker.number.int({ min: 5, max: 80 }),               // Total Fat (g)
          protein: faker.number.int({ min: 10, max: 100 }),         // Protein (g)
          calcium: faker.number.int({ min: 10, max: 1000 }),        // Calcium (mg)
          phosphorus: faker.number.int({ min: 10, max: 1000 }),     // Phosphorus (mg)
          sodium: faker.number.int({ min: 10, max: 2000 }),         // Sodium (mg)
          potassium: faker.number.int({ min: 10, max: 2000 }),      // Potassium (mg)
          magnesium: faker.number.int({ min: 5, max: 500 }),        // Magnesium (mg)
          iron: faker.number.int({ min: 1, max: 50 }),              // Iron (mg)
          zinc: faker.number.int({ min: 1, max: 30 }),              // Zinc (mg)
          cholesterol: faker.number.int({ min: 0, max: 300 }),      // Cholesterol (mg)
          trans_fat: faker.number.float({ min: 0, max: 5, precision: 0.1 }), // Trans Fat (g)
        } : null,
      };

      mealData.push(meal);
      imageIndex++;
    }
    // 만약 선택된 날짜가 3개로 꽉 찼다면, 루프의 다음 시도에서 다른 날짜가 선택될 것입니다.
    // 날짜 범위(41일 * 3 = 123 슬롯)가 목표(100개)보다 넓어서 무한 루프 걱정은 없습니다.
  }

  return mealData;
}

// 정확히 100개의 식사 데이터를 생성합니다.
const fakeMealData = generateMealData(100);

// 생성된 데이터를 JSON 파일로 보기 좋게 저장합니다.
fs.writeFileSync('fake-meal-data.json', JSON.stringify(fakeMealData, null, 2));

// 통계 정보 출력
const dailyStats = new Map();
fakeMealData.forEach(meal => {
  const dateKey = meal.created_at.split('T')[0];
  dailyStats.set(dateKey, (dailyStats.get(dateKey) || 0) + 1);
});

console.log('\n✅ 가짜 식사 데이터가 fake-meal-data.json 파일로 생성되었습니다!');
console.log(`📊 총 ${fakeMealData.length}개의 데이터 생성 완료`);

// 날짜별 통계 출력
console.log('\n📈 최종 날짜별 데이터 분포:');
const sortedDates = Array.from(dailyStats.keys()).sort();
sortedDates.forEach(date => {
  const count = dailyStats.get(date);
  console.log(`  ${date}: ${count}개`);
});

// 3개 초과 데이터가 있는지 확인
const overLimitDates = Array.from(dailyStats.entries()).filter(([date, count]) => count > 3);
if (overLimitDates.length > 0) {
  console.log('\n❌ 3개 초과 데이터가 있는 날짜:');
  overLimitDates.forEach(([date, count]) => {
    console.log(`  ${date}: ${count}개`);
  });
  console.log('🚨 이는 예상치 못한 오류입니다. 코드를 다시 확인해주세요.');
} else {
  console.log('\n✅ 모든 날짜가 3개 이내로 제한되었습니다!');
}

// 최대 개수 확인
const maxCount = Math.max(0, ...Array.from(dailyStats.values()));
console.log(`\n🏆 하루 최대 데이터 개수: ${maxCount}개`);

if (maxCount <= 3 && fakeMealData.length === 100) {
  console.log('✅ 계획이 성공적으로 실행되었습니다! (정확히 100개, 하루 최대 3개)');
} else {
  console.log('❌ 계획 실행에 실패했습니다!');
}
