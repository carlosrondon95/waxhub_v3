// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // Singleton plugin instance
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Navigator key for handling taps
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Channel IDs
  static const String _shopChannelId = 'nearby_shop_channel';

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
