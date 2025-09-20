class FilterOptions {
  final int? minStars; // 0~5
  final List<String>? categories; // ['한식','양식',...]
  final List<String>? mealTimes; // ['breakfast','lunch','dinner']

  const FilterOptions({this.minStars, this.categories, this.mealTimes});

  bool get hasAny =>
      (minStars != null && minStars! > 0) ||
      (categories?.isNotEmpty ?? false) ||
      (mealTimes?.isNotEmpty ?? false);
}
