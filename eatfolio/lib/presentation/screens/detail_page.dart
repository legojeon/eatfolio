import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatfolio/presentation/widgets/cards.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/fonts.dart';
import '../widgets/buttons.dart' show StarRatingButton;

class DetailPage extends StatelessWidget {
  final String recordId;

  const DetailPage({super.key, required this.recordId});

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance
        .collection('Photos')
        .doc(recordId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: docRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return _ErrorState(onBack: () => Navigator.pop(context));
          }

          final data = snap.data!.data() ?? {};

          // image
          final imageUrl = _firstNonEmpty([
            data['image_url'],
            data['photo_url'],
          ]);
          final imagePath = _firstNonEmpty([
            data['image_path'],
            data['local_path'],
          ]);

          // fields
          final foodName =
              _firstNonEmpty([
                data['food_name'],
                data['name'],
                data['title'],
              ]) ??
              '-';
          final foodCategory =
              _firstNonEmpty([data['food_category'], data['category']]) ?? '-';

          final mealTime = _prettyMealTime(
            _firstNonEmpty([data['meal_time'], data['mealTime']]) ?? '-',
          );

          // location (top-level or nested in 'location')
          final locMap = data['location'] as Map<String, dynamic>?;
          final latitude = _parseDouble(
            data['latitude'] ?? locMap?['latitude'] ?? locMap?['lat'],
          );
          final longitude = _parseDouble(
            data['longitude'] ?? locMap?['longitude'] ?? locMap?['lng'],
          );

          // latitude on first line, longitude on second line
          final locationText = (latitude != null && longitude != null)
              ? '${latitude.toStringAsFixed(5)}\n${longitude.toStringAsFixed(5)}'
              : '-';

          final ratingVal = _parseInt(data['rating']);

          final memo =
              _firstNonEmpty([
                data['memo'],
                data['note'],
                data['notes'],
                data['description'],
              ]) ??
              '-';

          // analyze/nutrition
          final analyze = data['analyze'] == true;
          final calories = data['calories']?.toString();
          final nutrition =
              (data['nutrition_info'] as Map<String, dynamic>?) ?? {};
          final carbohydrate = nutrition['carbohydrate']?.toString();
          final fat = nutrition['fat']?.toString();
          final protein = nutrition['protein']?.toString();

