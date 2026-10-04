import 'package:flutter/material.dart';

import '../main.dart';
import '../services/news_notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {
  final NewsNotificationService
  _notificationService =
  NewsNotificationService();

  bool _notificationsEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled =
    await _notificationService
        .areNotificationsEnabled();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled =
          notificationsEnabled;
      _isLoading = false;
    });
  }

  Future<void> _changeNotifications(
      bool value,
      ) async {
    setState(() {
      _notificationsEnabled = value;
    });

    await _notificationService
        .setNotificationsEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    final isDarkMode =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // عنوان الصفحة
              const Text(
                'تخصيص التطبيق',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'تحكمي بالمظهر والإشعارات حسب تفضيلاتك.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                  colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 30),

              // المظهر
              const Text(
                'المظهر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: colorScheme
                    .surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: SwitchListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  value: isDarkMode,
                  onChanged: (_) {
                    MyApp.of(context)
                        ?.toggleTheme();
                  },
                  secondary: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color:
                      colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'الوضع الليلي',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      isDarkMode
                          ? 'الوضع الليلي مفعّل'
                          : 'الوضع الفاتح مفعّل',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // الإشعارات
              const Text(
                'الإشعارات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: colorScheme
                    .surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: SwitchListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  value:
                  _notificationsEnabled,
                  onChanged:
                  _changeNotifications,
                  secondary: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _notificationsEnabled
                          ? Icons
                          .notifications_active_rounded
                          : Icons
                          .notifications_off_rounded,
                      color:
                      colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'إشعارات الأخبار',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 4,
                    ),
                    child: Text(
                      _notificationsEnabled
                          ? 'ستصلك إشعارات عند وجود خبر جديد'
                          : 'إشعارات الأخبار متوقفة',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // معلومات التطبيق
              const Text(
                'حول التطبيق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: colorScheme
                    .surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary
                          .withValues(
                        alpha: 0.12,
                      ),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.article_outlined,
                      color:
                      colorScheme.primary,
                    ),
                  ),
                  title: const Text(
                    'تطبيق الأخبار',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'متابعة آخر الأخبار في مكان واحد',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'تطبيق الأخبار',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme
                      .onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}



