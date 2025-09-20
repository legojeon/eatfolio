import 'package:eatfolio/presentation/screens/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/fonts.dart';
import '../../core/provider_nav.dart';
import '../../core/provider_auth.dart' as auth;
import '../widgets/buttons.dart';
import '../widgets/cards.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId =
        context.watch<auth.AuthProvider>().currentUser?.uid ?? 'guest';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('eatfolio', style: AppFonts.logotext),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      extendBody: true,

      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Stats stream ---
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('user_stats')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap.hasData || !snap.data!.exists) {
                    return Center(
                      child: Text('No stats yet', style: AppFonts.bodyMedium),
                    );
                  }

                  final data = snap.data!.data()!;
                  // Extract & coerce
                  final avgCalories = _asNum(data['avg_calories']).toDouble();
                  final avgMealTime = Map<String, dynamic>.from(
                    data['avg_meal_time'] ?? {},
                  );
                  final macroRatio = (data['macro_ratio_string'] ?? '')
                      .toString();
                  final macros = Map<String, dynamic>.from(
                    data['macros_total_g'] ?? {},
                  );
                  final carb = _asNum(macros['carbohydrate']).toDouble();
                  final protein = _asNum(macros['protein']).toDouble();
                  final fat = _asNum(macros['fat']).toDouble();

                  final mealCount = _asNum(data['meal_count']).toInt();

                  final mealTimeStats = Map<String, dynamic>.from(
                    data['meal_time_stats'] ?? {},
                  );
                  final b = Map<String, dynamic>.from(
                    mealTimeStats['breakfast'] ?? {},
                  );
                  final l = Map<String, dynamic>.from(
                    mealTimeStats['lunch'] ?? {},
                  );
                  final d = Map<String, dynamic>.from(
                    mealTimeStats['dinner'] ?? {},
                  );

                  final proteinEggEq = _asNum(
                    data['protein_egg_equiv'],
                  ).toDouble();
                  final proteinTotal = _asNum(
                    data['protein_total_g'],
                  ).toDouble();

                  final sodiumRamenEq = _asNum(
                    data['sodium_ramen_equiv'],
                  ).toDouble();
                  final sodiumTotal = _asNum(
                    data['sodium_total_mg'],
                  ).toDouble();

                  final totalCalories = _asNum(
                    data['total_calories'],
                  ).toDouble();
                  final totalWeight = _asNum(data['total_weight_g']).toDouble();

                  final updatedAtStr = _formatTimestamp(data['updated_at']);

                  return ListView(
                    children: [
                      // --- Overview (each stat is its own small card with icon) ---
                      Text('요약', style: AppFonts.heading3),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: '끼니',
                                  valueText: mealCount.toString(),
                                  icon: Icons.restaurant,
                                  iconColor: const Color(0xFF5C6BC0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  label: '총 칼로리',
                                  valueText: '${_fmt(totalCalories, 0)}kcal',
                                  icon: Icons.local_fire_department,
                                  iconColor: const Color(0xFFFF7043),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: '평균 칼로리',
                                  valueText: '${_fmt(avgCalories, 0)}kcal',
                                  icon: Icons.speed,
                                  iconColor: const Color(0xFF26A69A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  label: '총 섭취량',
                                  valueText: '${_fmt(totalWeight, 0)}g',
                                  icon: Icons.monitor_weight,
                                  iconColor: const Color(0xFF8E24AA),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  label: '총 단백질',
                                  valueText: '${_fmt(proteinTotal, 0)}g',
                                  icon: Icons.fitness_center,
                                  iconColor: const Color(0xFFF44336),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _StatCard(
                                  label: '총 나트륨',
                                  valueText: '${_fmt(sodiumTotal, 0)}mg',
                                  icon: Icons.water_drop,
                                  iconColor: const Color(0xFF2196F3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // --- Total nutrients consumed ---
                      Text('총 영양소 섭취량', style: AppFonts.heading3),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _MacroCard(
                                  label: '탄수화물',
                                  value: carb,
                                  unit: 'g',
                                  icon: Icons.rice_bowl,
                                  iconColor: const Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MacroCard(
                                  label: '단백질',
                                  value: protein,
                                  unit: 'g',
                                  icon: Icons.fitness_center,
                                  iconColor: const Color(0xFFF44336),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _MacroCard(
                                  label: '지방',
                                  value: fat,
                                  unit: 'g',
                                  icon: Icons.local_pizza,
                                  iconColor: const Color(0xFFFFC107),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Ratio as separate widget with wording
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('당신의 탄단지 비율은...', style: AppFonts.caption),
                                const SizedBox(height: 4),
                                Text(macroRatio, style: AppFonts.bodyLarge),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- Equivalents  ---
                      Text('비교', style: AppFonts.heading3),
                      const SizedBox(height: 8),

                      // Protein → Eggs
                      BoxCard(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: EquivCard(
                            title: '단백질 → 계란',
                            intro: "총 단백질을 계란으로 환산하면...",
                            value: proteinEggEq,
                            unitSingular: 'egg',
                            unitPlural: 'eggs',
                            icon: Icons.egg_alt,
                            accent: const Color(0xFFFFD54F),
                          ),
                        ),
                      ),

                      // Sodium → Ramen
                      const SizedBox(height: 12),
                      BoxCard(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: EquivCard(
                            title: '나트륨 → 라면',
                            intro: "총 나트륨을 라면으로 환산하면...",
                            value: sodiumRamenEq,
                            unitSingular: 'ramen',
                            unitPlural: 'ramen',
                            icon: Icons.ramen_dining,
                            accent: const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Average Meal Time (clock-style) ---
                      Text('평균 식사 시간', style: AppFonts.heading3),
                      const SizedBox(height: 8),
                      BoxCard(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _avgTimeRow('아침', avgMealTime['breakfast']),
                              const SizedBox(height: 8),
                              _avgTimeRow('점심', avgMealTime['lunch']),
                              const SizedBox(height: 8),
                              _avgTimeRow('저녁', avgMealTime['dinner']),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- Total Meals (counts only, card layout like macros) ---
                      Text('총 식사', style: AppFonts.heading3),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _MacroCard(
                              label: '아침',
                              value: _asNum(b['count']).toInt(),
                              unit: '',
                              icon: Icons.free_breakfast,
                              iconColor: const Color(0xFFFFC107),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MacroCard(
                              label: '점심',
                              value: _asNum(l['count']).toInt(),
                              unit: '',
                              icon: Icons.lunch_dining,
                              iconColor: const Color(0xFF4CAF50),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _MacroCard(
                              label: '저녁',
                              value: _asNum(d['count']).toInt(),
                              unit: '',
                              icon: Icons.dinner_dining,
                              iconColor: const Color(0xFF9C27B0),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // --- Last updated + Logout ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '최근 업데이트: $updatedAtStr',
                          style: AppFonts.caption.copyWith(color: Colors.grey),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Logout(
                        onPressed: () async {
                          await context.read<auth.AuthProvider>().signOut();
                          context.read<NavigationProvider>().setSelectedIndex(
                            0,
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => SplashPage()),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI Helpers ----------
  Widget _avgTimeRow(String label, dynamic rawValue) {
    final text = _toClockString(rawValue); // -> "8:35" style
    return Row(
      children: [
        Expanded(child: Text(label, style: AppFonts.bodyMedium)),
        Text(text, style: AppFonts.bodyMedium),
      ],
    );
  }

  // ---------- Logic Helpers ----------
  static num _asNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  static String _fmt(num n, int decimals) => n.toStringAsFixed(0);

  static (int, int)? _parseHHMM(String hhmm) {
    final rx = RegExp(r'^(\d{1,2}):(\d{1,2})(?::\d{1,2})?$');
    final m = rx.firstMatch(hhmm.trim());
    if (m == null) return null;
    final h = int.tryParse(m.group(1)!) ?? 0;
    final min = int.tryParse(m.group(2)!) ?? 0;
    if (h < 0 || h > 23 || min < 0 || min > 59) return null;
    return (h, min);
  }

  // -> returns "8:35"
  static String _toClockString(dynamic value) {
    if (value == null) return '-';

    // String formats: "8:5", "08:05", "08:05:00"
    if (value is String) {
      final p = _parseHHMM(value);
      if (p == null) return '-';
      final h = p.$1;
      final m = p.$2;
      return '$h:${m.toString().padLeft(2, '0')}';
    }

    // Firestore Timestamp / DateTime
    if (value is Timestamp) {
      final dt = value.toDate();
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (value is DateTime) {
      return '${value.hour}:${value.minute.toString().padLeft(2, '0')}';
    }

    // Numeric: treat as minutes since midnight
    if (value is num) {
      final total = value.round();
      final h = (total ~/ 60) % 24;
      final m = total % 60;
      return '$h:${m.toString().padLeft(2, '0')}';
    }

    // Map: {hour: 8, minute: 5} or {h:8, m:5}
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final h = _asNum(map['hour'] ?? map['h']).toInt();
      final m = _asNum(map['minute'] ?? map['m']).toInt();
      if (h >= 0 && h <= 23 && m >= 0 && m <= 59) {
        return '$h:${m.toString().padLeft(2, '0')}';
      }
    }

    return '-';
  }

  static String _formatTimestamp(dynamic ts) {
    if (ts == null) return '—';
    DateTime d;
    try {
      if (ts is Timestamp) {
        d = ts.toDate();
      } else if (ts is DateTime) {
        d = ts;
      } else {
        d = DateTime.tryParse(ts.toString()) ?? DateTime.now();
      }
    } catch (_) {
      d = DateTime.now();
    }
    return '${d.year}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

// ===== Small stat card =====
class _StatCard extends StatelessWidget {
  final String label;
  final String valueText;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.valueText,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
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
}

// ===== Macro card widget =====
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
    if (v == null) return unit.isEmpty ? '-' : '-$unit';
    if (v is num) return '${v.toStringAsFixed(0)}$unit';
    final parsed = num.tryParse(v.toString());
    if (parsed != null) return '${parsed.toStringAsFixed(0)}$unit';
    return '$v$unit';
  }
}

class EquivCard extends StatelessWidget {
  final String title;
  final String intro;
  final double value;
  final String unitSingular;
  final String unitPlural;
  final IconData icon;
  final Color accent;

  const EquivCard({
    super.key,
    required this.title,
    required this.intro,
    required this.value,
    required this.unitSingular,
    required this.unitPlural,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final String valueText = _formatPretty(value);
    final String unit = _pluralize(value, unitSingular, unitPlural);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 소제목
          Text(
            title,
            style: AppFonts.caption.copyWith(
              color: accent.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),

          // 멘트 (이탤릭 제거, bodySmall 사용)
          Text(
            intro,
            style: AppFonts.bodySmall.copyWith(
              // fontStyle: FontStyle.normal, // 굳이 지정 안 해도 기본은 normal
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 12),

              // 숫자와 단위는 bodyMedium
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '× ',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: valueText,
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: AppFonts.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _pluralize(double v, String one, String many) {
    final rounded = double.parse(v.toStringAsFixed(1));
    return (rounded == 1.0) ? one : many;
    // 라면은 단복수 동일하게 쓰려면 'ramen','ramen' 전달
  }

  static String _formatPretty(double v) {
    return v.toStringAsFixed(0);
  }
}