          // 추가 영양소 정보
          final sugars = nutrition['sugars']?.toString();
          final calcium = nutrition['calcium']?.toString();
          final phosphorus = nutrition['phosphorus']?.toString();
          final sodium = nutrition['sodium']?.toString();
          final potassium = nutrition['potassium']?.toString();
          final magnesium = nutrition['magnesium']?.toString();
          final iron = nutrition['iron']?.toString();
          final zinc = nutrition['zinc']?.toString();
          final cholesterol = nutrition['cholesterol']?.toString();
          final transFat = nutrition['trans_fat']?.toString();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 320,
                elevation: 0,
                backgroundColor: const Color(0xFFF7F7F9),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _HeaderImage(
                    imageUrl: imageUrl,
                    imagePath: imagePath,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + subtitle
                      _HeaderCard(
                        title: foodName,
                        foodType: foodCategory,
                        mealTime: mealTime,
                      ),
                      const SizedBox(height: 12),

                      // Meal details (Meal time + Location)
                      _InfoCard(
                        title: 'Meal details',
                        child: Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                label: 'Time',
                                value: _formatCreatedAt(data['created_at']),
                                icon: Icons.schedule,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _MiniStat(
                                label: 'Location',
                                value: locationText,
                                icon: Icons.place_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Rating (centered)
                      _InfoCard(
                        title: 'Rating',
                        child: Center(
                          child: IgnorePointer(
                            ignoring: true,
                            child: StarRatingButton(
                              rating: ratingVal,
                              onRatingChanged: (_) {},
                              size: 42,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Memo
                      _InfoCard(
                        title: 'Memo',
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            memo,
                            style: AppFonts.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nutrition or Analyzing block
                      analyze
                          ? _InfoCard(
                              title: 'Nutrition',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calories: ${calories ?? '-'} kcal',
                                    style: AppFonts.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _MacroCard(
                                          label: 'Carbs',
                                          value: carbohydrate ?? '-',
                                          unit: 'g',
                                          icon: Icons.rice_bowl,
                                          iconColor: const Color(
                                            0xFF4CAF50,
                                          ), // 녹색
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _MacroCard(
                                          label: 'Protein',
                                          value: protein ?? '-',
                                          unit: 'g',
                                          icon: Icons.fitness_center,
                                          iconColor: const Color(
                                            0xFFF44336,
                                          ), // 빨간색
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _MacroCard(
                                          label: 'Fat',
                                          value: fat ?? '-',
                                          unit: 'g',
                                          icon: Icons.local_pizza,
                                          iconColor: const Color(
                                            0xFFFFC107,
                                          ), // 노란색
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // 추가 영양소 정보
                                  _AdditionalNutritionCard(
                                    sugars: sugars,
                                    calcium: calcium,
                                    phosphorus: phosphorus,
                                    sodium: sodium,
                                    potassium: potassium,
                                    magnesium: magnesium,
                                    iron: iron,
                                    zinc: zinc,
                                    cholesterol: cholesterol,
                                    transFat: transFat,
                                  ),
                                ],
                              ),
                            )
                          : _InfoCard(
                              title: 'Analyzing…',
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Your meal is being analyzed. Results will appear soon.',
                                      style: AppFonts.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------- helpers ----------

  static String? _firstNonEmpty(List<dynamic> opts) {
    for (final v in opts) {
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static String _prettyMealTime(String raw) {
    final s = raw.trim();
    if (s.isEmpty || s == '-') return '-';
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v.clamp(0, 5);
    if (v is double) return v.round().clamp(0, 5);
    final n = int.tryParse(v.toString()) ?? 0;
    return n.clamp(0, 5);
  }
}

String _formatCreatedAt(dynamic v) {
  if (v == null) return '-';
  try {
    final dt = DateTime.tryParse(v.toString());
    if (dt == null) return '-';
    final date =
        '${dt.year % 100}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date\n$time';
  } catch (_) {
    return v.toString();
  }
}

// ===================================================================
// ========================= UI SUBWIDGETS ===========================
// ===================================================================

class _HeaderImage extends StatelessWidget {
  final String? imageUrl;
  final String? imagePath;

  const _HeaderImage({required this.imageUrl, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final img = _buildImage();
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: img,
        ),
        // gradient overlay for readability
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black26, Colors.black38],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return Image.network(imageUrl!, fit: BoxFit.cover);
    }
    if (imagePath != null && File(imagePath!).existsSync()) {
      return Image.file(File(imagePath!), fit: BoxFit.cover);
    }
    return const ColoredBox(
      color: Color(0xFFEAEAEA),
      child: Center(child: Icon(Icons.image, size: 72, color: Colors.grey)),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String foodType;
  final String mealTime;

  const _HeaderCard({
    required this.title,
    required this.foodType,
    required this.mealTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.heading2),
          const SizedBox(height: 10),
          Row(
            children: [
              PillLabel(text: foodType),
              const SizedBox(width: 8),
              PillLabel(text: mealTime),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.caption),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // keep row balanced
        children: [
          // ⬇️ Icon always centered vertically
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.borderLight, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),

          // ⬇️ Text stays multiline (top-aligned within its column)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // wrap content
              children: [
                Text(label, style: AppFonts.caption),
                const SizedBox(height: 6),
                Text(
                  value,
                  textAlign: TextAlign.left,
                  style: AppFonts.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final dynamic value; // num or String or null
  final String unit;
  final IconData icon;
  final Color iconColor;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final String valueText = _formatValue(value, unit);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          // Value
          Text(
            valueText,
            style: AppFonts.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          // Label
          Text(label, style: AppFonts.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  static String _formatValue(dynamic v, String unit) {
    if (v == null) return '-$unit';
    if (v is num) return '${v.toStringAsFixed(0)}$unit';
    final parsed = num.tryParse(v.toString());
    if (parsed != null) return '${parsed.toStringAsFixed(0)}$unit';
    return '$v$unit';
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(height: 6),
          Text(
            '$value$unit',
            style: AppFonts.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppFonts.caption.copyWith(
              color: AppColors.textSecondary,
            ), // 회색으로 변경
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AdditionalNutritionCard extends StatelessWidget {
  final String? sugars;
  final String? calcium;
  final String? phosphorus;
  final String? sodium;
  final String? potassium;
  final String? magnesium;
  final String? iron;
  final String? zinc;
  final String? cholesterol;
  final String? transFat;

  const _AdditionalNutritionCard({
    this.sugars,
    this.calcium,
    this.phosphorus,
    this.sodium,
    this.potassium,
    this.magnesium,
    this.iron,
    this.zinc,
    this.cholesterol,
    this.transFat,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Additional Nutrition',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 첫 번째 행: Sugars, Calcium, Phosphorus
          Row(
            children: [
              Expanded(
                child: _NutritionCard(
                  label: 'Sugars',
                  value: sugars ?? '-',
                  unit: 'g',
                  icon: Icons.cake, // 당류를 나타내는 케이크 아이콘
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NutritionCard(
                  label: 'Calcium',
                  value: calcium ?? '-',
                  unit: 'mg',
                  icon: Icons.local_drink, // 우유/유제품을 나타내는 아이콘
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NutritionCard(
                  label: 'Phosphorus',
                  value: phosphorus ?? '-',
                  unit: 'mg',
                  icon: Icons.wb_sunny, // 에너지/광합성을 나타내는 태양 아이콘
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 두 번째 행: Sodium, Potassium, Magnesium
          Row(
            children: [
              Expanded(
                child: _NutritionCard(
                  label: 'Sodium',
                  value: sodium ?? '-',
                  unit: 'mg',
                  icon: Icons.restaurant, // 소금/음식을 나타내는 식당 아이콘
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NutritionCard(
                  label: 'Potassium',
                  value: potassium ?? '-',
                  unit: 'mg',
                  icon: Icons.eco, // 자연/바나나를 나타내는 생태 아이콘
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NutritionCard(
                  label: 'Magnesium',
                  value: magnesium ?? '-',
                  unit: 'mg',
                  icon: Icons.landscape, // 자연/땅을 나타내는 풍경 아이콘
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 세 번째 행: Iron, Zinc, Cholesterol
          Row(
            children: [
              Expanded(
                child: _NutritionCard(
                  label: 'Iron',
                  value: iron ?? '-',
                  unit: 'mg',
                  icon: Icons.build, // 금속/철을 나타내는 도구 아이콘
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NutritionCard(
                  label: 'Zinc',
                  value: zinc ?? '-',
                  unit: 'mg',
                  icon: Icons.science, // 과학/미네랄을 나타내는 과학 아이콘
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NutritionCard(
                  label: 'Cholesterol',
                  value: cholesterol ?? '-',
                  unit: 'mg',
                  icon: Icons.favorite, // 심장/혈관 건강을 나타내는 하트 아이콘
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onBack;
  const _ErrorState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Record not found', style: AppFonts.bodyMedium),
            const SizedBox(height: 16),
            TextButton(onPressed: onBack, child: const Text('Go back')),
          ],
        ),
      ),
    );
  }
}
