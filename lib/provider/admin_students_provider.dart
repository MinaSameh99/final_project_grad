import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class PendingUser {
  final int userId;
  final String name;
  final String email;
  final String role;

  const PendingUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory PendingUser.fromJson(Map<String, dynamic> json) {
    return PendingUser(
      userId: json['user_id'] as int,
      name:   json['name']?.toString() ?? '',
      email:  json['email']?.toString() ?? '',
      role:   json['role']?.toString() ?? '',
    );
  }
}

class AdminStudentsProvider extends ChangeNotifier {
  List<PendingUser> _pendingUsers = [];
  List<PendingUser> get pendingUsers => List.unmodifiable(_pendingUsers);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get errorMessage => _error;

  Future<void> loadPendingUsers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await ApiService.getPendingUsers();
      _pendingUsers = data
          .map((e) => PendingUser.fromJson(e as Map<String, dynamic>))
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

  Future<bool> approveUser(int userId) async {
    try {
      await ApiService.approveUser(userId);
      _pendingUsers.removeWhere((u) => u.userId == userId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}