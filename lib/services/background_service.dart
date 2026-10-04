import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

import 'news_notification_service.dart';
import 'notification_service.dart';

const String newsCheckTask = 'news_check_task';


@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // تحميل مفتاح News API في الـ Background Isolate
      await dotenv.load(fileName: ".env");

      // تهيئة الإشعارات في الـ Background Isolate
      await NotificationService.initialize();

      if (task == newsCheckTask) {
        await NewsNotificationService().checkForNewNews();
      }


      return true;
    } catch (e) {
      return false;
    }
  });
}