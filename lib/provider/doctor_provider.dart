// lib/provider/doctor_provider.dart

import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class DoctorProvider extends ChangeNotifier {
  int    advisorId  = 0;
  String name       = '';
  String email      = '';
  String department = '';
  String phone      = '';
  List<String>               courses    = [];
  List<Map<String, dynamic>> myStudents = [];
  List<Map<String, dynamic>> myLectures = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  bool get isLoggedIn => advisorId > 0;

  /// True only when both phone and department have been filled in.
  /// Used by login_screen to decide whether to route to /docinfo or /dochome.
  bool get profileComplete =>
      phone.isNotEmpty && department.isNotEmpty;

  // ── Load full profile from FastAPI /advisor/profile ───────────────────────
  Future<void> loadAdvisorProfile() async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      final data = await ApiService.getAdvisorProfile();
      advisorId  = data['advisor_id']   as int?    ?? 0;
      name       = data['advisor_name'] ?.toString() ?? '';
      department = data['department']   ?.toString() ?? '';
      phone      = data['phone']        ?.toString() ?? '';
      courses    = List<String>.from(data['courses'] ?? []);
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyStudents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getMyStudents();
      myStudents = List<Map<String, dynamic>>.from(data);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyLectures() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getMyLectures();
      myLectures = List<Map<String, dynamic>>.from(data);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called right after login — loads full profile to check completeness.
  Future<void> setLoginDoctor(String userEmail) async {
    email = userEmail;
    await loadAdvisorProfile();
  }

  Future<void> logout() async {
    await ApiService.clearSession();
    advisorId  = 0;
    name       = '';
    email      = '';
    department = '';
    phone      = '';
    courses    = [];
    myStudents = [];
    myLectures = [];
    notifyListeners();
  }
}