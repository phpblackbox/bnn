import 'package:bnn/services/auth_service.dart';
import 'package:bnn/services/notification_service.dart';
import 'package:bnn/utils/constants.dart';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  List<dynamic> _data = Constants.fakeNotifications;
  List<dynamic> get data => _data;

  Future<void> getMyNotifications() async {
    loading = true;
    try {
      final meId = _authService.getCurrentUser()?.id;
      if (meId != null) {
        _data = await _notificationService.getNotificationsByUserId(meId);
        notifyListeners();
      }
    } finally {
      loading = false;
    }
  }

  Future<void> readNotificaiton(int noificationId) async {
    await _notificationService.updateNotification(noificationId);
    // Optionally refresh notifications after marking as read
    await getMyNotifications();
  }
}
