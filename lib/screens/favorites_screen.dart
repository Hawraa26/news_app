import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../services/favorites_service.dart';
import '../widgets/article_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final FavoritesService favoritesService =
    FavoritesService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأخبار المفضلة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: StreamBuilder<List<Article>>(
          stream: favoritesService.favoritesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _buildError(context);
            }

            final favorites =
                snapshot.data ?? [];

            if (favorites.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 24,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return ArticleCard(
                  article: favorites[index],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_border_rounded,
                size: 60,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'لا توجد أخبار مفضلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'عند إضافة أي خبر إلى المفضلة، '
                  'سيظهر هنا لتتمكني من الوصول إليه بسهولة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 25),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.explore_outlined,
              ),
              label: const Text(
                'استكشاف الأخبار',
              ),
              style: OutlinedButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.error
                    .withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 55,
                color: colorScheme.error,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'تعذر تحميل الأخبار المفضلة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'حدث خطأ أثناء تحميل الأخبار. '
                  'حاولي مرة أخرى.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color:
                colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const FavoritesScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'إعادة المحاولة',
              ),
              style: FilledButton.styleFrom(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}