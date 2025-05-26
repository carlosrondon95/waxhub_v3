// lib/providers/notifications_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsProvider extends ChangeNotifier {
  static const _keyNearby = 'notify_nearby_shops';
  static const _keyInterval = 'weekly_summary_interval';

  bool _notifyNearbyShops = true;
  int _summaryIntervalDays = 7; // por defecto semanal

  bool get notifyNearbyShops => _notifyNearbyShops;
  int get summaryIntervalDays => _summaryIntervalDays;

  NotificationsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sp = await SharedPreferences.getInstance();
    _notifyNearbyShops = sp.getBool(_keyNearby) ?? _notifyNearbyShops;
    _summaryIntervalDays = sp.getInt(_keyInterval) ?? _summaryIntervalDays;
    notifyListeners();
  }

  Future<void> setNotifyNearbyShops(bool val) async {
    _notifyNearbyShops = val;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyNearby, val);
  }

  Future<void> setSummaryIntervalDays(int days) async {
    _summaryIntervalDays = days;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_keyInterval, days);
    // aquí podrías reprogramar tu NotificationService.scheduleWeeklySummary()
  }
}
