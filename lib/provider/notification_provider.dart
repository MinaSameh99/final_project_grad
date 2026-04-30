import 'package:flutter/material.dart';
import 'package:sams/models/notification_model.dart';
import 'package:sams/services/api.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await ApiService.getMyNotifications();
      _notifications = (data)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(int id) async {
    try {
      await ApiService.markNotificationRead(id);
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1) {
        _notifications[idx] = NotificationModel(
          id: _notifications[idx].id,
          title: _notifications[idx].title,
          message: _notifications[idx].message,
          type: _notifications[idx].type,
          isRead: true,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  void clear() {
    _notifications = [];
    _error = '';
    notifyListeners();
  }
}