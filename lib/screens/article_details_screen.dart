import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../models/article_model.dart';
import '../services/favorites_service.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailsScreen({
    super.key,
    required this.article,
  });

  @override
  State<ArticleDetailsScreen> createState() =>
      _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState
    extends State<ArticleDetailsScreen> {
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

  Future<void> _openOriginalArticle() async {
    final uri = Uri.parse(
      widget.article.url,
    );

    if (!await canLaunchUrl(uri)) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر فتح الخبر',
          ),
        ),
      );

      return;
    }

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _shareArticle() async {
    final article = widget.article;

    final text =
        '${article.title}\n\n'
        'المصدر: ${article.source}\n\n'
        '${article.url}';

    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: article.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل الخبر',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _shareArticle,
            tooltip: 'مشاركة الخبر',
            icon: const Icon(
              Icons.share_outlined,
            ),
          ),
          _buildFavoriteButton(),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildImage(),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  20,
                  18,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _buildSourceAndDate(),

                    const SizedBox(height: 22),

                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      height: 4,
                      width: 55,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      article.description,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.9,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface,
                      ),
                    ),

                    const SizedBox(height: 35),

                    _buildOriginalArticleButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imageUrl =
        widget.article.imageUrl;

    if (imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    return SizedBox(
      height: 270,
      width: double.infinity,
      child: CachedNetworkImage(
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
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      height: 270,
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 65,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildSourceAndDate() {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.source_outlined,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    widget.article.source,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: colorScheme
                .surfaceContainerHighest,
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color:
                colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
              Text(
                _formatDate(
                  widget.article.publishedAt,
                ),
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    if (_isLoadingFavorite) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: _toggleFavorite,
      tooltip: _isFavorite
          ? 'إزالة من المفضلة'
          : 'إضافة إلى المفضلة',
      icon: Icon(
        _isFavorite
            ? Icons.star_rounded
            : Icons.star_border_rounded,
        color: Colors.amber,
      ),
    );
  }

  Widget _buildOriginalArticleButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: FilledButton.icon(
        onPressed: _openOriginalArticle,
        icon: const Icon(
          Icons.open_in_new_rounded,
        ),
        label: const Text(
          'قراءة الخبر كاملًا',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} - '
        '$hour:$minute';
  }
}