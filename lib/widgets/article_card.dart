import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/article_model.dart';
import '../screens/article_details_screen.dart';
import '../services/favorites_service.dart';

class ArticleCard extends StatefulWidget {
  final Article article;

  const ArticleCard({
    super.key,
    required this.article,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  final FavoritesService _favoritesService =
  FavoritesService();

  bool _isFavorite = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final result = await _favoritesService.isFavorite(
      widget.article.id,
    );

    if (!mounted) return;

    setState(() {
      _isFavorite = result;
      _isLoadingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final newValue = !_isFavorite;

    setState(() {
      _isFavorite = newValue;
    });

    try {
      if (newValue) {
        await _favoritesService.addFavorite(
          widget.article,
        );
      } else {
        await _favoritesService.removeFavorite(
          widget.article.id,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFavorite = !newValue;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ، حاولي مرة أخرى',
          ),
        ),
      );
    }
  }
  Future<void> _openArticle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailsScreen(
          article: widget.article,
        ),
      ),
    );

    if (!mounted) return;

    await _loadFavoriteStatus();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(
            alpha: 0.45,
          ),
        ),
      ),
      child: InkWell(
        onTap: _openArticle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                15,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.55,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: 0.10,
                          ),
                          borderRadius:
                          BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.source_outlined,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            ConstrainedBox(
                              constraints:
                              const BoxConstraints(
                                maxWidth: 120,
                              ),
                              child: Text(
                                article.source,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color:
                        colorScheme.onSurfaceVariant,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        _formatDate(
                          article.publishedAt,
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          color:
                          colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl = widget.article.imageUrl;

    return SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (
                  context,
                  url,
                  ) {
                return _buildImagePlaceholder();
              },
              errorWidget: (
                  context,
                  url,
                  error,
                  ) {
                return _buildImagePlaceholder();
              },
            )
          else
            _buildImagePlaceholder(),

          Positioned(
            top: 12,
            left: 12,
            child: Material(
              color: Colors.black.withValues(
                alpha: 0.55,
              ),
              shape: const CircleBorder(),
              child: _isLoadingFavorite
                  ? const Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
                  : IconButton(
                onPressed: _toggleFavorite,
                tooltip: _isFavorite
                    ? 'إزالة من المفضلة'
                    : 'إضافة إلى المفضلة',
                icon: Icon(
                  _isFavorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: _isFavorite
                      ? Colors.amber
                      : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 55,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} - $hour:$minute';
  }
}