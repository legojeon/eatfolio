import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatfolio/presentation/screens/detail_page.dart';
import 'package:flutter/material.dart';

import 'package:eatfolio/core/fonts.dart';
import 'package:eatfolio/presentation/widgets/cards.dart';
import 'package:eatfolio/core/utils/filter_options.dart';
import 'package:eatfolio/core/utils/meal_time.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  final FilterOptions? filters;
  final String? userId;

  const SearchPage({
    super.key,
    required this.initialQuery,
    this.filters,
    this.userId,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _searchText = widget.initialQuery.trim();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _clampStars(dynamic v) {
    final n = (v is int) ? v : int.tryParse('$v') ?? 0;
    if (n < 0) return 0;
    if (n > 5) return 5;
    return n;
  }

  Query<Map<String, dynamic>> _buildQuery() {
    final base = FirebaseFirestore.instance.collection('Photos');
    Query<Map<String, dynamic>> q = base;

    final uid = widget.userId;
    if (uid != null && uid.isNotEmpty) {
      q = q.where('user_id', isEqualTo: uid);
    }

    final f = widget.filters;
    final hasMinStars = f?.minStars != null && f!.minStars! > 0;

    // Equality filters
    if (f?.mealTimes != null && f!.mealTimes!.isNotEmpty) {
      q = q.where('meal_time', whereIn: f.mealTimes);
    }
    if (f?.categories != null && f!.categories!.isNotEmpty) {
      q = q.where('food_category', whereIn: f.categories);
    }

    final prefix = _searchText;

    if (prefix.isEmpty) {
      // ✅ Empty search (your current logic)
      if (hasMinStars) {
        q = q
            .where('rating', isGreaterThanOrEqualTo: f!.minStars)
            .orderBy('rating') // inequality field must be first
            .orderBy('created_at', descending: true);
      } else {
        q = q.orderBy('created_at', descending: true);
      }
    } else {
      // 🔎 Prefix search + rating filter (server-side)
      if (hasMinStars) {
        final min = f!.minStars!;
        q = q
            .where('rating', isGreaterThanOrEqualTo: min)
            .orderBy('rating') // 1) inequality field first
            .orderBy('food_name') // 2) prefix field
            .orderBy('created_at', descending: true) // 3) tie-breaker
            .startAt([min, prefix]) // cursor across (rating, food_name)
            .endAt([5, prefix + '\uf8ff']);
      } else {
        // no rating constraint → improved prefix query
        // Use a more restrictive range for better prefix matching
        final upperBound = prefix + '\uf8ff';
        q = q
            .where('food_name', isGreaterThanOrEqualTo: prefix)
            .where('food_name', isLessThan: upperBound)
            .orderBy('food_name')
            .orderBy('created_at', descending: true);
      }
    }

    return q;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Search food…',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchText = value.trim()),
            onSubmitted: (value) {
              setState(() => _searchText = value.trim());
              FocusScope.of(context).unfocus();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
            onPressed: () {
              _controller.clear();
              setState(() => _searchText = '');
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _buildQuery().snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];

            // 🔍 Client-side prefix filtering for more accurate results
            final filteredDocs = docs.where((doc) {
              if (_searchText.isEmpty) return true;

              final foodName = (doc.data()['food_name'] ?? '') as String? ?? '';
              return foodName.toLowerCase().startsWith(
                _searchText.toLowerCase(),
              );
            }).toList();

            if (filteredDocs.isEmpty) {
              final filterBadge = (widget.filters?.hasAny ?? false)
                  ? ' with filters'
                  : '';
              final prompt = _searchText.isEmpty
                  ? 'No results'
                  : 'No results for "$_searchText"';
              return Center(
                child: Text('$prompt$filterBadge', style: AppFonts.bodySmall),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final data = filteredDocs[index].data();

                final foodName = (data['food_name'] ?? '') as String? ?? '';
                final rating = _clampStars(data['rating']);
                final imagePath = (data['image_path'] ?? '') as String?;
                final mealTimeRaw = (data['meal_time'] ?? '') as String? ?? '';
                final mealTimeKo = toKoMealTime(mealTimeRaw); // ✅ shared map
                final categoryRaw =
                    (data['food_category'] ?? '') as String? ?? '';
                final category = categoryRaw.isEmpty
                    ? 'Uncategorized'
                    : categoryRaw;

                final docSnap = filteredDocs[index];
                final recordId = (data['record_id'] as String?) ?? docSnap.id;

                return FoodCard(
                  food: foodName.isEmpty ? '(No name)' : foodName,
                  time: mealTimeKo.isEmpty ? 'Unknown' : mealTimeKo,
                  category: category,
                  stars: rating,
                  imagePath: imagePath,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPage(recordId: recordId),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
