// lib/provider/admin_provider.dart

import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class AdminProvider extends ChangeNotifier {
  String name   = '';
  String email  = '';
  int    userId = 0;

  bool get isLoggedIn => userId > 0;

  Future<void> setLoginAdmin({
    required String adminName,
    required String adminEmail,
    required int    adminUserId,
  }) async {
    name   = adminName;
    email  = adminEmail;
    userId = adminUserId;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService.clearSession();
    name   = '';
    email  = '';
    userId = 0;
    notifyListeners();
  }
}