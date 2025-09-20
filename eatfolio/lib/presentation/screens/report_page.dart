import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatfolio/core/fonts.dart';
import 'package:eatfolio/presentation/widgets/cards.dart'; // BoxCard
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/provider_auth.dart' as auth;

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('user_reports')
              .doc(userId)
              .snapshots(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || !snap.data!.exists) {
              return Center(
                child: Text('No report yet', style: AppFonts.bodyMedium),
              );
            }

            final data = snap.data!.data()!;
            final report = Map<String, dynamic>.from(data['report'] ?? {});

            final score = ((report['score'] ?? 0) as num).toInt();

            final avg = Map<String, dynamic>.from(
              report['avg_nutrients'] ?? {},
            );
            final calories = (avg['calories'] ?? '-') as String;
            final protein = (avg['protein'] ?? '-') as String;
            final fat = (avg['fat'] ?? '-') as String;
            final carbs = (avg['carbohydrate'] ?? '-') as String;

            // pos/neg analysis
            final posAnalysis = (report['pos_analysis'] ?? '') as String;
            final negAnalysis = (report['neg_analysis'] ?? '') as String;

            final feedback = (report['feedback'] ?? '') as String;
            final recMeal = List<String>.from(
              (report['rec_meal'] ?? const <dynamic>[]).map(
                (e) => e.toString(),
              ),
            );

            final createdAtText = _formatTimestamp(data['created_at']);

            return ListView(
              children: [
                // ===== HERO: Score + meta (orange theme) =====
                _HeroScoreCard(
                  score: score,
                  updatedAtText: createdAtText,
                  subtitle: '이번 주 식단 점수',
                ),
                const SizedBox(height: 16),

                // ===== Avg nutrients (progress bars) =====
                Text('끼니 당 평균 영양소', style: AppFonts.heading3),
                const SizedBox(height: 8),
                BoxCard(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    child: Column(
                      children: [
                        _nutrientBarRow(
                          context,
                          label: '칼로리',
                          valueLabel: calories,
                          percent: _pctOf(calories, target: 650, unit: 'kcal'),
                          color: const Color(0xFFFF8A65), // orange
                        ),
                        const SizedBox(height: 10),
                        _nutrientBarRow(
                          context,
                          label: '단백질',
                          valueLabel: protein,
                          percent: _pctOf(protein, target: 30, unit: 'g'),
                          color: const Color(0xFF26A69A),
                        ),
                        const SizedBox(height: 10),
                        _nutrientBarRow(
                          context,
                          label: '탄수화물',
                          valueLabel: carbs,
                          percent: _pctOf(carbs, target: 85, unit: 'g'),
                          color: const Color(0xFF42A5F5),
                        ),
                        const SizedBox(height: 10),
                        _nutrientBarRow(
                          context,
                          label: '지방',
                          valueLabel: fat,
                          percent: _pctOf(fat, target: 20, unit: 'g'),
                          color: const Color(0xFFFFC107),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '기준치: 일반 성인 1끼 권장량 근사치',
                            style: AppFonts.caption.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== Analysis (pos/neg) =====
                Text('분석', style: AppFonts.heading3),
                const SizedBox(height: 8),
                BoxCard(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        _AnalysisCard(
                          text: posAnalysis.isEmpty ? '—' : posAnalysis,
                          positive: true,
                        ),
                        const SizedBox(height: 8),
                        _AnalysisCard(
                          text: negAnalysis.isEmpty ? '—' : negAnalysis,
                          positive: false,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== Feedback =====
                Text('피드백', style: AppFonts.heading3),
                const SizedBox(height: 8),
                BoxCard(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFF8A65,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tips_and_updates,
                            color: Color(0xFFFF8A65),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feedback.isEmpty ? '—' : feedback,
                            style: AppFonts.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ===== Recommended meals (HORIZONTAL CARDS) =====
                Text('추천 음식', style: AppFonts.heading3),
                const SizedBox(height: 8),
                if (recMeal.isEmpty)
                  BoxCard(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'No recommendations yet',
                        style: AppFonts.bodyMedium,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: _recListHeight(context),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: recMeal.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final title = recMeal[index];
                        return _RecMealHorizontalCard(
                          title: title,
                          accent: const Color(0xFFFFA726),
                          onTap: () {
                            // TODO: 상세 화면 이동 or 검색 등
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _formatTimestamp(dynamic ts) {
    if (ts == null) return '—';
    try {
      final d = (ts as Timestamp).toDate();
      return DateFormat('yyyy-MM-dd HH:mm').format(d);
    } catch (_) {
      return '—';
    }
  }

  // Height helper for the horizontal rec list (fits up to 3 lines of text).
  static double _recListHeight(BuildContext context) {
    // paddings & icon block
    const double verticalPadding = 12 + 10 + 12; // top padding + gap + bottom
    const double iconBlock = 44; // icon container height
    // approximate line height based on default text + scale; AppFonts.bodyMedium uses ~1.3 height
    final baseFont = DefaultTextStyle.of(context).style.fontSize ?? 14;
    final ts = MediaQuery.textScaleFactorOf(context);
    final lineHeight = baseFont * 1.3 * ts;
    const maxLines = 3;
    final textBlock = lineHeight * maxLines;

    // extra margin for shadows/borders
    return verticalPadding + iconBlock + textBlock + 20;
  }

  // ---------- UI helpers ----------
  static Widget _nutrientBarRow(
    BuildContext context, {
    required String label,
    required String valueLabel,
    required double percent,
    required Color color,
  }) {
    final pct = percent.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: AppFonts.bodyMedium)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(valueLabel, style: AppFonts.caption),
      ],
    );
  }

  // Parse "58g"/"721kcal" into % of target
  static double _pctOf(
    String raw, {
    required num target,
    required String unit,
  }) {
    final n = _numFromLabel(raw, unit);
    if (target <= 0) return 0;
    return (n / target).toDouble();
  }

  static num _numFromLabel(String raw, String unit) {
    if (raw.isEmpty) return 0;
    final cleaned = raw.toLowerCase().replaceAll(unit.toLowerCase(), '').trim();
    final v = num.tryParse(cleaned);
    return v ?? 0;
  }
}

// ===== HERO Score Card (orange theme) =====
class _HeroScoreCard extends StatelessWidget {
  final int score;
  final String subtitle;
  final String updatedAtText;

  const _HeroScoreCard({
    required this.score,
    required this.subtitle,
    required this.updatedAtText,
  });

  Color _ringColor(int s) {
    if (s >= 85) return const Color(0xFFFF7043); // deep orange
    if (s >= 70) return const Color(0xFFFF8A65); // orange
    if (s >= 50) return const Color(0xFFFFB74D); // amber-ish
    return const Color(0xFFE53935); // red for low
  }

  String _verdict(int s) {
    if (s >= 85) return '아주 좋아요!';
    if (s >= 70) return '좋아요';
    if (s >= 50) return '보통이에요';
    return '개선이 필요해요';
  }

  @override
  Widget build(BuildContext context) {
    final ring = _ringColor(score);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA726), Color(0xFFFF7043)], // orange gradient
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Row(
          children: [
            _GaugeRing(score: score, color: ring),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: AppFonts.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _verdict(score),
                    style: AppFonts.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '최근 업데이트: $updatedAtText',
                    style: AppFonts.caption.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeRing extends StatelessWidget {
  final int score;
  final Color color;
  const _GaugeRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 10,
            color: Colors.white.withValues(alpha: 0.95),
            backgroundColor: Colors.white24,
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  '$score',
                  style: AppFonts.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Analysis card (positive/negative) =====
class _AnalysisCard extends StatelessWidget {
  final String text;
  final bool positive;
  const _AnalysisCard({required this.text, required this.positive});

  @override
  Widget build(BuildContext context) {
    final base = positive ? const Color(0xFF26A69A) : const Color(0xFFE53935);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: base.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive ? Icons.check_circle_rounded : Icons.error_rounded,
            color: base,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppFonts.bodySmall)),
        ],
      ),
    );
  }
}

// ===== Recommended Meal Horizontal Card =====
class _RecMealHorizontalCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color accent;

  const _RecMealHorizontalCard({
    required this.title,
    this.onTap,
    this.accent = const Color(0xFFFFA726),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 200, // ✅ fixed width
        // ✅ height is flexible; let content define it
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: accent.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.restaurant_menu, color: accent, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppFonts.bodyMedium.copyWith(height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
