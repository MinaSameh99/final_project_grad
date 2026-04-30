import 'package:flutter/material.dart';
import 'package:sams/services/api.dart';

class PendingEnrollment {
  final int enrollmentId;
  final int studentId;
  final int courseId;
  final String status;

  const PendingEnrollment({
    required this.enrollmentId,
    required this.studentId,
    required this.courseId,
    required this.status,
  });

  factory PendingEnrollment.fromJson(Map<String, dynamic> json) {
    return PendingEnrollment(
      enrollmentId: json['enrollment_id'] as int,
      studentId:    json['student_id'] as int,
      courseId:     json['course_id'] as int,
      status:       json['status']?.toString() ?? 'pending',
    );
  }
}

class AdminDoctorsProvider extends ChangeNotifier {
  List<PendingEnrollment> _enrollments = [];
  List<PendingEnrollment> get enrollments => List.unmodifiable(_enrollments);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get errorMessage => _error;

  Future<void> loadPendingEnrollments() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await ApiService.getPendingEnrollments();
      _enrollments = data
          .map((e) => PendingEnrollment.fromJson(e as Map<String, dynamic>))
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

  Future<bool> approveEnrollment(int enrollmentId) async {
    try {
      await ApiService.approveEnrollment(enrollmentId);
      _enrollments.removeWhere((e) => e.enrollmentId == enrollmentId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectEnrollment(int enrollmentId) async {
    try {
      await ApiService.rejectEnrollment(enrollmentId);
      _enrollments.removeWhere((e) => e.enrollmentId == enrollmentId);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }
}