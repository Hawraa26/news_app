import 'package:shared_preferences/shared_preferences.dart';

import '../models/article_model.dart';
import 'news_api_service.dart';
import 'notification_service.dart';

class NewsNotificationService {
  final NewsApiService _newsApiService = NewsApiService();

  static const String _lastArticleIdKey =
      'last_article_id';

  static const String _notificationsEnabledKey =
      'notifications_enabled';

  Future<bool> areNotificationsEnabled() async {
    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getBool(
      _notificationsEnabledKey,
    ) ??
        true;
  }

  Future<void> setNotificationsEnabled(
      bool enabled,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      _notificationsEnabledKey,
      enabled,
    );
  }

  Future<void> checkForNewNews() async {
    final notificationsEnabled =
    await areNotificationsEnabled();

    if (!notificationsEnabled) {
      return;
    }

    final latestArticle =
    await _newsApiService.fetchLatestNews();

    if (latestArticle == null) {
      return;
    }

    final prefs =
    await SharedPreferences.getInstance();

    final savedArticleId =
    prefs.getString(
      _lastArticleIdKey,
    );

    if (savedArticleId == null) {
      await prefs.setString(
        _lastArticleIdKey,
        latestArticle.id,
      );

      return;
    }

    if (savedArticleId != latestArticle.id) {
      await NotificationService.showNotification(
        title: 'خبر جديد 📰',
        body: latestArticle.title,
      );

      await prefs.setString(
        _lastArticleIdKey,
        latestArticle.id,
      );
    }
  }
}