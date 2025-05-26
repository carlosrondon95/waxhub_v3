// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton plugin instance
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Navigator key for handling taps
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Channel IDs
  static const String _shopChannelId = 'nearby_shop_channel';
  static const String _summaryChannelId = 'summary_channel';
  static const int _summaryNotificationId = 0;

  /// Initialize plugin and timezones
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // iOS permissions
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Show an immediate notification for a nearby shop
  static Future<void> showNearbyShopNotification(
    String shopName,
    double distanceMeters,
  ) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final androidDetails = AndroidNotificationDetails(
      _shopChannelId,
      'Tiendas cercanas',
      channelDescription: 'Alertas de vinilo cerca de ti',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      '¡Tienda cercana!',
      'Hay una tienda a ${distanceMeters.toStringAsFixed(0)} m: $shopName',
      details,
      payload: '{"type":"nearby_shop","shop":"$shopName"}',
    );
  }

  /// Schedule or reschedule your summary notification
  static Future<void> scheduleSummary({
    required int intervalDays,
    int hour = 9,
    int minute = 0,
  }) async {
    // Cancel any existing summary
    await _plugin.cancel(_summaryNotificationId);

    final androidDetails = AndroidNotificationDetails(
      _summaryChannelId,
      'Resumen',
      channelDescription: 'Tu resumen de actividad',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (intervalDays == 1) {
      // Diario
      await _plugin.zonedSchedule(
        _summaryNotificationId,
        'Tu resumen diario',
        'Consulta tu actividad del día',
        _nextInstanceOfTime(hour, minute),
        details,
        payload: '{"type":"daily_summary"}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } else if (intervalDays == 7) {
      // Semanal
      await _plugin.zonedSchedule(
        _summaryNotificationId,
        'Tu resumen semanal',
        'Consulta tu actividad de la semana',
        _nextInstanceOfWeekday(hour, minute),
        details,
        payload: '{"type":"weekly_summary"}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } else if (intervalDays == 30) {
      // Mensual
      await _plugin.zonedSchedule(
        _summaryNotificationId,
        'Tu resumen mensual',
        'Consulta tu actividad del mes',
        _nextInstanceOfMonthDay(hour, minute),
        details,
        payload: '{"type":"monthly_summary"}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } else {
      // Fallback to daily
      await scheduleSummary(intervalDays: 1, hour: hour, minute: minute);
    }
  }

  // — Helpers to compute next trigger times —

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var sched = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (sched.isBefore(now)) sched = sched.add(const Duration(days: 1));
    return sched;
  }

  static tz.TZDateTime _nextInstanceOfWeekday(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var sched = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (sched.weekday != now.weekday || sched.isBefore(now)) {
      sched = sched.add(const Duration(days: 1));
    }
    return sched;
  }

  static tz.TZDateTime _nextInstanceOfMonthDay(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    final day = now.day;
    var sched = tz.TZDateTime(tz.local, now.year, now.month, day, hour, minute);
    if (sched.isBefore(now)) {
      sched = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        day,
        hour,
        minute,
      );
    }
    return sched;
  }

  /// Handle taps on notifications
  static void _onNotificationResponse(NotificationResponse resp) {
    final payload = resp.payload;
    if (payload == null) return;

    if (payload.contains('daily_summary') ||
        payload.contains('weekly_summary') ||
        payload.contains('monthly_summary')) {
      navigatorKey.currentState?.pushNamed('/weekly_summary');
    } else if (payload.contains('nearby_shop')) {
      // Optionally navigate to a shop detail
      // navigatorKey.currentState?.pushNamed('/detalle_tienda', extra: ...);
    }
  }
}
