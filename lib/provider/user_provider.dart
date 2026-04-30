import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class UserProvider extends ChangeNotifier {
  // Profile fields loaded from FastAPI /student/profile
  int studentId = 0;
  String name = '';
  String email = '';
  String uniId = '';
  String department = '';
  int level = 0;
  String phone = '';
  double gpa = 0.0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  /// True when this student has completed their profile (has a uni_id set).
  bool get profileComplete => uniId.isNotEmpty;

  // ── Called right after a successful login ────────────────────────────────────
  Future<void> loadStudentProfile() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await ApiService.getStudentProfile();
      studentId = data['student_id'] as int? ?? 0;
      uniId     = data['university_id']?.toString() ?? '';
      department= data['department']?.toString() ?? '';
      level     = data['level'] as int? ?? 0;
      phone     = data['phone']?.toString() ?? '';
      gpa       = (data['gpa'] as num?)?.toDouble() ?? 0.0;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLoginUser(String userEmail) async {
    email = userEmail;
    await loadStudentProfile();
  }

  Future<Map<String, dynamic>> getDashboard() async {
    return ApiService.getStudentDashboard();
  }

  Future<void> logout() async {
    await ApiService.clearSession();
    studentId  = 0;
    name       = '';
    email      = '';
    uniId      = '';
    department = '';
    level      = 0;
    phone      = '';
    gpa        = 0.0;
    notifyListeners();
  }
}