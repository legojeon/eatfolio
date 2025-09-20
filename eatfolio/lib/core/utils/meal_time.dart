const Map<String, String> koToEn = {
  '아침': 'breakfast',
  '점심': 'lunch',
  '저녁': 'dinner',
  '야식': 'midnight snack',
};

const Map<String, String> enToKo = {
  'breakfast': '아침',
  'lunch': '점심',
  'dinner': '저녁',
  'midnight snack': '야식',
};

String toKoMealTime(String raw) => enToKo[raw.toLowerCase()] ?? raw;
