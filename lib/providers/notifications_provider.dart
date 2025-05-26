// lib/providers/notifications_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsProvider extends ChangeNotifier {
  static const _keyNearby = 'notify_nearby_shops';

  bool _notifyNearbyShops = true;
  bool get notifyNearbyShops => _notifyNearbyShops;

  NotificationsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notifyNearbyShops = prefs.getBool(_keyNearby) ?? true;
    notifyListeners();
  }

  Future<void> setNotifyNearbyShops(bool value) async {
    _notifyNearbyShops = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNearby, value);
  }
}
