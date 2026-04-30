// lib/services/api.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static String? _token;
  static String? _role;
  static int?    _userId;

  // ══════════════════════════════════════════════════════════════════════════
  //  SESSION
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> saveSession({
    required String token,
    required String role,
    required int    userId,
  }) async {
    _token  = token;
    _role   = role;
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('role',         role);
    await prefs.setInt('user_id',         userId);
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    return _token;
  }

  static Future<String?> getRole() async {
    if (_role != null) return _role;
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('role');
    return _role;
  }

  static Future<int?> getUserId() async {
    if (_userId != null) return _userId;
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
    return _userId;
  }

  static Future<void> clearSession() async {
    _token  = null;
    _role   = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('role');
    await prefs.remove('user_id');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  HEADERS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static const Map<String, String> _publicHeaders = {
    'Content-Type': 'application/json',
    'Accept':       'application/json',
  };

  // ══════════════════════════════════════════════════════════════════════════
  //  AUTH
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String code,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _publicHeaders,
      body: jsonEncode({
        'full_name': fullName,
        'email':     email,
        'password':  password,
        'code':      code,
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _publicHeaders,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handle(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STUDENT
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getStudentProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/profile'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> completeStudentProfile({
    required String uniId,
    required String department,
    required int    level,
    required String phone,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/student/complete-profile'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'uni_id':     uniId,
        'department': department,
        'level':      level,
        'phone':      phone,
      }),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> getStudentDashboard() async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/dashboard'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  /// Returns { "eligible": [...], "locked": [...] }
  static Future<Map<String, dynamic>> getCoursesOverview() async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/courses-overview'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  static Future<List<dynamic>> getEligibleCourses() async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/eligible-courses'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getTranscript() async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/transcript'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> enrollCourse(int courseId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/student/enroll-course'),
      headers: await _authHeaders(),
      body: jsonEncode({'course_id': courseId}),
    );
    return _handle(res);
  }

  static Future<List<dynamic>> getMyEnrollments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/my-enrollments'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  static Future<List<dynamic>> getMyCourses() async {
    final res = await http.get(
      Uri.parse('$baseUrl/student/my-courses'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ADVISOR / DOCTOR
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getAdvisorProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/advisor/profile'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> completeAdvisorProfile({
    required String phone,
    required String department,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/advisor/complete-profile'),
      headers: await _authHeaders(),
      body: jsonEncode({'phone': phone, 'department': department}),
    );
    return _handle(res);
  }

  static Future<List<dynamic>> getMyLectures() async {
    final res = await http.get(
      Uri.parse('$baseUrl/advisor/my-lectures'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  static Future<List<dynamic>> getMyStudents() async {
    final res = await http.get(
      Uri.parse('$baseUrl/advisor/my-students'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> assignGrade({
    required int    enrollmentId,
    required String grade,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/advisor/assign-grade'),
      headers: await _authHeaders(),
      body: jsonEncode({'enrollment_id': enrollmentId, 'grade': grade}),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> createLecture({
    required int    courseId,
    required String title,
    required String description,
    required String room,
    required String lectureDatetime,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/advisor/create-lecture'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'course_id':        courseId,
        'title':            title,
        'description':      description,
        'room':             room,
        'lecture_datetime': lectureDatetime,
      }),
    );
    return _handle(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ADMIN — USERS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getPendingUsers() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/pending-users'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> approveUser(int userId) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/approve/$userId'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ADMIN — COURSES
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns all courses with advisor name.
  static Future<List<dynamic>> getAllCourses() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/courses'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  /// Creates a new course. Returns {message, course_id, course_name}.
  static Future<Map<String, dynamic>> createCourse({
    required String courseName,
    required String courseCode,
    required int    creditHours,
    required String department,
    required int    level,
    required String semester,
    required int    year,
    required int    advisorId,
    required int    capacity,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/create-course'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'course_name':  courseName,
        'course_code':  courseCode,
        'credit_hours': creditHours,
        'department':   department,
        'level':        level,
        'semester':     semester,
        'year':         year,
        'advisor_id':   advisorId,
        'capacity':     capacity,
      }),
    );
    return _handle(res);
  }

  /// Deletes a course by ID.
  static Future<Map<String, dynamic>> deleteCourse(int courseId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/courses/$courseId'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ADMIN — ADVISORS LIST
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns all active advisors — used to populate advisor dropdown.
  static Future<List<dynamic>> getAdvisors() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/advisors'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  ADMIN — ENROLLMENTS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getPendingEnrollments() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admin/pending-enrollments'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> approveEnrollment(
      int enrollmentId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/approve-enrollment'),
      headers: await _authHeaders(),
      body: jsonEncode({'enrollment_id': enrollmentId}),
    );
    return _handle(res);
  }

  static Future<Map<String, dynamic>> rejectEnrollment(
      int enrollmentId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/reject-enrollment'),
      headers: await _authHeaders(),
      body: jsonEncode({'enrollment_id': enrollmentId}),
    );
    return _handle(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getMyNotifications() async {
    final res = await http.get(
      Uri.parse('$baseUrl/notifications/my'),
      headers: await _authHeaders(),
    );
    return _handle(res) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> markNotificationRead(
      int notifId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/notifications/read/$notifId'),
      headers: await _authHeaders(),
    );
    return _handle(res);
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  RESPONSE HANDLER
  // ══════════════════════════════════════════════════════════════════════════

  static dynamic _handle(http.Response res) {
    debugPrint('📡 ${res.request?.method} ${res.request?.url}');
    debugPrint('📥 ${res.statusCode} → ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      return jsonDecode(res.body);
    }

    String detail = 'Server error (${res.statusCode})';
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body.containsKey('detail')) {
        detail = body['detail'].toString();
      }
    } catch (_) {}

    throw ApiException(detail, res.statusCode);
  }
}

class ApiException implements Exception {
  final String message;
  final int    statusCode;
  const ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}